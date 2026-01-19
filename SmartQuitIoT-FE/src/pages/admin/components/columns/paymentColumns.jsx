// ...existing code...
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/utils/currencyFormat";
import { formatDateTime } from "@/utils/formatDate";
import { useNavigate } from "react-router-dom";

const statusBadge = (s) => {
  switch (s) {
    case "SUCCESS":
      return (
        <Badge className="bg-emerald-500 hover:bg-emerald-600 text-white">
          Success
        </Badge>
      );
    case "PENDING":
      return (
        <Badge className="bg-amber-500 hover:bg-amber-600 text-white">
          Pending
        </Badge>
      );
    case "FAILED":
      return (
        <Badge className="bg-rose-500 hover:bg-rose-600 text-white">
          Failed
        </Badge>
      );
    default:
      return <Badge variant="secondary">{s || "—"}</Badge>;
  }
};

export const paymentColumns = () => [
  {
    accessorKey: "id",
    header: "ID",
    cell: ({ row }) => <span className="font-medium">#{row.original.id}</span>,
    size: 70,
  },
  {
    accessorKey: "orderCode",
    header: "Order Code",
    cell: ({ row }) => (
      <span className="font-mono text-sm">{row.original.orderCode || "—"}</span>
    ),
    size: 140,
  },
  {
    accessorKey: "member",
    header: "Member",
    cell: ({ row }) => {
      const m = row.original.member;
      const nav = useNavigate();
      return (
        <div
          className="flex flex-col cursor-pointer"
          onClick={() => nav(`/admin/manage-members/${m?.id}`)}
        >
          <span className="font-medium">
            {m?.firstName} {m?.lastName}
          </span>
          <span className="text-xs text-muted-foreground">
            Member ID: {m?.id ?? "—"}
          </span>
        </div>
      );
    },
    size: 160,
  },
  {
    accessorKey: "subscription.membershipPackage.name",
    header: "Package",
    cell: ({ row }) => (
      <span className="text-sm font-medium">
        {row.original.subscription?.membershipPackage?.name || "—"}
      </span>
    ),
    size: 120,
  },
  {
    accessorKey: "amount",
    header: "Amount",
    cell: ({ row }) => (
      <span className="font-semibold text-emerald-600">
        {formatCurrency(row.original.amount)}
      </span>
    ),
    size: 130,
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => statusBadge(row.original.status),
    size: 110,
  },
  {
    accessorKey: "createdAt",
    header: "Created",
    cell: ({ row }) => (
      <span className="text-xs">{formatDateTime(row.original.createdAt)}</span>
    ),
    size: 170,
  },
];
