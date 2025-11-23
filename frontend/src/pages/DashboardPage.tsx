
// React
import { useState, useEffect } from "react";

// Komponen UI
import {
  Card,
  Flex,
  Grid,
  Text,
  Progress,
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
  Calendar,
} from "lucide-react";

// Tipe Data
import type { DashboardStats, Absensi } from "../types";

// Layanan
import dashboardService from "../services/dashboardService";

// Menggunakan API real - data dummy sudah dihapus

// =====================================
// Komponen Pembantu
// =====================================

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    VALID: { color: "bg-green-100 text-green-800", label: "Tepat Waktu" },
    TERLAMBAT: { color: "bg-yellow-100 text-yellow-800", label: "Terlambat" },
    INVALID: { color: "bg-red-100 text-red-800", label: "Tidak Valid" },
  };

  const config = statusConfig[status] || { color: "bg-gray-100 text-gray-800", label: status };

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

const TypeBadge = ({ tipe }: { tipe: Absensi["tipe"] }) => {
  const typeConfig = {
    MASUK: { color: "bg-blue-100 text-blue-800", label: "Masuk" },
    KELUAR: { color: "bg-purple-100 text-purple-800", label: "Keluar" },
    IZIN: { color: "bg-orange-100 text-orange-800", label: "Izin" },
    SAKIT: { color: "bg-red-100 text-red-800", label: "Sakit" },
    CUTI: { color: "bg-green-100 text-green-800", label: "Cuti" },
  };

  const config = typeConfig[tipe] || { color: "bg-gray-100 text-gray-800", label: tipe };

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

// =====================================
// Hook Kustom
// =====================================

const useDashboardData = () => {
  const [selectedDate, setSelectedDate] = useState<string>(
    new Date().toISOString().split('T')[0] // Tanggal hari ini dalam format YYYY-MM-DD
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
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }
      
      setError(null); // Hapus error sebelumnya
      
      const targetDate = date || selectedDate;
      
      // Panggil API dengan parameter tanggal spesifik
      const response = await dashboardService.getDailyStats(targetDate);
      
      if (response.success && response.data) {
        setStats(response.data);
        console.log('Statistik harian dashboard dimuat untuk', targetDate, ':', response.data);
      } else {
        const errorMessage = response.message || 'Gagal memuat statistik dashboard';
        setError(errorMessage);
        console.error('Error API Dashboard:', errorMessage);
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Gagal memuat statistik dashboard';
      console.error('Error statistik dashboard:', error);
      setError(errorMessage);
      
      // Pertahankan data yang ada saat error daripada reset ke nol
      if (stats.totalPesertaMagang === 0) {
        // Hanya set data fallback jika tidak ada data sama sekali
        setStats(prev => ({
          ...prev,
          // Pertahankan nilai non-zero yang ada
        }));
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, [selectedDate]); // Muat ulang saat tanggal berubah

  useEffect(() => {
    // Auto refresh setiap 30 detik hanya jika menampilkan data hari ini
    const isToday = selectedDate === new Date().toISOString().split('T')[0];
    
    if (isToday) {
      const interval = setInterval(() => {
        fetchStats(true);
      }, 30000);
      
      // Refresh saat window kembali fokus
      const handleFocus = () => {
        fetchStats(true);
      };
      
      window.addEventListener('focus', handleFocus);
      
      return () => {
        clearInterval(interval);
        window.removeEventListener('focus', handleFocus);
      };
    }
  }, [selectedDate]);

  const refresh = () => {
    fetchStats(true);
  };

  const changeDate = (newDate: string) => {
    setSelectedDate(newDate);
  };

  const goToPreviousDay = () => {
    const currentDate = new Date(selectedDate);
    currentDate.setDate(currentDate.getDate() - 1);
    setSelectedDate(currentDate.toISOString().split('T')[0]);
  };

  const goToNextDay = () => {
    const currentDate = new Date(selectedDate);
    const today = new Date().toISOString().split('T')[0];
    
    // Jangan izinkan ke tanggal masa depan
    if (selectedDate < today) {
      currentDate.setDate(currentDate.getDate() + 1);
      setSelectedDate(currentDate.toISOString().split('T')[0]);
    }
  };

  const goToToday = () => {
    setSelectedDate(new Date().toISOString().split('T')[0]);
  };

  return { 
    stats, 
    loading, 
    error, 
    refreshing, 
    refresh, 
    selectedDate, 
    changeDate, 
    goToPreviousDay, 
    goToNextDay, 
    goToToday 
  };
};

// =====================================
// Komponen Utama
// =====================================

export default function DashboardPage() {
  // ============ Data ============
  const { 
    stats, 
    loading, 
    error, 
    refreshing, 
    refresh, 
    selectedDate, 
    changeDate, 
    goToPreviousDay, 
    goToNextDay, 
    goToToday 
  } = useDashboardData();

  // State loading yang ditingkatkan
  if (loading) {
    return (
      <div className="space-y-6">
        {/* Skeleton Header Halaman */}
        <div className="flex justify-between items-center">
          <div>
            <div className="h-8 w-48 bg-gray-200 rounded animate-pulse"></div>
            <div className="h-4 w-64 bg-gray-200 rounded animate-pulse mt-2"></div>
          </div>
          <div className="h-4 w-32 bg-gray-200 rounded animate-pulse"></div>
        </div>

        {/* Skeleton Kartu Statistik */}
        <Grid columns={{ initial: "1", md: "2", lg: "4" }} gap="4">
          {[1, 2, 3, 4].map((i) => (
            <Card key={i} className="p-6">
              <div className="space-y-3">
                <div className="w-12 h-12 bg-gray-200 rounded-lg animate-pulse"></div>
                <div className="space-y-2">
                  <div className="h-6 w-16 bg-gray-200 rounded animate-pulse"></div>
                  <div className="h-4 w-24 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </div>
            </Card>
          ))}
        </Grid>

        {/* Skeleton Konten */}
        <div className="space-y-4">
          <Card className="p-6">
            <div className="h-32 bg-gray-200 rounded animate-pulse"></div>
          </Card>
          <Card className="p-6">
            <div className="h-48 bg-gray-200 rounded animate-pulse"></div>
          </Card>
        </div>
      </div>
    );
  }

  // ============ Render ============
  return (
    <div className="space-y-6">
      {/* Peringatan Error */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <AlertCircle className="h-5 w-5 text-red-600 mr-2" />
              <div>
                <h3 className="text-sm font-medium text-red-800">
                  Terjadi kesalahan saat memuat data
                </h3>
                <p className="text-sm text-red-700 mt-1">{error}</p>
              </div>
            </div>
            <button
              onClick={refresh}
              disabled={refreshing}
              className="text-red-600 hover:text-red-800 text-sm font-medium disabled:opacity-50"
            >
              {refreshing ? 'Memuat...' : 'Coba Lagi'}
            </button>
          </div>
        </div>
      )}

      {/* Header Halaman */}
      <div className="flex flex-col gap-4">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Dasbor</h1>
            <p className="text-gray-600">
              Sistem Absensi Iconnet - Data Harian
            </p>
          </div>
          <button
            onClick={refresh}
            disabled={refreshing}
            className="text-blue-600 hover:text-blue-800 text-sm font-medium disabled:opacity-50 flex items-center gap-2 px-3 py-2 border border-blue-200 rounded-lg hover:bg-blue-50"
          >
            <Clock className="h-4 w-4" />
            {refreshing ? 'Memuat...' : 'Muat Ulang Data'}
          </button>
        </div>

        {/* Navigasi Tanggal */}
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div className="flex flex-col sm:flex-row sm:items-center gap-4">
              <div className="flex items-center gap-2">
                <Calendar className="h-5 w-5 text-gray-500" />
                <Text size="3" weight="bold" color="gray">
                  Data untuk:
                </Text>
              </div>
              
              <div className="flex items-center gap-2">
                <button
                  onClick={goToPreviousDay}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                  title="Hari sebelumnya"
                >
                  <ChevronLeft className="h-4 w-4 text-gray-600" />
                </button>
                
                <div className="flex flex-col sm:flex-row sm:items-center gap-2">
                  <input
                    type="date"
                    value={selectedDate}
                    onChange={(e) => changeDate(e.target.value)}
                    max={new Date().toISOString().split('T')[0]}
                    className="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                  <Text size="2" color="gray" className="text-center sm:whitespace-nowrap">
                    ({new Date(selectedDate).toLocaleDateString('id-ID', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })})
                  </Text>
                </div>
                
                <button
                  onClick={goToNextDay}
                  disabled={selectedDate >= new Date().toISOString().split('T')[0]}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  title="Hari berikutnya"
                >
                  <ChevronRight className="h-4 w-4 text-gray-600" />
                </button>
              </div>
            </div>
            
            <div className="flex items-center justify-center lg:justify-end gap-2">
              {selectedDate !== new Date().toISOString().split('T')[0] && (
                <button
                  onClick={goToToday}
                  className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Hari Ini
                </button>
              )}
              {selectedDate === new Date().toISOString().split('T')[0] && (
                <div className="flex items-center gap-1 px-3 py-2 bg-green-100 text-green-800 text-sm font-medium rounded-lg">
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                  Data Langsung
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Kartu Statistik */}
      <Grid columns={{ initial: "1", md: "2", lg: "4" }} gap="4">
        <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
          <Flex direction="column" gap="3">
            <Flex justify="between" align="center">
              <div className="p-3 bg-blue-100 rounded-lg w-fit">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              {refreshing && <div className="w-4 h-4 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>}
            </Flex>
            <div>
              <Text size="5" weight="bold" className="text-gray-900 block mb-1">
                {stats.totalPesertaMagang.toLocaleString('id-ID')}
              </Text>
              <Text size="2" color="gray">
                Total Peserta Magang
              </Text>
              {stats.totalPesertaMagang > 0 && (
                <Text size="1" color="green" className="mt-1 block">
                  ✓ Data tersedia
                </Text>
              )}
            </div>
          </Flex>
        </Card>

        <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
          <Flex direction="column" gap="3">
            <Flex justify="between" align="center">
              <div className="p-3 bg-green-100 rounded-lg w-fit">
                <CheckCircle className="h-6 w-6 text-green-600" />
              </div>
              {refreshing && <div className="w-4 h-4 border-2 border-green-600 border-t-transparent rounded-full animate-spin"></div>}
            </Flex>
            <div>
              <Text size="5" weight="bold" className="text-gray-900 block mb-1">
                {stats.pesertaMagangAktif.toLocaleString('id-ID')}
              </Text>
              <Text size="2" color="gray">
                Peserta Aktif
              </Text>
              <Text size="1" color="gray" className="mt-1 block">
                {stats.totalPesertaMagang > 0 
                  ? `${Math.round((stats.pesertaMagangAktif / stats.totalPesertaMagang) * 100)}% dari total`
                  : 'Tidak ada data'
                }
              </Text>
            </div>
          </Flex>
        </Card>

        <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
          <Flex direction="column" gap="3">
            <Flex justify="between" align="center">
              <div className="p-3 bg-orange-100 rounded-lg w-fit">
                <Clock className="h-6 w-6 text-orange-600" />
              </div>
              {refreshing && <div className="w-4 h-4 border-2 border-orange-600 border-t-transparent rounded-full animate-spin"></div>}
            </Flex>
            <div>
              <Text size="5" weight="bold" className="text-gray-900 block mb-1">
                {stats.absensiMasukHariIni.toLocaleString('id-ID')}
              </Text>
              <Text size="2" color="gray">
                Absen Masuk
              </Text>
              <Text size="1" color="gray" className="mt-1 block">
                {selectedDate === new Date().toISOString().split('T')[0] 
                  ? 'Hari ini' 
                  : new Date(selectedDate).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })
                }
              </Text>
            </div>
          </Flex>
        </Card>

        <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
          <Flex direction="column" gap="3">
            <Flex justify="between" align="center">
              <div className="p-3 bg-purple-100 rounded-lg w-fit">
                <XCircle className="h-6 w-6 text-purple-600" />
              </div>
              {refreshing && <div className="w-4 h-4 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></div>}
            </Flex>
            <div>
              <Text size="5" weight="bold" className="text-gray-900 block mb-1">
                {stats.absensiKeluarHariIni.toLocaleString('id-ID')}
              </Text>
              <Text size="2" color="gray">
                Absen Keluar
              </Text>
              <Text size="1" color="gray" className="mt-1 block">
                {selectedDate === new Date().toISOString().split('T')[0] 
                  ? 'Hari ini' 
                  : new Date(selectedDate).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })
                }
              </Text>
            </div>
          </Flex>
        </Card>
      </Grid>

      {/* Grafik Tingkat Kehadiran */}
      <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
        <Flex direction="column" gap="4">
          <Flex align="center" gap="3" justify="between">
            <Flex align="center" gap="3">
              <div className="p-3 bg-purple-100 rounded-lg">
                <BarChart3 className="h-6 w-6 text-purple-600" />
              </div>
              <Text size="4" weight="bold">
                Tingkat Kehadiran
              </Text>
              <Text size="1" color="gray">
                {selectedDate === new Date().toISOString().split('T')[0] 
                  ? 'Hari ini' 
                  : new Date(selectedDate).toLocaleDateString('id-ID', { 
                      weekday: 'long',
                      day: 'numeric', 
                      month: 'long' 
                    })
                }
              </Text>
            </Flex>
            {refreshing && <div className="w-5 h-5 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></div>}
          </Flex>

          <div>
            <Flex justify="between" mb="2">
              <Text size="2" color="gray">Tingkat Kehadiran</Text>
              <Text size="3" weight="bold" color={stats.tingkatKehadiran >= 80 ? "green" : stats.tingkatKehadiran >= 60 ? "yellow" : "red"}>
                {stats.tingkatKehadiran.toFixed(1)}%
              </Text>
            </Flex>
            <Progress value={stats.tingkatKehadiran} className="h-3" />
            <Text size="1" color="gray" className="mt-2">
              {stats.tingkatKehadiran >= 90 ? 'Luar Biasa! Tingkat kehadiran sangat baik' :
               stats.tingkatKehadiran >= 80 ? 'Bagus! Tingkat kehadiran baik' :
               stats.tingkatKehadiran >= 60 ? 'Cukup. Perlu peningkatan kehadiran' :
               'Kurang. Tingkat kehadiran perlu ditingkatkan'}
            </Text>
          </div>

            <Flex gap="6" wrap="wrap">
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              <Text size="2" color="gray">
                Hadir: {Math.round(stats.tingkatKehadiran * stats.pesertaMagangAktif / 100)} dari {stats.pesertaMagangAktif} orang
              </Text>
            </Flex>
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <Text size="2" color="gray">
                Belum hadir: {Math.max(0, stats.pesertaMagangAktif - Math.round(stats.tingkatKehadiran * stats.pesertaMagangAktif / 100))} orang
              </Text>
            </Flex>
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
              <Text size="2" color="gray">
                Total absen masuk: {stats.absensiMasukHariIni} catatan
              </Text>
            </Flex>
          </Flex>
        </Flex>
      </Card>

      {/* Bagian Dasbor */}
      <Grid columns={{ initial: "1" }} gap="4">
        {/* Aktivitas Terbaru */}
        <Card className={`p-6 transition-opacity duration-200 ${refreshing ? 'opacity-60' : ''}`}>
          <Flex direction="column" gap="4">
            <Flex align="center" gap="3" justify="between">
              <Flex align="center" gap="3">
                <div className="p-3 bg-blue-100 rounded-lg">
                  <Clock className="h-6 w-6 text-blue-600" />
                </div>
                <Flex gap="4" align="center">
                  <Text size="4" weight="bold">
                    Aktivitas
                  </Text>
                  <Text size="1" color="gray">
                    {stats.aktivitasBaruBaruIni.length} aktivitas pada {
                      selectedDate === new Date().toISOString().split('T')[0] 
                        ? 'hari ini' 
                        : new Date(selectedDate).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })
                    }
                  </Text>
                </Flex>
              </Flex>
              {refreshing && <div className="w-5 h-5 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>}
            </Flex>

            <div className="max-h-96 overflow-y-auto">
              {stats.aktivitasBaruBaruIni.length > 0 ? (
                <Flex direction="column" gap="3">
                  {stats.aktivitasBaruBaruIni.map((activity, index) => (
                    <Flex key={activity.id || index} align="center" gap="4" className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                      <div className={`p-2 rounded-lg ${
                        activity.status === "VALID"
                          ? "bg-green-100"
                          : activity.status === "TERLAMBAT"
                          ? "bg-yellow-100"
                          : "bg-red-100"
                      }`}>
                        {activity.status === "VALID" ? (
                          <CheckCircle className="h-4 w-4 text-green-600" />
                        ) : activity.status === "TERLAMBAT" ? (
                          <AlertCircle className="h-4 w-4 text-yellow-600" />
                        ) : (
                          <XCircle className="h-4 w-4 text-red-600" />
                        )}
                      </div>

                      <Flex direction="column" flexGrow="1" gap="1">
                        <Text size="3" weight="bold">
                          {activity.pesertaMagang?.nama || 'Nama tidak tersedia'}
                        </Text>
                        <Flex align="center" gap="2" wrap="wrap">
                          <TypeBadge tipe={activity.tipe} />
                          <Text size="1" color="gray">
                            • {new Date(activity.timestamp).toLocaleTimeString("id-ID", {
                              hour: '2-digit',
                              minute: '2-digit',
                              second: '2-digit'
                            })}
                          </Text>
                          {activity.lokasi?.alamat && (
                            <Text size="1" color="gray">
                              • {activity.lokasi.alamat}
                            </Text>
                          )}
                        </Flex>
                        {activity.catatan && (
                          <Text size="1" color="gray" className="mt-1">
                            Catatan: {activity.catatan}
                          </Text>
                        )}
                      </Flex>

                      <div className="flex flex-col items-end gap-2">
                        <StatusBadge status={activity.status} />
                        <Text size="1" color="gray">
                          {new Date(activity.timestamp).toLocaleDateString("id-ID")}
                        </Text>
                      </div>
                    </Flex>
                  ))}
                </Flex>
              ) : (
                <Flex direction="column" justify="center" className="text-center py-8">
                  <Clock className="h-12 w-12 text-gray-300 mx-auto mb-3" />
                  <Text size="3" color="gray" weight="medium">
                    {selectedDate === new Date().toISOString().split('T')[0] 
                      ? 'Belum ada aktivitas hari ini' 
                      : `Tidak ada aktivitas pada ${new Date(selectedDate).toLocaleDateString('id-ID', { 
                          day: 'numeric', 
                          month: 'long',
                          year: 'numeric'
                        })}`
                    }
                  </Text>
                  <Text size="2" color="gray">
                    {selectedDate === new Date().toISOString().split('T')[0] 
                      ? 'Aktivitas absensi akan muncul di sini'
                      : 'Pilih tanggal lain untuk melihat aktivitas'
                    }
                  </Text>
                </Flex>
              )}
            </div>
          </Flex>
        </Card>
      </Grid>
    </div>
  );
}
