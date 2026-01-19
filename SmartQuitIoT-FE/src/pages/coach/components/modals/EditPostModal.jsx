import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { X, Upload, Loader2, Image as ImageIcon, Video, Trash2 } from "lucide-react";
import { useState, useEffect } from "react";
import { toast } from "sonner";
import postService from "@/services/postService";
import uploadService from "@/services/uploadService";

const MAX_UPLOAD_BYTES = 50 * 1024 * 1024; // 50MB

const EditPostModal = ({ open, onOpenChange, onSuccess, post }) => {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    content: "",
  });
  const [mediaList, setMediaList] = useState([]);
  const [uploadingMedia, setUploadingMedia] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState({});

  // Pre-fill form when post changes
  useEffect(() => {
    if (post && open) {
      setFormData({
        title: post.title || "",
        description: post.description || "",
        content: post.content || "",
      });
      // Convert post.media to mediaList format
      if (post.media && Array.isArray(post.media) && post.media.length > 0) {
        setMediaList(
          post.media.map((m) => ({
            mediaUrl: m.mediaUrl || m.media_url || "",
            mediaType: m.mediaType || m.media_type || "IMAGE",
          }))
        );
      } else {
        // Fallback: if no media array, try to use mediaUrls or thumbnail
        const mediaListFromUrls = [];
        if (post.mediaUrls) {
          mediaListFromUrls.push({
            mediaUrl: post.mediaUrls,
            mediaType: "IMAGE",
          });
        } else if (post.thumbnail) {
          mediaListFromUrls.push({
            mediaUrl: post.thumbnail,
            mediaType: "IMAGE",
          });
        }
        setMediaList(mediaListFromUrls);
      }
      setErrors({});
    }
  }, [post, open]);

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error for this field
    if (errors[field]) {
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const handleMediaUpload = async (e) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    setUploadingMedia(true);
    try {
      const uploadPromises = Array.from(files).map(async (file) => {
        if (file.size > MAX_UPLOAD_BYTES) {
          toast.error(`File ${file.name} is too large (>50MB)`);
          return null;
        }

        const isVideo = file.type.startsWith("video/");
        const result = await uploadService.uploadUnsigned(file, {
          folder: isVideo ? "posts/videos" : "posts/images",
          resource_type: isVideo ? "video" : "image",
        });

        return {
          mediaUrl: result.secure_url || result.url,
          mediaType: isVideo ? "VIDEO" : "IMAGE",
        };
      });

      const results = await Promise.all(uploadPromises);
      const validResults = results.filter((r) => r !== null);
      setMediaList((prev) => [...prev, ...validResults]);
      toast.success(`Uploaded ${validResults.length} file(s)`);
    } catch (err) {
      console.error("Media upload error", err);
      toast.error("Upload failed: " + (err.message || "Unknown error"));
    } finally {
      setUploadingMedia(false);
      e.target.value = "";
    }
  };

  const removeMedia = (index) => {
    setMediaList((prev) => prev.filter((_, i) => i !== index));
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.title || formData.title.trim() === "") {
      newErrors.title = "Title is required";
    }

    if (!formData.content || formData.content.trim() === "") {
      newErrors.content = "Content is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    if (!post || !post.id) {
      toast.error("Post ID is missing");
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        title: formData.title.trim(),
        description: formData.description?.trim() || "",
        content: formData.content.trim(),
        thumbnail: mediaList.length > 0 ? mediaList[0].mediaUrl : post.thumbnail || "",
        media: mediaList.map((m) => ({
          mediaUrl: m.mediaUrl,
          mediaType: m.mediaType,
        })),
      };

      await postService.updatePost(post.id, payload);
      toast.success("Post updated successfully!");

      onSuccess?.();
      onOpenChange(false);
    } catch (error) {
      console.error("Update post error:", error);
      const errorMessage =
        error?.response?.data?.message ||
        error?.message ||
        "Failed to update post. Please try again.";
      toast.error(errorMessage);
    } finally {
      setSubmitting(false);
    }
  };

  const handleClose = () => {
    if (submitting || uploadingMedia) return;
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-3xl max-h-[90vh] overflow-y-auto overflow-x-hidden">
        <DialogHeader>
          <DialogTitle>Edit Post</DialogTitle>
          <DialogDescription>
            Update your post content, media, or other details
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Title */}
          <div className="space-y-2">
            <Label htmlFor="title">
              Title <span className="text-red-500">*</span>
            </Label>
            <Input
              id="title"
              placeholder="Enter post title..."
              value={formData.title}
              onChange={(e) => handleChange("title", e.target.value)}
              className={errors.title ? "border-red-500" : ""}
              disabled={submitting || uploadingMedia}
            />
            {errors.title && (
              <p className="text-sm text-red-500">{errors.title}</p>
            )}
          </div>

          {/* Description */}
          <div className="space-y-2">
            <Label htmlFor="description">Description (Optional)</Label>
            <Input
              id="description"
              placeholder="Brief description of your post..."
              value={formData.description}
              onChange={(e) => handleChange("description", e.target.value)}
              disabled={submitting || uploadingMedia}
            />
          </div>

          {/* Content */}
          <div className="space-y-2">
            <Label htmlFor="content">
              Content <span className="text-red-500">*</span>
            </Label>
            <Textarea
              id="content"
              placeholder="Write your post content here..."
              rows={8}
              value={formData.content}
              onChange={(e) => handleChange("content", e.target.value)}
              className={`resize-y overflow-wrap-anywhere break-words whitespace-pre-wrap ${
                errors.content ? "border-red-500" : ""
              }`}
              style={{
                wordWrap: "break-word",
                overflowWrap: "break-word",
                whiteSpace: "pre-wrap",
                maxWidth: "100%",
                minWidth: 0,
                boxSizing: "border-box",
              }}
              disabled={submitting || uploadingMedia}
            />
            {errors.content && (
              <p className="text-sm text-red-500">{errors.content}</p>
            )}
          </div>

          {/* Media Upload */}
          <div className="space-y-2">
            <Label>Media (Photos & Videos)</Label>
            <label className="flex items-center justify-center w-full px-4 py-6 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors">
              <div className="flex flex-col items-center justify-center">
                {uploadingMedia ? (
                  <Loader2 className="w-6 h-6 text-gray-400 mb-2 animate-spin" />
                ) : (
                  <Upload className="w-6 h-6 text-gray-400 mb-2" />
                )}
                <span className="text-sm text-gray-600">
                  {uploadingMedia
                    ? "Uploading..."
                    : "Click to upload or drag and drop"}
                </span>
                <span className="text-xs text-gray-500 mt-1">
                  PNG, JPG, MP4, WebM up to 50MB
                </span>
              </div>
              <input
                type="file"
                accept="image/*,video/*"
                multiple
                onChange={handleMediaUpload}
                className="hidden"
                disabled={submitting || uploadingMedia}
              />
            </label>

            {/* Media Preview */}
            {mediaList.length > 0 && (
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-4">
                {mediaList.map((media, index) => (
                  <div
                    key={index}
                    className="relative group rounded-lg overflow-hidden border border-gray-200"
                  >
                    {media.mediaType === "VIDEO" ? (
                      <div className="relative">
                        <video
                          src={media.mediaUrl}
                          className="w-full h-32 object-cover"
                          controls={false}
                        />
                        <div className="absolute inset-0 flex items-center justify-center bg-black/30 pointer-events-none">
                          <Video className="w-6 h-6 text-white" />
                        </div>
                      </div>
                    ) : (
                      <img
                        src={media.mediaUrl}
                        alt={`Media ${index + 1}`}
                        className="w-full h-32 object-cover"
                      />
                    )}
                    <button
                      type="button"
                      onClick={() => removeMedia(index)}
                      disabled={submitting || uploadingMedia}
                      className="absolute top-2 right-2 p-1.5 bg-red-600 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-700"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              disabled={submitting || uploadingMedia}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={submitting || uploadingMedia}
              className="bg-emerald-600 hover:bg-emerald-700"
            >
              {submitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Updating...
                </>
              ) : (
                "Update Post"
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
};

export default EditPostModal;

