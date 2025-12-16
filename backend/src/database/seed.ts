import {
  PrismaClient,
  Role,
  StatusPeserta,
  TipeAbsensi,
  StatusAbsensi,
  TipeIzin,
  StatusPengajuan,
  ActivityType,
  ActivityStatus,
} from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seeding...");

  // Hash password
  const hashedPassword = await bcrypt.hash("password123", 10);
  const hashedAdminPassword = await bcrypt.hash("admin123", 10);

  // === CREATE ADMIN USER ===
  const adminUser = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: hashedAdminPassword,
      role: Role.ADMIN,
      isActive: true,
    },
  });
  console.log("✅ Admin user created:", adminUser.username);

  // === CREATE PEMBIMBING MAGANG USER ===
  const pembimbingUser = await prisma.user.upsert({
    where: { username: "pembimbing" },
    update: {},
    create: {
      username: "pembimbing",
      password: hashedPassword,
      role: Role.PEMBIMBING_MAGANG,
      isActive: true,
    },
  });
  console.log("✅ Pembimbing Magang user created:", pembimbingUser.username);

  // === CREATE PESERTA MAGANG USERS ===
  const peserta1User = await prisma.user.upsert({
    where: { username: "ahmad123" },
    update: {},
    create: {
      username: "ahmad123",
      password: hashedPassword,
      role: Role.PESERTA_MAGANG,
      isActive: true,
    },
  });

  const peserta2User = await prisma.user.upsert({
    where: { username: "siti456" },
    update: {},
    create: {
      username: "siti456",
      password: hashedPassword,
      role: Role.PESERTA_MAGANG,
      isActive: true,
    },
  });

  const peserta3User = await prisma.user.upsert({
    where: { username: "budi789" },
    update: {},
    create: {
      username: "budi789",
      password: hashedPassword,
      role: Role.PESERTA_MAGANG,
      isActive: true,
    },
  });

  console.log("✅ Peserta Magang users created");

  // === CREATE PESERTA MAGANG PROFILES ===
  const peserta1 = await prisma.pesertaMagang.upsert({
    where: { username: "ahmad123" },
    update: {},
    create: {
      nama: "Ahmad Rizki Pratama",
      username: "ahmad123",
      id_peserta_magang: "1234567890",
      divisi: "IT Development",
      instansi: "Universitas Indonesia",
      id_instansi: "UI-2024-001",
      nomorHp: "081234567890",
      tanggalMulai: "2024-12-01",
      tanggalSelesai: "2025-06-30",
      status: StatusPeserta.AKTIF,
      userId: peserta1User.id,
    },
  });

  const peserta2 = await prisma.pesertaMagang.upsert({
    where: { username: "siti456" },
    update: {},
    create: {
      nama: "Siti Nurhaliza",
      username: "siti456",
      id_peserta_magang: "2345678901",
      divisi: "Marketing & Communication",
      instansi: "Universitas Gadjah Mada",
      id_instansi: "UGM-2024-002",
      nomorHp: "081234567891",
      tanggalMulai: "2024-12-01",
      tanggalSelesai: "2025-06-30",
      status: StatusPeserta.AKTIF,
      userId: peserta2User.id,
    },
  });

  const peserta3 = await prisma.pesertaMagang.upsert({
    where: { username: "budi789" },
    update: {},
    create: {
      nama: "Budi Santoso",
      username: "budi789",
      id_peserta_magang: "3456789012",
      divisi: "Finance & Accounting",
      instansi: "Institut Teknologi Bandung",
      id_instansi: "ITB-2024-003",
      nomorHp: "081234567892",
      tanggalMulai: "2024-11-15",
      tanggalSelesai: "2025-05-15",
      status: StatusPeserta.AKTIF,
      userId: peserta3User.id,
    },
  });

  console.log("✅ Peserta Magang profiles created");

  // === CREATE ABSENSI RECORDS ===
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  const lastWeek = new Date(today);
  lastWeek.setDate(lastWeek.getDate() - 7);

  // Absensi untuk peserta 1 (hari ini dan kemarin)
  await prisma.absensi.createMany({
    data: [
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeAbsensi.MASUK,
        timestamp: yesterday.toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_001",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.100",
        device: "Mobile App - Android",
      },
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeAbsensi.KELUAR,
        timestamp: new Date(
          yesterday.getTime() + 8 * 60 * 60 * 1000
        ).toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_002",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.100",
        device: "Mobile App - Android",
      },
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeAbsensi.MASUK,
        timestamp: today.toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_003",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.101",
        device: "Mobile App - Android",
      },
      // Absensi minggu lalu
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeAbsensi.MASUK,
        timestamp: lastWeek.toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_004",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.102",
        device: "Mobile App - Android",
      },
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeAbsensi.KELUAR,
        timestamp: new Date(
          lastWeek.getTime() + 8 * 60 * 60 * 1000
        ).toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_005",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.102",
        device: "Mobile App - Android",
      },
    ],
    skipDuplicates: true,
  });

  // Absensi untuk peserta 2
  await prisma.absensi.createMany({
    data: [
      {
        pesertaMagangId: peserta2.id,
        tipe: TipeAbsensi.MASUK,
        timestamp: yesterday.toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_006",
        status: StatusAbsensi.TERLAMBAT,
        ipAddress: "192.168.1.103",
        device: "Mobile App - iOS",
      },
      {
        pesertaMagangId: peserta2.id,
        tipe: TipeAbsensi.KELUAR,
        timestamp: new Date(
          yesterday.getTime() + 7 * 60 * 60 * 1000
        ).toISOString(),
        lokasi: {
          latitude: -6.2088,
          longitude: 106.8456,
          address: "PT PLN Icon Plus, Jakarta",
        },
        qrCodeData: "QR_SAMPLE_007",
        status: StatusAbsensi.VALID,
        ipAddress: "192.168.1.103",
        device: "Mobile App - iOS",
      },
    ],
    skipDuplicates: true,
  });

  console.log("✅ Absensi records created");

  // === CREATE PENGAJUAN IZIN ===
  await prisma.pengajuanIzin.createMany({
    data: [
      {
        pesertaMagangId: peserta1.id,
        tipe: TipeIzin.SAKIT,
        tanggalMulai: "2024-12-10",
        tanggalSelesai: "2024-12-10",
        alasan: "Demam tinggi dan perlu istirahat untuk pemulihan",
        status: StatusPengajuan.PENDING,
        dokumenPendukung: "surat-keterangan-dokter.pdf",
      },
      {
        pesertaMagangId: peserta2.id,
        tipe: TipeIzin.IZIN,
        tanggalMulai: "2024-12-15",
        tanggalSelesai: "2024-12-15",
        alasan: "Menghadiri acara keluarga penting",
        status: StatusPengajuan.DISETUJUI,
        disetujuiOleh: adminUser.id,
        disetujuiPada: new Date().toISOString(),
        catatan: "Izin disetujui. Pastikan untuk catch up pekerjaan yang tertunda.",
      },
      {
        pesertaMagangId: peserta3.id,
        tipe: TipeIzin.CUTI,
        tanggalMulai: "2024-12-20",
        tanggalSelesai: "2024-12-22",
        alasan: "Cuti tahunan yang sudah direncanakan sebelumnya",
        status: StatusPengajuan.PENDING,
      },
    ],
    skipDuplicates: true,
  });

  console.log("✅ Pengajuan izin records created");

  // === CREATE LOGBOOK RECORDS ===
  const logbookData = [
    // Logbook untuk peserta 1 (minggu ini dan minggu lalu)
    {
      pesertaMagangId: peserta1.id,
      tanggal: today.toISOString().split("T")[0],
      kegiatan: "Meeting Sprint Planning",
      deskripsi: "Membahas rencana sprint untuk 2 minggu ke depan bersama tim development",
      durasi: "2 jam",
      type: ActivityType.MEETING,
      status: ActivityStatus.COMPLETED,
    },
    {
      pesertaMagangId: peserta1.id,
      tanggal: yesterday.toISOString().split("T")[0],
      kegiatan: "Training React Native",
      deskripsi: "Mengikuti training React Native untuk memahami dasar-dasar mobile development",
      durasi: "4 jam",
      type: ActivityType.TRAINING,
      status: ActivityStatus.COMPLETED,
    },
    {
      pesertaMagangId: peserta1.id,
      tanggal: lastWeek.toISOString().split("T")[0],
      kegiatan: "Project Presentation",
      deskripsi: "Presentasi progress project aplikasi absensi kepada pembimbing",
      durasi: "1 jam",
      type: ActivityType.PRESENTATION,
      status: ActivityStatus.COMPLETED,
    },
    {
      pesertaMagangId: peserta1.id,
      tanggal: new Date(today.getTime() + 24 * 60 * 60 * 1000)
        .toISOString()
        .split("T")[0],
      kegiatan: "Code Review",
      deskripsi: "Review kode untuk fitur baru yang sedang dikembangkan",
      durasi: "3 jam",
      type: ActivityType.OTHER,
      status: ActivityStatus.IN_PROGRESS,
    },
    // Logbook untuk peserta 2
    {
      pesertaMagangId: peserta2.id,
      tanggal: today.toISOString().split("T")[0],
      kegiatan: "Content Planning",
      deskripsi: "Membuat konten untuk media sosial perusahaan",
      durasi: "5 jam",
      type: ActivityType.OTHER,
      status: ActivityStatus.IN_PROGRESS,
    },
    {
      pesertaMagangId: peserta2.id,
      tanggal: yesterday.toISOString().split("T")[0],
      kegiatan: "Marketing Meeting",
      deskripsi: "Koordinasi dengan tim marketing untuk kampanye bulan depan",
      durasi: "2 jam",
      type: ActivityType.MEETING,
      status: ActivityStatus.COMPLETED,
    },
    // Logbook untuk peserta 3
    {
      pesertaMagangId: peserta3.id,
      tanggal: today.toISOString().split("T")[0],
      kegiatan: "Financial Report",
      deskripsi: "Menyusun laporan keuangan bulanan",
      durasi: "6 jam",
      type: ActivityType.OTHER,
      status: ActivityStatus.PENDING,
    },
    {
      pesertaMagangId: peserta3.id,
      tanggal: lastWeek.toISOString().split("T")[0],
      kegiatan: "Budget Planning Training",
      deskripsi: "Training perencanaan anggaran untuk departemen",
      durasi: "3 jam",
      type: ActivityType.TRAINING,
      status: ActivityStatus.COMPLETED,
    },
  ];

  await prisma.logbook.createMany({
    data: logbookData,
    skipDuplicates: true,
  });

  console.log("✅ Logbook records created");

  console.log("🎉 Database seeding completed successfully!");
  console.log("\n📝 Test Credentials:");
  console.log("Admin - Username: admin, Password: admin123");
  console.log("Pembimbing - Username: pembimbing, Password: password123");
  console.log("Peserta 1 - Username: ahmad123, Password: password123");
  console.log("Peserta 2 - Username: siti456, Password: password123");
  console.log("Peserta 3 - Username: budi789, Password: password123");
}

main()
  .catch((e) => {
    console.error("❌ Error during seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });