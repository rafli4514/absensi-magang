export interface QRCodeData {
  // NOTE:
  // - "masuk" digunakan untuk QR Code Check-In (aktif dipakai sekarang)
  // - "keluar" dipertahankan HANYA untuk kompatibilitas data lama / riwayat lama (tidak lagi digenerate baru)
  type: "masuk" | "keluar";
  timestamp: string;
  location: string;
  validUntil: string;
  sessionId: string;
}

export const generateQRCodeCanvas = (qrData: QRCodeData): string => {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = 300;
  canvas.height = 300;
  
  if (!ctx) {
    throw new Error('Failed to get canvas context');
  }

  // White background
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, 300, 300);
  
  // Create QR-like pattern
  ctx.fillStyle = '#000000';
  const cellSize = 10;
  
  // Generate pseudo-random pattern based on data
  const dataString = JSON.stringify(qrData);
  for (let x = 0; x < 30; x++) {
    for (let y = 0; y < 30; y++) {
      const charCode = dataString.charCodeAt((x * 30 + y) % dataString.length);
      if (charCode % 2 === 0) {
        ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
      }
    }
  }
  
  // Add corner squares (typical QR code markers)
  const cornerSize = 70;
  
  // Top-left corner
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, cornerSize, cornerSize);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(10, 10, cornerSize - 20, cornerSize - 20);
  ctx.fillStyle = '#000000';
  ctx.fillRect(20, 20, cornerSize - 40, cornerSize - 40);
  
  // Top-right corner
  ctx.fillStyle = '#000000';
  ctx.fillRect(300 - cornerSize, 0, cornerSize, cornerSize);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(300 - cornerSize + 10, 10, cornerSize - 20, cornerSize - 20);
  ctx.fillStyle = '#000000';
  ctx.fillRect(300 - cornerSize + 20, 20, cornerSize - 40, cornerSize - 40);
  
  // Bottom-left corner
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 300 - cornerSize, cornerSize, cornerSize);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(10, 300 - cornerSize + 10, cornerSize - 20, cornerSize - 20);
  ctx.fillStyle = '#000000';
  ctx.fillRect(20, 300 - cornerSize + 20, cornerSize - 40, cornerSize - 40);
  
  return canvas.toDataURL();
};

/**
 * Create QR code data for attendance.
 * NOTE:
 * - Saat ini aplikasi hanya meng-generate QR Code untuk "masuk" (check-in).
 * - Parameter "keluar" dipertahankan agar utility ini tetap bisa membaca / menampilkan
 *   data QR lama yang mungkin masih berisi type "keluar" (backward compatibility).
 */
export const createAttendanceQRData = (
  type: "masuk" | "keluar" = "masuk",
  validityMinutes: number = 5
): QRCodeData => {
  const now = new Date();
  return {
    type,
    timestamp: now.toISOString(),
    location: "ICONNET_OFFICE",
    validUntil: new Date(now.getTime() + validityMinutes * 60 * 1000).toISOString(),
    sessionId: `ABSEN_${type.toUpperCase()}_${Date.now()}`
  };
};

export const parseQRCodeData = (qrCodeData: string): QRCodeData | null => {
  try {
    const parsed = JSON.parse(qrCodeData);
    if (parsed.type && parsed.timestamp && parsed.location && parsed.validUntil && parsed.sessionId) {
      return parsed as QRCodeData;
    }
    return null;
  } catch {
    return null;
  }
};

export const isQRCodeValid = (qrData: QRCodeData): boolean => {
  const now = new Date();
  const validUntil = new Date(qrData.validUntil);
  return now <= validUntil;
};

export const formatQRCodeType = (type: "masuk" | "keluar"): string => {
  // Hanya "masuk" yang aktif dipakai untuk generate baru.
  // Jika masih ada data lama dengan "keluar", tetap ditampilkan dengan label yang jelas.
  return type === "masuk" ? "Absen Masuk" : "Absen Keluar (lama)";
};

export const getQRCodeTypeColor = (type: "masuk" | "keluar"): string => {
  return type === "masuk" 
    ? "bg-green-100 text-green-800" 
    : "bg-blue-100 text-blue-800";
};

