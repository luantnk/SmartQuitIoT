import ActionMenu from "@/components/ui/action-menu";
import { Badge } from "@/components/ui/badge";
import { useNavigate } from "react-router-dom";

export const getAppointmentStatusBadge = (status) => {
  const statusUpper = (status || "").toUpperCase();
  switch (statusUpper) {
    case "PENDING":
      return (
        <Badge className="bg-amber-500 hover:bg-amber-600 text-white">
          Pending
        </Badge>
      );
    case "IN_PROGRESS":
      return (
        <Badge className="bg-blue-500 hover:bg-blue-600 text-white">
          In Progress
        </Badge>
      );
    case "COMPLETED":
      return (
        <Badge className="bg-emerald-500 hover:bg-emerald-600 text-white">
          Completed
        </Badge>
      );
    case "CANCELLED":
      return (
        <Badge className="bg-red-500 hover:bg-red-600 text-white">
          Cancelled
        </Badge>
      );
    default:
      return <Badge variant="secondary">{status || "—"}</Badge>;
  }
};

export const appointmentColumns = (handlers) => [
  {
    accessorKey: "appointmentId",
    header: "ID",
  },
  {
    accessorKey: "coachName",
    header: "Coach Name",
    accessorFn: (row) => row.coachName ?? "",
    cell: ({ row, getValue }) => {
      const name = getValue();
      const nav = useNavigate();
      return (
        <div
          className="flex flex-col cursor-pointer"
          onClick={() => nav(`/admin/manage-coaches/${row.original.coachId}`)}
        >
          <span className="font-medium">{name || "—"}</span>
          <span className="text-xs text-muted-foreground">
            Coach ID: {row.original.coachId}
          </span>
        </div>
      );
    },
  },
  {
    accessorKey: "memberName",
    header: "Member Name",
    accessorFn: (row) => row.memberName ?? "",
    cell: ({ row, getValue }) => {
      const name = getValue();
      const nav = useNavigate();
      return (
        <div
          className="flex flex-col cursor-pointer"
          onClick={() => nav(`/admin/manage-members/${row.original.memberId}`)}
        >
          <span className="font-medium">{name || "—"}</span>
          <span className="text-xs text-muted-foreground">
            Member ID: {row.original.memberId}
          </span>
        </div>
      );
    },
  },
  {
    accessorKey: "date",
    header: "Date",
  },
  {
    accessorKey: "startTime",
    header: "Start Time",
  },
  {
    accessorKey: "endTime",
    header: "End Time",
  },
  {
    id: "status",
    header: "Status",
    accessorFn: (row) => row.realAppointmentStatus || row.appointmentStatus || "",
    cell: ({ getValue }) => {
      const status = getValue();
      return getAppointmentStatusBadge(status);
    },
  },
  {
    id: "actions",
    header: "",
    cell: ({ row }) => {
      // Only show reassign option for PENDING appointments
      // Check multiple possible field names for status
      const status = 
        row.original.realAppointmentStatus || 
        row.original.appointmentStatus || 
        row.original.status ||
        "";
      const statusUpper = String(status).toUpperCase().trim();
      const isPending = statusUpper === "PENDING";
      
      return (
        <ActionMenu
          row={row}
          onEdit={handlers?.onEdit}
          editMessage="View Detail"
          onReassign={isPending ? handlers?.onReassign : undefined}
        />
      );
    },
    size: 48,
    enableHiding: false,
  },
];
