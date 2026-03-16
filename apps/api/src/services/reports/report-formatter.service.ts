import type { CollectedData, CollectedHolding, AnalysisResult, FormattedReport } from "./types.js";

const MAX_MSG_LEN = 4096;
const SEPARATOR = "─────────────────────";

function esc(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, "\\$1");
}

function sign(v: number): string {
  if (v > 0) return "\\+";
  if (v < 0) return "\\-";
  return "";
}

function plEmoji(v: number): string {
  if (v > 0) return "🟢";
  if (v < 0) return "🔴";
  return "⚪";
}

function fmtNum(v: number): string {
  return esc(
    Math.abs(v).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  );
}

function fmtPct(v: number): string {
  return esc(Math.abs(v).toFixed(2));
}

function fmtCompact(v: number): string {
  const abs = Math.abs(v);
  if (abs >= 1_000_000) return esc((abs / 1_000_000).toFixed(2)) + "M";
  if (abs >= 1_000) return esc((abs / 1_000).toFixed(2)) + "K";
  return fmtNum(v);
}

function plLine(label: string, value: number, pct: number): string {
  return `${plEmoji(value)} ${label}: \`${sign(value)}$${fmtNum(value)} \\(${sign(pct)}${fmtPct(pct)}%\\)\``;
}

function buildPortfolioSection(p: CollectedData["portfolios"][0], isWeekly: boolean, usdToSgd: number): string {
  const holdingCount = p.holdings.length;
  const assetsSgd = p.netAssets * usdToSgd;
  const plSgd = p.totalPL * usdToSgd;
  const lines = [
    `💼 *${esc(p.name)}* \\(${holdingCount} holdings\\)`,
    `   Assets: \`$${fmtCompact(p.netAssets)}\` \\(S$${fmtCompact(assetsSgd)}\\)`,
    `   Cost: \`$${fmtCompact(p.totalCost)}\``,
    `   ${plLine("Total P/L", p.totalPL, p.totalPLPercent)} \\(S$${fmtCompact(plSgd)}\\)`,
  ];

  if (isWeekly && p.weeklyChange !== undefined) {
    const weekSgd = p.weeklyChange * usdToSgd;
    lines.push(`   ${plLine("Week", p.weeklyChange, p.weeklyChangePercent!)} \\(S$${fmtCompact(weekSgd)}\\)`);
  } else {
    lines.push(`   ${plLine("Today", p.todayPL, p.todayPLPercent)}`);
  }

  // For weekly: show top 3 best/worst holdings by total P/L %
  if (isWeekly && p.holdings.length > 0) {
    const sorted = [...p.holdings].sort((a, b) => b.profitLossPercent - a.profitLossPercent);
    const best = sorted.filter((h) => h.profitLossPercent > 0).slice(0, 3);
    const worst = sorted.filter((h) => h.profitLossPercent < 0).slice(-3).reverse();

    if (best.length > 0) {
      lines.push(`   _Best:_ ${best.map((h) => `\`${esc(h.symbol)}\` ${sign(h.profitLossPercent)}${fmtPct(h.profitLossPercent)}%`).join(", ")}`);
    }
    if (worst.length > 0) {
      lines.push(`   _Worst:_ ${worst.map((h) => `\`${esc(h.symbol)}\` ${sign(h.profitLossPercent)}${fmtPct(h.profitLossPercent)}%`).join(", ")}`);
    }
  }

  return lines.join("\n");
}


function buildMoversSection(portfolios: CollectedData["portfolios"], isWeekly: boolean): string {
  // Gather all holdings across portfolios
  const allHoldings: CollectedHolding[] = [];
  for (const p of portfolios) {
    for (const h of p.holdings) {
      allHoldings.push(h);
    }
  }

  if (allHoldings.length === 0) return "";

  // Sort by daily change percent for daily, total P/L % for weekly
  const sortKey = isWeekly
    ? (h: CollectedHolding) => h.profitLossPercent
    : (h: CollectedHolding) => h.changePercent;

  const sorted = [...allHoldings].sort((a, b) => sortKey(b) - sortKey(a));

  const gainers = sorted.filter((h) => sortKey(h) > 0).slice(0, 3);
  const losers = sorted.filter((h) => sortKey(h) < 0).slice(-3).reverse();

  const title = isWeekly ? "🏆 *BEST & WORST PERFORMERS*" : "🔥 *TOP MOVERS*";
  const lines: string[] = [title];

  if (gainers.length > 0) {
    for (const h of gainers) {
      const val = sortKey(h);
      const plUsd = isWeekly ? ` ${sign(h.profitLoss)}$${fmtCompact(h.profitLoss)}` : "";
      lines.push(`   🟢 \`${esc(h.symbol)}\` ${sign(val)}${fmtPct(val)}%${plUsd} \\($${fmtNum(h.currentPrice)}\\)`);
    }
  }

  if (losers.length > 0) {
    for (const h of losers) {
      const val = sortKey(h);
      const plUsd = isWeekly ? ` ${sign(h.profitLoss)}$${fmtCompact(h.profitLoss)}` : "";
      lines.push(`   🔴 \`${esc(h.symbol)}\` ${sign(val)}${fmtPct(val)}%${plUsd} \\($${fmtNum(h.currentPrice)}\\)`);
    }
  }

  if (gainers.length === 0 && losers.length === 0) {
    lines.push(`   No significant moves`);
  }

  return lines.join("\n");
}

