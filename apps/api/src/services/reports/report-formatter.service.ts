import type { CollectedData, AnalysisResult, FormattedReport } from "./types.js";

const MAX_MSG_LEN = 4096;

function escapeMarkdownV2(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, "\\$1");
}

function sign(v: number): string {
  if (v > 0) return "\\+";
  if (v < 0) return "\\-";
  return "";
}

function fmtNum(v: number): string {
  return escapeMarkdownV2(
    Math.abs(v).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  );
}

function fmtPct(v: number): string {
  return escapeMarkdownV2(Math.abs(v).toFixed(2));
}

function buildPortfolioSection(p: CollectedData["portfolios"][0], isWeekly: boolean): string {
  const lines = [
    `💼 *PORTFOLIO: ${escapeMarkdownV2(p.name)}*`,
    `Net Assets: \`$${fmtNum(p.netAssets)}\``,
    `Total P/L: \`${sign(p.totalPL)}$${fmtNum(p.totalPL)} \\(${sign(p.totalPLPercent)}${fmtPct(p.totalPLPercent)}%\\)\``,
  ];

  if (isWeekly && p.weeklyChange !== undefined) {
    lines.push(
      `Weekly Change: \`${sign(p.weeklyChange)}$${fmtNum(p.weeklyChange)} \\(${sign(p.weeklyChangePercent!)}${fmtPct(p.weeklyChangePercent!)}%\\)\``
    );
  } else {
    lines.push(
      `Today's P/L: \`${sign(p.todayPL)}$${fmtNum(p.todayPL)} \\(${sign(p.todayPLPercent)}${fmtPct(p.todayPLPercent)}%\\)\``
    );
  }

  return lines.join("\n");
}

function buildCombinedSection(t: CollectedData["combinedTotals"], isWeekly: boolean): string {
  const lines = [
    `📊 *COMBINED TOTALS*`,
    `Net Assets: \`$${fmtNum(t.netAssets)}\``,
    `Total P/L: \`${sign(t.totalPL)}$${fmtNum(t.totalPL)} \\(${sign(t.totalPLPercent)}${fmtPct(t.totalPLPercent)}%\\)\``,
  ];

  if (isWeekly && t.weeklyChange !== undefined) {
    lines.push(
      `Weekly Change: \`${sign(t.weeklyChange)}$${fmtNum(t.weeklyChange)} \\(${sign(t.weeklyChangePercent!)}${fmtPct(t.weeklyChangePercent!)}%\\)\``
    );
  } else {
    lines.push(
      `Today's P/L: \`${sign(t.todayPL)}$${fmtNum(t.todayPL)} \\(${sign(t.todayPLPercent)}${fmtPct(t.todayPLPercent)}%\\)\``
    );
  }

  return lines.join("\n");
}

function splitMessages(fullText: string): string[] {
  if (fullText.length <= MAX_MSG_LEN) return [fullText];

  const sections = fullText.split(/(?=[\u{1F4CA}\u{1F4BC}\u{1F4C8}\u{1F3C6}\u{1F4A1}\u{1F1F8}\u{1FA99}])/u);
  const messages: string[] = [];
  let current = "";

  for (const section of sections) {
    if (current.length + section.length + 1 > MAX_MSG_LEN) {
      if (current) messages.push(current.trim());

      if (section.length > MAX_MSG_LEN) {
        const truncated = section.substring(0, MAX_MSG_LEN - 20) + "\n\\.\\.\\.continued";
        messages.push(truncated);
      } else {
        current = section;
      }
    } else {
      current += (current ? "\n\n" : "") + section;
    }
  }

  if (current.trim()) messages.push(current.trim());
  return messages;
}

export const reportFormatterService = {
  format(data: CollectedData, analysis: AnalysisResult | null): FormattedReport {
    const isWeekly = data.reportType === "weekly";
    const title = isWeekly ? "Weekly" : "Daily";
    const dateStr = escapeMarkdownV2(data.date);

    const sections: string[] = [];

    sections.push(`📊 *${title} Portfolio Report — ${dateStr}*`);

    for (const p of data.portfolios) {
      sections.push(buildPortfolioSection(p, isWeekly));
    }

    sections.push(buildCombinedSection(data.combinedTotals, isWeekly));

    if (analysis) {
      sections.push(`📈 *MARKET OVERVIEW*\n${escapeMarkdownV2(analysis.marketOverview)}`);
      sections.push(`🏆 *TOP MOVERS*\n${escapeMarkdownV2(analysis.topMovers)}`);

      if (isWeekly && analysis.sgMarket) {
        sections.push(`🇸🇬 *SINGAPORE MARKET*\n${escapeMarkdownV2(analysis.sgMarket)}`);
      }
      if (isWeekly && analysis.cryptoMarket) {
        sections.push(`🪙 *CRYPTO MARKET*\n${escapeMarkdownV2(analysis.cryptoMarket)}`);
      }

      sections.push(`💡 *INSIGHTS & RECOMMENDATIONS*\n${escapeMarkdownV2(analysis.insights)}`);
    } else {
      sections.push(`📈 *AI analysis unavailable* — data\\-only report`);
    }

    const fullText = sections.join("\n\n");
    return { messages: splitMessages(fullText) };
  },
};
