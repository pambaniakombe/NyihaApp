import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAdmin } from "../middleware/auth";

export const eventsRouter = Router();

eventsRouter.get("/", async (_req, res) => {
  const list = await prisma.jamiiEvent.findMany({ orderBy: { sortOrder: "asc" } });
  res.json(list);
});

const body = z.object({
  title: z.string().min(1),
  desc: z.string().min(1),
  date: z.string().min(1),
  tag: z.string().min(1),
  sortOrder: z.coerce.number().int().optional(),
});

eventsRouter.post("/", requireAdmin, async (req, res) => {
  const parsed = body.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const e = await prisma.jamiiEvent.create({
    data: { ...parsed.data, sortOrder: parsed.data.sortOrder ?? 0 },
  });
  res.status(201).json(e);
});

eventsRouter.patch("/:id", requireAdmin, async (req, res) => {
  const id = String(req.params.id);
  const parsed = body.partial().safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const e = await prisma.jamiiEvent.update({
      where: { id },
      data: parsed.data,
    });
    res.json(e);
  } catch {
    res.status(404).json({ error: "Event not found" });
  }
});

eventsRouter.delete("/:id", requireAdmin, async (req, res) => {
  const id = String(req.params.id);
  try {
    await prisma.jamiiEvent.delete({ where: { id } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: "Event not found" });
  }
});
