// src/pages/FeedbackPage.jsx
import React, { useEffect, useState } from "react";
import { Star, Calendar, Clock, User } from "lucide-react";
import { getFeedbacksForCoach } from "@/services/feedbackService";
import { useNavigate } from "react-router-dom";

const FeedbackPage = () => {
  const navigate = useNavigate();
  const [currentPage, setCurrentPage] = useState(1); // UI page 1..
  const pageSize = 8; // 4 cols x 2 rows

  const [feedbacks, setFeedbacks] = useState([]);
  const [filteredFeedbacks, setFilteredFeedbacks] = useState([]);
  const [totalPages, setTotalPages] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Filter states
  const [ratingFilter, setRatingFilter] = useState("all");

  const formatDate = (dateString) => {
    if (!dateString) return "";
    const d = new Date(dateString);
    if (isNaN(d)) return dateString;
    return d.toLocaleDateString("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  };

  const formatSlot = (startTime, endTime) => {
    if (!startTime && !endTime) return "";
    const parseHM = (t) => {
      if (!t) return "";
      const parts = t.split(":");
      if (parts.length >= 2)
        return `${parts[0].padStart(2, "0")}:${parts[1].padStart(2, "0")}`;
      return t;
    };
    return `${parseHM(startTime)}${startTime && endTime ? " - " : ""}${parseHM(
      endTime
    )}`;
  };

  const loadPage = async (uiPage) => {
    setLoading(true);
    setError(null);
    try {
      const backendPage = Math.max(0, uiPage - 1);
      const data = await getFeedbacksForCoach(backendPage, pageSize);

      const content = data?.content ?? [];
      setFeedbacks(content);
      setFilteredFeedbacks(content);
      setTotalPages(data?.totalPages ?? 0);
      setCurrentPage(uiPage);
    } catch (err) {
      console.error("fetch feedbacks error", err);
      setError("Failed to load feedbacks. Please try again.");
      setFeedbacks([]);
      setTotalPages(0);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPage(1);
  }, []);

  // Filter feedbacks based on rating
  useEffect(() => {
    if (ratingFilter === "all") {
      setFilteredFeedbacks(feedbacks);
    } else {
      const rating = parseInt(ratingFilter);
      setFilteredFeedbacks(feedbacks.filter((fb) => fb.rating === rating));
    }
  }, [ratingFilter, feedbacks]);

  const paginate = (pageNumber) => {
    if (pageNumber < 1 || pageNumber > totalPages) return;
    loadPage(pageNumber);
  };

  const handleViewProfile = (memberId) => {
    if (memberId) {
      navigate(`/coach/members?memberId=${memberId}`);
    }
  };

  const clearFilters = () => {
    setRatingFilter("all");
  };

  return (
    <div className="h-full flex flex-col min-h-0">
      <div className="w-full flex-1 overflow-auto min-h-0 px-10 py-2">
        <div className="mb-6">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-2xl font-semibold">Feedback</h1>
          </div>

          {/* Filter section - simplified inline */}
          <div className="flex items-center gap-3 mb-4 flex-wrap">
            <span className="text-sm font-medium text-gray-700">
              Filter by rating:
            </span>
            <div className="flex items-center gap-2">
              {["all", "5", "4", "3", "2", "1"].map((rating) => (
                <button
                  key={rating}
                  onClick={() => setRatingFilter(rating)}
                  className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all duration-200 ${
                    ratingFilter === rating
                      ? "bg-gradient-to-r from-emerald-500 to-teal-600 text-white shadow-md"
                      : "bg-white border border-gray-200 text-gray-700 hover:border-emerald-300 hover:bg-emerald-50"
                  }`}
                >
                  {rating === "all" ? (
                    "All"
                  ) : (
                    <span className="flex items-center gap-1">
                      <Star
                        size={14}
                        className={
                          ratingFilter === rating
                            ? "fill-white"
                            : "fill-amber-400 text-amber-400"
                        }
                      />
                      {rating}
                    </span>
                  )}
                </button>
              ))}
            </div>
            {ratingFilter !== "all" && (
              <button
                onClick={clearFilters}
                className="text-sm text-gray-500 hover:text-gray-700 underline"
              >
                Clear
              </button>
            )}
            <div className="ml-auto text-sm text-gray-500">
              Showing {filteredFeedbacks.length} of {feedbacks.length}
            </div>
          </div>
        </div>

        {loading && (
          <div className="py-8 text-center text-gray-500">
            Loading feedbacks...
          </div>
        )}
        {error && <div className="py-4 text-center text-red-500">{error}</div>}
        {!loading && feedbacks.length === 0 && (
          <div className="py-8 text-left text-gray-500">
            No feedbacks available.
          </div>
        )}

        {!loading && feedbacks.length > 0 && filteredFeedbacks.length === 0 && (
          <div className="py-8 text-center text-gray-500">
            No feedbacks match the selected filter.
          </div>
        )}

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mb-6 items-start">
          {filteredFeedbacks.map((fb) => (
            <div
              key={fb.id}
              className="bg-white rounded-2xl shadow-sm hover:shadow-md transition-all duration-300 overflow-hidden border border-gray-100 flex flex-col h-full"
            >
              {/* Header - Simplified: chỉ avatar, tên, rating */}
              <div className="bg-gradient-to-br from-emerald-50 to-teal-50 p-5">
                <div className="flex items-center gap-3">
                  {/* Avatar */}
                  <div className="relative flex-shrink-0">
                    <div className="absolute inset-0 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full blur-sm opacity-30"></div>
                    <img
                      src={fb.avatarUrl || "/images/avatar-placeholder.png"}
                      alt={fb.memberName || "Member"}
                      className="relative w-14 h-14 rounded-full object-cover ring-2 ring-white shadow-md"
                    />
                  </div>

                  {/* Member Name */}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-gray-900 text-base truncate">
                      {fb.memberName ?? "—"}
                    </h3>
                  </div>

                  {/* Rating badge */}
                  <div className="flex items-center gap-1 bg-white rounded-lg px-2.5 py-1.5 shadow-sm flex-shrink-0">
                    <Star size={16} className="fill-amber-400 text-amber-400" />
                    <span className="font-bold text-base text-gray-900">
                      {fb.rating}
                    </span>
                  </div>
                </div>
              </div>

              {/* Content section */}
              <div className="p-5 flex-1 flex flex-col space-y-4">
                {/* Feedback Date Section */}
                <div className="border-b border-gray-100 pb-3">
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="text-xs font-medium text-gray-500 mb-0.5">
                        Feedback submitted
                      </div>
                      <div className="text-sm font-medium text-gray-900">
                        {formatDate(fb.date)}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Feedback Content */}
                <div className="flex-1">
                  <div className="text-xs font-medium text-gray-500 mb-2">
                    Comment
                  </div>
                  <p className="text-sm text-gray-700 leading-relaxed line-clamp-4 min-h-[60px]">
                    {fb.content || (
                      <span className="text-gray-400 italic">
                        No comment provided.
                      </span>
                    )}
                  </p>
                </div>

                {/* Appointment Info */}
                <div className="border-t border-gray-100 pt-3">
                  <div className="text-xs font-medium text-gray-500 mb-2">
                    Appointment
                  </div>
                  <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg p-3 border border-gray-200">
                    <div className="flex items-start gap-2">
                      <Calendar className="w-4 h-4 text-emerald-600 flex-shrink-0 mt-0.5" />
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-semibold text-gray-900">
                          {formatDate(fb.appointmentDate)}
                        </div>
                        {fb.startTime && fb.endTime && (
                          <div className="flex items-center gap-1 mt-1 text-xs text-gray-600">
                            <Clock className="w-3 h-3 flex-shrink-0" />
                            <span>{formatSlot(fb.startTime, fb.endTime)}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Action button */}
                {fb.memberId && (
                  <button
                    onClick={() => handleViewProfile(fb.memberId)}
                    className="w-full flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-medium text-sm hover:from-emerald-600 hover:to-teal-700 shadow-md hover:shadow-lg transition-all duration-200 mt-2"
                  >
                    <User size={18} />
                    <span>View Profile</span>
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex flex-col items-center gap-4 py-4">
            <div className="text-sm text-gray-600">
              Page {currentPage} of {totalPages}
            </div>
            <div className="flex justify-center items-center gap-2">
              <button
                onClick={() => paginate(currentPage - 1)}
                disabled={currentPage === 1 || loading}
                className="px-4 py-2 rounded-xl bg-white border-2 border-gray-200 text-gray-700 font-semibold text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:border-emerald-300 hover:bg-emerald-50 hover:text-emerald-700 transition-all duration-200"
              >
                Previous
              </button>

              <div className="flex gap-2">
                {Array.from({ length: totalPages }).map((_, i) => {
                  const pg = i + 1;
                  const showPage =
                    pg === 1 ||
                    pg === totalPages ||
                    (pg >= currentPage - 1 && pg <= currentPage + 1);

                  if (!showPage) {
                    if (pg === currentPage - 2 || pg === currentPage + 2) {
                      return (
                        <span key={pg} className="px-2 text-gray-400">
                          ...
                        </span>
                      );
                    }
                    return null;
                  }

                  return (
                    <button
                      key={pg}
                      onClick={() => paginate(pg)}
                      className={`w-10 h-10 rounded-xl font-semibold text-sm transition-all duration-200 ${
                        currentPage === pg
                          ? "bg-gradient-to-r from-emerald-500 to-teal-600 text-white shadow-md"
                          : "bg-white border-2 border-gray-200 text-gray-700 hover:border-emerald-300 hover:bg-emerald-50 hover:text-emerald-700"
                      }`}
                    >
                      {pg}
                    </button>
                  );
                })}
              </div>

              <button
                onClick={() => paginate(currentPage + 1)}
                disabled={currentPage === totalPages || loading}
                className="px-4 py-2 rounded-xl bg-white border-2 border-gray-200 text-gray-700 font-semibold text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:border-emerald-300 hover:bg-emerald-50 hover:text-emerald-700 transition-all duration-200"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default FeedbackPage;
