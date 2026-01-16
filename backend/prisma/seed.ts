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

  // Hash passwords
  const password = await bcrypt.hash("password123", 10);
  const adminPassword = await bcrypt.hash("admin123", 10);

  // === 1. CREATE ADMIN USER ===
  const adminUser = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: adminPassword,
      role: Role.ADMIN,
      isActive: true,
    },
  });
  console.log("✅ Admin user created:", adminUser.username);

  // === 2. CREATE PEMBIMBING (MENTORS) ===
  // User requested mapping:
  // 1. Pemasaran dan Penjualan (khalil, dennis)
  // 2. Retail SBU (dela, dila, liza)
  // 3. Pembangunan dan Aktivasi (Beranju, anto)
  // 4. Operasi Pemeliharaan dan Aset (ridha, rifki)
  const mentorsData = [
    // Pemasaran dan Penjualan
    { username: "khalil", nama: "Khalil (Mentor)", bidang: "Pemasaran dan Penjualan" },
    { username: "dennis", nama: "Dennis (Mentor)", bidang: "Pemasaran dan Penjualan" },

    // Retail SBU
    { username: "dela", nama: "Dela (Mentor)", bidang: "Retail SBU" },
    { username: "dila", nama: "Dila (Mentor)", bidang: "Retail SBU" },
    { username: "liza", nama: "Liza (Mentor)", bidang: "Retail SBU" },

    // Pembangunan dan Aktivasi
    { username: "beranju", nama: "Beranju (Mentor)", bidang: "Pembangunan dan Aktivasi" },
    { username: "anto", nama: "Anto (Mentor)", bidang: "Pembangunan dan Aktivasi" },

    // Operasi Pemeliharaan dan Aset
    { username: "ridha", nama: "Ridha (Mentor)", bidang: "Operasi Pemeliharaan dan Aset" },
    { username: "rifki", nama: "Rifki (Mentor)", bidang: "Operasi Pemeliharaan dan Aset" },
  ];

  const createdMentors = [];

  for (const mentor of mentorsData) {
    // Create User for Mentor
    const user = await prisma.user.upsert({
      where: { username: mentor.username },
      update: {},
      create: {
        username: mentor.username,
        password: password, // password123
        role: Role.PEMBIMBING_MAGANG,
        isActive: true,
      },
    });

    // Create Profile for Mentor
    const profile = await prisma.pembimbing.upsert({
      where: { userId: user.id },
      update: {
        nama: mentor.nama,
        bidang: mentor.bidang,
      },
      create: {
        userId: user.id,
        nama: mentor.nama,
        bidang: mentor.bidang,
        kuota: 10, // Default quota
        nip: `NIP-${mentor.username.toUpperCase()}`,
      },
    });

    createdMentors.push(profile);
    console.log(`✅ Mentor created: ${mentor.nama} (${mentor.bidang})`);
  }

  // === 3. CREATE PESERTA MAGANG (PARTICIPANTS) ===
  const participants = [
    {
      username: "ahmad123",
      nama: "Ahmad Rizki Pratama",
      divisi: "Pemasaran dan Penjualan",
      instansi: "Universitas Indonesia",
      id_instansi: "UI-2024-001",
      nomorHp: "081234567890",
      tanggalMulai: "2024-12-01",
      tanggalSelesai: "2025-06-30",
      mentorUsername: "khalil", // Assign to Khalil
    },
    {
      username: "siti456",
      nama: "Siti Nurhaliza",
      divisi: "Retail SBU",
      instansi: "Universitas Gadjah Mada",
      id_instansi: "UGM-2024-002",
      nomorHp: "081234567891",
      tanggalMulai: "2024-12-01",
      tanggalSelesai: "2025-06-30",
      mentorUsername: "dela", // Assign to Dela
    },
    {
      username: "budi789",
      nama: "Budi Santoso",
      divisi: "Operasi Pemeliharaan dan Aset",
      instansi: "Institut Teknologi Bandung",
      id_instansi: "ITB-2024-003",
      nomorHp: "081234567892",
      tanggalMulai: "2024-11-15",
      tanggalSelesai: "2025-05-15",
      mentorUsername: "ridha", // Assign to Ridha
    },
  ];

  const createdParticipants = [];

  for (const p of participants) {
    // Create User
    const user = await prisma.user.upsert({
      where: { username: p.username },
      update: {},
      create: {
        username: p.username,
        password: password,
        role: Role.PESERTA_MAGANG,
        isActive: true,
      },
    });

    // Find assigned mentor object (we need the ID)
    const assignedMentor = createdMentors.find(m => m.nip === `NIP-${p.mentorUsername.toUpperCase()}`);

    if (!assignedMentor) {
      console.warn(`Warning: Mentor ${p.mentorUsername} not found for participant ${p.username}`);
      continue;
    }

    const profile = await prisma.pesertaMagang.upsert({
      where: { username: p.username },
      update: {
        pembimbingId: assignedMentor.id,
      },
      create: {
        nama: p.nama,
        username: p.username,
        id_peserta_magang: `${p.username}-ID`,
        divisi: p.divisi,
        instansi: p.instansi,
        id_instansi: p.id_instansi,
        nomorHp: p.nomorHp,
        tanggalMulai: p.tanggalMulai,
        tanggalSelesai: p.tanggalSelesai,
        status: StatusPeserta.AKTIF,
        userId: user.id,
        pembimbingId: assignedMentor.id,
        namaMentor: assignedMentor.nama,
      },
    });
    createdParticipants.push(profile);
    console.log(`✅ Participant created: ${p.nama} -> Mentor: ${assignedMentor.nama}`);
  }

  // === 4. CREATE ACTIVITY RECORDS (ABSENSI, IZIN, LOGBOOK) ===
  if (createdParticipants.length > 0) {
    const peserta1 = createdParticipants[0];
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    await prisma.absensi.createMany({
      data: [
        {
          pesertaMagangId: peserta1.id,
          tipe: TipeAbsensi.MASUK,
          timestamp: yesterday.toISOString(),
          lokasi: { latitude: -6.2088, longitude: 106.8456, address: "PT PLN Icon Plus, Jakarta" },
          status: StatusAbsensi.VALID,
          ipAddress: "192.168.1.100",
          device: "Android",
        },
      ],
      skipDuplicates: true,
    });
    console.log("✅ Sample Absensi created for " + peserta1.nama);
  }

  console.log("\n🎉 Database seeding completed successfully!");
  console.log("-------------------------------------------");
  console.log("👤 Admin: admin / admin123");
  console.log("👤 Mentors (Password: password123):");
  mentorsData.forEach(m => console.log(`   - ${m.nama}: ${m.username}`));
  console.log("-------------------------------------------");
}

main()
  .catch((e) => {
    console.error("❌ Error during seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });