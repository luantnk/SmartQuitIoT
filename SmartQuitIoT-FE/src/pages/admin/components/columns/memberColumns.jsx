import ActionMenu from "@/components/ui/action-menu";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { User, UserCircle } from "lucide-react";
import { useNavigate } from "react-router-dom";

export const memberColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    id: "member",
    header: "Member",
    accessorFn: (row) => `${row.firstName ?? ""} ${row.lastName ?? ""}`.trim(),
    cell: ({ row, getValue }) => {
      const name = getValue();
      const avatar = row.original.avatarUrl;
      const nav = useNavigate();
      return (
        <div
          className="flex items-center gap-3 cursor-pointer"
          onClick={() => nav(`/admin/manage-members/${row.original.id}`)}
        >
          <Avatar>
            <AvatarImage src={avatar} alt={name} />
            <AvatarFallback>{name}</AvatarFallback>
          </Avatar>
          <div className="flex flex-col">
            <span className="font-medium">{name || "—"}</span>
            <span className="text-xs text-muted-foreground">
              Account ID: {row.original.account?.id}
            </span>
          </div>
        </div>
      );
    },
  },
  {
    id: "gender",
    header: "Gender",
    accessorFn: (row) => row.gender ?? "",
    cell: ({ getValue }) => {
      const g = (getValue() || "").toString().toUpperCase();

      if (g === "MALE") {
        return (
          <div className="flex items-center gap-2">
            <div className="flex items-center justify-center w-8 h-8 rounded-full bg-blue-100">
              <User className="w-4 h-4 text-blue-700" />
            </div>
          </div>
        );
      }

      if (g === "FEMALE") {
        return (
          <div className="flex items-center gap-2">
            <div className="flex items-center justify-center w-8 h-8 rounded-full bg-pink-100">
              <User className="w-4 h-4 text-pink-700" />
            </div>
          </div>
        );
      }

      return (
        <div className="flex items-center gap-2">
          <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gray-100">
            <UserCircle className="w-4 h-4 text-gray-500" />
          </div>
          <span className="text-sm text-gray-500">—</span>
        </div>
      );
    },
  },
  {
    id: "email",
    header: "Email",
    accessorFn: (row) => row?.account?.email ?? "",
    cell: ({ getValue }) => {
      const email = getValue();
      return email ? (
        <span className="inline-flex items-center gap-1 text-gray-600 hover:underline">
          {email}
        </span>
      ) : (
        <span className="text-muted-foreground">—</span>
      );
    },
  },
  {
    id: "username",
    header: "Username",
    accessorFn: (row) => row?.account?.username ?? "",
  },

  // Role (nested)
  {
    id: "role",
    header: "Role",
    accessorFn: (row) => row?.account?.role ?? "",
    cell: ({ getValue }) => {
      const role = getValue();
      return (
        <Badge
          variant="primary"
          className="bg-white text-[#00d09e] border-[#00d09e]"
        >
          {role || "—"}
        </Badge>
      );
    },
  },
  {
    id: "accountType",
    header: "Type",
    accessorFn: (row) => row?.account?.accountType ?? "",
    cell: ({ getValue }) => {
      const accountType = getValue();
      return (
        <Badge
          variant="primary"
          className="bg-white text-[#00d09e] border-[#00d09e]"
        >
          {accountType || "—"}
        </Badge>
      );
    },
  },
  {
    id: "isActive",
    header: "Active",
    accessorFn: (row) => row?.account?.isActive ?? "",
    cell: ({ getValue }) => {
      const isActive = getValue();
      return (
        <>{isActive ? <Badge variant="" /> : <Badge variant="destructive" />}</>
      );
    },
  },
  {
    id: "isBanned",
    header: "Banned",
    accessorFn: (row) => row?.account?.isBanned ?? "",
    cell: ({ getValue }) => {
      const isBanned = getValue();
      return (
        <>{isBanned ? <Badge variant="" /> : <Badge variant="destructive" />}</>
      );
    },
  },
  {
    id: "createdAt",
    header: "Created At",
    accessorFn: (row) => row?.account?.createdAt ?? "",
    cell: ({ getValue }) => {
      const createdAt = getValue();
      return (
        <Badge
          variant="primary"
          className="bg-white text-[#00d09e] border-[#00d09e]"
        >
          {createdAt ? new Date(createdAt).toLocaleDateString() : "—"}
        </Badge>
      );
    },
  },
  {
    id: "actions",
    header: "",
    cell: ({ row }) => (
      <>
        {row.original.account?.isActive === true ? (
          <ActionMenu
            row={row}
            onEdit={handlers?.onEdit}
            onDelete={handlers?.onDelete}
            editMessage="View Detail"
          />
        ) : (
          <ActionMenu
            row={row}
            onEdit={handlers?.onEdit}
            editMessage="View Detail"
          />
        )}
      </>
    ),
    size: 48, // optional
    enableHiding: false,
  },
];
