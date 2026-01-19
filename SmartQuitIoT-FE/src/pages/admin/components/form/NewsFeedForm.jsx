// src/pages/admin/components/form/NewsFeedForm.jsx
import React, { useEffect, useState } from "react";
import { X, Upload, Image as ImageIcon, Video } from "lucide-react";
import uploadService from "@/services/uploadService";
import newsService from "@/services/newsService";

const MAX_UPLOAD_BYTES = 500 * 1024 * 1024; // 50 MB for videos

const NewsFeedForm = ({
  initial = null,
  onCancel,
  onSubmit,
  submitting = false,
}) => {
  const [form, setForm] = useState({
    title: "",
    content: "",
    status: "DRAFT",
    thumbnailUrl: "",
  });
  const [thumbPreview, setThumbPreview] = useState("");
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  
  // NEW: media array state
  const [mediaList, setMediaList] = useState([]);
  const [uploadingMedia, setUploadingMedia] = useState(false);

  useEffect(() => {
    if (initial) {
      setForm({
        title: initial.title || "",
        content: initial.content || "",
        status: initial.status || "DRAFT",
        thumbnailUrl: initial.thumbnailUrl || "",
      });
      setThumbPreview(initial.thumbnailUrl || "");
      // Load existing media
      if (initial.media && Array.isArray(initial.media)) {
        setMediaList(initial.media.map(m => ({
          mediaUrl: m.mediaUrl,
          mediaType: m.mediaType,
        })));
      } else {
        setMediaList([]);
      }
    } else {
      setForm({
        title: "",
        content: "",
        status: "DRAFT",
        thumbnailUrl: "",
      });
      setThumbPreview("");
      setMediaList([]);
    }
  }, [initial]);

  const setField = (k, v) => setForm((p) => ({ ...p, [k]: v }));

  const handleThumbnailFile = async (e) => {
    const file = e.target.files && e.target.files[0];
    if (!file) return;

    // immediate preview
    const tmpUrl = URL.createObjectURL(file);
    setThumbPreview(tmpUrl);
    setUploading(true);

    try {
      if (file.size > MAX_UPLOAD_BYTES) {
        alert("File is too large (>10MB). Please choose a smaller image.");
        setThumbPreview(form.thumbnailUrl || "");
        return;
      }

      const result = await uploadService.uploadUnsigned(file, {
        folder: "news",
      });
      const url = result.secure_url || result.url;
      setField("thumbnailUrl", url);
      setThumbPreview(url);
    } catch (err) {
      console.error("Upload error", err);
      const msg = err?.raw?.error?.message || err.message || "Upload failed";
      alert("Upload failed: " + msg);
      // keep existing thumbnail if any
      setThumbPreview(form.thumbnailUrl || "");
    } finally {
      setUploading(false);
    }
  };

  const clearThumbnail = () => {
    setField("thumbnailUrl", "");
    setThumbPreview("");
  };

  // NEW: handle media upload (image or video)
  const handleMediaUpload = async (e) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    console.log('Files selected:', files.length, files);
    setUploadingMedia(true);
    try {
      const uploadPromises = Array.from(files).map(async (file, idx) => {
        console.log(`Starting upload ${idx + 1}/${files.length}:`, file.name, file.type);
        
        if (file.size > MAX_UPLOAD_BYTES) {
          alert(`File ${file.name} is too large (>500MB)`);
          return null;
        }

        const isVideo = file.type.startsWith('video/');
        console.log(`Uploading ${file.name} as ${isVideo ? 'VIDEO' : 'IMAGE'}`);
        
        const result = await uploadService.uploadUnsigned(file, {
          folder: isVideo ? 'news/videos' : 'news/images',
          resource_type: isVideo ? 'video' : 'image',
        });
        
        console.log(`Upload complete ${idx + 1}:`, result.secure_url || result.url);
        
        return {
          mediaUrl: result.secure_url || result.url,
          mediaType: isVideo ? 'VIDEO' : 'IMAGE',
        };
      });

      console.log('Waiting for all uploads...');
      const results = await Promise.all(uploadPromises);
      console.log('All uploads done:', results);
      
      const validResults = results.filter(r => r !== null);
      console.log('Valid upload results:', validResults);
      
      setMediaList(prev => {
        const updated = [...prev, ...validResults];
        console.log('Updated mediaList:', updated);
        return updated;
      });
    } catch (err) {
      console.error('Media upload error', err);
      alert('Upload failed: ' + (err.message || 'Unknown error'));
    } finally {
      setUploadingMedia(false);
      // reset input
      e.target.value = '';
    }
  };

  const removeMedia = (index) => {
    setMediaList(prev => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async () => {
    if (!form.title?.trim() || !form.content?.trim()) {
      alert("Please enter a title and content.");
      return;
    }

    setSaving(true);
    try {
      // Debug log
      console.log('mediaList before submit:', mediaList);
      const mediaUrls = mediaList.map(m => m.mediaUrl);
      console.log('mediaUrls to send:', mediaUrls);
      
      const payload = {
        id: initial?.id,
        title: form.title,
        content: form.content,
        thumbnailUrl: form.thumbnailUrl || null,
        mediaUrls: mediaUrls, // Backend only needs URLs array
        status: form.status, // Keep as 'status' for parent component
        newsStatus: form.status, // Also send as newsStatus for API
      };

      console.log('Full payload:', payload);
      onSubmit && onSubmit(payload);
    } catch (err) {
      console.error("Save news error", err);
      const msg = err?.response?.data || err?.message || "Save failed";
      alert(
        "Save failed: " + (typeof msg === "string" ? msg : JSON.stringify(msg))
      );
    } finally {
      setSaving(false);
    }
  };

  const disabled = uploading || saving || submitting || uploadingMedia;

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-bold text-gray-900">
          {initial ? "Edit News Feed" : "Create News Feed"}
        </h2>
        <button
          onClick={onCancel}
          className="text-gray-400 hover:text-gray-600"
        >
          <X size={20} />
        </button>
      </div>

      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* left */}
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Title *
              </label>
              <input
                value={form.title}
                onChange={(e) => setField("title", e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                placeholder="Title..."
                disabled={disabled}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Content *
              </label>
              <textarea
                value={form.content}
                onChange={(e) => setField("content", e.target.value)}
                rows={6}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                placeholder="Content..."
                disabled={disabled}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                value={form.status}
                onChange={(e) => setField("status", e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                disabled={disabled}
              >
                <option value="DRAFT">Draft</option>
                <option value="PUBLISH">Publish</option>
              </select>
            </div>
          </div>

          {/* right */}
          <div className="space-y-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Thumbnail (display image)
            </label>

            {/* Styled upload button */}
            <div className="flex items-center gap-3">
              <label
                htmlFor="thumb-file"
                className={`inline-flex items-center gap-2 px-4 py-2 border rounded-lg cursor-pointer select-none
                  ${
                    disabled
                      ? "opacity-50 cursor-not-allowed"
                      : "bg-white hover:bg-gray-50"
                  }`}
                aria-disabled={disabled}
              >
                <svg
                  className="w-4 h-4 text-gray-600"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <path
                    d="M12 5v14M5 12h14"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                <span className="text-sm text-gray-700">Upload thumbnail</span>
              </label>
              <input
                id="thumb-file"
                type="file"
                accept="image/*"
                onChange={handleThumbnailFile}
                disabled={disabled}
                className="hidden"
              />

              {thumbPreview ? (
                <button
                  onClick={clearThumbnail}
                  disabled={disabled}
                  className="text-sm text-red-600 border border-red-100 px-3 py-1 rounded-lg"
                >
                  Remove
                </button>
              ) : null}

              {(uploading || saving) && (
                <div className="text-sm text-gray-500 ml-2 flex items-center gap-2">
                  <div className="w-4 h-4 border-2 border-gray-300 rounded-full animate-spin" />
                  <span>{uploading ? "Uploading..." : "Saving..."}</span>
                </div>
              )}
            </div>

            {/* Preview zone */}
            {thumbPreview ? (
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-3 relative">
                <img
                  src={thumbPreview}
                  alt="thumbnail preview"
                  className="w-full rounded-md object-cover max-h-48"
                />
                {/* small remove icon on top-right */}
                <button
                  onClick={clearThumbnail}
                  className="absolute top-2 right-2 bg-white bg-opacity-70 rounded-full p-1 shadow-sm hover:bg-opacity-100"
                  aria-label="Remove thumbnail"
                >
                  <X size={14} />
                </button>
              </div>
            ) : (
              <div className="text-sm text-gray-500">No thumbnail</div>
            )}
          </div>
        </div>

        {/* NEW: Media Upload Section */}
        <div className="border-t pt-6">
          <label className="block text-sm font-medium text-gray-700 mb-3">
            Additional Media (Images & Videos)
          </label>
          
          <div className="flex items-center gap-3 mb-4">
            <label
              htmlFor="media-files"
              className={`inline-flex items-center gap-2 px-4 py-2 border rounded-lg cursor-pointer select-none
                ${disabled ? 'opacity-50 cursor-not-allowed' : 'bg-white hover:bg-gray-50'}`}
              aria-disabled={disabled}
            >
              <Upload className="w-4 h-4 text-gray-600" />
              <span className="text-sm text-gray-700">Upload Media</span>
            </label>
            <input
              id="media-files"
              type="file"
              accept="image/*,video/*"
              multiple
              onChange={handleMediaUpload}
              disabled={disabled}
              className="hidden"
            />
            
            {uploadingMedia && (
              <div className="text-sm text-gray-500 flex items-center gap-2">
                <div className="w-4 h-4 border-2 border-gray-300 border-t-emerald-600 rounded-full animate-spin" />
                <span>Uploading...</span>
              </div>
            )}
          </div>

          {/* Media Preview Grid */}
          {mediaList.length > 0 ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {mediaList.map((media, idx) => (
                <div key={idx} className="relative group border rounded-lg overflow-hidden bg-gray-50">
                  {media.mediaType === 'VIDEO' ? (
                    <div className="relative">
                      <video
                        src={media.mediaUrl}
                        className="w-full h-32 object-cover"
                      />
                      <div className="absolute inset-0 flex items-center justify-center bg-black/20">
                        <Video className="w-8 h-8 text-white" />
                      </div>
                    </div>
                  ) : (
                    <img
                      src={media.mediaUrl}
                      alt={`media-${idx}`}
                      className="w-full h-32 object-cover"
                    />
                  )}
                  
                  <button
                    onClick={() => removeMedia(idx)}
                    className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                    aria-label="Remove media"
                  >
                    <X size={14} />
                  </button>
                  
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-2">
                    <span className="text-xs text-white font-medium">
                      {media.mediaType}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
              <div className="flex flex-col items-center gap-2 text-gray-400">
                <ImageIcon className="w-12 h-12" />
                <p className="text-sm">No additional media uploaded</p>
                <p className="text-xs">You can upload images and videos</p>
              </div>
            </div>
          )}
        </div>

        <div className="flex justify-end gap-3 pt-4 border-t">
          <button
            onClick={onCancel}
            disabled={disabled}
            className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg"
          >
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={disabled}
            className="px-6 py-2 bg-[#00bd7e] text-white rounded-lg"
          >
            {saving
              ? initial
                ? "Updating..."
                : "Creating..."
              : initial
              ? "Update"
              : "Create"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default NewsFeedForm;
