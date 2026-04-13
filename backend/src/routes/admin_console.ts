import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireAdmin, requireMainAdmin } from "../middleware/auth";
import { ChatChannel, ChatMediaKind } from "@prisma/client";

export const adminConsoleRouter = Router();

adminConsoleRouter.use(requireAdmin);

adminConsoleRouter.get("/members", async (_req, res) => {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      name: true,
      phone: true,
      location: true,
      ticksPaid: true,
      status: true,
      username: true,
      balance: true,
      adminProfileNote: true,
      adminWarning: true,
    },
  });
  const settings = await prisma.appSettings.findUnique({ where: { id: 1 } });
  const reqAnnual = settings?.ticksRequiredAnnual ?? 24;
  const withEmoji = users.map((u) => ({
    ...u,
    emoji: "👤",
    ticks: u.ticksPaid,
    ticksRequiredAnnual: reqAnnual,
    ticksOwed: Math.max(0, reqAnnual - u.ticksPaid),
    hasPaidAllTicks: u.ticksPaid >= reqAnnual,
  }));
  res.json(withEmoji);
});

const memberPatchBody = z
  .object({
    status: z.enum(["pending", "approved", "suspended"]).optional(),
    ticksPaid: z.coerce.number().int().min(0).max(999999).optional(),
    /// Outstanding debt in TZS (deni).
    balance: z.coerce.number().int().min(0).max(999999999).optional(),
    adminProfileNote: z.string().max(8000).optional(),
    adminWarning: z.string().max(4000).optional(),
  })
  .refine(
    (d) =>
      d.status !== undefined ||
      d.ticksPaid !== undefined ||
      d.balance !== undefined ||
      d.adminProfileNote !== undefined ||
      d.adminWarning !== undefined,
    { message: "Provide at least one field to update" },
  );

adminConsoleRouter.patch("/members/:id", async (req, res) => {
  const id = String(req.params.id);
  const parsed = memberPatchBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const data: {
      status?: "pending" | "approved" | "suspended";
      ticksPaid?: number;
      balance?: number;
      adminProfileNote?: string;
      adminWarning?: string;
    } = {};
    if (parsed.data.status !== undefined) data.status = parsed.data.status;
    if (parsed.data.ticksPaid !== undefined) data.ticksPaid = parsed.data.ticksPaid;
    if (parsed.data.balance !== undefined) data.balance = parsed.data.balance;
    if (parsed.data.adminProfileNote !== undefined) data.adminProfileNote = parsed.data.adminProfileNote;
    if (parsed.data.adminWarning !== undefined) data.adminWarning = parsed.data.adminWarning;
    const u = await prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        name: true,
        phone: true,
        location: true,
        ticksPaid: true,
        status: true,
        username: true,
        balance: true,
        adminProfileNote: true,
        adminWarning: true,
      },
    });
    const settings = await prisma.appSettings.findUnique({ where: { id: 1 } });
    const reqAnnual = settings?.ticksRequiredAnnual ?? 24;
    res.json({
      ...u,
      emoji: "👤",
      ticks: u.ticksPaid,
      ticksRequiredAnnual: reqAnnual,
      ticksOwed: Math.max(0, reqAnnual - u.ticksPaid),
      hasPaidAllTicks: u.ticksPaid >= reqAnnual,
    });
  } catch {
    res.status(404).json({ error: "Member not found" });
  }
});

adminConsoleRouter.get("/signups/pending", async (_req, res) => {
  const list = await prisma.pendingSignup.findMany({
    where: { resolved: false },
    orderBy: { submittedAt: "desc" },
  });
  res.json(list);
});

adminConsoleRouter.post("/signups/:id/approve", async (req, res) => {
  const signupId = String(req.params.id);
  try {
    const p = await prisma.pendingSignup.findUnique({ where: { id: signupId } });
    if (!p || p.resolved) return res.status(404).json({ error: "Request not found" });
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ phone: p.phone }, { username: p.username }],
      },
    });
    if (user) {
      await prisma.user.update({
        where: { id: user.id },
        data: { status: "approved" },
      });
    }
    await prisma.pendingSignup.update({
      where: { id: p.id },
      data: { resolved: true },
    });
    res.json({ ok: true });
  } catch {
    res.status(500).json({ error: "Approve failed" });
  }
});

