// src/pages/coach/components/MetricView.jsx
import React from "react";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Cell,
  CartesianGrid,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  PieChart,
  Pie,
} from "recharts";
import { Flame, DollarSign, TrendingUp, Target } from "lucide-react";

function StatCard({ label, value, small }) {
  return (
    <div className="bg-white p-3 rounded-md shadow-sm min-h-[56px]">
      <div className="text-xs text-gray-500">{label}</div>
      <div
        className={`text-lg font-semibold ${
          small ? "text-indigo-600" : "text-black"
        }`}
      >
        {value}
      </div>
    </div>
  );
}

// Circular Progress Component for percentages
function CircularProgress({
  value,
  max = 100,
  size = 120,
  strokeWidth = 8,
  color = "#10b981",
  label,
  subtitle,
}) {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const percentage = Math.min((value / max) * 100, 100);
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div className="flex flex-col items-center">
      <div className="relative" style={{ width: size, height: size }}>
        <svg width={size} height={size} className="transform -rotate-90">
          {/* Background circle */}
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke="#e5e7eb"
            strokeWidth={strokeWidth}
            fill="none"
          />
          {/* Progress circle */}
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke={color}
            strokeWidth={strokeWidth}
            fill="none"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            strokeLinecap="round"
            className="transition-all duration-500 ease-out"
          />
        </svg>
        {/* Center text */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-2xl font-bold" style={{ color }}>
            {value.toFixed(1)}%
          </span>
          {subtitle && (
            <span className="text-xs text-gray-500 mt-1">{subtitle}</span>
          )}
        </div>
      </div>
      {label && (
        <p className="text-sm font-semibold text-gray-700 mt-3 text-center">
          {label}
        </p>
      )}
    </div>
  );
}

// Large Metric Card Component
function LargeMetricCard({
  icon: Icon,
  value,
  label,
  subtitle,
  color,
  bgGradient,
}) {
  const IconComponent = Icon;
  return (
    <div
      className={`bg-white rounded-xl border border-gray-200 shadow-sm p-6 ${
        bgGradient || ""
      }`}
    >
      <div className="flex items-start justify-between mb-4">
        <div
          className={`p-3 rounded-lg ${
            bgGradient ? "bg-white/20" : "bg-gray-50"
          }`}
        >
          <IconComponent className={`w-6 h-6 ${color || "text-gray-600"}`} />
        </div>
      </div>
      <div className="space-y-1">
        <p className="text-3xl font-bold text-gray-900">{value}</p>
        <p className="text-sm font-semibold text-gray-700">{label}</p>
        {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}

function SkeletonGrid() {
  return (
    <div className="space-y-6 animate-pulse">
      <div className="h-6 bg-gray-200 rounded w-1/4" />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-48 bg-gray-200 rounded-xl" />
        ))}
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-20 bg-gray-200 rounded" />
        ))}
      </div>
      <div className="h-64 bg-gray-200 rounded" />
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-12 bg-gray-200 rounded" />
        ))}
      </div>
      <div className="h-64 bg-gray-200 rounded" />
    </div>
  );
}

