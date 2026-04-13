import { Router } from "express";
import { prisma } from "../lib/prisma";

export const pollsPublicRouter = Router();

pollsPublicRouter.get("/", async (_req, res) => {
  const list = await prisma.poll.findMany({ orderBy: { sortOrder: "asc" } });
  res.json(list);
});
