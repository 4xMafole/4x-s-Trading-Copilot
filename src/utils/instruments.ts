export const INSTR = {
  XAUUSD: { unit: '$ price move', pipVal: 1, desc: '$ move in gold price' },
  NQ:     { unit: 'index points', pipVal: 2, desc: 'NQ points (1pt = $2 per 0.1 lot)' },
  EURUSD: { unit: 'pips',         pipVal: 1, desc: 'pips (1 pip = $1 per 0.1 lot)' },
};

export type InstrKeys = keyof typeof INSTR;
