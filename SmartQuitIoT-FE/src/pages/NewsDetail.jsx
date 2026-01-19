// src/pages/NewsDetail.jsx
import React, { useEffect, useState } from "react";
import { ArrowLeft, Calendar, Clock, User, Video } from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";
import newsService from "@/services/newsService";
import MediaModal from "@/components/ui/media-modal";

const NewsDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [news, setNews] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Media modal state
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false);
  const [modalIndex, setModalIndex] = useState(0);

  useEffect(() => {
    const fetchNews = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await newsService.getNews(id);
        const newsData = data?.data || data?.result || data || null;
        setNews(newsData);
      } catch (err) {
        console.error("Failed to load news:", err);
        setError("Failed to load news article. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchNews();
    }
  }, [id]);

  const formatDate = (dateString) => {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        month: 'long',
        day: 'numeric',
        year: 'numeric',
      });
    } catch (e) {
      return '';
    }
  };

  const getTimeAgo = (dateString) => {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now - date;
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
      
      if (diffDays === 0) return 'Today';
      if (diffDays === 1) return 'Yesterday';
      if (diffDays < 7) return `${diffDays} days ago`;
      if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
      return `${Math.floor(diffDays / 30)} months ago`;
    } catch (e) {
      return '';
    }
  };

  const detectMediaType = (url) => {
    if (!url) return 'IMAGE';
    const videoExtensions = ['.mp4', '.webm', '.ogg', '.mov', '.avi'];
    const lowerUrl = url.toLowerCase();
    return videoExtensions.some(ext => lowerUrl.includes(ext)) ? 'VIDEO' : 'IMAGE';
  };

  const mediaList = Array.isArray(news?.media) && news.media.length > 0 
    ? news.media.map(m => ({
        mediaUrl: m.mediaUrl,
        mediaType: m.mediaType || detectMediaType(m.mediaUrl)
      }))
    : [];

  const firstMedia = mediaList.length > 0 ? mediaList[0] : null;
  const thumbnail = news?.thumbnailUrl || (firstMedia ? firstMedia.mediaUrl : null);

  const openMediaModal = (index) => {
    setModalIndex(index);
    setIsMediaModalOpen(true);
  };

  const handleMediaNavigate = (direction) => {
    if (direction === "prev" && modalIndex > 0) {
      setModalIndex(modalIndex - 1);
    } else if (direction === "next" && modalIndex < mediaList.length - 1) {
      setModalIndex(modalIndex + 1);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
        <div className="max-w-4xl mx-auto px-6 py-12">
          <div className="animate-pulse space-y-6">
            <div className="h-8 bg-gray-200 rounded w-24"></div>
            <div className="h-64 bg-gray-200 rounded-2xl"></div>
            <div className="space-y-3">
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              <div className="h-4 bg-gray-200 rounded"></div>
              <div className="h-4 bg-gray-200 rounded w-5/6"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error || !news) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
        <div className="max-w-4xl mx-auto px-6 py-12">
          <button
            onClick={() => navigate('/news')}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="font-medium">Back to News</span>
          </button>
          <div className="bg-red-50 border border-red-200 rounded-xl p-8 text-center">
            <p className="text-red-600 text-lg">{error || "News article not found"}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Header with back button */}
      <div className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-6 py-4">
          <button
            onClick={() => navigate('/news')}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="font-medium">Back to News</span>
          </button>
        </div>
      </div>

      {/* Main content */}
      <article className="max-w-4xl mx-auto px-6 py-8">
        {/* Hero Image/Video */}
        {thumbnail && (
          <div 
            className="relative w-full h-64 md:h-96 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-2xl overflow-hidden cursor-pointer group mb-8 shadow-xl"
            onClick={() => mediaList.length > 0 && openMediaModal(0)}
          >
            {firstMedia?.mediaType === "VIDEO" ? (
              <video
                src={firstMedia.mediaUrl}
                controls
                preload="metadata"
                className="w-full h-full object-cover"
                onClick={(e) => e.stopPropagation()}
              >
                Your browser does not support the video tag.
              </video>
            ) : (
              <img
                src={thumbnail}
                alt={news.title}
                className="w-full h-full object-cover transition-transform group-hover:scale-105"
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent pointer-events-none"></div>
          </div>
        )}

        {/* Content Container */}
        <div className="bg-white rounded-2xl shadow-lg p-8 md:p-12">
          {/* Meta Information */}
          <div className="flex flex-wrap items-center gap-4 text-sm text-gray-500 mb-6 pb-6 border-b">
            <div className="flex items-center gap-2">
              <Calendar className="w-4 h-4 text-emerald-600" />
              <span>{formatDate(news.createdAt)}</span>
            </div>
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-emerald-600" />
              <span>{getTimeAgo(news.createdAt)}</span>
            </div>
            {news.account && (
              <div className="flex items-center gap-2">
                <User className="w-4 h-4 text-emerald-600" />
                <span>{news.account.firstName || news.account.username}</span>
              </div>
            )}
          </div>

          {/* Title */}
          <h1 className="text-3xl md:text-5xl font-bold text-gray-900 mb-8 leading-tight">
            {news.title}
          </h1>

          {/* Content */}
          <div className="prose prose-lg max-w-none">
            <div className="text-gray-700 leading-relaxed whitespace-pre-wrap">
              {news.content}
            </div>
          </div>

          {/* Additional Media Gallery */}
          {mediaList.length > 1 && (
            <div className="mt-12 pt-12 border-t">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">Media Gallery</h3>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {mediaList.slice(1).map((m, idx) => {
                  const actualIndex = idx + 1;
                  return (
                    <div
                      key={idx}
                      className="relative rounded-xl overflow-hidden cursor-pointer group hover:shadow-xl transition-all"
                      onClick={() => openMediaModal(actualIndex)}
                    >
                      {m.mediaType === "VIDEO" ? (
                        <div className="relative bg-black">
                          <video
                            src={m.mediaUrl}
                            className="w-full h-48 object-cover"
                            onClick={(e) => e.stopPropagation()}
                          />
                          <div className="absolute inset-0 flex items-center justify-center bg-black/40 pointer-events-none">
                            <Video className="w-12 h-12 text-white" />
                          </div>
                        </div>
                      ) : (
                        <img
                          src={m.mediaUrl}
                          alt={`Media ${idx + 2}`}
                          className="w-full h-48 object-cover transition-transform group-hover:scale-110"
                        />
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>


      </article>

      {/* Media Modal */}
      <MediaModal
        isOpen={isMediaModalOpen}
        onClose={() => setIsMediaModalOpen(false)}
        mediaList={mediaList}
        currentIndex={modalIndex}
        onNavigate={handleMediaNavigate}
      />
    </div>
  );
};

export default NewsDetail;
