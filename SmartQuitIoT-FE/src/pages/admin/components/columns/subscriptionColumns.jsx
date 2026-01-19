import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/utils/currencyFormat";
import { formatDate, formatDateTime } from "@/utils/formatDate";
import { useNavigate } from "react-router-dom";

const getStatusBadge = (status) => {
  switch (status) {
    case "AVAILABLE":
      return (
        <Badge className="bg-emerald-500 hover:bg-emerald-600">Available</Badge>
      );
    case "EXPIRED":
      return <Badge variant="secondary">Expired</Badge>;
    case "UNAVAILABLE":
      return <Badge className="bg-red-500 hover:bg-red-600">Unavailable</Badge>;
    default:
      return <Badge variant="outline">{status}</Badge>;
  }
};

const getPackageTypeBadge = (type) => {
  switch (type) {
    case "TRIAL":
      return (
        <Badge
          variant="outline"
          className="bg-blue-50 text-blue-700 border-blue-200"
        >
          Trial
        </Badge>
      );
    case "PREMIUM":
      return (
        <Badge className="bg-purple-500 hover:bg-purple-600">Premium</Badge>
      );
    case "BASIC":
      return <Badge variant="secondary">Basic</Badge>;
    default:
      return <Badge variant="outline">{type}</Badge>;
  }
};

export const subscriptionColumns = () => [
  {
    accessorKey: "id",
    header: "ID",
    size: 80,
    cell: ({ row }) => <div className="font-medium">#{row.original.id}</div>,
  },
  {
    accessorKey: "member",
    header: "Member",
    size: 250,
    cell: ({ row }) => {
      const member = row.original.member;
      const nav = useNavigate();
      return (
        <div
          className="flex items-center gap-3 cursor-pointer"
          onClick={() => nav(`/admin/manage-members/${member?.id}`)}
        >
          <Avatar className="h-10 w-10">
            <AvatarImage
              src={member?.avatarUrl}
              alt={`${member?.firstName} ${member?.lastName}`}
            />
            <AvatarFallback>
              {member?.firstName?.[0]}
              {member?.lastName?.[0]}
            </AvatarFallback>
          </Avatar>
          <div>
            <div className="font-medium">
              {member?.firstName} {member?.lastName}
            </div>
            <div className="text-xs text-muted-foreground">
              {member?.account?.email}
            </div>
          </div>
        </div>
      );
    },
  },
  {
    accessorKey: "membershipPackage",
    header: "Package",
    size: 200,
    cell: ({ row }) => {
      const pkg = row.original.membershipPackage;
      return (
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="font-medium">{pkg?.name}</span>
            {getPackageTypeBadge(pkg?.type)}
          </div>
          <div className="text-xs text-muted-foreground">
            {pkg?.duration} {pkg?.durationUnit?.toLowerCase()}
          </div>
        </div>
      );
    },
  },
  {
    accessorKey: "status",
    header: "Status",
    size: 120,
    cell: ({ row }) => getStatusBadge(row.original.status),
  },
  {
    accessorKey: "startDate",
    header: "Start Date",
    size: 120,
    cell: ({ row }) => (
      <div className="text-sm">{formatDate(row.original.startDate)}</div>
    ),
  },
  {
    accessorKey: "endDate",
    header: "End Date",
    size: 120,
    cell: ({ row }) => (
      <div className="text-sm">{formatDate(row.original.endDate)}</div>
    ),
  },
  {
    accessorKey: "totalAmount",
    header: "Amount",
    size: 140,
    cell: ({ row }) => (
      <div className="font-semibold text-emerald-600">
        {formatCurrency(row.original.totalAmount)}
      </div>
    ),
  },
  {
    accessorKey: "orderCode",
    header: "Order Code",
    size: 120,
    cell: ({ row }) => (
      <div className="font-mono text-sm">{row.original.orderCode || "N/A"}</div>
    ),
  },
  {
    accessorKey: "createdAt",
    header: "Created At",
    size: 160,
    cell: ({ row }) => (
      <div className="text-sm">{formatDateTime(row.original.createdAt)}</div>
    ),
  },
];
