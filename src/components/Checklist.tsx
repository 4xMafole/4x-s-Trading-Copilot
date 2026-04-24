import React, { useEffect, useState } from 'react';
import { useStore } from '../store';
import { Card, CardTitle } from './ui/Card';
import { Button } from './ui/Button';
import { Alert } from './ui/Alert';
import { GATES } from '../utils/gates';
import { getEAT } from '../utils/time';
import { cn } from '@/lib/utils';
import { Check } from 'lucide-react';

export function Checklist() {
  const { state, toggleCheck, resetChecks, getTodayTrades } = useStore();
  const [now, setNow] = useState(getEAT());

  useEffect(() => {
    const interval = setInterval(() => setNow(getEAT()), 10000);
    return () => clearInterval(interval);
  }, []);

  const h = now.getUTCHours();
  const m = now.getUTCMinutes();
  const t = h * 60 + m;
  const fri = now.getUTCDay() === 5;
  const tc = getTodayTrades().length;

  const autoGates: Record<string, boolean> = {
    g2: !(t >= 540 && t < 630),
    g3: !(t >= 900 && t <= 990),
    g8: tc < 2 && !state.lock,
    g11: !(fri && t >= 1200),
  };

  const handleReset = () => {
    resetChecks(GATES.filter(g => !g.auto).map(g => g.id));
  };

  const total = GATES.length;
  let passed = 0;

  return (
    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card>
        <CardTitle>Pre-trade checklist — all 12 gates required</CardTitle>
        <div className="text-[10px] text-white/50 mb-6 font-mono">Note: Time-based gates auto-validate based on EAT session limits. "Fail" means trading is currently restricted.</div>
        <div className="flex flex-col">
          {GATES.map((g) => {
            const ok = g.auto ? autoGates[g.id] : !!state.checks[g.id];
            if (ok) passed++;

            return (
              <div key={g.id} className="flex items-start gap-4 py-4 border-b border-white/5 last:border-0 hover:bg-white/[0.01] transition-colors p-2 -mx-2 rounded-lg">
                <button
                  type="button"
                  onClick={() => !g.auto && toggleCheck(g.id)}
                  disabled={g.auto}
                  className={cn(
                    "w-5 h-5 rounded-sm border border-white/20 mt-0.5 flex-shrink-0 flex items-center justify-center bg-white/[0.02] transition-all focus:outline-none focus:border-white/50",
                    ok && "bg-emerald-500/10 border-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.2)]",
                    g.auto && "cursor-not-allowed opacity-50"
                  )}
                >
                  {ok && <Check className="w-4 h-4 text-emerald-400" strokeWidth={3} />}
                </button>
                <div className="flex-1">
                  <div className="text-xs font-mono text-white/90 tracking-wide">{g.l}</div>
                  <div className="text-[11px] text-white/40 mt-1.5 leading-snug">{g.s}</div>
                </div>
                <span className={cn(
                  "text-[9px] font-mono tracking-widest uppercase px-2.5 py-1 rounded-sm border ml-auto flex-shrink-0",
                  ok ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-400" :
                  g.auto ? "border-red-500/30 bg-red-500/10 text-red-500" :
                  "border-white/10 bg-white/5 text-white/40"
                )}>
                  {ok ? 'pass' : g.auto ? 'fail' : 'pending'}
                </span>
              </div>
            );
          })}
        </div>

        <div className="mt-8">
          {passed === total ? (
            <Alert variant="green">All {total} gates passed — you may execute. Calculate lot size first.</Alert>
          ) : passed >= total - 3 ? (
            <Alert variant="amber">{passed}/{total} — {total - passed} remaining. Complete all before entering.</Alert>
          ) : (
            <Alert variant="red">{passed}/{total} gates — conditions unmet for trading.</Alert>
          )}
        </div>

        <div className="flex gap-2 flex-wrap mt-4">
          <Button onClick={handleReset} variant="outline">Reset manual checks</Button>
        </div>
      </Card>
    </div>
  );
}
