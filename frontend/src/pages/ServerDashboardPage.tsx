import { useEffect, useState, useCallback } from "react";
import { Card, Text, Badge, IconButton, Tooltip } from "@radix-ui/themes";
import {
  Server, Cpu, HardDrive, Activity, Network, Clock, Database,
  ArrowDownCircle, ArrowUpCircle, FileText, Save, RefreshCw
} from "lucide-react";
import serverMonitorService from "../services/serverMonitorService";
import CircularProgress from "../components/CircularProgress";
import type { ServerSpecs, ResourceUsage, CpuNetworkStatus } from "../types/server";

// --- Components Kecil ---

const SpecItemCompact = ({ icon, label, value }: { icon: any, label: string, value: string }) => (
  <div className="flex items-center gap-3 py-1.5 border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors px-1 rounded">
    <div className="text-gray-400 shrink-0 bg-gray-50 p-1.5 rounded-md">
      {icon}
    </div>
    <div className="min-w-0">
      <div className="text-[10px] font-bold text-gray-400 uppercase tracking-wider leading-tight mb-0.5">{label}</div>
      <div className="text-sm font-bold text-gray-700 truncate leading-tight" title={value}>{value}</div>
    </div>
  </div>
);

const NetStatItem = ({ label, value, icon, colorClass }: { label: string, value: string, icon: any, colorClass: string }) => (
  <div className="bg-white border border-gray-100 rounded-xl p-3 flex items-center gap-3 shadow-sm hover:border-blue-100 transition-colors">
    <div className={`p-2 rounded-full ${colorClass}`}>
      {icon}
    </div>
    <div>
      <div className="text-[10px] uppercase font-semibold text-gray-400">{label}</div>
      <div className="text-sm font-bold text-gray-900">{value}</div>
    </div>
  </div>
);

