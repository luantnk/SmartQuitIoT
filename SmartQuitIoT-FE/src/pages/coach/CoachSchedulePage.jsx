import React, { useMemo, useState, useEffect } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import styles from "../../styles/CoachSchedulePage.module.css";
import { getMyWorkdays } from "@/services/scheduleService";

/**
 * Read-only calendar for Coach (server-controlled):
 * - show month view
 * - working day (green) vs off day (muted)
 * - server is single source-of-truth: user CANNOT toggle days locally
 */

/** CONFIG: change these 2 variables to modify default time displayed on the entire calendar */
const DEFAULT_START_TIME = "07:00";
const DEFAULT_END_TIME = "19:00";

/** ISO (local) - returns "YYYY-MM-DD" in local date (DO NOT use toISOString()) */
const ISO = (d) => {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0"); // getMonth() trả 0..11
  const dd = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${dd}`;
};

const monthGridStart = (year, month) => {
  const firstOfMonth = new Date(year, month, 1);
  const start = new Date(firstOfMonth);
  start.setDate(firstOfMonth.getDate() - firstOfMonth.getDay());
  return start;
};

const buildMonthGrid = (year, month) => {
  const start = monthGridStart(year, month);
  const grid = [];
  for (let i = 0; i < 42; i++) {
    const d = new Date(start);
    d.setDate(start.getDate() + i);
    grid.push(d);
  }
  return grid;
};

const CoachSchedulePage = () => {
  const today = new Date();
  const todayIso = ISO(
    new Date(today.getFullYear(), today.getMonth(), today.getDate())
  );

  const [viewDate, setViewDate] = useState(
    new Date(today.getFullYear(), today.getMonth(), 1)
  );

  // schedule: map iso -> { working: bool, start: DEFAULT_START_TIME, end: DEFAULT_END_TIME }
  const [schedule, setSchedule] = useState(() => {
    const start = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1);
    const map = {};
    const grid = buildMonthGrid(start.getFullYear(), start.getMonth());
    grid.forEach((d) => {
      const iso = ISO(new Date(d.getFullYear(), d.getMonth(), d.getDate()));
      map[iso] = {
        working: false,
        start: DEFAULT_START_TIME,
        end: DEFAULT_END_TIME,
      };
    });
    return map;
  });

  // regenerate grid when viewDate changes (and ensure schedule contains those days)
  const monthGrid = useMemo(() => {
    const grid = buildMonthGrid(viewDate.getFullYear(), viewDate.getMonth());
    setSchedule((prev) => {
      const copy = { ...prev };
      grid.forEach((d) => {
        const iso = ISO(new Date(d.getFullYear(), d.getMonth(), d.getDate()));
        if (!copy[iso]) {
          copy[iso] = {
            working: false,
            start: DEFAULT_START_TIME,
            end: DEFAULT_END_TIME,
          };
        }
      });
      return copy;
    });
    return grid;
  }, [viewDate]);

  // fetch workdays for the visible month and apply to schedule (server-only truth)
  useEffect(() => {
    let cancelled = false;
    const year = viewDate.getFullYear();
    const month = viewDate.getMonth() + 1; // backend expects 1-based month

    const fetch = async () => {
      try {
        const resp = await getMyWorkdays(year, month);
        const workdaysRaw = resp?.data?.data || []; // array of "YYYY-MM-DD"
        if (cancelled) return;

        const workdaySet = new Set(
          workdaysRaw.map((s) => {
            const dt = new Date(`${s}T00:00:00`);
            return ISO(dt);
          })
        );

        setSchedule(() => {
          const copy = {};
          const grid = buildMonthGrid(
            viewDate.getFullYear(),
            viewDate.getMonth()
          );
          grid.forEach((d) => {
            const iso = ISO(
              new Date(d.getFullYear(), d.getMonth(), d.getDate())
            );
            copy[iso] = {
              working: workdaySet.has(iso) ? true : false,
              start: DEFAULT_START_TIME,
              end: DEFAULT_END_TIME,
            };
          });
          return copy;
        });
      } catch (err) {
        console.error("Error fetching workdays:", err);
      }
    };

    fetch();
    return () => {
      cancelled = true;
    };
  }, [viewDate]);

  const goPrev = () => {
    const n = new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1);
    setViewDate(n);
  };
  const goNext = () => {
    const n = new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1);
    setViewDate(n);
  };

  // NOTE: user cannot toggle days — UI is read-only (server-controlled)
  const isCurrentMonth = (d) => d.getMonth() === viewDate.getMonth();

  const monthLabel = `${viewDate.toLocaleString("en-US", {
    month: "long",
  })} ${viewDate.getFullYear()}`;

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Work Schedule (Calendar)</h1>
          <p className={styles.subtitle}>
            Read-only calendar — day status is determined by the system
            (server).{" "}
            <strong>
              {DEFAULT_START_TIME} - {DEFAULT_END_TIME}
            </strong>{" "}
            is the default time for working days.
          </p>
        </div>

        <div className={styles.controls}>
          <button
            className={styles.iconBtn}
            onClick={goPrev}
            aria-label="Previous month"
          >
            <ChevronLeft />
          </button>
          <div className={styles.monthLabel}>{monthLabel}</div>
          <button
            className={styles.iconBtn}
            onClick={goNext}
            aria-label="Next month"
          >
            <ChevronRight />
          </button>
        </div>
      </div>

      <div className={styles.calendar}>
        <div className={styles.weekHead}>
          {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((w) => (
            <div key={w} className={styles.weekHeadItem}>
              {w}
            </div>
          ))}
        </div>

        <div className={styles.grid}>
          {monthGrid.map((d) => {
            const iso = ISO(
              new Date(d.getFullYear(), d.getMonth(), d.getDate())
            );
            const info = schedule[iso] || {
              working: false,
              start: DEFAULT_START_TIME,
              end: DEFAULT_END_TIME,
            };
            const working = info.working;
            const outside = !isCurrentMonth(d);
            const isToday = iso === todayIso;

            // if it's a day from another month → render empty cell (don't show date/label)
            if (outside) {
              return (
                <div
                  key={iso}
                  className={`${styles.day} ${styles.outside} ${styles.dayEmpty}`}
                  aria-hidden="true"
                >
                  <div className={styles.dayTop} />
                  <div className={styles.dayBottom} />
                </div>
              );
            }

            // Read-only cell (no onClick)
            return (
              <div
                key={iso}
                className={`${styles.day} ${
                  working ? styles.working : styles.off
                } ${isToday ? styles.today : ""}`}
                role="gridcell"
                aria-disabled="true"
                title={
                  working
                    ? "Working day (determined by system)"
                    : "Off day (determined by system)"
                }
              >
                <div className={styles.dayTop}>
                  <span className={styles.dayNum}>{d.getDate()}</span>
                  {working && (
                    <span className={styles.badge}>
                      {info.start} - {info.end}
                    </span>
                  )}
                </div>

                <div className={styles.dayBottom}>
                  {working ? (
                    <div className={styles.dot} />
                  ) : (
                    <div className={styles.offLabel}>OFF</div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div className={styles.legend}>
        <div className={styles.legendItem}>
          <span className={styles.legendSwatchWorking} /> Working day (
          {DEFAULT_START_TIME} - {DEFAULT_END_TIME})
        </div>
        <div className={styles.legendItem}>
          <span className={styles.legendSwatchOff} /> Off day
        </div>
      </div>
    </div>
  );
};

export default CoachSchedulePage;
