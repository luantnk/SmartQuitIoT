// src/pages/coach/components/HealthRecoveriesView.jsx
// Ghi chú ngắn (VN): file này tính progress dựa trên backend:
// - prefer targetTime nếu targetTime > timeTriggered + 1min
// - else fallback to recoveryTime (minutes) provided by backend
// Backend sets recoveryTime as double (minutes) using calculateTimeToNormal(...)

import React from "react";
import {
  Clock,
  Target,
  Heart,
  Activity,
  TrendingUp,
  Zap,
  Smile,
  Award,
  CheckCircle2,
} from "lucide-react";

/* ---------- Helpers ---------- */
function parseMs(dateString) {
  if (!dateString) return null;
  const ms = Date.parse(dateString);
  return Number.isNaN(ms) ? null : ms;
}

function msToHuman(ms) {
  if (ms <= 0) return "0 minutes";
  const mins = Math.ceil(ms / 60000);
  if (mins < 60) return `${mins} min`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours} hr`;
  const days = Math.floor(hours / 24);
  return `${days} day${days > 1 ? "s" : ""}`;
}

function humanDurationMinutes(mins) {
  if (mins === null || mins === undefined) return "-";
  const m = Number(mins);
  if (Number.isNaN(m)) return "-";
  if (m < 60) return `${Math.round(m)} min`;
  if (m < 60 * 24) return `${Math.round(m / 60)} hr`;
  if (m < 60 * 24 * 30) return `${Math.round(m / (60 * 24))} day`;
  return `${Math.round(m / (60 * 24 * 30))} mo`;
}

function timeAgo(dateString) {
  if (!dateString) return "-";
  const ms = parseMs(dateString);
  if (!ms) return "-";
  const diff = Date.now() - ms;
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

function formatTarget(dateString) {
  if (!dateString) return "-";
  const d = new Date(dateString);
  return d.toLocaleString();
}

/* Map enum -> label + icon */
function mapRecoveryType(name) {
  const n = (name || "").toUpperCase();
  switch (n) {
    case "PULSE_RATE":
      return { label: "Pulse rate returns to normal", Icon: Heart };
    case "OXYGEN_LEVEL":
      return { label: "Oxygen level returns to normal", Icon: Activity };
    case "CARBON_MONOXIDE_LEVEL":
      return { label: "Carbon monoxide level returns to normal", Icon: Zap };
    case "NICOTINE_EXPELLED_FROM_BODY":
      return { label: "Nicotine expelled from body", Icon: Target };
    case "TASTE_AND_SMELL":
      return { label: "Taste and smell improvement", Icon: Smile };
    case "BREATHING":
      return { label: "Breathing & cough improvement", Icon: Activity };
    case "ENERGY_LEVEL":
      return { label: "Energy level improves", Icon: TrendingUp };
    case "TOOTH_STAINING":
      return { label: "Tooth staining reduces", Icon: Award };
    case "GUMS_AND_TEETH":
      return { label: "Gums & teeth improvement", Icon: Smile };
    case "CIRCULATION":
      return {
        label: "Circulation & lung function improvement",
        Icon: TrendingUp,
      };
    case "GUM_TEXTURE":
      return { label: "Gum texture improves", Icon: Smile };
    case "IMMUNITY_AND_LUNG_FUNCTION":
      return { label: "Immunity & lung function improves", Icon: TrendingUp };
    case "REDUCED_RISK_OF_HEART_DISEASE":
      return { label: "Reduced risk of heart disease", Icon: Heart };
    case "DECREASED_RISK_OF_LUNG_CANCER":
      return { label: "Decreased risk of lung cancer", Icon: Heart };
    case "DECREASED_RISK_OF_HEART_ATTACK":
      return { label: "Decreased risk of heart attack", Icon: Heart };
    default:
      return {
        label: n.replace(/_/g, " ").toLowerCase() || "Unknown recovery",
        Icon: Heart,
      };
  }
}

/*
  Resolve target timestamp (ms) following backend rules:
  - If targetTime exists and is > start + 60s -> use parsed targetTime
  - Else if recoveryTime (minutes) exists and start exists -> start + recoveryTime*60s
  - Else null
*/
function resolveTargetMs(recovery) {
  if (!recovery) return null;
  const startMs = parseMs(recovery.timeTriggered);
  const apiTargetMs = parseMs(recovery.targetTime);

  if (startMs && apiTargetMs && apiTargetMs > startMs + 60_000) {
    return apiTargetMs;
  }

  if (
    startMs &&
    recovery.recoveryTime !== null &&
    recovery.recoveryTime !== undefined
  ) {
    const minutes = Number(recovery.recoveryTime);
    if (!Number.isNaN(minutes)) {
      return Math.round(startMs + minutes * 60_000);
    }
  }

  return null;
}

/* percent 0..100 from start->target using double recoveryTime */
function computePctToTarget(recovery) {
  const startMs = parseMs(recovery.timeTriggered);
  const targetMs = resolveTargetMs(recovery);
  if (!startMs || !targetMs) {
    // If backend sets targetTime == start (user NOT smoked) -> treat as done
    if (
      parseMs(recovery.targetTime) &&
      parseMs(recovery.timeTriggered) &&
      parseMs(recovery.targetTime) <= parseMs(recovery.timeTriggered) + 60_000
    ) {
      return 100;
    }
    return 0;
  }
  const now = Date.now();
  if (now >= targetMs) return 100;
  if (now <= startMs) return 0;
  const pct = ((now - startMs) / (targetMs - startMs)) * 100;
  return Math.max(0, Math.min(100, Math.round(pct)));
}

/* time left as string */
function getTimeLeftText(recovery) {
  const target = resolveTargetMs(recovery);
  if (!target) return "-";
  const now = Date.now();
  if (now >= target) return "Completed";
  return `${msToHuman(target - now)} left`;
}

/* ---------- Recovery card component ---------- */
function RecoveryCard({ recovery }) {
  // Safety check
  if (!recovery || !recovery.name) {
    return null; // Don't render invalid recovery cards
  }
  
  const { label, Icon } = mapRecoveryType(recovery.name);
  const pct = computePctToTarget(recovery);
  const isDone = pct >= 100;

  const displayValue =
    recovery.value !== null && recovery.value !== undefined
      ? recovery.value
      : recovery.recoveryTime
      ? humanDurationMinutes(recovery.recoveryTime)
      : "-";

  // Prefer showing API targetTime if it's meaningful, otherwise show estimated duration
  const showTarget = (() => {
    const apiTargetMs = parseMs(recovery.targetTime);
    const startMs = parseMs(recovery.timeTriggered);
    if (apiTargetMs && startMs && apiTargetMs > startMs + 60_000) {
      return formatTarget(recovery.targetTime);
    }
    if (recovery.recoveryTime !== null && recovery.recoveryTime !== undefined) {
      return `Estimated ${humanDurationMinutes(recovery.recoveryTime)}`;
    }
    return "-";
  })();

  return (
    <div className="group bg-white rounded-2xl shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden border border-gray-100">
      <div className="relative h-1.5 bg-gray-100">
        <div
          className={`absolute inset-y-0 left-0 rounded-r-full transition-all duration-500 ${
            isDone
              ? "bg-gradient-to-r from-emerald-500 to-teal-600"
              : "bg-gradient-to-r from-emerald-400 to-teal-500"
          }`}
          style={{ width: `${pct}%` }}
        />
      </div>

      <div className="p-5">
        <div className="flex items-start gap-4">
          <div
            className={`flex-shrink-0 w-12 h-12 rounded-xl flex items-center justify-center ${
              isDone
                ? "bg-gradient-to-br from-emerald-100 to-teal-100"
                : "bg-gradient-to-br from-gray-100 to-gray-50"
            }`}
          >
            <Icon
              size={22}
              className={isDone ? "text-emerald-600" : "text-gray-500"}
            />
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-4 mb-2">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-gray-900 text-sm truncate">
                    {recovery.description ?? label}
                  </h3>
                  {isDone && (
                    <CheckCircle2 size={16} className="text-emerald-500" />
                  )}
                </div>
                <div className="text-xs text-gray-500 mt-1">{label}</div>
              </div>

              <div className="flex-shrink-0 text-right">
                <div className="inline-flex items-center px-3 py-1 rounded-lg bg-gradient-to-br from-gray-50 to-white border border-gray-200">
                  <div className="text-sm font-bold text-gray-900">
                    {displayValue}
                  </div>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-4 text-xs text-gray-600 mb-3">
              <div className="flex items-center gap-1">
                <Clock size={14} className="text-gray-400" />
                <span>{timeAgo(recovery.timeTriggered)}</span>
              </div>
              <div className="flex items-center gap-1">
                <Target size={14} className="text-emerald-500" />
                <span>{showTarget}</span>
              </div>
              <div className="flex items-center gap-1">
                <span className="text-emerald-600 font-medium">
                  {getTimeLeftText(recovery)}
                </span>
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs">
                <span className="font-medium text-gray-700">
                  Recovery progress
                </span>
                <span
                  className={`font-bold ${
                    isDone ? "text-emerald-600" : "text-teal-600"
                  }`}
                >
                  {pct}%
                </span>
              </div>
              <div className="relative h-2 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className={`absolute inset-y-0 left-0 rounded-full transition-all duration-500 ${
                    isDone
                      ? "bg-gradient-to-r from-emerald-500 to-teal-600"
                      : "bg-gradient-to-r from-emerald-400 to-teal-500"
                  }`}
                  style={{ width: `${pct}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------- Main view ---------- */
