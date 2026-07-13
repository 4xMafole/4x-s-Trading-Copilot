-- LocoTrader — Initial Database Schema
-- Run against Supabase Postgres via Dashboard > SQL Editor or supabase db push

-- ══════════════════════════════════════════════════════════════════════
--  ENUMS
-- ══════════════════════════════════════════════════════════════════════

CREATE TYPE subscription_tier AS ENUM ('free', 'pro');
CREATE TYPE trade_direction AS ENUM ('buy', 'sell');
CREATE TYPE setup_quality AS ENUM ('A+', 'B', 'C');
CREATE TYPE trade_trigger AS ENUM ('Plan', 'FOMO', 'Revenge', 'Boredom', 'News', 'Other');
CREATE TYPE exit_reason AS ENUM ('TP', 'SL', 'Manual', 'Time');
CREATE TYPE gate_type AS ENUM ('auto', 'manual');
CREATE TYPE instrument_category AS ENUM ('forex_majors', 'forex_minors', 'forex_exotics', 'indices', 'crypto', 'commodities', 'stocks');

-- ══════════════════════════════════════════════════════════════════════
--  USERS & SUBSCRIPTIONS
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Subscription
  tier subscription_tier NOT NULL DEFAULT 'free',
  stripe_customer_id TEXT,
  subscription_expires_at TIMESTAMPTZ,

  -- Onboarding
  onboarding_completed BOOLEAN NOT NULL DEFAULT false,
  experience_level TEXT, -- beginner, intermediate, advanced
  primary_market instrument_category,

  -- AI
  ai_api_key_encrypted TEXT, -- user's own Gemini key (encrypted at rest)

  -- Risk defaults
  risk_cap_usd DOUBLE PRECISION NOT NULL DEFAULT 100.0,
  daily_trade_cap INT NOT NULL DEFAULT 2,

  -- Biometric / security
  biometric_enabled BOOLEAN NOT NULL DEFAULT false
);

-- ══════════════════════════════════════════════════════════════════════
--  INSTRUMENTS (pre-seeded library)
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.instruments (
  id TEXT PRIMARY KEY, -- e.g. 'XAUUSD', 'BTCUSDT', 'AAPL'
  display_name TEXT NOT NULL,
  category instrument_category NOT NULL,
  unit TEXT NOT NULL, -- 'pips', 'points', '$ move', '%'
  pip_value DOUBLE PRECISION NOT NULL DEFAULT 1.0,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true
);

-- User's selected instruments (their watchlist)
CREATE TABLE public.user_instruments (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  instrument_id TEXT NOT NULL REFERENCES public.instruments(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, instrument_id)
);

-- ══════════════════════════════════════════════════════════════════════
--  STRATEGY PROFILES & GATES
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.strategy_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT 'Default',
  is_active BOOLEAN NOT NULL DEFAULT true,
  template_source TEXT, -- 'ICT', 'SMC', 'Supply/Demand', 'Price Action', null = custom
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  strategy_id UUID NOT NULL REFERENCES public.strategy_profiles(id) ON DELETE CASCADE,
  sort_order INT NOT NULL DEFAULT 0,
  gate_type gate_type NOT NULL DEFAULT 'manual',
  label TEXT NOT NULL,
  description TEXT,
  -- Symbol scoping: null means applies to all instruments
  applies_to_instruments TEXT[], -- e.g. {'XAUUSD', 'EURUSD'} or null for all
  -- Auto-gate config (JSON for flexible rule definitions)
  auto_rule JSONB, -- e.g. {"type": "time_window", "start": "09:00", "end": "10:30", "action": "block"}
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
--  TRADING SESSIONS (user-configurable time windows)
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.trading_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL, -- 'London', 'New York', 'Tokyo', 'Sydney', 'Custom'
  start_time TIME NOT NULL, -- in user's local timezone
  end_time TIME NOT NULL,
  days_active INT[] NOT NULL DEFAULT '{1,2,3,4,5}', -- 1=Mon...7=Sun
  is_blackout BOOLEAN NOT NULL DEFAULT false, -- true = DO NOT trade here
  color TEXT, -- hex color for UI
  is_active BOOLEAN NOT NULL DEFAULT true
);

