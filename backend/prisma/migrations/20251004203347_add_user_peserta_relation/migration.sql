-- Add userId column to peserta_magang table (nullable first)
ALTER TABLE "peserta_magang" ADD COLUMN "userId" TEXT;

-- Create unique index for userId
CREATE UNIQUE INDEX "peserta_magang_userId_key" ON "peserta_magang"("userId");

-- Add foreign key constraint
ALTER TABLE "peserta_magang" ADD CONSTRAINT "peserta_magang_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
