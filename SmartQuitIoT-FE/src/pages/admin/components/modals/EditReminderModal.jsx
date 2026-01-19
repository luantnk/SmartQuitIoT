import React, { useEffect, useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";

const EditReminderModal = ({ open, onClose, reminder, onSubmit }) => {
  const [content, setContent] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (reminder) {
      setContent(reminder.content || "");
    }
  }, [reminder]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!content.trim()) {
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(reminder.id, { content: content.trim() });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!reminder) return null;

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Edit Reminder Template</DialogTitle>
          <DialogDescription>
            Update the content for this reminder template
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Read-only info */}
          <div className="grid grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg">
            <div>
              <Label className="text-xs text-gray-600">ID</Label>
              <p className="font-semibold">#{reminder.id}</p>
            </div>
            <div>
              <Label className="text-xs text-gray-600">Trigger Code</Label>
              <p className="font-mono text-sm">{reminder.triggerCode || "—"}</p>
            </div>
            <div>
              <Label className="text-xs text-gray-600">Phase</Label>
              <div className="mt-1">
                <Badge className="bg-blue-500">
                  {reminder.phaseEnum?.replace(/_/g, " ")}
                </Badge>
              </div>
            </div>
            <div>
              <Label className="text-xs text-gray-600">Type</Label>
              <div className="mt-1">
                <Badge className="bg-indigo-500">
                  {reminder.reminderType}
                </Badge>
              </div>
            </div>
          </div>

          {/* Editable content */}
          <div className="space-y-2">
            <Label htmlFor="content">
              Content <span className="text-red-500">*</span>
            </Label>
            <Textarea
              id="content"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="Enter reminder content..."
              rows={6}
              className="resize-none"
              disabled={isSubmitting}
            />
            <p className="text-xs text-gray-500">
              {content.length} characters
            </p>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={!content.trim() || isSubmitting}
              className="bg-emerald-600 hover:bg-emerald-700"
            >
              {isSubmitting ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
};

export default EditReminderModal;
