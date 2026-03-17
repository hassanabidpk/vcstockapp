import { config } from "../../../config/index.js";
import { logger } from "../../../utils/logger.js";
import { getSystemPrompt } from "./prompts.js";
import type { CollectedData, AnalysisResult } from "../types.js";

const AGENT_TIMEOUT_MS = 120_000;

function parseHoldingActions(raw: unknown): { symbol: string; action: string; reasoning: string }[] {
  const validActions = new Set(["hold", "trim", "accumulate", "watch"]);
  if (!Array.isArray(raw)) return [];
  return raw
    .filter((a: Record<string, unknown>) => a.symbol && a.reasoning)
    .map((a: Record<string, unknown>) => ({
      symbol: String(a.symbol),
      action: validActions.has(String(a.action)) ? String(a.action) : "watch",
      reasoning: String(a.reasoning),
    }));
}

function parseAnalysisResult(text: string): AnalysisResult {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);

      const portfolioAnalyses = Array.isArray(parsed.portfolioAnalyses)
        ? parsed.portfolioAnalyses.map((pa: Record<string, unknown>) => ({
            portfolioName: String(pa.portfolioName || "Unknown"),
            holdingActions: parseHoldingActions(pa.holdingActions),
            risks: String(pa.risks || "No risk assessment available."),
            outlook: String(pa.outlook || "No outlook available."),
          }))
        : [];

      return {
        marketOverview: parsed.marketOverview || "No market overview available.",
        portfolioAnalyses,
      };
    }
  } catch {
    logger.warn("Failed to parse agent JSON output, using raw text");
  }

  return {
    marketOverview: text || "No analysis available.",
    portfolioAnalyses: [],
  };
}

export const aiAnalyzerService = {
  async analyze(data: CollectedData): Promise<AnalysisResult | null> {
    const startTime = Date.now();
    logger.info({ reportType: data.reportType }, "AIAnalyzer: starting analysis");

    if (!config.googleCloudProject || !config.googleCredentialsJson) {
      logger.warn("Google Cloud credentials not configured, skipping AI analysis");
      return null;
    }

    try {
      const { LlmAgent, Runner, InMemorySessionService, GOOGLE_SEARCH } = await import("@google/adk");

      // Decode base64 credentials and write to temp file for Google Auth
      const credentialsJson = Buffer.from(config.googleCredentialsJson, "base64").toString("utf-8");
      JSON.parse(credentialsJson); // validate it's valid JSON

      const os = await import("node:os");
      const fs = await import("node:fs");
      const path = await import("node:path");
      const tmpFile = path.join(os.tmpdir(), `gcp-creds-${Date.now()}.json`);
      fs.writeFileSync(tmpFile, credentialsJson, { mode: 0o600 });

      // Set env vars for Google Cloud auth
      process.env.GOOGLE_APPLICATION_CREDENTIALS = tmpFile;
      process.env.GOOGLE_CLOUD_PROJECT = config.googleCloudProject;
      process.env.GOOGLE_CLOUD_LOCATION = config.googleCloudLocation;
      process.env.GOOGLE_GENAI_USE_VERTEXAI = "true";

      const portfolioNames = data.portfolios.map((p) => p.name);
      const systemPrompt = getSystemPrompt(data.reportType, portfolioNames);

      const agent = new LlmAgent({
        name: "portfolio_analyst",
        model: config.geminiModel,
        instruction: systemPrompt,
        tools: [GOOGLE_SEARCH],
      });

      const sessionService = new InMemorySessionService();
      const runner = new Runner({
        appName: "vc-stocks-reports",
        agent,
        sessionService,
      });

      const contextMessage = `Here is the current portfolio data:\n${JSON.stringify(data, null, 2)}\n\nPlease analyze this data and generate a ${data.reportType} report.`;

      const runPromise = (async () => {
        let lastText = "";
        const session = await sessionService.createSession({
          appName: "vc-stocks-reports",
          userId: "report-system",
        });

        const events = runner.runAsync({
          userId: "report-system",
          sessionId: session.id,
          newMessage: {
            role: "user",
            parts: [{ text: contextMessage }],
          },
        });

        let eventCount = 0;
        for await (const event of events) {
          eventCount++;
          const evt = event as unknown as Record<string, unknown>;
          if (evt.errorCode || evt.errorMessage) {
            logger.error({ errorCode: evt.errorCode, errorMessage: evt.errorMessage }, "AIAnalyzer: agent event error");
          }
          logger.info({ eventCount, author: event.author }, "AIAnalyzer: event received");
          if (event.content?.parts) {
            for (const part of event.content.parts) {
              if ("text" in part && part.text) {
                lastText = part.text;
                logger.info({ textLength: part.text.length, preview: part.text.substring(0, 200) }, "AIAnalyzer: got text");
              }
            }
          }
        }

        logger.info({ eventCount, hasText: !!lastText, textLength: lastText.length }, "AIAnalyzer: agent run complete");
        return lastText;
      })();

      const timeoutPromise = new Promise<null>((resolve) =>
        setTimeout(() => {
          logger.warn({ timeoutMs: AGENT_TIMEOUT_MS }, "AIAnalyzer: agent timed out");
          resolve(null);
        }, AGENT_TIMEOUT_MS)
      );

      const result = await Promise.race([runPromise, timeoutPromise]);

      if (!result) {
        logger.warn("AIAnalyzer: no text returned from agent");
        return null;
      }

      const duration = Date.now() - startTime;
      logger.info({ reportType: data.reportType, duration }, "AIAnalyzer: done");

      return parseAnalysisResult(result);
    } catch (err) {
      logger.error({ err }, "AIAnalyzer: failed");
      return null;
    } finally {
      // Clean up temp credentials file
      try {
        const tmpFile = process.env.GOOGLE_APPLICATION_CREDENTIALS;
        if (tmpFile?.includes("gcp-creds-")) {
          const fs = await import("node:fs");
          fs.unlinkSync(tmpFile);
          delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
        }
      } catch { /* ignore cleanup errors */ }
    }
  },
};
