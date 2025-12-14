/*
  Warnings:

  - The values [USER] on the enum `Role` will be removed. If these variants are still used in the database, this will fail.

*/
-- CreateEnum
CREATE TYPE "public"."ActivityType" AS ENUM ('MEETING', 'TRAINING', 'PRESENTATION', 'DEADLINE', 'OTHER');

-- CreateEnum
CREATE TYPE "public"."ActivityStatus" AS ENUM ('COMPLETED', 'IN_PROGRESS', 'PENDING', 'CANCELLED');

-- AlterEnum
BEGIN;
CREATE TYPE "public"."Role_new" AS ENUM ('ADMIN', 'PESERTA_MAGANG', 'PEMBIMBING_MAGANG');
ALTER TABLE "public"."users" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "public"."users" ALTER COLUMN "role" TYPE "public"."Role_new" USING ("role"::text::"public"."Role_new");
ALTER TYPE "public"."Role" RENAME TO "Role_old";
ALTER TYPE "public"."Role_new" RENAME TO "Role";
DROP TYPE "public"."Role_old";
ALTER TABLE "public"."users" ALTER COLUMN "role" SET DEFAULT 'PESERTA_MAGANG';
COMMIT;

-- AlterTable
ALTER TABLE "public"."logbook" ADD COLUMN     "status" "public"."ActivityStatus" DEFAULT 'PENDING',
ADD COLUMN     "type" "public"."ActivityType" DEFAULT 'OTHER';

-- AlterTable
ALTER TABLE "public"."users" ALTER COLUMN "role" SET DEFAULT 'PESERTA_MAGANG';
