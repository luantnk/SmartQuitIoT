import instance from "@/config/axiosConfig";

// export const getAllPagedCoaches = async (
//   page,
//   size,
//   search,
//   sortBy,
//   isActive
// ) => {
//   return instance.get(
//     `/coaches/all?page=${page}&size=${size}&searchString=${search}&sortBy=${sortBy}&isActive=${isActive}`
//   );
// };
/**
 * Get authenticated coach profile
 * @returns {Promise} Response with CoachDTO
 */
export const getAuthenticatedCoach = async () => {
  return instance.get("/coaches/p");
};

/**
 * Update coach profile
 * @param {number} coachId - Coach ID
 * @param {Object} data - CoachUpdateRequest data
 * @returns {Promise} Response with CoachDTO
 */
export const updateCoachProfile = async (coachId, data) => {
  return instance.put(`/coaches/${coachId}`, data);
};

/**
 * Get coach statistics
 * @returns {Promise} Response with statistics data (e.g., { totalCoaches: number })
 */
export const getCoachStatistics = async () => {
  return instance.get("/coaches/statistics");
};

/**
 * Get all coaches with pagination (Admin only)
 * @param {number} page - Page number (0-indexed)
 * @param {number} size - Page size
 * @param {string} searchString - Search string (optional)
 * @param {string} sortBy - Sort direction ("ASC" or "DESC")
 * @returns {Promise} Response with paginated CoachDTO list
 */
export const getAllPagedCoaches = async (
  page = 0,
  size = 10,
  searchString = "",
  sortBy = "ASC"
) => {
  const params = {
    page,
    size,
    sortBy,
  };

  if (searchString) {
    params.searchString = searchString;
  }

  return instance.get("/coaches/all", { params });
};

/**
 * Get coach by ID
 * @param {number|string} coachId - Coach ID
 * @returns {Promise} Response with CoachDTO
 */
export const getCoachById = async (coachId) => {
  return instance.get(`/coaches/${coachId}`);
};
