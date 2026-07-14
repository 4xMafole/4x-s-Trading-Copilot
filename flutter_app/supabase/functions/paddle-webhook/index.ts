import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PADDLE_API_KEY = Deno.env.get("PADDLE_API_KEY") ?? "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

async function fetchCustomerEmail(customerId: string): Promise<string> {
  if (!customerId) { console.error("fetchCustomerEmail: no customerId"); return ""; }
  if (!PADDLE_API_KEY) { console.error("fetchCustomerEmail: PADDLE_API_KEY is empty"); return ""; }
  // Try sandbox first, then production
  const bases = ["https://sandbox-api.paddle.com", "https://api.paddle.com"];
  for (const apiBase of bases) {
    try {
      console.log(`Trying ${apiBase}/customers/${customerId}`);
      const res = await fetch(`${apiBase}/customers/${customerId}`, {
        headers: { Authorization: `Bearer ${PADDLE_API_KEY}` },
      });
      if (res.ok) {
        const json = await res.json();
        const email = json?.data?.email ?? "";
        console.log(`Got email from ${apiBase}:`, email);
        return email;
      }
      const txt = await res.text();
      console.error(`${apiBase} returned ${res.status}:`, txt);
    } catch (e) { console.error(`${apiBase} error:`, e); }
  }
  return "";
}

async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  if (!RESEND_API_KEY) { console.error("sendEmail SKIPPED: RESEND_API_KEY is empty or not set"); return; }
  if (!to) { console.error("sendEmail SKIPPED: recipient email (to) is empty"); return; }
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
    await sendEmail(email, "You're in - LocoTrader Lifetime Pro confirmed", lifetimeEmailHtml(transactionId));

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
    await sendEmail(email, `Feature funded - "${featureTitle}"`, featureEmailHtml(featureTitle, featureDesc, totalAmount, transactionId));
  }

  return new Response(JSON.stringify({ received: true, type: paymentType, email, transactionId }), { status: 200, headers: { "Content-Type": "application/json" } });
});

// ── Email Templates ───────────────────────────────────────────────────

const LOGO_SVG = `<svg width="40" height="40" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="64" height="64" rx="14" fill="white"/><path d="M10 44 L28 12 L38 12 L20 44Z" fill="#3B82F6" opacity="0.35"/><path d="M26 52 L44 20 L54 20 L36 52Z" fill="#3B82F6"/><path d="M26 44 L28 12 L38 12 L36 44Z" fill="#60A5FA" opacity="0.25"/></svg>`;

