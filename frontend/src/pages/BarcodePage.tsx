// React
import { useState, useEffect } from "react";

// Services
import pengaturanService from "../services/pengaturanService";

// UI Components
import {
  Card,
  Flex,
  Button,
  Dialog,
  IconButton,
} from "@radix-ui/themes";

// Icons
import {
  QrCode,
  Download,
  RefreshCw,
  Check,
  Maximize2,
  X,
  AlertTriangle,
  History,
  Clock,
  Smartphone,
  Calendar,
  Image as ImageIcon // Import icon Image untuk memperjelas
} from "lucide-react";

interface QrHistoryItem {
  id: string;
  type: string;
  timestamp: string;
  qrData: string;
  expiresAt: string;
}

export default function BarcodePage() {
  // ============ State Management ============
  const [currentQR, setCurrentQR] = useState("");
  const [copied, setCopied] = useState(false);
  const [loading, setLoading] = useState(false);
  const [qrHistory, setQrHistory] = useState<QrHistoryItem[]>([]);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [isMaximized, setIsMaximized] = useState(false);
  const [error, setError] = useState("");
  const [qrExpiresAt, setQrExpiresAt] = useState("");
  const [remainingTime, setRemainingTime] = useState("");

  // ============ QR Code Generation for Attendance ============
  const generateAttendanceQR = async () => {
    setLoading(true);
    setError("");
    try {
      const response = await pengaturanService.generateQRCode();

      if (response.success && response.data) {
        const qrCodeDataURL = `data:image/png;base64,${response.data.qrCode}`;
        setCurrentQR(qrCodeDataURL);
        setQrExpiresAt(response.data.expiresAt);

        const newQR: QrHistoryItem = {
          id: `ABSEN_MASUK_${Date.now()}`,
          type: 'masuk',
          timestamp: new Date().toISOString(),
          qrData: response.data.qrCode,
          expiresAt: response.data.expiresAt
        };
        setQrHistory(prev => [newQR, ...prev.slice(0, 9)]);
      } else {
        throw new Error(response.message || 'Failed to generate QR code');
      }
    } catch (error) {
      console.error('Error generating QR code:', error);
      setError(error instanceof Error ? error.message : 'Gagal membuat QR Code');
    } finally {
      setLoading(false);
    }
  };

  // ============ Auto Refresh Logic ============
  useEffect(() => {
    if (autoRefresh) {
      const interval = setInterval(() => {
        if (currentQR) generateAttendanceQR();
      }, 5 * 60 * 1000);
      return () => clearInterval(interval);
    }
  }, [autoRefresh, currentQR]);

  // ============ Countdown Timer Logic ============
  useEffect(() => {
    if (!qrExpiresAt) {
      setRemainingTime("");
      return;
    }

    const updateTimer = () => {
      const now = new Date().getTime();
      const expiration = new Date(qrExpiresAt).getTime();
      const diff = expiration - now;

      if (diff <= 0) {
        setRemainingTime("00:00");
      } else {
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);
        setRemainingTime(`${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`);
      }
    };

    updateTimer();
    const timerInterval = setInterval(updateTimer, 1000);
    return () => clearInterval(timerInterval);
  }, [qrExpiresAt]);

  // ============ Utilities ============

  // FUNGSI COPY GAMBAR KE CLIPBOARD YANG DIPERBAIKI
  const copyImageToClipboard = async () => {
    if (!currentQR) return;

    try {
      // 1. Fetch gambar dari Data URL
      const response = await fetch(currentQR);
      const blob = await response.blob();

      // 2. Buat ClipboardItem dengan tipe PNG
      const item = new ClipboardItem({ "image/png": blob });

      // 3. Tulis ke clipboard
      await navigator.clipboard.write([item]);

      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error("Gagal menyalin gambar:", error);
      setError("Gagal menyalin gambar. Browser mungkin tidak mendukung fitur ini.");
    }
  };

  const downloadQR = () => {
    if (!currentQR) return;
    const link = document.createElement('a');
    link.download = `qr-code-masuk-${new Date().toISOString().slice(0, 10)}.png`;
    link.href = currentQR;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-4 w-full h-[calc(100vh-8rem)] flex flex-col pb-1">
      {/* Header - Compact */}
      <div className="flex justify-between items-center gap-4 shrink-0">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">QR Code Absensi</h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Manajemen kode akses harian
          </p>
        </div>

        {error && (
          <div role="alert" className="flex items-center gap-2 bg-red-50 text-red-700 px-3 py-1.5 rounded-md text-xs border border-red-200 animate-in fade-in slide-in-from-right-5">
            <AlertTriangle className="h-3.5 w-3.5" />
            <span>{error}</span>
            <button onClick={() => setError("")} className="ml-2 hover:text-red-900 cursor-pointer">
              <X className="h-3 w-3" />
            </button>
          </div>
        )}
      </div>

      {/* Main Content - Full Height Card */}
      <Card className="w-full flex-1 overflow-hidden shadow-sm flex flex-col p-0">
        <div className="flex flex-col lg:flex-row h-full">

          {/* LEFT COLUMN: Visual QR Display */}
          <div className="lg:w-1/2 p-6 bg-gray-50/50 border-b lg:border-b-0 lg:border-r border-gray-200 flex flex-col items-center justify-center relative">
            {currentQR ? (
              <div className="text-center w-full flex flex-col items-center gap-5 animate-in zoom-in-95 duration-300">

                {/* 1. Status Info & Timer (SIDE BY SIDE) */}
                <div className="flex flex-wrap items-center justify-center gap-3">
                  {/* Status Badge */}
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium border border-green-200 shadow-sm">
                    <div className="w-1.5 h-1.5 bg-green-600 rounded-full animate-pulse" />
                    Aktif
                  </div>

                  {/* Timer Badge (With Countdown) */}
                  {qrExpiresAt && (
                     <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-white text-gray-500 rounded-full text-xs font-medium border border-gray-200 shadow-sm">
                       <Clock className="h-3 w-3 text-gray-400" />
                       <span>
                         Berakhir: <span className="text-gray-900 font-semibold">{new Date(qrExpiresAt).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' })}</span>
                         <span className="ml-1.5 text-orange-600 font-mono font-bold">({remainingTime})</span>
                       </span>
                     </div>
                  )}
                </div>

                {/* 2. QR Image Block (DI TENGAH) */}
                <div className="relative group inline-block">
                  <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-200">
                    <img
                      src={currentQR}
                      alt="QR Code Absensi Aktif"
                      className="w-48 h-48 md:w-64 md:h-64 object-contain"
                    />
                  </div>
                  {/* Overlay Action */}
                  <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <IconButton
                      variant="solid"
                      color="gray"
                      highContrast
                      size="2"
                      onClick={() => setIsMaximized(true)}
                      className="cursor-pointer"
                    >
                      <Maximize2 className="h-4 w-4" />
                    </IconButton>
                  </div>
                </div>

                {/* 3. Helper Text (DI BAWAH) */}
                <p className="text-xs text-gray-400 max-w-xs mx-auto">
                  Scan untuk absensi masuk. Kode akan diperbarui otomatis.
                </p>
              </div>
            ) : (
              <div className="text-center space-y-3">
                <div className="bg-white p-4 rounded-full shadow-sm border border-gray-100 inline-block">
                  <QrCode className="h-8 w-8 text-gray-300" />
                </div>
                <div>
                  <h3 className="text-gray-900 font-medium text-sm">QR Code Belum Dibuat</h3>
                  <p className="text-xs text-gray-500">Klik generate untuk memulai sesi</p>
                </div>
              </div>
            )}
          </div>

          {/* RIGHT COLUMN: Controls & History */}
          <div className="lg:w-1/2 p-6 flex flex-col bg-white">
            <div className="flex-1 flex flex-col h-full overflow-hidden">

              {/* 1. Primary Actions */}
              <div className="shrink-0 mb-6">
                <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <Smartphone className="h-4 w-4" />
                  Kontrol Sesi
                </h3>

                <Flex gap="3" direction="column" className="w-full">
                  <Button
                    onClick={() => generateAttendanceQR()}
                    disabled={loading}
                    size="3"
                    className="w-full cursor-pointer bg-blue-600 hover:bg-blue-700 text-white"
                  >
                    {loading ? (
                      <>
                        <RefreshCw className="h-4 w-4 animate-spin mr-2" />
                        Memproses...
                      </>
                    ) : (
                      <>
                        <QrCode className="h-4 w-4 mr-2" />
                        {currentQR ? "Regenerate QR Baru" : "Buat QR Code"}
                      </>
                    )}
                  </Button>

                  {currentQR && (
                    <div className="grid grid-cols-2 gap-3">
                       <Button variant="soft" color="gray" size="2" onClick={downloadQR} className="cursor-pointer">
                         <Download className="h-4 w-4 mr-2" /> Download
                       </Button>
                       {/* Tombol Copy Gambar */}
                       <Button variant="soft" color="gray" size="2" onClick={copyImageToClipboard} className="cursor-pointer">
                         {copied ? <Check className="h-4 w-4 mr-2 text-green-600" /> : <ImageIcon className="h-4 w-4 mr-2" />}
                         {copied ? "Tersalin" : "Salin Gambar"}
                       </Button>
                    </div>
                  )}
                </Flex>
              </div>

              {/* 2. Settings Toggle */}
              <div className="shrink-0 mb-6 flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-100">
                <div className="space-y-0.5">
                  <label htmlFor="auto-refresh" className="text-sm font-medium text-gray-900 cursor-pointer block">Auto Refresh</label>
                  <p className="text-[10px] text-gray-500">Perbarui otomatis tiap 5 menit</p>
                </div>
                <button
                  id="auto-refresh"
                  role="switch"
                  aria-checked={autoRefresh}
                  onClick={() => setAutoRefresh(!autoRefresh)}
                  className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 cursor-pointer ${
                    autoRefresh ? 'bg-blue-600' : 'bg-gray-300'
                  }`}
                >
                  <span className={`inline-block h-3.5 w-3.5 transform rounded-full bg-white transition-transform ${
                    autoRefresh ? 'translate-x-4.5' : 'translate-x-0.5'
                  }`} />
                </button>
              </div>

              {/* 3. History List - Scrollable Area */}
              <div className="flex-1 flex flex-col min-h-0 border-t border-gray-100 pt-4">
                 <div className="flex items-center justify-between mb-3 shrink-0">
                   <h3 className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                     <History className="h-4 w-4" />
                     Riwayat
                   </h3>
                   {qrHistory.length > 0 && (
                     <button onClick={() => setQrHistory([])} className="text-xs text-red-600 hover:text-red-700 font-medium cursor-pointer">
                       Hapus Semua
                     </button>
                   )}
                 </div>

                 <div className="overflow-y-auto pr-1 space-y-2 flex-1">
                    {qrHistory.length === 0 ? (
                      <div className="flex flex-col items-center justify-center h-32 text-gray-400 text-xs border-2 border-dashed border-gray-100 rounded-lg">
                        <History className="h-6 w-6 mb-1 opacity-20" />
                        <p>Belum ada riwayat</p>
                      </div>
                    ) : (
                      qrHistory.map((item) => (
                        <div key={item.id} className="flex items-center justify-between p-2.5 bg-white border border-gray-100 rounded-md hover:bg-gray-50 transition-colors">
                          <div className="flex items-center gap-3">
                            <div className="bg-purple-50 p-1.5 rounded-md">
                              <Calendar className="h-3.5 w-3.5 text-purple-600" />
                            </div>
                            <div className="flex flex-col">
                              <span className="text-xs font-medium text-gray-900">Absen Masuk</span>
                              <span className="text-[10px] text-gray-500 font-mono tracking-tight">ID: {item.id.split('_').pop()}</span>
                            </div>
                          </div>
                          <div className="text-right">
                             <span className="block text-xs font-medium text-gray-900">
                               {new Date(item.timestamp).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' })}
                             </span>
                             <span className="text-[10px] text-gray-400">WIB</span>
                          </div>
                        </div>
                      ))
                    )}
                 </div>
              </div>

            </div>
          </div>
        </div>
      </Card>

      {/* Fullscreen Dialog */}
      <Dialog.Root open={isMaximized} onOpenChange={setIsMaximized}>
        <Dialog.Content style={{ maxWidth: '500px' }} className="p-0 overflow-hidden rounded-xl">
          <div className="bg-gray-900 p-8 flex flex-col items-center justify-center text-white relative min-h-[450px]">
            <Dialog.Close className="absolute top-4 right-4 z-10">
              <IconButton variant="ghost" color="gray" radius="full" className="text-white hover:bg-white/20 cursor-pointer">
                 <X className="h-5 w-5" />
              </IconButton>
            </Dialog.Close>

            <h2 className="text-xl font-bold mb-6">Scan Absensi Masuk</h2>

            {qrExpiresAt && (
              <div className="flex items-center gap-3 text-gray-400 text-sm mb-4 bg-white/10 px-4 py-1.5 rounded-full">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                  <span className="text-green-400 font-medium">Aktif</span>
                </div>
                <div className="h-3 w-px bg-gray-600" />
                <div className="flex items-center gap-1.5">
                  <Clock className="h-3.5 w-3.5" />
                  <span>Berakhir {new Date(qrExpiresAt).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' })} <span className="text-orange-400 font-mono ml-1">({remainingTime})</span></span>
                </div>
              </div>
            )}

            <div className="bg-white p-4 rounded-xl mb-6 shadow-2xl">
              <img
                src={currentQR}
                alt="QR Code Fullscreen"
                className="w-64 h-64 object-contain"
              />
            </div>
          </div>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  );
}