// --- Main Page ---
export default function ServerDashboardPage() {
  const [specs, setSpecs] = useState<ServerSpecs | null>(null);
  const [stats, setStats] = useState<{ resources: ResourceUsage; status: CpuNetworkStatus } | null>(null);

  // Loading state terpisah untuk inisial load dan refresh manual
  const [isInitialLoading, setIsInitialLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // 1. Fungsi Fetch Data yang reusable
  const fetchData = useCallback(async (isManual = false) => {
    if (isManual) setIsRefreshing(true);

    try {
      // Fetch parallel agar lebih cepat
      const [specsData, statsData] = await Promise.all([
        // Specs hanya perlu diambil jika belum ada (atau mau refresh total)
        !specs || isManual ? serverMonitorService.getServerSpecs() : Promise.resolve(specs),
        serverMonitorService.getRealtimeStats()
      ]);

      if (specsData) setSpecs(specsData);
      setStats(statsData);
    } catch (e) {
      console.error("Gagal memuat data server:", e);
    } finally {
      setIsInitialLoading(false);
      if (isManual) setIsRefreshing(false);
    }
  }, [specs]); // Dependency specs agar tidak re-fetch specs jika tidak perlu (kecuali manual)

  // 2. useEffect untuk Auto-Refresh Interval
  useEffect(() => {
    // Load pertama kali
    fetchData();

    // Auto refresh setiap 15 detik (Jauh lebih hemat resource daripada 3 detik)
    const interval = setInterval(() => {
      fetchData(false);
    }, 15000);

    return () => clearInterval(interval);
  }, [fetchData]);

  if (isInitialLoading) {
    return (
      <div className="flex flex-col items-center justify-center h-[60vh] text-gray-400 gap-3">
        <Server className="h-10 w-10 animate-pulse opacity-50" />
        <p className="text-sm font-medium">Menghubungkan ke Server...</p>
      </div>
    );
  }

  // Safety check jika data null setelah loading
  if (!specs || !stats) return null;

  return (
    <div className="space-y-5 pb-10 animate-in fade-in duration-500">

      {/* Header dengan Tombol Refresh */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">Server Monitor</h1>
          <div className="flex items-center gap-2 mt-0.5">
            <div className={`w-2 h-2 rounded-full ${isRefreshing ? 'bg-yellow-400' : 'bg-green-500'} animate-pulse`}/>
            <Text size="1" color="gray">
              {isRefreshing ? 'Updating data...' : `Live Connection • ${specs.hostname}`}
            </Text>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <Badge color="gray" variant="soft" className="font-mono text-xs px-2 hidden sm:inline-flex">
            {specs.os}
          </Badge>

          <Tooltip content="Refresh Data">
            <IconButton
              size="2"
              variant="soft"
              color="gray"
              onClick={() => fetchData(true)}
              disabled={isRefreshing}
              className="cursor-pointer"
            >
              <RefreshCw className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} />
            </IconButton>
          </Tooltip>
        </div>
      </div>

      {/* === MAIN GRID LAYOUT === */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-4 items-stretch">

        {/* --- LEFT COLUMN: SPECS --- */}
        <Card className="lg:col-span-1 h-full shadow-sm bg-white p-0 overflow-hidden flex flex-col">
          <div className="p-5 h-full flex flex-col">
            <div className="flex items-center gap-2 mb-6">
              <div className="p-1.5 bg-blue-50 rounded-md">
                <Server className="w-4 h-4 text-blue-600" />
              </div>
              <span className="text-sm font-bold text-gray-800">Spesifikasi</span>
            </div>

            <div className="flex-1 flex flex-col gap-3">
              <SpecItemCompact icon={<Cpu size={16} />} label="Processor" value={specs.cpuModel} />
              <SpecItemCompact icon={<Database size={16} />} label="Memory Total" value={specs.totalRam} />
              <SpecItemCompact icon={<HardDrive size={16} />} label="Storage Total" value={specs.totalStorage} />
              <SpecItemCompact icon={<Activity size={16} />} label="Core Count" value={`${specs.cpuCores} Cores`} />
              <SpecItemCompact icon={<Clock size={16} />} label="System Uptime" value={specs.uptime} />
            </div>
          </div>
        </Card>

        {/* --- RIGHT COLUMN: DASHBOARD CONTENT --- */}
        <div className="lg:col-span-3 flex flex-col gap-4">

           {/* TOP ROW: USAGE */}
           <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Card className="shadow-sm hover:shadow-md transition-shadow flex items-center justify-center py-6">
                 <CircularProgress
                   size={100}
                   percentage={stats.resources.memory.percentage}
                   label="Memory"
                   subLabel={`${stats.resources.memory.used} / ${stats.resources.memory.total} GB`}
                 />
              </Card>
              <Card className="shadow-sm hover:shadow-md transition-shadow flex items-center justify-center py-6">
                 <CircularProgress
                   size={100}
                   percentage={stats.resources.swap.percentage}
                   label="Swap"
                   subLabel={`${stats.resources.swap.used} / ${stats.resources.swap.total} GB`}
                 />
              </Card>
              <Card className="shadow-sm hover:shadow-md transition-shadow flex items-center justify-center py-6">
                 <CircularProgress
                   size={100}
                   percentage={stats.resources.storage.percentage}
                   label="Storage"
                   subLabel={`${stats.resources.storage.used} / ${stats.resources.storage.total} GB`}
                 />
              </Card>
           </div>

           {/* BOTTOM ROW: STATUS */}
           <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 flex-1">

              {/* CPU CARD */}
              <Card className="shadow-sm p-5 flex flex-col justify-center">
                <div className="flex flex-col gap-5">
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2">
                      <div className="p-1.5 bg-purple-50 rounded-md">
                        <Activity className="w-5 h-5 text-purple-600" />
                      </div>
                      <div>
                        <span className="block text-sm font-bold text-gray-800">CPU Load</span>
                      </div>
                    </div>
                    <span className="text-2xl font-black text-purple-600 tracking-tight">{stats.status.cpuLoad}%</span>
                  </div>

                  {/* Progress Bar */}
                  <div className="w-full bg-gray-100 rounded-full h-3 overflow-hidden">
                    <div
                      className="bg-gradient-to-r from-purple-500 to-indigo-600 h-3 rounded-full transition-all duration-700 ease-out"
                      style={{ width: `${stats.status.cpuLoad}%` }}
                    ></div>
                  </div>

                  {/* Load Avg */}
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { l: "1m", v: stats.status.loadAverage[0] },
                      { l: "5m", v: stats.status.loadAverage[1] },
                      { l: "15m", v: stats.status.loadAverage[2] }
                    ].map((item, idx) => (
                      <div key={idx} className="bg-purple-50/40 rounded-lg p-2 text-center border border-purple-100/50">
                        <span className="block text-[10px] font-bold text-purple-400">{item.l}</span>
                        <span className="block text-sm font-bold text-purple-900">{item.v.toFixed(2)}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </Card>

              {/* NETWORK CARD */}
              <Card className="shadow-sm p-4">
                 <div className="flex flex-col gap-4 h-full">
                  <div className="flex items-center gap-2">
                    <div className="p-1.5 bg-blue-50 rounded-md">
                      <Network className="w-5 h-5 text-blue-600" />
                    </div>
                    <span className="font-bold text-gray-800 text-sm">Network & I/O</span>
                  </div>

                  <div className="grid grid-cols-2 gap-3 flex-1 content-center">
                    <NetStatItem
                      label="Down"
                      value={stats.status.network.received}
                      icon={<ArrowDownCircle size={16} />}
                      colorClass="bg-blue-100 text-blue-600"
                    />
                    <NetStatItem
                      label="Up"
                      value={stats.status.network.sent}
                      icon={<ArrowUpCircle size={16} />}
                      colorClass="bg-indigo-100 text-indigo-600"
                    />
                    <NetStatItem
                      label="Read"
                      value={stats.status.diskIo.read}
                      icon={<FileText size={16} />}
                      colorClass="bg-orange-100 text-orange-600"
                    />
                    <NetStatItem
                      label="Write"
                      value={stats.status.diskIo.write}
                      icon={<Save size={16} />}
                      colorClass="bg-red-100 text-red-600"
                    />
                  </div>
                </div>
              </Card>

           </div>
        </div>
      </div>
    </div>
  );
}