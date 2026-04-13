import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import type { AuthedRequest } from "../middleware/auth";
import { requireMember } from "../middleware/auth";
import { ChatChannel, ChatMediaKind } from "@prisma/client";

export const chatRouter = Router();

const channelEnum = z.enum(["community", "admin", "seller"]);

chatRouter.get("/:channel", async (req, res) => {
  const ch = channelEnum.safeParse(req.params.channel);
  if (!ch.success) return res.status(400).json({ error: "Invalid channel" });
  const take = Math.min(Number(req.query.limit) || 100, 500);
  const list = await prisma.chatMessage.findMany({
    where: { channel: ch.data as ChatChannel },
    orderBy: { createdAt: "desc" },
    take,
  });
  res.json(list.reverse());
});

const sendBody = z.object({
  fromLabel: z.string().min(1),
  text: z.string().min(1),
  timeLabel: z.string().min(1),
  emoji: z.string().optional(),
  mediaKind: z.enum(["text", "image", "voice"]).optional(),
  imageUrl: z.string().optional(),
  voiceUrl: z.string().optional(),
  voiceDurationSec: z.coerce.number().int().optional(),
});

chatRouter.post("/:channel", requireMember, async (req: AuthedRequest, res) => {
  const ch = channelEnum.safeParse(req.params.channel);
  if (!ch.success) return res.status(400).json({ error: "Invalid channel" });
  const parsed = sendBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const settings = await prisma.appSettings.findUnique({ where: { id: 1 } });
  if (
    ch.data === "community" &&
    settings &&
    !settings.jamiiCommunityChatMembersCanSend
  ) {
    return res.status(403).json({ error: "Community chat is locked for members" });
  }

  const mk = parsed.data.mediaKind ?? "text";
  const msg = await prisma.chatMessage.create({
    data: {
      channel: ch.data as ChatChannel,
      fromLabel: parsed.data.fromLabel,
      text: parsed.data.text,
      timeLabel: parsed.data.timeLabel,
      emoji: parsed.data.emoji,
      mediaKind: mk as ChatMediaKind,
      imageUrl: parsed.data.imageUrl,
      voiceUrl: parsed.data.voiceUrl,
      voiceDurationSec: parsed.data.voiceDurationSec,
      userId: req.memberId,
      isFromMe: true,
    },
  });
  res.status(201).json(msg);
});
