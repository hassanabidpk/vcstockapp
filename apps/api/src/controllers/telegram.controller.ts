import type { Request, Response, NextFunction } from "express";
import { telegramService } from "../services/reports/telegram.service.js";
import { reportService } from "../services/reports/report.service.js";
import { logger } from "../utils/logger.js";
import type { ReportType } from "../services/reports/types.js";

const lastRequestTime = new Map<string, number>();
const RATE_LIMIT_MS = 5 * 60 * 1000;

export const telegramController = {
  async handleWebhook(req: Request, res: Response, _next: NextFunction) {
    const secretToken = req.headers["x-telegram-bot-api-secret-token"] as string | undefined;
    if (!telegramService.isValidWebhookRequest(secretToken)) {
      logger.warn("Invalid Telegram webhook secret");
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid webhook secret" } });
    }

    try {
      const update = req.body;
      const message = update?.message;
      if (!message?.text || !message?.chat?.id) {
        return res.status(200).json({ ok: true });
      }

      const chatId = String(message.chat.id);

      if (!telegramService.isAllowedChat(chatId)) {
        logger.warn({ chatId }, "Telegram message from unauthorized chat");
        return res.status(200).json({ ok: true });
      }

      const command = message.text.trim().toLowerCase();
      let reportType: ReportType | null = null;

      if (command === "/daily") reportType = "daily";
      else if (command === "/weekly") reportType = "weekly";
      else return res.status(200).json({ ok: true });

      const lastTime = lastRequestTime.get(chatId) || 0;
      if (Date.now() - lastTime < RATE_LIMIT_MS) {
        logger.info({ chatId, command }, "Rate limited Telegram command");
        return res.status(200).json({ ok: true });
      }
      lastRequestTime.set(chatId, Date.now());

      logger.info({ chatId, command: reportType }, "Processing Telegram report command");
      await reportService.generate(reportType);

      logger.info({ chatId, command: reportType }, "Telegram report command completed");
      return res.status(200).json({ ok: true });
    } catch (err) {
      logger.error({ err }, "Error processing Telegram webhook");
      return res.status(200).json({ ok: true });
    }
  },
};
