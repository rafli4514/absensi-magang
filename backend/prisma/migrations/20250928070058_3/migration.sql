/*
  Warnings:

  - Added the required column `instansi` to the `peserta_magang` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "public"."peserta_magang" ADD COLUMN     "instansi" TEXT NOT NULL;
