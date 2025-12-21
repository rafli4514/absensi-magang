// React
import { useState, useEffect } from "react";

// Services
import pengaturanService from "../services/pengaturanService";

// UI Components
import {
  Card,
  Flex,
  Text,
  Button,
  Dialog,
  IconButton,
  Badge,
  // Switch,
  // ScrollArea,
} from "@radix-ui/themes";

// Icons
import {
  QrCode,
  Download,
  RefreshCw,
  Copy,
  Check,
  Calendar,
  Maximize2,
  X,
  AlertTriangle,
  History,
  Clock,
  Smartphone,
  Share2
} from "lucide-react";

export default function BarcodePage() {
  // ============ State Management ============
  const [currentQR, setCurrentQR] = useState("");
  const [copied, setCopied] = useState(false);
  const [loading, setLoading] = useState(false);
  const [qrHistory, setQrHistory] = useState([]);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [isMaximized, setIsMaximized] = useState(false);
  const [error, setError] = useState("");
  const [qrExpiresAt, setQrExpiresAt] = useState("");

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

        const newQR = {
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

  // ============ Utilities ============
  const copyToClipboard = async (text) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
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
    // PERUBAHAN 1: Menghapus max-w-5xl mx-auto, diganti w-full
    <div className="space-y-4 w-full h-full p-1">

      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end border-b border-gray-100 pb-4 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Absensi QR Code</h1>
          <p className="text-sm text-gray-500">
            Manajemen kode akses harian peserta magang
          </p>
        </div>
        {/* Error Notification (Inline) */}
        {error && (
          <div role="alert" className="flex items-center gap-2 bg-red-50 text-red-700 px-3 py-1.5 rounded-md text-sm border border-red-200 animate-in fade-in slide-in-from-right-5">
            <AlertTriangle className="h-4 w-4" />
            <span>{error}</span>
            <button onClick={() => setError("")} className="ml-2 hover:text-red-900" aria-label="Close error">
              <X className="h-3 w-3" />
            </button>
          </div>
        )}
      </div>

      <Card className="w-full h-full">
        {/* Main Dashboard Layout */}
        <div className="flex flex-col lg:flex-row h-full min-h-[500px]">

          {/* LEFT COLUMN: Visual QR Display */}
          {/* PERUBAHAN 2: Lebar kolom disesuaikan (lg:w-1/2) agar seimbang di layar lebar */}
          <div className="lg:w-1/2 p-8 bg-gray-50 border-b lg:border-b-0 lg:border-r border-gray-200 flex flex-col items-center justify-center relative">
            {currentQR ? (
              <div className="text-center w-full space-y-6 animate-in zoom-in-95 duration-300">
                <div className="relative group inline-block">
                  <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                    <img
                      src={currentQR}
                      alt="QR Code Absensi Aktif"
                      className="w-56 h-56 md:w-72 md:h-72 object-contain"
                    />
                  </div>
                  {/* Overlay Action */}
                  <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                    <IconButton
                      variant="solid"
                      color="gray"
                      highContrast
                      size="2"
                      onClick={() => setIsMaximized(true)}
                      aria-label="Perbesar tampilan QR Code"
                    >
                      <Maximize2 className="h-4 w-4" />
                    </IconButton>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="inline-flex items-center gap-2 px-4 py-1.5 bg-green-100 text-green-700 rounded-full text-sm font-medium">
                    <div className="w-2 h-2 bg-green-600 rounded-full animate-pulse" />
                    Aktif & Valid
                  </div>
                  {qrExpiresAt && (
                     <p className="text-sm text-gray-500 flex items-center justify-center gap-1.5">
                       <Clock className="h-4 w-4" />
                       Berakhir: {new Date(qrExpiresAt).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' })}
                     </p>
                  )}
                </div>

                <p className="text-gray-500 max-w-sm mx-auto">
                  Scan menggunakan aplikasi mobile untuk melakukan absensi masuk.
                </p>
              </div>
            ) : (
              <div className="text-center space-y-4">
                <div className="bg-white p-6 rounded-full shadow-sm inline-block">
                  <QrCode className="h-12 w-12 text-gray-300" />
                </div>
                <div>
                  <h3 className="text-gray-900 font-medium text-lg">QR Code Belum Dibuat</h3>
                  <p className="text-gray-500">Klik tombol generate di panel kanan untuk memulai sesi</p>
                </div>
              </div>
            )}
          </div>

          {/* RIGHT COLUMN: Controls & History */}
          {/* PERUBAHAN 3: Kolom kanan juga w-1/2 agar proporsional */}
          <div className="lg:w-1/2 p-8 flex flex-col bg-white">

            <div className="flex-1 space-y-8">
              {/* 1. Primary Actions */}
              <div>
                <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2 text-lg">
                  <Smartphone className="h-5 w-5" />
                  Kontrol Sesi
                </h3>

                <Flex gap="3" direction={{ initial: "column", sm: "row" }} className="w-full">
                  <Button
                    onClick={() => generateAttendanceQR()}
                    disabled={loading}
                    size="4"
                    className="flex-1 cursor-pointer"
                  >
                    {loading ? (
                      <>
                        <RefreshCw className="h-5 w-5 animate-spin mr-2" />
                        Generating...
                      </>
                    ) : (
                      <>
                        <QrCode className="h-5 w-5 mr-2" />
                        {currentQR ? "Regenerate QR" : "Generate QR Code"}
                      </>
                    )}
                  </Button>

                  {currentQR && (
                    <div className="flex gap-2">
                       <Button variant="outline" size="4" onClick={downloadQR} aria-label="Download QR Code" className="cursor-pointer">
                         <Download className="h-5 w-5" />
                       </Button>
                       <Button variant="outline" size="4" onClick={() => copyToClipboard(currentQR)} aria-label="Copy QR Code Image" className="cursor-pointer">
                         {copied ? <Check className="h-5 w-5 text-green-600" /> : <Copy className="h-5 w-5" />}
                       </Button>
                    </div>
                  )}
                </Flex>
              </div>

              {/* 2. Settings */}
              <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                <div className="space-y-1">
                  <label htmlFor="auto-refresh" className="text-sm font-medium text-gray-900 cursor-pointer block">Auto Refresh</label>
                  <p className="text-xs text-gray-500">Perbarui QR code setiap 5 menit secara otomatis</p>
                </div>
                <button
                  id="auto-refresh"
                  role="switch"
                  aria-checked={autoRefresh}
                  onClick={() => setAutoRefresh(!autoRefresh)}
                  className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 cursor-pointer ${
                    autoRefresh ? 'bg-blue-600' : 'bg-gray-300'
                  }`}
                >
                  <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    autoRefresh ? 'translate-x-6' : 'translate-x-1'
                  }`} />
                </button>
              </div>

              {/* 3. History */}
              <div className="border-t border-gray-100 pt-6 flex-grow flex flex-col">
                 <div className="flex items-center justify-between mb-4">
                   <h3 className="font-semibold text-gray-900 flex items-center gap-2 text-lg">
                     <History className="h-5 w-5" />
                     Riwayat Hari Ini
                   </h3>
                   {qrHistory.length > 0 && (
                     <Button variant="ghost" color="red" size="2" onClick={() => setQrHistory([])} className="cursor-pointer">
                       Hapus Semua
                     </Button>
                   )}
                 </div>

                 <div className="space-y-3 overflow-y-auto pr-2 custom-scrollbar flex-1 max-h-[300px]">
                    {qrHistory.length === 0 ? (
                      <div className="flex flex-col items-center justify-center py-10 text-gray-400 text-sm border-2 border-dashed border-gray-100 rounded-xl h-full">
                        <History className="h-8 w-8 mb-2 opacity-20" />
                        <p>Belum ada riwayat generate</p>
                      </div>
                    ) : (
                      qrHistory.map((item) => (
                        <div key={item.id} className="flex items-center justify-between p-3 bg-white border border-gray-100 rounded-lg hover:bg-gray-50 transition-colors shadow-sm">
                          <div className="flex items-center gap-4">
                            <div className="bg-purple-50 p-2 rounded-lg">
                              <Calendar className="h-4 w-4 text-purple-600" />
                            </div>
                            <div className="flex flex-col">
                              <span className="text-sm font-medium text-gray-900">Absen Masuk</span>
                              <span className="text-xs text-gray-500 font-mono">ID: {item.id.split('_').pop()}</span>
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
        <Dialog.Content style={{ maxWidth: '600px' }} className="p-0 overflow-hidden rounded-2xl">
          <div className="bg-gray-900 p-10 flex flex-col items-center justify-center text-white relative min-h-[500px]">
            <Dialog.Close className="absolute top-4 right-4 z-10">
              <IconButton variant="ghost" color="gray" radius="full" className="text-white hover:bg-white/20 cursor-pointer">
                 <X className="h-6 w-6" />
              </IconButton>
            </Dialog.Close>

            <h2 className="text-2xl font-bold mb-8">Scan Absensi Masuk</h2>

            <div className="bg-white p-6 rounded-2xl mb-8 shadow-2xl">
              <img
                src={currentQR}
                alt="QR Code Fullscreen"
                className="w-80 h-80 object-contain"
              />
            </div>

            {qrExpiresAt && (
              <div className="flex items-center gap-2 text-gray-300">
                <Clock className="h-4 w-4" />
                <span className="text-lg">Berlaku s.d. {new Date(qrExpiresAt).toLocaleTimeString("id-ID")}</span>
              </div>
            )}
          </div>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  );
}