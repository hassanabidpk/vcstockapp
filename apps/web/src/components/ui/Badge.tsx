"use client";

export function Badge({ value, suffix = "%" }: { value: number; suffix?: string }) {
  const isPositive = value >= 0;
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${
        isPositive ? "bg-emerald-400/10 text-emerald-400" : "bg-red-400/10 text-red-400"
      }`}
    >
      {isPositive ? "+" : ""}
      {value.toFixed(2)}
      {suffix}
    </span>
  );
}
