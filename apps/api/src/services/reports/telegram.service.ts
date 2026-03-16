import { config } from "../../config/index.js";
import { logger } from "../../utils/logger.js";

function getApiUrl(): string {
  return `https://api.telegram.org/bot${config.telegramBotToken}`;
}

async function sendRequest(method: string, body: Record<string, unknown>, retryCount = 0): Promise<unknown> {
  const res = await fetch(`${getApiUrl()}/${method}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (res.status === 429 && retryCount < 3) {
    const retryAfter = Number(res.headers.get("Retry-After") || "5");
    logger.warn({ method, retryAfter, retryCount }, "Telegram rate limited, retrying");
    await new Promise((r) => setTimeout(r, retryAfter * 1000));
    return sendRequest(method, body, retryCount + 1);
  }

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Telegram API error ${res.status}: ${text}`);
  }

  return res.json();
}

async function sendMessageWithRetry(chatId: string, text: string, retries = 3): Promise<void> {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      await sendRequest("sendMessage", {
        chat_id: chatId,
        text,
        parse_mode: "MarkdownV2",
      });
      return;
    } catch (err) {
      logger.error({ attempt, retries, err }, "Failed to send Telegram message");
      if (attempt === retries) {
        logger.error("All Telegram send retries exhausted");
        return;
      }
      await new Promise((r) => setTimeout(r, Math.pow(2, attempt) * 1000));
    }
  }
}

export const telegramService = {
  async sendReport(messages: string[]): Promise<void> {
    const chatId = config.telegramChatId;
    if (!chatId) {
      logger.warn("TELEGRAM_CHAT_ID not set, skipping send");
      return;
    }

    for (let i = 0; i < messages.length; i++) {
      await sendMessageWithRetry(chatId, messages[i]);
      if (i < messages.length - 1) {
        await new Promise((r) => setTimeout(r, 500));
      }
    }

    logger.info({ messageCount: messages.length }, "Report sent to Telegram");
  },

  async setWebhook(url: string): Promise<void> {
    await sendRequest("setWebhook", {
      url,
      secret_token: config.telegramWebhookSecret,
      allowed_updates: ["message"],
    });
    logger.info({ url }, "Telegram webhook set");
  },

  isValidWebhookRequest(secretToken: string | undefined): boolean {
    return secretToken === config.telegramWebhookSecret;
  },

  isAllowedChat(chatId: number | string): boolean {
    return String(chatId) === config.telegramChatId;
  },
};
