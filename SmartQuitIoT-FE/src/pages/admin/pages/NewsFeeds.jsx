// src/pages/admin/pages/NewsFeeds.jsx
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";
import newsService from "@/services/newsService";
import NewsFeedList from "../components/form/NewsFeedList";
import NewsFeedForm from "../components/form/NewsFeedForm";

/**
 * Map backend DTO -> UI model
 * Keep this function defined BEFORE the component so fetchFeeds can use it.
 */
const mapNewsDTOtoUI = (n = {}) => {
  const firstMedia =
    Array.isArray(n.media) && n.media.length > 0 ? n.media[0] : null;

  return {
    id: n.id,
    title: n.title,
    content: n.content,
    status: n.status || "DRAFT", // Keep uppercase for enum
    createdAt: n.createdAt,
    updatedAt: n.updatedAt || n.createdAt,
    thumbnailUrl: n.thumbnailUrl || null,
    mediaUrl: firstMedia ? firstMedia.mediaUrl : null,
    mediaType: firstMedia ? firstMedia.mediaType || "IMAGE" : "IMAGE",
    account: n.account || null,
    raw: n,
  };
};

const NewsFeeds = () => {
  const navigate = useNavigate();
  const [feeds, setFeeds] = useState([]);
  const [loading, setLoading] = useState(false);

  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  // Pagination and filters
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(6);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [statusFilter, setStatusFilter] = useState("");
  const [searchTitle, setSearchTitle] = useState("");
  const [searchInput, setSearchInput] = useState("");

  const fetchFeeds = async () => {
    setLoading(true);
    try {
      const result = await newsService.getAllWithFilters({
        status: statusFilter || undefined,
        title: searchTitle || undefined,
        page,
        size,
        sort: "createdAt,desc"
      });
      
      // Handle paginated response
      const content = result?.content || [];
      const arr = Array.isArray(content) ? content.map(mapNewsDTOtoUI) : [];
      console.log("result:", result);
      setFeeds(arr);
      setTotalPages(result?.page?.totalPages || 0);
      setTotalElements(result?.page?.totalElements || 0);
    } catch (e) {
      console.error("fetchFeeds error", e);
      setFeeds([]);
      toast.error("Failed to load news list. Check console for details.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFeeds();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, size, statusFilter, searchTitle]);

  const handleCreateOrUpdate = async (payload) => {
    setSubmitting(true);
    try {
      console.log('Received payload from form:', payload);
      const createPayload = {
        title: payload.title,
        content: payload.content,
        thumbnailUrl: payload.thumbnailUrl || null,
        mediaUrls: payload.mediaUrls || [], // Use plural mediaUrls from form
        newsStatus: payload.newsStatus || "DRAFT", // Use newsStatus from form
      };
      console.log('Sending to API:', createPayload);

      if (payload.id) {
        const updated = await newsService.updateNews(payload.id, createPayload);
        const ui = mapNewsDTOtoUI(updated);
        setFeeds((prev) => prev.map((f) => (f.id === ui.id ? ui : f)));
        toast.success("Update successful");
      } else {
        const created = await newsService.createNews(createPayload);
        const ui = mapNewsDTOtoUI(created);
        setFeeds((prev) => [ui, ...(prev || [])]);
        toast.success("Create successful");
      }
      setShowForm(false);
      setEditing(null);
    } catch (err) {
      console.error("create/update error", err);
      toast.error("Error saving news. See console.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleEdit = (feed) => {
    setEditing(feed);
    setShowForm(true);
  };

  const handleDelete = async (id) => {
    try {
      await newsService.deleteNews(id);
     // showSuccess("Deleted");
      // Refresh list
      fetchFeeds();
    } catch (err) {
      console.error("delete error", err);
      toast.error("Delete failed. See console.");
    }
  };

  const handleSearch = () => {
    setSearchTitle(searchInput);
    setPage(0); // Reset to first page
  };

  const handleStatusChange = (newStatus) => {
    setStatusFilter(newStatus);
    setPage(0); // Reset to first page
  };

  const handlePageChange = (newPage) => {
    if (newPage >= 0 && newPage < totalPages) {
      setPage(newPage);
    }
  };

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              Manage News Feeds
            </h1>
            <p className="text-gray-600 mt-1">
              {totalElements} News Feeds Total
            </p>
          </div>

          {!showForm && (
            <button
              onClick={() => {
                setShowForm(true);
                setEditing(null);
              }}
              className="flex items-center gap-2 bg-[#00bd7e] hover:bg-[#00a56f] text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              Create News Feed
            </button>
          )}
        </div>

        {/* Search and Filter Bar */}
        {!showForm && (
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
            <div className="flex flex-col md:flex-row gap-4">
              {/* Search by title */}
              <div className="flex-1">
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={searchInput}
                    onChange={(e) => setSearchInput(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                    placeholder="Search by title..."
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#00bd7e]"
                  />
                  <button
                    onClick={handleSearch}
                    className="px-6 py-2 bg-[#00bd7e] text-white rounded-lg hover:bg-[#00a56f] transition"
                  >
                    Search
                  </button>
                  {searchTitle && (
                    <button
                      onClick={() => {
                        setSearchInput("");
                        setSearchTitle("");
                        setPage(0);
                      }}
                      className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition"
                    >
                      Clear
                    </button>
                  )}
                </div>
              </div>

              {/* Filter by status */}
              <div className="flex gap-2">
                <select
                  value={statusFilter}
                  onChange={(e) => handleStatusChange(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#00bd7e]"
                >
                  <option value="">All Status</option>
                  <option value="DRAFT">Draft</option>
                  <option value="PUBLISH">Published</option>
                  <option value="DELETED">Deleted</option>
                </select>
              </div>
            </div>
          </div>
        )}

        {showForm && (
          <NewsFeedForm
            key={editing?.id || "new"}
            initial={editing}
            onCancel={() => {
              setShowForm(false);
              setEditing(null);
            }}
            onSubmit={handleCreateOrUpdate}
            submitting={submitting}
          />
        )}

        {!showForm && (
          <>
            <NewsFeedList
              feeds={feeds}
              loading={loading}
              onEdit={handleEdit}
              onDelete={handleDelete}
              onOpen={(id) => navigate(`/admin/news-feeds/${id}`)}
            />

            {/* Pagination */}
            {!loading && totalPages > 1 && (
              <div className="mt-6 flex justify-center items-center gap-2">
                <button
                  onClick={() => handlePageChange(page - 1)}
                  disabled={page === 0}
                  className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
                >
                  Previous
                </button>

                <div className="flex gap-1">
                  {Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
                    let pageNum;
                    if (totalPages <= 5) {
                      pageNum = i;
                    } else if (page < 3) {
                      pageNum = i;
                    } else if (page > totalPages - 3) {
                      pageNum = totalPages - 5 + i;
                    } else {
                      pageNum = page - 2 + i;
                    }

                    return (
                      <button
                        key={pageNum}
                        onClick={() => handlePageChange(pageNum)}
                        className={`px-4 py-2 rounded-lg ${
                          page === pageNum
                            ? "bg-[#00bd7e] text-white"
                            : "border border-gray-300 hover:bg-gray-50"
                        }`}
                      >
                        {pageNum + 1}
                      </button>
                    );
                  })}
                </div>

                <button
                  onClick={() => handlePageChange(page + 1)}
                  disabled={page >= totalPages - 1}
                  className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
                >
                  Next
                </button>

                <span className="ml-4 text-sm text-gray-600">
                  Page {page + 1} of {totalPages}
                </span>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export default NewsFeeds;
