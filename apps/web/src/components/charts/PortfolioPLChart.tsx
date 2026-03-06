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

interface SnapshotData {
  date: string;
  totalValue: number;
  totalCost: number;
  totalPL: number;
}

interface ChartDataPoint extends SnapshotData {
  dailyChange: number | null;
}

function fmtSigned(v: number) {
  return `${v >= 0 ? "+" : ""}$${v.toFixed(2)}`;
}

function CustomTooltip({ active, payload, label }: any) {
  if (!active || !payload || !payload.length) return null;
  const d = payload[0].payload as ChartDataPoint;
  const plColor = d.totalPL >= 0 ? "#34d399" : "#f87171";
  const dailyColor =
    d.dailyChange == null ? "#94a3b8" : d.dailyChange >= 0 ? "#34d399" : "#f87171";

  return (
    <div
      style={{
        backgroundColor: "#1e293b",
        border: "1px solid #334155",
        borderRadius: "8px",
        padding: "10px 14px",
        color: "#f8fafc",
        fontSize: "13px",
      }}
    >
      <p style={{ color: "#94a3b8", marginBottom: 6, fontSize: 11 }}>{label}</p>
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

export function PortfolioPLChart({ data }: { data: SnapshotData[] }) {
  if (!data || data.length === 0) {
    return (
      <div className="h-48 flex items-center justify-center text-slate-500 text-sm">
        P/L trend chart will appear after daily snapshots are recorded
      </div>
    );
  }

  const chartData: ChartDataPoint[] = data.map((d, i) => ({
    ...d,
    dailyChange: i > 0 ? d.totalPL - data[i - 1].totalPL : null,
  }));

  const isProfit = data.length > 0 && data[data.length - 1].totalPL >= 0;

  return (
    <ResponsiveContainer width="100%" height={200}>
      <AreaChart data={chartData}>
        <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
        <XAxis
          dataKey="date"
          tick={{ fill: "#64748b", fontSize: 11 }}
          tickFormatter={(d) => {
            const date = new Date(d);
            return `${date.getMonth() + 1}/${date.getDate()}`;
          }}
        />
        <YAxis
          tick={{ fill: "#64748b", fontSize: 11 }}
          tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
        />
        <Tooltip content={<CustomTooltip />} />
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
