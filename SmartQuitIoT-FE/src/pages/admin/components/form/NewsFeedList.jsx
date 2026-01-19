// src/pages/admin/components/form/NewsFeedList.jsx
import React, { useState } from "react";
import { Calendar, MessageSquare, Video } from "lucide-react";
import { Edit2, Trash2 } from "lucide-react";
import { toast } from "sonner";
import useConfirm from "@/hooks/useConfirm";

const formatDate = (dateString) =>
  dateString
    ? new Date(dateString).toLocaleString("vi-VN", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      })
    : "-";

const getStatusColor = (status) => {
  const normalized = (status || "").toUpperCase();
  switch (normalized) {
    case "PUBLISH":
    case "PUBLISHED":
      return "bg-green-50 text-green-700 ring-green-100";
    case "DRAFT":
      return "bg-yellow-50 text-yellow-700";
    case "DELETED":
      return "bg-red-50 text-red-700";
    default:
      return "bg-gray-50 text-gray-700";
  }
};

const getStatusText = (status) => {
  const normalized = (status || "").toUpperCase();
  switch (normalized) {
    case "PUBLISH":
    case "PUBLISHED":
      return "Published";
    case "DRAFT":
      return "Draft";
    case "DELETED":
      return "Deleted";
    default:
      return status;
  }
};

const NewsFeedList = ({
  feeds = [],
  loading = false,
  onEdit,
  onDelete,
  onOpen,
}) => {
  const [processingId, setProcessingId] = useState(null);
  const confirm = useConfirm();

  if (loading) {
    return <div className="py-12 text-center text-gray-500">Loading...</div>;
  }

  if (!feeds || feeds.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-gray-400 mb-4">No news feeds yet</div>
      </div>
    );
  }

  // helper để detect Promise
  const isPromise = (p) => !!p && typeof p.then === "function";

  const handleEditClick = (e, feed) => {
    e.stopPropagation();
    if (onEdit) {
      onEdit(feed);
     // toast.success("Opened for editing");
    }
  };

  const handleDeleteClick = async (e, feed) => {
    e.stopPropagation();
    if (!onDelete) {
      toast("No delete action available", { id: "no-delete-action" });
      return;
    }

    // Use custom confirm modal
    const ok = await confirm({
      title: "Confirm Delete",
      message: `Are you sure you want to delete "${feed.title}"? This action cannot be undone.`,
      okText: "Delete",
      cancelText: "Cancel",
      destructive: true,
    });
    if (!ok) return;

    try {
      const result = onDelete(feed.id);
      if (isPromise(result)) {
        setProcessingId(feed.id);
        await toast.promise(result, {
          loading: "Deleting...",
          success: "Deleted successfully",
          error: (err) => `Delete failed: ${err?.message || "Error"}`,
        });
      } else {
        // sync delete: show success immediately
        toast.success("Deleted successfully");
      }
    } catch (err) {
      toast.error(`Delete failed: ${err?.message || "Unknown"}`);
    } finally {
      setProcessingId(null);
    }
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      {feeds.map((feed) => {
        const disabled = processingId === feed.id;
        return (
          <article
            key={feed.id}
            onClick={() => onOpen && onOpen(feed.id)}
            className="relative bg-white rounded-2xl shadow-sm hover:shadow-md overflow-hidden cursor-pointer transition-transform transform hover:-translate-y-0.5 flex flex-col h-full"
          >
            <div className="relative h-48 bg-gray-100">
              {feed.thumbnailUrl ? (
                <img
                  src={feed.thumbnailUrl}
                  alt={feed.title}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <MessageSquare className="w-12 h-12 text-gray-300" />
                </div>
              )}

              <div className="absolute top-3 right-3 flex gap-2">
                <span
                  className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                    feed.status
                  )}`}
                >
                  {getStatusText(feed.status)}
                </span>
                {feed.mediaType === "VIDEO" && (
                  <div className="bg-black bg-opacity-70 text-white px-2 py-1 rounded-full flex items-center gap-1">
                    <Video size={14} />
                    <span className="text-xs">Video</span>
                  </div>
                )}
              </div>
            </div>

            <div className="p-5 flex-1 flex flex-col">
              <div className="mb-4">
                <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">
                  {feed.title}
                </h3>
                <p className="text-sm text-gray-600 line-clamp-3">
                  {feed.content}
                </p>
              </div>

              <div className="mt-auto flex items-center justify-between pt-2 border-t border-gray-100 text-xs text-gray-500">
                <div className="flex items-center gap-2">
                  <img
                    src={
                      feed.account?.avatarUrl ||
                      `https://ui-avatars.com/api/?name=${
                        feed.account?.firstName || "ADMIN"
                      }`
                    }
                    alt="a"
                    className="w-7 h-7 rounded-full"
                  />
                  <div className="text-sm font-medium">
                    {feed.account?.firstName ||
                      feed.account?.username ||
                      "Admin"}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4" />
                  {formatDate(feed.createdAt)}
                </div>
              </div>

              {(feed.status || "").toUpperCase() !== "DELETED" && (
                <div className="flex gap-3 mt-4">
                  {/* Edit button - subtle outlined green */}
                  <button
                    onClick={(e) => handleEditClick(e, feed)}
                    aria-label={`Edit ${feed.title}`}
                    disabled={disabled}
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-white border border-[#00bd7e] text-[#00bd7e] rounded-lg hover:bg-[#00bd7e] hover:text-white transition focus:outline-none focus:ring-2 focus:ring-[#00bd7e]/30 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Edit2 size={16} />
                    <span className="text-sm font-medium">
                      {disabled ? "Processing..." : "Edit"}
                    </span>
                  </button>

                  {/* Delete button - subtle outlined red */}
                  <button
                    onClick={(e) => handleDeleteClick(e, feed)}
                    aria-label={`Delete ${feed.title}`}
                    disabled={disabled}
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-white border border-red-200 text-red-600 rounded-lg hover:bg-red-50 transition focus:outline-none focus:ring-2 focus:ring-red-100 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Trash2 size={16} />
                    <span className="text-sm font-medium">
                      {disabled ? "Processing..." : "Delete"}
                    </span>
                  </button>
                </div>
              )}
            </div>
          </article>
        );
      })}
    </div>
  );
};

export default NewsFeedList;
