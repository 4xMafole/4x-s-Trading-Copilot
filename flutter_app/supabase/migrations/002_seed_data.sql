-- LocoTrader — Seed data: instruments library + strategy templates
-- Run after 001_initial_schema.sql

-- ══════════════════════════════════════════════════════════════════════
--  INSTRUMENTS LIBRARY (60+ instruments across all categories)
-- ══════════════════════════════════════════════════════════════════════

-- Forex Majors
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('EURUSD', 'EUR/USD', 'forex_majors', 'pips', 1.0, 'Euro vs US Dollar'),
  ('GBPUSD', 'GBP/USD', 'forex_majors', 'pips', 1.0, 'British Pound vs US Dollar'),
  ('USDJPY', 'USD/JPY', 'forex_majors', 'pips', 0.9, 'US Dollar vs Japanese Yen'),
  ('USDCHF', 'USD/CHF', 'forex_majors', 'pips', 1.0, 'US Dollar vs Swiss Franc'),
  ('AUDUSD', 'AUD/USD', 'forex_majors', 'pips', 1.0, 'Australian Dollar vs US Dollar'),
  ('USDCAD', 'USD/CAD', 'forex_majors', 'pips', 0.75, 'US Dollar vs Canadian Dollar'),
  ('NZDUSD', 'NZD/USD', 'forex_majors', 'pips', 1.0, 'New Zealand Dollar vs US Dollar');

-- Forex Minors
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('EURGBP', 'EUR/GBP', 'forex_minors', 'pips', 1.3, 'Euro vs British Pound'),
  ('EURJPY', 'EUR/JPY', 'forex_minors', 'pips', 0.9, 'Euro vs Japanese Yen'),
  ('GBPJPY', 'GBP/JPY', 'forex_minors', 'pips', 0.9, 'British Pound vs Japanese Yen'),
  ('EURCHF', 'EUR/CHF', 'forex_minors', 'pips', 1.0, 'Euro vs Swiss Franc'),
  ('EURAUD', 'EUR/AUD', 'forex_minors', 'pips', 0.65, 'Euro vs Australian Dollar'),
  ('GBPAUD', 'GBP/AUD', 'forex_minors', 'pips', 0.65, 'British Pound vs Australian Dollar'),
  ('AUDNZD', 'AUD/NZD', 'forex_minors', 'pips', 0.6, 'Australian Dollar vs New Zealand Dollar'),
  ('CADJPY', 'CAD/JPY', 'forex_minors', 'pips', 0.9, 'Canadian Dollar vs Japanese Yen'),
  ('CHFJPY', 'CHF/JPY', 'forex_minors', 'pips', 0.9, 'Swiss Franc vs Japanese Yen'),
  ('NZDJPY', 'NZD/JPY', 'forex_minors', 'pips', 0.9, 'New Zealand Dollar vs Japanese Yen');

-- Forex Exotics
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('USDMXN', 'USD/MXN', 'forex_exotics', 'pips', 0.06, 'US Dollar vs Mexican Peso'),
  ('USDZAR', 'USD/ZAR', 'forex_exotics', 'pips', 0.06, 'US Dollar vs South African Rand'),
  ('USDTRY', 'USD/TRY', 'forex_exotics', 'pips', 0.03, 'US Dollar vs Turkish Lira'),
  ('EURTRY', 'EUR/TRY', 'forex_exotics', 'pips', 0.03, 'Euro vs Turkish Lira'),
  ('USDSEK', 'USD/SEK', 'forex_exotics', 'pips', 0.1, 'US Dollar vs Swedish Krona'),
  ('USDNOK', 'USD/NOK', 'forex_exotics', 'pips', 0.1, 'US Dollar vs Norwegian Krone');

-- Indices
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('NAS100', 'Nasdaq 100', 'indices', 'points', 2.0, 'US Tech 100 index'),
  ('US30', 'Dow Jones 30', 'indices', 'points', 1.0, 'US Dow Jones Industrial'),
  ('SPX500', 'S&P 500', 'indices', 'points', 1.0, 'US S&P 500 index'),
  ('GER40', 'DAX 40', 'indices', 'points', 1.0, 'German DAX index'),
  ('UK100', 'FTSE 100', 'indices', 'points', 1.0, 'UK FTSE 100 index'),
  ('JPN225', 'Nikkei 225', 'indices', 'points', 0.01, 'Japan Nikkei 225 index'),
  ('AUS200', 'ASX 200', 'indices', 'points', 1.0, 'Australia ASX 200 index'),
  ('FRA40', 'CAC 40', 'indices', 'points', 1.0, 'France CAC 40 index');

