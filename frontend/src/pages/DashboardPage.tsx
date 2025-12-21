// React
import { useState, useEffect } from "react";

// Komponen UI
import {
  Card,
  Flex,
  Grid,
  Text,
  IconButton,
  Button,
  Badge,
} from "@radix-ui/themes";

// Ikon
import {
  Users,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  BarChart3,
  ChevronLeft,
  ChevronRight,
  Calendar as CalendarIcon,
  RefreshCw,
  Activity,
  UserCheck,
  UserX,
  LogIn,
  LogOut,
} from "lucide-react";

// Tipe Data
import type { DashboardStats, Absensi } from "../types";

// Layanan
import dashboardService from "../services/dashboardService";

// =====================================
// Komponen Pembantu
// =====================================

// Pie Chart Sederhana menggunakan SVG
const SimplePieChart = ({ percentage }: { percentage: number }) => {
  const radius = 50;
  const stroke = 10;
  const normalizedRadius = radius - stroke / 2;
  const circumference = normalizedRadius * 2 * Math.PI;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  // Tentukan warna berdasarkan persentase
  let strokeColor = "#ef4444"; // red-500
  if (percentage >= 80) strokeColor = "#22c55e"; // green-500
  else if (percentage >= 60) strokeColor = "#eab308"; // yellow-500

  return (
    <div className="relative flex items-center justify-center w-28 h-28">
      <svg
        height="100%"
        width="100%"
        viewBox={`0 0 ${radius * 2} ${radius * 2}`}
        style={{ transform: 'rotate(-90deg)' }}
      >
        {/* Background Circle */}
        <circle
          stroke="#f3f4f6"
          strokeWidth={stroke}
          fill="transparent"
          r={normalizedRadius}
          cx={radius}
          cy={radius}
        />
        {/* Progress Circle */}
        <circle
          stroke={strokeColor}
          strokeWidth={stroke}
          strokeDasharray={circumference + ' ' + circumference}
          style={{ strokeDashoffset, transition: 'stroke-dashoffset 1s ease-in-out' }}
          strokeLinecap="round"
          fill="transparent"
          r={normalizedRadius}
          cx={radius}
          cy={radius}
        />
      </svg>
      {/* Teks Tengah */}
      <div className="absolute inset-0 flex items-center justify-center">
        <Text size="4" weight="bold" style={{ color: strokeColor }}>
          {percentage.toFixed(0)}%
        </Text>
      </div>
    </div>
  );
};

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    VALID: { color: "green", label: "Tepat Waktu" },
    TERLAMBAT: { color: "orange", label: "Terlambat" },
    INVALID: { color: "red", label: "Invalid" },
  };

  const config = statusConfig[status] || { color: "gray", label: status };

  return (
    <Badge color={config.color as any} size="1" variant="soft" radius="full">
      {config.label}
    </Badge>
  );
};

const TypeBadge = ({ tipe }: { tipe: Absensi["tipe"] }) => {
  const typeConfig = {
    MASUK: { color: "blue", label: "Masuk" },
    KELUAR: { color: "purple", label: "Keluar" },
    IZIN: { color: "orange", label: "Izin" },
    SAKIT: { color: "red", label: "Sakit" },
    CUTI: { color: "green", label: "Cuti" },
  };

  const config = typeConfig[tipe] || { color: "gray", label: tipe };

  return (
    <Badge color={config.color as any} size="1" variant="outline">
      {config.label}
    </Badge>
  );
};

// =====================================
// Hook Kustom
// =====================================

