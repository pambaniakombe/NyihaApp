import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/", (_req, res) => {
  res.json({ ok: true, service: "nyiha-society-api" });
});

healthRouter.get("/ready", (_req, res) => {
  res.json({ ready: true });
});
