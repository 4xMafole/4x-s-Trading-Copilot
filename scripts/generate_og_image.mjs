import sharp from 'sharp';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outputPath = join(__dirname, '..', 'public', 'og-image.png');

// 1200x630 is the standard OG image size
const width = 1200;
const height = 630;

const svg = `
<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#090912"/>
      <stop offset="50%" style="stop-color:#0f0f1a"/>
      <stop offset="100%" style="stop-color:#090912"/>
    </linearGradient>
    <linearGradient id="accent" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#3B82F6"/>
      <stop offset="100%" style="stop-color:#60A5FA"/>
    </linearGradient>
    <linearGradient id="glow" x1="50%" y1="0%" x2="50%" y2="100%">
      <stop offset="0%" style="stop-color:#3B82F6;stop-opacity:0.15"/>
      <stop offset="100%" style="stop-color:#3B82F6;stop-opacity:0"/>
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="${width}" height="${height}" fill="url(#bg)"/>

  <!-- Subtle grid pattern -->
  <g opacity="0.04">
    ${Array.from({length: 20}, (_, i) => `<line x1="${i * 60}" y1="0" x2="${i * 60}" y2="${height}" stroke="white" stroke-width="1"/>`).join('')}
    ${Array.from({length: 11}, (_, i) => `<line x1="0" y1="${i * 60}" x2="${width}" y2="${i * 60}" stroke="white" stroke-width="1"/>`).join('')}
  </g>

  <!-- Top glow -->
  <ellipse cx="600" cy="0" rx="500" ry="300" fill="url(#glow)"/>

  <!-- Logo mark (scaled version of favicon) -->
  <g transform="translate(80, 220) scale(2.5)">
    <rect width="64" height="64" rx="14" fill="white" opacity="0.1"/>
    <path d="M10 44 L28 12 L38 12 L20 44Z" fill="#3B82F6" opacity="0.35"/>
    <path d="M26 52 L44 20 L54 20 L36 52Z" fill="#3B82F6"/>
    <path d="M26 44 L28 12 L38 12 L36 44Z" fill="#60A5FA" opacity="0.25"/>
  </g>

  <!-- Brand name -->
  <text x="270" y="290" font-family="Inter, -apple-system, sans-serif" font-size="52" font-weight="800" fill="white" letter-spacing="-1">LocoTrader</text>

  <!-- Tagline -->
  <text x="270" y="345" font-family="Inter, -apple-system, sans-serif" font-size="28" font-weight="500" fill="#94A3B8">Your Edge Isn't Broken.</text>
  <text x="270" y="385" font-family="Inter, -apple-system, sans-serif" font-size="28" font-weight="500" fill="#94A3B8">You're Missing a System.</text>

  <!-- Bottom accent bar -->
  <rect x="0" y="610" width="${width}" height="20" fill="url(#accent)"/>

  <!-- Feature pills -->
  <g transform="translate(270, 430)">
    <rect x="0" y="0" width="160" height="36" rx="18" fill="white" opacity="0.08"/>
    <text x="80" y="23" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="#60A5FA" text-anchor="middle">Pre-Trade Gates</text>

    <rect x="175" y="0" width="160" height="36" rx="18" fill="white" opacity="0.08"/>
    <text x="255" y="23" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="#60A5FA" text-anchor="middle">Trading Journal</text>

    <rect x="350" y="0" width="145" height="36" rx="18" fill="white" opacity="0.08"/>
    <text x="423" y="23" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="#60A5FA" text-anchor="middle">Edge Analytics</text>

    <rect x="510" y="0" width="175" height="36" rx="18" fill="white" opacity="0.08"/>
    <text x="598" y="23" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="#60A5FA" text-anchor="middle">Prop Firm Tracker</text>
  </g>

  <!-- URL -->
  <text x="270" y="540" font-family="Inter, sans-serif" font-size="18" font-weight="400" fill="#64748B">locotrader.app</text>

  <!-- Right side: stat callout -->
  <g transform="translate(850, 100)">
    <rect x="0" y="0" width="280" height="120" rx="16" fill="white" opacity="0.05" stroke="#3B82F6" stroke-opacity="0.2" stroke-width="1"/>
    <text x="140" y="45" font-family="Inter, sans-serif" font-size="16" font-weight="500" fill="#94A3B8" text-anchor="middle">Without a system</text>
    <text x="140" y="90" font-family="Inter, sans-serif" font-size="48" font-weight="800" fill="#EF4444" text-anchor="middle">73%</text>
    <text x="140" y="112" font-family="Inter, sans-serif" font-size="14" font-weight="400" fill="#64748B" text-anchor="middle">of traders lose money</text>
  </g>
</svg>
`;

await sharp(Buffer.from(svg))
  .png({ quality: 95, compressionLevel: 9 })
  .toFile(outputPath);

console.log(`✅ OG image generated: ${outputPath} (${width}x${height})`);
