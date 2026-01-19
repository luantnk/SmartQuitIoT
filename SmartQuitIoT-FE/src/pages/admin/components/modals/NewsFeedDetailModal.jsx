// src/pages/admin/components/modals/NewsFeedDetailModal.jsx
import React, { useEffect, useState } from "react";
import { X, Video, Image as ImgIcon, Calendar } from "lucide-react";
import newsService from "@/services/newsService";

/**
 * Props:
 * - feedId: id of the news to fetch (optional if initialFeed provided)
 * - initialFeed: optional UI feed object (from list) to avoid extra fetch
 * - onClose: () => void
 */
const formatDate = (iso) =>
  iso
    ? new Date(iso).toLocaleString("en-US", {
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
      })
    : "-";

const NewsFeedDetailModal = ({
  feedId = null,
  initialFeed = null,
  onClose,
}) => {
  const [feed, setFeed] = useState(initialFeed);
  const [loading, setLoading] = useState(!initialFeed && !!feedId);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!feedId) return;
      setLoading(true);
      setError(null);
      try {
        const res = await newsService.getNews(feedId);
        // newsService.unwrap may return the DTO directly; handle wrapper shapes defensively
        const dto = res?.data || res?.result || res || null;
        if (mounted) setFeed(dto);
      } catch (err) {
        console.error("Failed to load news detail", err);
        if (mounted) setError("Failed to load details. Check console.");
      } finally {
        if (mounted) setLoading(false);
      }
    }

    // only fetch if we don't already have initialFeed
    if (!initialFeed && feedId) load();

    return () => {
      mounted = false;
    };
  }, [feedId, initialFeed]);

  // derive primary media
  const media =
    Array.isArray(feed?.media) && feed.media.length > 0 ? feed.media[0] : null;
  const thumbnail = feed?.thumbnailUrl || (media ? media.mediaUrl : null);
  const mediaType = media?.mediaType || (thumbnail ? "IMAGE" : null);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* backdrop */}
      <div
        className="absolute inset-0 bg-black bg-opacity-40 backdrop-blur-sm"
        onClick={onClose}
      />

      <div className="relative z-10 max-w-4xl w-full mx-4 md:mx-0 bg-white rounded-xl shadow-lg overflow-hidden">
        {/* header */}
        <div className="flex items-center justify-between px-6 py-4 border-b">
          <div className="flex items-center gap-3">
            <h3 className="text-lg font-semibold text-gray-900">
              {feed?.title || (loading ? "Loading..." : "News detail")}
            </h3>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={onClose}
              aria-label="Close"
              className="p-2 rounded-md hover:bg-gray-100"
            >
              <X size={18} />
            </button>
          </div>
        </div>

        {/* body */}
        <div className="p-6 max-h-[70vh] overflow-auto">
          {loading ? (
            <div className="w-full h-48 flex items-center justify-center">
              <div className="w-10 h-10 border-4 border-gray-200 border-t-[#00bd7e] rounded-full animate-spin" />
            </div>
          ) : error ? (
            <div className="text-red-600 text-sm">{error}</div>
          ) : !feed ? (
            <div className="text-gray-600">No data available.</div>
          ) : (
            <>
              {/* media / thumbnail */}
              {thumbnail ? (
                <div className="mb-6 rounded-md overflow-hidden bg-gray-50">
                  {mediaType === "VIDEO" ? (
                    <video
                      src={thumbnail}
                      controls
                      className="w-full max-h-96 object-cover"
                    />
                  ) : (
                    <img
                      src={thumbnail}
                      alt={feed.title}
                      className="w-full max-h-96 object-cover"
                    />
                  )}
                </div>
              ) : (
                <div className="mb-6 flex items-center gap-3 text-gray-500">
                  <ImgIcon size={20} />
                  <span>No thumbnail</span>
                </div>
              )}

              {/* meta */}
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4 text-sm text-gray-500">
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-2">
                    <Calendar size={14} />
                    <span>{formatDate(feed.createdAt)}</span>
                  </div>
                  {feed?.raw?.account?.firstName ||
                  feed?.raw?.account?.username ? (
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-gray-700">
                        {feed.raw.account.firstName ||
                          feed.raw.account.username}
                      </span>
                    </div>
                  ) : null}
                </div>
                <div className="text-xs text-gray-400">
                  {/* status badge */}
                  <span className="px-2 py-1 rounded-full bg-gray-100 text-gray-700">
                    {(feed.status || "unknown").toString().toUpperCase()}
                  </span>
                </div>
              </div>

              {/* content */}
              <div className="prose max-w-none text-gray-800 whitespace-pre-wrap">
                {feed.content || "(No content)"}
              </div>
            </>
          )}
        </div>

        {/* footer */}
        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t bg-gray-50">
          <button
            onClick={onClose}
            className="px-4 py-2 border rounded-md text-gray-700 hover:bg-gray-100"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default NewsFeedDetailModal;
