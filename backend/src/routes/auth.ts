import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { signAdminToken, signMemberToken } from "../lib/jwt";

export const authRouter = Router();

const registerBody = z.object({
  name: z.string().min(1),
  phone: z.string().min(8),
  location: z.string().min(1),
  children: z.coerce.number().int().min(0),
  username: z.string().min(2),
  password: z.string().min(6),
});

authRouter.post("/register", async (req, res) => {
  const parsed = registerBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const { name, phone, location, children, username, password } = parsed.data;
  const exists = await prisma.user.findFirst({
    where: { OR: [{ phone }, { username }] },
  });
  if (exists) return res.status(409).json({ error: "Phone or username already registered" });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name,
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
      detailLines: "",
    },
  });

  const token = signMemberToken(user.id);
  return res.status(201).json({
    token,
    user: publicUser(user),
  });
});

const loginBody = z.object({
  phone: z.string().min(1),
  password: z.string().min(1),
});

authRouter.post("/login", async (req, res) => {
  const parsed = loginBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const user = await prisma.user.findUnique({ where: { phone: parsed.data.phone } });
  if (!user) return res.status(401).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(parsed.data.password, user.passwordHash);
  if (!ok) return res.status(401).json({ error: "Invalid credentials" });

  const token = signMemberToken(user.id);
  return res.json({ token, user: publicUser(user) });
});

const adminLoginBody = z.object({
  email: z.string().email(),
  pin: z.string().min(1),
});

/** Admin login uses email + PIN (matches Flutter demo); stored as bcrypt hash. */
authRouter.post("/admin/login", async (req, res) => {
  const parsed = adminLoginBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const admin = await prisma.adminUser.findUnique({ where: { email: parsed.data.email } });
  if (!admin) return res.status(401).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(parsed.data.pin, admin.passwordHash);
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
    location: u.location,
    children: u.children,
    status: u.status,
    ticksPaid: u.ticksPaid,
    balance: u.balance,
    username: u.username,
  };
}
