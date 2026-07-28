# LocoTrader — Pitch Deck Script

> 10-minute pitch deck narrative (12-14 slides)
> For in-person meetings, video calls, and recorded pitches

---

## Slide 1: Title

**Visual**: LocoTrader logo + tagline on dark background
**Text on slide**:
```
LocoTrader
Trade Your Rules. Not Your Feelings.

Pre-Seed | $50K–$150K
Erick Mafole | Founder
```

**Script** (15 seconds):
> "I'm Erick Mafole. I'm a trader and full-stack developer from Dar es Salaam, Tanzania. I built LocoTrader — the first mobile app that physically blocks traders from entering bad trades. Let me show you why this matters."

---

## Slide 2: The Problem

**Visual**: Large "73%" stat + quote from a trader
**Text on slide**:
```
73% of retail traders lose money.

Not from bad strategy.
From bad execution.

— ESMA MiFID II Broker Disclosures (EU regulatory requirement)
```

**Script** (45 seconds):
> "Under EU regulations, every broker must disclose the percentage of retail clients losing money. The number averages 73% across major brokers."
>
> "But here's what most people miss: these traders aren't using bad strategies. They know what support and resistance is. They know about risk management."
>
> "They lose because of execution: revenge trading after a loss, entering during personal dead zones, ignoring their own lot sizing rules, and trading on emotion instead of their plan."
>
> "In other words — the problem isn't knowledge. It's behavior."

---

## Slide 3: Why Journals Don't Work

**Visual**: Split screen — Journal (reactive) vs. Enforcement (proactive)
**Text on slide**:
```
Every tool on the market is REACTIVE.

Trading Journals tell you what went wrong — AFTER you lost money.

• TradeZella ($99/mo) — records trades
• TraderSync ($60/mo) — analyzes patterns  
• Edgewonk ($12/mo) — reviews psychology

NONE of them prevent the next bad trade.
```

**Script** (30 seconds):
> "The market's answer to this is trading journals. TradeZella charges up to $99 a month. TraderSync charges up to $60. They all do the same thing: let you record a trade, then tell you what went wrong."
>
> "That's like installing a dashcam to prevent car crashes. It records the crash — it doesn't prevent it."
>
> "No product on the market today stops the bad trade BEFORE it happens."

---

## Slide 4: The Solution

**Visual**: Gate system screenshot showing blocked trade
**Text on slide**:
```
LocoTrader: Pre-Trade Enforcement

Before you can enter ANY trade, gates verify:
✓ Session window (are you in your hours?)
✓ Daily trade cap (haven't exceeded?)
✓ Loss lockout (not on cooldown?)
✓ Proof requirement (can you justify this entry?)

Gate fails → Trade BLOCKED. No override.
```

**Script** (45 seconds):
> "LocoTrader is fundamentally different. It's a pre-trade enforcement system."
>
> "Before a trader can enter any trade, they must pass through 'gates.' These gates check: Are you trading in your designated session window? Have you exceeded your daily trade cap? Are you locked out from consecutive losses? Can you provide proof — a chart screenshot or written justification — for why this trade meets your criteria?"
>
> "If any single gate fails, the trade is blocked. There is no override button. No 'I'll do it anyway.' The system says no."
>
> "This is the difference between a journal that records your failures and a system that prevents them."

---

## Slide 5: How It Works (Product Demo)

**Visual**: 3-panel product screenshots (Gate → Edge Map → Auto-Lock)
**Text on slide**:
```
1. GATES → Block bad entries
2. EDGE MAP → AI learns YOUR patterns (after 30 trades)
3. AUTO-LOCK → 3 losses = 24hr cooldown (no override)
```

**Script** (60 seconds):
> "Three core features make this work:"
>
> "First — the Gate System. Every trade must pass pre-set rules. This isn't a checklist you can ignore. It's enforcement."
>
> "Second — the Personal Edge Map. After 30 trades, our AI — powered by Google's Gemini, free tier — analyzes YOUR specific patterns. It finds your dead zones, your profitable time windows, which symbols make you money versus which ones bleed you, and behavioral patterns like stacking that destroy your edge."
>
> "Third — Auto-Lock. Three consecutive losing trades trigger a 24-hour account lockout. No override exists. This prevents revenge trading and tilt-driven decisions."
>
> "Together, these create a system where discipline isn't optional — it's enforced."

---

## Slide 6: Proof (My Own Data)

**Visual**: Data visualization from 572-trade dataset
**Text on slide**:
```
572 trades. 18 months. My own money.

Before LocoTrader:
• Stacking: 8.3% win rate (vs. 50% single entry)
• Dead zone 09:00-10:30: 23 consecutive losses
• EURUSD: 25% WR overall → 54.5% on sells only

After building enforcement:
• Eliminated dead zone trading
• Stopped stacking
• Profitable.
```

