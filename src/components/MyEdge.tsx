import React from 'react';
import { Card, CardTitle } from './ui/Card';
import { cn } from '@/lib/utils';
import { Alert } from './ui/Alert';

export function MyEdge() {
  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card>
        <CardTitle>Personal account overview — 572 trades · Jul 2025 – Mar 2026</CardTitle>
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          <StatBox label="Total trades" value="572" valColor="text-blue-400" />
          <StatBox label="Net P&L" value="+$301.06" valColor="text-emerald-500" />
          <StatBox label="Overall win rate" value="32.4%" valColor="text-amber-500" />
          <StatBox label="Avg R:R achieved" value="2.71" valColor="text-emerald-500" />
          <StatBox label="Avg win" value="+$38.48" valColor="text-emerald-500" />
          <StatBox label="Avg loss" value="-$14.19" valColor="text-red-500" />
        </div>
        <Alert variant="blue">
          <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">The paradox</div>
          32.4% win rate but still net profitable. Your average win ($38.48) is 2.71× your average loss ($14.19). The system has positive expectancy — it only needs discipline applied on top.
        </Alert>
      </Card>

      <Card>
        <CardTitle>Symbol performance — where your edge lives</CardTitle>

        <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/50 border-b border-white/10 pb-2 mb-4 mt-8">Your top instruments</div>
        <EdgeRow label="XAUUSD" sub="19 trades · Primary instrument" val="47% WR" valSub="+$406.90" valColor="text-emerald-500" percent={47} barColor="bg-emerald-500" />
        <EdgeRow label="NQ100" sub="16 trades · Secondary instrument" val="44% WR" valSub="+$49.10" valColor="text-emerald-500" percent={44} barColor="bg-emerald-500" />
        <EdgeRow label="EURUSD" sub="40 trades · Conditional only" val="25% WR" valSub="+$50.70" valColor="text-amber-500" percent={25} barColor="bg-amber-500" />

        <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/50 border-b border-white/10 pb-2 mb-4 mt-12">Avoid completely</div>
        <EdgeRow label="XAGUSD" sub="3 trades" val="0% WR" valSub="-$179.05" valColor="text-red-500" percent={0} barColor="bg-red-500" />
        <EdgeRow label="BTCUSD / ETHUSD" sub="11 trades combined" val="18% WR" valSub="-$55.56" valColor="text-red-500" percent={18} barColor="bg-red-500" />
        <EdgeRow label="GBPUSD" sub="15 trades" val="33% WR" valSub="-$60.22" valColor="text-red-500" percent={33} barColor="bg-amber-500" />
      </Card>

      <Card>
        <CardTitle>Session timing — your confirmed windows (EAT)</CardTitle>
        <EdgeRow active label="09:00–10:30 EAT — dead zone" labelColor="text-red-500" sub="EURUSD: 24 trades, 23 straight losses" val="4.2% WR" valSub="-$71.17" valColor="text-red-500" noBar />
        <EdgeRow label="10:30–13:00 EAT — mid London" sub="EU sells valid. Small sample but promising" val="66.7% WR" valSub="+$15.27" valColor="text-emerald-500" noBar />
        <EdgeRow label="13:00–15:00 EAT — late London" sub="All three instruments. Best EU + XAUUSD zone" val="Prime window" valColor="text-emerald-500" noBar />
        <EdgeRow active label="15:00–16:30 EAT — blackout" labelColor="text-red-500" sub="XAUUSD: identical WR inside and outside — coin flip" val="45.5% WR" valSub="No edge" valColor="text-red-500" noBar />
        <EdgeRow label="16:30–18:30 EAT — NY open" sub="NQ primary. XAUUSD continuation" val="Prime window" valColor="text-emerald-500" noBar />
        <EdgeRow active label="20:00+ EAT — NY late" labelColor="text-red-500" sub="Thin liquidity, asymmetric losses" val="50% WR" valSub="-$29.60" valColor="text-red-500" noBar />
      </Card>

      <Card>
        <CardTitle>EURUSD deep dive — direction bias confirmed</CardTitle>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <div className="bg-red-500/10 border border-red-500/20 p-4 rounded-lg">
            <div className="font-bold uppercase tracking-[0.2em] text-[10px] text-red-500 mb-4">Buying EURUSD</div>
            <div className="text-xs font-mono text-red-400 mb-1">29 trades</div>
            <div className="text-2xl font-mono tracking-tight text-red-500 mb-1">13.8% WR</div>
            <div className="text-[11px] font-mono text-red-400 mb-3">Net: -$6.05</div>
            <div className="text-[10px] uppercase tracking-widest text-red-500/60 leading-relaxed border-t border-red-500/20 pt-3 mt-3">25 of 29 buys hit SL</div>
          </div>
          <div className="bg-emerald-500/10 border border-emerald-500/20 p-4 rounded-lg">
            <div className="font-bold uppercase tracking-[0.2em] text-[10px] text-emerald-500 mb-4">Selling EURUSD</div>
            <div className="text-xs font-mono text-emerald-400 mb-1">11 trades</div>
            <div className="text-2xl font-mono tracking-tight text-emerald-500 mb-1">54.5% WR</div>
            <div className="text-[11px] font-mono text-emerald-400 mb-3">Net: +$56.75</div>
            <div className="text-[10px] uppercase tracking-widest text-emerald-500/60 leading-relaxed border-t border-emerald-500/20 pt-3 mt-3">Your real EU edge</div>
          </div>
        </div>

        <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/50 border-b border-white/10 pb-2 mb-4 mt-8">EU day-of-week breakdown</div>
        <EdgeRow label="Thursday" sub="9 trades" val="44.4% WR · +$72.07" valColor="text-emerald-500" percent={44} barColor="bg-emerald-500" />
        <EdgeRow label="Monday" sub="5 trades" val="20% WR · +$41.22" valColor="text-emerald-500" percent={20} barColor="bg-amber-500" />
        <EdgeRow label="Tuesday" sub="19 trades" val="26.3% WR · +$20.61" valColor="text-amber-500" percent={26} barColor="bg-amber-500" />
        <EdgeRow active label="Wednesday" labelColor="text-red-500" sub="5 trades" val="0% WR · -$44.30" valColor="text-red-500" percent={0} barColor="bg-red-500" />
        <EdgeRow active label="Friday" labelColor="text-red-500" sub="2 trades" val="0% WR · -$38.90" valColor="text-red-500" percent={0} barColor="bg-red-500" />

        <Alert variant="amber" className="mt-8">
          <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">EU entry rule — all 4 required</div>
          Thursday or Monday · 13:00–16:30 EAT · HTF bearish (sell only) · Single entry only. Missing even one condition = no trade.
        </Alert>
      </Card>

      <Card>
        <CardTitle>Stacking vs single entry — the definitive case</CardTitle>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="bg-emerald-500/10 border border-emerald-500/20 p-4 rounded-lg">
            <div className="font-bold uppercase tracking-[0.2em] text-[10px] text-emerald-500 mb-4">Single entry days</div>
            <div className="text-2xl font-mono tracking-tight text-emerald-500 mb-1">50% WR</div>
            <div className="text-[11px] font-mono text-emerald-400 mb-3">+$103.61 · 16 days</div>
            <div className="text-[10px] uppercase tracking-widest text-emerald-500/60 leading-relaxed border-t border-emerald-500/20 pt-3 mt-3">One entry with conviction — the math works</div>
          </div>
          <div className="bg-red-500/10 border border-red-500/20 p-4 rounded-lg">
            <div className="font-bold uppercase tracking-[0.2em] text-[10px] text-red-500 mb-4">Stacked days</div>
            <div className="text-2xl font-mono tracking-tight text-red-500 mb-1">8.3% WR</div>
            <div className="text-[11px] font-mono text-red-400 mb-3">-$52.91 · 6 days</div>
            <div className="text-[10px] uppercase tracking-widest text-red-500/60 leading-relaxed border-t border-red-500/20 pt-3 mt-3">Re-entering after loss — not finding new setups</div>
          </div>
        </div>
      </Card>

      <Card>
        <CardTitle>Behavioural flags — confirmed patterns</CardTitle>
        <div className="space-y-4">
          <Alert variant="red">
            <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">Stacking (critical)</div>
            Personal account: 3–56 trades per day. EU stacked days: 8.3% WR. Single entry days: 50% WR. After any losing trade, wait 60 minutes minimum before re-entry on same instrument.
          </Alert>
          <Alert variant="red">
            <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">Early London execution</div>
            09:00–10:30 EAT: 23 consecutive EURUSD losses. 4.2% WR. Hard no-trade zone — treat it as a second blackout.
          </Alert>
          <Alert variant="amber">
            <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">EU buy bias</div>
            29 buys → 13.8% WR · 11 sells → 54.5% WR. Default to sells until macro structure shifts bullish on H4/Daily.
          </Alert>
          <Alert variant="amber">
            <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">Lot size inconsistency</div>
            Personal account: 0.01 to 1.8 lots with no formula. Use the Calculator tab before every trade — 30 seconds, no exceptions.
          </Alert>
        </div>
      </Card>

      <Card>
        <CardTitle>XAUUSD blackout zone — the confirmed verdict</CardTitle>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <StatBox label="WR inside blackout" value="45.5%" valColor="text-amber-500" />
          <StatBox label="WR after blackout" value="45.5%" valColor="text-amber-500" />
          <StatBox label="Net inside (raw)" value="+$259" valColor="text-amber-500" />
          <StatBox label="Net (remove outlier)" value="-$67.19" valColor="text-red-500" />
        </div>
        <Alert variant="red">
          <div className="font-bold uppercase tracking-[0.2em] mb-2 text-[10px]">The +$192.60 outlier</div>
          The entire positive P&L inside the blackout is carried by one trade on Jan 20. Remove it and the window returns -$67 on 10 trades. That is not an edge — it is lottery trading. The blackout stands.
        </Alert>
      </Card>
    </div>
  );
}

