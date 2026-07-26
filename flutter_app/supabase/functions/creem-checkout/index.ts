import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

// Creem API — server-side checkout session creation
// CREEM_API_KEY must be set in Supabase Dashboard → Edge Functions → Secrets

const CREEM_API_KEY = Deno.env.get("CREEM_API_KEY") ?? "";
const IS_TEST = CREEM_API_KEY.startsWith("creem_test_");
const CREEM_BASE = IS_TEST
  ? "https://test-api.creem.io/v1"
  : "https://api.creem.io/v1";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers: CORS });
  }

  if (!CREEM_API_KEY) {
    console.error("CREEM_API_KEY is not set");
    return new Response(JSON.stringify({ error: "Payment service not configured" }), { status: 500, headers: CORS });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), { status: 400, headers: CORS });
  }

  const { product_id, success_url, metadata } = body as {
    product_id: string;
    success_url: string;
    metadata?: Record<string, string>;
  };

  if (!product_id || !success_url) {
    return new Response(JSON.stringify({ error: "product_id and success_url are required" }), { status: 400, headers: CORS });
  }

  try {
    const payload: Record<string, unknown> = {
      product_id,
      success_url,
    };
    if (metadata && Object.keys(metadata).length > 0) {
      payload.metadata = metadata;
    }

    const res = await fetch(`${CREEM_BASE}/checkouts`, {
      method: "POST",
      headers: {
        "x-api-key": CREEM_API_KEY,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const data = await res.json();

    if (!res.ok) {
      console.error("Creem checkout error:", data);
      return new Response(
        JSON.stringify({ error: data.message ?? "Checkout creation failed" }),
        { status: res.status, headers: CORS }
      );
    }

    // Creem returns { id, checkout_url, ... }
    return new Response(
      JSON.stringify({ checkout_url: data.checkout_url ?? data.url }),
      { status: 200, headers: CORS }
    );
  } catch (e) {
    console.error("creem-checkout error:", e);
    return new Response(JSON.stringify({ error: "Internal error" }), { status: 500, headers: CORS });
  }
});
