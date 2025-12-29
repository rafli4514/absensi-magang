/*
  Warnings:

  - A unique constraint covering the columns `[id_peserta_magang]` on the table `peserta_magang` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `namaMentor` to the `users` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "peserta_magang" ADD COLUMN     "id_peserta_magang" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "namaMentor" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "peserta_magang_id_peserta_magang_key" ON "peserta_magang"("id_peserta_magang");
