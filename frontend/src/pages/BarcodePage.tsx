
// React
import { useState, useEffect } from "react";

// Services
import pengaturanService from "../services/pengaturanService";

// UI Components
import {
  Card,
  Flex,
  Grid,
  Text,
  Button,
  Dialog,
  IconButton,
} from "@radix-ui/themes";

// Icons
import {
  QrCode,
  Download,
  RefreshCw,
  Copy,
  Check,
  Calendar,
  Users,
  Maximize2,
  X,
  AlertTriangle,
} from "lucide-react";
import { Link } from "react-router-dom";

export default function BarcodePage() {
  // ============ State Management ============
  const [currentQR, setCurrentQR] = useState("");
  const [copied, setCopied] = useState(false);
  const [loading, setLoading] = useState(false);
  const [qrHistory, setQrHistory] = useState<Array<{id: string, type: string, timestamp: string, qrData: string, expiresAt: string}>>([]);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [isMaximized, setIsMaximized] = useState(false);
  const [error, setError] = useState("");
  const [qrExpiresAt, setQrExpiresAt] = useState("");

  // ============ QR Code Generation for Attendance ============
  const generateAttendanceQR = async () => {
    setLoading(true);
    setError("");
    try {
      // Call backend API to generate QR code (masuk only)
      const response = await pengaturanService.generateQRCode();
      
      if (response.success && response.data) {
        // Convert base64 to data URL for display
        const qrCodeDataURL = `data:image/png;base64,${response.data.qrCode}`;
        setCurrentQR(qrCodeDataURL);
        setQrExpiresAt(response.data.expiresAt);
        
        // Add to history
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

  // ============ Auto Refresh QR Code ============
  useEffect(() => {
    if (autoRefresh) {
      const interval = setInterval(() => {
        if (currentQR) {
          generateAttendanceQR();
        }
      }, 5 * 60 * 1000); // Refresh every 5 minutes

      return () => clearInterval(interval);
    }
  }, [autoRefresh, currentQR]);

  // ============ Copy to Clipboard ============
  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
    }
  };

  // ============ Download QR Code ============
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
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex justify-between items-center">
        <Flex direction="column">
          <h1 className="text-3xl font-bold text-gray-900">QR Code Absensi</h1>
          <p className="text-gray-600">
            Generate QR code untuk absensi peserta magang
          </p>
        </Flex>
      </div>

      {/* Error Message */}
      {error && (
        <Card className="p-4 bg-red-50 border border-red-200">
          <Flex align="center" gap="2">
            <AlertTriangle className="h-5 w-5 text-red-600" />
            <Text color="red" weight="medium">{error}</Text>
            <Button 
              variant="ghost" 
              size="1" 
              onClick={() => setError("")}
              className="ml-auto"
            >
              <X className="h-4 w-4" />
            </Button>
          </Flex>
        </Card>
      )}


      {/* Main QR Code Display */}
      <Grid columns={{ initial: "1", lg: "3" }} gap="6">
        {/* QR Code Generator */}
        <Card className="p-6 lg:col-span-2">
          <Flex direction="column" gap="4">
            <Flex align="center" gap="3" justify="between">
              <Flex align="center" gap="3">
                <div className="p-3 rounded-lg bg-green-100">
                  <QrCode className="h-6 w-6 text-green-600" />
                </div>
                <Flex direction="column">
                  <Text size="4" weight="bold">
                    QR Code Masuk
                  </Text>
                  <Text size="2" color="gray">
                    Untuk scan di handphone peserta magang
                  </Text>
                </Flex>
              </Flex>
              <Flex align="center" gap="3">
                <div className="flex items-center gap-2">
                  <div className={`w-2 h-2 rounded-full ${autoRefresh ? "bg-green-500 animate-pulse" : "bg-gray-400"}`}></div>
                  <Text size="1" color="gray">
                    {autoRefresh ? "Auto Refresh" : "Manual"}
                  </Text>
                </div>
                {currentQR && (
                  <IconButton
                    variant="ghost"
                    size="2"
                    onClick={() => setIsMaximized(true)}
                    title="Maximize QR Code"
                  >
                    <Maximize2 className="h-4 w-4" />
                  </IconButton>
                )}
              </Flex>
            </Flex>

            {/* QR Code Display */}
            <div className="bg-white border-2 border-gray-200 rounded-lg p-8 text-center">
              {currentQR ? (
                <div className="space-y-4">
                  <img
                    src={currentQR}
                    alt="QR Code Absensi"
                    className="mx-auto border border-gray-200 rounded-lg shadow-sm"
                    style={{ maxWidth: "300px", width: "100%" }}
                  />
                  <div className="space-y-1">
                    <Text size="2" color="gray">
                      Scan dengan aplikasi kamera handphone
                    </Text>
                    {qrExpiresAt && (
                      <Text size="1" color="gray">
                        Berlaku hingga: {new Date(qrExpiresAt).toLocaleString("id-ID")}
                      </Text>
                    )}
                  </div>
                </div>
              ) : (
                <Flex direction="column" justify="center">
                  <QrCode className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                  <Text size="3" color="gray" weight="medium">
                    Belum ada QR Code
                  </Text>
                  <Text size="2" color="gray">
                    Klik tombol generate untuk membuat QR code
                  </Text>
                </Flex>
              )}
            </div>

            {/* Action Buttons */}
            <Flex gap="3">
              <Button
                onClick={() => generateAttendanceQR()}
                disabled={loading}
                className="flex-1"
                size="3"
              >
                {loading ? (
                  <Flex align="center" gap="2">
                    <RefreshCw className="h-4 w-4 animate-spin" />
                    Generating...
                  </Flex>
                ) : (
                  <Flex align="center" gap="2">
                    <QrCode className="h-4 w-4" />
                    Generate QR Code
                  </Flex>
                )}
              </Button>
              
              {currentQR && (
                <>
                  <Button
                    onClick={downloadQR}
                    variant="outline"
                    size="3"
                  >
                    <Download className="h-4 w-4" />
                    Download
                  </Button>
                  <Button
                    onClick={() => copyToClipboard(currentQR)}
                    variant="outline"
                    size="3"
                  >
                    {copied ? (
                      <Check className="h-4 w-4 text-green-600" />
                    ) : (
                      <Copy className="h-4 w-4" />
                    )}
                  </Button>
                </>
              )}
            </Flex>
          </Flex>
        </Card>

        {/* Settings & Info */}
        <Card className="p-6">
          <Flex direction="column" gap="4">
            <Flex align="center" gap="3">
              <div className="p-3 bg-orange-100 rounded-lg">
                <Users className="h-6 w-6 text-orange-600" />
              </div>
              <Flex direction="column">
                <Text size="4" weight="bold">
                  Pengaturan
                </Text>
                <Text size="2" color="gray">
                  Kontrol QR code
                </Text>
              </Flex>
            </Flex>

            <div className="space-y-4">
              {/* Auto Refresh Toggle */}
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <Flex direction="column">
                  <Text size="2" weight="medium">Auto Refresh</Text>
                  <Text size="1" color="gray">Refresh setiap 5 menit</Text>
                </Flex>
                <button
                  onClick={() => setAutoRefresh(!autoRefresh)}
                  className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                    autoRefresh ? 'bg-blue-600' : 'bg-gray-300'
                  }`}
                >
                  <span
                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                      autoRefresh ? 'translate-x-6' : 'translate-x-1'
                    }`}
                  />
                </button>
              </div>

              {/* Current QR Info */}
              {currentQR && (
                <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg">
                  <Text size="2" weight="medium" className="text-blue-800 block mb-2">
                    QR Code Aktif
                  </Text>
                  <div className="space-y-1 text-sm text-blue-700">
                    <div>Type: Absen Masuk</div>
                    <div>Berlaku: 5 menit</div>
                    <div>Lokasi: ICONNET Office</div>
                  </div>
                </div>
              )}

              {/* Instructions */}
              <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
                <Text size="2" weight="medium" className="text-green-800 block mb-2">
                  Cara Penggunaan
                </Text>
                <ul className="text-sm text-green-700 space-y-1">
                  <li>1. Generate QR code</li>
                  <li>2. Peserta scan dengan HP</li>
                  <li>3. QR code valid 5 menit</li>
                  <li>4. Auto refresh tersedia</li>
                </ul>
              </div>
            </div>
          </Flex>
        </Card>
      </Grid>

      {/* QR History */}
      {qrHistory.length > 0 && (
        <Card className="p-6">
          <Flex direction="column" gap="4">
            <Flex align="center" gap="3">
              <div className="p-3 bg-purple-100 rounded-lg">
                <Calendar className="h-6 w-6 text-purple-600" />
              </div>
              <Flex direction="column">
                <Text size="4" weight="bold">
                  Riwayat QR Code
                </Text>
                <Text size="2" color="gray">
                  QR code yang telah dibuat hari ini
                </Text>
              </Flex>
            </Flex>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-64 overflow-y-auto">
              {qrHistory.map((item, index) => (
                <div
                  key={item.id}
                  className="p-4 bg-gray-50 rounded-lg border border-gray-200 hover:bg-gray-100 transition-colors"
                >
                  <Flex justify="between" align="center" className="mb-2">
                    <span className="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                      Masuk
                    </span>
                    <Text size="1" color="gray">
                      {new Date(item.timestamp).toLocaleTimeString("id-ID", {
                        hour: '2-digit',
                        minute: '2-digit'
                      })}
                    </Text>
                  </Flex>
                  <Text size="1" color="gray" className="truncate">
                    {item.id}
                    {index}
                  </Text>
                </div>
              ))}
            </div>

            <Button
              onClick={() => setQrHistory([])}
              variant="outline"
              size="2"
            >
            </Button>
          </Flex>
        </Card>
      )}

      {/* Maximize QR Code Dialog */}
      <Dialog.Root open={isMaximized} onOpenChange={setIsMaximized}>
        <Dialog.Content 
          style={{ maxWidth: '90vw', maxHeight: '90vh' }}
          className="p-6"
        >
          <Flex direction="column" gap="4" align="center">
            <Flex justify="between" align="center" width="100%">
              <div>
                <Dialog.Title className="text-xl font-bold">
                  QR Code Masuk
                </Dialog.Title>
                <Dialog.Description className="text-gray-600">
                  Scan dengan kamera handphone untuk absensi
                </Dialog.Description>
              </div>
              <Dialog.Close>
                <IconButton variant="ghost" size="2">
                  <X className="h-4 w-4" />
                </IconButton>
              </Dialog.Close>
            </Flex>
            
            {currentQR && (
              <div className="text-center space-y-4">
                <div className="bg-white p-8 rounded-lg border-2 border-gray-200 shadow-lg">
                  <img
                    src={currentQR}
                    alt="QR Code Absensi"
                    className="mx-auto"
                    style={{ width: "400px", height: "400px" }}
                  />
                </div>
                
                <div className="space-y-2">
                  <div className="inline-flex px-4 py-2 text-sm font-medium rounded-full bg-green-100 text-green-800">
                    Absen Masuk
                  </div>
                  
                  {qrExpiresAt && (
                    <div>
                      <Text size="2" color="gray">
                        Berlaku hingga: {new Date(qrExpiresAt).toLocaleString("id-ID")}
                      </Text>
                    </div>
                  )}
                  
                  <div className="mt-4">
                    <Text size="3" weight="medium" className="text-gray-700">
                      Petunjuk Scan:
                    </Text>
                    <ul className="text-sm text-gray-600 mt-2 space-y-1">
                      <li>• Buka aplikasi kamera handphone</li>
                      <li>• Arahkan kamera ke QR Code</li>
                      <li>• Tunggu notifikasi untuk membuka link</li>
                      <li>• Ikuti instruksi selanjutnya</li>
                    </ul>
                  </div>
                </div>
                
                <Flex gap="3" justify="center">
                  <Button
                    onClick={downloadQR}
                    variant="outline"
                    size="3"
                  >
                    <Download className="h-4 w-4" />
                    Download QR Code
                  </Button>
                  <Button
                    onClick={() => copyToClipboard(currentQR)}
                    variant="outline"
                    size="3"
                  >
                    {copied ? (
                      <>
                        <Check className="h-4 w-4 text-green-600" />
                        Copied!
                      </>
                    ) : (
                      <>
                        <Copy className="h-4 w-4" />
                        Copy Image
                      </>
                    )}
                  </Button>
                </Flex>
              </div>
            )}
          </Flex>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  );
}
