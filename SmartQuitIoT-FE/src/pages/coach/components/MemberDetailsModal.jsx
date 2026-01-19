// src/pages/coach/components/MemberDetailsModal.jsx
import React, { useState, useEffect, useRef } from "react";
import { X } from "lucide-react";
import MetricView from "./MetricView";
import QuitPlansView from "./QuitPlansView";
import HealthRecoveriesView from "./HealthRecoveriesView";
import { getMemberMetrics } from "@/services/metricService";
import { getQuitPlanByMemberId } from "@/services/quitPlanService";

const TABS = [
  { key: "metric", label: "Metrics" },
  { key: "quitPlans", label: "Quit Plans" },
  { key: "healthRecoveries", label: "Health Recovery" },
];

export default function MemberDetailsModal({
  member,
  open,
  onClose,
  initialTab,
}) {
  const [tab, setTab] = useState(initialTab || "metric");

  // Metric states
  const [metrics, setMetrics] = useState(null);
  const [healthRecoveries, setHealthRecoveries] = useState([]);
  const [loadingMetrics, setLoadingMetrics] = useState(false);
  const [metricsError, setMetricsError] = useState(null);

  // QuitPlan states
  const [quitPlans, setQuitPlans] = useState([]);
  const [loadingQuitPlans, setLoadingQuitPlans] = useState(false);
  const [quitPlansError, setQuitPlansError] = useState(null);

  const dialogRef = useRef(null);
  const abortRef = useRef(null);

  useEffect(() => {
    if (open) setTab(initialTab || "metric");
  }, [open, initialTab]);

  // Fetch metrics + healthRecoveries when modal opens (same controller)
  useEffect(() => {
    if (!open || !member) return;

    // cancel previous requests
    if (abortRef.current) {
      try {
        abortRef.current.abort();
      } catch {
        // Ignore abort errors
      }
    }
    const controller = new AbortController();
    abortRef.current = controller;

    // metrics loader
    const loadMetrics = async () => {
      setLoadingMetrics(true);
      setMetricsError(null);
      try {
        const resp = await getMemberMetrics(member.id, {
          signal: controller.signal,
        });
        const payload = resp && resp.data ? resp.data : resp;
        const fetchedHealth = payload.healthRecoveries ?? [];
        // backend uses "metrics" key according to swagger
        const fetchedMetrics = payload.metrics ?? payload.metric ?? null;
        setHealthRecoveries(fetchedHealth);
        setMetrics(fetchedMetrics);
      } catch (err) {
        if (err.name !== "CanceledError" && err.name !== "AbortError") {
          console.error("Failed to load member metrics", err);
          setMetricsError("Failed to load metrics data.");
          setMetrics(null);
          setHealthRecoveries([]);
        }
      } finally {
        setLoadingMetrics(false);
      }
    };

    // quit plan loader
    const loadQuitPlan = async () => {
      setLoadingQuitPlans(true);
      setQuitPlansError(null);
      try {
        const resp = await getQuitPlanByMemberId(member.id, {
          signal: controller.signal,
        });
        const payload = resp && resp.data ? resp.data : resp;

        // swagger returns single quit-plan object for member
        // normalize to array for QuitPlansView which expects array
        if (!payload) {
          setQuitPlans([]);
        } else if (Array.isArray(payload)) {
          setQuitPlans(payload);
        } else {
          // single object -> wrap into array
          setQuitPlans([payload]);
        }
      } catch (err) {
        if (err.name !== "CanceledError" && err.name !== "AbortError") {
          console.error("Failed to load quit plan", err);
          setQuitPlansError("Failed to load quit plan data.");
          setQuitPlans([]);
        }
      } finally {
        setLoadingQuitPlans(false);
      }
    };

    // kick both (parallel)
    loadMetrics();
    loadQuitPlan();

    return () => {
      try {
        controller.abort();
      } catch {
        // Ignore abort errors
      }
    };
  }, [open, member]);

  // close on Esc
  useEffect(() => {
    if (!open) return;
    const onKey = (e) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  // prevent body scroll when modal open
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  if (!open || !member) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-6"
      aria-modal="true"
      role="dialog"
      aria-labelledby="member-details-title"
    >
      {/* backdrop */}
      <div
        className="absolute inset-0 bg-black/40"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* modal container */}
      <div
        ref={dialogRef}
        className="relative w-full max-w-6xl bg-white rounded-xl shadow-lg overflow-hidden z-10"
        style={{ maxHeight: "100vh" }}
      >
        <div className="flex items-center justify-between p-4 border-b">
          <div>
            <div id="member-details-title" className="font-semibold text-lg">
              {member.firstName} {member.lastName}
            </div>
            <div className="text-sm text-gray-500">
              Updated:{" "}
              {member.modifiedAt
                ? new Date(member.modifiedAt).toLocaleString()
                : "-"}
            </div>
          </div>
          <div>
            <button
              onClick={onClose}
              className="p-2 rounded hover:bg-gray-100"
              aria-label="Close member details"
            >
              <X />
            </button>
          </div>
        </div>

        <div className="flex">
          {/* Left: tabs */}
          <aside className="w-56 border-r p-4 bg-gray-50 flex-shrink-0">
            <div className="flex flex-col gap-2 sticky top-4">
              {TABS.map((t) => (
                <button
                  key={t.key}
                  onClick={() => setTab(t.key)}
                  className={`text-left w-full px-3 py-2 rounded-md transition ${
                    tab === t.key ? "bg-white shadow" : "hover:bg-gray-100"
                  }`}
                  aria-pressed={tab === t.key}
                >
                  <div className="text-sm font-medium">{t.label}</div>
                </button>
              ))}
            </div>
          </aside>

          {/* Right: content (scrollable) */}
          <main
            className="flex-1 p-6 overflow-y-auto"
            style={{ maxHeight: "74vh" }}
          >
            {tab === "metric" && (
              <MetricView 
                metric={metrics} 
                loading={loadingMetrics}
                error={metricsError}
              />
            )}

            {tab === "quitPlans" && (
              <QuitPlansView 
                quitPlans={quitPlans} 
                loading={loadingQuitPlans}
                error={quitPlansError}
              />
            )}

            {tab === "healthRecoveries" && (
              <HealthRecoveriesView
                healthRecoveries={healthRecoveries || []}
                loading={loadingMetrics}
                error={metricsError}
              />
            )}
          </main>
        </div>
      </div>
    </div>
  );
}