**Script** (45 seconds):
> "I didn't build this from theory. I built it from 18 months of losing my own money."
>
> "572 documented trades. My win rate was 32% with a 2.7 reward-to-risk ratio — mathematically profitable. But I was losing."
>
> "The data showed why: I was stacking entries at an 8% win rate instead of my usual 50%. I had 23 consecutive losses between 9 and 10:30 AM. I was trading EUR/USD in both directions when my edge was sells only."
>
> "Once I built the system to enforce these rules — gates, locks, restrictions — I stopped bleeding money. That system is now LocoTrader."

---

## Slide 7: Market Opportunity

**Visual**: Market size chart with TAM/SAM/SOM
**Text on slide**:
```
Market Size (Mordor Intelligence, 2026):

TAM: $12.57B (online trading platforms, 2026)
     → $18.18B by 2031 (7.66% CAGR)

SAM: $300M–$1.2B (trading tools/journals segment)
     → 5-10M active retail traders × $5-10/mo tool spend

SOM (Year 1): $10K–$25K
     → 2,000 users × 5-10% paid conversion

Key growth drivers:
• Retail investors = 69.59% of trades (8.43% CAGR)
• Mobile orders = 62% and rising
• "On-device ML behavioral nudges" = identified market driver
```

**Script** (30 seconds):
> "The online trading platform market is $12.57 billion in 2026, growing at nearly 8% annually to over $18 billion by 2031. Retail investors represent 70% of all trades and growing at 8.4% CAGR."
>
> "The trading tools and journals segment alone is a $300 million to $1.2 billion annual market. Mordor Intelligence specifically identifies 'on-device ML behavioral nudges' as a named growth driver — which is exactly what we're building."
>
> "Our Year 1 target is modest: 2,000 users, $10-25K revenue. Prove the model works, then scale."

---

## Slide 8: Business Model

**Visual**: Revenue model timeline
**Text on slide**:
```
Phase 1 (Launch): One-time lifetime deal — $49
• 100-200 spots → $4,900-$9,800 immediate revenue
• Funds development, builds user base

Phase 2 (Growth): Freemium + Subscription
• Free: Gates (3), basic calculator, 50 trades/month
• Pro ($9.99/mo): Edge Map, unlimited gates, AI coach
• Trader+ ($19.99/mo): Unlimited accounts, PDF exports, advanced features

Unit Economics Target:
• CAC: < $5 (organic-first)
• LTV: $80-160
• LTV:CAC: > 16:1
```

**Script** (30 seconds):
> "We launch with a one-time $49 lifetime deal — limited spots — to fund initial development and create urgency. After those sell out, we move to freemium with a $9.99 and $19.99 monthly subscription."
>
> "Because our acquisition is primarily organic — trading communities, social media, word-of-mouth — our CAC target is under $5. At an 8-month average retention, that gives us a lifetime value of $80-160 and a LTV-to-CAC ratio above 16:1."

---

## Slide 9: Competitive Landscape

**Visual**: 2x2 positioning matrix (Reactive/Proactive × Expensive/Free)
**Text on slide**:
```
                REACTIVE ←————→ PROACTIVE
                    |
   Edgewonk ●      |
   TraderSync ●    |          ● LocoTrader
   TradeZella ●    |            (ONLY PLAYER HERE)
                    |
   EXPENSIVE ———————+————————— FREE
                    |
   Notion ●        |
   Excel ●         |

No competitor occupies the top-right quadrant.
We own "proactive + affordable."
```

**Script** (30 seconds):
> "Every competitor sits in the left half of this matrix — they're reactive. They tell you what went wrong. Some are expensive — TradeZella at $99 a month. Some are cheaper."
>
> "LocoTrader is the only product in the top-right: proactive enforcement at zero cost. No one else occupies this position because retrofitting enforcement into a journal-first architecture requires rebuilding the entire product. It's not a feature they can bolt on."

---

## Slide 10: Why We Can't Be Easily Copied

**Visual**: Moat diagram
**Text on slide**:
```
Defensibility:

1. Architectural: Enforcement = different UX flow than journaling
   (Can't bolt "gates" onto a journal — requires redesign)

2. Business model conflict: Competitors profit from MORE trades logged
   (Blocking trades = less engagement for them)

3. Data moat: Personal Edge Maps trained on individual user data
   (More trades logged → better AI → stickier product)

4. Brand: First-mover in "trading enforcement" category
   (Category creation > feature competition)

5. Community: Africa-first, trader-built authenticity
   (Hard to fake with a VC-backed US team)
```

**Script** (30 seconds):
> "Our moat is structural, not just feature-based. Competitors can't easily copy this because their entire architecture assumes post-trade data entry. Adding gates requires rebuilding their core flow."
>
> "Moreover, there's a business model conflict: TradeZella profits when users log more trades. Blocking trades reduces their engagement metrics."
>
> "And as more users log trades, our Edge Maps get smarter per-user — creating a personal data moat that increases switching costs over time."

---

## Slide 11: Traction & Roadmap

