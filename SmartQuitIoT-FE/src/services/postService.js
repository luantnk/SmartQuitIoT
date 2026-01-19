// src/services/postService.js
import instance from "@/config/axiosConfig";

/** Helper để lấy payload thực tế <vì APi của Luân có chỗ bọc trong data, có chỗ không> */
const unwrap = (res) => {
  if (!res) return null;
  if (res.data && Object.prototype.hasOwnProperty.call(res.data, "data")) {
    return res.data.data;
  }
  return res.data;
};

/** normalize summary item (light parsing) */
const normalizePostSummary = (raw = {}) => {
  return {
    id: raw.id ?? null,
    title: raw.title ?? "",
    description: raw.description ?? "",
    thumbnail: raw.thumbnail ?? "",
    mediaUrls: raw.mediaUrls ?? "",
    mediaUrl: raw.mediaUrl ?? "",
    createdAt: raw.createdAt ? new Date(raw.createdAt) : null,
    account: raw.account ?? null, // may be {id, username, ...}
    commentCount: raw.commentCount ?? 0,
  };
};

/** normalize PostDetailDTO: parse dates, ensure arrays, normalize comments recursively */
const normalizePostDetail = (raw) => {
  if (!raw) return null;

  const normalizeComments = (list) => {
    if (!Array.isArray(list)) return [];
    return list.map((c) => ({
      id: c.id ?? null,
      content: c.content ?? "",
      createdAt: c.createdAt ? new Date(c.createdAt) : null,
      account: c.account ?? null,
      media: Array.isArray(c.media) ? c.media.map((m) => ({ ...m })) : [],
      replies: normalizeComments(c.replies),
    }));
  };

  return {
    id: raw.id ?? null,
    title: raw.title ?? "",
    content: raw.content ?? "",
    description: raw.description ?? "",
    thumbnail: raw.thumbnail ?? "",
    createdAt: raw.createdAt ? new Date(raw.createdAt) : null,
    updatedAt: raw.updatedAt ? new Date(raw.updatedAt) : null,
    account: raw.account ?? null,
    media: Array.isArray(raw.media) ? raw.media.map((m) => ({ ...m })) : [],
    comments: normalizeComments(raw.comments),
    commentCount: raw.commentCount ?? 0,
  };
};

/* ---------------- API calls ---------------- */

const getPosts = async (params = {}) => {
  const res = await instance.get("/posts", { params });
  const data = unwrap(res);
  if (!Array.isArray(data)) return data;
  return data.map(normalizePostSummary);
};
// http://localhost:8080/api/posts?query=hhaaa // nếu query không truyền gì thì lấy all
// Server response
// Code	Details
// 200
// Response body
// Download
// {
//   "success": true,
//   "message": "OK",
//   "data": [
//     {
//       "id": 2,
//       "title": "hhaaa",
//       "description": "12222",
//       "thumbnail": "",
//       "createdAt": "2025-11-10T17:21:15.726482",
//       "account": {
//         "id": 2,
//         "username": "member1",
//         "firstName": "mem",
//         "lastName": "mem",
//         "avatarUrl": "https://ui-avatars.com/api/?background=00D09E&color=fff&size=250&name=member1"
//       }
//     }
//   ],
//   "code": 200,
//   "timestamp": 1762770733841
// }

const getLatestPosts = async (limit = 5) => {
  const res = await instance.get("/posts/latest", { params: { limit } });
  const data = unwrap(res);
  if (!Array.isArray(data)) return data;
  return data.map(normalizePostSummary);
};

const getPostDetail = async (id) => {
  const res = await instance.get(`/posts/${id}`);
  const data = unwrap(res);
  return normalizePostDetail(data);
};
// GET http://localhost:8080/api/posts/2
// Server response
// Code	Details
// 200
// Response body
// Download
// {
//   "success": true,
//   "message": "OK",
//   "data": {
//     "id": 2,
//     "title": "hhaaa",
//     "content": "[{\"insert\":\"\\t\\tAnnjjj\\n\"}]",
//     "description": "12222",
//     "thumbnail": "",
//     "createdAt": "2025-11-10T17:21:15.726482",
//     "updatedAt": "2025-11-10T17:21:15.726482",
//     "account": {
//       "id": 2,
//       "username": "member1",
//       "firstName": "mem",
//       "email": "member1@smartquit.io.vn",
//       "lastName": "mem",
//       "avatarUrl": "https://ui-avatars.com/api/?background=00D09E&color=fff&size=250&name=member1"
//     },
//     "media": [],
//     "comments": []
//   },
//   "code": 200,
//   "timestamp": 1762771932040
// }

const createPost = async (payload) => {
  const url = "/posts";
  const res = await instance.post(url, payload);
  const data = unwrap(res);
  // nếu backend trả chi tiết bài mới, normalize luôn
  return normalizePostDetail(data) ?? data;
};

const updatePost = async (postId, payload) => {
  const url = `/posts/${postId}`;
  const res = await instance.put(url, payload);
  const data = unwrap(res);
  return normalizePostDetail(data) ?? data;
};

const deletePost = async (postId) => {
  const res = await instance.delete(`/posts/${postId}`);
  return unwrap(res);
};

const getAllMyPosts = async () => {
  const res = await instance.get("/posts/my-posts");
  const data = unwrap(res);
  if (!Array.isArray(data)) return data;
  return data.map(normalizePostSummary);
};

export default {
  getPosts,
  getLatestPosts,
  getPostDetail,
  createPost,
  updatePost,
  deletePost,
  getAllMyPosts,
};
