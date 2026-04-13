import jwt, { type Secret, type SignOptions } from "jsonwebtoken";

const JWT_SECRET: Secret = process.env.JWT_SECRET ?? "dev-only-change-me";

export type MemberJwtPayload = { sub: string; typ: "member" };
export type AdminJwtPayload = { sub: string; typ: "admin"; role: string };

export function signMemberToken(userId: string, expiresIn: SignOptions["expiresIn"] = "30d"): string {
  const opts: SignOptions = { expiresIn };
  return jwt.sign({ sub: userId, typ: "member" } satisfies MemberJwtPayload, JWT_SECRET, opts);
}

export function signAdminToken(
  adminId: string,
  role: string,
  expiresIn: SignOptions["expiresIn"] = "12h",
): string {
  const opts: SignOptions = { expiresIn };
  return jwt.sign({ sub: adminId, typ: "admin", role } satisfies AdminJwtPayload, JWT_SECRET, opts);
}

export function verifyMemberToken(token: string): MemberJwtPayload {
  const p = jwt.verify(token, JWT_SECRET) as MemberJwtPayload;
  if (p.typ !== "member") throw new Error("invalid token type");
  return p;
}

export function verifyAdminToken(token: string): AdminJwtPayload {
  const p = jwt.verify(token, JWT_SECRET) as AdminJwtPayload;
  if (p.typ !== "admin") throw new Error("invalid token type");
  return p;
}