-- Commodities
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('XAUUSD', 'Gold', 'commodities', '$ move', 1.0, 'Gold vs US Dollar (spot)'),
  ('XAGUSD', 'Silver', 'commodities', '$ move', 5.0, 'Silver vs US Dollar (spot)'),
  ('USOIL', 'Crude Oil (WTI)', 'commodities', '$ move', 1.0, 'West Texas Intermediate crude'),
  ('UKOIL', 'Brent Crude', 'commodities', '$ move', 1.0, 'Brent crude oil'),
  ('XNGUSD', 'Natural Gas', 'commodities', '$ move', 1.0, 'Natural gas'),
  ('COPPER', 'Copper', 'commodities', '$ move', 1.0, 'Copper futures');

-- Crypto
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('BTCUSDT', 'Bitcoin', 'crypto', '$ move', 1.0, 'Bitcoin vs USDT'),
  ('ETHUSDT', 'Ethereum', 'crypto', '$ move', 1.0, 'Ethereum vs USDT'),
  ('SOLUSDT', 'Solana', 'crypto', '$ move', 1.0, 'Solana vs USDT'),
  ('BNBUSDT', 'BNB', 'crypto', '$ move', 1.0, 'Binance Coin vs USDT'),
  ('XRPUSDT', 'XRP', 'crypto', '$ move', 1.0, 'Ripple vs USDT'),
  ('ADAUSDT', 'Cardano', 'crypto', '$ move', 1.0, 'Cardano vs USDT'),
  ('DOGEUSDT', 'Dogecoin', 'crypto', '$ move', 1.0, 'Dogecoin vs USDT'),
  ('AVAXUSDT', 'Avalanche', 'crypto', '$ move', 1.0, 'Avalanche vs USDT'),
  ('LINKUSDT', 'Chainlink', 'crypto', '$ move', 1.0, 'Chainlink vs USDT'),
  ('DOTUSDT', 'Polkadot', 'crypto', '$ move', 1.0, 'Polkadot vs USDT');

-- Stocks (popular)
INSERT INTO public.instruments (id, display_name, category, unit, pip_value, description) VALUES
  ('AAPL', 'Apple', 'stocks', '$ move', 1.0, 'Apple Inc.'),
  ('TSLA', 'Tesla', 'stocks', '$ move', 1.0, 'Tesla Inc.'),
  ('NVDA', 'Nvidia', 'stocks', '$ move', 1.0, 'Nvidia Corp.'),
  ('MSFT', 'Microsoft', 'stocks', '$ move', 1.0, 'Microsoft Corp.'),
  ('AMZN', 'Amazon', 'stocks', '$ move', 1.0, 'Amazon.com Inc.'),
  ('META', 'Meta', 'stocks', '$ move', 1.0, 'Meta Platforms Inc.'),
  ('GOOGL', 'Alphabet', 'stocks', '$ move', 1.0, 'Alphabet Inc.'),
  ('AMD', 'AMD', 'stocks', '$ move', 1.0, 'Advanced Micro Devices');

-- ══════════════════════════════════════════════════════════════════════
--  STRATEGY GATE TEMPLATES (inserted as a function users can clone)
-- ══════════════════════════════════════════════════════════════════════

-- We store templates as a special system user (NULL user_id won't work with RLS,
-- so we use a templates table instead)
CREATE TABLE public.gate_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name TEXT NOT NULL, -- 'ICT', 'SMC', 'Supply/Demand', 'Price Action'
  sort_order INT NOT NULL DEFAULT 0,
  gate_type gate_type NOT NULL DEFAULT 'manual',
  label TEXT NOT NULL,
  description TEXT,
  applies_to_categories instrument_category[],
  auto_rule JSONB
);

-- ICT (Inner Circle Trader) template
INSERT INTO public.gate_templates (template_name, sort_order, gate_type, label, description) VALUES
  ('ICT', 1, 'manual', 'Higher-timeframe PD array identified', 'Daily/4H order block, FVG, or liquidity void marked'),
  ('ICT', 2, 'manual', 'Liquidity swept (buy-side or sell-side)', 'External range liquidity or internal liquidity taken'),
  ('ICT', 3, 'manual', 'Market structure shift confirmed', 'Break of structure on M15 or lower — displacement candle present'),
  ('ICT', 4, 'manual', 'Optimal Trade Entry (OTE) zone reached', 'Price retraced into 62-79% fib of displacement leg'),
  ('ICT', 5, 'manual', 'Time window aligned (Killzone)', 'Entry during London (02:00-05:00 EST) or NY (07:00-10:00 EST) killzone'),
  ('ICT', 6, 'auto', 'Not in accumulation/distribution dead zone', 'Avoid 12:00-13:30 EST lunch session'),
  ('ICT', 7, 'manual', 'Risk defined — SL behind PD array', 'Stop loss placed behind the order block or FVG'),
  ('ICT', 8, 'manual', 'Target is opposing liquidity pool', 'TP targets equal highs/lows or untouched PD array');

