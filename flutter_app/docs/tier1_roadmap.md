# 🏆 Tier 1 Prop-Firm-Grade Roadmap

> **Mission:** Transform 4x Trades from a disciplined checklist + diary into an institutional-grade trading mentor that prop firms would license.
>
> **Guiding Principle:** _Every paid feature must have a free alternative._ This roadmap costs **$0/month** in third-party APIs. All AI/ML runs on-device or via free tiers.

---

## 📋 Table of Contents

1. [Phase 1 — Plug The Loopholes (Foundation)](#phase-1)
2. [Phase 2 — Behavioral Edge Layer (Mentor Mode)](#phase-2)
3. [Phase 3 — Adaptive Intelligence (Self-Learning System)](#phase-3)
4. [Phase 4 — Risk Architecture (Pro-Grade Risk)](#phase-4)
5. [Phase 5 — Trust & Resilience (Audit + Backup)](#phase-5)
6. [Phase 6 — Polish & Launch Readiness](#phase-6)
7. [Appendix — Free Tools Inventory](#appendix)

---

<a name="phase-1"></a>
## 🛡️ Phase 1 — Plug The Loopholes (Foundation)

> **Goal:** Make it impossible for the trader to lie to themselves.

### 1.1. On-Device Screenshot OCR Trade Importer
**Problem:** Manual P/L entry is the #1 way users cheat the system.

**Solution:** Use **Google ML Kit** (`google_mlkit_text_recognition`) — free, offline, on-device OCR.

**User Flow:**
1. User taps `+ Log Trade` → toggles `Import from Screenshot`.
2. They select screenshot from MT5/cTrader/TradeLocker history.
3. ML Kit reads all text lines on-device.
4. Smart parser detects: symbol, direction, lots, P/L, time.
5. App shows extracted trades for one-tap confirmation.
6. Trades flow into encrypted Hive store.

**Files to add/modify:**
- `lib/services/screenshot_ocr_service.dart` _(new)_
- `lib/services/trade_extractor.dart` _(new — pattern matching for MT5/cTrader/etc.)_
- `lib/ui/parts/trade_flow_tab.dart` _(add screenshot button)_
- `pubspec.yaml` _(add `google_mlkit_text_recognition`)_

**Cost:** $0 forever.

---

### 1.2. Evidence-Backed Manual Gates
**Problem:** Users tick checklist gates (HTF trend, BOS, Liquidity sweep) without doing the work.

**Solution:** Each manual gate requires **proof** before turning green.

**User Flow per Gate:**
1. User taps gate → modal opens.
2. They must either:
   - Type a 1-line justification ("HTF trend = bearish per Daily H&S"), OR
   - Attach a chart screenshot annotation.
3. Gate turns green only after proof submitted.
4. Proof is stored on the trade in Journal for later review.

**Files to modify:**
- `lib/ui/parts/trade_flow_tab.dart` _(gate confirm modal)_
- `lib/data/models.dart` _(add `gateProofs: Map<String, String>` to Trade model)_
- `lib/logic/cubits/trading_core_cubit.dart` _(persist gate proofs)_

**Mentor Impact:** Forces real cognitive effort instead of mindless ticking.

---

### 1.3. Locked-Down "Reset Today" + Integrity Log
**Problem:** Trader who blew up today resets the day to dodge the lockout.

**Solution:** Reset becomes hard — and tracked.

**User Flow:**
1. User taps `Reset Today` in Settings.
2. App requires: biometric reauth + 24-hour cooldown.
3. Action is permanently logged in **Integrity Log** (new tab in Settings).
4. After 3 resets in 30 days, AI flags user as "tilt-prone" with explicit warnings.

**Files to add/modify:**
- `lib/data/models.dart` _(add `IntegrityEvent` model)_
- `lib/ui/parts/settings_tab.dart` _(add Integrity Log section)_
- `lib/logic/cubits/trading_core_cubit.dart` _(log every mutation)_

**Mentor Impact:** No more ghost-resetting bad days.

---

### 1.4. Unforgeable Lock (Out-of-App Accountability)
**Problem:** The 24-hour lock can be ignored — user just opens MT5 and trades anyway.

**Solution:** Two-pronged accountability layer.

**User Flow:**
- **Option A — Soft Mode (free):** When locked, app sends a push to a designated **accountability partner** (spouse/coach) with: _"4x is locked until [time]. They can't trade until then."_
- **Option B — Hard Mode (cTrader users):** Use cTrader Open API (free OAuth) to actually freeze the broker account during the lockout window.

**Files to add:**
- `lib/services/accountability_service.dart` _(new)_
- `lib/ui/parts/settings_tab.dart` _(partner setup)_

**Cost:** $0 (uses Firebase Cloud Messaging free tier).

---

<a name="phase-2"></a>
## 🧠 Phase 2 — Behavioral Edge Layer (Mentor Mode)

> **Goal:** Capture _why_ trades happen, not just _what_ happens.

### 2.1. Setup Quality + Trigger Tagging (Mandatory)
**Problem:** Free-text notes are useless for analytics.

**Solution:** Force a structured tag on every trade.

**User Flow When Logging Trade:**
1. User must pick **one** Setup Quality: `A+ / B / C`.
2. User must pick **one** Trigger: `Plan / FOMO / Revenge / Boredom / News / Other`.
3. AI later analyzes: _"You make 80% of money on A+ setups but 60% of trades are FOMO."_

**Files to modify:**
- `lib/data/models.dart` _(add `setupQuality` and `trigger` fields to Trade)_
- `lib/ui/parts/trade_flow_tab.dart` _(2-tap pickers in log flow)_
- `lib/logic/intelligence_engine.dart` _(add insight: setup quality vs P/L)_

**Mentor Impact:** Unlocks dozens of new analytics that matter more than win rate.

---

### 2.2. Guided Post-Trade Reflection
**Problem:** After-trade notes are unstructured & emotional.

**Solution:** 30-second post-mortem after every closed trade.

**User Flow:**
After logging a trade, app prompts 3 quick questions:
1. **"Did you follow your plan?"** → ✅ Yes / ❌ No
2. **"What ended the trade?"** → TP / SL / Manual exit / Time stop
3. **"Rate your emotional state during the trade"** → 1-10 slider

**Files to add/modify:**
- `lib/ui/parts/post_trade_reflection.dart` _(new modal)_
- `lib/data/models.dart` _(add `reflection` sub-model on Trade)_

**Mentor Impact:** Builds a behavioral fingerprint.

---

### 2.3. Daily Mood Check-In
**Problem:** No correlation between trader state and trade quality.

**Solution:** 1-tap mood log on app open (before any trading).

**User Flow:**
1. App opens → sheet asks: _"How are you today?"_
2. 5 emoji options: 😴 Tired | 😐 Neutral | 😊 Sharp | 😤 Frustrated | 🤩 Hyped
3. Pick + optional 1-line note.
4. Mood tied to today's trades for analysis.

**Files to add:**
- `lib/ui/parts/mood_check_sheet.dart` _(new)_
- `lib/data/models.dart` _(add `dailyMoods` map to AppState)_

**Mentor Impact:** Pattern detection: _"You lose 70% on Frustrated days — consider paper trading when frustrated."_

---

<a name="phase-3"></a>
## 🤖 Phase 3 — Adaptive Intelligence (Self-Learning System)

> **Goal:** Stop hardcoding edges. Let the app learn from each trader's data.

### 3.1. Personal Edge Engine (Auto-Calibrating)
**Problem:** Hardcoded rules ("09:00-10:30 dead zone", "EU buy bias") are stale.

**Solution:** After 30+ trades, app recomputes the user's **personal edges**.

**Output:**
- Per-hour win rate heatmap
- Per-instrument win rate
- Per-day-of-week win rate
- Personal "best window" + "personal dead zones"
- Recalculated weekly

**User Flow:**
- New tab section: **"My Personal Edge"** alongside the historical research.
- Shows: _"Your best window: 13:00-15:00 EAT (62% WR over 24 trades)"_
- Shows: _"Your dead zone: Monday 09:00-10:30 (4 losses, 0 wins)"_
- Recommendations evolve as data grows.

**Files to add/modify:**
- `lib/logic/personal_edge_engine.dart` _(new)_
- `lib/ui/parts/edge_tab.dart` _(add "Personal Edge" section)_

**Mentor Impact:** App becomes a mirror of the user's actual behavior.

---

### 3.2. Weekly AI Digest (Push Notification)
**Problem:** AI is reactive — only acts when asked.

**Solution:** Sunday evening, AI auto-generates a 3-bullet digest.

**User Flow:**
1. Sunday at 6 PM EAT, user receives push: _"Your week in trades is ready."_
2. Tap → see digest:
   - **Win:** "Your A+ setups produced +$340 this week."
   - **Worst Habit:** "60% of trades were FOMO. Worst day: Wednesday."
   - **One Fix:** "Skip trades after 2 losses. Would have saved $180 this week."
3. AI uses Gemini's free tier (15 req/min) — well within weekly limit.

**Files to add:**
- `lib/services/weekly_digest_service.dart` _(new)_
- `lib/services/notification_scheduler.dart` _(new)_

**Mentor Impact:** App becomes a coach who shows up uninvited (in a good way).

---

### 3.3. Pre-Trade Streak Warning
**Problem:** Hot streaks lead to overconfidence and the worst trades.

**Solution:** Behavioral warning before 4th consecutive win/loss.

**User Flow:**
- Trader on 3W streak tries to log a 4th trade.
- App pops a calm modal: _"You're on a 3-win streak. Statistically, the next trade after a streak underperforms by 60%. Consider reducing size or skipping today."_
- User can dismiss but it's logged.

**Files to add/modify:**
- `lib/logic/intelligence_engine.dart` _(add streak detector)_
- `lib/ui/parts/trade_flow_tab.dart` _(streak warning modal)_

**Mentor Impact:** Adds friction at the most dangerous moments.

---

<a name="phase-4"></a>
## 💰 Phase 4 — Risk Architecture (Pro-Grade Risk)

> **Goal:** Think in periods, not single trades. Match how funds operate.

### 4.1. Drawdown Awareness Dashboard
**Problem:** No tracking of weekly/monthly/challenge drawdown.

**Solution:** Add a drawdown engine + UI panel.

**User Flow:**
- Dashboard shows new card: **"Distance from Bust"**
- Visual gauge: green (safe) → amber (caution) → red (danger).
- Breaks down: Daily DD / Weekly DD / Max DD vs prop firm rules.
- For prop firm users, set their firm's max DD in Settings → app warns when 70% consumed.

**Files to add/modify:**
- `lib/logic/drawdown_engine.dart` _(new)_
- `lib/ui/parts/dashboard_tab.dart` _(add DD card)_
- `lib/data/models.dart` _(add `propFirmRules` to Settings)_

---

### 4.2. Weekly Risk Budget System
**Problem:** Per-trade risk thinking is amateur. Pros think in R-units per period.

**Solution:** Configurable weekly risk budget that depletes per loss.

**User Flow:**
1. User sets weekly budget in Settings: e.g., **10R** (where 1R = $125).
2. Each loss deducts from budget.
3. When 80% consumed → warning banner.
4. When 100% consumed → mandatory paper-only mode rest of week.
5. Resets every Sunday.

**Files to add:**
- `lib/logic/risk_budget_engine.dart` _(new)_
- `lib/ui/parts/dashboard_tab.dart` _(R-budget meter)_

**Mentor Impact:** Shifts thinking from "1 trade" to "1 week" — institutional mindset.

---

### 4.3. Planned vs Realized Risk Delta
**Problem:** Calculator says $125 risk, but actual loss is $300 due to slippage/holding past stop.

**Solution:** Track planned risk per trade, then compare to realized loss.

**User Flow:**
- When logging trade, calculator's risk number is auto-attached.
- After logging close, app computes: _"Planned risk: $125 | Actual loss: $187 | Slippage: +$62 (49%)"_
- Aggregate insight: _"Your average actual loss is 1.4x planned. Tighten stop-loss execution."_

**Files to modify:**
- `lib/data/models.dart` _(add `plannedRisk` to Trade)_
- `lib/logic/intelligence_engine.dart` _(add slippage insight)_

---

### 4.4. Economic Calendar Awareness
**Problem:** App doesn't warn about NFP, CPI, FOMC days.

**Solution:** Pull free economic calendar (Forex Factory RSS or similar).

**User Flow:**
- High-impact news within 60 min → red banner on Dashboard.
- Optional: auto-block trade logging during ±15 min of red folder events.
- New Settings toggle: _"Block trades around news"_.

**Files to add:**
- `lib/services/economic_calendar_service.dart` _(new)_
- `lib/ui/parts/dashboard_tab.dart` _(news warning banner)_

**Cost:** $0 (Forex Factory RSS is free).

---

<a name="phase-5"></a>
## 🔒 Phase 5 — Trust & Resilience (Audit + Backup)

> **Goal:** Build user trust and prevent catastrophic data loss.

### 5.1. Immutable Audit Log
**Problem:** No way to see when trades were edited or deleted.

**Solution:** Every state mutation appends to an audit log.

**User Flow:**
- New Settings section: **Activity History**
- Shows chronological list: _"May 4, 2:14 PM — Trade #t12 P/L edited from -$80 → -$30"_
- Cannot be cleared or edited.
- Helps users self-audit and helps AI detect "fudging."

**Files to add:**
- `lib/data/audit_log_repository.dart` _(new)_
- `lib/ui/parts/settings_tab.dart` _(audit log viewer)_

---

### 5.2. Encrypted Cloud Backup
**Problem:** Phone breaks → months of journaling lost.

**Solution:** Encrypted weekly auto-backup to user's own iCloud/Google Drive.

**User Flow:**
1. Settings → "Cloud Backup" → user picks Drive/iCloud.
2. Every Sunday at 6 PM, encrypted Hive blob uploaded to user's drive.
3. On reinstall, user picks "Restore from Backup" → enters PIN → data restored.

**Files to add:**
- `lib/services/cloud_backup_service.dart` _(new)_
- Native bridges for Drive/iCloud on each platform.

**Cost:** $0 (uses user's existing storage).

---

### 5.3. Local-Only AI Mode Toggle
**Problem:** Some users (institutional/high-net-worth) don't want trades shipped to Google.

**Solution:** Settings toggle to disable all AI cloud calls.

**User Flow:**
- Settings → "Privacy" → "Local-only mode" toggle.
- When ON: AI Coach disabled, weekly digest computed locally with rule-based insights.
- All other features (charts, journaling, gates) work fully offline.

**Files to modify:**
- `lib/services/ai_service.dart` _(check toggle before calls)_
- `lib/logic/local_insights_engine.dart` _(new — rule-based fallback)_

---

### 5.4. PDF Tear Sheet Export
**Problem:** Traders need shareable reports for accountants/investors.

**Solution:** Generate institutional-grade PDF performance reports.

**User Flow:**
1. Settings → "Export Tear Sheet"
2. Pick date range.
3. PDF generated with: equity curve, max drawdown, Sharpe, profit factor, trade list.
4. User can save/share/email.

**Files to add:**
- `lib/services/pdf_report_service.dart` _(new — uses `pdf` package, free)_
- `lib/ui/parts/settings_tab.dart` _(export button)_

**Cost:** $0 (`pdf` Flutter package is free).

---

<a name="phase-6"></a>
## ✨ Phase 6 — Polish & Launch Readiness

### 6.1. Onboarding Walkthrough Refresh
- Re-record the walkthrough to highlight new features.
- Add a 30-second video on the welcome screen showing screenshot import.

### 6.2. Self-Comparison Widget
- Dashboard card: _"Discipline this month: 87% vs last month: 64%"_
- Trader sees themselves improving (the strongest motivator).

### 6.3. Configurable Daily Trade Cap
- Settings → "Daily trade limit" → user picks 1/2/3/5.
- Default still 2, but pros can adjust.

### 6.4. Prop Firm Profile Selector
- Settings → "Prop Firm" → pick: FTMO / Topstep / MFF / Custom.
- App auto-loads firm's daily DD, max DD, and rule constraints.

### 6.5. Multi-Account Support
- Some traders run 3-4 prop firm accounts simultaneously.
- Top bar account switcher: _Personal | FTMO 1 | FTMO 2_.
- Each account has its own trades, locks, and DD tracking.

---

<a name="appendix"></a>
## 📦 Appendix — Free Tools Inventory

| Need | Free Tool | Cost |
|------|-----------|------|
| OCR (Screenshot Reading) | `google_mlkit_text_recognition` | $0 forever |
| AI Insights | Gemini API free tier (15 req/min) | $0 (current key works) |
| Push Notifications | Firebase Cloud Messaging | $0 unlimited |
| PDF Generation | Flutter `pdf` package | $0 forever |
| Economic Calendar | Forex Factory RSS | $0 forever |
| Cloud Backup | User's own Drive/iCloud | $0 (user storage) |
| Charts | `fl_chart` Flutter package | $0 forever |
| Encrypted Storage | Hive AES-256 (already in use) | $0 forever |
| Biometric Auth | `local_auth` (already in use) | $0 forever |
| MT4/MT5 Account Sync | MyFxBook free read-only API | $0 free tier |
| cTrader Direct Sync | cTrader Open API (OAuth) | $0 free |

---

## 🚦 Suggested Build Order (Iterative Releases)

### **Sprint 1 — Stop The Bleeding** _(Phase 1.1, 1.2, 1.3)_
- Screenshot OCR Importer
- Evidence-backed gates
- Integrity Log + locked Reset

### **Sprint 2 — Behavioral Capture** _(Phase 2)_
- Setup quality + trigger tagging
- Post-trade reflection
- Mood check-in

### **Sprint 3 — Adaptive Brain** _(Phase 3)_
- Personal Edge Engine
- Weekly AI Digest
- Streak warnings

### **Sprint 4 — Pro Risk** _(Phase 4)_
- Drawdown dashboard
- Weekly risk budget
- Economic calendar

### **Sprint 5 — Trust Layer** _(Phase 5)_
- Audit log
- Cloud backup
- Local-only AI mode
- PDF tear sheets

### **Sprint 6 — Polish** _(Phase 6)_
- Onboarding refresh
- Multi-account support
- Prop firm profiles

---

## 🎯 Success Metrics (Post-Launch)

| Metric | Target |
|--------|--------|
| % of trades with verified P/L (OCR) | 80%+ |
| % of trades with setup tag | 100% |
| Week 4 retention | 60%+ |
| Avg user discipline streak | 5+ days |
| Avg "Reset Today" usage per user | <1/month |
| Crash-free rate | 99.8%+ |

---

## 🌟 The North Star

> By the end of this roadmap, opening this app should feel less like opening a calculator and more like meeting your prop trading coach.
>
> Every screen should answer one of three questions:
> 1. **Should I trade right now?**
> 2. **Did I trade well yesterday?**
> 3. **What's my one fix for this week?**
>
> If a feature doesn't answer one of those, it's noise. Cut it.