import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAdmin } from "../middleware/auth";

export const settingsRouter = Router();

settingsRouter.get("/", async (_req, res) => {
  let s = await prisma.appSettings.findUnique({ where: { id: 1 } });
  if (!s) {
    s = await prisma.appSettings.create({ data: { id: 1 } });
  }
  res.json(s);
});

const patchBody = z.object({
  customerCarePhone: z.string().optional(),
  customerCareWhatsApp: z.string().optional(),
  customerCareHoursLabel: z.string().optional(),
  jamiiCommunityChatMembersCanSend: z.boolean().optional(),
  showUserTabHome: z.boolean().optional(),
  showUserTabJamii: z.boolean().optional(),
  showUserTabDuka: z.boolean().optional(),
  showUserTabProfile: z.boolean().optional(),
  showJamiiMazungumzo: z.boolean().optional(),
  showJamiiAdminChat: z.boolean().optional(),
  showJamiiWanachama: z.boolean().optional(),
  showJamiiMatukio: z.boolean().optional(),
  showJamiiMkeka: z.boolean().optional(),
  showJamiiKura: z.boolean().optional(),
  ticksRequiredAnnual: z.coerce.number().int().optional(),
  tickPriceTzs: z.coerce.number().int().optional(),
});

settingsRouter.patch("/", requireAdmin, async (req, res) => {
  const parsed = patchBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  let s = await prisma.appSettings.findUnique({ where: { id: 1 } });
  if (!s) s = await prisma.appSettings.create({ data: { id: 1 } });
  s = await prisma.appSettings.update({
    where: { id: 1 },
    data: parsed.data,
  });
  res.json(s);
});
