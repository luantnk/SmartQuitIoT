import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { AlertTriangle, Info, Loader2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

const ReseedSlotsModal = ({ open, onOpenChange, onSuccess }) => {
  const [formData, setFormData] = useState({
    start: "07:00",
    end: "19:00",
    slotMinutes: 30,
    gapMinutes: 0,
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateForm = () => {
    const newErrors = {};

    // Validate start time (HH:mm format)
    if (!formData.start) {
      newErrors.start = "Start time is required";
    } else if (!/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(formData.start)) {
      newErrors.start = "Start time must be in HH:mm format (e.g., 07:00)";
    }

    // Validate end time (HH:mm format)
    if (!formData.end) {
      newErrors.end = "End time is required";
    } else if (!/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(formData.end)) {
      newErrors.end = "End time must be in HH:mm format (e.g., 19:00)";
    }

    // Validate that start < end
    if (!newErrors.start && !newErrors.end) {
      const [startHour, startMin] = formData.start.split(":").map(Number);
      const [endHour, endMin] = formData.end.split(":").map(Number);
      const startMinutes = startHour * 60 + startMin;
      const endMinutes = endHour * 60 + endMin;

      if (startMinutes >= endMinutes) {
        newErrors.end = "End time must be after start time";
      }
    }

    // Validate slotMinutes
    if (!formData.slotMinutes || formData.slotMinutes < 1) {
      newErrors.slotMinutes = "Slot duration must be at least 1 minute";
    }

    // Validate gapMinutes
    if (formData.gapMinutes === null || formData.gapMinutes === undefined || formData.gapMinutes < 0) {
      newErrors.gapMinutes = "Gap minutes must be 0 or greater";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    try {
      const { reseedSlots } = await import("@/services/slotService");
      const response = await reseedSlots(
        formData.start,
        formData.end,
        formData.slotMinutes,
        formData.gapMinutes
      );

      const message = response?.data?.message || "Slots reseeded successfully";
      toast.success(message);

      // Show details if available
      const data = response?.data?.data;
      if (data) {
        console.log("Reseed result:", {
          created: data.createdCount,
          deleted: data.deletedCount,
          total: data.totalSlots,
        });
      }

      onSuccess?.();
      onOpenChange(false);
      
      // Reset form
      setFormData({
        start: "07:00",
        end: "19:00",
        slotMinutes: 30,
        gapMinutes: 0,
      });
      setErrors({});
    } catch (error) {
      console.error("Reseed slots error:", error);
      const errorMessage =
        error?.response?.data?.message ||
        error?.message ||
        "Failed to reseed slots. Please try again.";
      toast.error(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error for this field when user starts typing
    if (errors[field]) {
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-amber-600" />
            Reseed Slots Configuration
          </DialogTitle>
          <DialogDescription>
            Update the slot configuration. This action will recreate all slots
            based on the new parameters.
          </DialogDescription>
        </DialogHeader>

        {/* Critical Warning */}
        <div className="rounded-lg border-2 border-red-200 bg-red-50 p-4 space-y-3">
          <div className="flex items-start gap-3">
            <AlertTriangle className="h-5 w-5 text-red-600 mt-0.5 flex-shrink-0" />
            <div className="flex-1 space-y-2">
              <h4 className="font-semibold text-red-900">
                ⚠️ Critical Warning: Data Deletion
              </h4>
              <p className="text-sm text-red-800">
                <strong>
                  This operation is NOT part of normal business logic.
                </strong>
              </p>
              <div className="text-sm text-red-700 space-y-1">
                <p>
                  When you reseed slots, the following data will be
                  <strong className="font-semibold"> permanently deleted</strong>:
                </p>
                <ul className="list-disc list-inside space-y-1 ml-2">
                  <li>All Feedbacks related to affected appointments</li>
                  <li>All Appointments using old slot configurations</li>
                  <li>All CoachWorkSchedule records using old slots</li>
                </ul>
                <p className="mt-2 font-medium">
                  The system will block this operation if there are active
                  appointments from today onwards.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Info Box */}
        <div className="rounded-lg border border-blue-200 bg-blue-50 p-3">
          <div className="flex items-start gap-2">
            <Info className="h-4 w-4 text-blue-600 mt-0.5 flex-shrink-0" />
            <div className="text-sm text-blue-800">
              <p>
                <strong>How it works:</strong> The system will create new slots
                based on your configuration and delete old slots that don't
                match. Only proceed if you understand the consequences.
              </p>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            {/* Start Time */}
            <div className="space-y-2">
              <Label htmlFor="start">
                Start Time <span className="text-red-500">*</span>
              </Label>
              <Input
                id="start"
                type="text"
                placeholder="07:00"
                value={formData.start}
                onChange={(e) => handleChange("start", e.target.value)}
                className={errors.start ? "border-red-500" : ""}
              />
              {errors.start && (
                <p className="text-sm text-red-500">{errors.start}</p>
              )}
              <p className="text-xs text-gray-500">
                Format: HH:mm (24-hour format)
              </p>
            </div>

            {/* End Time */}
            <div className="space-y-2">
              <Label htmlFor="end">
                End Time <span className="text-red-500">*</span>
              </Label>
              <Input
                id="end"
                type="text"
                placeholder="19:00"
                value={formData.end}
                onChange={(e) => handleChange("end", e.target.value)}
                className={errors.end ? "border-red-500" : ""}
              />
              {errors.end && (
                <p className="text-sm text-red-500">{errors.end}</p>
              )}
              <p className="text-xs text-gray-500">
                Format: HH:mm (24-hour format)
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Slot Duration */}
            <div className="space-y-2">
              <Label htmlFor="slotMinutes">
                Slot Duration (minutes) <span className="text-red-500">*</span>
              </Label>
              <Input
                id="slotMinutes"
                type="number"
                min="1"
                placeholder="30"
                value={formData.slotMinutes}
                onChange={(e) =>
                  handleChange("slotMinutes", parseInt(e.target.value) || 0)
                }
                className={errors.slotMinutes ? "border-red-500" : ""}
              />
              {errors.slotMinutes && (
                <p className="text-sm text-red-500">{errors.slotMinutes}</p>
              )}
              <p className="text-xs text-gray-500">
                Duration of each appointment slot
              </p>
            </div>

            {/* Gap Minutes */}
            <div className="space-y-2">
              <Label htmlFor="gapMinutes">
                Gap Between Slots (minutes) <span className="text-red-500">*</span>
              </Label>
              <Input
                id="gapMinutes"
                type="number"
                min="0"
                placeholder="0"
                value={formData.gapMinutes}
                onChange={(e) =>
                  handleChange("gapMinutes", parseInt(e.target.value) || 0)
                }
                className={errors.gapMinutes ? "border-red-500" : ""}
              />
              {errors.gapMinutes && (
                <p className="text-sm text-red-500">{errors.gapMinutes}</p>
              )}
              <p className="text-xs text-gray-500">
                Break time between consecutive slots
              </p>
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="destructive"
              disabled={isSubmitting}
              className="bg-red-600 hover:bg-red-700"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Reseeding...
                </>
              ) : (
                "Reseed Slots"
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
};

export default ReseedSlotsModal;

