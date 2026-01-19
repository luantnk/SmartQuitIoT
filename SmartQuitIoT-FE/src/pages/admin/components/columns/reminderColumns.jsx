import { Badge } from "@/components/ui/badge";
import { formatDateTime } from "@/utils/formatDate";
import { Button } from "@/components/ui/button";
import { Pencil } from "lucide-react";

const phaseBadge = (phase) => {
  if (!phase) {
    return <Badge variant="outline" className="text-gray-500">N/A</Badge>;
  }
  
  const colors = {
    PREPARATION: "bg-blue-500 hover:bg-blue-600",
    ONSET: "bg-purple-500 hover:bg-purple-600",
    PEAK_CRAVING: "bg-rose-500 hover:bg-rose-600",
    SUBSIDING: "bg-amber-500 hover:bg-amber-600",
    MAINTENANCE: "bg-emerald-500 hover:bg-emerald-600",
  };
  
  return (
    <Badge className={`${colors[phase] || "bg-gray-500"} text-white`}>
      {phase?.replace(/_/g, " ")}
    </Badge>
  );
};

const typeBadge = (type) => {
  const colors = {
    MORNING: "bg-sky-500 hover:bg-sky-600",
    BEHAVIOR: "bg-indigo-500 hover:bg-indigo-600",
    SMOKED: "bg-orange-500 hover:bg-orange-600",
  };
  
  return (
    <Badge className={`${colors[type] || "bg-gray-500"} text-white`}>
      {type || "—"}
    </Badge>
  );
};

const triggerBadge = (trigger) => {
  if (!trigger) {
    return <span className="text-gray-400 text-xs">—</span>;
  }
  
  return (
    <Badge variant="secondary" className="font-mono text-xs">
      {trigger.replace(/_/g, " ")}
    </Badge>
  );
};

export const reminderColumns = (handlers = {}) => [
  {
    accessorKey: "id",
    header: "ID",
    cell: ({ row }) => <span className="font-medium">#{row.original.id}</span>,
    size: 70,
  },
  {
    accessorKey: "phaseEnum",
    header: "Phase",
    cell: ({ row }) => phaseBadge(row.original.phaseEnum),
    size: 150,
  },
  {
    accessorKey: "reminderType",
    header: "Type",
    cell: ({ row }) => typeBadge(row.original.reminderType),
    size: 120,
  },
  {
    accessorKey: "triggerCode",
    header: "Trigger Code",
    cell: ({ row }) => triggerBadge(row.original.triggerCode),
    size: 140,
  },
  {
    accessorKey: "content",
    header: "Content",
    cell: ({ row }) => (
      <div className="max-w-md">
        <p className="text-sm text-gray-700 line-clamp-2">
          {row.original.content || "—"}
        </p>
      </div>
    ),
    size: 300,
  },
  {
    accessorKey: "createdAt",
    header: "Created",
    cell: ({ row }) => (
      <span className="text-xs text-gray-600">
        {formatDateTime(row.original.createdAt)}
      </span>
    ),
    size: 170,
  },
  {
    accessorKey: "updatedAt",
    header: "Updated",
    cell: ({ row }) => (
      <span className="text-xs text-gray-600">
        {formatDateTime(row.original.updatedAt)}
      </span>
    ),
    size: 170,
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => (
      <Button
        variant="ghost"
        size="sm"
        onClick={() => handlers?.onEdit?.(row.original)}
        className="hover:bg-emerald-50 hover:text-emerald-700"
      >
        <Pencil className="h-4 w-4 mr-1" />
        Edit
      </Button>
    ),
    size: 100,
    enableHiding: false,
  },
];
