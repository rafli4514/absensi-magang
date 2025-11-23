-- CreateEnum
CREATE TYPE "public"."StatusLogbook" AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "public"."logbook" (
    "id" TEXT NOT NULL,
    "pesertaMagangId" TEXT NOT NULL,
    "tanggal" TEXT NOT NULL,
    "kegiatan" TEXT NOT NULL,
    "deskripsi" TEXT NOT NULL,
    "durasi" TEXT,
    "status" "public"."StatusLogbook" NOT NULL DEFAULT 'DRAFT',
    "catatanPembimbing" TEXT,
    "disetujuiOleh" TEXT,
    "disetujuiPada" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "logbook_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "public"."logbook" ADD CONSTRAINT "logbook_pesertaMagangId_fkey" FOREIGN KEY ("pesertaMagangId") REFERENCES "public"."peserta_magang"("id") ON DELETE CASCADE ON UPDATE CASCADE;
