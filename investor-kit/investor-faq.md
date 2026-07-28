# LocoTrader — Investor FAQ

> Common questions pre-seed investors will ask, with data-backed answers

---

## Market & Opportunity

### Q: How big is the market really? Trading tools seems niche.

**A**: The online trading platform market is $12.57B in 2026, growing to $18.18B by 2031 (7.66% CAGR) according to Mordor Intelligence. Retail investors represent 69.59% of all trades and are growing at 8.43% CAGR.

The trading tools/journals sub-segment is estimated at $300M-$1.2B annually (5-10M active retail tool users × $5-10/month average tool spend). This is a large enough market for a venture-scale outcome while being specific enough to dominate a niche.

Additionally, prop trading firms are estimated to have 2-3M active challenge participants globally (FTMO alone has 500K+ registered users).

*Source: Mordor Intelligence Online Trading Platform Market Report (2026)*

---

### Q: Why do you think 73% of traders lose because of discipline, not strategy?

**A**: This isn't our claim — it's a regulatory disclosure. Under ESMA's MiFID II regulations, EU-regulated brokers are required to publicly disclose the percentage of retail clients losing money. The average across major brokers (IG, Plus500, CMC Markets, OANDA, Saxo) consistently shows 70-76%.

Academic research (Barber & Odean, "Trading is Hazardous to Your Wealth," 2000; and multiple follow-up studies) consistently finds that overtrading, disposition effect (cutting winners/holding losers), and behavioral biases — not poor market timing or technical analysis — drive losses.

Our own 572-trade dataset confirms this: a mathematically profitable strategy (32.4% WR × 2.71 R:R = positive expectancy) was unprofitable in execution due to behavioral errors (stacking, dead zone trading, FOMO entries).

---

### Q: What if prop firms build their own discipline tools?

**A**: Prop firms optimize for challenge SALES, not challenge PASSES. A higher failure rate means more repeat purchases ($300-$600 per challenge). Their incentive is misaligned with building tools that help traders pass.

However, if prop firms DO want to offer this, we become a partnership/white-label opportunity rather than a competitor. Our B2B roadmap includes prop firm licensing.

---

## Product & Technology

### Q: Why can't TradeZella or TraderSync just add a "gate" feature?

**A**: Three structural barriers:

1. **Architecture**: Their entire UX flow assumes post-trade data entry. Gates require pre-trade flow — a fundamentally different user journey. It's not a feature bolt-on; it requires redesigning the core product.

2. **Business model conflict**: These companies profit from engagement (more trades logged = better retention metrics = higher perceived value). Blocking trades reduces engagement — directly conflicts with their business model.

3. **Brand positioning**: They've spent years positioning as "analytics tools." Repositioning as "discipline enforcement" would confuse existing users, require new marketing, and dilute their current value proposition.

This isn't a 6-month copy threat — it's a structural moat.

---

### Q: What's your tech stack? Can you ship fast?

**A**: 
- **Mobile**: Flutter (single codebase → iOS + Android simultaneously)
- **Web**: React + Vite + TypeScript
- **Backend**: Supabase (auth, PostgreSQL, Edge Functions)
- **AI**: Google Gemini (free tier: 15 req/min, sufficient for early scale)
- **OCR**: Google ML Kit (on-device, free, no API key needed)
- **Storage**: Hive (encrypted local storage on device)
- **Security**: AES-256 encryption, biometric lock

I built the entire product solo. No contractor dependencies. I can ship features in days, not weeks. The full product is already built and functional.

---

### Q: What happens if Google increases Gemini pricing?

**A**: Multiple mitigations:
1. The app runs in **local-only mode** by default (rule-based, no AI needed for core enforcement)
2. AI coach is additive, not essential — gates, locks, and calculators work without AI
3. Gemini free tier (15 req/min) handles significant scale before paid tier is needed
4. At scale, AI costs are ~$0.001-0.01 per interaction — margin impact < 2%
5. If pricing changes dramatically, we can switch to other providers (Claude, Mistral, local models)

---

### Q: How do you handle data privacy? Traders won't want their data exposed.

**A**: Privacy is a core feature:
- **Local-first**: All data stored on-device by default (Hive encrypted storage)
- **No broker connection**: We never access trading accounts or execute trades
- **No cloud required**: Core features work without internet
- **AES-256 backups**: User-controlled, exported to their own storage
- **Biometric lock**: Fingerprint/Face ID on app open
- **No data selling**: Business model is subscriptions, not data monetization
- **GDPR-aligned**: User can delete all data at any time

