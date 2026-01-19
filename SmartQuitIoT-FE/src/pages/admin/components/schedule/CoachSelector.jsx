import { Check, Users } from "lucide-react";
import styles from "../../../../styles/SchedulePage.module.css";

export default function CoachSelector({
  coaches,
  visibleCoaches,
  loadingCoaches,
  coachSearch,
  setCoachSearch,
  selectedCoachIds,
  toggleCoach,
  selectAllVisible,
  clearCoaches,
  assigning,
  handleAssign,
  selectedDates,
}) {
  return (
    <div className={styles.card}>
      <div className={styles.coachHeader}>
        <div className={styles.coachTitle}>
          <Users className={styles.iconMuted} />
          <div className={styles.coachTitleTextWrap}>
            <h3 className={styles.coachTitleText}>Select Coaches</h3>
            <p className={styles.coachSubtitle}>Multi-select</p>
          </div>
        </div>
        <div className={styles.coachCount}>
          <span className={styles.coachCountBig}>
            {selectedCoachIds.length}
          </span>
          <span className={styles.coachCountLabel}>selected</span>
        </div>
      </div>

      <div className={styles.cardBody}>
        <input
          placeholder="🔍 Search coaches..."
          value={coachSearch}
          onChange={(e) => setCoachSearch(e.target.value)}
          className={styles.searchInput}
        />
        <div className={styles.coachList}>
          {loadingCoaches ? (
            <div style={{ padding: 12 }}>Loading coaches...</div>
          ) : visibleCoaches.length === 0 ? (
            <div style={{ padding: 12 }}>No matching coaches found.</div>
          ) : (
            visibleCoaches.map((c) => {
              const checked = selectedCoachIds.includes(c.id);
              return (
                <label
                  key={c.id}
                  className={`${styles.coachItem} ${
                    checked ? styles.coachItemSelected : ""
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={() => toggleCoach(c.id)}
                    className={styles.checkbox}
                  />
                  <img src={c.avatar} alt={c.name} className={styles.avatar} />
                  <div className={styles.coachInfo}>
                    <div className={styles.coachName}>{c.name}</div>
                    <div className={styles.coachId}>ID: {c.id}</div>
                  </div>
                  {checked && <Check className={styles.iconCheckSelected} />}
                </label>
              );
            })
          )}
        </div>

        <div className={styles.coachActions}>
          <button onClick={selectAllVisible} className={styles.btnOutline}>
            Select All
          </button>
          <button onClick={clearCoaches} className={styles.btnGhostOutline}>
            Clear Selection
          </button>
        </div>

        <button
          onClick={handleAssign}
          disabled={
            !selectedDates.length || !selectedCoachIds.length || assigning
          }
          className={styles.assignButton}
        >
          {assigning
            ? "Assigning..."
            : `Assign ${selectedCoachIds.length} coach${selectedCoachIds.length > 1 ? "es" : ""} to ${selectedDates.length} day${selectedDates.length > 1 ? "s" : ""}`}
        </button>
      </div>
    </div>
  );
}
