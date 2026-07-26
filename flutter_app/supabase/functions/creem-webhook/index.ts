import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Secrets — set in Supabase Dashboard > Edge Functions > Secrets:
// CREEM_WEBHOOK_SECRET  → Creem Dashboard > Developers > Webhooks > signing secret
// RESEND_API_KEY        → resend.com API key
// SUPABASE_SERVICE_ROLE_KEY → auto-set by Supabase

const CREEM_WEBHOOK_SECRET = Deno.env.get("CREEM_WEBHOOK_SECRET") ?? "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// ── Creem Webhook Product IDs ──────────────────────────────────────────
// These must match what you have in Creem Dashboard → Products
const PRODUCT_LIFETIME = "prod_5R4PpzBdaDFHwFvSW9jv1g";

// ── Helpers ────────────────────────────────────────────────────────────

async function sendEmail(to: string, subject: string, html: string) {
  if (!RESEND_API_KEY || !to) {
    console.log("sendEmail skipped — no key or no recipient");
    return;
  }
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "LocoTrader <noreply@locotrader.app>",
        to,
        subject,
        html,
      }),
    });
    if (!res.ok) console.error("Resend error:", await res.text());
    else console.log("Email sent to:", to);
  } catch (e) {
    console.error("sendEmail error:", e);
  }
}

function lifetimeEmailHtml(txnId: string): string {
  return `<div style="font-family:sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#fff;">
    <h1 style="font-size:28px;font-weight:900;">You're in.</h1>
    <p style="color:#60a5fa;font-size:14px;">Lifetime Pro - confirmed</p>
    <p style="color:#9ca3af;line-height:1.7;">
      You just joined the traders who decided to stop guessing.<br><br>
      Lifetime Pro is locked to this email. When LocoTrader launches, you will be
      the first to get access - no subscription, no limits, forever.
    </p>
    <p style="color:#4b5563;font-size:12px;margin-top:32px;">Transaction: ${txnId}</p>
    <p style="color:#374151;font-size:11px;margin-top:8px;">- The LocoTrader Team</p>
  </div>`;
}

function featureEmailHtml(title: string, desc: string, amount: number, txnId: string): string {
  return `<div style="font-family:sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#fff;">
    <h1 style="font-size:28px;font-weight:900;">Your voice matters.</h1>
    <p style="color:#60a5fa;font-size:14px;">Feature funded - $${amount}</p>
    <div style="background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;padding:16px;margin:16px 0;">
      <p style="color:#fff;font-size:15px;font-weight:700;margin:0 0 4px;">"${title}"</p>
      ${desc ? `<p style="color:#6b7280;font-size:13px;margin:0;">${desc}</p>` : ""}
    </div>
    <p style="color:#9ca3af;line-height:1.7;">
      Funded features ship faster. You have moved this up the priority list.
    </p>
    <p style="color:#4b5563;font-size:12px;margin-top:32px;">Transaction: ${txnId}</p>
    <p style="color:#374151;font-size:11px;margin-top:8px;">- The LocoTrader Team</p>
  </div>`;
}

// ── Main handler ────────────────────────────────────────────────────────

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "content-type, creem-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.text();

  // Verify Creem webhook signature (HMAC-SHA256)
  if (CREEM_WEBHOOK_SECRET) {
    const signature = req.headers.get("creem-signature") ?? "";
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(CREEM_WEBHOOK_SECRET),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const mac = await crypto.subtle.sign("HMAC", key, encoder.encode(body));
    const expected = Array.from(new Uint8Array(mac))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    if (signature !== expected) {
      console.error("Invalid webhook signature");
      return new Response("Unauthorized", { status: 401 });
    }
  }

  let event: Record<string, unknown>;
  try {
    event = JSON.parse(body);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  console.log("Creem event:", event.eventType ?? event.type);

  // Only handle completed checkouts
  const eventType = (event.eventType ?? event.type ?? "") as string;
  if (!eventType.includes("checkout.completed") && !eventType.includes("checkout_completed")) {
    return new Response(JSON.stringify({ received: true, skipped: eventType }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Extract data — Creem wraps payload in event.object or event.data
  const data = (event.object ?? event.data ?? event) as Record<string, unknown>;
  const customer = (data.customer ?? {}) as Record<string, unknown>;
  const email = (customer.email ?? data.customer_email ?? "") as string;
  const txnId = (data.id ?? data.order_id ?? "") as string;
  const productId = (data.product_id ?? (data.product as Record<string,unknown>)?.id ?? "") as string;
  const metadata = (data.metadata ?? {}) as Record<string, string>;
  const amount = typeof data.amount === "number" ? data.amount / 100 : 0;

  console.log("email:", email, "productId:", productId, "txnId:", txnId);

  const isLifetime = productId === PRODUCT_LIFETIME;
  const isFeature = !isLifetime && productId.startsWith("prod_");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  if (isLifetime) {
    const { error } = await supabase.from("early_access_payments").insert({
      email,
      amount: amount || 49,
      paddle_transaction_id: txnId, // reusing column for now
    });
    if (error) console.error("DB error:", error.message);

    await sendEmail(email, "You're in - LocoTrader Lifetime Pro confirmed", lifetimeEmailHtml(txnId));

  } else if (isFeature) {
    const featureTitle = metadata.feature_title ?? "Unnamed feature";
    const featureDesc = metadata.feature_description ?? "";

    const { data: existing } = await supabase
      .from("feature_requests")
      .select("id, total_funded, backer_count")
      .eq("title", featureTitle)
      .maybeSingle();

    let featureId = existing?.id;

    if (existing) {
      await supabase.from("feature_requests").update({
        total_funded: existing.total_funded + (amount || 5),
        backer_count: existing.backer_count + 1,
      }).eq("id", existing.id);
    } else {
      const { data: ins } = await supabase
        .from("feature_requests")
        .insert({ title: featureTitle, description: featureDesc, email, total_funded: amount || 5, backer_count: 1 })
        .select("id").single();
      featureId = ins?.id;
    }

    await supabase.from("feature_request_payments").insert({
      feature_id: featureId,
      email,
      amount: amount || 5,
      paddle_transaction_id: txnId,
    });

    await sendEmail(email, `Feature funded - "${featureTitle}"`, featureEmailHtml(featureTitle, featureDesc, amount || 5, txnId));
  }

  return new Response(
    JSON.stringify({ received: true, type: isLifetime ? "lifetime" : isFeature ? "feature" : "unknown", email, txnId }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
