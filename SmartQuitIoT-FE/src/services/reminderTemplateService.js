import instance from "@/config/axiosConfig";

export const getAllReminderTemplates = async (page, size, search = "") => {
  const params = new URLSearchParams();
  params.append("page", page);
  params.append("size", size);
  if (search) params.append("search", search);
  
  return instance.get(`/reminder/all?${params.toString()}`);
};

export const updateReminderTemplate = async (id, data) => {
  return instance.put(`/reminder/update/${id}`, data);
};
