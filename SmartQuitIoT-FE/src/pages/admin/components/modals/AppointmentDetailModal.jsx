// src/pages/admin/components/modals/AppointmentDetailModal.jsx
import React from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import {
  Calendar,
  Clock,
  User,
  UserCheck,
  Video,
  ExternalLink,
  Star,
  Hash,
  Globe,
  Clock3,
  Loader2,
} from "lucide-react";
import { formatDate, formatDateTime, formatTime } from "@/utils/formatDate";
import { useNavigate } from "react-router-dom";
import { getAppointmentStatusBadge } from "@/pages/admin/components/columns/appointmentColumns";

/**
 * FE-only modal for appointment detail
 * Business rule on FE: ONLY allow reassign when:
 *  - appointment.realAppointmentStatus === "PENDING"
 *  - appointment.date >= today (not in the past)
 *
 * No extra minutes-based rule added here (per request).
 */

const InfoRow = ({ icon: IconComponent, label, value, className = "" }) => {
  // IconComponent is used in JSX below
  const Icon = IconComponent;
  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <div className="flex items-center justify-center w-8 h-8 rounded-full bg-muted/10">
        <Icon className="w-4 h-4 text-muted-foreground" />
      </div>
      <div className="flex-1">
        <div className="text-xs text-muted-foreground">{label}</div>
        <div className="font-medium">{value ?? "N/A"}</div>
      </div>
    </div>
  );
};

const SmallMuted = ({ children }) => (
  <div className="text-sm text-muted-foreground">{children}</div>
);

const AppointmentDetailModal = ({ isOpen, onOpenChange, appointment }) => {
  const nav = useNavigate();

  if (!appointment) return null;

  const {
    appointmentId,
    coachId,
    coachName,
    memberId,
    memberName,
    slotId,
    date,
    startTime,
    endTime,
    channelName,
    meetingUrl,
    joinWindowStart,
    joinWindowEnd,
    hasRated,
    realAppointmentStatus,
  } = appointment;

  const duration =
    startTime && endTime
      ? (() => {
          const start = new Date(`2000-01-01T${startTime}`);
          const end = new Date(`2000-01-01T${endTime}`);
          const diffMinutes = Math.round((end - start) / (1000 * 60));
          return `${diffMinutes} minutes`;
        })()
      : "N/A";

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-3">
            <Calendar className="h-5 w-5 text-primary" />
            Appointment Details
            <Badge variant="outline" className="ml-auto">
              ID: {appointmentId ?? "N/A"}
            </Badge>
          </DialogTitle>
          <DialogDescription className="max-w-xl">
            Comprehensive information about the scheduled appointment. Admin can
            reassign a pending appointment to another available coach.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Participants */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm flex items-center gap-2">
                  <UserCheck className="h-4 w-4 text-emerald-600" />
                  Coach
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <div
                  className="font-medium text-lg cursor-pointer hover:underline"
                  onClick={() => nav(`/admin/manage-coaches/${coachId}`)}
                >
                  {coachName ?? "N/A"}
                </div>
                <SmallMuted>ID: {coachId ?? "N/A"}</SmallMuted>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm flex items-center gap-2">
                  <User className="h-4 w-4 text-blue-600" />
                  Member
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <div
                  className="font-medium text-lg cursor-pointer hover:underline"
                  onClick={() => nav(`/admin/manage-members/${memberId}`)}
                >
                  {memberName ?? "N/A"}
                </div>
                <SmallMuted>ID: {memberId ?? "N/A"}</SmallMuted>
              </CardContent>
            </Card>
          </div>

          <Separator />

          {/* Schedule */}
          <div>
            <h3 className="font-semibold mb-4 flex items-center gap-2">
              <Clock className="h-4 w-4 text-orange-600" />
              Schedule
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <InfoRow icon={Calendar} label="Date" value={formatDate(date)} />
              <InfoRow icon={Hash} label="Slot ID" value={slotId} />
              <InfoRow icon={Clock} label="Start Time" value={startTime} />
              <InfoRow
                icon={Clock}
                label="End Time"
                value={formatTime(endTime)}
              />
              <InfoRow icon={Clock3} label="Duration" value={duration} />
              <div className="flex items-center gap-3 p-2">
                <div className="text-xs text-muted-foreground">Status</div>
                {getAppointmentStatusBadge(realAppointmentStatus)}
              </div>
            </div>
          </div>

          <Separator />

          {/* Meeting */}
          <div>
            <h3 className="font-semibold mb-4 flex items-center gap-2">
              <Video className="h-4 w-4 text-purple-600" />
              Meeting
            </h3>
            <div className="space-y-4">
              <InfoRow icon={Globe} label="Channel" value={channelName} />
              {meetingUrl && (
                <div className="flex items-center gap-3">
                  <div className="flex items-center justify-center w-8 h-8 rounded-full bg-purple-50">
                    <Video className="w-4 h-4 text-purple-600" />
                  </div>
                  <div className="flex-1">
                    <div className="text-xs text-muted-foreground">
                      Meeting URL
                    </div>
                    <Button
                      variant="link"
                      className="p-0 h-auto font-medium text-left"
                      onClick={() => window.open(meetingUrl, "_blank")}
                    >
                      {meetingUrl}
                      <ExternalLink className="w-3 h-3 ml-2" />
                    </Button>
                  </div>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <div className="text-xs text-muted-foreground mb-1">
                    Join Window Start
                  </div>
                  <div className="text-sm font-medium">
                    {formatDateTime(joinWindowStart)}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-muted-foreground mb-1">
                    Join Window End
                  </div>
                  <div className="text-sm font-medium">
                    {formatDateTime(joinWindowEnd)}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <Separator />

          {/* Rating / meta */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Star className="h-4 w-4 text-amber-500" />
              <div className="font-medium">Rating status</div>
            </div>
            <Badge variant={hasRated ? "default" : "secondary"}>
              {hasRated ? "Rated" : "Not Rated"}
            </Badge>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default AppointmentDetailModal;
