import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireMember } from "../middleware/auth";

export const memberServicesRouter = Router();

memberServicesRouter.use(requireMember);

const tickBody = z.object({
  tickCount: z.coerce.number().int().min(1),
});

memberServicesRouter.post("/tick-payments", async (req: AuthedRequest, res) => {
  const parsed = tickBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const p = await prisma.pendingTickPayment.create({
    data: {
      userId: req.memberId!,
      tickCount: parsed.data.tickCount,
    },
  });
  res.status(201).json(p);
});

memberServicesRouter.get("/tick-payments/active", async (req: AuthedRequest, res) => {
  const p = await prisma.pendingTickPayment.findFirst({
    where: { userId: req.memberId! },
    orderBy: { submittedAt: "desc" },
  });
  res.json(p);
});

const voteBody = z.object({
  optionIdx: z.coerce.number().int().min(0),
});

memberServicesRouter.post("/polls/:id/vote", async (req: AuthedRequest, res) => {
  const pollId = String(req.params.id);
  const parsed = voteBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    await prisma.pollVote.create({
      data: {
        pollId,
        userId: req.memberId!,
        optionIdx: parsed.data.optionIdx,
      },
    });
    res.status(201).json({ ok: true });
  } catch {
    res.status(409).json({ error: "Already voted or invalid poll" });
  }
});
