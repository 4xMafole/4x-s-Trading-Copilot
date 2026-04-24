import React, { useRef, useState } from 'react';
import { useStore } from '../store';
import { Card, CardTitle } from './ui/Card';
import { Input, Label } from './ui/Input';
import { Button } from './ui/Button';
import { cn } from '@/lib/utils';

export function Settings() {
  const { state, updateState, resetToday, resetAll, exportData, importData } = useStore();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [importStatus, setImportStatus] = useState<string>('');

  const handleImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      const success = importData(content);
      setImportStatus(success ? 'Import successful!' : 'Import failed. Invalid file or format.');
      setTimeout(() => setImportStatus(''), 3000);
      if (fileInputRef.current) fileInputRef.current.value = '';
    };
    reader.readAsText(file);
  };

  const handleExport = () => {
    const dataStr = exportData();
    const dataUri = 'data:application/json;charset=utf-8,' + encodeURIComponent(dataStr);
    const exportFileDefaultName = `4x-copilot-backup-${new Date().toISOString().slice(0, 10)}.json`;

    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
  };

  return (
    <div className="space-y-3 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card>
        <CardTitle>Account settings</CardTitle>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div>
            <Label>Starting balance ($)</Label>
            <Input 
              type="number" 
              value={state.balance} 
              onChange={e => updateState({ balance: parseFloat(e.target.value) || 0 })} 
              step="0.01" 
            />
          </div>
          <div>
            <Label>Challenge start date</Label>
            <Input 
              type="date" 
              value={state.startDate} 
              onChange={e => updateState({ startDate: e.target.value })} 
            />
          </div>
        </div>
        
        <div className="mb-4">
          <Label>Cumulative P&L from prior days ($)</Label>
          <Input 
            type="number" 
            value={state.priorPnl} 
            onChange={e => updateState({ priorPnl: parseFloat(e.target.value) || 0 })} 
            step="0.01" 
          />
          <div className="text-[10px] font-mono uppercase tracking-widest text-[#e0e0e0]/40 mt-3 leading-loose">
            Enter the total P&L from all previous challenge days — today's trades are tracked automatically.
          </div>
        </div>

        <div className="flex gap-4 flex-wrap mt-8">
          <Button variant="destructive" onClick={() => { if(confirm('Reset today?')) resetToday(); }}>
            Reset today
          </Button>
          <Button variant="destructive" onClick={() => { if(confirm('Full reset? This will erase all data.')) resetAll(); }}>
            Full reset
          </Button>
        </div>
      </Card>

      <Card>
        <CardTitle>Data Management</CardTitle>
        <div className="text-[11px] font-mono text-white/50 leading-relaxed mb-6">
          Export your data to a JSON file to transfer between devices, or keep as a backup. Import a previously exported file to restore your state.
        </div>
        
        <div className="flex gap-4 flex-wrap items-center">
          <Button onClick={handleExport} variant="outline">
            Export Backup (.json)
          </Button>
          
          <Button onClick={() => fileInputRef.current?.click()} variant="outline">
            Import Backup
          </Button>
          <input 
            type="file" 
            ref={fileInputRef} 
            onChange={handleImport} 
            accept="application/json" 
            className="hidden" 
          />
          
          {importStatus && (
            <span className={cn("text-[10px] font-mono uppercase tracking-widest ml-4", importStatus.includes('success') ? "text-emerald-500" : "text-[#A32D2D]")}>
              {importStatus}
            </span>
          )}
        </div>
      </Card>

      <Card>
        <CardTitle>Storage info</CardTitle>
        <div className="text-[11px] font-mono text-white/40 leading-relaxed max-w-2xl">
          Data is saved to <code className="text-white/60">localStorage</code> in this browser. To keep data safe, use the export function above frequently.
        </div>
      </Card>
    </div>
  );
}