function buildAISection(analysis: AnalysisResult, isWeekly: boolean): string {
  const sections: string[] = [];

  // Trim AI text to stay within budget — ~600 chars per section max
  const trim = (text: string, max: number): string => {
    if (text.length <= max) return text;
    return text.substring(0, max - 3) + "...";
  };

  sections.push(`📈 *MARKET OVERVIEW*\n${esc(trim(analysis.marketOverview, 500))}`);
  sections.push(`🏆 *AI TOP MOVERS*\n${esc(trim(analysis.topMovers, 400))}`);

  if (isWeekly && analysis.sgMarket) {
    sections.push(`🇸🇬 *SG MARKET*\n${esc(trim(analysis.sgMarket, 300))}`);
  }
  if (isWeekly && analysis.cryptoMarket) {
    sections.push(`🪙 *CRYPTO*\n${esc(trim(analysis.cryptoMarket, 300))}`);
  }

  sections.push(`💡 *INSIGHTS*\n${esc(trim(analysis.insights, 500))}`);

  return sections.join("\n\n");
}

function splitMessages(fullText: string): string[] {
  if (fullText.length <= MAX_MSG_LEN) return [fullText];

  // Split on separator lines or emoji section headers
  const parts = fullText.split(/(?=─────|[\u{1F4CA}\u{1F4BC}\u{1F4C8}\u{1F3C6}\u{1F4A1}\u{1F1F8}\u{1FA99}\u{1F525}\u{1F4B0}\u{1F4C8}])/u);
  const messages: string[] = [];
  let current = "";

  for (const part of parts) {
    if (current.length + part.length + 2 > MAX_MSG_LEN) {
      if (current) messages.push(current.trim());

      if (part.length > MAX_MSG_LEN) {
        const truncated = part.substring(0, MAX_MSG_LEN - 20) + "\n\\.\\.\\.continued";
        messages.push(truncated);
        current = "";
      } else {
        current = part;
      }
    } else {
      current += (current ? "\n\n" : "") + part;
    }
  }

  if (current.trim()) messages.push(current.trim());
  return messages;
}

function formatSGTTime(dateStr: string): string {
  const now = new Date();
  const sgtOptions: Intl.DateTimeFormatOptions = {
    timeZone: "Asia/Singapore",
    weekday: "short",
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  };
  return now.toLocaleString("en-SG", sgtOptions);
}

export const reportFormatterService = {
  format(data: CollectedData, analysis: AnalysisResult | null): FormattedReport {
    const isWeekly = data.reportType === "weekly";
    const title = isWeekly ? "📊 Weekly Portfolio Report" : "📊 Daily Portfolio Report";
    const timeStr = esc(formatSGTTime(data.date));

    const sections: string[] = [];

    // Header
    sections.push(`*${title}*\n🕐 ${timeStr} SGT`);

    sections.push(esc(SEPARATOR));

    // Portfolio sections
    for (const p of data.portfolios) {
      sections.push(buildPortfolioSection(p, isWeekly, data.usdToSgd));
    }

    sections.push(esc(SEPARATOR));

    // Top movers from actual holdings data
    const movers = buildMoversSection(data.portfolios, isWeekly);
    if (movers) {
      sections.push(movers);
    }

    // AI analysis
    if (analysis) {
      sections.push(esc(SEPARATOR));
      sections.push(buildAISection(analysis, isWeekly));
    }

    // Footer
    const footerParts = [`💱 USD/SGD: \`${esc(data.usdToSgd.toFixed(4))}\``];
    sections.push(footerParts.join("  •  "));

    const fullText = sections.join("\n\n");
    return { messages: splitMessages(fullText) };
  },
};