-- SMC (Smart Money Concepts) template
INSERT INTO public.gate_templates (template_name, sort_order, gate_type, label, description) VALUES
  ('SMC', 1, 'manual', 'HTF bias determined (Daily/4H)', 'Bullish or bearish order flow on higher timeframe'),
  ('SMC', 2, 'manual', 'Point of Interest (POI) marked', 'Supply/demand zone, order block, or breaker identified on HTF'),
  ('SMC', 3, 'manual', 'LTF Change of Character (ChoCH)', 'Lower-timeframe shift into HTF direction confirmed'),
  ('SMC', 4, 'manual', 'Entry at LTF supply/demand zone', 'M5/M15 zone within the HTF POI'),
  ('SMC', 5, 'manual', 'Inducement taken', 'Minor liquidity swept before entry — stops hunted'),
  ('SMC', 6, 'manual', 'Imbalance/FVG present in leg', 'Impulsive move shows fair value gap as confirmation'),
  ('SMC', 7, 'manual', 'SL below/above zone extreme', 'Invalidation is clear and structural'),
  ('SMC', 8, 'manual', 'Risk-to-reward minimum 1:2', 'TP allows at least 2R based on structure');

-- Supply & Demand template
INSERT INTO public.gate_templates (template_name, sort_order, gate_type, label, description) VALUES
  ('Supply/Demand', 1, 'manual', 'Fresh zone identified (untested)', 'First return to a supply or demand zone'),
  ('Supply/Demand', 2, 'manual', 'Strong departure from zone', 'Price left the zone with momentum — big candle or gap'),
  ('Supply/Demand', 3, 'manual', 'Zone on HTF (H4/Daily)', 'Not just an M5 zone — must be visible on higher timeframes'),
  ('Supply/Demand', 4, 'manual', 'Trend alignment', 'Trading with the dominant trend, not counter'),
  ('Supply/Demand', 5, 'manual', 'Arrival pattern clean', 'Price approaching zone without grinding — sharp move in = better'),
  ('Supply/Demand', 6, 'manual', 'No opposing zone in the way', 'Clear path to target — no untested zones blocking'),
  ('Supply/Demand', 7, 'manual', 'Risk placed below/above zone', 'SL beyond the distal line of the zone');

-- Price Action template
INSERT INTO public.gate_templates (template_name, sort_order, gate_type, label, description) VALUES
  ('Price Action', 1, 'manual', 'Key level identified (support/resistance)', 'Major horizontal level, trendline, or moving average'),
  ('Price Action', 2, 'manual', 'Candlestick signal at level', 'Pin bar, engulfing, inside bar, or doji at the key level'),
  ('Price Action', 3, 'manual', 'Trend confirmed on Daily', 'Higher highs/lows for long, lower highs/lows for short'),
  ('Price Action', 4, 'manual', 'False breakout / trap confirmed', 'Wick rejection or failed breakout trapping traders'),
  ('Price Action', 5, 'manual', 'Confluence (2+ factors aligned)', 'Multiple reasons to take the trade — not just one signal'),
  ('Price Action', 6, 'manual', 'SL behind signal candle', 'Stop loss beyond the wick of the signal candle'),
  ('Price Action', 7, 'manual', 'TP at next key level', 'Target is the next logical support/resistance');

-- ══════════════════════════════════════════════════════════════════════
--  FUNCTION: Clone template gates into a user strategy
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.clone_gate_template(
  p_user_id UUID,
  p_strategy_id UUID,
  p_template_name TEXT
) RETURNS void AS $$
BEGIN
  INSERT INTO public.gates (strategy_id, sort_order, gate_type, label, description, auto_rule)
  SELECT p_strategy_id, sort_order, gate_type, label, description, auto_rule
  FROM public.gate_templates
  WHERE template_name = p_template_name
  ORDER BY sort_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ══════════════════════════════════════════════════════════════════════
--  FUNCTION: Create profile on signup (triggered by auth.users insert)
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ══════════════════════════════════════════════════════════════════════
--  FUNCTION: Enforce free-tier trade limit (30 trades)
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.check_trade_limit()
RETURNS TRIGGER AS $$
DECLARE
  user_tier subscription_tier;
  trade_count INT;
BEGIN
  SELECT tier INTO user_tier FROM public.profiles WHERE id = NEW.user_id;
  IF user_tier = 'free' THEN
    SELECT COUNT(*) INTO trade_count FROM public.trades WHERE user_id = NEW.user_id;
    IF trade_count >= 30 THEN
      RAISE EXCEPTION 'Free tier limited to 30 trades. Upgrade to Pro for unlimited.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER enforce_trade_limit
  BEFORE INSERT ON public.trades
  FOR EACH ROW EXECUTE FUNCTION public.check_trade_limit();
