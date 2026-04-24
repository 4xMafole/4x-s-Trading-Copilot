import React, { useEffect, useState } from 'react';
import { useStore } from '../store';
import { Badge } from './ui/Badge';
import { getEAT, SessionInfo, getSessionInfo } from '../utils/time';

export function TopBar() {
  const { getDayNumber } = useStore();
  const [timeStr, setTimeStr] = useState('');
  const [session, setSession] = useState<SessionInfo | null>(null);

  useEffect(() => {
    const updateTime = () => {
      const eat = getEAT();
      const hh = String(eat.getUTCHours()).padStart(2, '0');
      const mm = String(eat.getUTCMinutes()).padStart(2, '0');
      const ss = String(eat.getUTCSeconds()).padStart(2, '0');
      setTimeStr(`${hh}:${mm}:${ss}`);
      setSession(getSessionInfo(eat));
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <header className="min-h-[100px] py-4 border-b border-white/5 flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4 px-2 md:px-0">
      <div className="flex flex-col gap-3">
        <h1 className="font-serif text-2xl md:text-3xl tracking-tight text-white italic">4x's Copilot</h1>
        <div className="flex gap-2 items-center flex-wrap">
          <Badge variant="blue">Day {getDayNumber()}</Badge>
          {session ? (
            <Badge variant={session.type as any}>{session.label}</Badge>
          ) : (
            <Badge variant="gray">Status Load...</Badge>
          )}
        </div>
      </div>
      <div className="flex flex-col items-start md:items-end mb-4 md:mb-0">
        <span className="text-[11px] font-mono text-white/40 mb-1">EAT · UTC+3</span>
        <span className="text-xl font-mono text-[#e0e0e0]">{timeStr || '--:--:--'}</span>
      </div>
    </header>
  );
}
