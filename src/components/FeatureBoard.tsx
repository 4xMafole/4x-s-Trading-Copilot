import { useState, useEffect, useRef } from 'react';

const SUPABASE_URL = 'https://fistibmbmtcgqdtnwolq.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpc3RpYm1ibXRjZ3FkdG53b2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM3MTMxNjQsImV4cCI6MjA5OTI4OTE2NH0.qnFUUFms4693I9FG2X6CnwaUtZHHwllALYYME-GD1_A';

interface FeatureRequest {
  id: string;
  title: string;
  description: string;
  total_funded: number;
  backer_count: number;
  status: string;
}

const AMOUNTS = [5, 10, 25, 50];

export function FeatureBoard() {
  const [features, setFeatures] = useState<FeatureRequest[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState(5);
  const [loading, setLoading] = useState(true);
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) setVisible(true); },
      { threshold: 0.1 }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, []);

  useEffect(() => { fetchFeatures(); }, []);

  async function fetchFeatures() {
    try {
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/feature_requests?select=*&order=total_funded.desc`,
        { headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}` } }
      );
      if (res.ok) setFeatures(await res.json());
    } catch {} finally { setLoading(false); }
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || amount < 5) return;
    // TODO: Create Stripe Checkout session with metadata
    alert(`"${title}" — $${amount}\n\nStripe payment will be connected here.`);
  }

  return (
    <section ref={ref} id="features" className="py-32 px-6 sm:px-12 border-t border-white/[0.04]">
      <div className={`max-w-3xl mx-auto transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-12'}`}>
        <div className="flex items-end justify-between mb-10">
          <div>
            <h2 className="text-3xl font-black">Shape the product.</h2>
            <p className="text-white/30 mt-1 text-sm">Submit a feature. Pay more = ships faster.</p>
          </div>
          <button
            onClick={() => setShowForm(!showForm)}
            className="px-5 py-2 text-sm font-semibold bg-blue-500/10 border border-blue-500/30 text-blue-400 rounded-lg hover:bg-blue-500/20 transition"
          >
            {showForm ? 'Cancel' : '+ Request — $5'}
          </button>
        </div>

        {showForm && (
          <form onSubmit={handleSubmit} className="mb-10 p-6 rounded-xl border border-white/[0.06] bg-white/[0.015]">
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="What do you need?"
              className="w-full px-0 py-3 bg-transparent border-b border-white/10 text-lg font-medium text-white placeholder:text-white/20 focus:outline-none focus:border-blue-500/50 mb-4"
              required
            />
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
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
                  className={`px-3 py-1.5 rounded text-sm font-mono transition ${
                    amount === a
                      ? 'bg-blue-500 text-white'
                      : 'bg-white/[0.04] text-white/40 hover:text-white/70'
                  }`}
                >
                  ${a}
                </button>
              ))}
            </div>
            <button
              type="submit"
              className="w-full py-3 bg-blue-500 text-white font-bold rounded-xl hover:bg-blue-400 transition"
            >
              Submit & Pay ${amount}
            </button>
          </form>
        )}

        {loading ? (
          <div className="text-white/20 text-sm text-center py-12">Loading...</div>
        ) : features.length === 0 ? (
          <div className="text-center py-16 border border-dashed border-white/[0.06] rounded-2xl">
            <p className="text-white/20 text-sm">No requests yet. Be first.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {features.map((f, i) => (
              <div
                key={f.id}
                className="flex items-center gap-4 p-4 rounded-xl border border-white/[0.04] hover:border-white/[0.08] bg-white/[0.01] hover:bg-white/[0.02] transition group"
                style={{ transitionDelay: `${i * 50}ms` }}
              >
                <div className="shrink-0 w-14 text-center">
                  <span className="text-blue-400 font-bold font-mono text-lg">${f.total_funded}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-sm truncate">{f.title}</p>
                  {f.description && <p className="text-xs text-white/25 truncate">{f.description}</p>}
                </div>
                <button className="opacity-0 group-hover:opacity-100 px-3 py-1 text-xs bg-blue-500/10 text-blue-400 rounded hover:bg-blue-500/20 transition-all">
                  Boost
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  );
}