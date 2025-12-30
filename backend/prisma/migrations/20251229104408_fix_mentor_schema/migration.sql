/*
  Warnings:

  - You are about to drop the column `namaMentor` on the `users` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "peserta_magang" ADD COLUMN     "namaMentor" TEXT;

-- AlterTable
ALTER TABLE "users" DROP COLUMN "namaMentor";
