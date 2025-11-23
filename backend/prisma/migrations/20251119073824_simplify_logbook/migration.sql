/*
  Warnings:

  - You are about to drop the column `catatanPembimbing` on the `logbook` table. All the data in the column will be lost.
  - You are about to drop the column `disetujuiOleh` on the `logbook` table. All the data in the column will be lost.
  - You are about to drop the column `disetujuiPada` on the `logbook` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `logbook` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "public"."logbook" DROP COLUMN "catatanPembimbing",
DROP COLUMN "disetujuiOleh",
DROP COLUMN "disetujuiPada",
DROP COLUMN "status";

-- DropEnum
DROP TYPE "public"."StatusLogbook";
