import { useEffect, useRef, useState } from 'react';
import { Logo, LogoIcon } from './components/Logo';

// ── Creem Config ──
const SUPABASE_URL = 'https://fistibmbmtcgqdtnwolq.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpc3RpYm1ibXRjZ3FkdG53b2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM3MTMxNjQsImV4cCI6MjA5OTI4OTE2NH0.qnFUUFms4693I9FG2X6CnwaUtZHHwllALYYME-GD1_A';

const CREEM_PRODUCTS = {
  lifetime: 'prod_5R4PpzBdaDFHwFvSW9jv1g',
  feature_5:  'prod_1NsK8Ikic5DG4RVhuwB2jK',
  feature_10: 'prod_6q9OOudc8yP4dDTAUv9eox',
  feature_25: 'prod_3BakpvuvhE6AIL8aTKyuD7',
  feature_50: 'prod_73MmlD2bHWkWh6JlDbv4BL',
} as const;

// Feature amount → product id
const FEATURE_AMOUNT_MAP: Record<number, string> = {
  5:  CREEM_PRODUCTS.feature_5,
  10: CREEM_PRODUCTS.feature_10,
  25: CREEM_PRODUCTS.feature_25,
  50: CREEM_PRODUCTS.feature_50,
};

// Create a Creem checkout session via Supabase Edge Function and redirect
async function openCheckout(
  productId: string,
  successPath: string,
  metadata?: Record<string, string>
): Promise<void> {
  const btn = document.activeElement as HTMLButtonElement | null;
  if (btn) btn.disabled = true;

  try {
    const res = await fetch(`${SUPABASE_URL}/functions/v1/creem-checkout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        product_id: productId,
        success_url: window.location.origin + successPath,
        metadata,
      }),
    });

    const data = await res.json();

    if (!res.ok || !data.checkout_url) {
      console.error('Checkout error:', data);
      alert('Could not start checkout. Please try again.');
      return;
    }

    window.location.href = data.checkout_url;
  } catch (e) {
    console.error('openCheckout error:', e);
    alert('Network error. Please try again.');
  } finally {
    if (btn) btn.disabled = false;
  }
}

export default function App() {
  const [page, setPage] = useState(getPage());

  useEffect(() => {
    const onNav = () => setPage(getPage());
    window.addEventListener('popstate', onNav);
    return () => window.removeEventListener('popstate', onNav);
  }, []);

  if (page === 'thank-you-lifetime') return <ThankYouLifetime />;
  if (page === 'thank-you-feature') return <ThankYouFeature />;
  if (page === 'terms') return <LegalPage title="Terms of Service" content={termsContent} />;
  if (page === 'privacy') return <LegalPage title="Privacy Policy" content={privacyContent} />;
  if (page === 'refund') return <LegalPage title="Refund Policy" content={refundContent} />;

  return (
    <div className="min-h-screen bg-[#050508] text-white font-sans selection:bg-blue-500/20 overflow-x-hidden">
      <Hero />
      <FeatureRequest />
      <Problem />
      <AppFeatures />
      <Offer />
      <Footer />
    </div>
  );
}

function getPage() {
  const path = window.location.pathname;
  if (path === '/thank-you-lifetime') return 'thank-you-lifetime';
  if (path === '/thank-you-feature') return 'thank-you-feature';
  if (path === '/terms') return 'terms';
  if (path === '/privacy') return 'privacy';
  if (path === '/refund') return 'refund';
  return 'home';
}

// ═══════════════════════════════════════════════════════════════
//  THANK YOU — Lifetime
// ═══════════════════════════════════════════════════════════════

function ThankYouLifetime() {
  return (
    <div className="min-h-screen bg-[#050508] text-white font-sans flex items-center justify-center px-6">
      <div className="max-w-lg text-center">
        <div className="text-6xl mb-6">◆</div>
        <h1 className="text-3xl sm:text-4xl font-black mb-4">
          You're in.
        </h1>
        <p className="text-xl text-white/60 mb-6">
          You just became a systematic trader.
        </p>
        <p className="text-white/35 text-sm leading-relaxed mb-8">
          Lifetime Pro is locked to your email. When LocoTrader launches, you'll be the first to get access — no subscription, no limits, forever.
          <br /><br />
          We'll email you with early builds, progress updates, and your founding member badge.
        </p>
        <div className="inline-flex items-center gap-3 px-5 py-3 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-400 text-sm font-medium mb-8">
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
          Payment confirmed
        </div>
        <div>
          <a href="/" className="text-xs text-white/25 hover:text-white/50 transition">← Back to LocoTrader</a>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  THANK YOU — Feature Request
// ═══════════════════════════════════════════════════════════════

function ThankYouFeature() {
  return (
    <div className="min-h-screen bg-[#050508] text-white font-sans flex items-center justify-center px-6">
      <div className="max-w-lg text-center">
        <div className="text-6xl mb-6">✦</div>
        <h1 className="text-3xl sm:text-4xl font-black mb-4">
          Your voice matters.
        </h1>
        <p className="text-xl text-white/60 mb-6">
          Feature request submitted and funded.
        </p>
        <p className="text-white/35 text-sm leading-relaxed mb-8">
          Funded features ship faster. You've just moved this up the priority list.
          We'll notify you when it's being built and when it ships.
        </p>
        <div className="inline-flex items-center gap-3 px-5 py-3 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-400 text-sm font-medium mb-8">
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
          Payment confirmed · Feature queued
        </div>
        <div>
          <a href="/" className="text-xs text-white/25 hover:text-white/50 transition">← Back to LocoTrader</a>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  HERO
// ═══════════════════════════════════════════════════════════════

function Hero() {
  return (
    <section className="relative min-h-[100svh] flex items-center">
      <div className="absolute top-[-20%] right-[-10%] w-[800px] h-[800px] rounded-full bg-blue-600/[0.07] blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 sm:px-12 grid lg:grid-cols-2 gap-12 lg:gap-16 items-center py-24 lg:py-0">
        <div className="relative z-10">
          <p className="text-blue-400 text-sm font-mono tracking-wider mb-6 opacity-0 animate-[fadeUp_0.6s_0.1s_forwards]">
            Early access open
          </p>

          <h1 className="text-4xl sm:text-5xl lg:text-[4.5rem] font-black leading-[1.05] tracking-tight mb-6 opacity-0 animate-[fadeUp_0.6s_0.2s_forwards]">
            Your edge isn't broken.
            <br />
            <span className="text-white/30">You're missing a system.</span>
          </h1>

          <p className="text-base sm:text-lg text-white/50 max-w-md leading-relaxed mb-10 opacity-0 animate-[fadeUp_0.6s_0.35s_forwards]">
            No system means no edge. LocoTrader turns your chaos
            into a repeatable, rule-based process — so you stop
            bleeding money and start earning consistently.
          </p>

          <div className="flex flex-wrap items-center gap-4 opacity-0 animate-[fadeUp_0.6s_0.5s_forwards]">
            <button
              onClick={() => openCheckout(CREEM_PRODUCTS.lifetime, '/thank-you-lifetime')}
              className="inline-flex items-center px-7 py-4 bg-blue-500 text-white font-bold rounded-xl hover:bg-blue-400 transition-all duration-200 shadow-[0_0_40px_rgba(59,130,246,0.3)] hover:shadow-[0_0_60px_rgba(59,130,246,0.5)] cursor-pointer"
            >
              Get Lifetime Access — $49
            </button>
            <span className="text-xs text-white/25">Lifetime Pro · Limited spots</span>
          </div>
        </div>

        {/* Phone — larger */}
        <div className="relative flex justify-center lg:justify-end opacity-0 animate-[fadeUp_0.8s_0.4s_forwards]">
          <div className="relative">
            <div className="absolute inset-0 bg-blue-500/10 blur-[80px] rounded-full scale-75" />
            <div className="relative w-[300px] sm:w-[340px] lg:w-[380px] rounded-[3rem] border-[8px] border-white/[0.08] bg-[#111] p-1.5 shadow-2xl">
              <div className="absolute top-2 left-1/2 -translate-x-1/2 w-20 h-5 bg-[#050508] rounded-b-2xl z-10" />
              <div className="rounded-[2.25rem] overflow-hidden">
                <img src="/screenshots/photo_2026-07-13_15-11-40.jpg" alt="LocoTrader app" className="w-full" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll indicator — hidden on mobile */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 opacity-0 animate-[fadeUp_0.6s_1s_forwards] hidden lg:block">
        <div className="w-5 h-8 rounded-full border-2 border-white/20 flex justify-center pt-1.5">
          <div className="w-1 h-2 bg-white/40 rounded-full animate-bounce" />
        </div>
      </div>
    </section>
  );
}

// ═══════════════════════════════════════════════════════════════
//  FEATURE REQUEST — submit form only, no public list
// ═══════════════════════════════════════════════════════════════

const AMOUNTS = [5, 10, 25, 50];

function FeatureRequest() {
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [desc, setDesc] = useState('');
  const [amount, setAmount] = useState(5);
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.2 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || amount < 5) return;
    const productId = FEATURE_AMOUNT_MAP[amount];
    if (!productId) { alert('Invalid amount selected'); return; }
    openCheckout(productId, '/thank-you-feature', {
      feature_title: title.trim(),
      feature_description: desc.trim(),
    });
  }

  return (
    <section ref={ref} className="py-20 sm:py-28 px-6 sm:px-12 border-t border-white/[0.04]">
      <div className={`max-w-2xl mx-auto text-center transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-12'}`}>
        <p className="text-blue-400 text-xs font-mono tracking-wider mb-3 uppercase">Shape the product</p>
        <h2 className="text-2xl sm:text-3xl font-black mb-3">Help shape LocoTrader</h2>
        <p className="text-white/35 text-sm mb-8 max-w-md mx-auto">
          Vote with your wallet. Fund the features you want built first.
        </p>

        {!open ? (
          <button
            onClick={() => setOpen(true)}
            className="px-6 py-3 text-sm font-semibold bg-blue-500/10 border border-blue-500/30 text-blue-400 rounded-xl hover:bg-blue-500/20 transition"
          >
            + Request a Feature — from $5
          </button>
        ) : (
          <form onSubmit={handleSubmit} className="text-left p-6 rounded-2xl border border-white/[0.06] bg-white/[0.015]">
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="What do you need?"
              className="w-full px-0 py-3 bg-transparent border-b border-white/10 text-lg font-medium text-white placeholder:text-white/20 focus:outline-none focus:border-blue-500/50 mb-4"
              required
            />
            <textarea
              value={desc}
              onChange={(e) => setDesc(e.target.value)}
              placeholder="Why does this matter to your trading? (optional)"
              rows={2}
              className="w-full px-0 py-2 bg-transparent border-b border-white/10 text-sm text-white/70 placeholder:text-white/20 focus:outline-none focus:border-blue-500/50 resize-none mb-6"
            />
            <div className="flex items-center gap-3 mb-6">
              <span className="text-xs text-white/30 uppercase tracking-wider">Boost:</span>
              {AMOUNTS.map((a) => (
                <button
                  key={a}
                  type="button"
                  onClick={() => setAmount(a)}
                  className={`px-3 py-1.5 rounded text-sm font-mono transition ${amount === a ? 'bg-blue-500 text-white' : 'bg-white/[0.04] text-white/40 hover:text-white/70'}`}
                >
                  ${a}
                </button>
              ))}
            </div>
            <div className="flex gap-3">
              <button type="button" onClick={() => setOpen(false)} className="px-5 py-3 text-sm text-white/40 hover:text-white/70 transition">Cancel</button>
              <button type="submit" className="flex-1 py-3 bg-blue-500 text-white font-bold rounded-xl hover:bg-blue-400 transition">
                Submit & Pay ${amount}
              </button>
            </div>
          </form>
        )}
      </div>
    </section>
  );
}

// ═══════════════════════════════════════════════════════════════
//  PROBLEM
// ═══════════════════════════════════════════════════════════════

function Problem() {
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.2 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  const stats = [
    { num: '73%', text: 'of retail traders lose money consistently.' },
    { num: '#1', text: 'reason? No system. No rules. No accountability.' },
    { num: '0', text: 'apps actually force you to follow your own plan.' },
  ];

  return (
    <section ref={ref} className="py-28 sm:py-32 px-6 sm:px-12 border-t border-white/[0.04]">
      <div className="max-w-5xl mx-auto">
        <h2 className={`text-3xl sm:text-5xl font-black mb-16 sm:mb-20 transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'}`}>
          The problem isn't your strategy.
          <br />
          <span className="text-white/25">It's you.</span>
        </h2>

        <div className="grid sm:grid-cols-3 gap-10 sm:gap-12">
          {stats.map((s, i) => (
            <div
              key={i}
              className={`transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-12'}`}
              style={{ transitionDelay: `${200 + i * 150}ms` }}
            >
              <div className="text-4xl sm:text-6xl font-black text-blue-400 mb-3 font-mono">{s.num}</div>
              <p className="text-white/50 text-sm sm:text-base leading-relaxed">{s.text}</p>
            </div>
          ))}
        </div>

        <div className={`mt-16 sm:mt-20 p-6 sm:p-8 rounded-2xl border border-white/[0.06] bg-white/[0.02] transition-all duration-700 delay-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'}`}>
          <p className="text-lg sm:text-2xl font-semibold text-center">Systematic traders don't hope. They know.</p>
          <p className="text-white/30 text-center mt-2 text-xs sm:text-sm">
            Every trade starts with your rules. Every mistake becomes data. Every week you see exactly what's making — or costing — you money.
          </p>
        </div>
      </div>
    </section>
  );
}

// ═══════════════════════════════════════════════════════════════
//  APP FEATURES — 3 screenshots: Edge Map, Trade Flow, Dashboard
// ═══════════════════════════════════════════════════════════════

function AppFeatures() {
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);
  const itemRefs = useRef<(HTMLDivElement | null)[]>([]);
  const [itemVisible, setItemVisible] = useState([false, false, false]);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  useEffect(() => {
    const observers: IntersectionObserver[] = [];
    itemRefs.current.forEach((el, i) => {
      if (!el) return;
      const obs = new IntersectionObserver(
        ([entry]) => { if (entry.isIntersecting) setItemVisible(prev => { const n = [...prev]; n[i] = true; return n; }); },
        { threshold: 0.3 }
      );
      obs.observe(el);
      observers.push(obs);
    });
    return () => observers.forEach(o => o.disconnect());
  }, []);

  const features = [
    {
      src: '/screenshots/photo_2026-07-13_15-11-40.jpg',
      title: 'The disciplined trader sees the edge.',
      desc: 'Your real trades reveal patterns you can\'t see in the moment — which sessions print, which setups bleed, which habits cost you. This is how you stop guessing.',
    },
    {
      src: '/screenshots/photo_2026-07-13_15-11-48.jpg',
      title: 'The systematic trader follows a process.',
      desc: 'Before every trade: your rules, your checklist, your risk — verified. No more "I\'ll just take this one." The system says yes or the system says no.',
    },
    {
      src: '/screenshots/photo_2026-07-13_15-11-50.jpg',
      title: 'The professional trader knows the numbers.',
      desc: 'Win rate, discipline streak, equity curve, readiness score — not vanity metrics. Real accountability that compounds into consistency.',
    },
  ];

  return (
    <section ref={ref} className="py-28 sm:py-32 border-t border-white/[0.04]">
      <div className="max-w-5xl mx-auto px-6 sm:px-12 mb-12 sm:mb-16">
        <h2 className={`text-3xl sm:text-4xl font-black transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'}`}>
          What changes when you have a system.
        </h2>
      </div>

      <div className="max-w-6xl mx-auto px-6 sm:px-12 flex flex-col gap-24 sm:gap-32">
        {features.map((f, i) => (
          <div
            key={i}
            ref={el => { itemRefs.current[i] = el; }}
            className={`flex flex-col ${i % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'} items-center gap-10 lg:gap-16 transition-all duration-1000 ${itemVisible[i] ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-20'}`}
          >
            {/* Phone */}
            <div className={`shrink-0 transition-all duration-1000 delay-200 ${itemVisible[i] ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
              <div className="relative w-[260px] sm:w-[280px] rounded-[2.5rem] border-[6px] border-white/[0.06] bg-[#111] p-1 shadow-xl mx-auto hover:shadow-blue-500/10 hover:border-white/[0.1] transition-all duration-500">
                <div className="absolute top-1 left-1/2 -translate-x-1/2 w-16 h-4 bg-[#050508] rounded-b-xl z-10" />
                <div className="rounded-[2rem] overflow-hidden">
                  <img src={f.src} alt={f.title} className="w-full" loading="lazy" />
                </div>
              </div>
            </div>
            {/* Copy */}
            <div className={`text-center lg:text-left max-w-md transition-all duration-1000 delay-300 ${itemVisible[i] ? 'opacity-100 translate-x-0' : `opacity-0 ${i % 2 === 0 ? 'translate-x-8' : '-translate-x-8'}`}`}>
              <h3 className="text-2xl sm:text-3xl font-black mb-3">{f.title}</h3>
              <p className="text-white/40 text-sm sm:text-base leading-relaxed">{f.desc}</p>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

// ═══════════════════════════════════════════════════════════════
//  OFFER
// ═══════════════════════════════════════════════════════════════

function Offer() {
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.3 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section ref={ref} className="py-28 sm:py-32 px-6 sm:px-12 border-t border-white/[0.04]">
      <div className={`max-w-2xl mx-auto text-center transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-12'}`}>
        <p className="text-blue-400 text-sm font-mono tracking-wider mb-4">LIMITED OFFER</p>

        <h2 className="text-3xl sm:text-5xl font-black mb-4">
          One payment.
          <br />
          <span className="text-white/30">Forever yours.</span>
        </h2>

        <p className="text-white/40 mb-10 text-sm sm:text-base leading-relaxed max-w-lg mx-auto">
          Join the traders who decided to stop guessing. One payment gives you 
          <strong className="text-white">lifetime Pro access</strong> — the full system, forever. No subscription.
        </p>

        <button
          onClick={() => openCheckout(CREEM_PRODUCTS.lifetime, '/thank-you-lifetime')}
          className="inline-flex items-center px-10 py-5 bg-blue-500 text-white text-lg font-bold rounded-2xl hover:bg-blue-400 transition-all duration-200 shadow-[0_0_50px_rgba(59,130,246,0.3)] hover:shadow-[0_0_80px_rgba(59,130,246,0.5)] hover:scale-[1.02] cursor-pointer"
        >
          Get Lifetime Access — $49
        </button>

        <div className="mt-6 flex flex-wrap justify-center gap-x-6 gap-y-2 text-xs text-white/30">
          <span>✓ Lifetime Pro access</span>
          <span>✓ All future features</span>
          <span>✓ Secure payment via Creem</span>
        </div>
      </div>
    </section>
  );
}

// ═══════════════════════════════════════════════════════════════
//  FOOTER
// ═══════════════════════════════════════════════════════════════

function Footer() {
  return (
    <footer className="border-t border-white/[0.04] py-10 sm:py-12 px-6 sm:px-12">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <Logo size={28} variant="full" />
        <div className="flex gap-5 text-xs text-white/25">
          <a href="/terms" className="hover:text-white/50 transition">Terms</a>
          <a href="/privacy" className="hover:text-white/50 transition">Privacy</a>
          <a href="/refund" className="hover:text-white/50 transition">Refund Policy</a>
        </div>
        <span className="text-xs text-white/15">&copy; {new Date().getFullYear()} LocoTrader</span>
      </div>
    </footer>
  );
}

// ═══════════════════════════════════════════════════════════════
//  LEGAL PAGES
// ═══════════════════════════════════════════════════════════════

function LegalPage({ title, content }: { title: string; content: string }) {
  return (
    <div className="min-h-screen bg-[#050508] text-white font-sans px-6 py-20">
      <div className="max-w-2xl mx-auto">
        <a href="/" className="inline-flex items-center gap-2 text-xs text-white/30 hover:text-white/60 transition mb-8">
          <span>&larr;</span> Back to LocoTrader
        </a>
        <h1 className="text-3xl font-black mb-8">{title}</h1>
        <div
          className="prose prose-invert prose-sm max-w-none [&_h2]:text-lg [&_h2]:font-bold [&_h2]:mt-8 [&_h2]:mb-3 [&_p]:text-white/50 [&_p]:leading-relaxed [&_p]:mb-4 [&_li]:text-white/50 [&_ul]:mb-4 [&_ul]:list-disc [&_ul]:pl-5"
          dangerouslySetInnerHTML={{ __html: content }}
        />
        <p className="text-white/20 text-xs mt-12">Last updated: July 2026</p>
      </div>
    </div>
  );
}

const termsContent = `
<p>These Terms of Service ("Terms") govern your use of the LocoTrader application and website (locotrader.app), operated by LocoTrader ("we", "us", "our").</p>

<h2>1. Acceptance of Terms</h2>
<p>By accessing or using LocoTrader, you agree to be bound by these Terms. If you do not agree, do not use our services.</p>

<h2>2. Description of Service</h2>
<p>LocoTrader is a trading journal and discipline tool that provides pre-trade checklists, trade logging, edge analytics, and related features. LocoTrader does not provide financial advice, trading signals, or investment recommendations.</p>

<h2>3. Account Registration</h2>
<p>You must provide accurate information when creating an account. You are responsible for maintaining the security of your account credentials. You must be at least 18 years old to use this service.</p>

<h2>4. Payments and Subscriptions</h2>
<p>Payments are processed securely by Paddle (our Merchant of Record). By purchasing, you agree to Paddle's terms. Prices are displayed inclusive of applicable taxes. Lifetime access means access for the lifetime of the product.</p>

<h2>5. Acceptable Use</h2>
<p>You agree not to:</p>
<ul>
<li>Use the service for any illegal purpose</li>
<li>Attempt to reverse-engineer or exploit the application</li>
<li>Share your account with others or resell access</li>
<li>Upload malicious content or interfere with other users</li>
</ul>

<h2>6. Intellectual Property</h2>
<p>All content, features, and functionality of LocoTrader are owned by us and protected by intellectual property laws. Your trading data remains yours.</p>

<h2>7. Limitation of Liability</h2>
<p>LocoTrader is a journaling and discipline tool, not a financial advisor. We are not liable for any trading losses, missed opportunities, or financial decisions made while using our service. Trading involves substantial risk of loss.</p>

<h2>8. Termination</h2>
<p>We may terminate or suspend your account for violation of these Terms. You may delete your account at any time.</p>

<h2>9. Changes to Terms</h2>
<p>We may update these Terms from time to time. Continued use after changes constitutes acceptance.</p>

<h2>10. Contact</h2>
<p>For questions about these Terms, contact us at support@locotrader.app.</p>
`;

const privacyContent = `
<p>This Privacy Policy describes how LocoTrader ("we", "us", "our") collects, uses, and protects your personal information when you use our application and website (locotrader.app).</p>

<h2>1. Information We Collect</h2>
<p><strong>Account information:</strong> Email address, display name (when you sign up).</p>
<p><strong>Trading data:</strong> Trades you log, journal entries, checklist responses, and analytics. This data is yours and stored securely.</p>
<p><strong>Payment information:</strong> Handled entirely by Paddle (our payment processor). We do not store your credit card details.</p>
<p><strong>Usage data:</strong> Anonymous analytics about how you use the app (no personal trading data is shared).</p>

<h2>2. How We Use Your Information</h2>
<ul>
<li>To provide and maintain the LocoTrader service</li>
<li>To process payments and manage your subscription</li>
<li>To send transactional emails (purchase confirmations, feature updates)</li>
<li>To improve the product based on aggregated, anonymized usage patterns</li>
</ul>

<h2>3. Data Storage and Security</h2>
<p>Your data is stored on Supabase (hosted on AWS) with row-level security. Each user can only access their own data. We use encryption in transit (TLS) and at rest.</p>

<h2>4. Third-Party Services</h2>
<ul>
<li><strong>Paddle:</strong> Payment processing (Merchant of Record)</li>
<li><strong>Supabase:</strong> Database and authentication</li>
<li><strong>Resend:</strong> Transactional emails</li>
<li><strong>Vercel:</strong> Website hosting</li>
</ul>

<h2>5. Your Rights</h2>
<p>You have the right to:</p>
<ul>
<li>Access your personal data</li>
<li>Export your trading data</li>
<li>Delete your account and all associated data</li>
<li>Opt out of non-essential communications</li>
</ul>

<h2>6. Data Retention</h2>
<p>We retain your data for as long as your account is active. If you delete your account, all personal data is permanently removed within 30 days.</p>

<h2>7. Cookies</h2>
<p>We use minimal cookies required for authentication and session management. No third-party tracking cookies are used.</p>

<h2>8. Children's Privacy</h2>
<p>LocoTrader is not intended for users under 18 years of age.</p>

<h2>9. Changes to This Policy</h2>
<p>We may update this Privacy Policy from time to time. We will notify you of material changes via email.</p>

<h2>10. Contact</h2>
<p>For privacy-related inquiries, contact us at support@locotrader.app.</p>
`;

const refundContent = `
<p>We want you to be completely satisfied with your purchase. This policy applies to all purchases made through LocoTrader (locotrader.app).</p>

<h2>14-Day Refund Policy</h2>
<p>If you are not satisfied with your purchase, you may request a full refund within <strong>14 days</strong> of your purchase date. No questions asked.</p>

<h2>How to Request a Refund</h2>
<p>Email us at <strong>support@locotrader.app</strong> with your purchase email address and we will process your refund within 5-7 business days.</p>

<h2>Lifetime Access Purchases</h2>
<p>Lifetime Pro purchases ($49) are eligible for a full refund within 14 days of purchase. After 14 days, lifetime purchases are non-refundable as access is granted immediately and permanently.</p>

<h2>Feature Request Funding</h2>
<p>Feature request payments ($5-$50) are non-refundable once the feature has been marked as "planned" or "building." If the feature has not yet been started, you may request a refund within 14 days.</p>

<h2>Processing</h2>
<p>Refunds are processed by Paddle (our payment processor) and will appear on your statement within 5-10 business days depending on your bank.</p>

<h2>Contact</h2>
<p>For refund requests or questions, email support@locotrader.app.</p>
`;