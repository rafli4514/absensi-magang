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

// ================= KONFIGURASI =================
const OFFICE_LAT = 5.5454249;
const OFFICE_LNG = 95.3175582;
const DEFAULT_PASSWORD = "password123";

// Definisi Persona
type Persona = "RAJIN" | "NORMAL" | "MALAS" | "SAKITAN";

interface UserSeedConfig {
nama: string;
username: string;
divisi: string;
instansi: string;
gender: "male" | "female";
persona: Persona;
durationMonths: number; // Durasi history data (bulan)
}

// Data 20 User Dummy dengan Durasi Bervariasi
const USERS_TO_SEED: UserSeedConfig[] = [
  // --- KELOMPOK 12 BULAN (Senior) ---
  { nama: "Adi Nugraha", username: "adidev", divisi: "IT Development", instansi: "Telkom University", gender: "male", persona: "RAJIN", durationMonths: 12 },
  { nama: "Citra Lestari", username: "citradev", divisi: "IT Development", instansi: "UI", gender: "female", persona: "RAJIN", durationMonths: 12 },
  { nama: "Kartika Sari", username: "kartikafin", divisi: "Finance", instansi: "Unair", gender: "female", persona: "RAJIN", durationMonths: 12 },

  // --- KELOMPOK 6 BULAN (Standard) ---
  { nama: "Budi Santoso", username: "budidev", divisi: "IT Development", instansi: "ITB", gender: "male", persona: "NORMAL", durationMonths: 6 },
  { nama: "Eka Putri", username: "ekadev", divisi: "IT Development", instansi: "Binus", gender: "female", persona: "NORMAL", durationMonths: 6 },
  { nama: "Fajar Wicaksono", username: "fajarmkt", divisi: "Marketing", instansi: "Unpad", gender: "male", persona: "NORMAL", durationMonths: 6 },
  { nama: "Indah Permata", username: "indahmkt", divisi: "Marketing", instansi: "UNS", gender: "female", persona: "RAJIN", durationMonths: 6 },
  { nama: "Lukman Hakim", username: "lukmanfin", divisi: "Finance", instansi: "ITS", gender: "male", persona: "RAJIN", durationMonths: 6 },

  // --- KELOMPOK 5 BULAN ---
  { nama: "Dimas Anggara", username: "dimasdev", divisi: "IT Development", instansi: "UGM", gender: "male", persona: "MALAS", durationMonths: 5 },
  { nama: "Gita Gutawa", username: "gitamkt", divisi: "Marketing", instansi: "Undip", gender: "female", persona: "SAKITAN", durationMonths: 5 },
  { nama: "Maya Septha", username: "mayafin", divisi: "Finance", instansi: "Udayana", gender: "female", persona: "NORMAL", durationMonths: 5 },

  // --- KELOMPOK 3 BULAN ---
  { nama: "Hendra Setiawan", username: "hendramkt", divisi: "Marketing", instansi: "UB", gender: "male", persona: "NORMAL", durationMonths: 3 },
  { nama: "Joko Anwar", username: "jokomkt", divisi: "Marketing", instansi: "UPI", gender: "male", persona: "MALAS", durationMonths: 3 },
  { nama: "Nanda Putra", username: "nandafin", divisi: "Finance", instansi: "Unhas", gender: "male", persona: "NORMAL", durationMonths: 3 },
  { nama: "Putri Titian", username: "putrihr", divisi: "HR", instansi: "Andalas", gender: "female", persona: "RAJIN", durationMonths: 3 },
  { nama: "Oscar Lawalata", username: "oscarfin", divisi: "Finance", instansi: "USU", gender: "male", persona: "SAKITAN", durationMonths: 3 },

  // --- KELOMPOK 1 BULAN (Junior/Baru) ---
  { nama: "Qory Sandioriva", username: "qoryhr", divisi: "HR", instansi: "Sriwijaya", gender: "female", persona: "NORMAL", durationMonths: 1 },
  { nama: "Raka Pradana", username: "rakahr", divisi: "HR", instansi: "IPB", gender: "male", persona: "MALAS", durationMonths: 1 },
  { nama: "Siti Badriah", username: "sitihr", divisi: "HR", instansi: "UNJ", gender: "female", persona: "NORMAL", durationMonths: 1 },
  { nama: "Tono Sudirjo", username: "tonohr", divisi: "HR", instansi: "UIN", gender: "male", persona: "SAKITAN", durationMonths: 1 },
];

