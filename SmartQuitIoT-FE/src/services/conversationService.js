// src/services/conversationService.js
import instance from "@/config/axiosConfig";

export const getConversations = (page = 0, size = 50) => {
  return instance.get(`/conversations?page=${page}&size=${size}`);
};

export const getMessages = (
  conversationId,
  { beforeId = null, limit = 200 } = {}
) => {
  const q = new URLSearchParams();
  if (beforeId) q.append("beforeId", beforeId);
  q.append("limit", limit);
  return instance.get(
    `/conversations/${conversationId}/messages?${q.toString()}`
  );
};

export const postMessage = (payload) => {
  // payload: { conversationId?, targetUserId?, targetMemberId?, content, messageType }
  return instance.post(`/conversations/messages`, payload);
};

export const markAsRead = (conversationId) => {
  return instance.post(`/conversations/${conversationId}/read`);
};

export default {
  getConversations,
  getMessages,
  postMessage,
  markAsRead,
};
