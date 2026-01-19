import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useForm, useFieldArray } from "react-hook-form";
import { ArrowLeft, Plus, Trash2 } from "lucide-react";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { getAllInterestCategories } from "@/services/interestCategoryService";
import { getAllMissionTypes } from "@/services/missionTypeService";
import { getMissionById, updateMission } from "@/services/missionService";
import { toast } from "sonner";
import AppLoading from "@/components/loadings/AppLoading";

const PHASES = [
  "PREPARATION",
  "ONSET",
  "PEAK_CRAVING",
  "SUBSIDING",
  "MAINTENANCE",
];

const CONDITION_FIELDS = [
  { value: "avg_confident_level", label: "Avg Confident Level", type: "number" },
  { value: "avg_craving_level", label: "Avg Craving Level", type: "number" },
  { value: "avg_mood", label: "Avg Mood", type: "number" },
  { value: "avg_anxiety", label: "Avg Anxiety", type: "number" },
  { value: "streaks", label: "Streaks", type: "number" },
  // { value: "relapse_count_in_phase", label: "Relapse Count In Phase", type: "number" },
  { value: "use_nrt", label: "Use NRT", type: "boolean" },
  { value: "morning_smoking_frequency", label: "Morning Smoking Frequency", type: "boolean" },
  { value: "avg_in_take_nicotine_per_day", label: "Avg In Take Nicotine Per Day", type: "number" },
  { value: "minutes_after_waking_to_smoke", label: "Minutes After Waking To Smoke", type: "number" },
  { value: "smoke_avg_per_day", label: "Smoke Avg Per Day", type: "number" },
  { value: "mt_smoke_avg_per_day", label: "MT Smoke Avg Per Day", type: "number" },
  { value: "steps", label: "Steps", type: "number" },
  { value: "heart_rate", label: "Heart Rate", type: "number" },
  { value: "spo2", label: "SpO2", type: "number" },
  { value: "sleep_duration", label: "Sleep Duration", type: "number" },
];

const OPERATORS = [
  { value: "=", label: "=" },
  { value: "!=", label: "!=" },
  { value: ">", label: ">" },
  { value: ">=", label: ">=" },
  { value: "<", label: "<" },
  { value: "<=", label: "<=" },
];