// Daftar Aktivitas
const ACTIVITIES = [
  { title: "Meeting Harian", type: ActivityType.MEETING, desc: "Koordinasi tugas harian." },
  { title: "Mengerjakan Laporan", type: ActivityType.OTHER, desc: "Menyusun laporan progress mingguan." },
  { title: "Analisa Data", type: ActivityType.OTHER, desc: "Menganalisa data untuk kebutuhan project." },
  { title: "Belajar Materi Baru", type: ActivityType.TRAINING, desc: "Mempelajari modul baru yang diberikan mentor." },
  { title: "Membantu Event Kantor", type: ActivityType.OTHER, desc: "Menjadi panitia dalam acara internal divisi." },
  { title: "Revisi Pekerjaan", type: ActivityType.OTHER, desc: "Melakukan perbaikan berdasarkan feedback supervisor." },
  { title: "Presentasi Tim", type: ActivityType.PRESENTATION, desc: "Presentasi hasil kerja tim minggu ini." },
];

function getRandomOffset() {
  return (Math.random() - 0.5) * 0.0005;
}

// Konfigurasi Probabilitas
function getProbabilities(persona: Persona) {
  switch (persona) {
    case "RAJIN":
      return { late: 0.05, sick: 0.01, permit: 0.02, alpha: 0.0, forgetOut: 0.02 };
    case "NORMAL":
      return { late: 0.15, sick: 0.03, permit: 0.05, alpha: 0.01, forgetOut: 0.05 };
    case "MALAS":
      return { late: 0.40, sick: 0.05, permit: 0.10, alpha: 0.10, forgetOut: 0.20 };
    case "SAKITAN":
      return { late: 0.10, sick: 0.15, permit: 0.05, alpha: 0.02, forgetOut: 0.05 };
    default:
      return { late: 0.1, sick: 0.03, permit: 0.03, alpha: 0.01, forgetOut: 0.05 };
  }
}

