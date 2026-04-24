import React, { useState } from 'react';
import { Menu, X } from 'lucide-react';
import { TopBar } from './components/TopBar';
import { Dashboard } from './components/Dashboard';
import { Checklist } from './components/Checklist';
import { Calculator } from './components/Calculator';
import { Journal } from './components/Journal';
import { Settings } from './components/Settings';
import { MyEdge } from './components/MyEdge';
import { StoreProvider } from './store';
import { cn } from './lib/utils';
import { useAppStore } from './lib/store';
import { useStore } from './store';

export default function App() {
  const [activeTab, setActiveTab] = useState<'dash' | 'edge' | 'check' | 'calc' | 'journal' | 'settings'>('dash');
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const tabs = [
    { id: 'dash', label: 'Dashboard' },
    { id: 'edge', label: 'My Edge' },
    { id: 'check', label: 'Checklist' },
    { id: 'calc', label: 'Calculator' },
    { id: 'journal', label: 'Journal' },
    { id: 'settings', label: 'System' },
  ] as const;

  return (
    <StoreProvider>
      <div className="min-h-screen bg-[#0a0a0a] text-[#e0e0e0] font-sans p-4 md:p-8 pb-24 overflow-x-hidden selection:bg-white/20">
        <div className="max-w-[768px] mx-auto">
          <TopBar />
          
          <LockBanner />
          
          {/* Mobile Tab Drawer Toggle */}
          <div className="md:hidden relative mb-6">
            <button
              onClick={() => setIsMobileMenuOpen(true)}
              className="w-full flex items-center justify-between p-4 bg-white/[0.03] border border-white/10 rounded-lg text-white"
            >
              <span className="text-[10px] uppercase tracking-[0.2em] font-bold">
                {tabs.find(t => t.id === activeTab)?.label || 'Menu'}
              </span>
              <Menu className="w-4 h-4 text-white/60" />
            </button>

            {/* Mobile Drawer Overlay */}
            {isMobileMenuOpen && (
              <div className="fixed inset-0 z-50 flex justify-end">
                <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setIsMobileMenuOpen(false)} />
                <div className="relative w-[280px] bg-[#0a0a0a] border-l border-white/10 h-full flex flex-col animate-in fade-in slide-in-from-right-4 duration-300">
                  <div className="p-6 flex items-center justify-between border-b border-white/10">
                    <span className="text-[10px] uppercase tracking-[0.2em] text-white/40">Navigation</span>
                    <button onClick={() => setIsMobileMenuOpen(false)} className="text-white/60 hover:text-white transition-colors p-2 -mr-2">
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                  <div className="flex flex-col p-4 gap-2 pb-24 overflow-y-auto">
                    {tabs.map((tab) => (
                      <button
                        key={tab.id}
                        onClick={() => {
                          setActiveTab(tab.id as any);
                          setIsMobileMenuOpen(false);
                        }}
                        className={cn(
                          "text-left px-5 py-4 text-[10px] uppercase tracking-[0.2em] transition-colors rounded-sm",
                          activeTab === tab.id
                            ? "border-l-2 border-white text-white opacity-100 bg-white/[0.03] pl-[18px]"
                            : "border-transparent text-white opacity-40 hover:opacity-80 hover:bg-white/[0.02]"
                        )}
                      >
                        {tab.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>

          <nav className="hidden md:flex gap-2 mb-10 border-b border-white/10 pb-px overflow-x-auto snap-x scrollbar-hide -mx-4 px-4 md:mx-0 md:px-0">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={cn(
                  "shrink-0 px-5 py-3 text-[10px] uppercase tracking-[0.2em] transition-colors border-b-2 -mb-[1px] snap-start",
                  activeTab === tab.id
                    ? "border-white text-white opacity-100 bg-white/[0.02]"
                    : "border-transparent text-white opacity-40 hover:opacity-80 hover:bg-white/[0.02]"
                )}
              >
                {tab.label}
              </button>
            ))}
          </nav>
          
          <main>
            {activeTab === 'dash' && <Dashboard />}
            {activeTab === 'edge' && <MyEdge />}
            {activeTab === 'check' && <Checklist />}
            {activeTab === 'calc' && <Calculator />}
            {activeTab === 'journal' && <Journal />}
            {activeTab === 'settings' && <Settings />}
          </main>

          <footer className="h-20 mt-16 border-t border-white/5 flex flex-col md:flex-row items-center justify-between text-[10px] text-white/30 tracking-widest uppercase">
            <div>© 2026 Enterprise Systems | FP Phase 2.v4</div>
            <div className="mt-2 md:mt-0">Local Encryption Active</div>
          </footer>
        </div>
      </div>
    </StoreProvider>
  );
}

function LockBanner() {
  const { state } = useStore();
  
  if (!state.lock) return null;
  
  const exp = state.lockUntil ? new Date(new Date(state.lockUntil).getTime() + 3 * 3600 * 1000) : null;
  const expStr = exp ? exp.toUTCString().slice(17, 22) + ' EAT' : 'tomorrow';

  return (
    <div className="bg-[#A32D2D]/10 border border-[#A32D2D]/30 p-6 mb-10 border-l-[3px] border-l-[#A32D2D] animate-in fade-in slide-in-from-top-2">
      <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-[#A32D2D] mb-3">
        System Lock Active
      </div>
      <div className="text-xs font-mono text-red-500/80 leading-relaxed">
        Double critical SL condition met. Execution engine locked — resumes ~{expStr}. Charting & local nodes neutralized.
      </div>
    </div>
  );
}
