// src/pages/coach/ProfileSettingPage.jsx
import React, { useEffect, useState, useCallback } from "react";
import { useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  getAuthenticatedCoach,
  updateCoachProfile,
} from "@/services/coachService";
import { uploadUnsigned } from "@/services/uploadService";
import useToast from "@/hooks/useToast";
import { Save, Upload, User, FileText, Award, Briefcase } from "lucide-react";
import CircleLoading from "@/components/loadings/CircleLoading";

const ProfileSettingPage = () => {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [coachData, setCoachData] = useState(null);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [uploadingCertificate, setUploadingCertificate] = useState(false);
  const [avatarError, setAvatarError] = useState(false);
  // Local state for immediate preview updates
  const [avatarUrl, setAvatarUrl] = useState("");
  const [certificateUrl, setCertificateUrl] = useState("");

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
  } = useForm({
    defaultValues: {
      firstName: "",
      lastName: "",
      avatarUrl: "",
      certificateUrl: "",
      bio: "",
      experienceYears: 0,
      specializations: "",
    },
  });

  const fetchCoachProfile = useCallback(async () => {
    setFetching(true);
    try {
      const response = await getAuthenticatedCoach();
      if (response?.status === 200) {
        const data = response.data;
        setCoachData(data);
        setValue("firstName", data.firstName || "");
        setValue("lastName", data.lastName || "");
        const avatar = data.avatarUrl || "";
        const certificate = data.certificateUrl || "";
        setValue("avatarUrl", avatar);
        setValue("certificateUrl", certificate);
        // Update local state for immediate preview
        setAvatarUrl(avatar);
        setCertificateUrl(certificate);
        setAvatarError(false); // Reset error state when loading new data
        setValue("bio", data.bio || "");
        setValue("experienceYears", data.experienceYears || 0);
        setValue("specializations", data.specializations || "");
      }
    } catch (error) {
      console.error("Failed to fetch coach profile:", error);
      toast.error("Failed to load profile. Please try again.");
    } finally {
      setFetching(false);
    }
  }, [setValue, toast]);

  useEffect(() => {
    fetchCoachProfile();
  }, [fetchCoachProfile]);

  // Auto-save avatar to database
  const autoSaveAvatar = async (avatarUrlValue) => {
    if (!coachData?.id) {
      console.warn("Cannot auto-save: Coach ID not found");
      return;
    }

    try {
      const currentFormData = watch(); // Get current form values
      // Use the passed value directly (null for remove, URL for upload)
      // Convert empty string to null for proper deletion
      const finalAvatarUrl = avatarUrlValue === "" ? null : (avatarUrlValue || null);
      
      const response = await updateCoachProfile(coachData.id, {
        firstName: currentFormData.firstName || coachData.firstName,
        lastName: currentFormData.lastName || coachData.lastName,
        avatarUrl: finalAvatarUrl,
        certificateUrl: currentFormData.certificateUrl || coachData.certificateUrl || null,
        bio: currentFormData.bio || coachData.bio || null,
        experienceYears: currentFormData.experienceYears || coachData.experienceYears || 0,
        specializations: currentFormData.specializations || coachData.specializations || null,
      });

      if (response?.status === 200) {
        // Refresh profile data to get latest from server
        await fetchCoachProfile();
        console.log("Avatar auto-saved successfully");
      }
    } catch (error) {
      console.error("Failed to auto-save avatar:", error);
      // Don't show error toast for auto-save, just log it
      // User can still manually save later
    }
  };

  // Auto-save certificate to database
  const autoSaveCertificate = async (certificateUrlValue) => {
    if (!coachData?.id) {
      console.warn("Cannot auto-save: Coach ID not found");
      return;
    }

    try {
      const currentFormData = watch(); // Get current form values
      // Use the passed value directly (null for remove, URL for upload)
      // Convert empty string to null for proper deletion
      const finalCertificateUrl = certificateUrlValue === "" ? null : (certificateUrlValue || null);
      
      const response = await updateCoachProfile(coachData.id, {
        firstName: currentFormData.firstName || coachData.firstName,
        lastName: currentFormData.lastName || coachData.lastName,
        avatarUrl: currentFormData.avatarUrl || coachData.avatarUrl || null,
        certificateUrl: finalCertificateUrl,
        bio: currentFormData.bio || coachData.bio || null,
        experienceYears: currentFormData.experienceYears || coachData.experienceYears || 0,
        specializations: currentFormData.specializations || coachData.specializations || null,
      });

      if (response?.status === 200) {
        // Refresh profile data to get latest from server
        await fetchCoachProfile();
        console.log("Certificate auto-saved successfully");
      }
    } catch (error) {
      console.error("Failed to auto-save certificate:", error);
      // Don't show error toast for auto-save, just log it
      // User can still manually save later
    }
  };

  const handleAvatarUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith("image/")) {
      toast.error("Please select an image file");
      e.target.value = "";
      return;
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      toast.error("Image size must be less than 10MB");
      e.target.value = "";
      return;
    }

    setUploadingAvatar(true);
    try {
      const result = await uploadUnsigned(file, { folder: "coaches/avatars" });
      console.log("Upload result:", result);
      
      const imageUrl = result.secure_url || result.url;
      if (!imageUrl) {
        console.error("No URL in upload result:", result);
        throw new Error("No URL returned from upload");
      }
      
      // Update both form value and local state for immediate preview
      setValue("avatarUrl", imageUrl, { shouldValidate: true });
      setAvatarUrl(imageUrl); // Update local state for immediate preview
      // Update coachData state immediately for preview
      setCoachData((prev) => ({ ...prev, avatarUrl: imageUrl }));
      setAvatarError(false); // Reset error state on new upload
      toast.success("Avatar uploaded successfully");
      
      // Auto-save to database
      await autoSaveAvatar(imageUrl);
    } catch (error) {
      console.error("Avatar upload failed:", error);
      const errorMessage = error?.message || error?.raw?.error?.message || "Failed to upload avatar";
      toast.error(errorMessage);
    } finally {
      setUploadingAvatar(false);
      // Reset input to allow re-uploading the same file
      e.target.value = "";
    }
  };


  const handleCertificateUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type - only images allowed
    if (!file.type.startsWith("image/")) {
      toast.error("Please select an image file");
      e.target.value = "";
      return;
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      toast.error("File size must be less than 10MB");
      e.target.value = "";
      return;
    }

    setUploadingCertificate(true);
    try {
      const result = await uploadUnsigned(file, {
        folder: "coaches/certificates",
      });
      console.log("Certificate upload result:", result);
      
      const fileUrl = result.secure_url || result.url;
      if (!fileUrl) {
        console.error("No URL in upload result:", result);
        throw new Error("No URL returned from upload");
      }
      
      // Update both form value and local state for immediate preview
      setValue("certificateUrl", fileUrl, { shouldValidate: true });
      setCertificateUrl(fileUrl); // Update local state for immediate preview
      // Update coachData state immediately for preview
      setCoachData((prev) => ({ ...prev, certificateUrl: fileUrl }));
      toast.success("Certificate uploaded successfully");
      
      // Auto-save to database
      await autoSaveCertificate(fileUrl);
    } catch (error) {
      console.error("Certificate upload failed:", error);
      const errorMessage = error?.message || error?.raw?.error?.message || "Failed to upload certificate";
      toast.error(errorMessage);
    } finally {
      setUploadingCertificate(false);
      // Reset input to allow re-uploading the same file
      e.target.value = "";
    }
  };


  const onSubmit = async (data) => {
    if (!coachData?.id) {
      toast.error("Coach ID not found");
      return;
    }

    setLoading(true);
    try {
      // Use local state as fallback to ensure we have the latest values
      const finalAvatarUrl = data.avatarUrl || avatarUrl || null;
      const finalCertificateUrl = data.certificateUrl || certificateUrl || null;
      
      const response = await updateCoachProfile(coachData.id, {
        firstName: data.firstName,
        lastName: data.lastName,
        avatarUrl: finalAvatarUrl,
        certificateUrl: finalCertificateUrl,
        bio: data.bio || null,
        experienceYears: parseInt(data.experienceYears) || 0,
        specializations: data.specializations || null,
      });

      if (response?.status === 200) {
        toast.success("Profile updated successfully");
        // Refresh profile data
        await fetchCoachProfile();
      }
    } catch (error) {
      console.error("Failed to update profile:", error);
      const errorMessage =
        error?.response?.data?.message || "Failed to update profile";
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  if (fetching) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <CircleLoading />
      </div>
    );
  }

  return (
    <div className="px-10 min-h-screen">
      <div className="max-w-8xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Profile Settings
          </h1>
          <p className="text-gray-600">
            Manage your profile information and preferences
          </p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)}>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Left Column - 2 Cards stacked vertically */}
            <div className="lg:col-span-2 space-y-6">
              {/* Personal Information Card */}
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-2">
                    <User className="w-5 h-5 text-emerald-600" />
                    <CardTitle>Personal Information</CardTitle>
                  </div>
                  <CardDescription>
                    Update your personal details and profile picture
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Avatar Upload */}
                  <div className="flex items-start gap-6">
                    <div className="flex-shrink-0">
                      <div className="relative">
                        <div className="w-32 h-32 rounded-full overflow-hidden border-4 border-emerald-100 bg-gray-100 relative">
                          {avatarUrl && !avatarError ? (
                            <img
                              key={avatarUrl} // Force re-render when URL changes
                              src={avatarUrl}
                              alt="Avatar"
                              className="w-full h-full object-cover"
                              onError={() => {
                                setAvatarError(true);
                              }}
                              onLoad={() => {
                                setAvatarError(false);
                              }}
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-emerald-400 to-teal-500 text-white text-3xl font-bold">
                              {coachData?.firstName?.charAt(0) ||
                                coachData?.lastName?.charAt(0) ||
                                "C"}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                    <div className="flex-1">
                      <Label htmlFor="avatar-upload" className="mb-2 block">
                        Profile Picture
                      </Label>
                      <div className="flex items-center gap-3">
                        <label
                          htmlFor="avatar-upload"
                          className="cursor-pointer inline-flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors"
                        >
                          <Upload className="w-4 h-4" />
                          {uploadingAvatar ? "Uploading..." : "Upload Avatar"}
                        </label>
                        <input
                          id="avatar-upload"
                          type="file"
                          accept="image/*"
                          onChange={handleAvatarUpload}
                          className="hidden"
                          disabled={uploadingAvatar}
                        />
                      </div>
                      <p className="text-sm text-gray-500 mt-2">
                        Recommended: Square image, at least 400x400px
                      </p>
                    </div>
                  </div>

                  {/* Name Fields */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="firstName">
                        First Name <span className="text-red-500">*</span>
                      </Label>
                      <Input
                        id="firstName"
                        placeholder="Enter first name"
                        {...register("firstName", {
                          required: "First name is required",
                        })}
                        className={errors.firstName ? "border-red-500" : ""}
                      />
                      {errors.firstName && (
                        <p className="text-sm text-red-500">
                          {errors.firstName.message}
                        </p>
                      )}
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="lastName">
                        Last Name <span className="text-red-500">*</span>
                      </Label>
                      <Input
                        id="lastName"
                        placeholder="Enter last name"
                        {...register("lastName", {
                          required: "Last name is required",
                        })}
                        className={errors.lastName ? "border-red-500" : ""}
                      />
                      {errors.lastName && (
                        <p className="text-sm text-red-500">
                          {errors.lastName.message}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Email (Read-only) */}
                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      value={coachData?.email || ""}
                      disabled
                      className="bg-gray-50"
                    />
                    <p className="text-sm text-gray-500">
                      Email cannot be changed
                    </p>
                  </div>
                </CardContent>
              </Card>

              {/* Professional Information Card */}
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-2">
                    <Briefcase className="w-5 h-5 text-emerald-600" />
                    <CardTitle>Professional Information</CardTitle>
                  </div>
                  <CardDescription>
                    Update your professional credentials and experience
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Experience Years */}
                  <div className="space-y-2">
                    <Label htmlFor="experienceYears">
                      Years of Experience{" "}
                      <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="experienceYears"
                      type="number"
                      min="0"
                      placeholder="Enter years of experience"
                      {...register("experienceYears", {
                        required: "Experience years is required",
                        min: {
                          value: 0,
                          message: "Experience years must be 0 or greater",
                        },
                        valueAsNumber: true,
                      })}
                      className={errors.experienceYears ? "border-red-500" : ""}
                    />
                    {errors.experienceYears && (
                      <p className="text-sm text-red-500">
                        {errors.experienceYears.message}
                      </p>
                    )}
                  </div>

                  {/* Specializations */}
                  <div className="space-y-2">
                    <Label htmlFor="specializations">Specializations</Label>
                    <Input
                      id="specializations"
                      placeholder="e.g., Smoking Cessation, Behavioral Therapy"
                      {...register("specializations")}
                    />
                    <p className="text-sm text-gray-500">
                      List your areas of expertise
                    </p>
                  </div>

                  {/* Bio */}
                  <div className="space-y-2">
                    <Label htmlFor="bio">Bio</Label>
                    <Textarea
                      id="bio"
                      placeholder="Tell us about yourself, your background, and your approach to coaching..."
                      rows={6}
                      {...register("bio")}
                    />
                    <p className="text-sm text-gray-500">
                      A brief description about yourself and your coaching style
                    </p>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Right Column - Certificate Card */}
            <div className="lg:col-span-1">
              <Card className="h-full flex flex-col">
                <CardHeader>
                  <div className="flex items-center gap-2">
                    <Award className="w-5 h-5 text-emerald-600" />
                    <CardTitle>Certificates</CardTitle>
                  </div>
                  <CardDescription>
                    Upload your professional certificates
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6 flex-1 flex flex-col">
                  <div className="space-y-2 flex-1">
                    <Label htmlFor="certificate-upload">Certificate</Label>
                    <div className="flex flex-col gap-3">
                      <label
                        htmlFor="certificate-upload"
                        className={`cursor-pointer inline-flex items-center justify-center gap-2 px-4 py-2 rounded-lg transition-colors ${
                          uploadingCertificate
                            ? "bg-emerald-400 text-white cursor-not-allowed"
                            : "bg-emerald-600 text-white hover:bg-emerald-700"
                        }`}
                      >
                        <Upload className="w-4 h-4" />
                        {uploadingCertificate
                          ? "Uploading..."
                          : "Upload Certificate"}
                      </label>
                      <input
                        id="certificate-upload"
                        type="file"
                        accept="image/*"
                        onChange={handleCertificateUpload}
                        className="hidden"
                        disabled={uploadingCertificate}
                      />
                      
                      {/* Certificate Preview */}
                      {certificateUrl && (
                        <div className="border border-gray-200 rounded-lg p-3 bg-gray-50">
                          <div className="flex items-start gap-3">
                            <img
                              src={certificateUrl}
                              alt="Certificate"
                              className="w-16 h-20 object-cover rounded border border-gray-200"
                              onError={(e) => {
                                e.target.style.display = "none";
                                const fallback = e.target.parentElement.querySelector(".certificate-fallback");
                                if (fallback) fallback.style.display = "flex";
                              }}
                            />
                            <div className="flex-shrink-0 w-16 h-20 bg-red-100 rounded flex items-center justify-center certificate-fallback" style={{ display: "none" }}>
                              <FileText className="w-8 h-8 text-red-600" />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-medium text-gray-900 mb-2 truncate">
                                Certificate
                              </p>
                              <div className="flex flex-col gap-2">
                                <a
                                  href={certificateUrl}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className="text-sm text-emerald-600 hover:underline flex items-center gap-1 w-fit"
                                >
                                  <FileText className="w-4 h-4" />
                                  View Certificate
                                </a>
                              </div>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                    <p className="text-sm text-gray-500 mt-2">
                      Upload your professional certification documents (Image only, max 10MB)
                    </p>
                  </div>

                  {/* Submit Button - Fixed at bottom */}
                  <div className="mt-auto pt-4 border-t">
                    <Button
                      type="submit"
                      disabled={
                        loading || uploadingAvatar || uploadingCertificate
                      }
                      className="w-full bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white"
                    >
                      {loading ? (
                        <span className="flex items-center gap-2">
                          <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                          Saving...
                        </span>
                      ) : (
                        <>
                          <Save className="w-4 h-4 mr-2" />
                          Save Changes
                        </>
                      )}
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ProfileSettingPage;
