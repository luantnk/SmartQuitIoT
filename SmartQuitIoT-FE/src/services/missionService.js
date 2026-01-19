import instance from "@/config/axiosConfig";

export const getAllMission = async (page, size, search = "", status = "", phase = "") => {
  const params = new URLSearchParams();
  params.append("page", page);
  params.append("size", size);
  if (search) params.append("search", search);
  if (status && status !== "all") params.append("status", status);
  if (phase && phase !== "all") params.append("phase", phase);
  
  return instance.get(`/missions?${params.toString()}`);
};

export const getMissionById = async (id) => {
  return instance.get(`/missions/${id}`);
};

export const createMission = async (missionData) => {
  return instance.post("/missions", missionData);
};

export const updateMission = async (id, missionData) => {
  return instance.put(`/missions/${id}`, missionData);
};

export const deleteMission = async (id) => {
  return instance.delete(`/missions/${id}`);
};
