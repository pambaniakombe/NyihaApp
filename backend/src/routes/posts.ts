import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireAdmin, requireMember } from "../middleware/auth";

export const postsRouter = Router();

postsRouter.get("/", async (_req, res) => {
  const list = await prisma.communityPost.findMany({ orderBy: { createdAt: "desc" } });
  res.json(list);
});

const createBody = z.object({
  authorLabel: z.string().min(1),
  headline: z.string().min(1),
  body: z.string().min(1),
  dateLabel: z.string().min(1),
  tag: z.string().min(1),
  imageUrls: z.array(z.string()).optional(),
});

postsRouter.post("/", requireAdmin, async (req: AuthedRequest, res) => {
  const parsed = createBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const p = await prisma.communityPost.create({
    data: {
      ...parsed.data,
      imageUrls: parsed.data.imageUrls ?? [],
    },
  });
  res.status(201).json(p);
});

postsRouter.patch("/:id", requireAdmin, async (req: AuthedRequest, res) => {
  const id = String(req.params.id);
  const parsed = createBody.partial().safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const p = await prisma.communityPost.update({
      where: { id },
      data: parsed.data as Record<string, unknown>,
    });
    res.json(p);
  } catch {
    res.status(404).json({ error: "Post not found" });
  }
});

postsRouter.delete("/:id", requireAdmin, async (req: AuthedRequest, res) => {
  const id = String(req.params.id);
  try {
    await prisma.communityPost.delete({ where: { id } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: "Post not found" });
  }
});

const reactBody = z.object({
  kind: z.string().min(1),
});

postsRouter.post("/:id/reactions", requireMember, async (req: AuthedRequest, res) => {
  const postId = String(req.params.id);
  const parsed = reactBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const r = await prisma.postReaction.upsert({
      where: {
        postId_userId_kind: {
          postId,
          userId: req.memberId!,
          kind: parsed.data.kind,
        },
      },
      create: {
        postId,
        userId: req.memberId!,
        kind: parsed.data.kind,
      },
      update: {},
    });
    res.status(201).json(r);
  } catch {
    res.status(404).json({ error: "Post not found" });
  }
});

postsRouter.get("/:id/reactions/counts", async (req, res) => {
  const postId = String(req.params.id);
  const rows = await prisma.postReaction.groupBy({
    by: ["kind"],
    where: { postId },
    _count: { kind: true },
  });
  const counts: Record<string, number> = {};
  for (const r of rows) counts[r.kind] = r._count.kind;
  res.json(counts);
});
