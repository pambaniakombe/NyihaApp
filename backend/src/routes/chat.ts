import { randomUUID } from "crypto";
import fs from "fs";
import path from "path";
import { Router } from "express";
import multer from "multer";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireMember, requireMemberOrAdmin } from "../middleware/auth";
import { ChatChannel, ChatMediaKind } from "@prisma/client";

export const chatRouter = Router();

const channelEnum = z.enum(["community", "admin", "seller"]);

const uploadDir = path.join(process.cwd(), "uploads", "chat");
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname) || ".bin";
    cb(null, `${randomUUID()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 12 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ok =
      /^image\/(jpeg|png|webp|gif)$/i.test(file.mimetype) ||
      /^audio\//i.test(file.mimetype) ||
      /\.(jpe?g|png|webp|gif|m4a|aac|mp3|caf|wav)$/i.test(file.originalname);
    cb(null, ok);
  },
});

chatRouter.post(
  "/upload",
  requireMemberOrAdmin,
  upload.single("file"),
  (req: AuthedRequest, res) => {
    if (!req.file?.filename) {
      return res.status(400).json({ error: "No file" });
    }
    const mime = req.file.mimetype;
    let mediaKind: "image" | "voice" | "unknown" = "unknown";
    if (mime.startsWith("image/")) mediaKind = "image";
    else if (mime.startsWith("audio/")) mediaKind = "voice";
    const relPath = `/api/v1/chat/media/${req.file.filename}`;
    res.status(201).json({ path: relPath, mediaKind });
  },
);

chatRouter.get("/:channel", requireMemberOrAdmin, async (req, res) => {
  const ch = channelEnum.safeParse(req.params.channel);
  if (!ch.success) return res.status(400).json({ error: "Invalid channel" });
  const take = Math.min(Number(req.query.limit) || 100, 500);
  const list = await prisma.chatMessage.findMany({
    where: { channel: ch.data as ChatChannel },
    orderBy: { createdAt: "desc" },
    take,
    include: {
      user: {
        select: {
          avatarUrl: true,
        },
      },
    },
  });
  res.json(
    list
      .reverse()
      .map(({ user, ...msg }) => ({
        ...msg,
        avatarUrl: user?.avatarUrl ?? null,
      })),
  );
});

const sendBody = z
  .object({
    fromLabel: z.string().min(1),
    text: z.preprocess((val) => (val == null ? "" : String(val)), z.string()),
    timeLabel: z.string().min(1),
    emoji: z.string().optional(),
    mediaKind: z.enum(["text", "image", "voice"]).optional(),
    imageUrl: z.string().optional(),
    voiceUrl: z.string().optional(),
    voiceDurationSec: z.coerce.number().int().optional(),
  })
  .superRefine((data, ctx) => {
    const mk = data.mediaKind ?? "text";
    if (mk === "text") {
      if (!data.text.trim()) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "text required for text messages" });
      }
    } else if (mk === "image") {
      if (!data.imageUrl?.trim()) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "imageUrl required" });
      }
    } else if (mk === "voice") {
      if (!data.voiceUrl?.trim()) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "voiceUrl required" });
      }
    }
  });

chatRouter.post("/:channel", requireMember, async (req: AuthedRequest, res) => {
  const ch = channelEnum.safeParse(req.params.channel);
  if (!ch.success) return res.status(400).json({ error: "Invalid channel" });
  const parsed = sendBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const settings = await prisma.appSettings.findUnique({ where: { id: 1 } });
  if (ch.data === "community" && settings && !settings.jamiiCommunityChatMembersCanSend) {
    return res.status(403).json({ error: "Community chat is locked for members" });
  }

  const mk = (parsed.data.mediaKind ?? "text") as ChatMediaKind;
  const rawText = parsed.data.text.trim();
  const msg = await prisma.chatMessage.create({
    data: {
      channel: ch.data as ChatChannel,
      fromLabel: parsed.data.fromLabel,
      text: mk === "text" ? rawText : rawText,
      timeLabel: parsed.data.timeLabel,
      emoji: parsed.data.emoji,
      mediaKind: mk,
      imageUrl: parsed.data.imageUrl?.trim() || null,
      voiceUrl: parsed.data.voiceUrl?.trim() || null,
      voiceDurationSec: parsed.data.voiceDurationSec ?? null,
      userId: req.memberId,
      isFromMe: true,
    },
  });
  res.status(201).json(msg);
});
