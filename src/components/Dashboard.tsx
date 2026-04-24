import React, { useEffect, useState } from 'react';
import { useStore } from '../store';
import { Card, CardTitle } from './ui/Card';
import { eatDateStr, getEAT, getSessionInfo } from '../utils/time';
import { cn } from '@/lib/utils';

export function Dashboard() {
  const { state, getDayNumber, getChallengePnl, getTodayPnl, getTodayTrades } = useStore();
  const [now, setNow] = useState(getEAT());

  useEffect(() => {
    const interval = setInterval(() => setNow(getEAT()), 10000);
    return () => clearInterval(interval);
  }, []);

  const dayNumber = getDayNumber();
  const challengePnl = getChallengePnl();
  const todayPnl = getTodayPnl();
  const todayTrades = getTodayTrades();
  const balance = state.balance + challengePnl;
  const dleft = 1250 + todayPnl;
  const tc = todayTrades.length;
  const prog = Math.max(0, Math.min(100, (challengePnl / 1250) * 100));

  const totalViolations = todayTrades.reduce((s, t) => s + (t.violations?.length || 0), 0);
  const score = Math.max(0, Math.round((1 - totalViolations / (Math.max(1, tc) * 5)) * 100));

  const sessionInfo = getSessionInfo(now);

  return (
    <div className="space-y-3 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
        <StatBox label="Balance" value={`$${balance.toFixed(2)}`} valColor={balance >= state.balance ? 'text-white' : 'text-[#A32D2D]'} />
        <StatBox label="Today's P&L" value={`${todayPnl >= 0 ? '+' : ''}$${todayPnl.toFixed(2)}`} valColor={todayPnl >= 0 ? 'text-emerald-500' : 'text-[#A32D2D]'} />
        <StatBox label="Daily limit left" value={`$${Math.max(0, dleft).toFixed(2)}`} valColor={dleft > 500 ? 'text-emerald-500' : dleft > 200 ? 'text-amber-500' : 'text-[#A32D2D]'} />
        <StatBox label="Trades today" value={`${tc}/2`} valColor={tc < 2 ? 'text-emerald-500' : 'text-[#A32D2D]'} />
        <StatBox label="Challenge P&L" value={`${challengePnl >= 0 ? '+' : ''}$${challengePnl.toFixed(2)}`} valColor={challengePnl >= 0 ? 'text-emerald-500' : 'text-[#A32D2D]'} />
        <StatBox label="Progress" value={`${prog.toFixed(1)}%`} />
      </div>

      <Card>
        <CardTitle>Phase 2 target — $1,250</CardTitle>
        <div className="h-2 bg-white/5 rounded-none overflow-hidden my-4 border border-white/5">
          <div 
            className={`h-full transition-all duration-700 ease-out rounded-none ${prog >= 100 ? 'bg-emerald-500' : prog >= 50 ? 'bg-emerald-500/80' : 'bg-white/40'}`} 
            style={{ width: `${prog}%` }}
          />
        </div>
        <div className="flex justify-between text-[10px] tracking-widest uppercase text-white/40 font-mono">
          <span>${Math.max(0, challengePnl).toFixed(2)} earned</span>
          <span>$1,250 needed to pass</span>
        </div>
      </Card>

      <Card>
        <CardTitle>Session window</CardTitle>
        <div className="text-xs text-white/60 leading-relaxed font-mono">
          {sessionInfo?.detail || "Checking..."}
        </div>
      </Card>

      <Card>
        <CardTitle>Today's compliance</CardTitle>
        <div className="flex items-center gap-6">
          <div>
            <div className={`text-4xl font-mono tracking-tighter ${tc === 0 ? 'text-white/40' : score >= 80 ? 'text-emerald-500' : score >= 50 ? 'text-amber-500' : 'text-[#A32D2D]'}`}>
              {tc === 0 ? '—' : score}
            </div>
          </div>
          <div className="text-[11px] text-white/50 leading-relaxed max-w-[200px]">
            {tc === 0 ? 'Log trades to generate your compliance score.' : 
             totalViolations ? `${totalViolations} violation${totalViolations > 1 ? 's' : ''} across ${tc} trade${tc > 1 ? 's' : ''}.` :
             'Clean session. All rules followed.'}
          </div>
        </div>
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
