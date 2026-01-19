// src/pages/coach/MeetingPage.jsx
import React, { useEffect, useRef, useState } from "react";
import AgoraRTC from "agora-rtc-sdk-ng";
import { useLocation, useParams, useNavigate } from "react-router-dom";
import api from "@/api/appointments"; // wrapper that returns unwrapped data
import { uploadUnsigned } from "@/services/uploadService";
import {
  Loader2,
  Video,
  Mic,
  MicOff,
  VideoOff,
  Phone,
  Timer,
  User,
  Maximize2,
} from "lucide-react";
import styles from "../../styles/MeetingPage.module.css";

export default function MeetingPage() {
  const { appointmentId: paramId } = useParams();
  const location = useLocation();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [tokenData, setTokenData] = useState(location.state?.tokenData || null);
  const [appointmentData, setAppointmentData] = useState(
    location.state?.appointment || null
  );
  const [error, setError] = useState(null);

  const clientRef = useRef(null);
  const localTrackRefs = useRef({ videoTrack: null, audioTrack: null });
  const localDivRef = useRef(null);
  const remoteDivRef = useRef(null); // ✅ Ref cho remote container
  const REMOTE_MOUNT_ID = "remote-mount";
  const localVideoMountingRef = useRef(false); // ✅ Guard để tránh mount nhiều lần
  const remoteVideoMountingRef = useRef(new Map()); // ✅ Guard cho remote videos: uid -> boolean

  // state of remote users: map uid -> { uid, hasVideo, hasAudio, name, isLocal }
  const [remoteUsers, setRemoteUsers] = useState({});
  const timerRef = useRef(null);
  const intervalRef = useRef(null);
  const joinTimeRef = useRef(null);

  const joiningRef = useRef(false); // <-- guard to prevent duplicate join attempts

  // UI states
  const [micOn, setMicOn] = useState(true);
  const [camOn, setCamOn] = useState(true);
  const [elapsedMs, setElapsedMs] = useState(0);
  const [timeLeftMs, setTimeLeftMs] = useState(null);

  // Snapshot states
  const [snapshots, setSnapshots] = useState([]);
  const snapshotTimersRef = useRef([]);
  const hasStartedSnapshotsRef = useRef(false);

  const msUntilExpire = (expiresAt) => {
    if (!expiresAt) return null;
    const now = Date.now();
    if (typeof expiresAt === "number") {
      const t = expiresAt > 1e12 ? expiresAt : expiresAt * 1000;
      return Math.max(0, t - now);
    }
    const t = Date.parse(expiresAt);
    if (isNaN(t)) return null;
    return Math.max(0, t - now);
  };

  // ---------- timer helpers (moved outside useEffect so retry/cleanup can use them) ----------
  const startClock = (expiresAt) => {
    joinTimeRef.current = Date.now();
    setElapsedMs(0);
    const update = () => {
      setElapsedMs(Date.now() - (joinTimeRef.current || Date.now()));
      setTimeLeftMs(msUntilExpire(expiresAt));
    };
    update();
    if (intervalRef.current) clearInterval(intervalRef.current);
    intervalRef.current = setInterval(update, 1000);
  };

  const stopClock = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
    setElapsedMs(0);
    setTimeLeftMs(null);
  };

  // ---------- Remote video mounting helper ----------

  // Helper để mount remote video vào container của React (không tạo container thủ công)
  const mountRemoteVideo = async (remoteVideoTrack, userUid) => {
    if (!remoteVideoTrack) {
      console.warn("[Agora] mountRemoteVideo: no track provided");
      return;
    }
    
    // ✅ FIX: Guard để tránh mount nhiều lần cho cùng một remote user
    const uid = userUid || 'unknown';
    if (remoteVideoMountingRef.current.get(uid)) {
      console.debug(`[Agora] Remote video mount for uid ${uid} already in progress, skipping...`);
      return;
    }

    remoteVideoMountingRef.current.set(uid, true);

    try {
      const container =
        remoteDivRef.current || document.getElementById(REMOTE_MOUNT_ID);
      if (!container) {
        console.warn("[Agora] Remote container not found, retrying in 500ms...");
        // Retry sau 500ms nếu container chưa ready
        setTimeout(() => {
          remoteVideoMountingRef.current.set(uid, false);
          mountRemoteVideo(remoteVideoTrack, userUid);
        }, 500);
        return;
      }

      // ✅ FIX: Xóa bất kỳ local video nào đang ở remote container
      const localVideosInRemote = container.querySelectorAll("video[data-agora-local]");
      localVideosInRemote.forEach((v) => {
        console.warn("[Agora] Removing misplaced local video from remote container");
        v.remove();
      });

      // ✅ FIX: Đảm bảo remote track không đang play ở local container
      const localContainer = localDivRef.current || document.getElementById("local-mount");
      if (localContainer) {
        const remoteVideosInLocal = localContainer.querySelectorAll("video[data-agora-remote]");
        remoteVideosInLocal.forEach((v) => {
          console.warn("[Agora] Removing misplaced remote video from local container");
          v.remove();
        });
      }

      // ✅ FIX: Cleanup duplicate remote video elements (chỉ giữ lại 1)
      const existingRemoteVideos = container.querySelectorAll("video[data-agora-remote]");
      if (existingRemoteVideos.length > 1) {
        console.warn(`[Agora] Found ${existingRemoteVideos.length} remote video elements, cleaning up duplicates...`);
        // Giữ lại element đầu tiên, xóa các element còn lại
        for (let j = 1; j < existingRemoteVideos.length; j++) {
          try {
            const oldTrack = existingRemoteVideos[j]._agoraTrackRef;
            if (oldTrack && oldTrack !== remoteVideoTrack) {
              await oldTrack.stop().catch(() => {});
            }
          } catch {}
          existingRemoteVideos[j].remove();
        }
      }

      // create/reuse video element
      let videoEl = container.querySelector("video[data-agora-remote]");
      
      // ✅ FIX: Nếu video element đã tồn tại và đang play đúng track, không cần mount lại
      if (videoEl && videoEl._agoraTrackRef === remoteVideoTrack) {
        if (videoEl.videoWidth > 0 && remoteVideoTrack.isPlaying) {
          console.debug("[Agora] Remote video already playing in correct container with same track");
          remoteVideoMountingRef.current.set(uid, false);
          return;
        }
        // Nếu track đã thay đổi, cleanup element cũ
        if (videoEl._agoraTrackRef !== remoteVideoTrack) {
          try {
            const oldTrack = videoEl._agoraTrackRef;
            if (oldTrack && oldTrack !== remoteVideoTrack) {
              await oldTrack.stop().catch(() => {});
            }
          } catch {}
          videoEl.srcObject = null;
          videoEl.load();
        }
      }

      if (!videoEl) {
        videoEl = document.createElement("video");
        videoEl.setAttribute("data-agora-remote", "1");
        videoEl.setAttribute("data-user-uid", String(uid));
        videoEl.autoplay = true;
        videoEl.playsInline = true;
        videoEl.muted = false;
        videoEl.style.position = "absolute";
        videoEl.style.top = "0";
        videoEl.style.left = "0";
        videoEl.style.width = "100%";
        videoEl.style.height = "100%";
        videoEl.style.objectFit = "cover";
        videoEl.style.backgroundColor = "#000";
        // Lưu track reference để có thể cleanup sau
        videoEl._agoraTrackRef = remoteVideoTrack;
        const cs = getComputedStyle(container);
        if (cs.position === "static") container.style.position = "relative";
        // remove placeholders (keep if you want)
        Array.from(container.children).forEach((ch) => {
          if (ch.tagName !== "VIDEO") ch.remove();
        });
        container.appendChild(videoEl);
      } else {
        // Update track reference nếu element đã tồn tại
        videoEl._agoraTrackRef = remoteVideoTrack;
      }

      // ✅ FIX: Đảm bảo track chỉ play một lần và retry nếu cần
      if (!remoteVideoTrack.isPlaying) {
        try {
          await remoteVideoTrack.play(videoEl);
          console.debug("[Agora] Remote video play successful");
        } catch (playErr) {
          console.warn("[Agora] Remote video play failed, retrying...", playErr);
          // Retry sau 500ms
          setTimeout(async () => {
            try {
              if (!remoteVideoTrack.isPlaying && videoEl) {
                await remoteVideoTrack.play(videoEl);
                console.debug("[Agora] Remote video play retry successful");
              }
            } catch (retryErr) {
              console.error("[Agora] Remote video play retry failed", retryErr);
            }
          }, 500);
        }
      } else {
        console.debug("[Agora] Remote video track already playing");
      }
    } catch (err) {
      console.error("[Agora] mountRemoteVideo failed", err);
      // Retry sau 1s nếu có lỗi
      setTimeout(() => {
        remoteVideoMountingRef.current.set(uid, false);
        mountRemoteVideo(remoteVideoTrack, userUid);
      }, 1000);
    } finally {
      // Chỉ release guard sau khi đã hoàn thành hoặc retry
      setTimeout(() => {
        remoteVideoMountingRef.current.set(uid, false);
      }, 100);
    }
  };

  // ---------- Local video mounting helper ----------

  // Helper để mount local video với retry mechanism
  const mountLocalVideo = async (track, containerRef, retries = 10) => {
    // ✅ FIX: Guard để tránh mount nhiều lần đồng thời
    if (localVideoMountingRef.current) {
      console.debug("[Agora] Local video mount already in progress, skipping...");
      return;
    }

    localVideoMountingRef.current = true;

    try {
      for (let i = 0; i < retries; i++) {
        // Đợi container mount (quan trọng khi deploy - React có thể render chậm hơn)
        if (!containerRef.current) {
          console.debug(
            `[Agora] Waiting for localDivRef to mount (attempt ${
              i + 1
            }/${retries})`
          );
          await new Promise((r) => setTimeout(r, 200));
          continue;
        }

        try {
          // ✅ FIX: Xóa bất kỳ local video nào đang ở sai chỗ (remote container)
          const remoteContainer = remoteDivRef.current || document.getElementById(REMOTE_MOUNT_ID);
          if (remoteContainer) {
            const misplacedLocalVideos = remoteContainer.querySelectorAll("video[data-agora-local]");
            misplacedLocalVideos.forEach((v) => {
              console.warn("[Agora] Removing misplaced local video from remote container");
              v.remove();
            });
          }

          // ✅ FIX: Cleanup tất cả video elements cũ trong local container trước
          const existingVideos = containerRef.current.querySelectorAll("video[data-agora-local]");
          if (existingVideos.length > 1) {
            console.warn(`[Agora] Found ${existingVideos.length} local video elements, cleaning up duplicates...`);
            // Giữ lại element đầu tiên, xóa các element còn lại
            for (let j = 1; j < existingVideos.length; j++) {
              try {
                const oldTrack = existingVideos[j]._agoraTrackRef;
                if (oldTrack) {
                  await oldTrack.stop().catch(() => {});
                }
              } catch {}
              existingVideos[j].remove();
            }
          }

          // ✅ FIX: Kiểm tra xem track đã được play chưa
          const existingVideo = containerRef.current.querySelector("video[data-agora-local]");
          if (existingVideo && existingVideo.videoWidth > 0) {
            // Kiểm tra xem track có đang play trong element này không
            const isPlaying = existingVideo._agoraTrackRef === track || 
                             (existingVideo.srcObject && existingVideo.srcObject.getTracks().length > 0);
            if (isPlaying) {
              console.debug("[Agora] Local video already playing in correct container");
              return; // Đã mount rồi, không cần mount lại
            }
          }

          // ✅ FIX: Stop track trước khi mount lại (nếu đã được mount ở đâu đó)
          // Chỉ stop nếu track đang playing
          try {
            if (track.isPlaying) {
              await track.stop();
              // Đợi một chút để track cleanup xong
              await new Promise((r) => setTimeout(r, 100));
            }
          } catch {
            // Ignore nếu track chưa được play hoặc đã stop
          }

          const createOrGetLocalVideo = () => {
            // try reuse - chỉ tìm trong local container
            let videoEl = containerRef.current.querySelector(
              "video[data-agora-local]"
            );
            if (videoEl) {
              // Cleanup element cũ trước khi reuse
              videoEl.srcObject = null;
              videoEl.load(); // Reset video element
              return videoEl;
            }

            // create
            videoEl = document.createElement("video");
            videoEl.setAttribute("data-agora-local", "1");
            videoEl.autoplay = true;
            videoEl.playsInline = true;
            videoEl.muted = true; // necessary for autoplay
            videoEl.style.position = "absolute";
            videoEl.style.top = "0";
            videoEl.style.left = "0";
            videoEl.style.width = "100%";
            videoEl.style.height = "100%";
            videoEl.style.objectFit = "cover";
            // Lưu track reference để có thể cleanup sau
            videoEl._agoraTrackRef = track;

            // ensure container positioned
            const cs = getComputedStyle(containerRef.current);
            if (cs.position === "static")
              containerRef.current.style.position = "relative";

            // remove non-video placeholders
            Array.from(containerRef.current.children).forEach((ch) => {
              if (ch.tagName !== "VIDEO") ch.remove();
            });

            containerRef.current.appendChild(videoEl);
            return videoEl;
          };

          const videoEl = createOrGetLocalVideo();

          // Đợi video element ready trước khi play (fix timing issues)
          if (videoEl.readyState === 0) {
            await new Promise((resolve) => {
              videoEl.addEventListener("loadedmetadata", resolve, {
                once: true,
              });
              setTimeout(resolve, 1000); // Timeout sau 1s để không block quá lâu
            });
          }

          // ✅ FIX: Đảm bảo track chỉ play một lần
          if (!track.isPlaying) {
            await track.play(videoEl);
            console.debug("[Agora] Local video play -> using explicit element");
          } else {
            console.debug("[Agora] Local video track already playing, skipping play()");
          }

          // ✅ FIX: Verify video chỉ có trong local container
          setTimeout(() => {
            const localVideos = containerRef.current?.querySelectorAll(
              "video[data-agora-local]"
            );
            const remoteVideos = remoteContainer?.querySelectorAll(
              "video[data-agora-local]"
            );
            
            if (remoteVideos && remoteVideos.length > 0) {
              console.warn("[Agora] Found local video in remote container, removing...");
              remoteVideos.forEach((v) => v.remove());
            }

            const v = containerRef.current?.querySelector(
              "video[data-agora-local]"
            );
            if (v && v.videoWidth === 0) {
              console.warn("[Agora] Video width is 0, retrying enable...");
              track
                .setEnabled(false)
                .then(() => track.setEnabled(true))
                .catch(() => {});
            } else if (v && v.videoWidth > 0) {
              console.debug("[Agora] Local video mounted successfully:", {
                width: v.videoWidth,
                height: v.videoHeight,
                container: containerRef.current.id,
              });
            }
          }, 1500);

          return; // Success, exit retry loop
        } catch (err) {
          console.warn(
            `[Agora] Local video mount attempt ${i + 1}/${retries} failed:`,
            err
          );
          if (i < retries - 1) {
            // Retry sau 500ms
            await new Promise((r) => setTimeout(r, 500));
          } else {
            console.error("[Agora] All local video mount attempts failed");
            // Không throw error để meeting vẫn có thể tiếp tục (chỉ không có video)
          }
        }
      }
    } finally {
      localVideoMountingRef.current = false;
    }
  };

  // ---------- Snapshot helpers ----------

  // Parse appointment start time
  const parseLocalDateTime = (dateStr, timeStr) => {
    try {
      const [y, m, d] = (dateStr || "").split("-").map((n) => parseInt(n, 10));
      const [hh, mm] = (timeStr || "00:00")
        .split(":")
        .map((n) => parseInt(n, 10));
      if (!y || !m || !d || isNaN(hh) || isNaN(mm)) return null;
      return new Date(y, m - 1, d, hh, mm, 0, 0);
    } catch {
      return null;
    }
  };

  // Backup snapshot vào localStorage
  const saveSnapshotToLocalStorage = (appointmentId, url) => {
    try {
      const key = `snapshots_${appointmentId}`;
      const existing = JSON.parse(localStorage.getItem(key) || "[]");
      existing.push({ url, timestamp: Date.now() });
      localStorage.setItem(key, JSON.stringify(existing));
    } catch (e) {
      console.error("Save to localStorage failed:", e);
    }
  };

  // Retry snapshots từ localStorage
  const retryFailedSnapshots = async (appointmentId) => {
    try {
      const key = `snapshots_${appointmentId}`;
      const stored = JSON.parse(localStorage.getItem(key) || "[]");

      if (stored.length > 0) {
        const urls = stored.map((s) => s.url);
        await api.saveAppointmentSnapshots(appointmentId, urls);
        localStorage.removeItem(key);
        console.log("Retried and saved snapshots from localStorage");
      }
    } catch (e) {
      console.error("Retry snapshots failed:", e);
    }
  };

  // Capture snapshot từ cả 2 video (local + remote) - toàn cảnh
  const captureSnapshot = async () => {
    try {
      const localContainer = document.getElementById("local-mount");
      const remoteContainer = document.getElementById(REMOTE_MOUNT_ID);
      const localVideo = localContainer?.querySelector("video");
      const remoteVideo = remoteContainer?.querySelector("video");

      // Cần ít nhất 1 video để chụp
      if (!localVideo && !remoteVideo) {
        console.warn("No video available for snapshot");
        return null;
      }

      // Tạo canvas với kích thước lớn để chứa cả 2 video
      const canvas = document.createElement("canvas");
      const ctx = canvas.getContext("2d");

      // Kích thước mỗi video (giả sử 640x480 hoặc lấy từ video thực tế)
      const videoWidth = 640;
      const videoHeight = 480;
      const padding = 10;

      // Canvas layout: 2 video cạnh nhau hoặc chồng lên nhau
      if (localVideo && remoteVideo) {
        // Cả 2 video: đặt cạnh nhau
        canvas.width = videoWidth * 2 + padding * 3;
        canvas.height = videoHeight + padding * 2;

        // Background
        ctx.fillStyle = "#000000";
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Vẽ local video (bên trái)
        if (localVideo.videoWidth > 0 && localVideo.readyState >= 2) {
          try {
            ctx.drawImage(
              localVideo,
              padding,
              padding,
              videoWidth,
              videoHeight
            );
            // Label
            ctx.fillStyle = "#FFFFFF";
            ctx.font = "16px Arial";
            ctx.fillText("Coach", padding + 10, padding + 30);
          } catch (e) {
            console.warn("Failed to draw local video:", e);
          }
        }

        // Vẽ remote video (bên phải)
        if (remoteVideo.videoWidth > 0 && remoteVideo.readyState >= 2) {
          try {
            ctx.drawImage(
              remoteVideo,
              videoWidth + padding * 2,
              padding,
              videoWidth,
              videoHeight
            );
            // Label
            ctx.fillStyle = "#FFFFFF";
            ctx.font = "16px Arial";
            ctx.fillText("Member", videoWidth + padding * 2 + 10, padding + 30);
          } catch (e) {
            console.warn("Failed to draw remote video:", e);
          }
        }
      } else if (localVideo) {
        // Chỉ có local video
        canvas.width = videoWidth + padding * 2;
        canvas.height = videoHeight + padding * 2;
        ctx.fillStyle = "#000000";
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        if (localVideo.videoWidth > 0 && localVideo.readyState >= 2) {
          ctx.drawImage(localVideo, padding, padding, videoWidth, videoHeight);
          ctx.fillStyle = "#FFFFFF";
          ctx.font = "16px Arial";
          ctx.fillText("Coach", padding + 10, padding + 30);
        }
      } else if (remoteVideo) {
        // Chỉ có remote video
        canvas.width = videoWidth + padding * 2;
        canvas.height = videoHeight + padding * 2;
        ctx.fillStyle = "#000000";
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        if (remoteVideo.videoWidth > 0 && remoteVideo.readyState >= 2) {
          ctx.drawImage(remoteVideo, padding, padding, videoWidth, videoHeight);
          ctx.fillStyle = "#FFFFFF";
          ctx.font = "16px Arial";
          ctx.fillText("Member", padding + 10, padding + 30);
        }
      }

      return new Promise((resolve) => {
        canvas.toBlob((blob) => resolve(blob), "image/jpeg", 0.9);
      });
    } catch (error) {
      console.error("Capture snapshot error:", error);
      return null;
    }
  };

  // Upload snapshot lên Cloudinary
  const uploadSnapshot = async (blob, appointmentId) => {
    if (!blob) return null;

    try {
      const file = new File([blob], `snapshot-${Date.now()}.jpg`, {
        type: "image/jpeg",
      });

      const result = await uploadUnsigned(file, {
        folder: `appointments/${appointmentId}/snapshots`,
      });

      return result.secure_url;
    } catch (error) {
      console.error("Upload snapshot error:", error);
      return null;
    }
  };

  // Chụp và upload snapshot - gửi về backend ngay lập tức
  const takeAndUploadSnapshot = async () => {
    if (!paramId) return null;

    const blob = await captureSnapshot();
    if (!blob) return null;

    try {
      // Upload lên Cloudinary
      const url = await uploadSnapshot(blob, paramId);
      if (!url) return null;

      // Gửi về backend ngay lập tức (real-time sync)
      try {
        await api.saveAppointmentSnapshots(paramId, [url]);
        console.log("Snapshot saved to backend:", url);
      } catch (error) {
        console.error("Save snapshot to backend failed:", error);
        // Backup vào localStorage nếu gửi thất bại
        saveSnapshotToLocalStorage(paramId, url);
      }

      setSnapshots((prev) => [...prev, url]);
      return url;
    } catch (error) {
      console.error("Upload snapshot error:", error);
      return null;
    }
  };

  // Bắt đầu auto snapshots: chụp 3 ảnh tại 5', 10', 15' tính từ START TIME của appointment slot
  const startAutoSnapshots = () => {
    if (hasStartedSnapshotsRef.current) return;
    if (!paramId) return;

    // Lấy appointment data từ location.state hoặc appointmentData state
    const appointment = appointmentData || location.state?.appointment;

    // Nếu không có appointment data, fetch từ API
    if (!appointment) {
      // Fallback: tính từ lúc join (code cũ)
      console.warn("No appointment data, using join time as fallback");
      hasStartedSnapshotsRef.current = true;
      const snapshotTimes = [2 * 60 * 1000, 4 * 60 * 1000, 6 * 60 * 1000];
      const checkRemoteVideo = setInterval(() => {
        const remoteContainer = document.getElementById(REMOTE_MOUNT_ID);
        const videoElement = remoteContainer?.querySelector("video");
        if (
          videoElement &&
          videoElement.videoWidth > 0 &&
          videoElement.readyState >= 2
        ) {
          clearInterval(checkRemoteVideo);
          snapshotTimes.forEach((delay, index) => {
            const timer = setTimeout(async () => {
              console.log(
                `Auto snapshot ${index + 1}/3 at ${
                  delay / 60000
                } minutes from join`
              );
              await takeAndUploadSnapshot();
            }, delay);
            snapshotTimersRef.current.push(timer);
          });
        }
      }, 2000);
      setTimeout(() => clearInterval(checkRemoteVideo), 30000);
      return;
    }

    // Tính thời gian bắt đầu slot từ appointment
    const dateStr = appointment.date || appointment.appointmentDate;
    const timeStr = appointment.startTime || appointment.time;

    if (!dateStr || !timeStr) {
      console.warn(
        "Missing appointment date/time, using join time as fallback"
      );
      // Fallback như trên
      return;
    }

    const slotStartTime = parseLocalDateTime(dateStr, timeStr);
    if (!slotStartTime) {
      console.warn(
        "Invalid appointment start time, using join time as fallback"
      );
      return;
    }

    hasStartedSnapshotsRef.current = true;

    // Snapshot tại 2', 4', 6' tính từ START TIME của slot
    const snapshotOffsets = [
      2 * 60 * 1000, // 2 phút từ startTime
      4 * 60 * 1000, // 4 phút từ startTime
      6 * 60 * 1000, // 6 phút từ startTime
    ];

    // Đợi video ready (local hoặc remote)
    const checkVideo = setInterval(() => {
      const localContainer = document.getElementById("local-mount");
      const remoteContainer = document.getElementById(REMOTE_MOUNT_ID);
      const localVideo = localContainer?.querySelector("video");
      const remoteVideo = remoteContainer?.querySelector("video");

      // Cần ít nhất 1 video
      const hasVideo =
        (localVideo &&
          localVideo.videoWidth > 0 &&
          localVideo.readyState >= 2) ||
        (remoteVideo &&
          remoteVideo.videoWidth > 0 &&
          remoteVideo.readyState >= 2);

      if (hasVideo) {
        clearInterval(checkVideo);

        snapshotOffsets.forEach((offset, index) => {
          const snapshotTime = slotStartTime.getTime() + offset;
          const now = Date.now();
          const delay = snapshotTime - now;

          // Nếu thời gian đã qua rồi, skip
          if (delay < 0) {
            console.log(
              `Snapshot ${index + 1} time already passed (${
                Math.abs(delay) / 60000
              } minutes ago), skipping`
            );
            return;
          }

          const timer = setTimeout(async () => {
            console.log(
              `Auto snapshot ${index + 1}/3 at ${
                offset / 60000
              } minutes from slot start (${new Date(
                snapshotTime
              ).toLocaleTimeString()})`
            );
            await takeAndUploadSnapshot();
          }, delay);

          snapshotTimersRef.current.push(timer);
        });
      }
    }, 2000);

    // Cleanup nếu không có video sau 30s
    setTimeout(() => {
      clearInterval(checkVideo);
    }, 30000);
  };

  // Dừng auto snapshots
  const stopAutoSnapshots = () => {
    snapshotTimersRef.current.forEach((timer) => clearTimeout(timer));
    snapshotTimersRef.current = [];
    hasStartedSnapshotsRef.current = false;
  };

  // ---------- cleanup (define before useEffect to allow calling inside) ----------
  const cleanupAndLeave = async () => {
    try {
      // QUAN TRỌNG: Stop và close tracks TRƯỚC khi cleanup DOM
      // Điều này đảm bảo Agora SDK không còn manipulate DOM nữa
      const client = clientRef.current;
      const { audioTrack, videoTrack } = localTrackRefs.current || {};

      // Stop và close tracks trước
      if (videoTrack) {
        try {
          await videoTrack.stop();
        } catch {
          // Ignore stop errors
        }
        try {
          videoTrack.close();
        } catch {
          // Ignore close errors
        }
      }
      if (audioTrack) {
        try {
          await audioTrack.stop();
        } catch {
          // Ignore stop errors
        }
        try {
          audioTrack.close();
        } catch {
          // Ignore close errors
        }
      }

      // Leave client - điều này sẽ cleanup remote tracks
      if (client) {
        try {
          await client.leave();
          console.debug("[Agora] client.leave() success");
          // Đợi một chút để Agora SDK cleanup xong
          await new Promise((r) => setTimeout(r, 100));
        } catch (e) {
          console.warn("[Agora] client.leave() failed", e);
        }
      }

      // Cleanup timers
      if (timerRef.current) {
        clearTimeout(timerRef.current);
        timerRef.current = null;
      }
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    } catch (e) {
      console.warn("cleanup error", e);
    } finally {
      // Set refs về null sau khi đã cleanup tracks
      clientRef.current = null;
      localTrackRefs.current = { audioTrack: null, videoTrack: null };

      // KHÔNG cleanup DOM elements - để Agora SDK tự cleanup
      // Khi tracks đã được stop và close, Agora SDK sẽ tự động cleanup DOM
      // Nếu chúng ta cố cleanup DOM, sẽ gây conflict với React unmount

      setRemoteUsers({});
      stopClock();
      stopAutoSnapshots();
    }
  };

  useEffect(() => {
    let mounted = true;

    const loadAndStart = async () => {
      setLoading(true);
      try {
        // ✅ OPTION 2: Bỏ test stream, để Agora SDK tự handle permission
        // (Nhưng sẽ mất khả năng show error message sớm)

        // Check HTTPS requirement for production
        const isSecureContext =
          window.location.protocol === "https:" ||
          window.location.hostname === "localhost" ||
          window.location.hostname === "127.0.0.1";

        if (!isSecureContext) {
          console.warn("[Meeting] Camera access requires HTTPS in production!");
          // Không throw error ngay, vì có thể user vẫn muốn thử
          // Nhưng sẽ log warning
        }

        // Bỏ phần test stream, để Agora SDK tự handle permission
        // Nếu permission bị deny, Agora SDK sẽ throw error và được catch ở line 888

        // 1) get token data if missing
        let td = tokenData;
        if (!td) {
          const id =
            paramId ||
            (location.state &&
              location.state.appointment &&
              location.state.appointment.id);
          if (!id) throw new Error("Missing appointment id / tokenData");
          const resp = await api.requestJoinToken(id);
          td = resp;
          if (!mounted) return;
          setTokenData(td);
        }

        const channel = td.channel;
        const token = td.token;
        const uid = td.uid ?? 0;
        const appId = import.meta.env.VITE_AGORA_APPID || td.appId;
        if (!appId) throw new Error("Missing Agora appId.");
        if (!channel) throw new Error("Missing channel in token data.");

        // --- PATCH: prevent concurrent joins and implement retry on OPERATION_ABORTED ---
        if (joiningRef.current) {
          console.warn(
            "[Meeting] join already in progress — skipping duplicate call"
          );
          return;
        }
        joiningRef.current = true;

        // ensure we don't leave an old client hanging
        // Đợi cleanup hoàn toàn trước khi tạo client mới
        if (clientRef.current) {
          try {
            await cleanupAndLeave();
            // Đợi một chút để đảm bảo cleanup hoàn tất
            await new Promise((r) => setTimeout(r, 200));
          } catch (e) {
            console.warn("[Meeting] cleanup before new join failed", e);
            // Vẫn tiếp tục tạo client mới ngay cả khi cleanup fail
          }
          // Đảm bảo clientRef đã được clear
          if (clientRef.current) {
            console.warn("[Meeting] Force clearing old client ref");
            clientRef.current = null;
          }
        }

        // log token summary for debug (avoid printing full token in prod)
        console.debug("[Meeting] joining", {
          appId,
          channel,
          uid,
          tokenLen: token ? token.length : 0,
          expiresAt: td.expiresAt,
        });

        // helper: retry join once on cancel/operation aborted
        const tryJoinWithRetry = async (
          client,
          appId_,
          channel_,
          token_,
          uid_,
          attempts = 1
        ) => {
          try {
            await client.join(appId_, channel_, token_ || null, uid_);
            return;
          } catch (err) {
            const msg = String(err && err.message ? err.message : err);

            // Nếu client đã bị leave (thường xảy ra khi reload)
            // Return null để signal cần tạo client mới
            if (
              msg.includes("already left") ||
              msg.includes("INVALID_OPERATION") ||
              msg.includes("Client already left")
            ) {
              console.warn(
                "[Meeting] Client already left, will create new client"
              );
              return null; // Signal để tạo client mới
            }

            // transient: SDK cancelled previous join attempt -> retry
            if (
              attempts > 0 &&
              (msg.includes("OPERATION_ABORTED") ||
                msg.includes("cancel token"))
            ) {
              console.warn(
                "[Meeting] join failed transiently, retrying...",
                msg
              );
              await new Promise((r) => setTimeout(r, 500));
              return tryJoinWithRetry(
                client,
                appId_,
                channel_,
                token_,
                uid_,
                attempts - 1
              );
            }
            throw err;
          }
        };

        // create client and register handlers
        // Đảm bảo clientRef.current đã được clear trước khi tạo mới
        if (clientRef.current) {
          console.warn("[Meeting] Old client still exists, clearing it");
          try {
            clientRef.current.leave().catch(() => {
              // Ignore
            });
          } catch {
            // Ignore
          }
          clientRef.current = null;
        }

        const client = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
        clientRef.current = client;

        client.on("user-published", async (user, mediaType) => {
          console.debug("[Agora] user-published", user.uid, mediaType);
          try {
            await client.subscribe(user, mediaType);
            console.debug(`[Agora] Subscribed to user ${user.uid} ${mediaType}`);
          } catch (err) {
            console.error("[Agora] subscribe error", err);
            // Không return ngay, vẫn cập nhật state để UI biết user đã vào
            // Nhưng không mount media nếu subscribe fail
            if (err.message?.includes("already subscribed")) {
              console.debug("[Agora] Already subscribed, continuing...");
            } else {
              return;
            }
          }

          setRemoteUsers((prev) => ({
            ...prev,
            [user.uid]: {
              uid: user.uid,
              hasVideo: !!user.videoTrack,
              hasAudio: !!user.audioTrack,
              name: user?.userInfo?.name || `User ${user.uid}`,
              isLocal: false,
            },
          }));

          // ✅ FIX: Dùng helper function thay vì manual DOM creation
          if (mediaType === "video") {
            const remoteVideoTrack = user.videoTrack;
            if (remoteVideoTrack) {
              console.debug(`[Agora] Mounting remote video for user ${user.uid}`);
              // Retry mount nếu fail lần đầu
              try {
                await mountRemoteVideo(remoteVideoTrack, user.uid);
              } catch (mountErr) {
                console.warn("[Agora] Initial mount failed, will retry", mountErr);
                // Retry sau 1s
                setTimeout(async () => {
                  try {
                    await mountRemoteVideo(remoteVideoTrack, user.uid);
                  } catch (retryErr) {
                    console.error("[Agora] Retry mount also failed", retryErr);
                  }
                }, 1000);
              }
            } else {
              console.warn(`[Agora] User ${user.uid} published video but no videoTrack found`);
            }
          }

          if (mediaType === "audio") {
            const remoteAudioTrack = user.audioTrack;
            if (remoteAudioTrack) {
              try {
                await remoteAudioTrack.play();
                console.debug(`[Agora] Remote audio playing for user ${user.uid}`);
              } catch (e) {
                console.warn("[Agora] remote audio play failed", e);
                // Retry sau 500ms
                setTimeout(async () => {
                  try {
                    await remoteAudioTrack.play();
                  } catch (retryErr) {
                    console.error("[Agora] Remote audio retry failed", retryErr);
                  }
                }, 500);
              }
            }
          }
        });

        client.on("user-unpublished", (user, type) => {
          console.debug("[Agora] user-unpublished", user.uid, type);
          setRemoteUsers((prev) => {
            const copy = { ...prev };
            if (copy[user.uid]) {
              if (type === "video") copy[user.uid].hasVideo = false;
              if (type === "audio") copy[user.uid].hasAudio = false;
            }
            return copy;
          });
          // Không cleanup DOM - để Agora SDK tự xử lý khi track được stop
          // Cleanup DOM sẽ gây conflict với React unmount
        });

        client.on("user-left", (user) => {
          console.debug("[Agora] user-left", user.uid);
          setRemoteUsers((prev) => {
            const copy = { ...prev };
            delete copy[user.uid];
            return copy;
          });
        });

        client.on("connection-state-change", (cur, rev) => {
          console.debug("[Agora] connection-state-change", cur, rev);
        });

        client.on("token-privilege-will-expire", () => {
          console.warn(
            "[Agora] token will expire soon - request new token from server."
          );
        });

        // JOIN with retry helper
        let joinResult = await tryJoinWithRetry(
          client,
          appId,
          channel,
          token,
          uid,
          1
        );

        // Nếu client đã bị leave (thường xảy ra khi reload), tạo client mới
        if (joinResult === null) {
          console.log(
            "[Meeting] Client was left, creating new client and retrying join"
          );

          // Cleanup client cũ hoàn toàn
          try {
            client.leave().catch(() => {});
          } catch {
            // Ignore
          }
          clientRef.current = null;

          // Đợi một chút để đảm bảo cleanup
          await new Promise((r) => setTimeout(r, 200));

          // Tạo client mới
          const newClient = AgoraRTC.createClient({
            mode: "rtc",
            codec: "vp8",
          });
          clientRef.current = newClient;

          // Register lại tất cả handlers cho client mới
          newClient.on("user-published", async (user, mediaType) => {
            console.debug("[Agora] user-published", user.uid, mediaType);
            try {
              await newClient.subscribe(user, mediaType);
              console.debug(`[Agora] Subscribed to user ${user.uid} ${mediaType}`);
            } catch (err) {
              console.error("[Agora] subscribe error", err);
              if (err.message?.includes("already subscribed")) {
                console.debug("[Agora] Already subscribed, continuing...");
              } else {
                return;
              }
            }

            setRemoteUsers((prev) => ({
              ...prev,
              [user.uid]: {
                uid: user.uid,
                hasVideo: !!user.videoTrack,
                hasAudio: !!user.audioTrack,
                name: user?.userInfo?.name || `User ${user.uid}`,
                isLocal: false,
              },
            }));

            // ✅ FIX: Dùng helper function thay vì manual DOM creation
            if (mediaType === "video") {
              const remoteVideoTrack = user.videoTrack;
              if (remoteVideoTrack) {
                console.debug(`[Agora] Mounting remote video for user ${user.uid}`);
                try {
                  await mountRemoteVideo(remoteVideoTrack, user.uid);
                } catch (mountErr) {
                  console.warn("[Agora] Initial mount failed, will retry", mountErr);
                  setTimeout(async () => {
                    try {
                      await mountRemoteVideo(remoteVideoTrack, user.uid);
                    } catch (retryErr) {
                      console.error("[Agora] Retry mount also failed", retryErr);
                    }
                  }, 1000);
                }
              }
            }

            if (mediaType === "audio") {
              const remoteAudioTrack = user.audioTrack;
              if (remoteAudioTrack) {
                try {
                  await remoteAudioTrack.play();
                  console.debug(`[Agora] Remote audio playing for user ${user.uid}`);
                } catch (e) {
                  console.warn("[Agora] remote audio play failed", e);
                  setTimeout(async () => {
                    try {
                      await remoteAudioTrack.play();
                    } catch (retryErr) {
                      console.error("[Agora] Remote audio retry failed", retryErr);
                    }
                  }, 500);
                }
              }
            }
          });

          newClient.on("user-unpublished", (user, type) => {
            console.debug("[Agora] user-unpublished", user.uid, type);
            setRemoteUsers((prev) => {
              const copy = { ...prev };
              if (copy[user.uid]) {
                if (type === "video") copy[user.uid].hasVideo = false;
                if (type === "audio") copy[user.uid].hasAudio = false;
              }
              return copy;
            });
          });

          newClient.on("user-left", (user) => {
            console.debug("[Agora] user-left", user.uid);
            setRemoteUsers((prev) => {
              const copy = { ...prev };
              delete copy[user.uid];
              return copy;
            });
          });

          newClient.on("connection-state-change", (cur, rev) => {
            console.debug("[Agora] connection-state-change", cur, rev);
          });

          newClient.on("token-privilege-will-expire", () => {
            console.warn(
              "[Agora] token will expire soon - request new token from server."
            );
          });

          // Join với client mới
          await newClient.join(appId, channel, token || null, uid);

          // Từ đây, dùng clientRef.current thay vì client variable
          // Vì client là const, không thể reassign
          // newClient đã được set vào clientRef.current ở trên
        }

        // create local tracks
        let microphoneTrack, cameraTrack;
        try {
          [microphoneTrack, cameraTrack] = await Promise.all([
            AgoraRTC.createMicrophoneAudioTrack(),
            AgoraRTC.createCameraVideoTrack({
              encoderConfig: "720p",
              facingMode: "user", // Front camera
            }),
          ]);

          // Log track info for debugging
          if (cameraTrack) {
            console.log("[Agora] Camera track created:", {
              trackId: cameraTrack.getTrackId(),
              enabled: cameraTrack.isPlaying,
              muted: cameraTrack.isMuted,
            });
          }
        } catch (trackErr) {
          console.error("[Agora] Failed to create tracks:", trackErr);
          console.error("Error details:", {
            name: trackErr.name,
            message: trackErr.message,
            stack: trackErr.stack,
          });
          throw new Error(
            `Failed to access camera/microphone: ${trackErr.message}`
          );
        }

        // QUAN TRỌNG: Enable track ngay sau khi tạo
        if (cameraTrack) {
          try {
            await cameraTrack.setEnabled(true);
            console.debug("[Agora] Camera track enabled");
          } catch (e) {
            console.warn("[Agora] Failed to enable camera track:", e);
          }
        }

        localTrackRefs.current = {
          audioTrack: microphoneTrack,
          videoTrack: cameraTrack,
        };

        // ✅ FIX: Không mount video ở đây nữa - sẽ mount sau khi DOM render (trong useEffect riêng)
        // Video sẽ được mount trong useEffect riêng sau khi loading = false và DOM ready

        // publish local - dùng clientRef.current để support cả client mới và cũ
        const currentClient = clientRef.current || client;
        try {
          await currentClient.publish([microphoneTrack, cameraTrack]);
          console.debug("[Agora] published local tracks");
        } catch (pubErr) {
          console.warn("[Agora] publish failed", pubErr);
        }

        // register local user in map (so UI shows "You" tile)
        // Dùng uid từ token data hoặc từ client
        const currentUid = currentClient.uid || uid;
        setRemoteUsers((prev) => ({
          ...prev,
          [currentUid]: {
            uid: currentUid,
            hasVideo: !!cameraTrack,
            hasAudio: !!microphoneTrack,
            name: "You",
            isLocal: true,
          },
        }));

        // start timers
        startClock(td.expiresAt);

        // auto-leave safety
        if (td.expiresAt) {
          const ms = msUntilExpire(td.expiresAt);
          if (ms > 0) {
            timerRef.current = setTimeout(() => {
              alert("Session expired");
              cleanupAndLeave();
              navigate(-1);
            }, ms + 500);
          }
        }

        // Lưu appointment data nếu có
        if (location.state?.appointment) {
          setAppointmentData(location.state.appointment);
        }

        // Retry snapshots từ localStorage khi mount
        if (paramId) {
          retryFailedSnapshots(paramId);
        }

        // Bắt đầu auto snapshots sau 5s (đợi video ready)
        setTimeout(() => {
          startAutoSnapshots();
        }, 5000);
      } catch (err) {
        console.error("Meeting init error", err);
        if (mounted) setError(err.message || String(err));
      } finally {
        joiningRef.current = false; // <-- release guard
        if (mounted) setLoading(false);
      }
    }; // end loadAndStart

    loadAndStart();

    return () => {
      mounted = false;
      stopClock();
      stopAutoSnapshots();
      // Cleanup khi component unmount (reload, navigate away)
      // QUAN TRỌNG: Phải cleanup tracks trước khi React unmount DOM
      const cleanup = async () => {
        try {
          await cleanupAndLeave();
        } catch (e) {
          console.warn(
            "[Meeting] Cleanup on unmount failed (safe to ignore):",
            e
          );
        }
      };
      // Chạy cleanup nhưng không block unmount
      cleanup();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ✅ FIX: Mount local video sau khi DOM đã render và loading = false
  useEffect(() => {
    if (loading) {
      return; // Đợi loading xong
    }

    let isMounted = true;
    let mountAttempted = false;

    // Hàm check và mount video
    const tryMountVideo = async () => {
      // Check xem video đã được mount chưa
      const existingVideo = localDivRef.current?.querySelector(
        "video[data-agora-local]"
      );
      if (existingVideo && existingVideo.videoWidth > 0) {
        console.debug("[Agora] Local video already mounted");
        return true; // Đã mount rồi
      }

      const cameraTrack = localTrackRefs.current?.videoTrack;
      if (!cameraTrack) {
        return false; // Chưa có track
      }

      if (!localDivRef.current) {
        return false; // Container chưa ready
      }

      // Mount video với retry mechanism
      if (!mountAttempted) {
        mountAttempted = true;
        console.debug("[Agora] Starting local video mount after DOM ready");
        try {
          await mountLocalVideo(cameraTrack, localDivRef);
          return true;
        } catch (err) {
          console.error(
            "[Agora] Failed to mount local video after DOM ready:",
            err
          );
          mountAttempted = false; // Cho phép retry
          return false;
        }
      }

      return false;
    };

    // Thử mount ngay
    tryMountVideo();

    // Nếu chưa mount được, check lại sau mỗi 500ms (tối đa 10 lần = 5s)
    const maxAttempts = 10;
    let attempts = 0;
    const intervalId = setInterval(async () => {
      if (!isMounted || attempts >= maxAttempts) {
        clearInterval(intervalId);
        return;
      }

      attempts++;
      const videoMounted = await tryMountVideo();
      if (videoMounted) {
        clearInterval(intervalId);
      }
    }, 500);

    return () => {
      isMounted = false;
      clearInterval(intervalId);
    };
  }, [loading]); // Chạy lại khi loading thay đổi

  // ✅ FIX: Cleanup video elements không đúng chỗ định kỳ
  useEffect(() => {
    if (loading) return;

    const cleanupInterval = setInterval(() => {
      const localContainer = localDivRef.current || document.getElementById("local-mount");
      const remoteContainer = remoteDivRef.current || document.getElementById(REMOTE_MOUNT_ID);

      // Xóa local video khỏi remote container
      if (remoteContainer) {
        const misplacedLocalVideos = remoteContainer.querySelectorAll("video[data-agora-local]");
        if (misplacedLocalVideos.length > 0) {
          console.warn(`[Agora] Cleaning up ${misplacedLocalVideos.length} misplaced local video(s) from remote container`);
          misplacedLocalVideos.forEach((v) => v.remove());
        }
      }

      // Xóa remote video khỏi local container
      if (localContainer) {
        const misplacedRemoteVideos = localContainer.querySelectorAll("video[data-agora-remote]");
        if (misplacedRemoteVideos.length > 0) {
          console.warn(`[Agora] Cleaning up ${misplacedRemoteVideos.length} misplaced remote video(s) from local container`);
          misplacedRemoteVideos.forEach((v) => v.remove());
        }
      }
    }, 2000); // Check mỗi 2 giây

    return () => {
      clearInterval(cleanupInterval);
    };
  }, [loading]);

  // Xử lý khi user đóng tab/refresh đột ngột
  useEffect(() => {
    const handleBeforeUnload = () => {
      // QUAN TRỌNG: Cleanup Agora tracks SYNCHRONOUSLY trước khi reload
      // Điều này ngăn React cố remove DOM nodes mà Agora đang dùng
      try {
        const client = clientRef.current;
        const { audioTrack, videoTrack } = localTrackRefs.current || {};

        // Stop và close tracks ngay lập tức (synchronous)
        if (videoTrack) {
          try {
            videoTrack.stop();
            videoTrack.close();
          } catch {
            // Ignore
          }
        }
        if (audioTrack) {
          try {
            audioTrack.stop();
            audioTrack.close();
          } catch {
            // Ignore
          }
        }

        // Leave client (synchronous - không await)
        if (client) {
          try {
            client.leave().catch(() => {
              // Ignore async errors
            });
          } catch {
            // Ignore
          }
        }

        // Clear refs
        clientRef.current = null;
        localTrackRefs.current = { audioTrack: null, videoTrack: null };
      } catch {
        // Ignore cleanup errors
      }

      // Backup snapshots
      if (snapshots.length > 0 && paramId) {
        try {
          const key = `snapshots_${paramId}`;
          const existing = JSON.parse(localStorage.getItem(key) || "[]");
          const existingUrls = existing.map((s) => s.url);

          const newSnapshots = snapshots
            .filter((url) => !existingUrls.includes(url))
            .map((url) => ({ url, timestamp: Date.now() }));

          if (newSnapshots.length > 0) {
            localStorage.setItem(
              key,
              JSON.stringify([...existing, ...newSnapshots])
            );
          }
        } catch {
          // Ignore localStorage errors
        }
      }
    };

    window.addEventListener("beforeunload", handleBeforeUnload);

    return () => {
      window.removeEventListener("beforeunload", handleBeforeUnload);
    };
  }, [snapshots, paramId]);

  // toggle mic
  const toggleMic = async () => {
    const t = localTrackRefs.current?.audioTrack;
    if (!t) {
      console.warn("[Meeting] No audio track available for toggle");
      return;
    }
    try {
      const newState = !micOn;
      await t.setEnabled(newState);
      setMicOn(newState);
      console.debug(`[Meeting] Mic ${newState ? "enabled" : "disabled"}`);
    } catch (e) {
      console.error("[Meeting] toggleMic failed", e);
      // Không set error state để tránh làm component render error screen
      // Chỉ log error và giữ nguyên state
    }
  };

  // toggle cam
  const toggleCam = async () => {
    const t = localTrackRefs.current?.videoTrack;
    if (!t) {
      console.warn("[Meeting] No video track available for toggle");
      return;
    }
    try {
      const newState = !camOn;
      await t.setEnabled(newState);
      setCamOn(newState);
      
      // Update remote users state
      setRemoteUsers((prev) => {
        const copy = { ...prev };
        const localUid = tokenData?.uid ?? 0;
        if (copy[localUid]) {
          copy[localUid].hasVideo = newState;
        }
        return copy;
      });
      
      console.debug(`[Meeting] Camera ${newState ? "enabled" : "disabled"}`);
    } catch (err) {
      console.error("[Meeting] toggleCam failed", err);
      // Không set error state để tránh làm component render error screen
      // Chỉ log error và giữ nguyên state
    }
  };

  const leaveAndBack = async () => {
    stopAutoSnapshots();

    // Gửi lại tất cả snapshots (đảm bảo không mất)
    if (snapshots.length > 0 && paramId) {
      try {
        await api.saveAppointmentSnapshots(paramId, snapshots);
        console.log(
          `Final save: ${snapshots.length} snapshots sent to backend`
        );
      } catch (error) {
        console.error("Final save snapshots error:", error);
        // Backup vào localStorage nếu gửi thất bại
        snapshots.forEach((url) => {
          saveSnapshotToLocalStorage(paramId, url);
        });
      }
    }

    // Retry snapshots từ localStorage
    if (paramId) {
      await retryFailedSnapshots(paramId);
    }

    await cleanupAndLeave();
    navigate(-1);
  };

  const formatMs = (ms) => {
    if (ms == null) return "--:--";
    const total = Math.floor(ms / 1000);
    const mm = String(Math.floor(total / 60)).padStart(2, "0");
    const ss = String(total % 60).padStart(2, "0");
    return `${mm}:${ss}`;
  };

  if (loading) {
    return (
      <div className={styles.loading}>
        <Loader2 className="w-6 h-6 inline-block mr-2" /> Preparing meeting...
      </div>
    );
  }

  if (error) {
    return <div className={styles.error}>Error: {String(error)}</div>;
  }

  if (!tokenData) {
    return <div className={styles.error}>No token available</div>;
  }

  const remoteList = Object.values(remoteUsers).filter((u) => !u.isLocal);
  const anyRemote = remoteList.length > 0;

  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <div className={styles.headerLeft}>
          <Video />
          <h2 className={styles.title}>
            Meeting — {paramId || tokenData.channel}
          </h2>
        </div>

        <div className={styles.headerRight}>
          <div className={styles.timer}>
            <Timer />
            <span style={{ marginLeft: 8 }}>
              {formatMs(elapsedMs)} | left{" "}
              {timeLeftMs != null ? formatMs(timeLeftMs) : "N/A"}
            </span>
          </div>
          <div
            className={styles.participantCount}
            style={{
              display: "flex",
              gap: 6,
              alignItems: "center",
              padding: "6px 10px",
              borderRadius: 8,
              background: "#fff7ed",
              color: "#663c00",
            }}
          >
            <User />
            <span>{1 + remoteList.length}</span>
          </div>
        </div>
      </header>

      <main className={styles.main}>
        <div className={styles.gridSideBySide}>
          {/* Left: Local */}
          <div className={styles.tile}>
            <div className={styles.tileHeader}>
              <div>You</div>
              <div className={styles.tileBadge}>Local</div>
            </div>
            <div
              id={`local-mount`}
              ref={localDivRef}
              className={styles.tileInner}
            />
          </div>

          {/* Right: Remote */}
          <div className={styles.tile}>
            <div className={styles.tileHeader}>
              <div>
                {anyRemote
                  ? remoteList[0].name || `User ${remoteList[0].uid}`
                  : "Waiting for participant"}
              </div>
              <div className={styles.tileBadge}>Remote</div>
            </div>
            <div
              id={REMOTE_MOUNT_ID}
              ref={remoteDivRef}
              className={styles.tileInner}
              // Prevent React from unmounting this node khi có video tracks
              data-agora-container="remote"
            >
              {!anyRemote && (
                <div className={styles.placeholder}>
                  <User size={48} />
                  <div style={{ fontSize: 18, fontWeight: 700 }}>
                    Waiting for participant
                  </div>
                  <div className={styles.placeholderName}>
                    Participant chưa vào hoặc chưa bật video
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className={styles.controlsWrap}>
          <div className={styles.controls}>
            <button
              className={styles.controlBtn}
              onClick={toggleMic}
              title={micOn ? "Mute" : "Unmute"}
            >
              {micOn ? <Mic /> : <MicOff />}
            </button>

            <button
              className={styles.controlBtn}
              onClick={toggleCam}
              title={camOn ? "Turn camera off" : "Turn camera on"}
            >
              {camOn ? <Video /> : <VideoOff />}
            </button>

            <button
              className={`${styles.controlBtn} ${styles.leaveBtn}`}
              onClick={leaveAndBack}
              title="Leave"
            >
              <Phone />
            </button>

            <button
              className={styles.controlBtn}
              onClick={() => {
                /* optional fullscreen */
              }}
              title="Toggle fullscreen"
            >
              <Maximize2 />
            </button>
          </div>

          <div className={styles.meta}>
            <div>
              <strong>Channel:</strong> {tokenData.channel}
            </div>
            <div>
              <strong>UID:</strong> {tokenData.uid}
            </div>
            <div>
              <strong>Expires:</strong>{" "}
              {tokenData.expiresAt
                ? new Date(tokenData.expiresAt).toString()
                : "N/A"}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
