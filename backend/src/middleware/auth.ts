import type { Request, Response, NextFunction } from "express";
import { verifyAdminToken, verifyMemberToken } from "../lib/jwt";

export type AuthedRequest = Request & {
  memberId?: string;
  adminId?: string;
  adminRole?: string;
};

function bearer(req: Request): string | null {
  const h = req.headers.authorization;
  if (!h?.startsWith("Bearer ")) return null;
  return h.slice(7);
}

export function requireMember(req: AuthedRequest, res: Response, next: NextFunction) {
  const t = bearer(req);
  if (!t) return res.status(401).json({ error: "Missing Bearer token" });
  try {
    const p = verifyMemberToken(t);
    req.memberId = p.sub;
    next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

export function requireAdmin(req: AuthedRequest, res: Response, next: NextFunction) {
  const t = bearer(req);
  if (!t) return res.status(401).json({ error: "Missing Bearer token" });
  try {
    const p = verifyAdminToken(t);
    req.adminId = p.sub;
    req.adminRole = p.role;
    next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

export function requireMainAdmin(req: AuthedRequest, res: Response, next: NextFunction) {
  requireAdmin(req, res, () => {
    if (req.adminRole !== "main") {
      return res.status(403).json({ error: "Main admin only" });
    }
    next();
  });
}
