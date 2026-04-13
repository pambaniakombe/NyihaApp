import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAdmin } from "../middleware/auth";

export const productsRouter = Router();

productsRouter.get("/", async (_req, res) => {
  const list = await prisma.product.findMany({ orderBy: { sortOrder: "asc" } });
  res.json(list);
});

const upsertBody = z.object({
  name: z.string().min(1),
  priceLabel: z.string().min(1),
  emoji: z.string().min(1),
  color: z.coerce.number().int(),
  imageUrl: z.string().url(),
  sortOrder: z.coerce.number().int().optional(),
});

productsRouter.post("/", requireAdmin, async (req, res) => {
  const parsed = upsertBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const p = await prisma.product.create({
    data: {
      ...parsed.data,
      sortOrder: parsed.data.sortOrder ?? 0,
    },
  });
  res.status(201).json(p);
});

productsRouter.patch("/:id", requireAdmin, async (req, res) => {
  const id = String(req.params.id);
  const parsed = upsertBody.partial().safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const p = await prisma.product.update({
      where: { id },
      data: parsed.data,
    });
    res.json(p);
  } catch {
    res.status(404).json({ error: "Product not found" });
  }
});

productsRouter.delete("/:id", requireAdmin, async (req, res) => {
  const id = String(req.params.id);
  try {
    await prisma.product.delete({ where: { id } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: "Product not found" });
  }
});
