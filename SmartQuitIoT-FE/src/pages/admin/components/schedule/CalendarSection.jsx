import { Check, ChevronLeft, ChevronRight, Users } from "lucide-react";
import styles from "../../../../styles/SchedulePage.module.css";
import { getMonthGrid, isPast, toISODate } from "../../../../utils/formatDate";

export default function CalendarSection({
  year,
  month,
  setYear,
  setMonth,
  selectedDates,
  setSelectedDates,
  toggleDate,
  clearSelectedDates,
  masterSchedule,
}) {
  const weeks = getMonthGrid(year, month);
  const monthLabel = new Date(year, month - 1).toLocaleString("en-US", {
    month: "long",
    year: "numeric",
  });

  const prevMonth = () =>
    month === 1 ? (setMonth(12), setYear((y) => y - 1)) : setMonth(month - 1);
  const nextMonth = () =>
    month === 12 ? (setMonth(1), setYear((y) => y + 1)) : setMonth(month + 1);

  /* ✅ Chọn nhanh: từ hôm nay → hết tháng */
  const quickSelectRestOfMonth = () => {
    const today = new Date();
    const currentY = today.getFullYear();
    const currentM = today.getMonth() + 1;
    const currentD = today.getDate();

    if (year < currentY || (year === currentY && month < currentM)) {
      alert("Cannot select dates in the past.");
      return;
    }

    const daysInMonth = new Date(year, month, 0).getDate();
    const list = [];

    for (let d = 1; d <= daysInMonth; d++) {
      if (year === currentY && month === currentM && d < currentD) continue;
      const iso = toISODate(year, month, d);
      if (!isPast(year, month, d)) list.push(iso);
    }

    setSelectedDates(list);
  };

  return (
    <div className={styles.card}>
      {/* Header */}
      <div className={styles.cardHeader}>
        <div className={styles.monthNav}>
          <button className={styles.iconBtn} onClick={prevMonth}>
            <ChevronLeft className={styles.iconWhite} />
          </button>
          <div className={styles.monthLabel}>{monthLabel}</div>
          <button className={styles.iconBtn} onClick={nextMonth}>
            <ChevronRight className={styles.iconWhite} />
          </button>
        </div>

        <div className={styles.headerActions}>
          <button
            className={styles.btnGhost}
            onClick={quickSelectRestOfMonth}
            title="Select from today to end of month"
          >
            Quick Select
          </button>

          <button className={styles.btnGhostLight} onClick={clearSelectedDates}>
            Clear Selection
          </button>
        </div>
      </div>

      {/* Calendar body */}
      <div className={styles.calendarBody}>
        <div className={styles.weekHeader}>
          {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) => (
            <div key={day} className={styles.weekDay}>
              {day}
            </div>
          ))}
        </div>

        <div className={styles.calendarGrid}>
          {weeks.flatMap((week, wi) =>
            week.map((cell, ci) => {
              if (!cell)
                return (
                  <div key={`empty-${wi}-${ci}`} className={styles.emptyCell} />
                );
              const d = cell.day;
              const iso = toISODate(year, month, d);
              const selected = selectedDates.includes(iso);
              const hasAssigned = masterSchedule.some((r) => r.date === iso);
              const scheduleEntry = masterSchedule.find((r) => r.date === iso);
              const isCellPast = isPast(year, month, d);

              const cellClass = selected
                ? styles.daySelected
                : hasAssigned
                ? styles.dayAssigned
                : styles.day;

              return (
                <button
                  key={iso}
                  onClick={() => toggleDate(year, month, d)}
                  className={cellClass}
                  disabled={isCellPast}
                >
                  <div className={styles.dayInner}>
                    <div className={styles.dayNumber}>{d}</div>
                    {hasAssigned && !selected && (
                      <div className={styles.assignedBadge}>
                        <Users className={styles.iconTiny} />
                        <span className={styles.assignedCount}>
                          {scheduleEntry?.coachIds?.length || 0}
                        </span>
                      </div>
                    )}
                    {selected && <Check className={styles.iconCheck} />}
                  </div>
                </button>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}
