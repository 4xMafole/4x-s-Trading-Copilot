import React from 'react';
import { cn } from '@/lib/utils';

export function Card({ className, children }: { className?: string; children: React.ReactNode }) {
  return (
    <div className={cn("bg-white/[0.02] border border-white/5 rounded-lg p-6 md:p-8 mb-8", className)}>
      {children}
    </div>
  );
}

export function CardTitle({ className, children }: { className?: string; children: React.ReactNode }) {
  return (
    <h2 className={cn("text-[10px] uppercase tracking-[0.3em] opacity-40 text-[#e0e0e0] mb-6", className)}>
      {children}
    </h2>
  );
}
