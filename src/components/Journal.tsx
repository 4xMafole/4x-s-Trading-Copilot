import React, { useState } from 'react';
import { useStore } from '../store';
import { Card, CardTitle } from './ui/Card';
import { Input, Select, Textarea, Label } from './ui/Input';
import { Button } from './ui/Button';
import { Alert } from './ui/Alert';
import { Badge } from './ui/Badge';
import { cn } from '@/lib/utils';
import { X } from 'lucide-react';

const VIOLATIONS = [
  { id: 'stacking', label: 'Stacking' },
  { id: 'session', label: 'Session timing' },
  { id: 'risk', label: 'Risk exceeded' },
  { id: 'instrument', label: 'Off-list instrument' },
  { id: 'rr', label: 'R:R below 1:2' },
];

export function Journal() {
  const { state, addTrade, deleteTrade, getTodayTrades } = useStore();
  
  const [sym, setSym] = useState('XAUUSD');
  const [dir, setDir] = useState<'buy' | 'sell'>('buy');
  const [lots, setLots] = useState('');
  const [pnl, setPnl] = useState('');
  const [note, setNote] = useState('');
  const [violations, setViolations] = useState<string[]>([]);
  const [alert, setAlert] = useState<{ type: 'red' | 'green', msg: string } | null>(null);

  const tc = getTodayTrades().length;

  const handleLog = () => {
    if (state.lock || tc >= 2) {
      setAlert({ type: 'red', msg: 'Session closed — 2 trades used or lock active.' });
      return;
    }
    const pnlNum = parseFloat(pnl);
    if (isNaN(pnlNum)) {
      setAlert({ type: 'red', msg: 'Enter a valid P&L value.' });
      return;
    }

    addTrade({
      sym,
      dir,
      lots: parseFloat(lots) || 0,
      pnl: pnlNum,
      note,
      violations
    });

    setLots('');
    setPnl('');
    setNote('');
    setViolations([]);
    setAlert({ type: 'green', msg: 'Trade logged successfully.' });
    setTimeout(() => setAlert(null), 3000);
  };

  const todayTrades = getTodayTrades();

  return (
    <div className="space-y-3 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card>
        <CardTitle>Log a trade</CardTitle>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div>
            <Label>Instrument</Label>
            <Select value={sym} onChange={e => setSym(e.target.value)}>
              <option value="XAUUSD">XAUUSD</option>
              <option value="NQ">NQ</option>
              <option value="EURUSD">EURUSD</option>
            </Select>
          </div>
          <div>
            <Label>Direction</Label>
            <Select value={dir} onChange={e => setDir(e.target.value as 'buy' | 'sell')}>
              <option value="buy">buy</option>
              <option value="sell">sell</option>
            </Select>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div>
            <Label>Lot size</Label>
            <Input type="number" placeholder="0.18" step="0.01" min="0.01" value={lots} onChange={e => setLots(e.target.value)} />
          </div>
          <div>
            <Label>Net P&L ($)</Label>
            <Input type="number" placeholder="-125.00" step="0.01" value={pnl} onChange={e => setPnl(e.target.value)} />
          </div>
        </div>

        <div className="mb-3">
          <Label>Violations (tick all that apply)</Label>
          <div className="flex gap-4 flex-wrap mt-2">
            {VIOLATIONS.map(v => (
              <label key={v.id} className="flex items-center gap-2 text-[11px] font-mono uppercase tracking-widest text-white/60 cursor-pointer hover:text-white transition-colors">
                <input 
                  type="checkbox" 
                  checked={violations.includes(v.id)}
                  onChange={e => {
                    if (e.target.checked) setViolations([...violations, v.id]);
                    else setViolations(violations.filter(id => id !== v.id));
                  }}
                  className="rounded-none border-white/20 bg-white/5 accent-emerald-500 w-3 h-3"
                />
                {v.label}
              </label>
            ))}
          </div>
        </div>

        <div className="mb-3">
          <Label>Notes</Label>
          <Textarea 
            placeholder="What happened? What would you do differently?" 
            value={note}
            onChange={e => setNote(e.target.value)}
          />
        </div>

        <Button className="w-full" onClick={handleLog}>Add to journal</Button>
        {alert && <Alert variant={alert.type} className="mt-3">{alert.msg}</Alert>}
      </Card>

      <Card>
        <CardTitle>Today's trades</CardTitle>
        <div className="flex flex-col">
          {todayTrades.length === 0 ? (
            <div className="text-[10px] text-white/40 uppercase tracking-widest font-mono py-2">No trades today.</div>
          ) : (
            todayTrades.map(t => (
              <div key={t.id} className="py-4 border-b border-white/5 last:border-0 relative group">
                <div className="flex items-center gap-3 flex-wrap pr-6">
                  <span className="font-mono text-sm tracking-tight text-white/90">{t.sym}</span>
                  <Badge variant={t.dir === 'buy' ? 'blue' : 'amber'}>{t.dir}</Badge>
                  <span className="text-xs font-mono text-white/40">{t.lots || '?'}L</span>
                  <span className="text-xs font-mono text-white/30 ml-2">{t.time}</span>
                  <span className={cn("ml-auto font-mono text-lg tracking-tight", t.pnl >= 0 ? "text-emerald-500" : "text-[#A32D2D]")}>
                    {t.pnl >= 0 ? '+' : ''}${t.pnl.toFixed(2)}
                  </span>
                </div>
                
                {t.violations && t.violations.length > 0 && (
                  <div className="mt-3 flex gap-2 flex-wrap">
                    {t.violations.map(vId => {
                      const vObj = VIOLATIONS.find(v => v.id === vId);
                      return <Badge key={vId} variant="red">{vObj?.label || vId}</Badge>
                    })}
                  </div>
                )}
                
                {t.note && (
                  <div className="text-[11px] font-mono text-white/50 mt-3 leading-relaxed bg-white/[0.02] border-l-2 border-white/10 p-3">
                    {t.note}
                  </div>
                )}
                
                <button 
                  onClick={() => deleteTrade(t.id)}
                  className="absolute top-2 right-0 p-1 text-neutral-400 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-opacity"
                  title="Delete trade"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))
          )}
        </div>
      </Card>
      <ComplianceAudit />
    </div>
  );
}

