import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { AppState, Trade } from './types';
import { getEAT, eatDateStr } from './utils/time';

const STORAGE_KEY = 'em_fp2_v4';

const TARGET = 1250;
const DAILY_LIMIT = 1250;

const DEFAULT_STATE: AppState = {
  balance: 25000,
  startDate: '2026-04-20',
  priorPnl: 0,
  checks: {},
  allTrades: [],
  lock: false,
  lockUntil: null,
  preloaded: false,
};

interface StoreContextType {
  state: AppState;
  updateState: (updates: Partial<AppState>) => void;
  addTrade: (trade: Omit<Trade, 'id' | 'date' | 'time'>) => void;
  deleteTrade: (id: string) => void;
  toggleCheck: (id: string) => void;
  resetChecks: (gateIds: string[]) => void;
  resetToday: () => void;
  resetAll: () => void;
  importData: (data: string) => boolean;
  exportData: () => string;
  getTodayTrades: () => Trade[];
  getTodayPnl: () => number;
  getChallengePnl: () => number;
  getDayNumber: () => number;
  checkLock: () => void;
}

const StoreContext = createContext<StoreContextType | null>(null);

export function StoreProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AppState>(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        return { ...DEFAULT_STATE, ...JSON.parse(stored) };
      }
    } catch (e) {
      console.warn('Failed to load state from local storage');
    }
    return DEFAULT_STATE;
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [state]);

  const updateState = (updates: Partial<AppState>) => {
    setState((prev) => ({ ...prev, ...updates }));
  };

  const getTodayTrades = () => {
    const today = eatDateStr(getEAT());
    return state.allTrades.filter((t) => t.date === today);
  };

  const getTodayPnl = () => {
    return getTodayTrades().reduce((sum, t) => sum + t.pnl, 0);
  };

  const getChallengePnl = () => {
    return state.priorPnl + getTodayPnl();
  };

  const getDayNumber = () => {
    const start = new Date(state.startDate + 'T00:00:00Z');
    const today = new Date(eatDateStr(getEAT()) + 'T00:00:00Z');
    return Math.max(1, Math.floor((today.getTime() - start.getTime()) / 86400000) + 1);
  };

  const checkLock = () => {
    setState((prev) => {
      let newLock = prev.lock;
      let newLockUntil = prev.lockUntil;

      // Unlock if time expired
      if (newLock && newLockUntil && Date.now() > newLockUntil) {
        newLock = false;
        newLockUntil = null;
      }

      // Check if we need to lock (2 trades today, both SL)
      const today = eatDateStr(getEAT());
      const tt = prev.allTrades.filter((t) => t.date === today);
      if (tt.length >= 2 && tt.every((t) => t.pnl < 0) && !newLock) {
        newLock = true;
        newLockUntil = Date.now() + 24 * 3600 * 1000;
      }

      if (newLock !== prev.lock) {
        return { ...prev, lock: newLock, lockUntil: newLockUntil };
      }
      return prev;
    });
  };

  const addTrade = (trade: Omit<Trade, 'id' | 'date' | 'time'>) => {
    const eat = getEAT();
    const newTrade: Trade = {
      ...trade,
      id: 't' + Date.now(),
      date: eatDateStr(eat),
      time: `${String(eat.getUTCHours()).padStart(2, '0')}:${String(eat.getUTCMinutes()).padStart(2, '0')} EAT`,
    };
    setState((prev) => ({ ...prev, allTrades: [...prev.allTrades, newTrade] }));
    setTimeout(checkLock, 0); // Check lock after state updates
  };

  const deleteTrade = (id: string) => {
    setState((prev) => ({ ...prev, allTrades: prev.allTrades.filter((t) => t.id !== id) }));
    setTimeout(checkLock, 0);
  };

  const toggleCheck = (id: string) => {
    setState((prev) => ({
      ...prev,
      checks: { ...prev.checks, [id]: !prev.checks[id] },
    }));
  };

  const resetChecks = (gateIds: string[]) => {
    setState((prev) => {
      const newChecks = { ...prev.checks };
      gateIds.forEach((id) => {
        newChecks[id] = false;
      });
      return { ...prev, checks: newChecks };
    });
  };

  const resetToday = () => {
    const today = eatDateStr(getEAT());
    setState((prev) => ({
      ...prev,
      allTrades: prev.allTrades.filter((t) => t.date !== today),
      checks: {},
      lock: false,
      lockUntil: null,
    }));
  };

  const resetAll = () => {
    setState(DEFAULT_STATE);
  };

  const exportData = () => {
    return JSON.stringify(state, null, 2);
  };

  const importData = (dataStr: string) => {
    try {
      const parsed = JSON.parse(dataStr);
      if (parsed && typeof parsed === 'object') {
        setState({ ...DEFAULT_STATE, ...parsed });
        return true;
      }
    } catch (e) {
      console.error('Invalid JSON');
    }
    return false;
  };

  return (
    <StoreContext.Provider
      value={{
        state,
        updateState,
        addTrade,
        deleteTrade,
        toggleCheck,
        resetChecks,
        resetToday,
        resetAll,
        importData,
        exportData,
        getTodayTrades,
        getTodayPnl,
        getChallengePnl,
        getDayNumber,
        checkLock,
      }}
    >
      {children}
    </StoreContext.Provider>
  );
}

export function useStore() {
  const context = useContext(StoreContext);
  if (!context) throw new Error('useStore must be used within a StoreProvider');
  return context;
}
