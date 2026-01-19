// src/pages/coach/components/QuitPlansView.jsx
import React, { useMemo, useState } from "react";
import {
  Calendar,
  CheckCircle2,
  Clock,
  PlayCircle,
  XCircle,
  Layers,
  Award,
  TrendingUp,
  ChevronDown,
  ChevronRight,
} from "lucide-react";

/* ---------- Helpers ---------- */
function statusConfig(status) {
  switch (status) {
    case "IN_PROGRESS":
      return {
        color: "from-amber-100 to-orange-100 text-amber-800 border-amber-200",
        icon: PlayCircle,
        label: "IN_PROGRESS",
      };
    case "COMPLETED":
      return {
        color:
          "from-emerald-100 to-teal-100 text-emerald-800 border-emerald-200",
        icon: CheckCircle2,
        label: "COMPLETED",
      };
    case "CREATED":
      return {
        color: "from-blue-100 to-indigo-100 text-blue-800 border-blue-200",
        icon: Clock,
        label: "CREATED",
      };
    case "CANCELLED":
      return {
        color: "from-red-100 to-rose-100 text-red-800 border-red-200",
        icon: XCircle,
        label: "CANCELLED",
      };
    default:
      return {
        color: "from-gray-100 to-gray-200 text-gray-800 border-gray-200",
        icon: Clock,
        label: status,
      };
  }
}

function daysBetween(a, b) {
  return Math.max(
    0,
    Math.round(
      (new Date(b).getTime() - new Date(a).getTime()) / (1000 * 60 * 60 * 24)
    )
  );
}

