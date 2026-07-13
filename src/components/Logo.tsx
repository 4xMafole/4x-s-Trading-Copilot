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
      {/* Two intersecting angular planes — creates depth + negative space
          Inspired by Linear/Stripe's geometric simplicity.
          The two overlapping rhomboids suggest: precision, edge, forward momentum */}

      {/* Back plane — deeper blue, offset bottom-left */}
      <path
        d="M10 44 L28 12 L38 12 L20 44Z"
        fill="#3B82F6"
        opacity="0.35"
      />

      {/* Front plane — full blue, offset top-right */}
      <path
        d="M26 52 L44 20 L54 20 L36 52Z"
        fill="#3B82F6"
      />

      {/* Intersection highlight — subtle lighter accent where planes overlap */}
      <path
        d="M26 44 L28 12 L38 12 L36 44Z"
        fill="#60A5FA"
        opacity="0.25"
      />
    </svg>
  );
}
