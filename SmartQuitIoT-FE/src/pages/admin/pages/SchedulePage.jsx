import React, { useEffect, useMemo, useState } from "react";
import styles from "../../../styles/SchedulePage.module.css";
import {
  getAllCoaches,
  assignSchedules,
  getMonthlySchedules,
  updateScheduleByDate,
} from "@/services/scheduleService";
import useToast from "@/hooks/useToast";
import useConfirm from "@/hooks/useConfirm";
import CalendarSection from "../components/schedule/CalendarSection";
import CoachSelector from "../components/schedule/CoachSelector";
import MasterScheduleTable from "../components/schedule/MasterScheduleTable";
import { formatDisplay } from "../../../utils/formatDate";
export default function SchedulePage() {
  const now = new Date();
  const [year, setYear] = useState(now.getFullYear());
  const [month, setMonth] = useState(now.getMonth() + 1);
  const [selectedDates, setSelectedDates] = useState([]);
  const [coaches, setCoaches] = useState([]);
  const [coachSearch, setCoachSearch] = useState("");
  const [selectedCoachIds, setSelectedCoachIds] = useState([]);
  const [masterSchedule, setMasterSchedule] = useState([]);
  const [loadingCoaches, setLoadingCoaches] = useState(false);
  const [loadingSchedule, setLoadingSchedule] = useState(false);
  const [assigning, setAssigning] = useState(false);

  const toast = useToast();
  const confirm = useConfirm();

  const visibleCoaches = useMemo(() => {
    const q = coachSearch.trim().toLowerCase();
    return q
      ? coaches.filter((c) => c.name.toLowerCase().includes(q))
      : coaches;
  }, [coaches, coachSearch]);

  /* -------- FETCH COACHES -------- */
  useEffect(() => {
    const fetchCoaches = async () => {
      setLoadingCoaches(true);
      try {
        const res = await getAllCoaches();
        if (res?.data?.success) {
          const data = res.data.data || [];
          setCoaches(
            data.map((c) => ({
              id: c.id,
              name:
                `${c.firstName || ""} ${c.lastName || ""}`.trim() ||
                `Coach ${c.id}`,
              avatar:
                c.avatarUrl ||
                `https://ui-avatars.com/api/?name=${encodeURIComponent(
                  `${c.firstName || ""} ${c.lastName || ""}`
                )}&background=random`,
            }))
          );
        } else toast.error("Failed to load coaches list.");
      } catch (err) {
        const errorMessage =
          err?.response?.data?.message ||
          err?.message ||
          "Failed to connect to server to fetch coaches list.";
        toast.error(errorMessage);
      } finally {
        setLoadingCoaches(false);
      }
    };
    fetchCoaches();
  }, [toast]);

  /* -------- FETCH SCHEDULE -------- */
  const fetchSchedules = async () => {
    setLoadingSchedule(true);
    try {
      const res = await getMonthlySchedules(year, month);
      if (res?.data?.success) {
        const data = (res.data.data || []).map((d) => ({
          date: d.date,
          coachIds: d.coachIds || d.coaches?.map((c) => c.id) || [],
        }));
        setMasterSchedule(data);
      } else toast.error("Failed to fetch schedule for this month.");
    } catch (err) {
      const errorMessage =
        err?.response?.data?.message ||
        err?.message ||
        "Error fetching schedule from server.";
      toast.error(errorMessage);
    } finally {
      setLoadingSchedule(false);
    }
  };

  useEffect(() => {
    fetchSchedules();
  }, [year, month]);

  /* -------- LOGIC -------- */
  const toggleDate = (y, m, d) => {
    const iso = `${y}-${String(m).padStart(2, "0")}-${String(d).padStart(
      2,
      "0"
    )}`;
    setSelectedDates((prev) =>
      prev.includes(iso) ? prev.filter((x) => x !== iso) : [...prev, iso].sort()
    );
  };
  const clearSelectedDates = () => setSelectedDates([]);
  const toggleCoach = (id) =>
    setSelectedCoachIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  const selectAllVisible = () =>
    setSelectedCoachIds(visibleCoaches.map((c) => c.id));
  const clearCoaches = () => setSelectedCoachIds([]);

  const handleAssign = async () => {
    if (!selectedDates.length || !selectedCoachIds.length)
      return toast.error("Please select dates and coaches before assigning.");

    const ok = await confirm({
      title: "Confirm Schedule Assignment",
      message: `Assign ${selectedCoachIds.length} coach${selectedCoachIds.length > 1 ? "es" : ""} to ${selectedDates.length} day${selectedDates.length > 1 ? "s" : ""}?`,
      okText: "Assign",
    });
    if (!ok) return;

    setAssigning(true);
    try {
      const res = await assignSchedules({
        dates: selectedDates,
        coachIds: selectedCoachIds,
      });
      if (res?.data?.success) {
        toast.success("Schedule assigned successfully!");
        await fetchSchedules();
        setSelectedDates([]);
        setSelectedCoachIds([]);
      } else {
        const errorMsg = res?.data?.message || "Failed to assign schedule.";
        toast.error(errorMsg);
      }
    } catch (err) {
      const errorMessage =
        err?.response?.data?.message ||
        err?.response?.data?.error ||
        err?.message ||
        "Error sending schedule assignment request.";
      toast.error(errorMessage);
      console.error("Assign schedule error:", err);
    } finally {
      setAssigning(false);
    }
  };

  const handleUpdateDay = async (
    date,
    addCoachIds = [],
    removeCoachIds = []
  ) => {
    const action = removeCoachIds.length > 0 ? "remove" : "add";
    const ok = await confirm({
      title: "Update Schedule",
      message: `${action === "remove" ? "Remove" : "Add"} coach${removeCoachIds.length > 1 || addCoachIds.length > 1 ? "es" : ""} from schedule on ${formatDisplay(date)}?`,
      okText: "Update",
    });
    if (!ok) return;

    try {
      const res = await updateScheduleByDate(date, {
        addCoachIds,
        removeCoachIds,
      });
      if (res?.data?.success) {
        toast.success("Schedule updated successfully!");
        await fetchSchedules();
      } else {
        const errorMsg = res?.data?.message || "Failed to update schedule.";
        toast.error(errorMsg);
      }
    } catch (err) {
      // Extract detailed error message from backend response
      const errorMessage =
        err?.response?.data?.message ||
        err?.response?.data?.error ||
        err?.message ||
        "Failed to update schedule. Please check your connection and try again.";
      toast.error(errorMessage);
      console.error("Update schedule error:", err);
    }
  };

  const removeDate = async (date) => {
    setMasterSchedule((prev) => prev.filter((r) => r.date !== date));
  };

  /* -------- RENDER -------- */
  return (
    <div className={styles.page}>
      <div className={styles.grid}>
        <div className={styles.colLeft}>
          <CalendarSection
            year={year}
            month={month}
            setYear={setYear}
            setMonth={setMonth}
            selectedDates={selectedDates}
            setSelectedDates={setSelectedDates}
            toggleDate={toggleDate}
            clearSelectedDates={clearSelectedDates}
            masterSchedule={masterSchedule}
          />
        </div>

        <div className={styles.colRight}>
          <CoachSelector
            coaches={coaches}
            visibleCoaches={visibleCoaches}
            loadingCoaches={loadingCoaches}
            coachSearch={coachSearch}
            setCoachSearch={setCoachSearch}
            selectedCoachIds={selectedCoachIds}
            toggleCoach={toggleCoach}
            selectAllVisible={selectAllVisible}
            clearCoaches={clearCoaches}
            assigning={assigning}
            handleAssign={handleAssign}
            selectedDates={selectedDates}
          />
        </div>
      </div>

      <MasterScheduleTable
        masterSchedule={masterSchedule}
        coaches={coaches}
        handleUpdateDay={handleUpdateDay}
        removeDate={removeDate}
        loadingSchedule={loadingSchedule}
        selectedMonth={month}
        setSelectedMonth={setMonth}
        selectedYear={year}
        setSelectedYear={setYear}
      />
    </div>
  );
}
