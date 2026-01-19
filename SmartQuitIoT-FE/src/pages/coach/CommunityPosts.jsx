// src/pages/coach/CommunityPosts.jsx
import React, { useEffect, useMemo, useRef, useState } from "react";
import {
  ArrowLeft,
  Calendar,
  MessageSquare,
  Video,
  Plus,
  Search,
  Edit,
  Trash2,
} from "lucide-react";
import { toast } from "sonner";
import postService from "@/services/postService";
import commentService from "@/services/commentService";
import MediaModal from "@/components/ui/media-modal";
import CreatePostModal from "@/pages/coach/components/modals/CreatePostModal";
import EditPostModal from "@/pages/coach/components/modals/EditPostModal";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import useAuth from "@/hooks/useAuth";
import useConfirm from "@/hooks/useConfirm";

/* ----------------------
   Helpers (date parsing + relative)
   ---------------------- */
const parseDateFlexible = (v) => {
  if (!v) return null;
  if (v instanceof Date && !isNaN(v)) return v;
  try {
    let s = String(v).trim();
    s = s.replace(/\.(\d{3})\d+/, ".$1");
    let d = new Date(s);
    if (isNaN(d)) {
      d = new Date(s + "Z");
      if (isNaN(d)) return null;
    }
    return d;
  } catch {
    return null;
  }
};

