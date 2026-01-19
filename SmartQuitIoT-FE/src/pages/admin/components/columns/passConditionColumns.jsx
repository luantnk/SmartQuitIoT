import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Pencil } from "lucide-react";
import { format } from "date-fns";

// Helper function to render condition rules recursively
const renderConditionRules = (condition) => {
  if (!condition || !condition.rules) return "N/A";
  
  const renderRule = (rule, depth = 0) => {
    const indent = "  ".repeat(depth);
    
    if (rule.logic) {
      // Nested logic group
      const subRules = rule.rules.map(r => renderRule(r, depth + 1)).join("\n");
      return `${indent}${rule.logic}:\n${subRules}`;
    } else {
      // Individual rule
      if (rule.formula) {
        return `${indent}• ${rule.field} ${rule.operator} (${rule.formula.base} ${rule.formula.operator} ${rule.formula.percent * 100}%)`;
      } else {
        return `${indent}• ${rule.field} ${rule.operator} ${rule.value}`;
      }
    }
  };
  
  const rulesText = condition.rules.map(r => renderRule(r, 0)).join("\n");
  return `${condition.logic}:\n${rulesText}`;
};

export const passConditionColumns = (handlers) => [
  {
    accessorKey: "id",
    header: "ID",
    size: 60,
  },
  {
    id: "name",
    header: "Phase Name",
    accessorFn: (row) => row.name ?? "",
    cell: ({ getValue }) => {
      const name = getValue();
      let className = "border rounded-full px-4 py-1 text-sm font-medium";
      
      switch (name) {
        case "Preparation":
          className += " border-blue-300 text-blue-700 bg-blue-50";
          break;
        case "Onset":
          className += " border-green-300 text-green-700 bg-green-50";
          break;
        case "Peak Craving":
          className += " border-orange-300 text-orange-700 bg-orange-50";
          break;
        case "Subsiding":
          className += " border-purple-300 text-purple-700 bg-purple-50";
          break;
        case "Maintenance":
          className += " border-yellow-300 text-yellow-700 bg-yellow-50";
          break;
        default:
          className += " border-gray-300 text-gray-700 bg-gray-50";
      }
      
      return <span className={className}>{name}</span>;
    },
  },
  {
    id: "condition",
    header: "Condition Rules",
    accessorFn: (row) => row.condition ?? null,
    cell: ({ getValue }) => {
      const condition = getValue();
      if (!condition) return <span className="text-gray-400">No condition</span>;
      
      const renderRuleItem = (rule, depth = 0) => {
        const marginLeft = depth * 16;
        
        if (rule.logic) {
          // Nested logic group
          return (
            <div key={Math.random()} style={{ marginLeft: `${marginLeft}px` }} className="my-1">
              <Badge variant="outline" className="mb-1">
                {rule.logic}
              </Badge>
              <div className="pl-2 border-l-2 border-gray-200">
                {rule.rules.map((r, idx) => renderRuleItem(r, depth + 1))}
              </div>
            </div>
          );
        } else {
          // Individual rule
          let ruleText = "";
          if (rule.formula) {
            ruleText = `${rule.field} ${rule.operator} (${rule.formula.base} ${rule.formula.operator} ${rule.formula.percent * 100}%)`;
          } else {
            ruleText = `${rule.field} ${rule.operator} ${rule.value}`;
          }
          
          return (
            <div key={Math.random()} style={{ marginLeft: `${marginLeft}px` }} className="text-sm text-gray-600 my-0.5">
              • {ruleText}
            </div>
          );
        }
      };
      
      return (
        <div className="py-2 max-w-md">
          <Badge variant="secondary" className="mb-2">
            {condition.logic}
          </Badge>
          <div className="pl-2 border-l-2 border-gray-300">
            {condition.rules.map((rule, idx) => renderRuleItem(rule, 0))}
          </div>
        </div>
      );
    },
  },
  {
    id: "updatedAt",
    header: "Last Updated",
    accessorFn: (row) => row.updatedAt ?? "",
    cell: ({ getValue }) => {
      const updatedAt = getValue();
      if (!updatedAt) return <span className="text-gray-400">N/A</span>;
      
      try {
        const date = new Date(updatedAt);
        return (
          <span className="text-gray-600">
            {format(date, "MMM dd, yyyy HH:mm")}
          </span>
        );
      } catch (error) {
        return <span className="text-gray-400">{updatedAt}</span>;
      }
    },
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => (
      <Button
        variant="outline"
        size="sm"
        onClick={() => handlers?.onEdit(row)}
        className="gap-2"
      >
        <Pencil className="h-4 w-4" />
        Edit Pass Condition
      </Button>
    ),
    size: 120,
    enableHiding: false,
  },
];
