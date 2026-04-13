import { Router } from "express";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireMember } from "../middleware/auth";

export const memberMeRouter = Router();

memberMeRouter.use(requireMember);

memberMeRouter.get("/", async (req: AuthedRequest, res) => {
  const id = req.memberId;
  if (!id) return res.status(401).json({ error: "Unauthorized" });
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) return res.status(404).json({ error: "User not found" });
  res.json({
    id: user.id,
    name: user.name,
    phone: user.phone,
    location: user.location,
    children: user.children,
    status: user.status,
    ticksPaid: user.ticksPaid,
    balance: user.balance,
    username: user.username,
  });
});
