import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Trash2, Plus, X } from "lucide-react";

const FIELD_OPTIONS = [
  { value: "progress", label: "Progress" },
  { value: "craving_level_avg", label: "Average Craving Level" },
  { value: "avg_cigarettes", label: "Average Cigarettes Per Day" },
  { value: "avg_mood", label: "Average Mood" },
  { value: "avg_anxiety", label: "Average Anxiety" },
  { value: "avg_confident", label: "Average Confidence" },
];

const OPERATOR_OPTIONS = [
  { value: ">=", label: ">= (Greater than or equal)" },
  { value: "<=", label: "<= (Less than or equal)" },
  { value: ">", label: "> (Greater than)" },
  { value: "<", label: "< (Less than)" },
  { value: "=", label: "= (Equal)" },
];

const LOGIC_OPTIONS = [
  { value: "AND", label: "AND" },
  { value: "OR", label: "OR" },
];

const BASE_OPTIONS = [
  { value: "fm_cigarettes_total", label: "FM Cigarettes Total" },
  { value: "initial_cigarettes", label: "Initial Cigarettes" },
];

const FORMULA_OPERATOR_OPTIONS = [
  { value: "*", label: "* (Multiply)" },
  { value: "/", label: "/ (Divide)" },
  { value: "+", label: "+ (Add)" },
  { value: "-", label: "- (Subtract)" },
];

const RuleEditor = ({ rule, onUpdate, onDelete, depth = 0, canDelete = true }) => {
  const [localRule, setLocalRule] = useState(rule);
  const [hasFormula, setHasFormula] = useState(!!rule.formula);

  useEffect(() => {
    setLocalRule(rule);
    setHasFormula(!!rule.formula);
  }, [rule]);

  const handleChange = (field, value) => {
    const updated = { ...localRule, [field]: value };
    setLocalRule(updated);
    onUpdate(updated);
  };

  const handleFormulaChange = (field, value) => {
    const updated = {
      ...localRule,
      formula: {
        ...localRule.formula,
        [field]: value,
      },
    };
    setLocalRule(updated);
    onUpdate(updated);
  };

  const toggleFormula = () => {
    if (hasFormula) {
      // Remove formula
      const { formula, ...rest } = localRule;
      const updated = { ...rest, value: 0 };
      setLocalRule(updated);
      onUpdate(updated);
      setHasFormula(false);
    } else {
      // Add formula
      const { value, ...rest } = localRule;
      const updated = {
        ...rest,
        formula: {
          base: "fm_cigarettes_total",
          percent: 0.8,
          operator: "*",
        },
      };
      setLocalRule(updated);
      onUpdate(updated);
      setHasFormula(true);
    }
  };

  if (localRule.logic) {
    // Nested logic group
    return (
      <div className="border-l-4 border-blue-400 pl-4 py-3 my-3 bg-blue-50/50 rounded-r">
        <div className="flex items-center gap-3 mb-3 flex-wrap">
          <div className="flex items-center gap-2">
            <Badge variant="default" className="text-sm px-3 py-1">
              {localRule.logic}
            </Badge>
            <Select
              value={localRule.logic}
              onValueChange={(val) => handleChange("logic", val)}
            >
              <SelectTrigger className="w-32">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {LOGIC_OPTIONS.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {opt.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          {canDelete && (
            <Button
              variant="ghost"
              size="sm"
              onClick={onDelete}
              className="ml-auto text-red-600 hover:text-red-700 hover:bg-red-50"
            >
              <Trash2 className="h-4 w-4 mr-1" />
              Delete Group
            </Button>
          )}
        </div>
        <div className="space-y-2">
          {localRule.rules.map((subRule, idx) => (
            <RuleEditor
              key={idx}
              rule={subRule}
              depth={depth + 1}
              canDelete={localRule.rules.length > 1}
              onUpdate={(updated) => {
                const newRules = [...localRule.rules];
                newRules[idx] = updated;
                handleChange("rules", newRules);
              }}
              onDelete={() => {
                const newRules = localRule.rules.filter((_, i) => i !== idx);
                handleChange("rules", newRules);
              }}
            />
          ))}
          <div className="flex gap-2 mt-3 flex-wrap">
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const newRule = {
                  field: "progress",
                  operator: ">=",
                  value: 0,
                };
                handleChange("rules", [...localRule.rules, newRule]);
              }}
            >
              <Plus className="h-4 w-4 mr-1" /> Add Rule
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const newLogicGroup = {
                  logic: "OR",
                  rules: [
                    { field: "progress", operator: ">=", value: 0 },
                  ],
                };
                handleChange("rules", [...localRule.rules, newLogicGroup]);
              }}
            >
              <Plus className="h-4 w-4 mr-1" /> Add Logic Group
            </Button>
          </div>
        </div>
      </div>
    );
  } else {
    // Individual rule
    return (
      <div className="border-2 border-gray-200 rounded-lg p-4 my-2 bg-white hover:border-gray-300 transition-colors">
        <div className="space-y-3">
          {/* Row 1: Field and Operator */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label className="text-sm font-medium mb-2 block">Field</Label>
              <Select
                value={localRule.field}
                onValueChange={(val) => handleChange("field", val)}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {FIELD_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label className="text-sm font-medium mb-2 block">Operator</Label>
              <Select
                value={localRule.operator}
                onValueChange={(val) => handleChange("operator", val)}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {OPERATOR_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Row 2: Value or Formula fields */}
          {!hasFormula ? (
            <div>
              <Label className="text-sm font-medium mb-2 block">Value</Label>
              <Input
                type="number"
                value={localRule.value ?? ""}
                onChange={(e) => {
                  const val = e.target.value;
                  if (val === "") {
                    handleChange("value", "");
                  } else {
                    const parsed = parseFloat(val);
                    handleChange("value", isNaN(parsed) ? 0 : parsed);
                  }
                }}
                onBlur={(e) => {
                  if (e.target.value === "") {
                    handleChange("value", 0);
                  }
                }}
                className="w-full"
                placeholder="Enter value"
              />
            </div>
          ) : (
            <div className="grid grid-cols-3 gap-4">
              <div>
                <Label className="text-sm font-medium mb-2 block">
                  Base (Read-only)
                </Label>
                <Input
                  value={localRule.formula?.base || ""}
                  disabled
                  className="bg-gray-100 w-full"
                  title="Base field is read-only"
                />
              </div>
              <div>
                <Label className="text-sm font-medium mb-2 block">
                  Formula Operator
                </Label>
                <Select
                  value={localRule.formula?.operator || "*"}
                  onValueChange={(val) => handleFormulaChange("operator", val)}
                >
                  <SelectTrigger className="w-full">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {FORMULA_OPERATOR_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label className="text-sm font-medium mb-2 block">
                  Percent (0-1)
                </Label>
                <Input
                  type="number"
                  value={localRule.formula?.percent ?? ""}
                  onChange={(e) => {
                    const val = e.target.value;
                    if (val === "") {
                      handleFormulaChange("percent", "");
                    } else {
                      const parsed = parseFloat(val);
                      handleFormulaChange("percent", isNaN(parsed) ? 0 : parsed);
                    }
                  }}
                  onBlur={(e) => {
                    if (e.target.value === "") {
                      handleFormulaChange("percent", 0);
                    }
                  }}
                  className="w-full"
                  placeholder="e.g., 0.8"
                />
              </div>
            </div>
          )}

          {/* Row 3: Action buttons */}
          <div className="flex gap-2 pt-2">
            <Button
              variant="outline"
              size="sm"
              onClick={toggleFormula}
              className="text-xs whitespace-nowrap"
              title={hasFormula ? "Switch to simple value" : "Switch to formula"}
            >
              {hasFormula ? "Simple" : "Formula"}
            </Button>
            {canDelete && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onDelete}
                className="text-red-600 hover:text-red-700 hover:bg-red-50 ml-auto"
                title="Delete this rule"
              >
                <Trash2 className="h-4 w-4 mr-1" />
                Delete
              </Button>
            )}
          </div>
        </div>
      </div>
    );
  }
};

