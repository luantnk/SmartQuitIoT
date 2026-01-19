import ActionMenu from "@/components/ui/action-menu";

export const newsColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    id: "title",
    header: "Title",
    accessorFn: (row) => row.title ?? "",
    cell: ({ getValue }) => {
      const title = getValue();
      return <span className="font-medium">{title}</span>;
    },
  },
  {
    id: "status",
    header: "Status",
    accessorFn: (row) => row.status ?? "",
    cell: ({ getValue }) => {
      const status = getValue();
      return <span className="text-gray-600">{status}</span>;
    },
  },
  {
    id: "publishedDate",
    header: "Published Date",
    accessorFn: (row) => row.publishedDate ?? "",
    cell: ({ getValue }) => {
      const date = new Date(getValue());
      return <span className="text-gray-600">{date.toLocaleDateString()}</span>;
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
      />
    ),
    size: 48, // optional
    enableHiding: false,
  },
];
