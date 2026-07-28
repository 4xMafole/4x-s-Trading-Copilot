# LocoTrader — Metrics & KPIs

> North Star: Revenue / MRR (Monthly Recurring Revenue equivalent)
> Tracking framework for pre-launch, launch, and growth phases

---

## North Star Metric

**Revenue (total lifetime deal sales + any future monetization)**

Why: As a solo founder bootstrapping, revenue validates product-market fit and funds development. Everything else is a leading indicator.

---

## Metric Hierarchy

```
REVENUE (North Star)
├── Conversion Rate (waitlist → download → purchase)
│   ├── Waitlist signups
│   ├── Download-to-trial rate
│   └── Trial-to-purchase rate
├── User Acquisition
│   ├── Downloads (organic)
│   ├── Downloads (paid, if applicable)
│   └── Referral rate
└── Retention (drives word-of-mouth → more revenue)
    ├── Day 1 / Day 7 / Day 30 retention
    ├── Weekly Active Users (WAU)
    └── Feature adoption (gates used, trades logged)
```

---

## Pre-Launch Metrics (Months 1-3)

| Metric | Target | How to Track |
|--------|--------|-------------|
| Twitter followers | 500 by launch | Twitter Analytics |
| Waitlist signups | 200+ | Landing page form (Carrd/Supabase) |
| Email open rate | > 40% | Email tool (Resend, Mailchimp free tier) |
| Engagement rate (Twitter) | > 5% | Likes + replies + RTs / impressions |
| Discord/community interactions | 50+ conversations | Manual tracking |
| Beta tester signups | 20 | Direct outreach |
| Beta feedback NPS | > 8/10 | Survey (Google Forms) |

### Benchmarks (Finance/Trading App Category)
- Average Twitter engagement rate for finance: 1.5-3% (source: Sprout Social 2024)
- Email open rate for tech/finance: 20-25% average (source: Mailchimp benchmarks)
- Your target of 5%+ engagement and 40%+ open rate = high-engagement niche audience

---

## Launch Metrics (Month 4-5)

| Metric | Target | Stretch | Benchmark |
|--------|--------|---------|-----------|
| Day 1 downloads | 50 | 200 | Top 1% indie apps get 100+ Day 1 |
| Week 1 downloads | 150 | 500 | — |
| Month 1 downloads | 300 | 1,000 | — |
| Lifetime deals sold | 30 ($1,470) | 100 ($4,900) | — |
| App Store rating | 4.5+ | 4.8+ | Finance app average: 4.2 |
| Day 1 retention | 60% | 75% | Industry avg: 25% (finance apps better: 35-40%) |
| Day 7 retention | 35% | 50% | Industry avg: 12% (finance apps: 20-25%) |
| Day 30 retention | 20% | 35% | Industry avg: 6% (finance apps: 10-15%) |

### Retention Benchmarks (Mobile Finance Apps)
| Timeframe | Industry Average | Top Quartile | LocoTrader Target |
|-----------|-----------------|-------------|-------------------|
| Day 1 | 35-40% | 55-65% | 60% |
| Day 7 | 20-25% | 35-45% | 35% |
| Day 30 | 10-15% | 25-35% | 20% |
| Day 90 | 5-8% | 15-20% | 15% |

*Source: Adjust Mobile App Benchmarks Report (2024), AppsFlyer State of App Marketing (2024)*

**Why LocoTrader should beat benchmarks:**
- Daily use case (traders check before EVERY trade)
- Gate system creates habit loop (trigger: want to trade → behavior: check gates → reward: allowed to trade)
- Lock system ensures users return (check countdown)

---

## Growth Metrics (Months 5-12)

| Metric | Month 6 Target | Month 12 Target |
|--------|---------------|----------------|
| Monthly Active Users (MAU) | 500 | 2,000 |
| Weekly Active Users (WAU) | 250 | 1,000 |
| Daily Active Users (DAU) | 80 | 350 |
| DAU/MAU ratio | 16% | 17.5% |
| Total revenue | $3,000 | $10,000 |
| Organic install rate | 70%+ of downloads | 60%+ |
| Referral rate | 5% of users refer 1+ | 10% |
| App store reviews | 50+ | 200+ |
| Average session length | 3-5 min | 3-5 min |
| Sessions per user/day | 2-3 | 2-4 |

### DAU/MAU Benchmark
- Social apps: 50%+ (daily use expected)
- Finance apps: 15-25% (check-in pattern)
- Trading apps: 20-30% (daily when markets open)
- **LocoTrader target: 17.5%** (conservative — only open market days = ~22/30 days)

