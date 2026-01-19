// src/api/conversations.js
import conversationService from "@/services/conversationService";

/**
 * Thin wrapper that unwraps backend GlobalResponse shape:
 * { success, message, data, code, timestamp }
 * Returns data or throws.
 */

const unwrap = (resp) => {
  if (!resp || !resp.data) throw new Error("Empty response");
  const payload = resp.data;
  if (Object.prototype.hasOwnProperty.call(payload, "data"))
    return payload.data;
  // fallback: maybe backend returned array directly
  if (Array.isArray(payload)) return payload;
  return payload;
};

export const fetchConversations = async (opts = { page: 0, size: 50 }) => {
  const resp = await conversationService.getConversations(opts.page, opts.size);
  return unwrap(resp);
};

export const fetchMessages = async (
  conversationId,
  opts = { beforeId: null, limit: 200 }
) => {
  const resp = await conversationService.getMessages(conversationId, opts);
  return unwrap(resp);
};

export const sendMessage = async (payload) => {
  const resp = await conversationService.postMessage(payload);
  return unwrap(resp);
};

export const markConversationRead = async (conversationId) => {
  const resp = await conversationService.markAsRead(conversationId);
  return unwrap(resp);
};

export default {
  fetchConversations,
  fetchMessages,
  sendMessage,
  markConversationRead,
};
