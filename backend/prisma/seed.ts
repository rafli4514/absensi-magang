import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database...");

  // Create admin user
  const hashedPassword = await bcrypt.hash("admin123", 12);

  const admin = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: hashedPassword,
      role: "ADMIN",
      isActive: true,
    },
  });

  console.log("✅ Admin user created:", admin);

  // Create sample peserta magang
  const pesertaMagang1 = await prisma.pesertaMagang.upsert({
    where: { username: "ahmad" },
    update: {},
    create: {
      nama: "Ahmad Rizki Pratama",
      username: "ahmad",
      divisi: "IT",
      instansi: "Instansi Indonesia",
      nomorHp: "08123456789",
      tanggalMulai: "2025-01-01",
      tanggalSelesai: "2025-06-30",
      status: "AKTIF",
    },
  });

  const pesertaMagang2 = await prisma.pesertaMagang.upsert({
    where: { username: "siti" },
    update: {},
    create: {
      nama: "Siti Nurhaliza",
      username: "siti",
      divisi: "Marketing",
      instansi: "Instansi Gadjah Mada",
      nomorHp: "08123456790",
      tanggalMulai: "2025-01-01",
      tanggalSelesai: "2025-06-30",
      status: "AKTIF",
    },
  });

  console.log("✅ Peserta magang created:", pesertaMagang1, pesertaMagang2);

  // Create sample absensi (attendance)
  await prisma.absensi.createMany({
    data: [
      {
        pesertaMagangId: pesertaMagang1.id,
        tipe: "MASUK",
        timestamp: new Date().toISOString(),
        status: "VALID",
        qrCodeData: "sample-qr-code-1",
      },
      {
        pesertaMagangId: pesertaMagang2.id,
        tipe: "MASUK",
        timestamp: new Date().toISOString(),
        status: "TERLAMBAT",
        qrCodeData: "sample-qr-code-2",
      },
    ],
  });

  console.log("✅ Sample absensi created");

  // Create sample pengajuan izin (leave requests)
  await prisma.pengajuanIzin.createMany({
    data: [
      {
        pesertaMagangId: pesertaMagang1.id,
        tipe: "SAKIT",
        tanggalMulai: "2025-01-15",
        tanggalSelesai: "2025-01-16",
        alasan: "Demam tinggi dan perlu istirahat",
        status: "PENDING",
        dokumenPendukung: "surat-dokter.pdf",
      },
      {
        pesertaMagangId: pesertaMagang2.id,
        tipe: "IZIN",
        tanggalMulai: "2025-01-20",
        tanggalSelesai: "2025-01-20",
        alasan: "Menghadiri acara keluarga",
        status: "DISETUJUI",
        disetujuiOleh: "Admin",
        disetujuiPada: new Date().toISOString(),
        catatan: "Izin disetujui. Pastikan untuk catch up pekerjaan.",
      },
    ],
  });

  console.log("✅ Sample pengajuan izin created");
}

main()
  .then(async () => {
    await prisma.$disconnect();
    console.log("🎉 Seeding completed successfully!");
  })
  .catch(async (e) => {
    console.error("❌ Seeding failed:", e);
    await prisma.$disconnect();
    process.exit(1);
  });