async function main() {
  console.log(`[START] Memulai seeding untuk ${USERS_TO_SEED.length} user dengan durasi variatif...`);

  const hashedPassword = await bcrypt.hash(DEFAULT_PASSWORD, 10);
  const endDate = new Date(); // Hari ini (titik akhir data)

  for (const userData of USERS_TO_SEED) {
    // Hitung Tanggal Mulai berdasarkan durasi user
    const startDate = new Date();
    startDate.setMonth(endDate.getMonth() - userData.durationMonths);

    // Set Tanggal Selesai Kontrak (misal: 3 bulan setelah hari ini, agar status masih AKTIF)
    const contractEndDate = new Date();
    contractEndDate.setMonth(endDate.getMonth() + 3);

    console.log(`[PROCESS] ${userData.nama} | Durasi: ${userData.durationMonths} Bulan | Persona: ${userData.persona}`);

    // 1. Buat User & Profile
    const user = await prisma.user.upsert({
      where: { username: userData.username },
      update: { role: Role.PESERTA_MAGANG, isActive: true },
      create: {
        username: userData.username,
        password: hashedPassword,
        role: Role.PESERTA_MAGANG,
        isActive: true,
      },
    });

    const peserta = await prisma.pesertaMagang.upsert({
      where: { username: userData.username },
      update: {
        status: StatusPeserta.AKTIF,
        tanggalMulai: startDate.toISOString(),
        tanggalSelesai: contractEndDate.toISOString()
      },
      create: {
        userId: user.id,
        nama: userData.nama,
        username: userData.username,
        id_peserta_magang: `M-${Math.floor(Math.random() * 10000)}`,
        divisi: userData.divisi,
        instansi: userData.instansi,
        nomorHp: `08${Math.floor(Math.random() * 1000000000)}`,
        tanggalMulai: startDate.toISOString(),
        tanggalSelesai: contractEndDate.toISOString(),
        status: StatusPeserta.AKTIF,
        avatar: `https://ui-avatars.com/api/?name=${userData.nama.replace(" ", "+")}&background=random&color=fff`,
      },
    });

    // 2. Generate Data Harian (Loop dari StartDate user s/d Hari Ini)
    let currentDate = new Date(startDate);
    const probs = getProbabilities(userData.persona);

    while (currentDate <= endDate) {
      const dayOfWeek = currentDate.getDay();
      // Skip Sabtu (6) dan Minggu (0)
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        const dateStr = currentDate.toISOString().split("T")[0];
        const rand = Math.random();

        // --- SAKIT ---
        if (rand < probs.sick) {
          await prisma.pengajuanIzin.create({
            data: {
              pesertaMagangId: peserta.id,
              tipe: TipeIzin.SAKIT,
              tanggalMulai: dateStr,
              tanggalSelesai: dateStr,
              alasan: "Sakit (Generated)",
              status: StatusPengajuan.DISETUJUI,
              disetujuiPada: new Date().toISOString(),
            },
          });

          try {
            await prisma.absensi.create({
                data: {
                    pesertaMagangId: peserta.id,
                    tipe: TipeAbsensi.SAKIT,
                    timestamp: new Date(currentDate.setHours(8,0,0)).toISOString(),
                    status: StatusAbsensi.VALID,
                    catatan: "Sakit"
                }
            });
          } catch(e) {}

        // --- IZIN ---
        } else if (rand < probs.sick + probs.permit) {
          await prisma.pengajuanIzin.create({
            data: {
              pesertaMagangId: peserta.id,
              tipe: TipeIzin.IZIN,
              tanggalMulai: dateStr,
              tanggalSelesai: dateStr,
              alasan: "Izin Keperluan Pribadi",
              status: StatusPengajuan.DISETUJUI,
              disetujuiPada: new Date().toISOString(),
            },
          });

        // --- ALPHA (BOLOS) ---
        } else if (rand < probs.sick + probs.permit + probs.alpha) {
          // Kosong = Alpha

        // --- MASUK KERJA ---
        } else {
          // Cek Telat
          const isLate = Math.random() < probs.late;

          const hourIn = 7;
          let minuteIn = isLate
            ? 60 + Math.floor(Math.random() * 90)  // 08:00 - 09:30
            : 30 + Math.floor(Math.random() * 30); // 07:30 - 08:00

          let finalHourIn = hourIn;
          if (minuteIn >= 60) {
            finalHourIn += Math.floor(minuteIn / 60);
            minuteIn = minuteIn % 60;
          }

          const timeIn = new Date(currentDate);
          timeIn.setHours(finalHourIn, minuteIn, 0);

          await prisma.absensi.create({
            data: {
              pesertaMagangId: peserta.id,
              tipe: TipeAbsensi.MASUK,
              timestamp: timeIn.toISOString(),
              lokasi: {
                latitude: OFFICE_LAT + getRandomOffset(),
                longitude: OFFICE_LNG + getRandomOffset(),
                address: "Kantor Pusat",
              },
              status: isLate ? StatusAbsensi.TERLAMBAT : StatusAbsensi.VALID,
              device: "Android Device",
            },
          });

          // Absen Keluar
          if (Math.random() > probs.forgetOut) {
            const timeOut = new Date(currentDate);
            timeOut.setHours(17 + Math.floor(Math.random() * 2), Math.floor(Math.random() * 59));

            await prisma.absensi.create({
              data: {
                pesertaMagangId: peserta.id,
                tipe: TipeAbsensi.KELUAR,
                timestamp: timeOut.toISOString(),
                lokasi: {
                  latitude: OFFICE_LAT + getRandomOffset(),
                  longitude: OFFICE_LNG + getRandomOffset(),
                  address: "Kantor Pusat",
                },
                status: StatusAbsensi.VALID,
                device: "Android Device",
              },
            });
          }

          // Logbook
          const act = ACTIVITIES[Math.floor(Math.random() * ACTIVITIES.length)];
          const desc = userData.persona === "MALAS" ? "Mengerjakan tugas." : act.desc;
          const duration = userData.persona === "MALAS" ? "4 jam" : "8 jam";

          await prisma.logbook.create({
            data: {
              pesertaMagangId: peserta.id,
              tanggal: dateStr,
              kegiatan: act.title,
              deskripsi: desc,
              durasi: duration,
              type: act.type,
              status: ActivityStatus.COMPLETED,
            },
          });
        }
      }
      // Hari Berikutnya
      currentDate.setDate(currentDate.getDate() + 1);
    }
  }

  console.log("");
  console.log("[SUCCESS] SELESAI! 20 User dengan durasi variatif (1-12 bulan) berhasil dibuat.");
  console.log("[INFO] Password untuk semua user: " + DEFAULT_PASSWORD);
}

main()
  .catch((e) => {
    console.error("[ERROR]", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });