import instance from "@/config/axiosConfig";

/**
 * Get dashboard statistics
 * @returns {Promise} Response with DashboardStatisticsDTO
 */
export const getDashboardStatistics = async () => {
  return instance.get("/statistics/dashboard");
};
