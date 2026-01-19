// src/services/newsService.js
import instance from "@/config/axiosConfig";

/**
 * Helper unwrap: hỗ trợ backend bọc response trong { data: ... } hoặc trả trực tiếp
 */
const unwrap = (res) => {
  if (!res) return null;
  if (res.data && Object.prototype.hasOwnProperty.call(res.data, "data")) {
    return res.data.data;
  }
  return res.data;
};

const getLatest = async (limit = 5) => {
  try {
    const res = await instance.get("/news/latest", { params: { limit } });
    return unwrap(res);
  } catch (err) {
    console.error("newsService.getLatest error:", err);
    throw err;
  }
};

const getAll = async (query = "") => {
  try {
    const params = {};
    if (query && String(query).trim() !== "") params.query = query;
    const res = await instance.get("/news", { params });
    return unwrap(res);
  } catch (err) {
    console.error("newsService.getAll error:", err);
    throw err;
  }
};

const getNews = async (id) => {
  try {
    const res = await instance.get(`/news/${id}`);
    return unwrap(res);
  } catch (err) {
    console.error("newsService.getNews error:", err);
    throw err;
  }
};

/**
 * createNews payload example:
 * {
 *   title: "Tiêu đề",
 *   content: "Nội dung",
 *   thumbnailUrl: "https://res.cloudinary.com/yourcloud/...",
 *   mediaUrls: ["https://res.cloudinary.com/yourcloud/..", ...] // optional
 * }
 */
const createNews = async (payload) => {
  try {
    const res = await instance.post("/news", payload);
    return unwrap(res);
  } catch (err) {
    console.error("newsService.createNews error:", err);
    throw err;
  }
};

const updateNews = async (id, payload) => {
  try {
    const res = await instance.put(`/news/${id}`, payload);
    return unwrap(res);
  } catch (err) {
    console.error("newsService.updateNews error:", err);
    throw err;
  }
};

const deleteNews = async (id) => {
  try {
    // controller returns 200 OK void
    await instance.delete(`/news/${id}`);
    return true;
  } catch (err) {
    console.error("newsService.deleteNews error:", err);
    throw err;
  }
};

const getAllWithFilters = async ({ status, title, page = 0, size = 6, sort = "createdAt,desc" } = {}) => {
  try {
    const params = { page, size, sort };
    if (status) params.status = status;
    if (title && title.trim()) params.title = title.trim();
    
    const res = await instance.get("/news/admin", { params });
    return unwrap(res);
  } catch (err) {
    console.error("newsService.getAllWithFilters error:", err);
    throw err;
  }
};

export default {
  getLatest,
  getAll,
  getNews,
  createNews,
  updateNews,
  deleteNews,
  getAllWithFilters,
};