const formatDateRelative = (input) => {
  const d = parseDateFlexible(input);
  if (!d) return "";
  const now = new Date();
  const diffMs = now - d;
  const diffMinutes = Math.floor(diffMs / (1000 * 60));
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffMinutes < 1) return "Just now";
  if (diffMinutes < 60)
    return `${diffMinutes} minute${diffMinutes > 1 ? "s" : ""} ago`;
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? "s" : ""} ago`;
  if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? "s" : ""} ago`;
  return d.toLocaleDateString("en-US", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

/* ----------------------
   Parse content: support plain text or Quill delta JSON
   ---------------------- */
const parsePostContent = (raw) => {
  if (!raw) return [];
  if (typeof raw !== "string") raw = String(raw);

  const s = raw.trim();
  if (s.startsWith("[")) {
    try {
      const ops = JSON.parse(s);
      const blocks = [];
      let paragraphBuffer = "";
      ops.forEach((op) => {
        if (typeof op.insert === "string") {
          paragraphBuffer += op.insert;
        } else if (op.insert && op.insert.image) {
          if (paragraphBuffer.trim()) {
            paragraphBuffer.split("\n").forEach((line) => {
              if (line.trim()) blocks.push({ type: "p", content: line });
            });
            paragraphBuffer = "";
          }
          blocks.push({ type: "img", content: op.insert.image });
        }
        if (op.attributes && op.attributes.header) {
          if (paragraphBuffer.trim()) {
            paragraphBuffer.split("\n").forEach((line) => {
              if (line.trim()) blocks.push({ type: "p", content: line });
            });
            paragraphBuffer = "";
          }
          blocks.push({ type: "h3", content: op.insert });
        }
      });
      if (paragraphBuffer.trim()) {
        paragraphBuffer.split("\n").forEach((line) => {
          if (line.trim()) blocks.push({ type: "p", content: line });
        });
      }
      return blocks;
    } catch {
      return s.split("\n").map((p) => ({ type: "p", content: p }));
    }
  }

  return s.split("\n").map((p) => ({ type: "p", content: p }));
};

/* ----------------------
   UI helpers for content rendering
   ---------------------- */
const RenderBlocks = ({ blocks }) => {
  if (!blocks || blocks.length === 0) return null;
  return blocks.map((b, i) => {
    if (b.type === "h3")
      return (
        <h3 key={i} className="text-2xl font-semibold text-gray-900 mt-6 mb-3">
          {String(b.content).trim()}
        </h3>
      );
    if (b.type === "img")
      return (
        <div key={i} className="my-6 flex justify-center">
          <img
            src={b.content}
            alt={`media-${i}`}
            className="w-full max-w-[900px] rounded-lg object-cover shadow-md"
            style={{ maxHeight: "520px" }}
          />
        </div>
      );
    if (b.type === "li")
      return (
        <li key={i} className="ml-6 text-gray-700">
          {b.content}
        </li>
      );
    return (
      <p key={i} className="text-gray-700 leading-relaxed mb-4">
        {b.content}
      </p>
    );
  });
};

/* ----------------------
   Comment components
   ---------------------- */
const CommentForm = ({
  avatarUrl,
  placeholder = "Write a comment...",
  onSubmit,
  submitting,
}) => {
  const [value, setValue] = useState("");
  return (
    <div className="flex gap-4 items-start">
      <img
        src={
          avatarUrl ||
          "https://ui-avatars.com/api/?background=333&color=fff&name=Coach"
        }
        alt="Avatar"
        className="w-12 h-12 rounded-full border-2 border-emerald-200"
      />
      <div className="flex-1">
        <textarea
          value={value}
          onChange={(e) => setValue(e.target.value)}
          rows={3}
          placeholder={placeholder}
          className="w-full rounded-lg border-gray-200 shadow-sm p-3 focus:ring-2 focus:ring-emerald-200 resize-none"
        />
        <div className="flex justify-end mt-2">
          <button
            onClick={async () => {
              const t = value.trim();
              if (!t || submitting) return;
              await onSubmit(t);
              setValue("");
            }}
            disabled={submitting || value.trim() === ""}
            className={`px-4 py-2 rounded-md font-medium transition-colors ${
              submitting
                ? "bg-emerald-200 text-white cursor-not-allowed"
                : "bg-emerald-600 text-white hover:bg-emerald-700"
            }`}
          >
            {submitting ? "Sending..." : "Post Comment"}
          </button>
        </div>
      </div>
    </div>
  );
};

const CommentItem = ({ c, onReply }) => {
  const avatarUrl =
    c.account?.username === "admin"
      ? "https://res.cloudinary.com/dmp8hzwup/image/upload/v1763904550/657b6b513ddcb182e8cd_ktrbwd.jpg"
      : c.account?.avatarUrl ||
        c.avatarUrl ||
        "https://ui-avatars.com/api/?background=00D09E&color=fff&name=U";

  return (
    <div className="flex gap-3 py-4 border-b border-gray-100 last:border-0">
      <img src={avatarUrl} alt="avatar" className="w-10 h-10 rounded-full" />
      <div className="flex-1">
        <div className="flex items-center justify-between">
          <div className="font-medium text-sm text-gray-900">
            {c.account?.firstName || c.account?.username}
          </div>
          <div className="text-xs text-gray-400">
            {formatDateRelative(c.createdAt)}
          </div>
        </div>
        <div className="text-gray-700 mt-1">{c.content}</div>
        <div className="text-xs text-gray-500 mt-2">
          <button
            className="hover:underline text-emerald-600 hover:text-emerald-700"
            onClick={() => onReply && onReply(c.id)}
          >
            Reply
          </button>
        </div>
        {c.replies && c.replies.length > 0 && (
          <div className="mt-3 ml-12 border-l-2 border-emerald-100 pl-4 space-y-3">
            {c.replies.map((r) => (
              <CommentItem key={r.id} c={r} onReply={onReply} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

/* ---------------------------
   Main CommunityPosts Component
   --------------------------- */
const CommunityPosts = () => {
  const [perPage] = useState(6);
  const [page, setPage] = useState(1);
  const [posts, setPosts] = useState([]);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState("");

  // DETAIL state
  const [selectedPost, setSelectedPost] = useState(null);
  const [loadingPosts, setLoadingPosts] = useState(false);

  // comment state
  const [commentSubmitting, setCommentSubmitting] = useState(false);
  const [replyingTo, setReplyingTo] = useState(null);
  const [replySubmitting, setReplySubmitting] = useState(false);

  // showComments toggle + ref for smooth scroll
  const [showComments, setShowComments] = useState(false);
  const commentsRef = useRef(null);

  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalIndex, setModalIndex] = useState(0);

  // Create post modal
  const [isCreatePostModalOpen, setIsCreatePostModalOpen] = useState(false);
  
  // Edit post modal
  const [isEditPostModalOpen, setIsEditPostModalOpen] = useState(false);
  const [postToEdit, setPostToEdit] = useState(null);
  const [loadingPostForEdit, setLoadingPostForEdit] = useState(false);
  
  // Delete post state
  const [deletingPostId, setDeletingPostId] = useState(null);
  
  // Get current user account ID
  const { getAccountId } = useAuth();
  const currentAccountId = getAccountId();
  const confirm = useConfirm();

  const totalPages = useMemo(() => {
    if (!totalCount) return 1;
    return Math.max(1, Math.ceil(totalCount / perPage));
  }, [totalCount, perPage]);

  /* fetch list */
  const fetchPosts = async (query = "") => {
    setLoadingPosts(true);
    try {
      const list = await postService.getPosts(query ? { query } : {});
      console.log("fetched posts", list);
      setPosts(Array.isArray(list) ? list : []);
      setTotalCount(Array.isArray(list) ? list.length : 0);
    } catch (e) {
      console.error(e);
      toast.error("Failed to load posts");
    } finally {
      setLoadingPosts(false);
    }
  };

  useEffect(() => {
    fetchPosts(searchQuery);
  }, [searchQuery]);

  const visiblePosts = useMemo(() => {
    if (!posts) return [];
    const start = (page - 1) * perPage;
    return posts.slice(start, start + perPage);
  }, [posts, page, perPage]);

  /* load detail */
  const loadPostDetail = async (postId) => {
    setShowComments(false);
    try {
      const detail = await postService.getPostDetail(postId);
      let comments = [];
      try {
        comments = await commentService.getCommentsByPostId(postId);
      } catch {
        comments = detail?.comments ?? [];
      }
      setSelectedPost({ ...(detail || {}), comments });
      setTimeout(() => window.scrollTo({ top: 0, behavior: "smooth" }), 50);
    } catch (err) {
      console.error("loadPostDetail", err);
      toast.error("Failed to load post details");
    }
  };

  const handleBack = () => {
    setSelectedPost(null);
    setReplyingTo(null);
    setShowComments(false);
  };

  /* comments create */
  const createComment = async (postId, content, parentId = null) => {
    if (!content || content.trim() === "") return null;
    setCommentSubmitting(true);
    try {
      const payload = { content };
      if (parentId) payload.parentId = parentId;
      const created = await commentService.createComment(postId, payload);

      const commentWithAccount = {
        ...created,
        account: created.account || selectedPost?.account || {},
      };

      setSelectedPost((prev) => {
        if (!prev) return prev;
        const copy = { ...prev };
        if (!parentId)
          copy.comments = [commentWithAccount, ...(copy.comments || [])];
        else {
          const insertReply = (list = []) =>
            list.map((c) => {
              if (c.id === parentId) {
                const replies = c.replies
                  ? [...c.replies, commentWithAccount]
                  : [commentWithAccount];
                return { ...c, replies };
              }
              if (c.replies && c.replies.length)
                return { ...c, replies: insertReply(c.replies) };
              return c;
            });
          copy.comments = insertReply(copy.comments || []);
        }
        return copy;
      });
      return commentWithAccount;
    } catch (e) {
      console.error(e);
      toast.error("Failed to post comment");
      return null;
    } finally {
      setCommentSubmitting(false);
    }
  };

  /* reply */
  const onReplyClick = (id) =>
    setReplyingTo((prev) => (prev === id ? null : id));
  const onSubmitReply = async (text, parentId) => {
    if (!selectedPost) return;
    setReplySubmitting(true);
    await createComment(selectedPost.id, text, parentId);
    setReplyingTo(null);
    setReplySubmitting(false);
  };

  const handleOpenPost = (id) => loadPostDetail(id);

  useEffect(() => {
    if (showComments && commentsRef.current) {
      commentsRef.current.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }
  }, [showComments]);

  const handleCreatePostSuccess = () => {
    fetchPosts(searchQuery);
    toast.success("Post created successfully!");
  };

  // Check if post belongs to current user
  const isMyPost = (post) => {
    if (!post || !post.account) return false;
    const postAccountId = post.account.id || post.account.accountId;
    return postAccountId === currentAccountId;
  };

  // Handle edit post
  const handleEditPost = async (e, post) => {
    if (e && typeof e.stopPropagation === "function") {
      e.stopPropagation();
    }
    
    // Load full post detail to get media array
    setLoadingPostForEdit(true);
    try {
      const fullPost = await postService.getPostDetail(post.id);
      setPostToEdit(fullPost);
      setIsEditPostModalOpen(true);
    } catch (error) {
      console.error("Failed to load post detail for editing:", error);
      toast.error("Failed to load post details");
    } finally {
      setLoadingPostForEdit(false);
    }
  };

  const handleEditPostSuccess = () => {
    fetchPosts(searchQuery);
    // If editing the currently selected post, reload it
    if (selectedPost && postToEdit && selectedPost.id === postToEdit.id) {
      loadPostDetail(selectedPost.id);
    }
    setIsEditPostModalOpen(false);
    setPostToEdit(null);
    toast.success("Post updated successfully!");
  };

  // Handle delete post
  const handleDeletePost = async (e, postId) => {
    if (e && typeof e.stopPropagation === "function") {
      e.stopPropagation();
    }

    const ok = await confirm({
      title: "Delete Post",
      message: "Are you sure you want to delete this post? This action cannot be undone.",
      okText: "Delete",
      cancelText: "Cancel",
      destructive: true,
    });

    if (!ok) {
      return;
    }

    setDeletingPostId(postId);
    try {
      await postService.deletePost(postId);
      
      // Remove from list
      setPosts((prev) => prev.filter((p) => p.id !== postId));
      setTotalCount((prev) => Math.max(0, prev - 1));

      // If viewing this post, go back to list
      if (selectedPost && selectedPost.id === postId) {
        setSelectedPost(null);
        setShowComments(false);
      }

      toast.success("Post deleted successfully");
    } catch (error) {
      console.error("Delete post error:", error);
      toast.error("Failed to delete post");
    } finally {
      setDeletingPostId(null);
    }
  };

  /* ----------------------
     RENDER
     ---------------------- */

  // LIST VIEW
  if (!selectedPost) {
    return (
      <div className="min-h-[90vh] bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-2">
              SmartQuit Community
            </h1>
            <p className="text-gray-600 text-base sm:text-lg">
              Share and learn experiences from others on their journey to quit
              smoking.
            </p>
          </div>

          {/* Search and Create Post */}
          <div className="flex flex-col sm:flex-row gap-4 mb-8">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="text"
                placeholder="Search posts..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setPage(1);
                }}
                className="pl-10 border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
              />
            </div>
            <Button
              onClick={() => setIsCreatePostModalOpen(true)}
              className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-sm hover:shadow-md transition-shadow"
            >
              <Plus className="mr-2 h-4 w-4" />
              Create Post
            </Button>
          </div>

          {/* Posts Grid */}
          {loadingPosts ? (
            <div className="flex items-center justify-center py-16">
              <div className="text-gray-500">Loading posts...</div>
            </div>
          ) : visiblePosts.length === 0 ? (
            <div className="text-center py-16">
              <MessageSquare className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 text-lg">No posts found</p>
            </div>
          ) : (
            <div className="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 items-stretch">
              {visiblePosts.map((p) => (
                <article
                  key={p.id}
                  onClick={() => handleOpenPost(p.id)}
                  className="relative bg-white rounded-xl border border-gray-200 overflow-hidden cursor-pointer hover:border-emerald-300 hover:shadow-lg transition-all duration-300 flex flex-col h-full group"
                >
                  {/* Tag badge - only show if post belongs to current user */}
                  {isMyPost(p) && (
                    <div className="absolute top-2 left-2 z-10">
                      <span className="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-semibold bg-emerald-600 text-white shadow-md">
                        My Post
                      </span>
                    </div>
                  )}
                  
                  <div className="h-48 overflow-hidden bg-gray-100 flex items-center justify-center">
                    {p.mediaUrls || p.thumbnail ? (
                      <img
                        src={p.mediaUrls || p.thumbnail}
                        alt={p.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    ) : (
                      <MessageSquare className="w-12 h-12 text-gray-400" />
                    )}
                  </div>

                  <div className="p-5 flex-1 flex flex-col">
                    <div className="mb-4">
                      <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2 text-lg group-hover:text-emerald-600 transition-colors">
                        {p.title}
                      </h3>
                      <p className="text-sm text-gray-600 line-clamp-3">
                        {p.description}
                      </p>
                    </div>

                    <div className="mt-auto flex items-center justify-between pt-4 border-t border-gray-100">
                      <div className="flex items-center gap-2">
                        <img
                          src={
                            p.account?.avatarUrl ||
                            "https://ui-avatars.com/api/?background=00D09E&color=fff&name=U"
                          }
                          alt="avatar"
                          className="w-7 h-7 rounded-full border border-gray-200"
                        />
                        <div className="text-sm font-medium text-gray-700">
                          {p.account?.firstName || p.account?.username}
                        </div>
                      </div>
                      <div className="flex items-center gap-1.5 text-xs text-gray-500">
                        <Calendar className="w-3.5 h-3.5" />
                        <span>{formatDateRelative(p.createdAt)}</span>
                      </div>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-2 mt-12">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="px-4 py-2 rounded-lg border border-gray-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-50 hover:border-gray-400 transition-colors text-sm font-medium"
              >
                Previous
              </button>
              {Array.from({ length: totalPages }).map((_, i) => {
                const idx = i + 1;
                return (
                  <button
                    key={idx}
                    onClick={() => setPage(idx)}
                    className={`px-3 py-2 rounded-lg transition-colors text-sm font-medium ${
                      idx === page
                        ? "bg-emerald-600 text-white shadow-sm"
                        : "border border-gray-300 hover:bg-gray-50 hover:border-gray-400"
                    }`}
                  >
                    {idx}
                  </button>
                );
              })}
              <button
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page >= totalPages}
                className="px-4 py-2 rounded-lg border border-gray-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-50 hover:border-gray-400 transition-colors text-sm font-medium"
              >
                Next
              </button>
            </div>
          )}
        </div>

        {/* Create Post Modal */}
        <CreatePostModal
          open={isCreatePostModalOpen}
          onOpenChange={setIsCreatePostModalOpen}
          onSuccess={handleCreatePostSuccess}
        />
      </div>
    );
  }

  // DETAIL VIEW
  const blocks = parsePostContent(selectedPost.content);
  const mediaList = Array.isArray(selectedPost.media) ? selectedPost.media : [];

  const firstImageMedia =
    mediaList.find((m) => m.mediaType === "IMAGE")?.mediaUrl || null;
  const firstImgFromBlocks = blocks.find((b) => b.type === "img")?.content;
  const coverImage =
    firstImageMedia || selectedPost.thumbnail || firstImgFromBlocks || null;

  const firstMediaIsVideo =
    mediaList.length > 0 && mediaList[0].mediaType === "VIDEO";
  const videoUrl = firstMediaIsVideo ? mediaList[0].mediaUrl : null;

  const allMediaForModal = mediaList.map((m) => ({
    mediaUrl: m.mediaUrl,
    mediaType: m.mediaType,
  }));

  const openModal = (index) => {
    setModalIndex(index);
    setIsModalOpen(true);
  };

  const handleModalNavigate = (direction) => {
    if (direction === "prev" && modalIndex > 0) {
      setModalIndex(modalIndex - 1);
    } else if (
      direction === "next" &&
      modalIndex < allMediaForModal.length - 1
    ) {
      setModalIndex(modalIndex + 1);
    }
  };

  return (
    <div className="min-h-[90vh] bg-white">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Back button and Action buttons */}
        <div className="flex items-center justify-between mb-6">
          <button
            onClick={handleBack}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors text-sm font-medium"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Community</span>
          </button>
          
          {/* Edit and Delete buttons - only show if post belongs to current user */}
          {isMyPost(selectedPost) && (
            <div className="flex items-center gap-2">
              <button
                onClick={(e) => handleEditPost(e, selectedPost)}
                disabled={loadingPostForEdit}
                className="flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 transition-colors text-sm font-medium shadow-sm hover:shadow-md disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Edit className="w-4 h-4" />
                {loadingPostForEdit ? "Loading..." : "Edit"}
              </button>
              <button
                onClick={(e) => handleDeletePost(e, selectedPost.id)}
                disabled={deletingPostId === selectedPost.id}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg text-white transition-colors text-sm font-medium shadow-sm hover:shadow-md ${
                  deletingPostId === selectedPost.id
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-red-600 hover:bg-red-700"
                }`}
              >
                <Trash2 className="w-4 h-4" />
                {deletingPostId === selectedPost.id ? "Deleting..." : "Delete"}
              </button>
            </div>
          )}
        </div>

        {/* Post Card */}
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden mb-6">
          <div className="p-6 sm:p-8">
            <div className="flex items-start justify-between mb-4">
              <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 flex-1">
                {selectedPost.title}
              </h1>
              {/* Tag badge - only show if post belongs to current user */}
              {isMyPost(selectedPost) && (
                <span className="inline-flex items-center px-3 py-1.5 rounded-md text-sm font-semibold bg-emerald-600 text-white shadow-sm ml-4">
                  My Post
                </span>
              )}
            </div>

            {selectedPost.description && (
              <p className="text-gray-600 text-base mb-6 leading-relaxed">
                {selectedPost.description}
              </p>
            )}

            {/* Author and metadata */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 text-sm text-gray-600 pb-6 border-b border-gray-200">
              <div className="flex items-center gap-3">
                <img
                  src={
                    selectedPost.account?.avatarUrl ||
                    "https://ui-avatars.com/api/?background=00D09E&color=fff&name=U"
                  }
                  alt={selectedPost.account?.username}
                  className="w-10 h-10 rounded-full border-2 border-emerald-200"
                />
                <div>
                  <div className="font-medium text-gray-900">
                    @{selectedPost.account?.username}
                  </div>
                  <div className="text-xs text-gray-500">
                    {formatDateRelative(selectedPost.createdAt)}
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-4 text-sm">
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4" />
                  <span>
                    {new Date(
                      parseDateFlexible(selectedPost.createdAt)
                    ).toLocaleDateString("en-US", {
                      day: "2-digit",
                      month: "short",
                      year: "numeric",
                    })}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <MessageSquare className="w-4 h-4" />
                  <span>{selectedPost.commentCount ?? selectedPost.comments?.length ?? 0} Comments</span>
                </div>
              </div>
            </div>
          </div>

          {/* Cover Image/Video */}
          <div
            className="relative overflow-hidden cursor-pointer group bg-gray-100"
            onClick={() => allMediaForModal.length > 0 && openModal(0)}
          >
            <div className="w-full flex items-center justify-center h-64 md:h-80 lg:h-[420px] transition-all duration-200">
              {videoUrl ? (
                <video
                  src={videoUrl}
                  controls
                  preload="metadata"
                  className="w-full h-full object-cover object-center bg-black relative z-10"
                  onClick={(e) => e.stopPropagation()}
                >
                  Your browser does not support the video tag.
                </video>
              ) : coverImage ? (
                <img
                  src={coverImage}
                  alt="cover"
                  className="w-full h-full object-cover object-center transition-transform group-hover:scale-105"
                />
              ) : (
                <div className="px-6">
                  <MessageSquare className="w-16 h-16 text-gray-400" />
                </div>
              )}
            </div>
          </div>

          {/* Content */}
          <div className="p-6 sm:p-8">
            <div className="prose max-w-none text-gray-700">
              <RenderBlocks blocks={blocks} />
            </div>
          </div>

          {/* Media gallery */}
          {mediaList.length > 1 && (
            <div className="px-6 sm:px-8 pb-6 grid grid-cols-3 gap-3">
              {mediaList.slice(1, 7).map((m, idx) => {
                const actualIndex = idx + 1;
                return (
                  <div
                    key={idx}
                    className="relative cursor-pointer group hover:shadow-lg transition-all rounded-lg overflow-hidden"
                    onClick={() => openModal(actualIndex)}
                  >
                    {m.mediaType === "VIDEO" ? (
                      <div className="relative">
                        <video
                          src={m.mediaUrl}
                          className="w-full h-28 object-cover"
                          onClick={(e) => e.stopPropagation()}
                        />
                        <div className="absolute inset-0 flex items-center justify-center bg-black/30 pointer-events-none">
                          <Video className="w-8 h-8 text-white" />
                        </div>
                      </div>
                    ) : (
                      <img
                        src={m.mediaUrl}
                        alt={`m${idx}`}
                        className="w-full h-28 object-cover transition-transform group-hover:scale-105"
                      />
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* COMMENTS */}
        <section
          ref={commentsRef}
          className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 sm:p-8"
        >
          {showComments ? (
            <>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-gray-900">
                  Comments
                </h3>
                <div className="text-sm text-gray-500">
                  {selectedPost.comments && selectedPost.comments.length > 0
                    ? ""
                    : "Be the first to comment"}
                </div>
              </div>

              <div className="space-y-4">
                <CommentForm
                  avatarUrl={selectedPost.account?.avatarUrl}
                  onSubmit={(t) => createComment(selectedPost.id, t, null)}
                  submitting={commentSubmitting}
                />
                <div className="mt-6 space-y-4">
                  {selectedPost.comments && selectedPost.comments.length > 0 ? (
                    selectedPost.comments.map((c) => (
                      <div key={c.id}>
                        <CommentItem c={c} onReply={(id) => onReplyClick(id)} />
                        {replyingTo === c.id && (
                          <div className="mt-3 ml-12">
                            <CommentForm
                              avatarUrl={selectedPost.account?.avatarUrl}
                              onSubmit={(t) => onSubmitReply(t, c.id)}
                              submitting={replySubmitting}
                            />
                          </div>
                        )}
                      </div>
                    ))
                  ) : (
                    <p className="text-gray-500 text-center py-8">
                      No comments yet. Be the first to comment!
                    </p>
                  )}
                </div>
              </div>
            </>
          ) : (
            <div className="flex items-center justify-center">
              <button
                onClick={() => setShowComments(true)}
                className="px-6 py-3 rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 transition-colors font-medium shadow-sm hover:shadow-md"
              >
                View Comments ({selectedPost.commentCount ?? selectedPost.comments?.length ?? 0})
              </button>
            </div>
          )}
        </section>
      </div>

      {/* Media Modal */}
      <MediaModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        mediaList={allMediaForModal}
        currentIndex={modalIndex}
        onNavigate={handleModalNavigate}
      />

      {/* Edit Post Modal */}
      <EditPostModal
        open={isEditPostModalOpen}
        onOpenChange={setIsEditPostModalOpen}
        onSuccess={handleEditPostSuccess}
        post={postToEdit}
      />
    </div>
  );
};

export default CommunityPosts;