function emailWrapper(content: string): string {
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"></head>
<body style="margin:0;padding:0;background:#050508;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#050508;padding:40px 16px;">
    <tr><td align="center">
      <table width="520" cellpadding="0" cellspacing="0" style="max-width:520px;width:100%;">
        <!-- Logo -->
        <tr><td style="padding-bottom:32px;">${LOGO_SVG}<span style="display:inline-block;vertical-align:middle;margin-left:12px;font-size:18px;font-weight:900;color:#fff;">Loco</span><span style="display:inline-block;vertical-align:middle;font-size:18px;font-weight:900;color:#60A5FA;">Trader</span></td></tr>
        <!-- Content -->
        <tr><td style="background:#0d0d18;border-radius:16px;padding:40px 32px;border:1px solid rgba(255,255,255,0.06);">
          ${content}
        </td></tr>
        <!-- Footer -->
        <tr><td style="padding-top:24px;text-align:center;">
          <a href="https://locotrader.app" style="color:#4b5563;font-size:12px;text-decoration:none;">locotrader.app</a>
          <p style="color:#1f2937;font-size:11px;margin-top:8px;">You received this because you made a purchase on LocoTrader.</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`;
}

function lifetimeEmailHtml(txnId: string): string {
  return emailWrapper(`
    <div style="text-align:center;margin-bottom:24px;">
      <div style="display:inline-block;background:#3B82F6;color:#fff;font-size:11px;font-weight:700;letter-spacing:1px;padding:4px 12px;border-radius:20px;text-transform:uppercase;">Founding Member</div>
    </div>
    <h1 style="color:#ffffff;font-size:28px;font-weight:900;margin:0 0 8px;text-align:center;">You're in.</h1>
    <p style="color:#60a5fa;font-size:14px;text-align:center;margin:0 0 24px;">Lifetime Pro - confirmed</p>
    <div style="width:48px;height:2px;background:#3B82F6;margin:0 auto 24px;border-radius:1px;"></div>
    <p style="color:#9ca3af;line-height:1.8;font-size:14px;margin:0 0 20px;">
      You just joined the traders who decided to stop guessing.
    </p>
    <p style="color:#9ca3af;line-height:1.8;font-size:14px;margin:0 0 20px;">
      Lifetime Pro is locked to this email. When LocoTrader launches, you will be the first to get access - no subscription, no limits, forever.
    </p>
    <p style="color:#9ca3af;line-height:1.8;font-size:14px;margin:0 0 20px;">
      Here is what happens next:
    </p>
    <table cellpadding="0" cellspacing="0" style="margin-bottom:24px;width:100%;">
      <tr><td style="padding:8px 0;color:#60a5fa;font-size:13px;width:24px;vertical-align:top;">1.</td><td style="padding:8px 0;color:#d1d5db;font-size:13px;">Early access build sent to your email before public launch</td></tr>
      <tr><td style="padding:8px 0;color:#60a5fa;font-size:13px;width:24px;vertical-align:top;">2.</td><td style="padding:8px 0;color:#d1d5db;font-size:13px;">Your founding member badge added to your profile</td></tr>
      <tr><td style="padding:8px 0;color:#60a5fa;font-size:13px;width:24px;vertical-align:top;">3.</td><td style="padding:8px 0;color:#d1d5db;font-size:13px;">Progress updates as we build</td></tr>
    </table>
    <div style="background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.15);border-radius:8px;padding:12px 16px;margin-bottom:8px;">
      <p style="color:#6b7280;font-size:11px;margin:0;">Transaction: ${txnId}</p>
    </div>
  `);
}

function featureEmailHtml(title: string, desc: string, amount: number, txnId: string): string {
  return emailWrapper(`
    <div style="text-align:center;margin-bottom:24px;">
      <div style="display:inline-block;background:#3B82F6;color:#fff;font-size:11px;font-weight:700;letter-spacing:1px;padding:4px 12px;border-radius:20px;text-transform:uppercase;">Feature Funded</div>
    </div>
    <h1 style="color:#ffffff;font-size:28px;font-weight:900;margin:0 0 8px;text-align:center;">Your voice matters.</h1>
    <p style="color:#60a5fa;font-size:14px;text-align:center;margin:0 0 24px;">Funded - $${amount}</p>
    <div style="width:48px;height:2px;background:#3B82F6;margin:0 auto 24px;border-radius:1px;"></div>
    <div style="background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;padding:20px;margin-bottom:24px;">
      <p style="color:#ffffff;font-size:16px;font-weight:700;margin:0 0 8px;">"${title}"</p>
      ${desc ? `<p style="color:#6b7280;font-size:13px;line-height:1.6;margin:0;">${desc}</p>` : ""}
    </div>
    <p style="color:#9ca3af;line-height:1.8;font-size:14px;margin:0 0 20px;">
      Funded features ship faster. You have just moved this up the priority list.
    </p>
    <p style="color:#9ca3af;line-height:1.8;font-size:14px;margin:0 0 20px;">
      We will notify you when this feature is being built and when it ships.
    </p>
    <div style="background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.15);border-radius:8px;padding:12px 16px;">
      <p style="color:#6b7280;font-size:11px;margin:0;">Amount: $${amount} | Transaction: ${txnId}</p>
    </div>
  `);
}
