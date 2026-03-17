import type { CollectedData, CollectedHolding, CollectedPortfolio, AnalysisResult, FormattedReport } from "./types.js";

const MAX_MSG_LEN = 4096;

// ── Helpers ──────────────────────────────────────────────────────────────────

function esc(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, "\\$1");
}

function sign(v: number): string {
  return v > 0 ? "\\+" : v < 0 ? "\\-" : "";
}

function plEmoji(v: number): string {
  return v > 0 ? "🟢" : v < 0 ? "🔴" : "⚪";
}

function fmt(v: number, compact = false): string {
  const abs = Math.abs(v);
  if (compact) {
    if (abs >= 1_000_000) return esc((abs / 1_000_000).toFixed(1)) + "M";
    if (abs >= 10_000) return esc((abs / 1_000).toFixed(1)) + "K";
    if (abs >= 1_000) return esc((abs / 1_000).toFixed(2)) + "K";
  }
  return esc(abs.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
}

function pct(v: number): string {
  return esc(Math.abs(v).toFixed(2));
}

function fxConvert(usd: number, rate: number): string {
  return fmt(usd * rate, true);
}

/** Currency label for display */
function currLabel(currency: string): string {
  switch (currency) {
    case "SGD": return "S$";
    case "HKD": return "HK$";
    default: return "$";
  }
}

function formatSGTTime(): string {
  return new Date().toLocaleString("en-SG", {
    timeZone: "Asia/Singapore",
    weekday: "short",
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  });
}

// ── Sections ─────────────────────────────────────────────────────────────────

function buildDailyPortfolio(p: CollectedPortfolio, usdToSgd: number): string {
  const n = p.holdings.length;
  const assetsSgd = fxConvert(p.netAssets, usdToSgd);
  const plSgd = fxConvert(p.totalPL, usdToSgd);

  const lines = [
    `💼 *${esc(p.name)}* \\(${n}\\)`,
    `  💰 \`$${fmt(p.netAssets, true)}\` \\(S$${assetsSgd}\\)`,
    `  ${plEmoji(p.totalPL)} P/L: \`${sign(p.totalPL)}$${fmt(p.totalPL, true)}\` ${sign(p.totalPLPercent)}${pct(p.totalPLPercent)}% \\(S$${plSgd}\\)`,
    `  📈 Today: ${plEmoji(p.todayPL)} \`${sign(p.todayPL)}$${fmt(p.todayPL, true)}\` ${sign(p.todayPLPercent)}${pct(p.todayPLPercent)}%`,
  ];

  return lines.join("\n");
}

function buildWeeklyPortfolio(p: CollectedPortfolio, usdToSgd: number): string {
  const n = p.holdings.length;
  const assetsSgd = fxConvert(p.netAssets, usdToSgd);
  const plSgd = fxConvert(p.totalPL, usdToSgd);

  const lines = [
    `💼 *${esc(p.name)}* \\(${n}\\)`,
    `  💰 \`$${fmt(p.netAssets, true)}\` \\(S$${assetsSgd}\\)`,
    `  ${plEmoji(p.totalPL)} Total: \`${sign(p.totalPL)}$${fmt(p.totalPL, true)}\` ${sign(p.totalPLPercent)}${pct(p.totalPLPercent)}% \\(S$${plSgd}\\)`,
  ];

  if (p.weeklyChange !== undefined) {
    const weekSgd = fxConvert(p.weeklyChange, usdToSgd);
    lines.push(
      `  📅 Week: ${plEmoji(p.weeklyChange)} \`${sign(p.weeklyChange)}$${fmt(p.weeklyChange, true)}\` ${sign(p.weeklyChangePercent!)}${pct(p.weeklyChangePercent!)}% \\(S$${weekSgd}\\)`,
    );
  }

  // Top 5 holdings by P/L (mix of best and worst)
  if (p.holdings.length > 0) {
    const active = p.holdings.filter((h) => h.shares > 0);
    const sorted = [...active].sort((a, b) => b.profitLossPercent - a.profitLossPercent);
    const top = sorted.slice(0, 3);
    const bottom = sorted.filter((h) => h.profitLossPercent < 0).slice(-2).reverse();

    if (top.length > 0) {
      lines.push(`  🏅 ${top.map((h) => `\`${esc(h.symbol)}\` ${sign(h.profitLossPercent)}${pct(h.profitLossPercent)}%`).join(" ")}`);
    }
    if (bottom.length > 0) {
      lines.push(`  📉 ${bottom.map((h) => `\`${esc(h.symbol)}\` ${sign(h.profitLossPercent)}${pct(h.profitLossPercent)}%`).join(" ")}`);
    }
  }

  return lines.join("\n");
}

function buildMovers(portfolios: CollectedPortfolio[], isWeekly: boolean): string {
  const all: CollectedHolding[] = [];
  for (const p of portfolios) {
    for (const h of p.holdings) all.push(h);
  }
  if (all.length === 0) return "";

  const key = isWeekly
    ? (h: CollectedHolding) => h.profitLossPercent
    : (h: CollectedHolding) => h.changePercent;

  const sorted = [...all].sort((a, b) => key(b) - key(a));
  // Deduplicate by symbol (same stock in multiple portfolios)
  const seen = new Set<string>();
  const unique = sorted.filter((h) => {
    if (seen.has(h.symbol)) return false;
    seen.add(h.symbol);
    return true;
  });

  const gainers = unique.filter((h) => key(h) > 0).slice(0, 3);
  const losers = unique.filter((h) => key(h) < 0).slice(-3).reverse();

  if (gainers.length === 0 && losers.length === 0) return "";

  const title = isWeekly ? "🏆 *TOP & BOTTOM*" : "🔥 *MOVERS*";
  const lines: string[] = [title];

  for (const h of gainers) {
    const v = key(h);
    lines.push(`🟢 \`${esc(h.symbol)}\` ${sign(v)}${pct(v)}% \\(${currLabel(h.currency)}${fmt(h.currentPrice)}\\)`);
  }
  for (const h of losers) {
    const v = key(h);
    lines.push(`🔴 \`${esc(h.symbol)}\` ${sign(v)}${pct(v)}% \\(${currLabel(h.currency)}${fmt(h.currentPrice)}\\)`);
  }

  return lines.join("\n");
}

