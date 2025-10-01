-- CreateEnum
CREATE TYPE "public"."Role" AS ENUM ('ADMIN', 'USER');

-- CreateEnum
CREATE TYPE "public"."StatusPeserta" AS ENUM ('AKTIF', 'NONAKTIF', 'SELESAI');

-- CreateEnum
CREATE TYPE "public"."TipeAbsensi" AS ENUM ('MASUK', 'KELUAR', 'IZIN', 'SAKIT', 'CUTI');

-- CreateEnum
CREATE TYPE "public"."StatusAbsensi" AS ENUM ('VALID', 'INVALID', 'TERLAMBAT');

-- CreateEnum
CREATE TYPE "public"."TipeIzin" AS ENUM ('SAKIT', 'IZIN', 'CUTI');

-- CreateEnum
CREATE TYPE "public"."StatusPengajuan" AS ENUM ('PENDING', 'DISETUJUI', 'DITOLAK');

-- CreateTable
CREATE TABLE "public"."users" (
    "id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" "public"."Role" NOT NULL DEFAULT 'USER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "avatar" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."peserta_magang" (
    "id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "instansi" TEXT NOT NULL,
    "divisi" TEXT NOT NULL,
    "nomorHp" TEXT NOT NULL,
    "tanggalMulai" TEXT NOT NULL,
    "tanggalSelesai" TEXT NOT NULL,
    "status" "public"."StatusPeserta" NOT NULL DEFAULT 'AKTIF',
    "avatar" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "peserta_magang_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."absensi" (
    "id" TEXT NOT NULL,
    "pesertaMagangId" TEXT NOT NULL,
    "tipe" "public"."TipeAbsensi" NOT NULL,
    "timestamp" TEXT NOT NULL,
    "lokasi" JSONB,
    "selfieUrl" TEXT,
    "qrCodeData" TEXT,
    "status" "public"."StatusAbsensi" NOT NULL DEFAULT 'VALID',
    "catatan" TEXT,
    "ipAddress" TEXT,
    "device" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "absensi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."pengajuan_izin" (
    "id" TEXT NOT NULL,
    "pesertaMagangId" TEXT NOT NULL,
    "tipe" "public"."TipeIzin" NOT NULL,
    "tanggalMulai" TEXT NOT NULL,
    "tanggalSelesai" TEXT NOT NULL,
    "alasan" TEXT NOT NULL,
    "status" "public"."StatusPengajuan" NOT NULL DEFAULT 'PENDING',
    "dokumenPendukung" TEXT,
    "disetujuiOleh" TEXT,
    "disetujuiPada" TEXT,
    "catatan" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pengajuan_izin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."settings" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" JSONB NOT NULL,
    "category" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "public"."users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "peserta_magang_username_key" ON "public"."peserta_magang"("username");

-- CreateIndex
CREATE UNIQUE INDEX "settings_key_key" ON "public"."settings"("key");

-- AddForeignKey
ALTER TABLE "public"."absensi" ADD CONSTRAINT "absensi_pesertaMagangId_fkey" FOREIGN KEY ("pesertaMagangId") REFERENCES "public"."peserta_magang"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."pengajuan_izin" ADD CONSTRAINT "pengajuan_izin_pesertaMagangId_fkey" FOREIGN KEY ("pesertaMagangId") REFERENCES "public"."peserta_magang"("id") ON DELETE CASCADE ON UPDATE CASCADE;
