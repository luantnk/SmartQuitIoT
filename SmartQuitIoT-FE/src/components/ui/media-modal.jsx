// src/components/ui/media-modal.jsx
import React, { useEffect } from "react";
import { X, ChevronLeft, ChevronRight } from "lucide-react";

const MediaModal = ({ isOpen, onClose, mediaList, currentIndex, onNavigate }) => {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === "Escape") onClose();
    };
    
    const handleArrowKeys = (e) => {
      if (!isOpen || !onNavigate) return;
      if (e.key === "ArrowLeft") onNavigate("prev");
      if (e.key === "ArrowRight") onNavigate("next");
    };

    if (isOpen) {
      document.addEventListener("keydown", handleEscape);
      document.addEventListener("keydown", handleArrowKeys);
      document.body.style.overflow = "hidden";
    }

    return () => {
      document.removeEventListener("keydown", handleEscape);
      document.removeEventListener("keydown", handleArrowKeys);
      document.body.style.overflow = "unset";
    };
  }, [isOpen, onClose, onNavigate]);

  if (!isOpen || !mediaList || mediaList.length === 0) return null;

  const currentMedia = mediaList[currentIndex];
  const showNavigation = mediaList.length > 1;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm"
      onClick={onClose}
    >
      {/* Close button */}
      <button
        onClick={onClose}
        className="absolute top-4 right-4 z-50 p-2 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors"
        aria-label="Close"
      >
        <X className="w-6 h-6" />
      </button>

      {/* Navigation buttons */}
      {showNavigation && (
        <>
          <button
            onClick={(e) => {
              e.stopPropagation();
              onNavigate("prev");
            }}
            className="absolute left-4 top-1/2 -translate-y-1/2 z-50 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={currentIndex === 0}
            aria-label="Previous"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>

          <button
            onClick={(e) => {
              e.stopPropagation();
              onNavigate("next");
            }}
            className="absolute right-4 top-1/2 -translate-y-1/2 z-50 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={currentIndex === mediaList.length - 1}
            aria-label="Next"
          >
            <ChevronRight className="w-6 h-6" />
          </button>
        </>
      )}

      {/* Counter */}
      {showNavigation && (
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-50 px-4 py-2 rounded-full bg-white/10 text-white text-sm">
          {currentIndex + 1} / {mediaList.length}
        </div>
      )}

      {/* Media content */}
      <div
        className="relative max-w-7xl max-h-[90vh] w-full h-full flex items-center justify-center p-4"
        onClick={(e) => e.stopPropagation()}
      >
        {currentMedia.mediaType === "VIDEO" ? (
          <video
            src={currentMedia.mediaUrl}
            controls
            autoPlay
            className="max-w-full max-h-full rounded-lg shadow-2xl"
          >
            Your browser does not support the video tag.
          </video>
        ) : (
          <img
            src={currentMedia.mediaUrl}
            alt={`Media ${currentIndex + 1}`}
            className="max-w-full max-h-full object-contain rounded-lg shadow-2xl"
          />
        )}
      </div>
    </div>
  );
};

export default MediaModal;
