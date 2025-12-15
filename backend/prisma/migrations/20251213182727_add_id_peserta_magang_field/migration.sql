-- AlterTable
-- Add id_peserta_magang column as nullable first
ALTER TABLE "peserta_magang" ADD COLUMN IF NOT EXISTS "id_peserta_magang" TEXT;

-- Create unique index for id_peserta_magang (only on non-null values)
CREATE UNIQUE INDEX IF NOT EXISTS "peserta_magang_id_peserta_magang_key" ON "peserta_magang"("id_peserta_magang") WHERE "id_peserta_magang" IS NOT NULL;



