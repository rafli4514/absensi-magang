-- AlterTable
ALTER TABLE "public"."peserta_magang" ADD COLUMN     "pembimbingId" TEXT;

-- CreateTable
CREATE TABLE "public"."pembimbing" (
    "id" TEXT NOT NULL,
    "nip" TEXT,
    "nama" TEXT NOT NULL,
    "bidang" TEXT NOT NULL,
    "kuota" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "pembimbing_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "pembimbing_nip_key" ON "public"."pembimbing"("nip");

-- CreateIndex
CREATE UNIQUE INDEX "pembimbing_userId_key" ON "public"."pembimbing"("userId");

-- AddForeignKey
ALTER TABLE "public"."peserta_magang" ADD CONSTRAINT "peserta_magang_pembimbingId_fkey" FOREIGN KEY ("pembimbingId") REFERENCES "public"."pembimbing"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."pembimbing" ADD CONSTRAINT "pembimbing_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