const useDashboardData = () => {
  const [selectedDate, setSelectedDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );
  const [stats, setStats] = useState<DashboardStats>({
    totalPesertaMagang: 0,
    pesertaMagangAktif: 0,
    absensiMasukHariIni: 0,
    absensiKeluarHariIni: 0,
    tingkatKehadiran: 0,
    aktivitasBaruBaruIni: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchStats = async (isRefresh = false, date?: string) => {
    try {
      if (isRefresh) setRefreshing(true);
      else setLoading(true);

      setError(null);
      const targetDate = date || selectedDate;
      const response = await dashboardService.getDailyStats(targetDate);

      if (response.success && response.data) {
        setStats(response.data);
      } else {
        setError(response.message || 'Gagal memuat data');
      }
    } catch (error: unknown) {
      setError(error instanceof Error ? error.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => { fetchStats(); }, [selectedDate]);

  useEffect(() => {
    const isToday = selectedDate === new Date().toISOString().split('T')[0];
    if (isToday) {
      const interval = setInterval(() => fetchStats(true), 30000);
      return () => clearInterval(interval);
    }
  }, [selectedDate]);

  const goToPreviousDay = () => {
    const d = new Date(selectedDate);
    d.setDate(d.getDate() - 1);
    setSelectedDate(d.toISOString().split('T')[0]);
  };

  const goToNextDay = () => {
    const d = new Date(selectedDate);
    const today = new Date().toISOString().split('T')[0];
    if (selectedDate < today) {
      d.setDate(d.getDate() + 1);
      setSelectedDate(d.toISOString().split('T')[0]);
    }
  };

  return {
    stats, loading, error, refreshing, refresh: () => fetchStats(true),
    selectedDate, setSelectedDate, goToPreviousDay, goToNextDay
  };
};

// =====================================
// Komponen Utama
// =====================================

export default function DashboardPage() {
  const {
    stats, loading, error, refreshing, refresh,
    selectedDate, setSelectedDate, goToPreviousDay, goToNextDay
  } = useDashboardData();

  const isToday = selectedDate === new Date().toISOString().split('T')[0];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[50vh]">
        <div className="text-center">
          <RefreshCw className="h-8 w-8 text-blue-600 animate-spin mx-auto" />
          <p className="mt-2 text-sm text-gray-500">Memuat dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-10">

      {/* Error Alert */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3 flex items-center justify-between text-xs text-red-700">
          <div className="flex items-center gap-2">
            <AlertCircle className="h-4 w-4" />
            <span>{error}</span>
          </div>
          <button onClick={refresh} className="font-bold hover:underline">Retry</button>
        </div>
      )}

      {/* Header & Date Navigation */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">Dashboard</h1>
          <p className="text-xs text-gray-500 mt-0.5">Ringkasan aktivitas dan performa</p>
        </div>

        <div className="flex items-center gap-2 bg-white p-1 rounded-lg border border-gray-200 shadow-sm">
          <IconButton size="1" variant="ghost" color="gray" onClick={goToPreviousDay}>
            <ChevronLeft className="h-4 w-4" />
          </IconButton>

          <div className="flex items-center gap-2 px-2 min-w-[140px] justify-center border-x border-gray-100">
            <CalendarIcon className="h-3.5 w-3.5 text-gray-500" />
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              max={new Date().toISOString().split('T')[0]}
              className="text-xs font-medium text-gray-700 bg-transparent border-none focus:ring-0 p-0 cursor-pointer"
            />
          </div>

          <IconButton
            size="1"
            variant="ghost"
            color="gray"
            onClick={goToNextDay}
            disabled={isToday}
          >
            <ChevronRight className="h-4 w-4" />
          </IconButton>

          {/* Refresh / Live Indicator */}
          <div className="pl-2 border-l border-gray-100">
             <IconButton
               size="1"
               variant={isToday ? "soft" : "ghost"}
               color={isToday ? "green" : "gray"}
               onClick={refresh}
               loading={refreshing}
               title="Refresh Data"
             >
               <RefreshCw className={`h-3.5 w-3.5 ${refreshing ? 'animate-spin' : ''}`} />
             </IconButton>
          </div>
        </div>
      </div>

      {/* Statistik Utama - Compact Grid */}
      <Grid columns={{ initial: "2", md: "4" }} gap="3">
        {/* Total Peserta */}
        <Card className="shadow-sm border border-gray-100">
          <Flex direction="column" p="3" gap="1">
            <Flex justify="between" align="start">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">Total Peserta</Text>
              <div className="p-1 bg-blue-50 rounded text-blue-600"><Users className="h-3.5 w-3.5" /></div>
            </Flex>
            <Text size="6" weight="bold" className="text-gray-900 mt-1">{stats.totalPesertaMagang}</Text>
            <Text size="1" color="gray" className="text-[10px]">Terdaftar dalam sistem</Text>
          </Flex>
        </Card>

        {/* Peserta Aktif */}
        <Card className="shadow-sm border border-gray-100">
          <Flex direction="column" p="3" gap="1">
            <Flex justify="between" align="start">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">Hadir Hari Ini</Text>
              <div className="p-1 bg-green-50 rounded text-green-600"><UserCheck className="h-3.5 w-3.5" /></div>
            </Flex>
            <Text size="6" weight="bold" className="text-gray-900 mt-1">{stats.pesertaMagangAktif}</Text>
            <Text size="1" color="gray" className="text-[10px]">
              {stats.totalPesertaMagang > 0 ? `${Math.round((stats.pesertaMagangAktif / stats.totalPesertaMagang) * 100)}% kehadiran` : '0%'}
            </Text>
          </Flex>
        </Card>

        {/* Absen Masuk */}
        <Card className="shadow-sm border border-gray-100">
          <Flex direction="column" p="3" gap="1">
            <Flex justify="between" align="start">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">Check In</Text>
              <div className="p-1 bg-orange-50 rounded text-orange-600"><LogIn className="h-3.5 w-3.5" /></div>
            </Flex>
            <Text size="6" weight="bold" className="text-gray-900 mt-1">{stats.absensiMasukHariIni}</Text>
            <Text size="1" color="gray" className="text-[10px]">Total scan masuk</Text>
          </Flex>
        </Card>

        {/* Absen Keluar */}
        <Card className="shadow-sm border border-gray-100">
          <Flex direction="column" p="3" gap="1">
            <Flex justify="between" align="start">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">Check Out</Text>
              <div className="p-1 bg-purple-50 rounded text-purple-600"><LogOut className="h-3.5 w-3.5" /></div>
            </Flex>
            <Text size="6" weight="bold" className="text-gray-900 mt-1">{stats.absensiKeluarHariIni}</Text>
            <Text size="1" color="gray" className="text-[10px]">Total scan keluar</Text>
          </Flex>
        </Card>
      </Grid>

      {/* Grid Content: Chart & Activity */}
      <Grid columns={{ initial: "1", md: "3" }} gap="4">

        {/* Kolom Kiri: Tingkat Kehadiran (Pie Chart) */}
        <div className="md:col-span-1 space-y-4">
          <Card className="shadow-sm border border-gray-100 h-full">
            <Flex direction="column" p="3" gap="4" className="h-full">
              <Flex align="center" gap="2" className="border-b border-gray-50 pb-2">
                <BarChart3 className="h-4 w-4 text-gray-500" />
                <Text weight="bold" size="2">Tingkat Kehadiran</Text>
              </Flex>

              <Flex direction="column" align="center" justify="center" gap="4" className="flex-1">
                {/* PIE CHART */}
                <SimplePieChart percentage={stats.tingkatKehadiran} />

                <Text size="1" color="gray" align="center" className="text-[10px] leading-tight max-w-[200px]">
                  {stats.tingkatKehadiran >= 90 ? 'Luar Biasa! Pertahankan performa ini.' :
                   stats.tingkatKehadiran >= 75 ? 'Cukup Baik. Tingkatkan lagi.' : 'Perlu ditingkatkan.'}
                </Text>
              </Flex>

              <div className="space-y-2 pt-3 border-t border-gray-100 mt-auto">
                <Flex justify="between" align="center">
                  <Flex align="center" gap="2">
                    <div className="w-2 h-2 rounded-full bg-green-500"/>
                    <Text size="1" color="gray">Hadir</Text>
                  </Flex>
                  <Text size="1" weight="bold">{Math.round(stats.tingkatKehadiran * stats.pesertaMagangAktif / 100)}</Text>
                </Flex>
                <Flex justify="between" align="center">
                  <Flex align="center" gap="2">
                    <div className="w-2 h-2 rounded-full bg-gray-300"/>
                    <Text size="1" color="gray">Belum Hadir</Text>
                  </Flex>
                  <Text size="1" weight="bold">{Math.max(0, stats.pesertaMagangAktif - Math.round(stats.tingkatKehadiran * stats.pesertaMagangAktif / 100))}</Text>
                </Flex>
              </div>
            </Flex>
          </Card>
        </div>

        {/* Kolom Kanan: Aktivitas Terbaru (2/3) */}
        <div className="md:col-span-2">
          <Card className="shadow-sm border border-gray-100 h-full flex flex-col">
            <Flex justify="between" align="center" p="3" className="border-b border-gray-100 bg-gray-50/50">
              <Flex align="center" gap="2">
                <Activity className="h-4 w-4 text-blue-600" />
                <Text weight="bold" size="2">Aktivitas Terbaru</Text>
              </Flex>
              <Text size="1" color="gray">{stats.aktivitasBaruBaruIni.length} item</Text>
            </Flex>

            <div className="flex-1 overflow-y-auto max-h-[400px] p-0">
              {stats.aktivitasBaruBaruIni.length > 0 ? (
                <div className="divide-y divide-gray-100">
                  {stats.aktivitasBaruBaruIni.map((activity, index) => (
                    <Flex key={index} align="center" gap="3" className="p-3 hover:bg-gray-50 transition-colors">
                      <div className={`p-1.5 rounded-full shrink-0 ${
                        activity.status === "VALID" ? "bg-green-100 text-green-600" :
                        activity.status === "TERLAMBAT" ? "bg-yellow-100 text-yellow-600" :
                        "bg-red-100 text-red-600"
                      }`}>
                        {activity.status === "VALID" ? <CheckCircle size={16} /> :
                         activity.status === "TERLAMBAT" ? <AlertCircle size={16} /> :
                         <XCircle size={16} />}
                      </div>

                      <div className="flex-1 min-w-0">
                        <Flex justify="between" align="start">
                          <Text size="2" weight="bold" className="truncate">
                            {activity.pesertaMagang?.nama || 'Unknown'}
                          </Text>
                          <Text size="1" color="gray" className="shrink-0">
                            {new Date(activity.timestamp).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' })}
                          </Text>
                        </Flex>

                        <Flex align="center" gap="2" mt="1">
                          <TypeBadge tipe={activity.tipe} />
                          <StatusBadge status={activity.status} />
                          {activity.lokasi?.alamat && (
                            <Text size="1" color="gray" className="truncate hidden sm:block max-w-[150px]">
                              • {activity.lokasi.alamat}
                            </Text>
                          )}
                        </Flex>
                      </div>
                    </Flex>
                  ))}
                </div>
              ) : (
                <Flex direction="column" align="center" justify="center" className="py-12 text-gray-400">
                  <Clock className="h-8 w-8 mb-2 opacity-20" />
                  <Text size="2">Belum ada aktivitas tercatat</Text>
                </Flex>
              )}
            </div>
          </Card>
        </div>

      </Grid>
    </div>
  );
}