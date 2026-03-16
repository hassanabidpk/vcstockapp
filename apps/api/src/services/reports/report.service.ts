import { logger } from "../../utils/logger.js";
import { dataCollectorService } from "./data-collector.service.js";
import { aiAnalyzerService } from "./ai-analyzer/agent.js";
import { reportFormatterService } from "./report-formatter.service.js";
import { telegramService } from "./telegram.service.js";
import type { ReportType } from "./types.js";

export const reportService = {
  async generate(reportType: ReportType): Promise<{ portfolioCount: number }> {
    const startTime = Date.now();
    logger.info({ reportType }, "Report pipeline: starting");

    // Stage 1: Collect data
    const data = await dataCollectorService.collect(reportType);

    if (data.portfolios.length === 0) {
      logger.warn("No portfolios found, skipping report");
      return { portfolioCount: 0 };
    }

    // Stage 2: AI analysis (graceful degradation on failure)
    const analysis = await aiAnalyzerService.analyze(data);

    // Stage 3: Format report
    const formatted = reportFormatterService.format(data, analysis);

    // Stage 4: Send via Telegram
    await telegramService.sendReport(formatted.messages);

    const duration = Date.now() - startTime;
    logger.info(
      { reportType, portfolioCount: data.portfolios.length, messageCount: formatted.messages.length, duration },
      "Report pipeline: complete"
    );

    return { portfolioCount: data.portfolios.length };
  },
};
