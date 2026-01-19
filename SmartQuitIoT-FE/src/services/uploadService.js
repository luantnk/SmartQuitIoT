// src/services/uploadService.js
/**
 * Simple Cloudinary upload helper (unsigned preset).
 * - Uses VITE_CLOUDINARY_CLOUD_NAME and VITE_CLOUDINARY_UPLOAD_PRESET
 * - Returns the parsed Cloudinary response (including secure_url)
 *
 * Note: unsigned uploads => no secret needed. Works for quick dev.
 */

const CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME;
const UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET;

if (!CLOUD_NAME) {
  // eslint-disable-next-line no-console
  console.warn("VITE_CLOUDINARY_CLOUD_NAME not set — upload will fail");
}
if (!UPLOAD_PRESET) {
  // eslint-disable-next-line no-console
  console.warn(
    "VITE_CLOUDINARY_UPLOAD_PRESET not set — upload will fail unless you supply preset in opts"
  );
}

/**
 * uploadUnsigned
 * - file: File
 * - opts: { folder, upload_preset }   (upload_preset overrides env)
 * returns: { secure_url, resource_type, public_id, raw }
 */
export async function uploadUnsigned(file, opts = {}) {
  if (!file) throw new Error("No file provided for upload");
  
  // Get cloud name and preset with fallbacks
  const cloud = opts.cloudName || CLOUD_NAME;
  const preset = opts.upload_preset || UPLOAD_PRESET;

  // Validate required parameters
  if (!cloud) {
    const error = new Error(
      "Cloudinary cloud name missing. Please set VITE_CLOUDINARY_CLOUD_NAME environment variable or provide cloudName in opts."
    );
    console.error("Upload error:", error.message);
    throw error;
  }
  
  if (!preset) {
    const error = new Error(
      "Cloudinary upload preset missing. Please set VITE_CLOUDINARY_UPLOAD_PRESET environment variable or provide upload_preset in opts."
    );
    console.error("Upload error:", error.message);
    throw error;
  }

  // Build upload URL
  const url = `https://api.cloudinary.com/v1_1/${cloud}/auto/upload`;
  
  // Create FormData
  const fd = new FormData();
  fd.append("file", file);
  fd.append("upload_preset", preset); // Always append preset
  
  if (opts.folder) {
    fd.append("folder", opts.folder);
  }
  
  // Optional timestamp
  fd.append("timestamp", Math.floor(Date.now() / 1000));

  // Log for debugging (only in development)
  if (import.meta.env.DEV) {
    console.log("Uploading to Cloudinary:", {
      cloud,
      preset: preset.substring(0, 10) + "...", // Only show first 10 chars for security
      folder: opts.folder,
      fileName: file.name,
      fileSize: file.size,
    });
  }

  try {
    const res = await fetch(url, {
      method: "POST",
      body: fd,
    });

    const data = await res.json();
    
    if (!res.ok) {
      const msg = data?.error?.message || JSON.stringify(data);
      const e = new Error("Cloudinary upload failed: " + msg);
      e.raw = data;
      e.status = res.status;
      console.error("Cloudinary upload error:", {
        status: res.status,
        error: data,
        message: msg,
      });
      throw e;
    }

    // Return normalized response
    return {
      secure_url: data.secure_url,
      url: data.secure_url || data.url,
      public_id: data.public_id,
      resource_type: data.resource_type,
      raw: data,
    };
  } catch (error) {
    // Re-throw if it's already our custom error
    if (error.message.includes("Cloudinary")) {
      throw error;
    }
    // Wrap network errors
    const wrappedError = new Error("Network error during upload: " + error.message);
    wrappedError.originalError = error;
    throw wrappedError;
  }
}

/**
 * uploadMultipleUnsigned(files, opts) => Promise<results[]>
 */
export async function uploadMultipleUnsigned(files = [], opts = {}) {
  if (!Array.isArray(files)) files = [files];
  const tasks = files.map((f) => uploadUnsigned(f, opts));
  return Promise.all(tasks);
}

export default {
  uploadUnsigned,
  uploadMultipleUnsigned,
};