function buildAssetBreakdown(portfolios: CollectedPortfolio[]): string {
  const totals: Record<string, { value: number; pl: number }> = {};
  for (const p of portfolios) {
    for (const h of p.holdings) {
      const t = h.assetType;
      if (!totals[t]) totals[t] = { value: 0, pl: 0 };
      totals[t].value += h.marketValue;
      totals[t].pl += h.profitLoss;
    }
  }

  const labels: Record<string, string> = {
    us_stock: "🇺🇸US",
    sg_stock: "🇸🇬SG",
    hk_stock: "🇭🇰HK",
    crypto: "🪙Crypto",
  };

  const order = ["us_stock", "sg_stock", "hk_stock", "crypto"];
  const parts: string[] = [];
  for (const type of order) {
    const t = totals[type];
    if (!t || t.value === 0) continue;
    parts.push(`${labels[type]} \`$${fmt(t.value, true)}\` ${plEmoji(t.pl)}${sign(t.pl)}$${fmt(t.pl, true)}`);
  }

  if (parts.length === 0) return "";
  return `📊 *BREAKDOWN*\n${parts.join("\n")}`;
}

const ACTION_EMOJI: Record<string, string> = {
  hold: "🟢",
  accumulate: "🔵",
  watch: "🟡",
  trim: "🔴",
};

function buildAIMessage(analysis: AnalysisResult): string {
  const sections: string[] = [];

  sections.push("🤖 *AI ANALYSIS*");

  // Market overview
  sections.push(`📈 *MARKET*\n${esc(analysis.marketOverview)}`);

  // Holding actions
  if (analysis.holdingActions.length > 0) {
    const actionLines = analysis.holdingActions.map((a) => {
      const emoji = ACTION_EMOJI[a.action] || "🟡";
      const label = a.action.charAt(0).toUpperCase() + a.action.slice(1);
      return `${emoji} \`${esc(a.symbol)}\` — ${esc(label)}\\. ${esc(a.reasoning)}`;
    });
    sections.push(`⚡ *ACTIONS*\n${actionLines.join("\n")}`);
  }

  // Risks
  sections.push(`⚠️ *RISKS*\n${esc(analysis.risks)}`);

  // Outlook
  sections.push(`🔭 *OUTLOOK*\n${esc(analysis.outlook)}`);

  return sections.join("\n\n");
}

// ── Message splitting ────────────────────────────────────────────────────────

function splitMessages(fullText: string): string[] {
  if (fullText.length <= MAX_MSG_LEN) return [fullText];

  // Split on double newlines (section breaks)
  const parts = fullText.split("\n\n");
  const messages: string[] = [];
  let current = "";

  for (const part of parts) {
    if (current.length + part.length + 2 > MAX_MSG_LEN) {
      if (current) messages.push(current.trim());

      if (part.length > MAX_MSG_LEN) {
        messages.push(part.substring(0, MAX_MSG_LEN - 20) + "\n\\.\\.\\.continued");
        current = "";
      } else {
        current = part;
      }
    } else {
      current += (current ? "\n\n" : "") + part;
    }
  }

  if (current.trim()) messages.push(current.trim());
  return messages.length > 0 ? messages : [fullText.substring(0, MAX_MSG_LEN)];
}

// ── Main formatter ───────────────────────────────────────────────────────────

export const reportFormatterService = {
  format(data: CollectedData, analysis: AnalysisResult | null): FormattedReport {
    const isWeekly = data.reportType === "weekly";
    const title = isWeekly ? "📊 *WEEKLY REPORT*" : "📊 *DAILY REPORT*";
    const timeStr = esc(formatSGTTime());

    const sections: string[] = [];

    // Header
    sections.push(`${title}\n🕐 ${timeStr} SGT`);

    // Portfolio sections
    for (const p of data.portfolios) {
      sections.push(
        isWeekly
          ? buildWeeklyPortfolio(p, data.usdToSgd)
          : buildDailyPortfolio(p, data.usdToSgd),
      );
    }

    // Asset breakdown (weekly only)
    if (isWeekly) {
      const breakdown = buildAssetBreakdown(data.portfolios);
      if (breakdown) sections.push(breakdown);
    }

    // Top movers
    const movers = buildMovers(data.portfolios, isWeekly);
    if (movers) sections.push(movers);

    // Footer
    const footer = `💱 \`USD/SGD ${esc(data.usdToSgd.toFixed(4))}\` · \`USD/HKD ${esc(data.usdToHkd.toFixed(4))}\``;
    sections.push(footer);

    // Data message(s) — split if exceeds Telegram limit
    const dataText = sections.join("\n\n");
    const messages = splitMessages(dataText);

    // AI message — separate, full 4096 chars available
    if (analysis) {
      const aiText = buildAIMessage(analysis);
      messages.push(...splitMessages(aiText));
    }

    return { messages };
  },
};
