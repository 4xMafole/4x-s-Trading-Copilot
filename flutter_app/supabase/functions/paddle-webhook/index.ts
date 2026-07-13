import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Paddle webhook secret — set in Supabase Dashboard > Edge Functions > Secrets
// PADDLE_WEBHOOK_SECRET = your webhook secret from Paddle > Developer Tools > Notifications
const PADDLE_WEBHOOK_SECRET = Deno.env.get("PADDLE_WEBHOOK_SECRET") || "";

serve(async (req) => {
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
