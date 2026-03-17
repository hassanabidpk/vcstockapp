"use client";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import { useTheme } from "@/context/ThemeContext";

interface SnapshotData {
  date: string;
  totalValue: number;
  totalCost: number;
  totalPL: number;
}

interface ChartDataPoint extends SnapshotData {
  dailyChange: number | null;
  isCurrent?: boolean;
}

function fmtSigned(v: number) {
  return `${v >= 0 ? "+" : ""}$${v.toFixed(2)}`;
}

function CustomTooltip({ active, payload, label, isDark }: any) {
  if (!active || !payload || !payload.length) return null;
  const d = payload[0].payload as ChartDataPoint;
  const plColor = d.totalPL >= 0 ? "#34d399" : "#f87171";
  const dailyColor =
    d.dailyChange == null ? "#94a3b8" : d.dailyChange >= 0 ? "#34d399" : "#f87171";

  return (
    <div
      style={{
        backgroundColor: isDark ? "#1e293b" : "#ffffff",
        border: `1px solid ${isDark ? "#334155" : "#e2e8f0"}`,
        borderRadius: "8px",
        padding: "10px 14px",
        color: isDark ? "#f8fafc" : "#1e293b",
        fontSize: "13px",
        boxShadow: isDark ? "none" : "0 2px 8px rgba(0,0,0,0.1)",
      }}
    >
      <p style={{ color: "#94a3b8", marginBottom: 6, fontSize: 11 }}>
        {label}{d.isCurrent ? " · Live" : ""}
      </p>
      <p>
        P/L: <span style={{ color: plColor, fontWeight: 600 }}>${d.totalPL.toFixed(2)}</span>
      </p>
      {d.dailyChange != null && (
        <p style={{ marginTop: 2 }}>
          Daily: <span style={{ color: dailyColor, fontWeight: 600 }}>{fmtSigned(d.dailyChange)}</span>
        </p>
      )}
    </div>
  );
}

interface PortfolioPLChartProps {
  data: SnapshotData[];
  currentSummary?: { totalValue: number; totalCost: number; totalPL: number };
}

export function PortfolioPLChart({ data, currentSummary }: PortfolioPLChartProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const todayStr = new Date().toISOString().split("T")[0];

  // Merge live current data as today's point
  let mergedData = [...data];
  if (currentSummary) {
    const last = mergedData[mergedData.length - 1];
    const todayEntry = { date: todayStr, ...currentSummary };
    if (last?.date === todayStr) {
      mergedData[mergedData.length - 1] = todayEntry;
    } else {
      mergedData = [...mergedData, todayEntry];
    }
  }

  if (mergedData.length === 0) {
    return (
      <div className="h-48 flex items-center justify-center dark:text-slate-500 text-slate-400 text-sm">
        P/L trend chart will appear after daily snapshots are recorded
      </div>
    );
  }

  const chartData: ChartDataPoint[] = mergedData.map((d, i) => ({
    ...d,
    dailyChange: i > 0 ? d.totalPL - mergedData[i - 1].totalPL : null,
    isCurrent: d.date === todayStr && !!currentSummary,
  }));

  const isProfit = chartData[chartData.length - 1].totalPL >= 0;
  const gridColor = isDark ? "#1e293b" : "#e2e8f0";
  const tickColor = isDark ? "#64748b" : "#94a3b8";

  return (
    <ResponsiveContainer width="100%" height={200}>
      <AreaChart data={chartData}>
        <CartesianGrid strokeDasharray="3 3" stroke={gridColor} />
        <XAxis
          dataKey="date"
          tick={{ fill: tickColor, fontSize: 11 }}
          tickFormatter={(d) => {
            const [, m, day] = d.split("-");
            const label = `${parseInt(m)}/${parseInt(day)}`;
            return d === todayStr ? `${label}*` : label;
          }}
        />
        <YAxis
          tick={{ fill: tickColor, fontSize: 11 }}
          tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
        />
        <Tooltip content={<CustomTooltip isDark={isDark} />} />
        <Area
          type="monotone"
          dataKey="totalPL"
          stroke={isProfit ? "#34d399" : "#f87171"}
          fill={isProfit ? "#34d39920" : "#f8717120"}
          strokeWidth={2}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
