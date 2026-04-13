import path from "path";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import { healthRouter } from "./routes/health";
import { authRouter } from "./routes/auth";
import { memberMeRouter } from "./routes/member_me";
import { productsRouter } from "./routes/products";
import { ordersRouter } from "./routes/orders";
import { postsRouter } from "./routes/posts";
import { eventsRouter } from "./routes/events";
import { chatRouter } from "./routes/chat";
import { settingsRouter } from "./routes/settings";
import { adminConsoleRouter } from "./routes/admin_console";
import { memberServicesRouter } from "./routes/member_services";
import { pollsPublicRouter } from "./routes/polls_public";

function parseOrigins(): string[] | boolean {
  const raw = process.env.CORS_ORIGINS;
  if (!raw || raw === "*") return true;
  return raw.split(",").map((s) => s.trim()).filter(Boolean);
}

export function createApp() {
  const app = express();
  app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
  app.use(
    cors({
      origin: parseOrigins(),
      credentials: true,
    }),
  );
  app.use(express.json({ limit: "2mb" }));

  app.use("/health", healthRouter);

  const v1 = "/api/v1";
  app.use(
    `${v1}/chat/media`,
    express.static(path.join(process.cwd(), "uploads", "chat"), { index: false }),
  );
  app.use(
    `${v1}/me/media`,
    express.static(path.join(process.cwd(), "uploads", "avatars"), { index: false }),
  );
  app.use(`${v1}/auth`, authRouter);
  app.use(`${v1}/me`, memberMeRouter);
  app.use(`${v1}/products`, productsRouter);
  app.use(`${v1}/orders`, ordersRouter);
  app.use(`${v1}/posts`, postsRouter);
  app.use(`${v1}/events`, eventsRouter);
  app.use(`${v1}/chat`, chatRouter);
  app.use(`${v1}/settings`, settingsRouter);
  app.use(`${v1}/admin`, adminConsoleRouter);
  app.use(`${v1}/member`, memberServicesRouter);
  app.use(`${v1}/polls`, pollsPublicRouter);

  app.use((_req, res) => {
    res.status(404).json({ error: "Not found" });
  });

  return app;
}
