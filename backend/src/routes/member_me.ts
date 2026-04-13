import { randomUUID } from "crypto";
import fs from "fs";
import path from "path";
import { Router } from "express";
import multer from "multer";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireMember } from "../middleware/auth";

export const memberMeRouter = Router();

memberMeRouter.use(requireMember);

const avatarUploadDir = path.join(process.cwd(), "uploads", "avatars");
fs.mkdirSync(avatarUploadDir, { recursive: true });

const avatarUpload = multer({
  storage: multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, avatarUploadDir),
    filename: (_req, file, cb) => {
      const ext = path.extname(file.originalname) || ".jpg";
      cb(null, `${randomUUID()}${ext}`);
    },
  }),
  limits: { fileSize: 6 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ok = /^image\/(jpeg|png|webp|gif)$/i.test(file.mimetype);
    cb(null, ok);
  },
});

memberMeRouter.get("/", async (req: AuthedRequest, res) => {
  const id = req.memberId;
  if (!id) return res.status(401).json({ error: "Unauthorized" });
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) return res.status(404).json({ error: "User not found" });
  let settings = await prisma.appSettings.findUnique({ where: { id: 1 } });
  if (!settings) settings = await prisma.appSettings.create({ data: { id: 1 } });
  const reqAnnual = settings.ticksRequiredAnnual;
  const owed = Math.max(0, reqAnnual - user.ticksPaid);
  res.json({
    id: user.id,
    name: user.name,
    phone: user.phone,
    email: user.email,
    avatarUrl: user.avatarUrl,
    location: user.location,
    children: user.children,
    status: user.status,
    ticksPaid: user.ticksPaid,
    balance: user.balance,
    username: user.username,
    ticksRequiredAnnual: reqAnnual,
    ticksOwed: owed,
    tickPriceTzs: settings.tickPriceTzs,
    hasPaidAllTicks: user.ticksPaid >= reqAnnual,
    adminProfileNote: user.adminProfileNote,
    adminWarning: user.adminWarning,
  });
});

memberMeRouter.post(
  "/avatar",
  avatarUpload.single("file"),
  async (req: AuthedRequest, res) => {
    const id = req.memberId;
    if (!id) return res.status(401).json({ error: "Unauthorized" });
    if (!req.file?.filename) return res.status(400).json({ error: "No file" });
    const avatarUrl = `/api/v1/me/media/${req.file.filename}`;
    const user = await prisma.user.update({
      where: { id },
      data: { avatarUrl },
      select: {
        id: true,
        avatarUrl: true,
      },
    });
    res.status(201).json(user);
  },
);
