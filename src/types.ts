export interface Trade {
  id: string;
  date: string;
  time: string;
  sym: string;
  dir: 'buy' | 'sell';
  lots: number;
  pnl: number;
  note: string;
  violations: string[];
}

export interface AppState {
  balance: number;
  startDate: string;
  priorPnl: number;
  checks: Record<string, boolean>;
  allTrades: Trade[];
  lock: boolean;
  lockUntil: number | null;
  preloaded: boolean;
}

export type TabKey = 'dash' | 'edge' | 'check' | 'calc' | 'journal' | 'settings';
