-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "MemberStatus" AS ENUM ('pending', 'approved', 'suspended');

-- CreateEnum
CREATE TYPE "AdminRole" AS ENUM ('main', 'helper');

-- CreateEnum
CREATE TYPE "ChatChannel" AS ENUM ('community', 'admin', 'seller');

-- CreateEnum
CREATE TYPE "ChatMediaKind" AS ENUM ('text', 'image', 'voice');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('inasubiri_malipo', 'confirmed', 'cancelled');

-- CreateEnum
CREATE TYPE "TickPaymentPhase" AS ENUM ('waitingMoney', 'waitingAdminApproval');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "children" INTEGER NOT NULL DEFAULT 0,
    "status" "MemberStatus" NOT NULL DEFAULT 'pending',
    "ticksPaid" INTEGER NOT NULL DEFAULT 0,
    "balance" INTEGER NOT NULL DEFAULT 0,
    "username" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdminUser" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "role" "AdminRole" NOT NULL,
    "linkedMemberPhone" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AdminUser_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Product" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "priceLabel" TEXT NOT NULL,
    "emoji" TEXT NOT NULL,
    "color" INTEGER NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Order" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "productId" TEXT,
    "productName" TEXT NOT NULL,
    "priceLabel" TEXT NOT NULL,
    "size" TEXT NOT NULL,
    "rangi" TEXT NOT NULL,
    "idadi" INTEGER NOT NULL,
    "buyerName" TEXT NOT NULL,
    "status" "OrderStatus" NOT NULL DEFAULT 'inasubiri_malipo',
    "placedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CommunityPost" (
    "id" TEXT NOT NULL,
    "authorLabel" TEXT NOT NULL,
    "headline" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "dateLabel" TEXT NOT NULL,
    "tag" TEXT NOT NULL,
    "imageUrls" JSONB NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CommunityPost_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PostReaction" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PostReaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JamiiEvent" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "desc" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "tag" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "JamiiEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChatMessage" (
    "id" TEXT NOT NULL,
    "channel" "ChatChannel" NOT NULL,
    "fromLabel" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "timeLabel" TEXT NOT NULL,
    "isFromMe" BOOLEAN NOT NULL DEFAULT false,
    "emoji" TEXT,
    "mediaKind" "ChatMediaKind" NOT NULL DEFAULT 'text',
    "imageUrl" TEXT,
    "voiceUrl" TEXT,
    "voiceDurationSec" INTEGER,
    "userId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChatMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PendingSignup" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "children" INTEGER NOT NULL,
    "registrationFeePaid" BOOLEAN NOT NULL DEFAULT false,
    "detailLines" TEXT NOT NULL DEFAULT '',
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "PendingSignup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PendingTickPayment" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tickCount" INTEGER NOT NULL,
    "phase" "TickPaymentPhase" NOT NULL DEFAULT 'waitingMoney',
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PendingTickPayment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Poll" (
    "id" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "options" JSONB NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Poll_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PollVote" (
    "id" TEXT NOT NULL,
    "pollId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "optionIdx" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PollVote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AppSettings" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "customerCarePhone" TEXT NOT NULL DEFAULT '+255 700 000 111',
    "customerCareWhatsApp" TEXT NOT NULL DEFAULT '+255 700 000 222',
    "customerCareHoursLabel" TEXT NOT NULL DEFAULT 'Jumatatu–Ijumaa · 08:00–18:00',
    "jamiiCommunityChatMembersCanSend" BOOLEAN NOT NULL DEFAULT true,
    "showUserTabHome" BOOLEAN NOT NULL DEFAULT true,
    "showUserTabJamii" BOOLEAN NOT NULL DEFAULT true,
    "showUserTabDuka" BOOLEAN NOT NULL DEFAULT true,
    "showUserTabProfile" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiMazungumzo" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiAdminChat" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiWanachama" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiMatukio" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiMkeka" BOOLEAN NOT NULL DEFAULT true,
    "showJamiiKura" BOOLEAN NOT NULL DEFAULT true,
    "ticksRequiredAnnual" INTEGER NOT NULL DEFAULT 24,
    "tickPriceTzs" INTEGER NOT NULL DEFAULT 2000,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AppSettings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE UNIQUE INDEX "AdminUser_email_key" ON "AdminUser"("email");

-- CreateIndex
CREATE INDEX "Order_userId_idx" ON "Order"("userId");

-- CreateIndex
CREATE INDEX "Order_placedAt_idx" ON "Order"("placedAt");

-- CreateIndex
CREATE INDEX "PostReaction_postId_idx" ON "PostReaction"("postId");

-- CreateIndex
CREATE UNIQUE INDEX "PostReaction_postId_userId_kind_key" ON "PostReaction"("postId", "userId", "kind");

-- CreateIndex
CREATE INDEX "ChatMessage_channel_createdAt_idx" ON "ChatMessage"("channel", "createdAt");

-- CreateIndex
CREATE INDEX "PendingSignup_resolved_idx" ON "PendingSignup"("resolved");

-- CreateIndex
CREATE INDEX "PendingTickPayment_userId_idx" ON "PendingTickPayment"("userId");

-- CreateIndex
CREATE INDEX "PollVote_pollId_idx" ON "PollVote"("pollId");

-- CreateIndex
CREATE UNIQUE INDEX "PollVote_pollId_userId_key" ON "PollVote"("pollId", "userId");

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PostReaction" ADD CONSTRAINT "PostReaction_postId_fkey" FOREIGN KEY ("postId") REFERENCES "CommunityPost"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatMessage" ADD CONSTRAINT "ChatMessage_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PollVote" ADD CONSTRAINT "PollVote_pollId_fkey" FOREIGN KEY ("pollId") REFERENCES "Poll"("id") ON DELETE CASCADE ON UPDATE CASCADE;

