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

/**
 * Get all notifications with pagination (POST method)
 * @param {Object} request - Request body
 * @param {number} request.page - Page number (default: 0)
 * @param {number} request.size - Page size (default: 20)
 * @param {boolean} request.isRead - Filter by read status (optional)
 * @returns {Promise<Object>} Response with content array and page info
 */
const getAllNotifications = async (request = {}) => {
  try {
    const { page = 0, size = 20, isRead } = request;
    const body = { page, size };
    if (isRead !== undefined) body.isRead = isRead;

    const res = await instance.post("/notifications/all", body);
    return unwrap(res);
  } catch (err) {
    console.error("notificationService.getAllNotifications error:", err);
    throw err;
  }
};

/**
 * Get appointment notifications with pagination (GET method)
 * @param {Object} params - Query parameters
 * @param {number} params.page - Page number (default: 0)
 * @param {number} params.size - Page size (default: 20)
 * @param {boolean} params.isRead - Filter by read status (optional)
 * @returns {Promise<Object>} Response with content array and page info
 */
const getAppointmentNotifications = async (params = {}) => {
  try {
    const { page = 0, size = 20, isRead } = params;
    const queryParams = { page, size };
    if (isRead !== undefined) queryParams.isRead = isRead;

    const res = await instance.get("/notifications/mine/appointments", {
      params: queryParams,
    });
    return unwrap(res);
  } catch (err) {
    console.error(
      "notificationService.getAppointmentNotifications error:",
      err
    );
    throw err;
  }
};

/**
 * Mark notification as read
 * @param {number} notificationId - Notification ID
 * @returns {Promise<boolean>}
 */
const markAsRead = async (notificationId) => {
  try {
    await instance.put(`/notifications/${notificationId}/read`);
    return true;
  } catch (err) {
    console.error("notificationService.markAsRead error:", err);
    throw err;
  }
};

/**
 * Mark all notifications as read
 * @returns {Promise<number>} Number of notifications marked as read
 */
const markAllAsRead = async () => {
  try {
    const res = await instance.put("/notifications/read-all");
    const data = unwrap(res);
    // Backend returns the count of updated records
    return typeof data === "number" ? data : 0;
  } catch (err) {
    console.error("notificationService.markAllAsRead error:", err);
    throw err;
  }
};

/**
 * Soft delete all notifications
 * @returns {Promise<number>} Number of notifications deleted
 */
const deleteAll = async () => {
  try {
    const res = await instance.delete("/notifications/delete-all");
    const data = unwrap(res);
    // Backend returns the count of deleted records
    return typeof data === "number" ? data : 0;
  } catch (err) {
    console.error("notificationService.deleteAll error:", err);
    throw err;
  }
};

/**
 * Soft delete one notification
 * @param {number} notificationId - Notification ID
 * @returns {Promise<boolean>}
 */
const deleteOne = async (notificationId) => {
  try {
    await instance.delete(`/notifications/${notificationId}`);
    return true;
  } catch (err) {
    console.error("notificationService.deleteOne error:", err);
    throw err;
  }
};

/**
 * Get unread count
 * @returns {Promise<number>}
 */
const getUnreadCount = async () => {
  try {
    const res = await instance.get("/notifications/mine/appointments", {
      params: { page: 0, size: 1, isRead: false },
    });
    const data = unwrap(res);
    return data?.page?.totalElements || 0;
  } catch (err) {
    console.error("notificationService.getUnreadCount error:", err);
    return 0;
  }
};

export const getAllSystemNotifications = (page, size) => {
  return instance.get(
    `/notifications/system-activity?page=${page}&size=${size}`
  );
};

export default {
  getAllNotifications,
  getAppointmentNotifications,
  markAsRead,
  markAllAsRead,
  deleteAll,
  deleteOne,
  getUnreadCount,
};
