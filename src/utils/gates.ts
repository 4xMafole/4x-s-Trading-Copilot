export const GATES = [
  { id: 'g1',  auto: false, l: 'Instrument on watchlist',              s: 'XAUUSD, NQ100, or EURUSD only' },
  { id: 'g2',  auto: true,  l: 'Outside early London dead zone',       s: 'Must be outside 09:00–10:30 EAT (4.2% EU WR — hard no-trade)' },
  { id: 'g3',  auto: true,  l: 'Outside blackout zone',                s: 'Must be outside 15:00–16:30 EAT (coin-flip results)' },
  { id: 'g4',  auto: false, l: 'HTF trend identified on H4 + Daily',   s: 'Written down — not from memory' },
  { id: 'g5',  auto: false, l: 'Entry aligns with HTF direction',      s: 'No counter-trend trades' },
  { id: 'g6',  auto: false, l: 'Liquidity sweep or zone tap confirmed',s: 'Price swept significant high/low or tapped OB/FVG' },
  { id: 'g7',  auto: false, l: 'LTF Break of Structure confirmed',     s: 'M5 or M15 BOS — not just a wick' },
  { id: 'g8',  auto: true,  l: 'Trade slots available',                s: 'Fewer than 2 trades today — lock not active' },
  { id: 'g9',  auto: false, l: 'Lot size calculated — risk ≤ $125',    s: 'Used the calculator, not guesswork' },
  { id: 'g10', auto: false, l: 'TP ≥ 2× SL (minimum $250 target)',    s: 'R:R confirmed 1:2 minimum before entry' },
  { id: 'g11', auto: true,  l: 'Friday kill-switch clear',             s: 'If Friday: time is before 20:00 EAT' },
  { id: 'g12', auto: false, l: 'Single deployment — combined risk ≤ $125', s: 'All same-asset entries = one deployment' },
];
