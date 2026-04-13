import crypto from "crypto";
import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { sendNewPasswordEmail } from "../lib/mail";
import { signAdminToken, signMemberToken } from "../lib/jwt";

export const authRouter = Router();

function sha256hex(s: string): string {
  return crypto.createHash("sha256").update(s, "utf8").digest("hex");
}

const registerBody = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  phone: z.string().min(8),
  location: z.string().min(1),
  children: z.coerce.number().int().min(0),
  username: z.string().min(2),
  password: z.string().min(8),
  detailLines: z.string().optional(),
});

authRouter.post("/register", async (req, res) => {
  const parsed = registerBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const { name, email, phone, location, children, username, password, detailLines } = parsed.data;
  const emailNorm = email.trim().toLowerCase();
  const exists = await prisma.user.findFirst({
    where: {
      OR: [{ phone }, { username }, { email: emailNorm }],
    },
  });
  if (exists) return res.status(409).json({ error: "Phone, email, or username already registered" });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name,
      email: emailNorm,
      phone,
      location,
      children,
      username,
      passwordHash,
      status: "pending",
    },
  });

  await prisma.pendingSignup.create({
    data: {
      fullName: name,
      phone,
      location,
      username,
      children,
      detailLines: detailLines ?? "",
    },
  });

  const token = signMemberToken(user.id);
  return res.status(201).json({
    token,
    user: publicUser(user),
  });
});

const loginBody = z.object({
  identifier: z.string().min(1),
  password: z.string().min(1),
});

authRouter.post("/login", async (req, res) => {
  const parsed = loginBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const idRaw = parsed.data.identifier.trim();
  const idLower = idRaw.toLowerCase();
  const user = await prisma.user.findFirst({
    where: {
      OR: [{ phone: idRaw }, { email: idLower }, { username: idLower }],
    },
  });
  if (!user) return res.status(401).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(parsed.data.password, user.passwordHash);
  if (!ok) return res.status(401).json({ error: "Invalid credentials" });

  const token = signMemberToken(user.id);
  return res.json({ token, user: publicUser(user) });
});

const forgotBody = z.object({
  email: z.string().email(),
});

authRouter.post("/forgot-password", async (req, res) => {
  const parsed = forgotBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const email = parsed.data.email.trim().toLowerCase();
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    return res.json({ ok: true, message: "If this email exists, we sent a reset link." });
  }

  const generatedPassword = crypto.randomBytes(9).toString("base64url");
  const passwordHash = await bcrypt.hash(generatedPassword, 10);
  await prisma.$transaction([
    prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    }),
    prisma.passwordResetToken.deleteMany({
      where: { userId: user.id },
    }),
  ]);
  await sendNewPasswordEmail(user.email ?? email, generatedPassword);

  return res.json({
    ok: true,
    message: "If this email exists, we sent a new password.",
  });
});

const resetBody = z.object({
  token: z.string().min(10),
  newPassword: z.string().min(8),
});

authRouter.post("/reset-password", async (req, res) => {
  const parsed = resetBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const tokenHash = sha256hex(parsed.data.token);
  const row = await prisma.passwordResetToken.findUnique({
    where: { tokenHash },
  });
  if (!row || row.expiresAt < new Date()) {
    return res.status(400).json({ error: "Invalid or expired reset link" });
  }

  const passwordHash = await bcrypt.hash(parsed.data.newPassword, 10);
  await prisma.$transaction([
    prisma.user.update({
      where: { id: row.userId },
      data: { passwordHash },
    }),
    prisma.passwordResetToken.delete({ where: { id: row.id } }),
  ]);

  return res.json({ ok: true, message: "Password updated. You can sign in now." });
});

/** GET variant for email links (browser) — forwards token to same logic */
authRouter.get("/reset-password", async (req, res) => {
  const token = typeof req.query.token === "string" ? req.query.token : "";
  if (!token) return res.status(400).send("Missing token");
  return res
    .status(200)
    .type("html")
    .send(
      `<!DOCTYPE html><html><head><meta charset="utf-8"><title>Set password</title></head><body style="font-family:system-ui;padding:24px;">` +
        `<p>Open the Nyiha app and use “Nenosiri jipya” with this token, or POST JSON to <code>/api/v1/auth/reset-password</code> with <code>token</code> and <code>newPassword</code>.</p>` +
        `<p><strong>Token (one-time):</strong></p><textarea readonly rows="4" style="width:100%;">${token}</textarea></body></html>`,
    );
});

const adminLoginBody = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

authRouter.post("/admin/login", async (req, res) => {
  const parsed = adminLoginBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const email = parsed.data.email.trim().toLowerCase();
  const admin = await prisma.adminUser.findUnique({ where: { email } });
  if (!admin) return res.status(401).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(parsed.data.password, admin.passwordHash);
  if (!ok) return res.status(401).json({ error: "Invalid credentials" });

  const token = signAdminToken(admin.id, admin.role);
  return res.json({
    token,
    admin: {
      id: admin.id,
      displayName: admin.displayName,
      email: admin.email,
      role: admin.role,
      linkedMemberPhone: admin.linkedMemberPhone,
    },
  });
});

function publicUser(u: {
  id: string;
  name: string;
  phone: string;
  email: string | null;
  avatarUrl: string | null;
  location: string;
  children: number;
  status: string;
  ticksPaid: number;
  balance: number;
  username: string;
}) {
  return {
    id: u.id,
    name: u.name,
    phone: u.phone,
    email: u.email,
    avatarUrl: u.avatarUrl,
    location: u.location,
    children: u.children,
    status: u.status,
    ticksPaid: u.ticksPaid,
    balance: u.balance,
    username: u.username,
  };
}