---

## Business Model & Revenue

### Q: One-time $49 deal → how do you make recurring revenue?

**A**: The lifetime deal is a launch mechanic, not the long-term business model.

**Phase 1** (Launch): 100-200 lifetime deals = $4,900-$9,800 immediate cash to fund launch marketing and infrastructure. Creates urgency and initial user base.

**Phase 2** (Growth): Freemium + subscription. Free tier includes basic gates and calculator. Paid tier ($9.99-$19.99/mo) unlocks Edge Map, AI coach, unlimited accounts, PDF exports. Lifetime deal users keep everything forever (cost of ~200 users is negligible at scale).

**Phase 3** (Scale): B2B partnerships, white-labeling, premium community features.

The $49 × 200 spots = $9,800 is essentially a pre-sale that funds MVP marketing while building a base of power users who generate word-of-mouth.

---

### Q: Isn't free pricing a problem? How do you monetize free users?

**A**: Free is a distribution strategy, not a pricing failure.

The free tier is deliberately limited (3 gates, 50 trades/month, 1 account, no Edge Map). It's useful enough to create habit formation (traders use gates daily) but limited enough that serious traders upgrade.

Benchmarks: Finance apps see 2-5% free-to-paid conversion (RevenueCat, 2024). Our unique enforcement features (Edge Map, AI coach, unlimited accounts) should push this to 5-10% because:
- The free tier creates daily dependency (gate habit)
- After 30 trades, the Edge Map "unlock" is extremely compelling (personalized insights)
- Prop firm traders managing multiple accounts NEED the paid tier

Even at 5% conversion, 10,000 free users = 500 paid × $9.99/mo = $5K MRR.

---

### Q: What's your path to $1M ARR?

**A**: 

$1M ARR = $83,333 MRR = ~8,334 paid subscribers at $9.99/mo (or mix of $9.99 and $19.99 plans)

At 7% conversion rate, this requires ~119,000 MAU.

**Timeline estimate**: Year 3 (optimistic) to Year 4 (base case).

**Path**: Organic growth + referral loops + eventual paid acquisition once unit economics are proven. The trading community is tight-knit — one viral "gate blocked my revenge trade" share can drive hundreds of downloads.

---

### Q: $50-150K is a small raise. Why not raise more?

**A**: Three reasons:

1. **Low burn**: Based in Dar es Salaam, my monthly burn is $1,500-2,000. $100K = 50-66 months of runway (more than enough to prove PMF).

2. **Less dilution**: At pre-seed with no traction, raising $1M means giving up significant equity at a low valuation. Better to prove metrics on $100K, then raise seed at a much higher valuation.

3. **Discipline**: The product is about discipline. The company should mirror that. Raise what you need, prove the model, scale when ready.

---

## Founder & Team

### Q: You're a solo founder. Isn't that risky?

**A**: It's a valid concern. Here's why it's manageable:

