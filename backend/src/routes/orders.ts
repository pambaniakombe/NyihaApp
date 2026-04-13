import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireAdmin, requireMember } from "../middleware/auth";

export const ordersRouter = Router();

const placeBody = z.object({
  productId: z.string().optional(),
  productName: z.string().min(1),
  priceLabel: z.string().min(1),
  size: z.string().min(1),
  rangi: z.string().min(1),
  idadi: z.coerce.number().int().min(1),
  buyerName: z.string().min(1),
});

ordersRouter.post("/", requireMember, async (req: AuthedRequest, res) => {
  const parsed = placeBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const o = await prisma.order.create({
    data: {
      userId: req.memberId,
      productId: parsed.data.productId,
      productName: parsed.data.productName,
      priceLabel: parsed.data.priceLabel,
      size: parsed.data.size,
      rangi: parsed.data.rangi,
      idadi: parsed.data.idadi,
      buyerName: parsed.data.buyerName,
    },
  });
  res.status(201).json(o);
});

ordersRouter.get("/mine", requireMember, async (req: AuthedRequest, res) => {
  const list = await prisma.order.findMany({
    where: { userId: req.memberId },
    orderBy: { placedAt: "desc" },
  });
  res.json(list);
});

ordersRouter.get("/", requireAdmin, async (_req, res) => {
  const list = await prisma.order.findMany({
    orderBy: { placedAt: "desc" },
    include: { user: { select: { phone: true, name: true } } },
  });
  res.json(list);
});

const patchStatus = z.object({
  status: z.enum(["inasubiri_malipo", "confirmed", "cancelled"]),
});

ordersRouter.patch("/:id", requireAdmin, async (req, res) => {
  const id = String(req.params.id);
  const parsed = patchStatus.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const o = await prisma.order.update({
      where: { id },
      data: { status: parsed.data.status },
    });
    res.json(o);
  } catch {
    res.status(404).json({ error: "Order not found" });
  }
});
