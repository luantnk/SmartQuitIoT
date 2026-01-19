// src/services/achievementService.js
import instance from "@/config/axiosConfig";

export const getAllAchievements = async (page, size, search) => {
  return instance.get(
    `/achievement/all?page=${page}&size=${size}&search=${search}`
  );
};

export const getAchievementById = async (id) => {
  return instance.get(`/achievement/${id}`);
};

export const createAchievement = async (data) => {
  return instance.post("/achievement/create-new", data);
};

export const updateAchievement = async (id, data) => {
  return instance.put(`/achievement/update/${id}`, data);
};

export const deleteAchievement = async (id) => {
  return instance.delete(`/achievement/delete/${id}`);
};
