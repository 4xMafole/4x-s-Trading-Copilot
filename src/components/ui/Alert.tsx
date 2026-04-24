import React from 'react';
import { cn } from '@/lib/utils';

interface AlertProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'red' | 'green' | 'amber' | 'blue';
}

export function Alert({ className, variant = 'default', children, ...props }: AlertProps) {
  const variants = {
    default: 'border-white/20 bg-white/[0.02] text-white/80',
    red: 'border-[#A32D2D] bg-[#A32D2D]/10 text-red-400',
    green: 'border-emerald-500/50 bg-emerald-500/10 text-emerald-400',
    amber: 'border-amber-500/50 bg-amber-500/10 text-amber-400',
    blue: 'border-blue-500/40 bg-blue-500/10 text-blue-400',
  };

  return (
    <div className={cn("p-4 text-[11px] font-mono border-l-2 bg-white/[0.02]", variants[variant], className)} {...props}>
      {children}
    </div>
  );
}
