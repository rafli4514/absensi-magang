import {
  PrismaClient,
  Role,
  StatusPeserta,
  TipeAbsensi,
  StatusAbsensi,
  TipeIzin,
  StatusPengajuan,
} from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seeding...");

  // Create admin user
  const hashedPassword = await bcrypt.hash("admin123", 10);

  const adminUser = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: hashedPassword,
      role: Role.ADMIN,
      isActive: true,
    },
  });

  console.log("✅ Admin user created:", adminUser.username);

  // Create sample peserta magang
  const pesertaMagang = await prisma.pesertaMagang.upsert({
    where: { username: "johndoe" },
    update: {},
    create: {
      nama: "John Doe",
      username: "johndoe",
      divisi: "IT Development",
      instansi: "PLN Icon Plus",
      nomorHp: "081234567890",
      tanggalMulai: "2024-01-01",
      tanggalSelesai: "2024-06-30", 
      status: StatusPeserta.AKTIF,
      avatar: "https://via.placeholder.com/150",
    },
  });

  console.log("✅ Sample peserta magang created:", pesertaMagang.nama);

  // Create another peserta magang
  const pesertaMagang2 = await prisma.pesertaMagang.upsert({
    where: { username: "janesmith" },
    update: {},
    create: {
      nama: "Jane Smith",
      username: "janesmith",
      divisi: "Marketing",
      instansi: "PLN Icon Plus",
      nomorHp: "081234567891",
      tanggalMulai: "2024-02-01",
      tanggalSelesai: "2024-07-31",
      status: StatusPeserta.AKTIF,
      avatar: "https://via.placeholder.com/150",
    },
  });

  console.log("✅ Sample peserta magang 2 created:", pesertaMagang2.nama);

  // Create sample absensi records
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  // Check in for yesterday
  await prisma.absensi.create({
    data: {
      pesertaMagangId: pesertaMagang.id,
      tipe: TipeAbsensi.MASUK,
      timestamp: yesterday.toISOString(),
      lokasi: {
        latitude: -6.2088,
        longitude: 106.8456,
        address: "Jakarta, Indonesia",
      },
      selfieUrl: "https://via.placeholder.com/300x300",
      qrCodeData: "QR_CODE_SAMPLE_1",
      status: StatusAbsensi.VALID,
      ipAddress: "192.168.1.100",
      device: "Mobile App",
    },
  });

  // Check out for yesterday
  await prisma.absensi.create({
    data: {
      pesertaMagangId: pesertaMagang.id,
      tipe: TipeAbsensi.KELUAR,
      timestamp: new Date(
        yesterday.getTime() + 8 * 60 * 60 * 1000
      ).toISOString(), // 8 hours later
      lokasi: {
        latitude: -6.2088,
        longitude: 106.8456,
        address: "Jakarta, Indonesia",
      },
      selfieUrl: "https://via.placeholder.com/300x300",
      qrCodeData: "QR_CODE_SAMPLE_2",
      status: StatusAbsensi.VALID,
      ipAddress: "192.168.1.100",
      device: "Mobile App",
    },
  });

  // Check in for today
  await prisma.absensi.create({
    data: {
      pesertaMagangId: pesertaMagang.id,
      tipe: TipeAbsensi.MASUK,
      timestamp: today.toISOString(),
      lokasi: {
        latitude: -6.2088,
        longitude: 106.8456,
        address: "Jakarta, Indonesia",
      },
      selfieUrl: "https://via.placeholder.com/300x300",
      qrCodeData: "QR_CODE_SAMPLE_3",
      status: StatusAbsensi.VALID,
      ipAddress: "192.168.1.100",
      device: "Mobile App",
    },
  });

  console.log("✅ Sample absensi records created");

  // Create sample pengajuan izin
  await prisma.pengajuanIzin.create({
    data: {
      pesertaMagangId: pesertaMagang.id,
      tipe: TipeIzin.SAKIT,
      tanggalMulai: "2024-09-15",
      tanggalSelesai: "2024-09-15",
      alasan: "Sakit demam dan flu",
      status: StatusPengajuan.PENDING,
      dokumenPendukung: "https://via.placeholder.com/400x600",
    },
  });

  await prisma.pengajuanIzin.create({
    data: {
      pesertaMagangId: pesertaMagang2.id,
      tipe: TipeIzin.IZIN,
      tanggalMulai: "2024-09-16",
      tanggalSelesai: "2024-09-16",
      alasan: "Ada keperluan keluarga mendesak",
      status: StatusPengajuan.DISETUJUI,
      dokumenPendukung: "https://via.placeholder.com/400x600",
      disetujuiOleh: adminUser.id,
      disetujuiPada: new Date().toISOString(),
    },
  });

  console.log("✅ Sample pengajuan izin created");

  console.log("🎉 Database seeding completed successfully!");
}

main()
  .catch((e) => {
    console.error("❌ Error during seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
