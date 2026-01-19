// src/services/commentService.js
import instance from "@/config/axiosConfig";

const unwrap = (res) => {
  if (!res) return null;
  if (res.data && Object.prototype.hasOwnProperty.call(res.data, "data")) {
    return res.data.data;
  }
  return res.data;
};

/**
 * Normalize media item (PostMediaDTO)
 */
const normalizeMedia = (m = {}) => ({
  id: m.id ?? null,
  mediaUrl: m.mediaUrl ?? m.url ?? "",
  mediaType: m.mediaType ?? m.type ?? "",
});

/**
 * Normalize account DTO (AccountDTO inside PostDetailDTO)
 */
const normalizeAccount = (a = {}) => {
  if (!a) return null;
  return {
    id: a.id ?? null,
    username: a.username ?? a.userName ?? "",
    firstName: a.firstName ?? "",
    lastName: a.lastName ?? "",
    email: a.email ?? "",
    avatarUrl: a.avatarUrl ?? a.avatar ?? "",
  };
};

/**
 * Normalize a single comment (recursive for replies)
 * Expected raw shape (PostDetailDTO.CommentDTO):
 * {
 *   id, content, createdAt, account, media, replies
 * }
 */
const normalizeComment = (raw = {}) => {
  if (!raw) return null;
  const createdAt = raw.createdAt ? new Date(raw.createdAt) : null;

  const media = Array.isArray(raw.media) ? raw.media.map(normalizeMedia) : [];
  const replies = Array.isArray(raw.replies)
    ? raw.replies.map(normalizeComment)
    : [];

  return {
    id: raw.id ?? null,
    content: raw.content ?? "",
    avatarUrl: raw.avatarUrl ?? "",
    createdAt,
    account: normalizeAccount(raw.account),
    media,
    replies,
  };
};

/* ------------------------
   API calls
   ------------------------ */

/**
 * Get comments for a post (returns array of normalized comments)
 * GET /posts/{postId}/comments
 */
const getCommentsByPostId = async (postId) => {
  const res = await instance.get(`/posts/${postId}/comments`);
  const data = unwrap(res);
  if (!Array.isArray(data)) {
    // If server returned wrapper { items: [...], meta: ... }
    const arr = data?.items ?? data?.data ?? [];
    if (!Array.isArray(arr)) return [];
    return arr.map(normalizeComment);
  }
  return data.map(normalizeComment);
};

/**
 * Create a comment (or reply) on post
 * POST /posts/{postId}/comments
 * payload: { content: string, parentId?: number | null }
 * Returns normalized created comment object
 */
const createComment = async (postId, payload) => {
  const res = await instance.post(`/posts/${postId}/comments`, payload);
  const created = unwrap(res);
  // created might be a comment object
  return normalizeComment(created);
};

/**
 * Update a comment
 * PUT /posts/comments/{commentId}
 * payload: { content?: string, media?: [...] }
 * Returns normalized updated comment
 */
const updateComment = async (commentId, payload) => {
  const res = await instance.put(`/posts/comments/${commentId}`, payload);
  const updated = unwrap(res);
  return normalizeComment(updated);
};

/**
 * Delete comment
 * DELETE /posts/comments/{commentId}
 * Returns backend response (unwrapped) or true/false
 */
const deleteComment = async (commentId) => {
  const res = await instance.delete(`/posts/comments/${commentId}`);
  const data = unwrap(res);
  // if backend returns message or boolean, forward it; otherwise return true
  return data ?? true;
};

export default {
  getCommentsByPostId,
  createComment,
  updateComment,
  deleteComment,
};
