/**
 * US Market hours: Mon-Fri, 9:30 AM - 4:00 PM Eastern Time.
 * Uses Intl.DateTimeFormat to get current ET time without a timezone library.
 */

function getCurrentET(): { hour: number; minute: number; day: number } {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/New_York",
    hour: "numeric",
    minute: "numeric",
    weekday: "short",
    hour12: false,
  });
  const parts = formatter.formatToParts(now);
  const hour = parseInt(parts.find((p) => p.type === "hour")!.value, 10);
  const minute = parseInt(parts.find((p) => p.type === "minute")!.value, 10);
  const weekday = parts.find((p) => p.type === "weekday")!.value;

  const dayMap: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };
  return { hour, minute, day: dayMap[weekday] ?? 0 };
}

export function isUSMarketOpen(): boolean {
  const { hour, minute, day } = getCurrentET();

  // Weekend
  if (day === 0 || day === 6) return false;

  // Market hours: 9:30 AM - 4:00 PM ET
  const timeInMinutes = hour * 60 + minute;
  const openTime = 9 * 60 + 30; // 9:30 AM
  const closeTime = 16 * 60; // 4:00 PM

  return timeInMinutes >= openTime && timeInMinutes < closeTime;
}

/**
 * Returns cache TTL in minutes for US stocks:
 * - 60 minutes during market hours (hourly refresh)
 * - 720 minutes (12 hours) outside market hours
 */
export function getUSStockCacheTTLMinutes(): number {
  return isUSMarketOpen() ? 60 : 720;
}
