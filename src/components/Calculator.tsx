import React, { useState, useEffect } from 'react';
import { Card, CardTitle } from './ui/Card';
import { Input, Label } from './ui/Input';
import { Alert } from './ui/Alert';
import { INSTR, InstrKeys } from '../utils/instruments';
import { cn } from '@/lib/utils';

export function Calculator() {
  const [instr, setInstr] = useState<InstrKeys>('XAUUSD');
  const [sl, setSl] = useState<string>('7');
  const [entries, setEntries] = useState<string>('1');
  
  // Output state
  const [lotRes, setLotRes] = useState('0.00');
  const [totRisk, setTotRisk] = useState('$0.00');

  useEffect(() => {
    const slNum = parseFloat(sl) || 0;
    const entNum = parseInt(entries) || 1;
    const pv = INSTR[instr].pipVal;
    
    let lot = 0;
    if (slNum > 0 && pv > 0 && entNum > 0) {
      lot = (125 / entNum) / (slNum * pv * 10);
    }

    setLotRes(lot.toFixed(2) + ' lots');
    setTotRisk('$' + Math.min(125, lot * entNum * slNum * pv * 10).toFixed(2));
  }, [instr, sl, entries]);

  const tpOut = (parseFloat(sl) || 0) * 2;

  return (
    <div className="space-y-3 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card>
        <CardTitle>Lot size calculator — $125 risk cap</CardTitle>
        <div className="flex gap-1.5 mb-3 flex-wrap">
          {(Object.keys(INSTR) as InstrKeys[]).map((k) => (
            <button
              key={k}
              onClick={() => setInstr(k)}
              className={cn(
                "px-4 py-3 text-[10px] uppercase font-bold tracking-[0.2em] transition-all rounded-sm border shrink-0",
                instr === k 
                  ? "bg-white text-[#0a0a0a] border-white shadow-[0_0_10px_rgba(255,255,255,0.2)]" 
                  : "bg-transparent border-white/10 text-white/50 hover:bg-white/5"
              )}
            >
              {k === 'NQ' ? 'NQ100' : k}
            </button>
          ))}
        </div>

        {instr === 'EURUSD' && (
          <Alert variant="blue" className="mb-3">
            EU reminder: sells only · Thursday/Monday only · 13:00–16:30 EAT · single entry only.
          </Alert>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div>
            <Label>SL distance</Label>
            <Input 
              type="number" 
              value={sl} 
              onChange={e => setSl(e.target.value)} 
              min="0.1" 
              step="0.1" 
            />
            <div className="text-[10px] uppercase tracking-widest text-white/40 mt-2">
              {INSTR[instr].unit} ({INSTR[instr].desc})
            </div>
          </div>
          <div>
            <Label>Number of entries (stacked)</Label>
            <Input 
              type="number" 
              value={entries} 
              onChange={e => setEntries(e.target.value)} 
              min="1" max="5" step="1" 
            />
            <div className="text-[10px] uppercase tracking-widest text-white/40 mt-2">
              combined risk capped at $125
            </div>
          </div>
        </div>

        <div className="bg-white/[0.02] border border-white/5 rounded-lg p-5 mt-4 flex justify-between items-center">
          <div>
            <div className="text-[10px] uppercase tracking-[0.2em] text-white/40 mb-1">Max lot size per entry</div>
            <div className="text-2xl font-mono text-white">
              {lotRes}
            </div>
            {parseInt(entries) > 1 && (
              <div className="text-[11px] font-mono text-amber-500 mt-1">
                {entries}× {parseFloat(lotRes).toFixed(2)} lots each
              </div>
            )}
          </div>
          <div className="text-right">
            <div className="text-[10px] uppercase tracking-[0.2em] text-white/40 mb-1">Total risk</div>
            <div className="text-xl font-mono text-white/80">{totRisk}</div>
          </div>
        </div>

        {parseInt(entries) > 1 && (
          <Alert variant="amber" className="mt-3">
            Stacking alert: combined risk must stay ≤ $125 total across all entries.
          </Alert>
        )}
      </Card>

      <Card>
        <CardTitle>Target calculator — minimum 2R</CardTitle>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div>
            <Label>SL distance (same as above)</Label>
            <Input 
              type="number" 
              value={sl} 
              onChange={e => setSl(e.target.value)} 
              min="0.1" step="0.1" 
            />
          </div>
          <div>
            <Label>Minimum TP distance (2× SL)</Label>
            <Input 
              type="number" 
              readOnly 
              value={tpOut.toFixed(1)} 
              className="bg-white/[0.01] border-white/5 text-white/40 cursor-not-allowed" 
            />
            <div className="text-[10px] uppercase tracking-[0.2em] text-white/40 mt-2">
              = $250 minimum target
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
}
