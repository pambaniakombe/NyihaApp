-- Add nullable avatar URL for member profile photos.
ALTER TABLE "User"
ADD COLUMN "avatarUrl" TEXT;
