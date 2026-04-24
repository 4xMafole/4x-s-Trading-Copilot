import React from 'react';
import { cn } from '@/lib/utils';

export function Input({ className, ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn(
        "w-full px-4 py-3 border border-white/10 bg-white/5 text-[11px] font-mono text-[#e0e0e0] placeholder:text-white/20 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all rounded-none",
        className
      )}
      {...props}
    />
  );
}

export function Select({ className, ...props }: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      className={cn(
        "w-full px-4 py-3 border border-white/10 bg-white/5 text-[11px] font-mono text-[#e0e0e0] focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all cursor-pointer rounded-none outline-none appearance-none",
        className
      )}
      {...props}
    />
  );
}

export function Textarea({ className, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={cn(
        "w-full px-4 py-3 border border-white/10 bg-white/5 text-[11px] font-mono text-[#e0e0e0] placeholder:text-white/20 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all min-h-[80px] resize-y rounded-none",
        className
      )}
      {...props}
    />
  );
}

export function Label({ className, children, ...props }: React.LabelHTMLAttributes<HTMLLabelElement>) {
  return (
    <label className={cn("block text-[10px] uppercase tracking-[0.3em] opacity-50 mb-3", className)} {...props}>
      {children}
    </label>
  );
}
