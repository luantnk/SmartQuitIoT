// src/components/FloatingNotifications.jsx
import React, { useEffect, useRef, useState } from "react";
import bookedNoti from "@/assets/booked_notification.mp3";
import cancelledNoti from "@/assets/Cancelled_Notification.mp3";
import reminderNoti from "@/assets/reminder_notification.mp3";

/**
 * Vibrant FloatingNotifications with sound (limited to 3s)
 * - presence handling removed (DEFAULT used for unknown types)
 * - sounds auto-stop after 3s
 */

const TYPE_STYLE = {
  APPOINTMENT_BOOKED: {
    gradient: "bg-gradient-to-r from-[#34D399] to-[#10B981]",
    glow: "shadow-[0_6px_24px_rgba(16,185,129,0.18)]",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
        <path
          d="M5 13l4 4L19 7"
          stroke="white"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  APPOINTMENT_CANCELLED: {
    gradient: "bg-gradient-to-r from-[#FF7A7A] to-[#FF4D4D]",
    glow: "shadow-[0_6px_24px_rgba(255,77,77,0.18)]",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
        <path
          d="M6 18L18 6M6 6l12 12"
          stroke="white"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  APPOINTMENT_REMINDER: {
    gradient: "bg-gradient-to-r from-[#FFD166] to-[#FFB020]",
    glow: "shadow-[0_6px_24px_rgba(255,176,32,0.14)]",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
        <path
          d="M12 8v5l3 3"
          stroke="white"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M18.4 6.6A8 8 0 1 0 5.6 19.4"
          stroke="white"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  DEFAULT: {
    gradient: "bg-gradient-to-r from-[#A78BFA] to-[#7C3AED]",
    glow: "shadow-[0_6px_24px_rgba(124,58,237,0.12)]",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
        <path
          d="M12 5v7l4 2"
          stroke="white"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
};

export default function FloatingNotifications({ max = 3, ttl = 8 }) {
  const [toasts, setToasts] = useState([]);
  const shownRef = useRef(new Set());
  const timersRef = useRef(new Map());

  // audio refs + timers
  const bookedAudioRef = useRef(null);
  const cancelledAudioRef = useRef(null);
  const reminderAudioRef = useRef(null);
  const bookedAudioTimerRef = useRef(null);
  const cancelledAudioTimerRef = useRef(null);
  const reminderAudioTimerRef = useRef(null);

  const [soundEnabled, setSoundEnabled] = useState(true);

  useEffect(() => {
    bookedAudioRef.current = new Audio(bookedNoti);
    cancelledAudioRef.current = new Audio(cancelledNoti);
    reminderAudioRef.current = new Audio(reminderNoti);

    [bookedAudioRef, cancelledAudioRef, reminderAudioRef].forEach((r) => {
      if (r.current) {
        r.current.volume = 0.65;
        r.current.loop = false;
      }
    });

    return () => {
      try {
        bookedAudioRef.current?.pause();
        cancelledAudioRef.current?.pause();
        reminderAudioRef.current?.pause();
      } catch (e) {}
      clearTimeout(bookedAudioTimerRef.current);
      clearTimeout(cancelledAudioTimerRef.current);
      clearTimeout(reminderAudioTimerRef.current);
    };
  }, []);

  useEffect(() => {
    const makeId = (payload) =>
      payload?.id ??
      payload?.deepLink ??
      `${payload?.notificationType ?? "notif"}_${
        payload?.title ?? "t"
      }_${Date.now()}`;

    const normalize = (p) => {
      if (!p) return null;
      const notificationType = p.notificationType ?? p.type ?? "DEFAULT";
      return {
        id: makeId(p),
        title: p.title || "Notification",
        content: p.content || "",
        url: p.url,
        deepLink: p.deepLink,
        notificationType,
      };
    };

    const stopAudio = (audioRef, timerRef) => {
      try {
        if (audioRef?.current) {
          audioRef.current.pause();
          audioRef.current.currentTime = 0;
        }
      } catch (e) {}
      if (timerRef?.current) {
        clearTimeout(timerRef.current);
        timerRef.current = null;
      }
    };

    const playWithLimit = async (audioRef, timerRef, maxMs = 3000) => {
      if (!soundEnabled) return;
      if (!audioRef?.current) return;
      try {
        audioRef.current.currentTime = 0;
        await audioRef.current.play();
      } catch (err) {
        if (process.env.NODE_ENV === "development")
          console.warn("Play failed:", err);
      }
      if (timerRef?.current) clearTimeout(timerRef.current);
      timerRef.current = setTimeout(() => stopAudio(audioRef, timerRef), maxMs);
    };

    const show = (raw) => {
      const payload = normalize(raw);
      if (!payload) return;
      if (shownRef.current.has(payload.id)) return;
      shownRef.current.add(payload.id);

      setToasts((prev) => [payload, ...prev].slice(0, max));

      // sounds limited to ~3s
      if (payload.notificationType === "APPOINTMENT_BOOKED") {
        playWithLimit(bookedAudioRef, bookedAudioTimerRef, 3000);
      } else if (payload.notificationType === "APPOINTMENT_CANCELLED") {
        playWithLimit(cancelledAudioRef, cancelledAudioTimerRef, 3000);
      } else if (payload.notificationType === "APPOINTMENT_REMINDER") {
        playWithLimit(reminderAudioRef, reminderAudioTimerRef, 3000);
      }

      const timer = setTimeout(() => removeById(payload.id), ttl * 1000);
      timersRef.current.set(payload.id, timer);
    };

    const handler = (e) => show(e.detail);

    window.addEventListener("ws:notification", handler);

    return () => {
      window.removeEventListener("ws:notification", handler);
      for (const t of timersRef.current.values()) clearTimeout(t);
      timersRef.current.clear();
      shownRef.current.clear();
      stopAudio(bookedAudioRef, bookedAudioTimerRef);
      stopAudio(cancelledAudioRef, cancelledAudioTimerRef);
      stopAudio(reminderAudioRef, reminderAudioTimerRef);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [max, ttl, soundEnabled]);

  const removeById = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
    const timer = timersRef.current.get(id);
    if (timer) {
      clearTimeout(timer);
      timersRef.current.delete(id);
    }
    shownRef.current.delete(id);
  };

  return (
    <>
      <style>{`
        @keyframes notifEnter {
          0% { transform: translateY(-10px) scale(.98); opacity: 0; filter: blur(2px); }
          60% { transform: translateY(4px) scale(1.02); opacity: 1; filter: blur(0); }
          100% { transform: translateY(0) scale(1); }
        }
        @keyframes progress { from { width: 100%; } to { width: 0%; } }
      `}</style>

      <div
        style={{
          position: "fixed",
          right: 16,
          top: 16,
          zIndex: 99999,
          width: "100%",
          maxWidth: 420,
          pointerEvents: "auto",
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "flex-end",
            marginBottom: 8,
          }}
        >
          <button
            aria-pressed={!soundEnabled}
            onClick={() => setSoundEnabled((s) => !s)}
            title={
              soundEnabled
                ? "Mute notification sounds"
                : "Unmute notification sounds"
            }
            style={{
              background: soundEnabled
                ? "linear-gradient(90deg,#10B981,#34D399)"
                : "transparent",
              color: soundEnabled ? "white" : "#374151",
              border: "1px solid rgba(0,0,0,0.06)",
              padding: "6px 8px",
              borderRadius: 8,
              cursor: "pointer",
              boxShadow: soundEnabled
                ? "0 6px 18px rgba(16,185,129,0.18)"
                : "none",
              fontWeight: 600,
              fontSize: 13,
            }}
          >
            {soundEnabled ? "🔊On" : "🔈Off "}
          </button>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {toasts.map((t) => {
            const cfg = TYPE_STYLE[t.notificationType] || TYPE_STYLE.DEFAULT;
            return (
              <div
                key={t.id}
                className={cfg.glow}
                style={{
                  display: "flex",
                  width: "100%",
                  borderRadius: 12,
                  overflow: "hidden",
                  animation: "notifEnter 360ms cubic-bezier(.2,.9,.3,1)",
                  boxShadow: "0 10px 30px rgba(2,6,23,0.08)",
                  background:
                    "linear-gradient(180deg, rgba(255,255,255,0.96), rgba(255,255,255,0.92))",
                  border: "1px solid rgba(255,255,255,0.6)",
                  backdropFilter: "blur(6px)",
                  alignItems: "stretch",
                }}
                role="status"
                aria-live="polite"
              >
                <div
                  className={`flex items-center justify-center px-3 ${cfg.gradient}`}
                  style={{ minWidth: 56 }}
                >
                  <div
                    style={{
                      width: 44,
                      height: 44,
                      borderRadius: 10,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                    }}
                  >
                    {cfg.icon}
                  </div>
                </div>

                <div style={{ flex: 1, padding: "12px 12px 12px 10px" }}>
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      gap: 8,
                      alignItems: "flex-start",
                    }}
                  >
                    <div style={{ minWidth: 0 }}>
                      <div
                        style={{
                          fontSize: 14,
                          fontWeight: 700,
                          color: "#0f172a",
                          overflow: "hidden",
                          textOverflow: "ellipsis",
                          whiteSpace: "nowrap",
                        }}
                      >
                        {t.title}
                      </div>
                      <div
                        style={{
                          fontSize: 12,
                          color: "#475569",
                          marginTop: 6,
                          display: "-webkit-box",
                          WebkitLineClamp: 2,
                          WebkitBoxOrient: "vertical",
                          overflow: "hidden",
                        }}
                      >
                        {t.content}
                      </div>
                    </div>

                    <button
                      onClick={() => removeById(t.id)}
                      aria-label="Close notification"
                      style={{
                        background: "transparent",
                        border: "none",
                        fontSize: 18,
                        color: "#64748b",
                        cursor: "pointer",
                      }}
                    >
                      ×
                    </button>
                  </div>

                  <div
                    style={{
                      marginTop: 10,
                      height: 6,
                      borderRadius: 6,
                      overflow: "hidden",
                      background: "rgba(15,23,42,0.05)",
                    }}
                  >
                    <div
                      style={{
                        height: "100%",
                        animation: `progress ${ttl}s linear forwards`,
                      }}
                      className={`${cfg.gradient}`}
                    />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </>
  );
}
