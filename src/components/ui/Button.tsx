import React from 'react';
import { cn } from '@/lib/utils';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'destructive' | 'outline' | 'ghost';
}

export function Button({ className, variant = 'default', ...props }: ButtonProps) {
  const variants = {
    default: 'bg-[#e0e0e0] text-[#0a0a0a] shadow-xl hover:bg-white',
    destructive: 'border border-red-500/50 text-red-500 bg-red-500/5 hover:bg-red-500/20',
    outline: 'border border-white/20 bg-transparent text-white/90 hover:bg-white hover:text-black',
    ghost: 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white',
  };

  return (
    <button
      className={cn(
        "px-4 md:px-6 py-2 md:py-3 text-[10px] font-bold uppercase tracking-[0.2em] transition-all focus:outline-none focus:ring-0 disabled:opacity-50 disabled:cursor-not-allowed",
        variants[variant],
        className
      )}
      {...props}
    />
  );
}
