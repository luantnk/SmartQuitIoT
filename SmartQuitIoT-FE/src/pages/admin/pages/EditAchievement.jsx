import CircleLoading from "@/components/loadings/CircleLoading";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import ErrorMessage from "@/components/ui/error-message";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { 
  getAchievementById, 
  updateAchievement 
} from "@/services/achievementService";
import { uploadImage } from "@/services/cloudinaryService";
import { Upload, Save, X } from "lucide-react";
import React, { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";

const ACHIEVEMENT_TYPES = [
  { value: "STREAK", label: "Streak" },
  { value: "ACTIVITY", label: "Activity" },
  { value: "FINANCE", label: "Finance" },
  { value: "SOCIAL", label: "Social" },
  { value: "PROGRESS", label: "Progress" },
];

const CONDITION_FIELDS = [
  { value: "streaks", label: "Streaks" },
  { value: "steps", label: "Steps" },
  { value: "money_saved", label: "Money Saved" },
  { value: "post_count", label: "Post Count" },
  { value: "comment_count", label: "Comment Count" },
  { value: "total_mission_completed", label: "Total Mission Completed" },
  { value: "completed_all_mission_in_day", label: "Completed All Mission In Day" },
];

const OPERATORS = [
  { value: ">=", label: ">= (Greater than or equal)" },
  { value: ">", label: "> (Greater than)" },
  { value: "=", label: "== (Equal to)" },
  { value: "<", label: "< (Less than)" },
  { value: "<=", label: "<= (Less than or equal)" },
];

const EditAchievement = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);
  const [error, setError] = useState("");
  const [iconFile, setIconFile] = useState(null);
  const [iconPreview, setIconPreview] = useState("");
  const [existingIconUrl, setExistingIconUrl] = useState("");
  const [isUploading, setIsUploading] = useState(false);

  const form = useForm({
    defaultValues: {
      name: "",
      description: "",
      icon: "",
      type: "",
      conditionField: "",
      conditionOperator: ">=",
      conditionValue: "",
    },
  });

  useEffect(() => {
    fetchAchievementData();
  }, [id]);

  const fetchAchievementData = async () => {
    try {
      setIsFetching(true);
      const response = await getAchievementById(id);
      const achievement = response.data;

      // Set form values
      form.reset({
        name: achievement.name,
        description: achievement.description,
        type: achievement.type,
        conditionField: achievement.condition?.field || "",
        conditionOperator: achievement.condition?.operator || ">=",
        conditionValue: achievement.condition?.value?.toString() || "",
      });

      // Set existing icon
      setExistingIconUrl(achievement.icon);
      setIconPreview(achievement.icon);
    } catch (error) {
      console.error("Error fetching achievement:", error);
      toast.error("Failed to load achievement data");
      navigate("/admin/manage-achievements");
    } finally {
      setIsFetching(false);
    }
  };

  const handleIconChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith("image/")) {
        toast.error("Please upload an image file");
        return;
      }
      setIconFile(file);
      const reader = new FileReader();
      reader.onload = (event) => {
        setIconPreview(event.target?.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const uploadIconToCloudinary = async () => {
    if (!iconFile) return existingIconUrl; // Keep existing icon if no new file

    setIsUploading(true);
    try {
      const formData = new FormData();
      formData.append("file", iconFile);
      formData.append("upload_preset", import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET);
      formData.append("folder", "achievements/icons");

      const response = await uploadImage(formData);
      return response.data.secure_url;
    } catch (error) {
      console.error("Error uploading icon:", error);
      toast.error("Failed to upload icon");
      return existingIconUrl; // Fallback to existing icon
    } finally {
      setIsUploading(false);
    }
  };

  const onSubmit = async (data) => {
    setIsLoading(true);
    setError("");

    try {
      // Upload icon to Cloudinary (or keep existing)
      const iconUrl = await uploadIconToCloudinary();
      if (!iconUrl) {
        toast.error("Icon URL is required");
        setIsLoading(false);
        return;
      }

      // Build condition object
      const condition = {
        field: data.conditionField,
        operator: data.conditionOperator,
        value: parseInt(data.conditionValue),
      };

      // Prepare payload
      const payload = {
        name: data.name,
        description: data.description,
        icon: iconUrl,
        type: data.type,
        condition: condition,
      };

      const response = await updateAchievement(id, payload);

      if (response.status === 200 || response.status === 201) {
        toast.success("Achievement updated successfully");
        navigate("/admin/manage-achievements");
      }
    } catch (error) {
      console.error("Error updating achievement:", error);
      setError(error?.response?.data?.message || "Failed to update achievement");
      toast.error("Failed to update achievement");
    } finally {
      setIsLoading(false);
    }
  };

  const onCancel = () => {
    navigate("/admin/manage-achievements");
  };

  if (isFetching) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <CircleLoading />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-achievements", "edit-achievement"]} />

      <Card>
        <CardHeader>
          <CardTitle>Edit Achievement</CardTitle>
          <CardDescription>
            Update achievement information. Modify the fields below and save changes.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              {/* Basic Information */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-gray-900">Basic Information</h3>
                
                <FormField
                  control={form.control}
                  name="name"
                  rules={{ required: "Achievement name is required" }}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Achievement Name *</FormLabel>
                      <FormControl>
                        <Input placeholder="Enter achievement name" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="description"
                  rules={{ required: "Description is required" }}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Description *</FormLabel>
                      <FormControl>
                        <Textarea
                          placeholder="Enter achievement description"
                          className="min-h-[100px]"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="type"
                  rules={{ required: "Achievement type is required" }}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Achievement Type *</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Select achievement type" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {ACHIEVEMENT_TYPES.map((type) => (
                            <SelectItem key={type.value} value={type.value}>
                              {type.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              {/* Icon Upload */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-gray-900">Achievement Icon</h3>
                <div className="flex flex-col gap-4">
                  <label className="flex items-center justify-center w-full px-4 py-6 border-2 border-dashed border-border rounded-lg cursor-pointer hover:bg-muted/50 transition-colors">
                    <div className="flex flex-col items-center justify-center">
                      <Upload className="w-6 h-6 text-muted-foreground mb-2" />
                      <span className="text-sm text-muted-foreground">
                        Click to upload new icon (optional)
                      </span>
                      <span className="text-xs text-muted-foreground mt-1">
                        PNG, JPG, SVG up to 5MB
                      </span>
                    </div>
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleIconChange}
                      className="hidden"
                    />
                  </label>

                  {iconPreview && (
                    <div className="flex items-center justify-center">
                      <div className="relative w-32 h-32 border-2 border-gray-200 rounded-lg overflow-hidden">
                        <img
                          src={iconPreview}
                          alt="Icon preview"
                          className="w-full h-full object-cover"
                        />
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Condition Configuration */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-gray-900">Achievement Condition</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <FormField
                    control={form.control}
                    name="conditionField"
                    rules={{ required: "Condition field is required" }}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Field *</FormLabel>
                        <Select onValueChange={field.onChange} value={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select field" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {CONDITION_FIELDS.map((condField) => (
                              <SelectItem key={condField.value} value={condField.value}>
                                {condField.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="conditionOperator"
                    rules={{ required: "Operator is required" }}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Operator *</FormLabel>
                        <Select onValueChange={field.onChange} value={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select operator" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {OPERATORS.map((op) => (
                              <SelectItem key={op.value} value={op.value}>
                                {op.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="conditionValue"
                    rules={{ 
                      required: "Value is required",
                      min: { value: 0, message: "Value must be positive" }
                    }}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Value *</FormLabel>
                        <FormControl>
                          <Input
                            type="number"
                            placeholder="Enter value"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                {/* Condition Preview */}
                {form.watch("conditionField") && form.watch("conditionValue") && (
                  <div className="p-4 bg-muted rounded-lg">
                    <p className="text-sm font-medium text-muted-foreground mb-2">
                      Condition Preview:
                    </p>
                    <code className="text-sm bg-background p-2 rounded block">
                      {JSON.stringify({
                        field: form.watch("conditionField"),
                        operator: form.watch("conditionOperator"),
                        value: parseInt(form.watch("conditionValue") || 0),
                      }, null, 2)}
                    </code>
                  </div>
                )}
              </div>

              {error && <ErrorMessage text={error} />}

              {/* Form Actions */}
              <div className="flex justify-end space-x-4 pt-6 border-t">
                {isLoading || isUploading ? (
                  <CircleLoading />
                ) : (
                  <>
                    <Button
                      type="button"
                      variant="outline"
                      onClick={onCancel}
                      className="flex items-center space-x-2"
                    >
                      <X className="h-4 w-4" />
                      <span>Cancel</span>
                    </Button>
                    <Button type="submit" className="flex items-center space-x-2">
                      <Save className="h-4 w-4" />
                      <span>Update Achievement</span>
                    </Button>
                  </>
                )}
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
};

export default EditAchievement;
