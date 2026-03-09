"use client";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import { RANGE_OPTIONS } from "@/lib/constants";
import { useTheme } from "@/context/ThemeContext";
import type { HistoricalPriceData } from "@/lib/api-client";

export function PriceChart({
  data,
  range,
  onRangeChange,
  color = "#3b82f6",
}: {
  data: HistoricalPriceData[];
  range: string;
  onRangeChange: (r: string) => void;
  color?: string;
}) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  if (!data || data.length === 0) {
    return (
      <div className="h-64 flex items-center justify-center dark:text-slate-500 text-slate-400">
        No chart data available
      </div>
    );
  }

  const gridColor = isDark ? "#1e293b" : "#e2e8f0";
  const tickColor = isDark ? "#64748b" : "#94a3b8";

  return (
    <div>
      <div className="flex gap-1 mb-3">
        {RANGE_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            onClick={() => onRangeChange(opt.value)}
            className={`px-3 py-1 rounded text-xs font-medium transition-colors ${
              range === opt.value
                ? "bg-blue-600 text-white"
                : "dark:bg-slate-800 bg-slate-100 dark:text-slate-400 text-slate-600 dark:hover:text-white hover:text-slate-900"
            }`}
          >
            {opt.label}
          </button>
        ))}
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke={gridColor} />
          <XAxis
            dataKey="date"
            tick={{ fill: tickColor, fontSize: 11 }}
            tickFormatter={(d) => {
              const date = new Date(d);
              return `${date.getMonth() + 1}/${date.getDate()}`;
            }}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: tickColor, fontSize: 11 }}
            domain={["auto", "auto"]}
            tickFormatter={(v) => `$${v.toFixed(0)}`}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: isDark ? "#1e293b" : "#ffffff",
              border: `1px solid ${isDark ? "#334155" : "#e2e8f0"}`,
              borderRadius: "8px",
              color: isDark ? "#f8fafc" : "#1e293b",
              boxShadow: isDark ? "none" : "0 2px 8px rgba(0,0,0,0.1)",
            }}
            labelStyle={{ color: "#94a3b8" }}
            formatter={(value: number) => [`$${value.toFixed(2)}`, "Price"]}
          />
          <Line
            type="monotone"
            dataKey="close"
            stroke={color}
            strokeWidth={2}
            dot={false}
            activeDot={{ r: 4 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
