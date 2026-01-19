// src/pages/coach/AppointmentDetailsModal.jsx
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Calendar,
  Clock,
  User,
  Video,
  XCircle,
  Loader2,
  X,
  CheckCircle,
  AlertCircle,
  Radio,
  Image as ImageIcon,
} from "lucide-react";
import api from "@/api/appointments";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import useToast from "@/hooks/useToast";

/**
 * Props:
 * - open (bool)
 * - onClose()
 * - appointmentBrief: { id, date, time, member, raw } (optional)
 * - onCanceled(appointmentId)
 */
export default function AppointmentDetailsModal({
  open,
  onClose,
  appointmentBrief,
  onCanceled,
}) {
  const [loading, setLoading] = useState(false);
  const [detail, setDetail] = useState(null);
  const [error, setError] = useState(null);
  const [doingStart, setDoingStart] = useState(false);
  const [doingCancel, setDoingCancel] = useState(false);
  const [snapshots, setSnapshots] = useState([]);
  const [loadingSnapshots, setLoadingSnapshots] = useState(false);
  const [confirmCancelOpen, setConfirmCancelOpen] = useState(false);
  const navigate = useNavigate();
  const toast = useToast();

  // Clear error and reset state when modal closes
  useEffect(() => {
    if (!open) {
      setError(null);
      setConfirmCancelOpen(false);
      setDoingCancel(false);
      setDoingStart(false);
    }
  }, [open]);

  // Fetch appointment details
  useEffect(() => {
    if (!open) return;
    let mounted = true;
    const fetchDetail = async () => {
      setLoading(true);
      setError(null);
      try {
        if (!appointmentBrief?.id) {
          throw new Error("No appointment id provided");
        }
        const resp = await api.getAppointmentDetailForCoach(
          appointmentBrief.id
        );
        const dto = resp?.data?.data ?? resp?.data ?? resp;
        if (!mounted) return;
        setDetail(dto);
      } catch (e) {
        console.error("detail fetch error", e);
        if (!mounted) return;
        setError(e.message || "Failed to load appointment detail");
      } finally {
        if (mounted) setLoading(false);
      }
    };

    if (appointmentBrief?.raw && appointmentBrief.raw.memberName) {
      setDetail(appointmentBrief.raw);
      fetchDetail(); // optional: fetch fresh
    } else {
      fetchDetail();
    }
    return () => {
      mounted = false;
    };
  }, [open, appointmentBrief]);

  // Fetch snapshots nếu appointment đã completed
  useEffect(() => {
    if (!open || !appointmentBrief?.id) return;

    // Chỉ fetch snapshots nếu appointment đã completed
    const appointmentStatus =
      detail?.runtimeStatus ||
      appointmentBrief?.status ||
      appointmentBrief?.raw?.runtimeStatus;

    if (appointmentStatus !== "COMPLETED") {
      setSnapshots([]);
      return;
    }

    let mounted = true;
    const fetchSnapshots = async () => {
      setLoadingSnapshots(true);
      try {
        const resp = await api.getAppointmentSnapshots(appointmentBrief.id);
        // Response có thể là array trực tiếp hoặc wrapped
        const snapshotUrls = Array.isArray(resp)
          ? resp
          : resp?.data || resp?.imageUrls || [];

        if (!mounted) return;
        setSnapshots(Array.isArray(snapshotUrls) ? snapshotUrls : []);
      } catch (e) {
        console.error("fetch snapshots error", e);
        if (!mounted) return;
        // Không set error vì snapshots là optional
        setSnapshots([]);
      } finally {
        if (mounted) setLoadingSnapshots(false);
      }
    };

    fetchSnapshots();
    return () => {
      mounted = false;
    };
  }, [open, appointmentBrief?.id, detail?.runtimeStatus]);

  // Handle ESC key to close modal
  useEffect(() => {
    if (!open) return;
    const handleEsc = (e) => {
      if (e.key === "Escape") {
        onClose();
      }
    };
    window.addEventListener("keydown", handleEsc);
    return () => window.removeEventListener("keydown", handleEsc);
  }, [open, onClose]);

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  if (!open) return null;

  const startMeeting = async () => {
    if (!detail || !detail.appointmentId) return;
    setDoingStart(true);
    try {
      const resp = await api.requestJoinToken(detail.appointmentId);
      const tokenData = resp?.data ?? resp; // unwrap if needed
      navigate(`/meeting/${detail.appointmentId}`, {
        state: { tokenData, appointment: detail },
      });
    } catch (e) {
      console.error("request join token error", e);
      setError(e?.message || "Unable to obtain join token");
    } finally {
      setDoingStart(false);
    }
  };

  const cancelAppointment = async () => {
    if (!detail || !detail.appointmentId) return;
    setConfirmCancelOpen(true);
  };

  const handleConfirmCancel = async () => {
    if (!detail || !detail.appointmentId) return;
    setConfirmCancelOpen(false);
    setDoingCancel(true);
    setError(null); // Clear previous errors
    try {
      await api.cancelAppointmentByCoach(detail.appointmentId);
      // Show success toast
      toast.success("Appointment cancelled successfully");
      if (onCanceled) onCanceled(detail.appointmentId);
      onClose();
    } catch (e) {
      console.error("cancel error", e);
      // Extract error message from response (backend returns { message: "..." })
      const errorMessage =
        e?.response?.data?.message ||
        e?.data?.message ||
        e?.message ||
        "Cancel failed";
      setError(errorMessage);
      // Show error toast as well
      toast.error(errorMessage);
      // Keep modal open to show error
    } finally {
      setDoingCancel(false);
    }
  };

  const getStatusConfig = (status) => {
    const configs = {
      PENDING: {
        label: "Pending",
        icon: Clock,
        bgClass: "bg-amber-50",
        textClass: "text-amber-700",
        borderClass: "border-amber-200",
        iconClass: "text-amber-600",
      },
      IN_PROGRESS: {
        label: "In Progress",
        icon: Radio,
        bgClass: "bg-blue-50",
        textClass: "text-blue-700",
        borderClass: "border-blue-200",
        iconClass: "text-blue-600",
      },
      COMPLETED: {
        label: "Completed",
        icon: CheckCircle,
        bgClass: "bg-emerald-50",
        textClass: "text-emerald-700",
        borderClass: "border-emerald-200",
        iconClass: "text-emerald-600",
      },
      CANCELLED: {
        label: "Cancelled",
        icon: XCircle,
        bgClass: "bg-red-50",
        textClass: "text-red-700",
        borderClass: "border-red-200",
        iconClass: "text-red-600",
      },
    };
    return configs[status] || configs.PENDING;
  };

  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
    } catch {
      return dateString;
    }
  };

  const formatTime = (timeString) => {
    if (!timeString) return "N/A";
    try {
      const time = String(timeString).slice(0, 5);
      return time;
    } catch {
      return timeString;
    }
  };

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-6"
      aria-modal="true"
      role="dialog"
    >
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/40 backdrop-blur-sm"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Modal Container */}
      <div
        className="relative w-full max-w-2xl bg-white rounded-xl shadow-2xl overflow-hidden z-10"
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b bg-gradient-to-r from-emerald-50 to-teal-50">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              Appointment Details
            </h2>
            {detail && (
              <p className="text-sm text-gray-600 mt-1">
                ID: #{detail.appointmentId}
              </p>
            )}
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-white/80 transition-colors"
            aria-label="Close modal"
          >
            <X className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div
          className="p-6 overflow-y-auto"
          style={{ maxHeight: "calc(90vh - 140px)" }}
        >
          {loading ? (
            <div className="flex flex-col items-center justify-center py-12">
              <Loader2 className="w-8 h-8 text-emerald-600 animate-spin mb-3" />
              <p className="text-gray-600">Loading appointment details...</p>
            </div>
          ) : !detail ? (
            <div className="flex flex-col items-center justify-center py-12">
              <AlertCircle className="w-12 h-12 text-gray-400 mb-3" />
              <p className="text-gray-600">No appointment details available</p>
              {error && (
                <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                  <p className="text-red-600 font-medium">{error}</p>
                </div>
              )}
            </div>
          ) : (
            <div className="space-y-6">
              {/* Error Banner - Show at top if error exists */}
              {error && (
                <div className="flex items-start gap-3 p-4 bg-red-50 border border-red-200 rounded-lg">
                  <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
                  <div className="flex-1">
                    <p className="text-sm font-semibold text-red-900 mb-1">
                      Error
                    </p>
                    <p className="text-sm text-red-700">{error}</p>
                  </div>
                  <button
                    onClick={() => setError(null)}
                    className="text-red-500 hover:text-red-700 transition-colors"
                    aria-label="Dismiss error"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              )}
              {/* Status Badge */}
              {detail.runtimeStatus && (
                <div className="flex items-center gap-3">
                  <span className="text-sm font-medium text-gray-700">
                    Status:
                  </span>
                  {(() => {
                    const statusConfig = getStatusConfig(detail.runtimeStatus);
                    const StatusIcon = statusConfig.icon;
                    return (
                      <div
                        className={`inline-flex items-center gap-2 px-4 py-2 rounded-lg border ${statusConfig.bgClass} ${statusConfig.borderClass}`}
                      >
                        <StatusIcon
                          className={`w-4 h-4 ${statusConfig.iconClass}`}
                        />
                        <span
                          className={`text-sm font-semibold ${statusConfig.textClass}`}
                        >
                          {statusConfig.label}
                        </span>
                      </div>
                    );
                  })()}
                </div>
              )}

              {/* Information Cards */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Date Card */}
                <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl p-4 border border-gray-200">
                  <div className="flex items-center gap-3 mb-2">
                    <div className="w-10 h-10 rounded-lg bg-emerald-100 flex items-center justify-center">
                      <Calendar className="w-5 h-5 text-emerald-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600 font-medium">Date</p>
                      <p className="text-sm font-semibold text-gray-900">
                        {formatDate(detail.date)}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Time Card */}
                <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl p-4 border border-gray-200">
                  <div className="flex items-center gap-3 mb-2">
                    <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                      <Clock className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600 font-medium">Time</p>
                      <p className="text-sm font-semibold text-gray-900">
                        {formatTime(detail.startTime)} -{" "}
                        {formatTime(detail.endTime)}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Member Card */}
              <div className="bg-gradient-to-br from-emerald-50 to-teal-50 rounded-xl p-4 border border-emerald-200">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-white border-2 border-emerald-200 flex items-center justify-center">
                    <User className="w-6 h-6 text-emerald-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 font-medium">Member</p>
                    <p className="text-base font-semibold text-gray-900">
                      {detail.memberName || detail.member || "N/A"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Additional Info */}
              <div className="space-y-3">
                {detail.channelName && (
                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <span className="text-sm font-medium text-gray-700">
                      Channel:
                    </span>
                    <span className="text-sm text-gray-900 font-semibold">
                      {detail.channelName}
                    </span>
                  </div>
                )}

                {detail.joinWindowStart && detail.joinWindowEnd && (
                  <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                    <p className="text-xs font-medium text-blue-900 mb-2">
                      Join Window
                    </p>
                    <div className="space-y-1 text-sm text-blue-800">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        <span>
                          Start:{" "}
                          {new Date(detail.joinWindowStart).toLocaleString()}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        <span>
                          End: {new Date(detail.joinWindowEnd).toLocaleString()}
                        </span>
                      </div>
                    </div>
                  </div>
                )}

                {/* Snapshots Section - Chỉ hiển thị cho COMPLETED */}
                {detail.runtimeStatus === "COMPLETED" && (
                  <div className="p-4 bg-purple-50 border border-purple-200 rounded-lg">
                    <div className="flex items-center gap-2 mb-3">
                      <ImageIcon className="w-5 h-5 text-purple-600" />
                      <p className="text-sm font-semibold text-purple-900">
                        Evidence (Snapshots)
                      </p>
                    </div>
                    {loadingSnapshots ? (
                      <div className="flex items-center justify-center py-8">
                        <Loader2 className="w-6 h-6 text-purple-600 animate-spin" />
                        <span className="ml-2 text-sm text-purple-700">
                          Đang tải snapshots...
                        </span>
                      </div>
                    ) : snapshots &&
                      Array.isArray(snapshots) &&
                      snapshots.length > 0 ? (
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {snapshots.map((url, index) => (
                          <div
                            key={index}
                            className="relative group cursor-pointer rounded-lg overflow-hidden border-2 border-purple-200 hover:border-purple-400 transition-colors"
                            onClick={() => window.open(url, "_blank")}
                          >
                            <img
                              src={url}
                              alt={`Snapshot ${index + 1}`}
                              className="w-full h-48 object-cover"
                              loading="lazy"
                              onError={(e) => {
                                e.target.src = "/images/placeholder.png";
                                e.target.alt = "Failed to load image";
                              }}
                            />
                            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                              <div className="opacity-0 group-hover:opacity-100 transition-opacity text-white text-sm font-medium">
                                Click to view full size
                              </div>
                            </div>
                            <div className="absolute top-2 left-2 bg-purple-600 text-white text-xs font-semibold px-2 py-1 rounded">
                              #{index + 1}
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-sm text-purple-700 italic">
                        No snapshots available
                      </p>
                    )}
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="flex flex-wrap gap-3 pt-4 border-t">
                {detail.runtimeStatus === "PENDING" && (
                  <>
                    <button
                      disabled={doingCancel}
                      onClick={cancelAppointment}
                      className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-red-500 text-white font-medium text-sm hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-md hover:shadow-lg"
                    >
                      {doingCancel ? (
                        <>
                          <Loader2 className="w-4 h-4 animate-spin" />
                          <span>Canceling...</span>
                        </>
                      ) : (
                        <>
                          <XCircle className="w-4 h-4" />
                          <span>Cancel Appointment</span>
                        </>
                      )}
                    </button>

                    {/* Confirmation Dialog */}
                    <AlertDialog
                      open={confirmCancelOpen}
                      onOpenChange={setConfirmCancelOpen}
                    >
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle className="flex items-center gap-2">
                            <XCircle className="w-5 h-5 text-red-500" />
                            Cancel Appointment
                          </AlertDialogTitle>
                          <AlertDialogDescription className="text-base">
                            Are you sure you want to cancel this appointment?
                            This action cannot be undone.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel disabled={doingCancel}>
                            Keep Appointment
                          </AlertDialogCancel>
                          <AlertDialogAction
                            onClick={handleConfirmCancel}
                            disabled={doingCancel}
                            className="bg-red-500 hover:bg-red-600 text-white"
                          >
                            {doingCancel ? (
                              <>
                                <Loader2 className="w-4 h-4 animate-spin mr-2" />
                                Canceling...
                              </>
                            ) : (
                              "Yes, Cancel Appointment"
                            )}
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </>
                )}

                {detail.runtimeStatus === "IN_PROGRESS" && (
                  <button
                    disabled={doingStart}
                    onClick={startMeeting}
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-medium text-sm hover:from-emerald-600 hover:to-teal-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-md hover:shadow-lg"
                  >
                    {doingStart ? (
                      <>
                        <Loader2 className="w-4 h-4 animate-spin" />
                        <span>Starting...</span>
                      </>
                    ) : (
                      <>
                        <Video className="w-4 h-4" />
                        <span>Join Meeting</span>
                      </>
                    )}
                  </button>
                )}

                <button
                  onClick={onClose}
                  className="px-4 py-2.5 rounded-xl border-2 border-gray-200 text-gray-700 font-medium text-sm hover:border-gray-300 hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
