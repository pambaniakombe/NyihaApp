-- Admin-visible notes & warnings on member profile
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "adminProfileNote" TEXT NOT NULL DEFAULT '';
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "adminWarning" TEXT NOT NULL DEFAULT '';