function ComplianceAudit() {
  const { getTodayTrades } = useStore();
  const tt = getTodayTrades();
  
  if (!tt.length) {
    return (
      <Card>
        <CardTitle>Compliance audit</CardTitle>
        <div className="text-[10px] uppercase font-mono tracking-widest text-white/40 py-2">Log trades to see your compliance report.</div>
      </Card>
    );
  }

  const totalV = tt.reduce((s, t) => s + (t.violations?.length || 0), 0);
  const score = Math.max(0, Math.round((1 - totalV / (tt.length * 5)) * 100));
  const vBreak: Record<string, number> = {};
  
  tt.forEach(t => (t.violations || []).forEach(v => vBreak[v] = (vBreak[v] || 0) + 1));
  
  const fixes: Record<string, string> = {
    stacking: 'Section 7.1 — one entry per deployment, combined risk ≤ $125.',
    session: 'Section 3.1 — check session window before every trade.',
    risk: 'Section 2.1 — use the calculator, not guesswork.',
    instrument: 'Section 4 — XAUUSD, NQ, EURUSD only.',
    rr: 'Section 2.4 — TP must be ≥ 2× SL.'
  };

  const vL: Record<string, string> = {};
  VIOLATIONS.forEach(v => vL[v.id] = v.label);

  return (
    <Card>
      <CardTitle>Compliance audit</CardTitle>
      
      <div className="mb-4">
        <span className={cn("text-4xl font-mono tracking-tighter", score >= 80 ? "text-emerald-500" : score >= 50 ? "text-amber-500" : "text-[#A32D2D]")}>
          {score}
        </span>
        <span className="text-[10px] font-mono uppercase tracking-widest text-white/40 ml-3">/ 100 compliance score</span>
      </div>

      {totalV > 0 ? (
        <>
          <Alert variant="red" className="mb-4">
            {Object.entries(vBreak).map(([k, v]) => `${v}× ${vL[k] || k}`).join(', ')} — review your trading plan.
          </Alert>
          <div className="text-[11px] font-mono text-white/50 space-y-2">
            {Object.entries(vBreak).map(([k]) => (
              <div key={k} className="py-2 border-b border-white/5 last:border-0 leading-relaxed">
                <Badge variant="red" className="mr-2 inline-block">{vL[k] || k}</Badge> {fixes[k] || 'Review rule.'}
              </div>
            ))}
          </div>
        </>
      ) : (
        <Alert variant="green">Perfect compliance today. Keep the same discipline tomorrow.</Alert>
      )}
    </Card>
  );
}
