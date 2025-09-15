-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'USER');

-- CreateEnum
CREATE TYPE "StatusPeserta" AS ENUM ('AKTIF', 'NONAKTIF', 'SELESAI');

-- CreateEnum
CREATE TYPE "TipeAbsensi" AS ENUM ('MASUK', 'KELUAR', 'IZIN', 'SAKIT', 'CUTI');

-- CreateEnum
CREATE TYPE "StatusAbsensi" AS ENUM ('VALID', 'INVALID', 'TERLAMBAT');

-- CreateEnum
CREATE TYPE "TipeIzin" AS ENUM ('SAKIT', 'IZIN', 'CUTI');

-- CreateEnum
CREATE TYPE "StatusPengajuan" AS ENUM ('PENDING', 'DISETUJUI', 'DITOLAK');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "avatar" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "peserta_magang" (
    "id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "divisi" TEXT NOT NULL,
    "universitas" TEXT NOT NULL,
    "nomorHp" TEXT NOT NULL,
    "tanggalMulai" TEXT NOT NULL,
    "tanggalSelesai" TEXT NOT NULL,
    "status" "StatusPeserta" NOT NULL DEFAULT 'AKTIF',
    "avatar" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "peserta_magang_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "absensi" (
    "id" TEXT NOT NULL,
    "pesertaMagangId" TEXT NOT NULL,
    "tipe" "TipeAbsensi" NOT NULL,
    "timestamp" TEXT NOT NULL,
    "lokasi" JSONB,
    "selfieUrl" TEXT,
    "qrCodeData" TEXT,
    "status" "StatusAbsensi" NOT NULL DEFAULT 'VALID',
    "catatan" TEXT,
    "ipAddress" TEXT,
    "device" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "absensi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pengajuan_izin" (
    "id" TEXT NOT NULL,
    "pesertaMagangId" TEXT NOT NULL,
    "tipe" "TipeIzin" NOT NULL,
    "tanggalMulai" TEXT NOT NULL,
    "tanggalSelesai" TEXT NOT NULL,
    "alasan" TEXT NOT NULL,
    "status" "StatusPengajuan" NOT NULL DEFAULT 'PENDING',
    "dokumenPendukung" TEXT,
    "disetujuiOleh" TEXT,
    "disetujuiPada" TEXT,
    "catatan" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pengajuan_izin_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "peserta_magang_username_key" ON "peserta_magang"("username");

-- AddForeignKey
ALTER TABLE "absensi" ADD CONSTRAINT "absensi_pesertaMagangId_fkey" FOREIGN KEY ("pesertaMagangId") REFERENCES "peserta_magang"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pengajuan_izin" ADD CONSTRAINT "pengajuan_izin_pesertaMagangId_fkey" FOREIGN KEY ("pesertaMagangId") REFERENCES "peserta_magang"("id") ON DELETE CASCADE ON UPDATE CASCADE;