function formatDate(dateString) {
  if (!dateString) return "-";
  const date = new Date(dateString);
  return date.toLocaleDateString("vi-VN", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}

function Chip({ children, className = "" }) {
  return (
    <span
      className={`inline-flex items-center gap-2 px-2 py-0.5 rounded-full text-xs font-medium ${className}`}
    >
      {children}
    </span>
  );
}

function ProgressBar({ value = 0 }) {
  return (
    <div className="w-full bg-gray-100 rounded-full h-2 overflow-hidden">
      <div
        className="h-full bg-gradient-to-r from-emerald-400 to-teal-500 transition-all"
        style={{ width: `${Math.max(0, Math.min(100, value))}%` }}
      />
    </div>
  );
}

/* ---------- MissionRow ---------- */
function MissionRow({ mission }) {
  const status = (mission.status || "").toUpperCase();
  const isDone =
    status === "COMPLETED" || status === "DONE" || status === "FINISHED";
  const statusClass = isDone
    ? "bg-emerald-100 text-emerald-800"
    : status === "INCOMPLETED" || status === "INCOMPLETE"
    ? "bg-amber-50 text-amber-800"
    : "bg-gray-100 text-gray-700";

  return (
    <div className="flex items-start gap-4 p-3 rounded-lg hover:bg-gray-50 transition">
      <div className="w-10 flex-shrink-0">
        <div
          className={`w-9 h-9 rounded-lg flex items-center justify-center ${
            isDone ? "bg-emerald-50" : "bg-gray-50"
          }`}
        >
          {isDone ? (
            <CheckCircle2 className="text-emerald-500" />
          ) : (
            <Clock className="text-gray-400" />
          )}
        </div>
      </div>

      <div className="flex-1">
        <div className="flex items-center justify-between gap-4">
          <div className="font-medium text-sm text-gray-900">
            {mission.name}
          </div>
          <div className="text-xs text-gray-400">{mission.code}</div>
        </div>
        <div className="text-sm text-gray-600 mt-1">{mission.description}</div>
        <div className="mt-2 flex items-center gap-2">
          <Chip className={statusClass}>{mission.status ?? "UNKNOWN"}</Chip>
          {mission.eta && (
            <Chip className="bg-gray-50 text-gray-600">
              ETA: {formatDate(mission.eta)}
            </Chip>
          )}
        </div>
      </div>
    </div>
  );
}

/* ---------- DayDetail (collapsible) ---------- */
function DayDetail({ detail }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="border border-gray-100 rounded-xl overflow-hidden">
      <button
        className="w-full flex items-center justify-between p-3 bg-white hover:bg-gray-50"
        onClick={() => setOpen((s) => !s)}
        aria-expanded={open}
      >
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded-full bg-indigo-500" />
          <div>
            <div className="font-medium">{detail.name}</div>
            {/* <div className="text-xs text-gray-500">
              {formatDate(detail.date)} · Day: {detail.dayIndex}
            </div> */}
          </div>
        </div>
        <div className="text-sm text-gray-500 flex items-center gap-3">
          {/* <div>
            {detail.missionCompleted}/{detail.totalMission} completed
          </div> */}
          {open ? <ChevronDown /> : <ChevronRight />}
        </div>
      </button>

      {open && (
        <div className="p-3 bg-gray-50">
          <div className="space-y-2">
            {detail.missions && detail.missions.length ? (
              detail.missions
                .filter((m) => m != null) // Filter null missions
                .map((m) => (
                  <MissionRow key={m.id || Math.random()} mission={m} />
                ))
            ) : (
              <div className="text-sm text-gray-500 p-3 bg-white rounded border border-gray-100">
                No missions scheduled for this day.
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

/* ---------- PhaseCard (collapsible) ---------- */
function PhaseCard({ phase }) {
  const [open, setOpen] = useState(false);

  const totalMissions =
    phase.totalMissions ??
    phase.details?.reduce((acc, d) => acc + (d.totalMission ?? 0), 0);
  const completed =
    phase.completedMissions ??
    phase.details?.reduce((acc, d) => acc + (d.missionCompleted ?? 0), 0);
  const progress =
    totalMissions > 0
      ? Math.round((completed / totalMissions) * 100)
      : phase.progress ?? 0;

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div className="p-4 flex items-start justify-between gap-4">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-1">
            <div className="w-9 h-9 rounded-lg bg-indigo-50 flex items-center justify-center">
              <Layers className="text-indigo-600" />
            </div>
            <div>
              <div className="font-semibold text-gray-900">{phase.name}</div>
              <div className="text-sm text-gray-500">{phase.reason}</div>
            </div>
          </div>

          <div className="mt-3 grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="text-sm">
              <div className="text-xs text-gray-500">Time Period</div>
              <div className="font-medium">
                {formatDate(phase.startDate) || "-"} →{" "}
                {formatDate(phase.endDate) || "-"}
              </div>
            </div>

            <div className="text-sm">
              <div className="text-xs text-gray-500">Missions</div>
              <div className="font-medium">
                {completed || 0}/{totalMissions || 0} Completed
              </div>
            </div>

            <div>
              <div className="text-xs text-gray-500">Progress</div>
              <div className="mt-1">
                <ProgressBar value={progress} />
              </div>
              <div className="text-xs text-indigo-700 font-semibold mt-1">
                {progress}%
              </div>
            </div>
          </div>
        </div>

        <div className="flex-shrink-0">
          <button
            className="inline-flex items-center gap-2 px-3 py-2 rounded-xl bg-white border border-gray-200 shadow-sm hover:bg-gray-50"
            onClick={() => setOpen((s) => !s)}
          >
            <span className="text-sm text-gray-700">
              {open ? "Hide details" : "View details"}
            </span>
            {open ? <ChevronDown /> : <ChevronRight />}
          </button>
        </div>
      </div>

      {open && (
        <div className="p-4 border-t border-gray-100 bg-gray-50 space-y-3">
          {/* Condition summary */}
          {/* {phase.condition && (
            <div className="rounded-lg p-3 bg-white border border-gray-100">
              <div className="text-xs text-gray-500 mb-2">
                Điều kiện tự động kết thúc giai đoạn
              </div>
              <pre className="text-xs text-gray-700 whitespace-pre-wrap">
                {JSON.stringify(phase.condition, null, 2)}
              </pre>
            </div>
          )} */}

          {/* Details / day list */}
          <div className="space-y-2">
            {phase.details && phase.details.length ? (
              phase.details.map((d) => <DayDetail key={d.id} detail={d} />)
            ) : (
              <div className="text-sm text-gray-500 p-3"></div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

/* ---------- Main QuitPlansView ---------- */
export default function QuitPlansView({
  quitPlans = [],
  loading = false,
  error = null,
}) {
  // Error state
  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-red-100 to-rose-100 flex items-center justify-center mb-4">
          <Calendar size={32} className="text-red-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">
          Failed to load quit plans
        </p>
        <p className="text-gray-500 text-sm text-center max-w-md">
          {typeof error === "string"
            ? error
            : "Unable to fetch quit plans. Please try again later."}
        </p>
      </div>
    );
  }

  const plans = Array.isArray(quitPlans)
    ? quitPlans.filter((p) => p != null) // Filter out null/undefined
    : quitPlans && typeof quitPlans === "object"
    ? [quitPlans]
    : [];

  const sortedPlans = useMemo(() => {
    const priority = { IN_PROGRESS: 0, PLANNED: 1, COMPLETED: 2, CANCELLED: 3 };
    return [...plans].sort(
      (a, b) => (priority[a.status] ?? 99) - (priority[b.status] ?? 99)
    );
  }, [plans]);

  if (loading) {
    return (
      <div className="space-y-3">
        {Array.from({ length: 2 }).map((_, i) => (
          <div
            key={i}
            className="animate-pulse bg-white p-6 rounded-2xl h-40 border border-gray-100"
          />
        ))}
      </div>
    );
  }

  if (!plans || plans.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-20 h-20 rounded-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center mb-4">
          <Calendar size={32} className="text-gray-400" />
        </div>
        <p className="text-gray-700 font-semibold mb-1">No quit plans yet</p>
        <p className="text-gray-500 text-sm text-center max-w-md mt-1">
          The member hasn't created any quit plans. Plans will appear here once
          they start their journey.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      {sortedPlans.map((plan) => {
        // derive counts from phases if not provided
        const phasesCount = plan.phases?.length ?? 0;
        const completedPhases =
          plan.phases?.filter((p) => (p.progress ?? 0) >= 100).length ?? 0;

        // derive total days
        const start = plan.startDate ? new Date(plan.startDate) : null;
        const end = plan.endDate ? new Date(plan.endDate) : null;
        const totalDays = start && end ? daysBetween(start, end) : 0;
        const elapsed = start ? daysBetween(start, new Date()) : 0;
        const overallProgress =
          totalDays > 0
            ? Math.min(100, Math.round((elapsed / totalDays) * 100))
            : plan.progress ?? 0;

        return (
          <div
            key={plan.id}
            className="bg-white rounded-2xl shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden border border-gray-100"
          >
            {/* top status */}
            <div className="h-1.5 bg-gradient-to-r from-emerald-400 to-teal-500" />

            <div className="p-6 space-y-4">
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-3">
                    <h3 className="text-lg font-bold text-gray-900">
                      {plan.name}
                    </h3>
                    {plan.status === "COMPLETED" && (
                      <Award size={20} className="text-emerald-500" />
                    )}
                    <div className="text-sm text-gray-500">
                      · {plan.id ? `#${plan.id}` : null}
                    </div>
                  </div>
                  <div className="mt-2 flex flex-wrap items-center gap-2">
                    {plan.ftndScore !== undefined && (
                      <Chip className="bg-purple-50 text-purple-700 border border-purple-200">
                        <TrendingUp size={14} />
                        FTND {plan.ftndScore}
                      </Chip>
                    )}
                    {plan.useNRT && (
                      <Chip className="bg-teal-50 text-teal-700 border border-teal-200">
                        💊 NRT
                      </Chip>
                    )}
                    {plan.formMetricDTO && (
                      <Chip className="bg-gray-50 text-gray-700 border border-gray-200">
                        T: {plan.formMetricDTO.smokeAvgPerDay ?? "-"}
                        cigarattes/day
                        {/* · Đ
                        {plan.formMetricDTO.estimatedMoneySavedOnPlan ?? "-"} */}
                      </Chip>
                    )}
                  </div>
                </div>

                <div
                  className={`inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-br ${
                    statusConfig(plan.status).color
                  } border font-semibold text-sm shadow-sm`}
                >
                  <span>{statusConfig(plan.status).label}</span>
                </div>
              </div>

              {/* reason */}
              {plan.reason && (
                <div className="p-4 rounded-xl bg-gray-50 border border-gray-100 text-sm text-gray-700">
                  <div className="font-medium text-gray-800 mb-1">
                    Reason / Summary
                  </div>
                  <div className="text-sm text-gray-600 break-words">
                    {plan.reason}
                  </div>
                </div>
              )}

              {/* timeline + progress */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-center">
                <div>
                  <div className="text-xs text-gray-500">Time Period</div>
                  <div className="font-medium">
                    {formatDate(plan.startDate) || "-"} →{" "}
                    {formatDate(plan.endDate) || "-"}
                  </div>
                  <div className="text-sm text-gray-500 mt-1">
                    {elapsed || 0}/{totalDays || 0} days
                  </div>
                </div>

                <div className="md:col-span-2">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-xs text-gray-500">
                      Overall Progress
                    </div>
                    <div className="text-sm font-semibold text-emerald-600">
                      {overallProgress}%
                    </div>
                  </div>
                  <ProgressBar value={overallProgress} />
                </div>
              </div>

              {/* phases list */}
              <div className="space-y-3">
                <div className="flex items-center justify-between mb-2">
                  <div className="text-sm font-medium text-gray-700">
                    Phase ({phasesCount})
                  </div>
                  {/* <div className="text-xs text-gray-500">
                    Complete: {completedPhases}/{phasesCount}
                  </div> */}
                </div>

                <div className="space-y-3">
                  {plan.phases && plan.phases.length ? (
                    plan.phases.map((p) => (
                      <PhaseCard
                        key={p.id}
                        phase={{
                          ...p,
                          totalMissions:
                            p.totalMissions ??
                            (p.details?.reduce(
                              (acc, d) => acc + (d.totalMission || 0),
                              0
                            ) ||
                              0),
                          completedMissions:
                            p.completedMissions ??
                            (p.details?.reduce(
                              (acc, d) => acc + (d.missionCompleted || 0),
                              0
                            ) ||
                              0),
                        }}
                      />
                    ))
                  ) : (
                    <div className="text-sm text-gray-500 p-3 bg-white rounded border border-gray-100">
                      No phases available for this plan
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
