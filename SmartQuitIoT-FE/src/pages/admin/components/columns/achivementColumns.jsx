import ActionMenu from "@/components/ui/action-menu";
import { Badge } from "@/components/ui/badge";

export const achievementColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    id: "name",
    header: "Name",
    accessorFn: (row) => row.name ?? "",
    cell: ({ getValue }) => {
      const name = getValue();
      return name ? (
        <span className="inline-flex items-center gap-1 text-gray-600 hover:underline">
          {name}
        </span>
      ) : (
        <span className="text-muted-foreground">—</span>
      );
    },
  },
  {
    id: "typ",
    header: "Type",
    accessorFn: (row) => row.type ?? "",
    cell: ({ getValue }) => {
      const type = getValue();
      const typeColors = {
        STREAK: "bg-purple-100 text-purple-700",
        ACTIVITY: "bg-blue-100 text-blue-700",
        FINANCE: "bg-green-100 text-green-700",
        SOCIAL: "bg-pink-100 text-pink-700",
        PROGRESS: "bg-orange-100 text-orange-700",
      };
      return (
        <Badge
          className={`px-2 py-0.5 text-xs font-medium ${
            typeColors[type] || "bg-gray-100 text-gray-700"
          }`}
        >
          {type || "—"}
        </Badge>
      );
    },
  },
  {
    id: "description",
    header: "Description",
    accessorFn: (row) => row.description ?? "",
    cell: ({ getValue }) => {
      const description = getValue();
      return description ? (
        <span className="inline-flex items-center gap-1 text-gray-600 hover:underline">
          {description}
        </span>
      ) : (
        <span className="text-muted-foreground">—</span>
      );
    },
  },
  {
    id: "icon",
    header: "Icon",
    accessorFn: (row) => row.icon ?? 0,
    cell: ({ getValue }) => (
      <img src={getValue()} alt="Achievement Icon" className="h-8 w-8" />
    ),
  },
  {
    id: "updatedAt",
    header: "Updated At",
    accessorFn: (row) => row.updatedAt ?? "",
    cell: ({ getValue }) => {
      const updatedAt = getValue();
      if (!updatedAt) return <span className="text-muted-foreground">—</span>;

      const date = new Date(updatedAt);
      const formatted = date.toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });

      return <span className="text-gray-600 text-sm">{formatted}</span>;
    },
  },

  {
    id: "actions",
    header: "",
    cell: ({ row }) => (
      <ActionMenu
        row={row}
        onEdit={handlers?.onEdit}
        onDelete={handlers?.onDelete}
        onViewDetails={handlers?.onViewDetails}
      />
    ),
    size: 48, // optional
    enableHiding: false,
  },
];
