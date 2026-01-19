import ActionMenu from "@/components/ui/action-menu";
import { Badge } from "@/components/ui/badge";

export const missionsColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    id: "code",
    header: "Code",
    accessorFn: (row) => row.code ?? "",
    cell: ({ getValue }) => {
      const code = getValue();
      return <span className="font-medium">{code}</span>;
    },
  },
  {
    id: "name",
    header: "Name",
    accessorFn: (row) => row.name ?? "",
    cell: ({ getValue }) => {
      const name = getValue();
      return <span className="text-gray-600">{name}</span>;
    },
  },
  {
    id: "phase",
    header: "Phase",
    accessorFn: (row) => row.phase ?? "",
    cell: ({ getValue }) => {
      const phase = getValue();
      var className = "";
      if (phase === "PREPARATION") {
        className =
          "border border-blue-300 rounded-full px-4 text-sm text-blue-700 py-0.5";
      } else if (phase === "ONSET") {
        className =
          "border border-green-300 rounded-full px-4 text-sm text-green-700 py-0.5";
      } else if (phase === "PEAK_CRAVING") {
        className =
          "border border-gray-300 rounded-full px-4 text-sm text-gray-700 py-0.5";
      } else if (phase === "SUBSIDING") {
        className =
          "border border-purple-300 rounded-full px-4 text-sm text-purple-700 py-0.5";
      } else if (phase === "MAINTENANCE") {
        className =
          "border border-yellow-300 rounded-full px-4 text-sm text-yellow-700 py-0.5";
      }

      return <span className={className}>{phase}</span>;
    },
  },
  {
    id: "type",
    header: "Mission Type",
    accessorFn: (row) => row.missionType?.name ?? "",
    cell: ({ getValue }) => {
      const type = getValue();
      return <span className="text-gray-600">{type}</span>;
    },
  },
  {
    id: "interestCategory",
    header: "Interest Category",
    accessorFn: (row) => row.interestCategory?.name ?? null,
    cell: ({ getValue }) => {
      const category = getValue();
      return category ? (
        <span className="text-gray-600">{category}</span>
      ) : (
        <span className="text-gray-400 italic">All Interests</span>
      );
    },
  },
  {
    id: "status",
    header: "Status",
    accessorFn: (row) => row.status ?? "",
    cell: ({ getValue }) => {
      const status = getValue();
      const statusColors = {
        ACTIVE: "bg-green-100 text-green-700 border-green-300",
        INACTIVE: "bg-gray-100 text-gray-700 border-gray-300",
      };
      return (
        <Badge className={`${statusColors[status] || "bg-gray-100 text-gray-700"}`}>
          {status || "—"}
        </Badge>
      );
    },
  },
  {
    id: "condition",
    header: "Condition",
    accessorFn: (row) => row.condition ?? null,
    cell: ({ getValue }) => {
      const condition = getValue();
      if (!condition) return <span className="text-gray-400">—</span>;
      
      // Handle new condition format with logic and rules
      if (condition.logic && condition.rules) {
        const formatRules = (rules) => {
          return rules.map((rule, index) => {
            if (rule.logic && rule.rules) {
              return `${rule.logic}(${formatRules(rule.rules)})`;
            }
            return `${rule.field} ${rule.operator} ${String(rule.value)}`;
          }).join(', ');
        };
        
        return (
          <div className="text-xs text-gray-700 max-w-xs">
            <span className="font-semibold text-blue-600">{condition.logic}: </span>
            <span className="font-mono">{formatRules(condition.rules)}</span>
          </div>
        );
      }
      
      // Handle old simple condition format
      const { field, operator, value } = condition;
      if (!field || !operator || value === undefined) {
        return <span className="text-gray-400 text-xs">Invalid format</span>;
      }
      
      return (
        <span className="text-xs text-gray-600 font-mono">
          {field} {operator} {String(value)}
        </span>
      );
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
