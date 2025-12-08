-- Step 2: Update all existing USER records to PESERTA_MAGANG
-- This must be in a separate migration after the enum value is committed
UPDATE "public"."users" 
SET "role" = 'PESERTA_MAGANG'::"public"."Role"
WHERE "role" = 'USER'::"public"."Role";