export default function MetricView({ metric, loading = false, error = null }) {
  if (loading) return <SkeletonGrid />;

  // Error state
  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-red-100 to-rose-100 flex items-center justify-center mb-4">
          <Target size={32} className="text-red-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">
          Failed to load metrics
        </p>
        <p className="text-gray-500 text-sm text-center max-w-md">
          {typeof error === "string"
            ? error
            : "Unable to fetch metrics data. Please try again later."}
        </p>
      </div>
    );
  }

  // Empty/null state
  if (
    !metric ||
    (typeof metric === "object" && Object.keys(metric).length === 0)
  ) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center mb-4">
          <Target size={32} className="text-gray-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">No metrics available</p>
        <p className="text-gray-500 text-sm text-center max-w-md">
          Metrics data will appear here once the member starts tracking their
          progress.
        </p>
      </div>
    );
  }

  // safe access & formatting
  const fmtNum = (v) =>
    v === null || v === undefined ? "-" : typeof v === "number" ? v : v;

  const fmt2 = (v) => {
    if (v === null || v === undefined) return "-";
    if (typeof v === "number") return v.toFixed(2);
    return v; // giữ nguyên nếu nó là string
  };

  // Format VNĐ currency
  const formatVND = (amount) => {
    if (amount === null || amount === undefined || isNaN(amount)) return "0 ₫";
    return `${amount.toLocaleString("vi-VN")} ₫`;
  };

  // Extract key metrics with safe defaults
  const streaks = metric.streaks ?? 0;
  const smokeFreePct = metric.smokeFreeDayPercentage ?? 0;
  const reductionPct = metric.reductionPercentage ?? 0;
  const moneySaved = metric.moneySaved ?? 0;

  // Check if metric has meaningful data (not all zeros/null)
  const hasData =
    streaks > 0 ||
    smokeFreePct > 0 ||
    reductionPct > 0 ||
    moneySaved > 0 ||
    (metric.steps ?? 0) > 0 ||
    (metric.heartRate ?? null) !== null ||
    (metric.avgCravingLevel ?? null) !== null;

  if (!hasData) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-amber-100 to-orange-100 flex items-center justify-center mb-4">
          <Target size={32} className="text-amber-500" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">
          Metrics not yet recorded
        </p>
        <p className="text-gray-500 text-sm text-center max-w-md">
          The member hasn't started tracking metrics yet. Data will appear here
          once they begin their quit journey.
        </p>
      </div>
    );
  }

  const iotChartData = [
    {
      name: "Steps",
      value: metric.steps ?? 0,
      color: "#6366f1",
    },
    {
      name: "Heart Rate",
      value: metric.heartRate ?? 0,
      color: "#ef4444",
    },
    {
      name: "SpO2",
      value: metric.spo2 ?? 0,
      color: "#06b6d4",
    },
    {
      name: "Sleep (h)",
      value: (metric.sleepDuration ?? 0) * 10, // Scale for better visualization
      color: "#8b5cf6",
    },
  ];

  const moodRadarData = [
    {
      subject: "Craving",
      avg: metric.avgCravingLevel ?? 0,
      current: metric.currentCravingLevel ?? 0,
      fullMark: 10,
    },
    {
      subject: "Mood",
      avg: metric.avgMood ?? 0,
      current: metric.currentMoodLevel ?? 0,
      fullMark: 10,
    },
    {
      subject: "Confidence",
      avg: metric.avgConfidentLevel ?? 0,
      current: metric.currentConfidenceLevel ?? 0,
      fullMark: 10,
    },
    {
      subject: "Anxiety",
      avg: metric.avgAnxiety ?? 0,
      current: metric.currentAnxietyLevel ?? 0,
      fullMark: 10,
    },
  ];

  const progressData = [
    {
      name: "Smoke-Free",
      value: metric.smokeFreeDayPercentage ?? 0,
      fill: "#10b981",
    },
    {
      name: "Remaining",
      value: 100 - (metric.smokeFreeDayPercentage ?? 0),
      fill: "#e5e7eb",
    },
  ];

  const COLORS = ["#10b981", "#3b82f6", "#f59e0b", "#8b5cf6", "#ef4444"];

  return (
    <div className="space-y-6">
      <section>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Quick Summary</h3>
          <div className="text-sm text-gray-500">
            Updated:{" "}
            {metric.updatedAt
              ? new Date(metric.updatedAt).toLocaleString()
              : "-"}
          </div>
        </div>

        {/* Key Metrics - Separated Visualizations */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          {/* Streaks - Large Card */}
          <LargeMetricCard
            icon={Flame}
            value={streaks}
            label="Current Streak"
            subtitle={`${streaks === 1 ? "day" : "days"} smoke-free`}
            color="text-orange-500"
            bgGradient="bg-gradient-to-br from-orange-50 to-amber-50"
          />

          {/* Money Saved - Large Card */}
          <LargeMetricCard
            icon={DollarSign}
            value={formatVND(moneySaved)}
            label="Money Saved"
            subtitle="Estimated savings"
            color="text-emerald-600"
            bgGradient="bg-gradient-to-br from-emerald-50 to-teal-50"
          />

          {/* Smoke-Free % - Circular Progress */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 flex flex-col items-center justify-center">
            <CircularProgress
              value={smokeFreePct}
              max={100}
              size={140}
              strokeWidth={10}
              color="#10b981"
              label="Smoke-Free Days"
              subtitle={`${smokeFreePct.toFixed(1)}% of days`}
            />
            <div className="mt-4 text-center">
              <p className="text-xs text-gray-500">
                Percentage of days without smoking
              </p>
            </div>
          </div>

          {/* Reduction % - Circular Progress */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 flex flex-col items-center justify-center">
            <CircularProgress
              value={reductionPct}
              max={100}
              size={140}
              strokeWidth={10}
              color="#3b82f6"
              label="Reduction Rate"
              subtitle={`${reductionPct.toFixed(1)}% reduction`}
            />
            <div className="mt-4 text-center">
              <p className="text-xs text-gray-500">
                Cigarette consumption reduction
              </p>
            </div>
          </div>
        </div>

        {/* Quick Stats Row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <StatCard label="Streaks" value={`${fmtNum(streaks)} 🔥`} />
          <StatCard label="Smoke-free %" value={`${fmt2(smokeFreePct)}%`} />
          <StatCard label="Reduction" value={`${fmt2(reductionPct)}%`} />
          <StatCard label="Money saved" value={formatVND(moneySaved)} />
        </div>
      </section>

      <section>
        <h4 className="font-medium mb-4">IoT / Health Metrics</h4>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
          <StatCard
            label="Steps (today)"
            value={fmtNum(metric.steps ?? 0)}
            small
          />
          <StatCard
            label="Heart rate"
            value={`${fmtNum(metric.heartRate ?? "-")} bpm`}
            small
          />
          <StatCard
            label="SpO2"
            value={`${fmtNum(metric.spo2 ?? "-")}%`}
            small
          />
          <StatCard
            label="Sleep (h)"
            value={(metric.sleepDuration ?? 0).toFixed(1)}
            small
          />
        </div>

        {/* IoT Metrics Bar Chart */}
        <div className="bg-white p-4 rounded-lg border border-gray-200 shadow-sm">
          <h4 className="text-sm font-semibold text-gray-700 mb-4">
            Health Metrics Comparison
          </h4>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart
              data={iotChartData}
              margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="name" tick={{ fontSize: 12, fill: "#6b7280" }} />
              <YAxis tick={{ fontSize: 12, fill: "#6b7280" }} />
              <Tooltip
                formatter={(value, name) => {
                  if (name === "Sleep (h)") {
                    return [(value / 10).toFixed(1) + " hours", name];
                  }
                  if (name === "Steps") {
                    return [value.toLocaleString(), name];
                  }
                  return [value, name];
                }}
                contentStyle={{
                  backgroundColor: "white",
                  border: "1px solid #e5e7eb",
                  borderRadius: "8px",
                }}
              />
              <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                {iotChartData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </section>

      <section>
        <h4 className="font-medium mb-4">Mood & Craving Analysis</h4>
        <div className="grid gap-3 mb-6">
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
            <StatCard
              label="Avg craving"
              value={fmt2(metric.avgCravingLevel ?? "-")}
            />
            <StatCard label="Avg mood" value={fmt2(metric.avgMood ?? "-")} />
            <StatCard
              label="Avg anxiety"
              value={fmt2(metric.avgAnxiety ?? "-")}
            />
            <StatCard
              label="Avg confident"
              value={fmt2(metric.avgConfidentLevel ?? "-")}
            />
          </div>

          <div className="mt-2 p-3 bg-gray-50 rounded">
            <div className="text-sm text-gray-600 mb-2">
              Current (self-reported)
            </div>
            <div className="flex gap-6">
              <div>
                <div className="text-xs text-gray-500">Craving</div>
                <div className="font-semibold">
                  {fmtNum(metric.currentCravingLevel ?? "-")}
                </div>
              </div>
              <div>
                <div className="text-xs text-gray-500">Mood</div>
                <div className="font-semibold">
                  {fmtNum(metric.currentMoodLevel ?? "-")}
                </div>
              </div>
              <div>
                <div className="text-xs text-gray-500">Confidence</div>
                <div className="font-semibold">
                  {fmtNum(metric.currentConfidenceLevel ?? "-")}
                </div>
              </div>
              <div>
                <div className="text-xs text-gray-500">Anxiety</div>
                <div className="font-semibold">
                  {fmtNum(metric.currentAnxietyLevel ?? "-")}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Mood Radar Chart */}
        <div className="bg-white p-4 rounded-lg border border-gray-200 shadow-sm mb-6">
          <h4 className="text-sm font-semibold text-gray-700 mb-4">
            Average vs Current Mental State
          </h4>
          <ResponsiveContainer width="100%" height={300}>
            <RadarChart data={moodRadarData}>
              <PolarGrid stroke="#e5e7eb" />
              <PolarAngleAxis
                dataKey="subject"
                tick={{ fontSize: 12, fill: "#6b7280" }}
              />
              <PolarRadiusAxis
                angle={90}
                domain={[0, 10]}
                tick={{ fontSize: 10, fill: "#9ca3af" }}
              />
              <Radar
                name="Average"
                dataKey="avg"
                stroke="#3b82f6"
                fill="#3b82f6"
                fillOpacity={0.3}
                strokeWidth={2}
              />
              <Radar
                name="Current"
                dataKey="current"
                stroke="#10b981"
                fill="#10b981"
                fillOpacity={0.3}
                strokeWidth={2}
              />
              <Legend wrapperStyle={{ paddingTop: "20px" }} iconType="circle" />
              <Tooltip
                contentStyle={{
                  backgroundColor: "white",
                  border: "1px solid #e5e7eb",
                  borderRadius: "8px",
                }}
              />
            </RadarChart>
          </ResponsiveContainer>
        </div>

        {/* Progress Pie Chart */}
        <div className="bg-white p-4 rounded-lg border border-gray-200 shadow-sm">
          <h4 className="text-sm font-semibold text-gray-700 mb-4">
            Smoke-Free Progress
          </h4>
          <div className="flex items-center justify-center">
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={progressData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) =>
                    name === "Smoke-Free"
                      ? `${(percent * 100).toFixed(1)}%`
                      : ""
                  }
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {progressData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.fill} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value) => [`${value.toFixed(1)}%`, "Progress"]}
                  contentStyle={{
                    backgroundColor: "white",
                    border: "1px solid #e5e7eb",
                    borderRadius: "8px",
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="text-center mt-2">
            <p className="text-sm text-gray-600">
              {metric.smokeFreeDayPercentage?.toFixed(1) ?? 0}% Smoke-Free Days
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