**Visual**: Timeline with milestones
**Text on slide**:
```
DONE:
✅ Full product built (Flutter + React + Supabase + Gemini AI)
✅ 572-trade dataset validating thesis
✅ Gate system, Edge Map, Drawdown Engine, AI Coach — functional
✅ Pitch deck + investor materials

NEXT 6 MONTHS (with funding):
🎯 Month 1-2: App store submission + beta program (20 users)
🎯 Month 2-3: Public launch + lifetime deals (100+ sales)
🎯 Month 3-6: 1,000 downloads, 30% D30 retention
🎯 Month 6-9: Subscription tier launch, $2K MRR
🎯 Month 9-12: 2,000 MAU, $5K MRR, seed-ready metrics
```

**Script** (30 seconds):
> "The product is fully built. Not a prototype — a complete app with every feature I described functional and working. That's unusual at pre-seed."
>
> "What I need funding for is launch execution: app store submission, user acquisition, infrastructure costs, and 12 months of runway to prove product-market fit."
>
> "The target: 2,000 monthly active users and $5K MRR within 12 months — which positions us for a seed round."

---

## Slide 12: The Ask

**Visual**: Clean, simple — amount + use of funds
**Text on slide**:
```
Raising: $50K–$150K (Pre-Seed)

Use of Funds:
• 40% — Product (iOS/Android polish, integrations)
• 25% — Marketing (content, community, micro-influencers)
• 15% — Infrastructure (Supabase, AI, cloud — 12 months)
• 15% — Founder salary (12 months, Dar es Salaam COL)
• 5%  — Legal & compliance

Terms: SAFE note (negotiable)
Target: 12-month runway to seed-ready metrics
```

**Script** (30 seconds):
> "I'm raising $50,000 to $150,000 on a SAFE note. The majority goes to product polish and marketing execution."
>
> "My burn rate is low — I'm based in Dar es Salaam where cost of living is a fraction of the US. This means your capital goes 3-5x further than backing a Bay Area founder."
>
> "The goal is simple: 12 months to seed-ready metrics. If I hit 2,000 MAU with strong retention and growing MRR, we raise a proper seed round to scale."

---

## Slide 13: Why Me

**Visual**: Founder photo + key credentials
**Text on slide**:
```
Erick Mafole — Founder

• Full-stack developer (Flutter, React, Node.js, Supabase)
• Active trader (572+ documented trades)
• Built the entire product solo — $0 spent
• Based in Dar es Salaam, Tanzania (low burn, high leverage)
• Domain expertise: I AM the target user

"I built this because I needed it.
I launched it because everyone else needs it too."
```

**Script** (30 seconds):
> "I'm a full-stack developer who also trades actively. I built the entire product — mobile app, web dashboard, backend, AI integration — solo, with zero external capital."
>
> "This matters because I'm not building for a hypothetical user. I AM the user. I felt the pain. I validated the solution on my own money. And I can ship fast because I own the entire stack."
>
> "My location in Dar es Salaam means my personal burn is under $1,500/month. Your money goes to product and growth, not Bay Area rent."

---

## Slide 14: Closing

**Visual**: App screenshots + contact info
**Text on slide**:
```
LocoTrader
The app that blocks bad trades before they happen.

$12.57B market. Zero competitors in our quadrant.
Product built. Launch ready.

Let's talk.

Erick Mafole
[email] | [Twitter/X] | [LinkedIn]
```

**Script** (15 seconds):
> "LocoTrader: a $12 billion market, zero competitors doing what we do, product already built, and a launch plan ready to execute. I'm looking for investors who understand that the biggest problem in retail trading isn't strategy — it's discipline. And discipline can now be enforced by software."
>
> "Thank you. I'd love to answer any questions."

---

## Appendix Slides (If Questions Arise)

### A1: Technical Architecture
```
• Flutter (iOS + Android) — single codebase
• React + Vite (web dashboard)
• Supabase (auth, Edge Functions, database)
• Google Gemini AI (free tier: 15 req/min)
• Google ML Kit (on-device OCR — free)
• Hive (encrypted local storage)
• AES-256 encryption for backups
```

### A2: Revenue Scenarios
```
Conservative: 1,000 users, 5% paid → $500 MRR → $6K ARR
Base: 3,000 users, 7% paid → $2,100 MRR → $25K ARR  
Optimistic: 7,000 users, 10% paid → $7,000 MRR → $84K ARR
```

### A3: Comparable Exits / Valuations
```
• Edgewonk: Private, est. $5-10M valuation (profitable, 10+ years)
• TradeZella: Raised $X (venture-backed, 100K+ users)
• TraderSync: Private, profitable, est. $10-20M
• Zerodha: $3.5B valuation (Oct 2025, Temasek investment)
• Comparable pre-seed: $2-5M post-money valuation typical
```

---

## Pitch Delivery Notes

1. **Total time**: 8-10 minutes (leave 5 min for Q&A)
2. **Energy**: Confident but not hype-y. Data-driven. Match the "no-BS" brand voice.
3. **Demo**: If possible, live-demo the gate system blocking a trade (15 seconds)
4. **Key moment**: Slide 6 (your own data) — this is where credibility peaks. Linger here.
5. **Close strong**: "Zero competitors in our quadrant" — memorable positioning statement
6. **Follow up**: Send executive summary + one-pager within 2 hours of meeting
