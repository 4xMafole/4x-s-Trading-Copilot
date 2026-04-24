import React from 'react';
import { cn } from '@/lib/utils';

interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: 'default' | 'green' | 'red' | 'amber' | 'blue' | 'gray';
}

export function Badge({ className, variant = 'default', children, ...props }: BadgeProps) {
  const variants = {
    default: 'border-white/20 bg-white/5 text-white/80',
    green: 'border-emerald-500/30 bg-emerald-500/10 text-emerald-400',
    red: 'border-red-500/30 bg-red-500/10 text-red-500',
    amber: 'border-amber-500/30 bg-amber-500/10 text-amber-500',
    blue: 'border-blue-500/30 bg-blue-500/10 text-blue-400',
    gray: 'border-white/10 bg-white/5 text-white/50',
  };

  return (
    <span className={cn("text-[9px] font-mono tracking-[0.2em] uppercase px-2.5 py-1 border rounded-sm whitespace-nowrap", variants[variant], className)} {...props}>
      {children}
    </span>
  );
}