---

## Product-Specific Metrics

### Gate System Health
| Metric | What It Tells You | Target |
|--------|-------------------|--------|
| Gates triggered / day / user | Is the system working? | 1-3 |
| Gate pass rate | Are gates too strict/easy? | 60-80% pass |
| Override attempts | Do users try to bypass? | Track (no override exists, but track frustration) |
| Trades blocked by auto-gates | System preventing bad trades | 1-2 per user/week |

### Edge Map Engagement
| Metric | Target |
|--------|--------|
| Users reaching 30-trade threshold | 40% of active users by Day 30 |
| Edge Map views / week | 2+ per active user |
| Users who modify behavior after Edge Map insight | Track via dead zone avoidance |

### Drawdown Engine
| Metric | Target |
|--------|--------|
| Users setting up prop firm profiles | 50% of active users |
| Auto-locks triggered | Track frequency |
| Users who "survived" a drawdown event (didn't bust) | Key testimonial metric |

### AI Coach
| Metric | Target |
|--------|--------|
| Post-trade debrief completion rate | 60% of trades |
| Weekly digest open/read rate | 70% of active users |
| AI interaction satisfaction (thumbs up/down) | 80%+ positive |

---

## Revenue Metrics

### Lifetime Deal Phase (Launch - Month 3)
| Metric | Formula | Target |
|--------|---------|--------|
| Total lifetime deals sold | Count | 100-200 |
| Revenue from deals | Deals × $49 | $4,900-$9,800 |
| Conversion rate (download → purchase) | Purchases / Downloads | 10-15% |
| Revenue per download | Total revenue / Total downloads | $5-15 |

### Post-Lifetime Phase (Month 4+) — Future Monetization
| Metric | Target |
|--------|--------|
| Premium feature adoption | 5-10% of free users |
| ARPU (Average Revenue Per User) | $2-5/month equivalent |
| LTV (Lifetime Value) | $50-150 |
| CAC (Customer Acquisition Cost) | < $5 (mostly organic) |
| LTV:CAC ratio | > 10:1 |

---

## Tracking Stack (Free Tools)

| What to Track | Tool | Cost |
|---------------|------|------|
| App analytics (retention, sessions, events) | Firebase Analytics | Free |
| Crash reporting | Firebase Crashlytics | Free |
| Revenue tracking | App Store Connect / Google Play Console | Free |
| Social media metrics | Native analytics (Twitter, IG) | Free |
| Waitlist/email | Resend or Mailchimp free tier | Free |
| User feedback | In-app survey + Google Forms | Free |
| A/B testing (store listing) | Google Play Experiments | Free |
| Funnel visualization | Firebase + custom Supabase queries | Free |

---

## Weekly Review Template

Every Sunday, review these numbers:

```markdown
## Week of [DATE]

### Acquisition
- New downloads this week: ___
- Waitlist signups: ___
- Twitter followers gained: ___
- Source breakdown: Organic ___% | Referral ___% | Paid ___%

### Activation  
- First trade logged (% of downloads): ___%
- Gate system used at least once: ___%
- Completed onboarding: ___%

### Retention
- WAU: ___
- DAU (avg): ___
- Day 7 retention (this cohort): ___%

### Revenue
- Lifetime deals sold this week: ___
- Total revenue to date: $___
- Conversion rate: ___%

### Product
- Gates triggered: ___
- Trades blocked: ___
- Edge Maps generated (30+ trade threshold): ___
- Auto-locks triggered: ___
- AI coach interactions: ___

### Top Priority Next Week:
1. ___
2. ___
```

---

## Investor-Ready Metrics (What to Track for Pitch)

When you go to investors, they'll want:

| Metric | Why Investors Care |
|--------|-------------------|
| MoM growth rate | Trajectory > absolute numbers at pre-seed |
| Retention curves | Product-market fit signal |
| Revenue per user | Monetization potential |
| Organic % of acquisition | Scalability without paid spend |
| NPS score | Word-of-mouth potential |
| Feature adoption rates | Product depth / stickiness |

**Pre-seed investors accept small numbers IF the trajectory is strong.**
- 20% MoM growth = good
- 30%+ MoM growth = exceptional
- Flat or declining = red flag

---

*Retention benchmarks sourced from Adjust Global App Trends Report (2024) and AppsFlyer State of App Marketing. Finance/trading category specifically has higher-than-average retention due to daily utility. Revenue benchmarks are based on comparable indie app launches in the trading tools niche.*
