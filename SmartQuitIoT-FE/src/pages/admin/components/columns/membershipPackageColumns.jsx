import ActionMenu from "@/components/ui/action-menu";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/utils/currencyFormat";

export const membershipPackageColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "description",
    header: "Description",
  },
  {
    accessorKey: "price",
    header: "Price",
    cell: ({ row }) => {
      return <Badge>{formatCurrency(row.original.price)}</Badge>;
    },
  },
  {
    accessorKey: "type",
    header: "Type",
    cell: ({ getValue }) => {
      const t = (getValue() || "").toString().toUpperCase();
      const style =
        t === "STANDARD"
          ? "bg-green-100 text-green-700"
          : t === "PREMIUM"
          ? "bg-yellow-100 text-yellow-700"
          : "bg-gray-100 text-gray-700";
      return (
        <Badge className={`px-2 py-0.5 text-xs font-medium ${style}`}>
          {t || "—"}
        </Badge>
      );
    },
  },
  {
    accessorKey: "duration",
    header: "Duration",
    cell: ({ row }) => (
      <span>
        {row.original.duration} {row.original.durationUnit}
      </span>
    ),
  },
  {
    id: "actions",
    header: "",
    cell: ({ row }) => <ActionMenu row={row} onEdit={handlers?.onEdit} />,
    size: 48, // optional
    enableHiding: false,
  },
];
