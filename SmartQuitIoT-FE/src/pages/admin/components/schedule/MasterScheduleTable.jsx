import { Calendar, CalendarX, Trash, X } from "lucide-react";
import { useMemo } from "react";
import styles from "../../../../styles/SchedulePage.module.css";
import { formatDisplay } from "../../../../utils/formatDate";

export default function MasterScheduleTable({
  masterSchedule,
  coaches,
  handleUpdateDay,
  removeDate,
  loadingSchedule,
  selectedMonth,
  setSelectedMonth,
  selectedYear,
  setSelectedYear,
}) {
  if (loadingSchedule)
    return (
      <div className={styles.emptyMaster}>
        <Calendar className={styles.iconHuge} />
        <p className={styles.emptyTitle}>Loading schedule...</p>
      </div>
    );

  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  const years = Array.from(
    { length: 3 },
    (_, i) => new Date().getFullYear() - 1 + i
  );

  // ✅ Lọc các ngày trong tháng được chọn có coach làm việc
  const filteredDays = useMemo(() => {
    return masterSchedule.filter((m) => {
      const date = new Date(m.date);
      return (
        date.getFullYear() === selectedYear &&
        date.getMonth() + 1 === selectedMonth &&
        m.coachIds?.length > 0
      );
    });
  }, [masterSchedule, selectedMonth, selectedYear]);

  return (
    <div className={styles.masterCard}>
      {/* Header */}
      <div className={styles.masterHeader}>
        <div className={styles.masterLeft}>
          <Calendar className={styles.iconWhite} />
          <div>
            <h3 className={styles.masterTitle}>Work Schedule</h3>
            <p className={styles.masterSubtitle}>
              {months[selectedMonth - 1]} {selectedYear}
            </p>
          </div>
        </div>

        {/* Bộ chọn tháng / năm */}
        <div className={styles.monthPicker}>
          <select
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(parseInt(e.target.value))}
            className={styles.monthSelect}
          >
            {months.map((m, i) => (
              <option key={i + 1} value={i + 1}>
                {m}
              </option>
            ))}
          </select>

          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className={styles.yearSelect}
          >
            {years.map((y) => (
              <option key={y} value={y}>
                {y}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Không có coach nào trong tháng */}
      {filteredDays.length === 0 ? (
        <div className={styles.emptyMaster}>
          <CalendarX className={styles.iconHuge} />
          <p className={styles.emptyTitle}>
            No coaches scheduled for this month
          </p>
          <p className={styles.emptySub}>
            Try selecting a different month or add new schedules for coaches.
          </p>
        </div>
      ) : (
        /* Table */
        <div className={styles.tableWrap}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Date</th>
                <th>Coaches</th>
                {/* <th>Actions</th> */}
              </tr>
            </thead>
            <tbody>
              {filteredDays.map((row) => (
                <tr key={row.date} className={styles.tableRow}>
                  {/* Ngày */}
                  <td className={styles.tdDate}>
                    <div className={styles.rowDate}>
                      <Calendar className={styles.iconAccent} />
                      <span className={styles.dateText}>
                        {formatDisplay(row.date)}
                      </span>
                    </div>
                  </td>

                  {/* Coaches */}
                  <td className={styles.tdCoaches}>
                    <div className={styles.coachChips}>
                      {row.coachIds.map((cid) => {
                        const coach = coaches.find((c) => c.id === cid);
                        return (
                          <div key={cid} className={styles.coachChip}>
                            <span className={styles.coachChipText}>
                              {coach?.name || `ID ${cid}`}
                            </span>
                            <button
                              onClick={() =>
                                handleUpdateDay(row.date, [], [cid])
                              }
                              className={styles.removeCoachBtn}
                              title="Remove coach from this date"
                            >
                              <X className={styles.iconTinyRed} />
                            </button>
                          </div>
                        );
                      })}
                    </div>
                  </td>

                  {/* Thao tác */}
                  {/* <td className={styles.tdActions}>
                    <button
                      onClick={() => removeDate(row.date)}
                      className={styles.removeDateBtn}
                    >
                      <Trash className={styles.iconSmall} />
                      Xóa ngày
                    </button>
                  </td> */}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
