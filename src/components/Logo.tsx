interface LogoProps {
  size?: number;
  variant?: 'full' | 'icon';
  className?: string;
}

export function Logo({ size = 32, variant = 'full', className = '' }: LogoProps) {
  return (
    <span className={`inline-flex items-center gap-2.5 ${className}`}>
      <LogoIcon size={size} />
      {variant === 'full' && (
        <span
          className="font-black tracking-tight text-white"
          style={{ fontSize: size * 0.65, lineHeight: 1 }}
        >
          Loco<span className="text-blue-400">Trader</span>
        </span>
      )}
    </span>
  );
}

export function LogoIcon({ size = 32 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-label="LocoTrader"
    >
      {/* Background */}
      <rect width="64" height="64" rx="14" fill="#090912" />

      {/* 3 ascending bars — sharp, no radius */}
      <rect x="10" y="42" width="11" height="12" fill="#3B82F6" opacity="0.3" />
      <rect x="26" y="30" width="11" height="24" fill="#3B82F6" opacity="0.65" />
      <rect x="42" y="16" width="11" height="38" fill="#3B82F6" />

      {/* Trend line connecting bar tops — 1.5px, square cap */}
      <line x1="15.5" y1="42" x2="31.5" y2="30" stroke="#3B82F6" strokeWidth="1.5" strokeLinecap="butt" />
      <line x1="31.5" y1="30" x2="47.5" y2="16" stroke="#3B82F6" strokeWidth="1.5" strokeLinecap="butt" />

      {/* Arrowhead at top — filled triangle, points north-east */}
      <polygon points="48,10 55,17 50,19" fill="#3B82F6" />

      {/* Faint baseline */}
      <rect x="10" y="55" width="44" height="1" fill="white" opacity="0.07" />
    </svg>
  );
}