const EditMission = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [interestCategories, setInterestCategories] = useState([]);
  const [missionTypes, setMissionTypes] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  const {
    register,
    control,
    handleSubmit,
    watch,
    setValue,
    reset,
    formState: { errors },
  } = useForm({
    defaultValues: {
      code: "",
      name: "",
      description: "",
      phase: "PREPARATION",
      status: "ACTIVE",
      exp: 100,
      missionTypeId: "",
      interestCategoryId: "",
      conditionLogic: "AND",
      rules: [{ field: "avg_confident_level", operator: "=", value: "0", valueType: "number" }],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: "rules",
  });

  useEffect(() => {
    fetchData();
  }, [id]);

  const fetchData = async () => {
    try {
      setIsFetching(true);
      const [categoriesRes, typesRes, missionRes] = await Promise.all([
        getAllInterestCategories(),
        getAllMissionTypes(),
        getMissionById(id),
      ]);
      
      const categories = categoriesRes.data || [];
      const types = typesRes.data || [];
      setInterestCategories(categories);
      setMissionTypes(types);

      // Parse mission data
      const mission = missionRes.data || missionRes;
      
      // Parse condition if it's a string
      let condition = mission.condition;
      if (condition && typeof condition === 'string') {
        try {
          condition = JSON.parse(condition);
        } catch (e) {
          console.error("Failed to parse condition:", e);
          condition = null;
        }
      }

      // Populate form with mission data
      reset({
        code: mission.code,
        name: mission.name,
        description: mission.description || "",
        phase: mission.phase,
        status: mission.status,
        exp: mission.exp,
        missionTypeId: mission.missionType?.id?.toString() || "",
        interestCategoryId: mission.interestCategory?.id?.toString() || null,
        conditionLogic: condition?.logic || "AND",
        rules: condition?.rules?.length > 0 ? condition.rules.map(rule => ({
          field: rule.field,
          operator: rule.operator,
          value: String(rule.value),
          valueType: typeof rule.value === "boolean" ? "boolean" : "number"
        })) : [],
      });
    } catch (error) {
      console.error("Error fetching data:", error);
      toast.error("Failed to load mission data");
      navigate("/admin/manage-missions");
    } finally {
      setIsFetching(false);
    }
  };

  const onSubmit = async (data) => {
    try {
      setIsLoading(true);
      
      // Build condition object or set to null if no rules
      let conditionString = null;
      if (data.rules && data.rules.length > 0) {
        const condition = {
          logic: data.conditionLogic,
          rules: data.rules.map((rule) => {
            let value = rule.value;
            
            // Convert value based on field type
            const fieldInfo = CONDITION_FIELDS.find(f => f.value === rule.field);
            if (fieldInfo) {
              if (fieldInfo.type === "boolean") {
                value = value === "true" || value === true;
              } else if (fieldInfo.type === "number") {
                value = parseFloat(value);
              }
            }
            
            return {
              field: rule.field,
              operator: rule.operator,
              value: value,
            };
          }),
        };
        conditionString = JSON.stringify(condition);
      }

      const payload = {
        code: data.code,
        name: data.name,
        description: data.description,
        phase: data.phase,
        status: data.status,
        exp: parseInt(data.exp),
        missionTypeId: parseInt(data.missionTypeId),
        interestCategoryId: (data.interestCategoryId && parseInt(data.interestCategoryId) !== 1) ? parseInt(data.interestCategoryId) : null,
        condition: conditionString,
      };

      await updateMission(id, payload);
      toast.success("Mission updated successfully!");
      navigate("/admin/manage-missions");
    } catch (error) {
      console.error("Error updating mission:", error);
      
      // Check for duplicate code error
      if (error.response?.status === 409 || 
          error.response?.data?.message?.includes("code") ||
          error.response?.data?.message?.includes("duplicate")) {
        toast.error("Mission code already exists. Please use a different code.");
      } else if (error.response?.data?.message) {
        toast.error(error.response.data.message);
      } else {
        toast.error("Failed to update mission");
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleFieldChange = (index, field) => {
    const fieldInfo = CONDITION_FIELDS.find((f) => f.value === field);
    if (fieldInfo) {
      setValue(`rules.${index}.valueType`, fieldInfo.type);
      setValue(`rules.${index}.value`, fieldInfo.type === "boolean" ? "true" : "");
    }
  };

  if (isFetching) {
    return <AppLoading />;
  }

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-missions", "edit"]} />

      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          size="icon"
          onClick={() => navigate("/admin/manage-missions")}
        >
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <h1 className="text-2xl font-bold">Edit Mission</h1>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Basic Information */}
        <Card>
          <CardHeader>
            <CardTitle>Basic Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="code">
                  Code <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="code"
                  {...register("code", { required: "Code is required" })}
                  placeholder="e.g., PREP_LEARN_NRT"
                />
                {errors.code && (
                  <p className="text-sm text-red-500">{errors.code.message}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="name">
                  Name <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="name"
                  {...register("name", { required: "Name is required" })}
                  placeholder="Mission name"
                />
                {errors.name && (
                  <p className="text-sm text-red-500">{errors.name.message}</p>
                )}
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                {...register("description")}
                placeholder="Mission description"
                rows={3}
              />
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="phase">
                  Phase <span className="text-red-500">*</span>
                </Label>
                <Select 
                  value={watch("phase")}
                  onValueChange={(value) => setValue("phase", value)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select phase" />
                  </SelectTrigger>
                  <SelectContent>
                    {PHASES.map((phase) => (
                      <SelectItem key={phase} value={phase}>
                        {phase}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {errors.phase && (
                  <p className="text-sm text-red-500">{errors.phase.message}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="status">Status</Label>
                <Select
                  value={watch("status")}
                  onValueChange={(value) => setValue("status", value)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ACTIVE">ACTIVE</SelectItem>
                    <SelectItem value="INACTIVE">INACTIVE</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="exp">EXP</Label>
                <Input
                  id="exp"
                  type="number"
                  min="0"
                  {...register("exp")}
                  defaultValue={100}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Mission Type & Interest Category */}
        <Card>
          <CardHeader>
            <CardTitle>Mission Type & Category</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="missionTypeId">
                  Mission Type <span className="text-red-500">*</span>
                </Label>
                <Select 
                  value={watch("missionTypeId")}
                  onValueChange={(value) => setValue("missionTypeId", value)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select mission type" />
                  </SelectTrigger>
                  <SelectContent>
                    {missionTypes.map((type) => (
                      <SelectItem key={type.id} value={type.id.toString()}>
                        {type.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {errors.missionTypeId && (
                  <p className="text-sm text-red-500">
                    {errors.missionTypeId.message}
                  </p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="interestCategoryId">
                  Interest Category (Optional)
                </Label>
                <Select
                  value={watch("interestCategoryId") || "null"}
                  onValueChange={(value) => setValue("interestCategoryId", value === "null" ? null : value)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {interestCategories.map((cat) => (
                      <SelectItem key={cat.id} value={cat.id.toString()}>
                        {cat.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Condition Builder */}
        <Card>
          <CardHeader>
            <CardTitle>Condition Rules</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Logic Operator</Label>
              <Select
                value={watch("conditionLogic")}
                onValueChange={(value) => setValue("conditionLogic", value)}
              >
                <SelectTrigger className="w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="AND">AND</SelectItem>
                  <SelectItem value="OR">OR</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {fields.length === 0 && (
              <div className="text-center py-6 text-gray-500 bg-gray-50 rounded-lg border-2 border-dashed">
                No condition rules. Click "Add Rule" to create conditions.
              </div>
            )}

            <div className="space-y-3">
              {fields.map((field, index) => {
                const selectedField = watch(`rules.${index}.field`);
                const fieldInfo = CONDITION_FIELDS.find(
                  (f) => f.value === selectedField
                );

                return (
                  <div
                    key={field.id}
                    className="flex items-start gap-3 p-4 border rounded-lg bg-gray-50"
                  >
                    <div className="flex-1 grid grid-cols-3 gap-3">
                      {/* Field Selection */}
                      <div className="space-y-2">
                        <Label>Field</Label>
                        <Select
                          value={watch(`rules.${index}.field`)}
                          onValueChange={(value) => {
                            setValue(`rules.${index}.field`, value);
                            handleFieldChange(index, value);
                          }}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select field" />
                          </SelectTrigger>
                          <SelectContent>
                            {CONDITION_FIELDS.map((f) => (
                              <SelectItem key={f.value} value={f.value}>
                                {f.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>

                      {/* Operator Selection */}
                      <div className="space-y-2">
                        <Label>Operator</Label>
                        <Select
                          value={watch(`rules.${index}.operator`)}
                          onValueChange={(value) =>
                            setValue(`rules.${index}.operator`, value)
                          }
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {OPERATORS.map((op) => (
                              <SelectItem key={op.value} value={op.value}>
                                {op.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>

                      {/* Value Input */}
                      <div className="space-y-2">
                        <Label>Value</Label>
                        {fieldInfo?.type === "boolean" ? (
                          <Select
                            value={watch(`rules.${index}.value`) || "true"}
                            onValueChange={(value) =>
                              setValue(`rules.${index}.value`, value)
                            }
                          >
                            <SelectTrigger>
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="true">True</SelectItem>
                              <SelectItem value="false">False</SelectItem>
                            </SelectContent>
                          </Select>
                        ) : (
                          <Input
                            type="number"
                            step="any"
                            min="0"
                            {...register(`rules.${index}.value`)}
                            placeholder="Enter value"
                          />
                        )}
                      </div>
                    </div>

                    {/* Remove Button */}
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon"
                      className="mt-8"
                      onClick={() => remove(index)}
                    >
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </div>
                );
              })}
            </div>

            <Button
              type="button"
              variant="outline"
              onClick={() =>
                append({ field: "avg_confident_level", operator: "=", value: "0", valueType: "number" })
              }
              className="w-full"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add Rule
            </Button>
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-3">
          <Button
            type="button"
            variant="outline"
            onClick={() => navigate("/admin/manage-missions")}
          >
            Cancel
          </Button>
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Updating..." : "Update Mission"}
          </Button>
        </div>
      </form>
    </div>
  );
};

export default EditMission;
