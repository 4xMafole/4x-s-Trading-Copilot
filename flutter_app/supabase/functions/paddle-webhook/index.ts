import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Secrets — add these in Supabase Dashboard > Edge Functions > Secrets
// PADDLE_API_KEY   → Paddle Dashboard > Developer Tools > API Keys
// RESEND_API_KEY   → resend.com > API Keys (free tier: 3,000 emails/month)

const PADDLE_API_KEY = Deno.env.get("PADDLE_API_KEY") || "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") || "";
const FROM_EMAIL = "noreply@locotrader.app";

// ── Email sender via Resend ──────────────────────────────────────────
async function sendEmail(to: string, subject: string, html: string) {
  if (!RESEND_API_KEY || !to) return;
  try {
    await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from: FROM_EMAIL, to, subject, html }),
    });
  } catch (e) {
    console.error("Email send failed:", e);
  }
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type, paddle-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.text();
  let event;
  try {
    event = JSON.parse(body);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  // Only process completed transactions
  if (event.event_type !== "transaction.completed") {
    return new Response(
      JSON.stringify({ received: true, skipped: event.event_type }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  const data = event.data;
  const transactionId = data.id || "";
  const customerId = data.customer_id || "";
  const items = data.items || [];
  const lineItems = data.details?.line_items || [];
  const customData = data.custom_data || {};

  // ── Detect product type ──────────────────────────────────────────────
  const priceDesc = (items[0]?.price?.description || "").toLowerCase();
  const productName = (lineItems[0]?.product?.name || "").toLowerCase();
  const combined = priceDesc + " " + productName;

  let paymentType = "unknown";
  if (combined.includes("lifetime") || combined.includes("pro")) {
    paymentType = "lifetime_pro";
  } else if (combined.includes("feature")) {
    paymentType = "feature_request";
  }

  // Amount in dollars (Paddle sends in cents)
  const totalAmount = data.details?.totals?.total
    ? parseFloat(data.details.totals.total) / 100
    : 0;

  // ── Fetch customer email from Paddle API ────────────────────────────
  let email = "";
  if (customerId && PADDLE_API_KEY) {
    const apiBase = PADDLE_API_KEY.startsWith("test_")
      ? "https://sandbox-api.paddle.com"
      : "https://api.paddle.com";
    try {
      const res = await fetch(`${apiBase}/customers/${customerId}`, {
        headers: { Authorization: `Bearer ${PADDLE_API_KEY}` },
      });
      if (res.ok) {
        const customer = await res.json();
        email = customer.data?.email || "";
      } else {
        console.error("Paddle customer fetch failed:", await res.text());
      }
    } catch (e) {
      console.error("Failed to fetch customer email:", e);
    }
  }

  // ── Store in Supabase ───────────────────────────────────────────────
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
  const supabase = createClient(supabaseUrl, supabaseKey);

  if (paymentType === "lifetime_pro") {
    const { error } = await supabase.from("early_access_payments").insert({
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });
    if (error) console.error("DB insert error:", error.message);

    // Send confirmation email
    await sendEmail(
      email,
      "You're in — LocoTrader Lifetime Pro confirmed",
      `
      <div style="font-family:Inter,sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#ffffff;">
        <h1 style="font-size:28px;font-weight:900;margin-bottom:8px;">You're in.</h1>
        <p style="color:#60a5fa;font-size:14px;margin-bottom:24px;">Lifetime Pro — confirmed</p>
        <p style="color:#9ca3af;line-height:1.7;">
          You just became a systematic trader.<br><br>
          Lifetime Pro is locked to this email. When LocoTrader launches, you'll be 
          the first to get access — no subscription, no limits, forever.<br><br>
          We'll email you with early builds, progress updates, and your founding 
          member badge.
        </p>
        <p style="color:#6b7280;font-size:12px;margin-top:32px;">Transaction: ${transactionId}</p>
        <p style="color:#374151;font-size:11px;margin-top:8px;">— The LocoTrader Team</p>
      </div>
      `
    );

  } else if (paymentType === "feature_request") {
    const featureTitle = customData.feature_title || "Unnamed feature";
    const featureDesc = customData.feature_description || "";

    const { data: existing } = await supabase
      .from("feature_requests")
      .select("id, total_funded, backer_count")
      .eq("title", featureTitle)
      .maybeSingle();

    let featureId = existing?.id;

    if (existing) {
      await supabase
        .from("feature_requests")
        .update({
          total_funded: existing.total_funded + totalAmount,
          backer_count: existing.backer_count + 1,
        })
        .eq("id", existing.id);
    } else {
      const { data: inserted } = await supabase
        .from("feature_requests")
        .insert({
          title: featureTitle,
          description: featureDesc,
          email,
          total_funded: totalAmount,
          backer_count: 1,
        })
        .select("id")
        .single();
      featureId = inserted?.id;
    }

    await supabase.from("feature_request_payments").insert({
      feature_id: featureId,
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });

    // Send confirmation email
    await sendEmail(
      email,
      `Feature request funded — "${featureTitle}"`,
      `
      <div style="font-family:Inter,sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#ffffff;">
        <h1 style="font-size:28px;font-weight:900;margin-bottom:8px;">Your voice matters.</h1>
        <p style="color:#60a5fa;font-size:14px;margin-bottom:24px;">Feature request funded — $${totalAmount}</p>
        <p style="color:#9ca3af;line-height:1.7;">
          <strong style="color:#ffffff;">"${featureTitle}"</strong> has been submitted and funded.<br><br>
          Funded features ship faster. You've just moved this up the priority list. 
          We'll notify you when it's being built and when it ships.
        </p>
        <p style="color:#374151;font-size:11px;margin-top:32px;">— The LocoTrader Team</p>
      </div>
      `
    );
  }

  return new Response(
    JSON.stringify({ received: true, type: paymentType, email, transactionId }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});


serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paddle-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.text();

  let event;
  try {
    event = JSON.parse(body);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  // Only process completed transactions
  if (event.event_type !== "transaction.completed") {
    return new Response(JSON.stringify({ received: true, skipped: event.event_type }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  const data = event.data;
  const transactionId = data.id || "";
  const customerId = data.customer_id || "";
  const items = data.items || [];
  const lineItems = data.details?.line_items || [];
  const customData = data.custom_data || {};

  // ── Fix 1: Detect product type from actual payload paths ──
  // data.items[0].price.description OR data.details.line_items[0].product.name
  const priceDesc = (items[0]?.price?.description || "").toLowerCase();
  const productName = (lineItems[0]?.product?.name || "").toLowerCase();
  const combined = priceDesc + " " + productName;

  let paymentType = "unknown";
  if (combined.includes("lifetime") || combined.includes("pro")) {
    paymentType = "lifetime_pro";
  } else if (combined.includes("feature")) {
    paymentType = "feature_request";
  }

  // Amount in dollars (Paddle sends cents)
  const totalAmount = data.details?.totals?.total
    ? parseFloat(data.details.totals.total) / 100
    : 0;

  // ── Fix 2: Fetch customer email from Paddle API ──
  let email = "";
  if (customerId && PADDLE_API_KEY) {
    const apiBase = PADDLE_API_KEY.startsWith("test_")
      ? "https://sandbox-api.paddle.com"
      : "https://api.paddle.com";
    try {
      const res = await fetch(`${apiBase}/customers/${customerId}`, {
        headers: { Authorization: `Bearer ${PADDLE_API_KEY}` },
      });
      if (res.ok) {
        const customer = await res.json();
        email = customer.data?.email || "";
      }
    } catch (e) {
      console.error("Failed to fetch customer email:", e);
    }
  }

  // ── Store in Supabase ──
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
  const supabase = createClient(supabaseUrl, supabaseKey);

  if (paymentType === "lifetime_pro") {
    const { error } = await supabase.from("early_access_payments").insert({
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });
    if (error) console.error("DB insert error:", error.message);

  } else if (paymentType === "feature_request") {
    const featureTitle = customData.feature_title || "Unnamed feature";
    const featureDesc = customData.feature_description || "";

    const { data: existing } = await supabase
      .from("feature_requests")
      .select("id, total_funded, backer_count")
      .eq("title", featureTitle)
      .maybeSingle();

    let featureId = existing?.id;

    if (existing) {
      await supabase
        .from("feature_requests")
        .update({
          total_funded: existing.total_funded + totalAmount,
          backer_count: existing.backer_count + 1,
        })
        .eq("id", existing.id);
    } else {
      const { data: inserted } = await supabase
        .from("feature_requests")
        .insert({ title: featureTitle, description: featureDesc, email, total_funded: totalAmount, backer_count: 1 })
        .select("id")
        .single();
      featureId = inserted?.id;
    }

    await supabase.from("feature_request_payments").insert({
      feature_id: featureId,
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });
  }

  return new Response(
    JSON.stringify({ received: true, type: paymentType, email, transactionId }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paddle-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.text();
  const signature = req.headers.get("paddle-signature") || "";

  // In production: verify the webhook signature
  // For now we skip verification in sandbox mode
  // TODO: Add signature verification for production
  // See: https://developer.paddle.com/webhooks/signature-verification

  let event;
  try {
    event = JSON.parse(body);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  // We only care about completed transactions
  if (event.event_type !== "transaction.completed") {
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  const data = event.data;
  const email = data.customer?.email || data.billing_details?.email || "";
  const transactionId = data.id || "";
  const items = data.items || [];
  const totalAmount = data.details?.totals?.total
    ? parseFloat(data.details.totals.total) / 100
    : 0;

  // Determine product type from line items
  let paymentType = "unknown";
  for (const item of items) {
    const name = (item.price?.name || item.product?.name || "").toLowerCase();
    if (name.includes("lifetime") || name.includes("pro")) {
      paymentType = "lifetime_pro";
    } else if (name.includes("feature")) {
      paymentType = "feature_request";
    }
  }

  // Store in Supabase
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
  const supabase = createClient(supabaseUrl, supabaseKey);

  if (paymentType === "lifetime_pro") {
    await supabase.from("early_access_payments").insert({
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });
  } else if (paymentType === "feature_request") {
    // For feature requests, we'd need the feature title from custom data
    // Paddle allows passing custom_data in checkout which we can read here
    const customData = data.custom_data || {};
    const featureTitle = customData.feature_title || "Unnamed feature";
    const featureDesc = customData.feature_description || "";

    // Insert the feature request
    const { data: existingFeature } = await supabase
      .from("feature_requests")
      .select("id, total_funded, backer_count")
      .eq("title", featureTitle)
      .maybeSingle();

    if (existingFeature) {
      // Boost existing feature
      await supabase
        .from("feature_requests")
        .update({
          total_funded: existingFeature.total_funded + totalAmount,
          backer_count: existingFeature.backer_count + 1,
        })
        .eq("id", existingFeature.id);
    } else {
      // Create new feature request
      await supabase.from("feature_requests").insert({
        title: featureTitle,
        description: featureDesc,
        email,
        total_funded: totalAmount,
        backer_count: 1,
      });
    }

    // Log the payment
    await supabase.from("feature_request_payments").insert({
      feature_id: existingFeature?.id,
      email,
      amount: totalAmount,
      paddle_transaction_id: transactionId,
    });
  }

  return new Response(
    JSON.stringify({ received: true, type: paymentType, email }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
