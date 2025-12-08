-- Step 1: Add PESERTA_MAGANG to Role enum
-- This will be committed separately before the UPDATE can use it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'PESERTA_MAGANG' 
        AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'Role')
    ) THEN
        ALTER TYPE "public"."Role" ADD VALUE 'PESERTA_MAGANG';
    END IF;
END $$;