1. **Product is already built**: The single biggest solo-founder risk (can't ship) is eliminated. Full app exists.
2. **Full-stack capability**: I handle mobile, web, backend, AI, DevOps, and marketing. No blocking dependencies.
3. **First hire plan**: With funding, priority hire is a marketing/community person (I'm weakest at sustained content creation). Tech I can handle solo through seed.
4. **Low complexity**: The product is well-scoped. This isn't a marketplace requiring both supply and demand — it's a single-user tool.
5. **Long-term**: Plan to hire 2-3 engineers for seed round (Year 2). Pre-seed is execution-focused, and I can execute alone.

---

### Q: Why should you specifically build this? What's your unfair advantage?

**A**:

1. **I AM the target user**: I trade forex/indices with real money. I experienced the exact problem. I built the solution for myself first.
2. **572 trades of proof**: Not hypothetical — I validated the thesis with my own capital and data.
3. **Technical capability**: Built the entire product solo — mobile + web + backend + AI. Ship speed is unmatched.
4. **Geographic advantage**: Dar es Salaam = low burn + authentic access to Africa's exploding retail trading market.
5. **Domain + technical**: Rare combination of active trader + full-stack developer. Most trading tools are built by developers who don't trade, or traders who can't code.

---

### Q: What does the team look like in 18 months?

**A**:

| Role | When | Why |
|------|------|-----|
| Community/Marketing lead | Month 3-6 (with funding) | Content, social media, influencer outreach (my weakest skill) |
| Mobile engineer | Month 9-12 | Scale feature development, handle app store specifics |
| Backend engineer | Month 12-18 | As user base grows, need dedicated infrastructure |
| Designer | Contract/part-time | Polish UI, create marketing assets |

Total team by seed round: 3-4 full-time + 1-2 contractors.

---

## Growth & Competition

### Q: How do you acquire users with no marketing budget?

**A**: Five channels, all organic:

1. **Twitter/X trading community** (35% of downloads): Data-driven threads from my 572-trade dataset. Trading Twitter is extremely engaged and content-hungry.
2. **Trading Discord servers** (20%): Active participation in 5+ servers, providing genuine value through risk management advice.
3. **Reddit** (15%): r/Forex (900K+), r/Daytrading (1.1M+), r/PropFirm — data posts that provide value first.
4. **Word-of-mouth / referral** (15%): "Gate Blocked" shareable moments — when the app blocks a trade, users can one-tap share to Twitter.
5. **WhatsApp/Telegram groups** (10%): Africa-specific trader groups, leveraging local founder credibility.

Post-product-market-fit (with funding): add $300-500/month in targeted ads to accelerate.

---

### Q: What happens if this doesn't work? What's your plan B?

**A**: Honest answer — there are multiple pivot paths within the same thesis:

1. **B2B pivot**: If individual acquisition is too expensive, pivot to white-labeling for prop firms (they send traffic, we provide the tool).
2. **Education platform integration**: Become the "execution layer" that trading courses bundle with their curriculum.
3. **Broker partnership**: Offer as a free add-on to brokers (reduces their client churn → they pay us per-user).
4. **Data play**: Anonymized behavioral data about retail trader psychology → sell to prop firms, brokers, or researchers.

The underlying IP (enforcement system, Edge Map AI, behavioral tracking) has multiple monetization paths beyond direct-to-consumer.

---

### Q: What about regulatory risk?

**A**: LocoTrader has minimal regulatory exposure because:

1. **We don't execute trades**: No broker license needed. We never touch user funds.
2. **We don't give trading signals**: No "buy EURUSD" recommendations. We enforce the user's OWN rules.
3. **We don't manage money**: Not an investment advisor or asset manager.
4. **No financial data access**: We don't connect to brokers or access account balances.
5. **Classification**: We're a productivity/self-improvement tool that happens to be used by traders — similar to a habit tracker or workout app.

The only regulatory surface is standard app store compliance (privacy policy, data handling) and basic consumer protection laws — which we already address.

---

## Valuation & Terms

### Q: What valuation are you looking for?

**A**: We're raising on a SAFE (Simple Agreement for Future Equity) with:
- **Valuation cap**: $1.5M–$3M (negotiable based on check size)
- **Discount**: 20% (standard)

Rationale for cap:
- Product fully built (not typical for pre-seed)
- Clear market with identified gap
- Solo founder with low burn = capital-efficient
- Comparable pre-seed caps in fintech/trading tools: $2-5M

---

### Q: What's the expected exit path?

**A**: Multiple paths exist:

1. **Acquisition by trading platform** (most likely, Year 3-5): Companies like TradeZella, TraderSync, or larger platforms (TradingView, broker-owned tools) acquire for the enforcement technology + user base.
2. **Acquisition by prop firm** (Year 3-5): Prop firm integrates discipline tools to reduce challenge failure rates (and support costs).
3. **Profitable standalone business** (ongoing): At $1M+ ARR with 85% margins, the business is highly profitable as a lifestyle/SMB outcome.
4. **Series A → B growth path** (Year 4-6): If unit economics support it, scale to 500K+ users and pursue larger fundraise.

Comparable reference: Zerodha raised at $3.5B valuation (Oct 2025, Temasek) — while they're a broker not a tool, it demonstrates the magnitude of outcomes in trading tech.

---

### Q: Why invest now? What's the urgency?

**A**:

1. **Category creation window**: No one owns "pre-trade enforcement" yet. First mover wins this positioning.
2. **AI cost window**: Gemini free tier makes AI-powered features possible at $0 marginal cost. This window may not last.
3. **Product complete**: You're not betting on "can he build it" — it's built. You're betting on "can he distribute it."
4. **Low-cost bet**: $50-100K in a pre-seed with fully built product + low burn = extended runway + multiple shots on goal.
5. **Pre-traction valuation**: Investing now means lower valuation. After 1,000 MAU and growing MRR, the cap will be 3-5x higher.

---

*All market data sourced from Mordor Intelligence (2026), ESMA MiFID II disclosures, competitor public pricing pages, and RevenueCat State of Subscription Apps (2024). Financial assumptions are estimates and actual results may vary.*