function StatBox({ label, value, valColor }: { label: string; value: string; valColor?: string }) {
  return (
    <div className="bg-white/[0.03] border border-white/10 p-4 md:p-5 rounded-lg flex flex-col justify-between min-h-[90px]">
      <div className="text-[10px] uppercase tracking-[0.2em] text-white/40 mb-2">{label}</div>
      <div className={cn("text-lg md:text-2xl font-mono tracking-tight", valColor || "text-white")}>{value}</div>
    </div>
  );
}

function EdgeRow({ label, sub, val, valSub, valColor, percent, barColor, noBar, labelColor, active }: any) {
  return (
    <div className={cn(
      "flex items-center gap-4 py-4 border-b border-white/5 last:border-0",
      active && "bg-red-500/5 -mx-4 px-6 border-l-4 border-l-red-500"
    )}>
      <div className="flex-1">
        <div className={cn("font-mono text-sm tracking-tight mb-1", labelColor || "text-white/90")}>{label}</div>
        <div className="text-[11px] text-white/40">{sub}</div>
      </div>
      
      {!noBar && (
        <div className="hidden md:block w-32 shrink-0">
          <div className="h-2 bg-white/5 w-full rounded-none overflow-hidden border border-white/5">
            <div className={cn("h-full transition-all", barColor)} style={{ width: `${percent}%` }} />
          </div>
        </div>
      )}
      
      <div className="min-w-[80px] text-right">
        <div className={cn("font-mono text-sm tracking-tight", valColor)}>{val}</div>
        {valSub && <div className="text-[10px] font-mono text-white/40 mt-1">{valSub}</div>}
      </div>
    </div>
  );
}
