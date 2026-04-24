export function getEAT(): Date {
  // Use pure UTC offset math (EAT is UTC+3)
  return new Date(Date.now() + 3 * 3600 * 1000);
}

export function eatDateStr(eat: Date): string {
  // Because 'eat' has its UTC time shifted to match Nairobi local time,
  // we must use the UTC methods to get the correct YYYY-MM-DD.
  const yyyy = eat.getUTCFullYear();
  const mm = String(eat.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(eat.getUTCDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

export type SessionType = 'gray' | 'red' | 'green' | 'amber';

export interface SessionInfo {
  label: string;
  type: SessionType;
  ok: boolean;
  detail: string;
}

export function getSessionInfo(eat: Date): SessionInfo {
  // IMPORTANT: Because 'eat' has its epoch shifted by 3 hours, we MUST get
  // the 'UTC' hours and minutes to read what the EAT time actually is.
  const h = eat.getUTCHours();
  const m = eat.getUTCMinutes();
  const t = h * 60 + m;
  const fri = eat.getUTCDay() === 5;

  if (t < 540)  return { label: 'Pre-London — no trade',    type: 'gray',  ok: false, detail: 'Market not open for your sessions. Study H4/Daily on all three instruments. Mark key levels.' };
  if (t < 630)  return { label: 'Early London — dead zone', type: 'red',   ok: false, detail: '09:00–10:30 EAT: Hard no-trade for EURUSD (4.2% WR / 23 straight losses). XAUUSD not in prime window. Observe only.' };
  if (t < 780)  return { label: 'Mid London — valid',       type: 'green', ok: true,  detail: '10:30–13:00 EAT: EU sell setups valid (Thu/Mon only). XAUUSD only if HTF strongly aligns. Max 1 trade.' };
  if (t < 900)  return { label: 'Late London — prime',      type: 'green', ok: true,  detail: '13:00–15:00 EAT: All three instruments active. Best EU and XAUUSD window per your data. Be alert.' };
  if (t <= 990) return { label: 'BLACKOUT — no execution',  type: 'red',   ok: false, detail: '15:00–16:30 EAT: Step away. 45.5% WR = coin flip. NY pre-market noise. No exceptions.' };
  if (fri && t >= 1200) return { label: 'Friday kill-switch',type: 'red',  ok: false, detail: 'After 20:00 EAT Friday: ALL positions flat. No new trades. Weekend holdings prohibited.' };
  if (t <= 1110) return { label: 'NY Open — prime',         type: 'green', ok: true,  detail: '16:30–18:30 EAT: NQ and XAUUSD prime window. Confirmed directional move post-blackout.' };
  if (t <= 1200) return { label: 'NY Mid — caution',        type: 'amber', ok: true,  detail: '18:30–20:00 EAT: NQ continuation only. No new XAUUSD or EURUSD. Manage positions only.' };
  return         { label: 'NY Late — no trade',             type: 'gray',  ok: false, detail: 'After 20:00 EAT: Session over. Journal your trades. Review compliance.' };
}
