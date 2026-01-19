import React, { useEffect, useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
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
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Calendar, Clock, User, Loader2, AlertCircle, UserRoundCog } from "lucide-react";
import { formatDate } from "@/utils/formatDate";
import {
  getAvailableCoaches,
  reassignAppointment,
} from "@/services/appointmentService";
import useToast from "@/hooks/useToast";

const ReassignAppointmentModal = ({
  isOpen,
  onOpenChange,
  appointment,
  onReassigned,
}) => {
  const toast = useToast();
  const [availableCoaches, setAvailableCoaches] = useState([]);
  const [loadingCoaches, setLoadingCoaches] = useState(false);
  const [selectedCoachId, setSelectedCoachId] = useState("");
  const [reassigning, setReassigning] = useState(false);
  const [errorMsg, setErrorMsg] = useState(null);
  const [confirmOpen, setConfirmOpen] = useState(false);

  // Reset state when modal closes
  useEffect(() => {
    if (!isOpen) {
      setAvailableCoaches([]);
      setSelectedCoachId("");
      setLoadingCoaches(false);
      setReassigning(false);
      setErrorMsg(null);
      return;
    }

    // Fetch available coaches when modal opens
    const fetchAvailableCoaches = async () => {
      if (!appointment) return;

      const { date, slotId, coachId } = appointment;
      if (!date || !slotId) {
        setErrorMsg("Appointment date or slot information is missing");
        return;
      }

      setLoadingCoaches(true);
      setErrorMsg(null);
      try {
        const isoDate =
          typeof date === "string"
            ? date
            : date?.toISOString?.()?.slice(0, 10) || date;
        const res = await getAvailableCoaches({
          date: isoDate,
          slotId,
          excludeCoachId: coachId,
        });

        // Parse response
        let parsed = [];
        if (res && res.data !== undefined) {
          const payload = res.data;
          if (Array.isArray(payload)) {
            parsed = payload;
          } else if (Array.isArray(payload.data)) {
            parsed = payload.data;
          } else if (Array.isArray(payload.items)) {
            parsed = payload.items;
          } else if (Array.isArray(payload.result)) {
            parsed = payload.result;
          } else {
            const maybeArray = Object.values(payload).find(Array.isArray);
            if (Array.isArray(maybeArray)) parsed = maybeArray;
          }
        }
        if (!Array.isArray(parsed)) parsed = [];
        setAvailableCoaches(parsed);
      } catch (err) {
        console.error("getAvailableCoaches error:", err);
        setErrorMsg(
          err?.response?.data?.message ||
            err?.message ||
            "Failed to load available coaches"
        );
        setAvailableCoaches([]);
      } finally {
        setLoadingCoaches(false);
      }
    };

    fetchAvailableCoaches();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, appointment]);

  if (!appointment) return null;

  const { appointmentId, coachName, date, startTime, endTime, slotId } =
    appointment;

  // Find selected coach name for confirmation dialog
  const selectedCoach = availableCoaches.find(
    (c) => String(c.id) === selectedCoachId
  );
  const selectedCoachName = selectedCoach
    ? selectedCoach.firstName
      ? `${selectedCoach.firstName} ${selectedCoach.lastName ?? ""}`.trim()
      : selectedCoach.fullName || selectedCoach.name || `Coach #${selectedCoach.id}`
    : "";

  const handleReassignClick = () => {
    setErrorMsg(null);
    if (!selectedCoachId) {
      setErrorMsg("Please select a target coach");
      return;
    }
    setConfirmOpen(true);
  };

  const handleConfirmReassign = async () => {
    setConfirmOpen(false);
    try {
      setReassigning(true);
      await reassignAppointment(appointmentId, parseInt(selectedCoachId));
      toast.success("Appointment reassigned successfully");
      if (typeof onReassigned === "function") onReassigned();
      onOpenChange(false);
    } catch (err) {
      console.error("reassignAppointment error:", err);
      const msg =
        err?.response?.data?.message ||
        err?.response?.data?.error ||
        err?.message ||
        "Failed to reassign appointment";
      setErrorMsg(msg);
      toast.error(msg);
    } finally {
      setReassigning(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-3">
            <User className="h-5 w-5 text-primary" />
            Reassign Appointment
            <Badge variant="outline" className="ml-auto">
              ID: {appointmentId ?? "N/A"}
            </Badge>
          </DialogTitle>
          <DialogDescription>
            Reassign this appointment to another available coach. Only PENDING
            appointments can be reassigned.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Appointment Info */}
          <div className="p-4 bg-muted/50 rounded-lg space-y-3">
            <div className="flex items-center gap-2 text-sm">
              <Calendar className="h-4 w-4 text-muted-foreground" />
              <span className="font-medium">Date:</span>
              <span>{formatDate(date)}</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Clock className="h-4 w-4 text-muted-foreground" />
              <span className="font-medium">Time:</span>
              <span>
                {startTime} - {endTime}
              </span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <User className="h-4 w-4 text-muted-foreground" />
              <span className="font-medium">Current Coach:</span>
              <span>{coachName ?? "N/A"}</span>
            </div>
          </div>

          {/* Coach Selection */}
          <div className="space-y-3">
            <label className="text-sm font-medium">
              Select New Coach <span className="text-destructive">*</span>
            </label>

            {loadingCoaches ? (
              <div className="flex items-center gap-2 text-sm text-muted-foreground p-4 border rounded-lg">
                <Loader2 className="w-4 h-4 animate-spin" />
                Loading available coaches...
              </div>
            ) : errorMsg ? (
              <div className="flex items-center gap-2 text-sm text-destructive p-4 border border-destructive/50 rounded-lg bg-destructive/10">
                <AlertCircle className="w-4 h-4" />
                {errorMsg}
              </div>
            ) : availableCoaches.length > 0 ? (
              <Select
                value={selectedCoachId}
                onValueChange={setSelectedCoachId}
                disabled={reassigning}
              >
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Choose a coach..." />
                </SelectTrigger>
                <SelectContent>
                  {availableCoaches.map((coach) => {
                    const displayName = coach.firstName
                      ? `${coach.firstName} ${coach.lastName ?? ""}`.trim()
                      : coach.fullName || coach.name || `Coach #${coach.id}`;
                    return (
                      <SelectItem key={coach.id} value={String(coach.id)}>
                        <div className="flex flex-col">
                          <span className="font-medium">{displayName}</span>
                          <span className="text-xs text-muted-foreground">
                            ID: {coach.id}
                            {coach.ratingAvg !== undefined &&
                              ` • Rating: ${coach.ratingAvg}`}
                            {coach.experienceYears !== undefined &&
                              ` • Experience: ${coach.experienceYears} years`}
                          </span>
                        </div>
                      </SelectItem>
                    );
                  })}
                </SelectContent>
              </Select>
            ) : (
              <div className="text-sm text-muted-foreground p-4 border rounded-lg">
                No available coaches for this slot.
              </div>
            )}
          </div>

          {/* Warning Note */}
          <div className="p-3 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg">
            <p className="text-sm text-yellow-800 dark:text-yellow-200">
              <strong>Note:</strong> Reassigning will mark the old coach's slot
              as <strong>UNAVAILABLE</strong>.
            </p>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t">
            <Button
              variant="ghost"
              onClick={() => onOpenChange(false)}
              disabled={reassigning}
            >
              Cancel
            </Button>
            <Button
              onClick={handleReassignClick}
              disabled={!selectedCoachId || reassigning || loadingCoaches}
            >
              Reassign
            </Button>
          </div>
        </div>
      </DialogContent>

      {/* Confirmation Dialog */}
      <AlertDialog open={confirmOpen} onOpenChange={setConfirmOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <UserRoundCog className="w-5 h-5 text-amber-500" />
              Confirm Reassignment
            </AlertDialogTitle>
            <AlertDialogDescription className="text-base">
              Are you sure you want to reassign appointment #{appointmentId}?
              <br />
              <br />
              <strong>Current Coach:</strong> {coachName}
              <br />
              <strong>New Coach:</strong> {selectedCoachName}
              <br />
              <br />
              <span className="text-amber-600 dark:text-amber-400 font-medium">
                This will mark the old coach's slot as UNAVAILABLE.
              </span>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={reassigning}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmReassign}
              disabled={reassigning}
              className="bg-amber-500 hover:bg-amber-600 text-white"
            >
              {reassigning ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Reassigning...
                </>
              ) : (
                "Confirm Reassign"
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Dialog>
  );
};

export default ReassignAppointmentModal;