-- ══════════════════════════════════════════════════════════════════════
--  TRADES
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  strategy_id UUID REFERENCES public.strategy_profiles(id) ON DELETE SET NULL,

  -- Core fields
  instrument_id TEXT NOT NULL,
  direction trade_direction NOT NULL DEFAULT 'buy',
  lots DOUBLE PRECISION NOT NULL DEFAULT 0,
  pnl DOUBLE PRECISION NOT NULL DEFAULT 0,
  note TEXT DEFAULT '',

  -- Timing
  open_date DATE,
  open_time TIME,
  close_date DATE NOT NULL DEFAULT CURRENT_DATE,
  close_time TIME,

  -- Prices
  open_price DOUBLE PRECISION,
  close_price DOUBLE PRECISION,
  stop_loss DOUBLE PRECISION,
  take_profit DOUBLE PRECISION,

  -- Metadata
  setup_quality setup_quality,
  trigger trade_trigger,
  planned_risk DOUBLE PRECISION,
  violations TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  is_hypothetical BOOLEAN NOT NULL DEFAULT false,

  -- Broker import fields
  ticket_id TEXT,
  commission DOUBLE PRECISION,
  swap DOUBLE PRECISION,

  -- Images (Supabase Storage paths)
  htf_image TEXT,
  ltf_image TEXT,
  plan_image TEXT,

  -- Reflection
  reflection_followed_plan BOOLEAN,
  reflection_exit_reason exit_reason,
  reflection_emotional_state INT, -- 1-10

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
--  GATE CHECKS (per-day status of each gate)
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.gate_checks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  gate_id UUID NOT NULL REFERENCES public.gates(id) ON DELETE CASCADE,
  checked_date DATE NOT NULL DEFAULT CURRENT_DATE,
  is_passed BOOLEAN NOT NULL DEFAULT false,
  proof TEXT,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, gate_id, checked_date)
);

-- ══════════════════════════════════════════════════════════════════════
--  DAILY MOOD
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.daily_moods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  mood TEXT NOT NULL, -- 'Tired', 'Neutral', 'Sharp', 'Frustrated', 'Hyped'
  note TEXT DEFAULT '',
  mood_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, mood_date)
);

-- ══════════════════════════════════════════════════════════════════════
--  PROP FIRM PROFILES
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.prop_firm_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  firm_name TEXT NOT NULL, -- 'FTMO', 'MyForexFunds', 'TFT', 'Custom'
  max_daily_drawdown DOUBLE PRECISION, -- as % or $ depending on firm
  max_total_drawdown DOUBLE PRECISION,
  profit_target DOUBLE PRECISION,
  is_percentage BOOLEAN NOT NULL DEFAULT true, -- true = %, false = $
  is_active BOOLEAN NOT NULL DEFAULT false,
  metadata JSONB, -- firm-specific rules
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
--  WEEKLY DIGESTS
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE public.weekly_digests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  week_id TEXT NOT NULL, -- '2026-W28'
  win TEXT,
  worst_habit TEXT,
  one_fix TEXT,
  is_seen BOOLEAN NOT NULL DEFAULT false,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, week_id)
);

-- ══════════════════════════════════════════════════════════════════════
--  INDEXES
-- ══════════════════════════════════════════════════════════════════════

CREATE INDEX idx_trades_user_date ON public.trades(user_id, close_date DESC);
CREATE INDEX idx_trades_user_instrument ON public.trades(user_id, instrument_id);
CREATE INDEX idx_trades_ticket ON public.trades(user_id, ticket_id) WHERE ticket_id IS NOT NULL;
CREATE INDEX idx_gate_checks_user_date ON public.gate_checks(user_id, checked_date);
CREATE INDEX idx_moods_user_date ON public.daily_moods(user_id, mood_date);
CREATE INDEX idx_strategy_user ON public.strategy_profiles(user_id);

-- ══════════════════════════════════════════════════════════════════════
--  ROW-LEVEL SECURITY (every user sees only their own data)
-- ══════════════════════════════════════════════════════════════════════

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gate_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trading_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_instruments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prop_firm_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_digests ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read/update their own row
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Trades: full CRUD on own trades
CREATE POLICY "Users can CRUD own trades"
  ON public.trades FOR ALL USING (auth.uid() = user_id);

-- Gate checks: full CRUD
CREATE POLICY "Users can CRUD own gate checks"
  ON public.gate_checks FOR ALL USING (auth.uid() = user_id);

-- Daily moods
CREATE POLICY "Users can CRUD own moods"
  ON public.daily_moods FOR ALL USING (auth.uid() = user_id);

-- Strategy profiles
CREATE POLICY "Users can CRUD own strategies"
  ON public.strategy_profiles FOR ALL USING (auth.uid() = user_id);

-- Gates (belong to strategy which belongs to user)
CREATE POLICY "Users can CRUD own gates"
  ON public.gates FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.strategy_profiles sp
      WHERE sp.id = gates.strategy_id AND sp.user_id = auth.uid()
    )
  );

-- Trading sessions
CREATE POLICY "Users can CRUD own sessions"
  ON public.trading_sessions FOR ALL USING (auth.uid() = user_id);

-- User instruments
CREATE POLICY "Users can CRUD own instruments"
  ON public.user_instruments FOR ALL USING (auth.uid() = user_id);

-- Prop firm profiles
CREATE POLICY "Users can CRUD own prop profiles"
  ON public.prop_firm_profiles FOR ALL USING (auth.uid() = user_id);

-- Weekly digests
CREATE POLICY "Users can CRUD own digests"
  ON public.weekly_digests FOR ALL USING (auth.uid() = user_id);

-- Instruments table is read-only for all authenticated users
ALTER TABLE public.instruments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read instruments"
  ON public.instruments FOR SELECT
  USING (auth.role() = 'authenticated');
