import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PADDLE_API_KEY = Deno.env.get("PADDLE_API_KEY") ?? "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

async function fetchCustomerEmail(customerId: string): Promise<string> {
  if (!customerId || !PADDLE_API_KEY) return "";
  const apiBase = PADDLE_API_KEY.startsWith("test_")
    ? "https://sandbox-api.paddle.com"
    : "https://api.paddle.com";
  try {
    const res = await fetch(`${apiBase}/customers/${customerId}`, {
      headers: { Authorization: `Bearer ${PADDLE_API_KEY}` },
    });
    if (!res.ok) { console.error(`Paddle ${res.status}:`, await res.text()); return ""; }
    const json = await res.json();
    return json?.data?.email ?? "";
  } catch (e) { console.error("fetchCustomerEmail:", e); return ""; }
}

async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  if (!RESEND_API_KEY || !to) { console.log("sendEmail skipped — no key or no to"); return; }
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: "LocoTrader <noreply@locotrader.app>", to, subject, html }),
    });
    if (!res.ok) console.error(`Resend ${res.status}:`, await res.text());
    else console.log("Email sent to:", to);
  } catch (e) { console.error("sendEmail:", e); }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paddle-signature" } });
  }
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const body = await req.text();
  let event: Record<string, unknown>;
  try { event = JSON.parse(body); } catch { return new Response("Invalid JSON", { status: 400 }); }

  console.log("Event:", event.event_type);

  if (event.event_type !== "transaction.completed") {
    return new Response(JSON.stringify({ received: true, skipped: event.event_type }), { status: 200, headers: { "Content-Type": "application/json" } });
  }

  const data = event.data as Record<string, unknown>;
  const transactionId = (data.id as string) ?? "";
  const customerId = (data.customer_id as string) ?? "";
  const items = (data.items as any[]) ?? [];
  const details = (data.details as any) ?? {};
  const lineItems = (details?.line_items as any[]) ?? [];
  const customData = (data.custom_data as any) ?? {};

  const priceDesc = String(items[0]?.price?.description ?? "").toLowerCase();
  const productName = String(lineItems[0]?.product?.name ?? "").toLowerCase();
  const combined = `${priceDesc} ${productName}`;
  console.log("combined:", combined);

  let paymentType = "unknown";
  if (combined.includes("lifetime") || combined.includes("pro")) paymentType = "lifetime_pro";
  else if (combined.includes("feature")) paymentType = "feature_request";
  console.log("paymentType:", paymentType);

  const totalAmount = details?.totals?.total ? parseFloat(String(details.totals.total)) / 100 : 0;
  const email = await fetchCustomerEmail(customerId);
  console.log("email:", email);

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  if (paymentType === "lifetime_pro") {
    const { error } = await supabase.from("early_access_payments").insert({ email, amount: totalAmount, paddle_transaction_id: transactionId });
    if (error) console.error("DB error:", error.message);
    await sendEmail(email, "You're in — LocoTrader Lifetime Pro confirmed", `<div style="font-family:sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#fff;"><h1 style="font-size:28px;font-weight:900;">You're in.</h1><p style="color:#60a5fa;">Lifetime Pro confirmed.</p><p style="color:#9ca3af;line-height:1.7;">You just became a systematic trader. Lifetime Pro is locked to this email. When LocoTrader launches, you'll be the first in — no subscription, no limits, forever.</p><p style="color:#4b5563;font-size:12px;margin-top:24px;">Transaction: ${transactionId}</p></div>`);

  } else if (paymentType === "feature_request") {
    const featureTitle = String(customData?.feature_title ?? "Unnamed feature");
    const featureDesc = String(customData?.feature_description ?? "");

    const { data: existing } = await supabase.from("feature_requests").select("id, total_funded, backer_count").eq("title", featureTitle).maybeSingle();
    let featureId = existing?.id;

    if (existing) {
      await supabase.from("feature_requests").update({ total_funded: existing.total_funded + totalAmount, backer_count: existing.backer_count + 1 }).eq("id", existing.id);
    } else {
      const { data: ins } = await supabase.from("feature_requests").insert({ title: featureTitle, description: featureDesc, email, total_funded: totalAmount, backer_count: 1 }).select("id").single();
      featureId = ins?.id;
    }
    await supabase.from("feature_request_payments").insert({ feature_id: featureId, email, amount: totalAmount, paddle_transaction_id: transactionId });
    await sendEmail(email, `Feature funded — "${featureTitle}"`, `<div style="font-family:sans-serif;max-width:520px;margin:0 auto;padding:40px 24px;background:#050508;color:#fff;"><h1 style="font-size:28px;font-weight:900;">Your voice matters.</h1><p style="color:#60a5fa;">Feature funded — $${totalAmount}</p><p style="color:#9ca3af;line-height:1.7;">"${featureTitle}" submitted and funded. Funded features ship faster. We'll notify you when it ships.</p></div>`);
  }

  return new Response(JSON.stringify({ received: true, type: paymentType, email, transactionId }), { status: 200, headers: { "Content-Type": "application/json" } });
});