adminConsoleRouter.post("/signups/:id/reject", async (req, res) => {
  const signupId = String(req.params.id);
  try {
    const p = await prisma.pendingSignup.findUnique({ where: { id: signupId } });
    if (!p || p.resolved) return res.status(404).json({ error: "Request not found" });
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ phone: p.phone }, { username: p.username }],
      },
    });
    if (user) {
      await prisma.user.update({
        where: { id: user.id },
        data: { status: "suspended" },
      });
    }
    await prisma.pendingSignup.update({
      where: { id: p.id },
      data: { resolved: true },
    });
    res.json({ ok: true });
  } catch {
    res.status(500).json({ error: "Reject failed" });
  }
});

adminConsoleRouter.get("/admins", async (_req, res) => {
  const list = await prisma.adminUser.findMany({
    select: {
      id: true,
      displayName: true,
      email: true,
      role: true,
      linkedMemberPhone: true,
    },
  });
  res.json(list);
});

const newAdminBody = z.object({
  displayName: z.string().min(1),
  email: z.string().email(),
  pin: z.string().min(4),
  role: z.enum(["helper"]),
  linkedMemberPhone: z.string().optional(),
});

adminConsoleRouter.post("/admins", requireMainAdmin, async (req: AuthedRequest, res) => {
  const parsed = newAdminBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const helpers = await prisma.adminUser.count({ where: { role: "helper" } });
  if (helpers >= 2) return res.status(400).json({ error: "Max helper admins reached" });
  const passwordHash = await bcrypt.hash(parsed.data.pin, 10);
  const a = await prisma.adminUser.create({
    data: {
      displayName: parsed.data.displayName,
      email: parsed.data.email,
      passwordHash,
      role: "helper",
      linkedMemberPhone: parsed.data.linkedMemberPhone,
    },
    select: {
      id: true,
      displayName: true,
      email: true,
      role: true,
      linkedMemberPhone: true,
    },
  });
  res.status(201).json(a);
});

const adminSendBody = z
  .object({
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

adminConsoleRouter.post(
  "/chat/:channel",
  async (req: AuthedRequest, res) => {
    const ch = z.enum(["community", "admin", "seller"]).safeParse(req.params.channel);
    if (!ch.success) return res.status(400).json({ error: "Invalid channel" });
    const admin = await prisma.adminUser.findUnique({ where: { id: req.adminId! } });
    if (!admin) return res.status(401).json({ error: "Admin not found" });

    const parsed = adminSendBody.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

    const mk = (parsed.data.mediaKind ?? "text") as ChatMediaKind;
    const rawText = parsed.data.text.trim();
    const msg = await prisma.chatMessage.create({
      data: {
        channel: ch.data as ChatChannel,
        fromLabel: admin.displayName,
        text: rawText,
        timeLabel: parsed.data.timeLabel,
        emoji: parsed.data.emoji,
        mediaKind: mk,
        imageUrl: parsed.data.imageUrl?.trim() || null,
        voiceUrl: parsed.data.voiceUrl?.trim() || null,
        voiceDurationSec: parsed.data.voiceDurationSec ?? null,
        isFromMe: false,
      },
    });
    res.status(201).json(msg);
  },
);

adminConsoleRouter.get("/tick-payments/pending", async (_req, res) => {
  const list = await prisma.pendingTickPayment.findMany({
    orderBy: { submittedAt: "desc" },
  });
  res.json(list);
});

const tickPhaseBody = z.object({
  phase: z.enum(["waitingMoney", "waitingAdminApproval"]),
});

adminConsoleRouter.patch("/tick-payments/:id", async (req, res) => {
  const id = String(req.params.id);
  const parsed = tickPhaseBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const p = await prisma.pendingTickPayment.update({
      where: { id },
      data: { phase: parsed.data.phase },
    });
    res.json(p);
  } catch {
    res.status(404).json({ error: "Not found" });
  }
});

const pollsBody = z.object({
  question: z.string().min(1),
  options: z.array(z.object({ t: z.string(), v: z.coerce.number().int() })),
  sortOrder: z.coerce.number().int().optional(),
});

adminConsoleRouter.post("/polls", async (req, res) => {
  const parsed = pollsBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const poll = await prisma.poll.create({
    data: {
      question: parsed.data.question,
      options: parsed.data.options as object[],
      sortOrder: parsed.data.sortOrder ?? 0,
    },
  });
  res.status(201).json(poll);
});

adminConsoleRouter.get("/polls", async (_req, res) => {
  const list = await prisma.poll.findMany({ orderBy: { sortOrder: "asc" } });
  res.json(list);
});
