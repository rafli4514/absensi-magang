-- Script untuk menghubungkan data users dan peserta_magang
-- Update peserta magang yang sudah ada dengan userId yang sesuai

-- Untuk peserta magang yang username-nya sama dengan user yang ada
UPDATE "peserta_magang" 
SET "userId" = (
    SELECT "id" FROM "users" 
    WHERE "users"."username" = "peserta_magang"."username"
)
WHERE EXISTS (
    SELECT 1 FROM "users" 
    WHERE "users"."username" = "peserta_magang"."username"
);

-- Untuk peserta magang yang belum punya user, buat user baru
INSERT INTO "users" ("id", "username", "password", "role", "isActive", "createdAt", "updatedAt")
SELECT 
    gen_random_uuid()::text,
    "username",
    '$2a$12$defaultpasswordhash', -- Default password, perlu diubah
    'USER',
    true,
    NOW(),
    NOW()
FROM "peserta_magang" 
WHERE "userId" IS NULL;

-- Update peserta magang dengan userId dari user yang baru dibuat
UPDATE "peserta_magang" 
SET "userId" = (
    SELECT "id" FROM "users" 
    WHERE "users"."username" = "peserta_magang"."username"
)
WHERE "userId" IS NULL;