const EditPassConditionModal = ({ open, onClose, condition, onSave }) => {
  const [editedCondition, setEditedCondition] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  const [validationErrors, setValidationErrors] = useState([]);

  useEffect(() => {
    if (condition) {
      // Deep clone the condition to avoid mutating the original
      setEditedCondition(JSON.parse(JSON.stringify(condition)));
      setValidationErrors([]);
    }
  }, [condition]);

  const validateCondition = () => {
    const errors = [];
    
    const validateRule = (rule, path = "") => {
      if (rule.logic) {
        // Validate logic group
        if (!rule.rules || rule.rules.length === 0) {
          errors.push(`${path} Logic group must have at least one rule`);
        } else {
          rule.rules.forEach((subRule, idx) => {
            validateRule(subRule);
          });
        }
      } else {
        // Validate individual rule
        if (!rule.field) {
          errors.push(`${path} Field is required`);
        }
        if (!rule.operator) {
          errors.push(`${path} Operator is required`);
        }
        if (rule.formula) {
          // Validate formula
          if (!rule.formula.base) {
            errors.push(`${path} Formula base is required`);
          }
          if (rule.formula.percent === undefined || rule.formula.percent === null || rule.formula.percent === "") {
            errors.push(`${path} Formula percent is required`);
          } else {
            const percent = parseFloat(rule.formula.percent);
            if (isNaN(percent)) {
              errors.push(`${path} Formula percent must be a valid number`);
            } else if (percent < 0 || percent > 1) {
              errors.push(`${path} Formula percent must be between 0 and 1`);
            }
          }
          if (!rule.formula.operator) {
            errors.push(`${path} Formula operator is required`);
          }
        } else {
          // Validate simple value
          if (rule.value === undefined || rule.value === null || rule.value === "") {
            errors.push(`${path} Value is required`);
          } else {
            const value = parseFloat(rule.value);
            if (isNaN(value)) {
              errors.push(`${path} Value must be a valid number`);
            } else {
              // Field-specific validation
              const field = rule.field;
              const ratingFields = ["avg_mood", "avg_anxiety", "avg_confident", "craving_level_avg"];
              
              if (field === "progress") {
                if (value < 0 || value > 100) {
                  errors.push(`${path} Progress must be between 0 and 100`);
                }
              } else if (ratingFields.includes(field)) {
                if (value < 0 || value > 10) {
                  errors.push(`${path} ${field} must be between 0 and 10`);
                }
              } else if (field === "avg_cigarettes") {
                if (value < 0) {
                  errors.push(`${path} Average cigarettes must be 0 or greater`);
                }
              } else {
                if (value < 0) {
                  errors.push(`${path} Value must be 0 or greater`);
                }
              }
            }
          }
        }
      }
    };

    if (!editedCondition.condition.logic) {
      errors.push("Root logic is required");
    }
    
    if (!editedCondition.condition.rules || editedCondition.condition.rules.length === 0) {
      errors.push("At least one rule is required");
    } else {
      editedCondition.condition.rules.forEach((rule, idx) => {
        validateRule(rule, `Rule ${idx + 1}`);
      });
    }

    return errors;
  };

  const handleSave = async () => {
    // Validate before saving
    const errors = validateCondition();
    
    if (errors.length > 0) {
      setValidationErrors(errors);
      console.warn("Validation errors:", errors);
      return;
    }

    setValidationErrors([]);
    
    try {
      setIsSaving(true);
      console.log("Saving condition:", editedCondition);
      await onSave(editedCondition);
      onClose();
    } catch (error) {
      console.error("Error saving condition:", error);
    } finally {
      setIsSaving(false);
    }
  };

  if (!editedCondition) return null;

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/50" 
        onClick={onClose}
      ></div>
      
      {/* Modal Content */}
      <div className="relative bg-white rounded-lg shadow-xl w-[95vw] max-w-[1000px] max-h-[95vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              Edit Pass Condition - {condition?.name}
            </h2>
            <p className="text-sm text-gray-600 mt-1">
              Update the condition rules for this phase. You can add, remove, or modify rules and logic groups.
            </p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {/* Validation Errors */}
        {validationErrors.length > 0 && (
          <div className="mx-6 mt-4 bg-red-50 border border-red-200 rounded-lg p-4">
            <h4 className="font-semibold text-red-800 mb-2"> Please fix the following errors:</h4>
            <ul className="list-disc list-inside space-y-1">
              {validationErrors.map((error, idx) => (
                <li key={idx} className="text-red-700 text-sm">
                  {error}
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Body - Scrollable */}
        <div className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <Label className="text-base font-semibold mb-2 block">Root Logic</Label>
            <Select
              value={editedCondition.condition.logic}
              onValueChange={(val) => {
                setEditedCondition({
                  ...editedCondition,
                  condition: {
                    ...editedCondition.condition,
                    logic: val,
                  },
                });
              }}
            >
              <SelectTrigger className="w-48">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {LOGIC_OPTIONS.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {opt.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-3">
            {editedCondition.condition.rules.map((rule, idx) => (
              <RuleEditor
                key={idx}
                rule={rule}
                canDelete={editedCondition.condition.rules.length > 1}
                onUpdate={(updated) => {
                  const newRules = [...editedCondition.condition.rules];
                  newRules[idx] = updated;
                  setEditedCondition({
                    ...editedCondition,
                    condition: {
                      ...editedCondition.condition,
                      rules: newRules,
                    },
                  });
                }}
                onDelete={() => {
                  const newRules = editedCondition.condition.rules.filter(
                    (_, i) => i !== idx
                  );
                  setEditedCondition({
                    ...editedCondition,
                    condition: {
                      ...editedCondition.condition,
                      rules: newRules,
                    },
                  });
                }}
              />
            ))}
          </div>

          <div className="flex gap-3 mt-6">
            <Button
              variant="outline"
              onClick={() => {
                const newRule = {
                  field: "progress",
                  operator: ">=",
                  value: 0,
                };
                setEditedCondition({
                  ...editedCondition,
                  condition: {
                    ...editedCondition.condition,
                    rules: [...editedCondition.condition.rules, newRule],
                  },
                });
              }}
            >
              <Plus className="h-4 w-4 mr-2" /> Add Rule
            </Button>
            <Button
              variant="outline"
              onClick={() => {
                const newLogicGroup = {
                  logic: "OR",
                  rules: [{ field: "progress", operator: ">=", value: 0 }],
                };
                setEditedCondition({
                  ...editedCondition,
                  condition: {
                    ...editedCondition.condition,
                    rules: [...editedCondition.condition.rules, newLogicGroup],
                  },
                });
              }}
            >
              <Plus className="h-4 w-4 mr-2" /> Add Logic Group
            </Button>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 p-6 border-t bg-gray-50">
          <Button 
            variant="outline" 
            onClick={onClose} 
            disabled={isSaving}
            className="min-w-[100px]"
          >
            Cancel
          </Button>
          <Button 
            onClick={handleSave} 
            disabled={isSaving}
            className="min-w-[120px]"
          >
            {isSaving ? "Saving..." : "Save Changes"}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default EditPassConditionModal;