export default function HealthRecoveriesView({
  healthRecoveries = [],
  loading = false,
  error = null,
}) {
  if (loading) {
    return (
      <div className="space-y-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div
            key={i}
            className="animate-pulse bg-white p-5 rounded-2xl h-28 border border-gray-100"
          />
        ))}
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-red-100 to-rose-100 flex items-center justify-center mb-4">
          <Heart size={32} className="text-red-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">Failed to load health recoveries</p>
        <p className="text-gray-500 text-sm text-center max-w-md">
          {typeof error === "string" ? error : "Unable to fetch recovery data. Please try again later."}
        </p>
      </div>
    );
  }

  // Filter out null/undefined recoveries
  const validRecoveries = Array.isArray(healthRecoveries)
    ? healthRecoveries.filter(r => r != null && r.id != null)
    : [];

  if (!validRecoveries || validRecoveries.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center mb-4">
          <Heart size={32} className="text-gray-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">No recovery events yet</p>
        <p className="text-gray-500 text-sm text-center max-w-md mt-1">
          Health recovery data will appear here once the member starts their quit plan and begins tracking progress.
        </p>
      </div>
    );
  }

  // Sort by unfinished first (lower pct first)
  const sorted = [...validRecoveries].sort(
    (a, b) => computePctToTarget(a) - computePctToTarget(b)
  );

  return (
    <div className="space-y-4">
      {sorted.map((r) => (
        <RecoveryCard key={r.id || Math.random()} recovery={r} />
      ))}
    </div>
  );
}
