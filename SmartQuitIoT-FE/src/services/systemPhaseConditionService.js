import instance from "@/config/axiosConfig";

export const getAllSystemPhaseConditions = async () => {
  return instance.get(`/system-phase-condition`);
};

export const updateSystemPhaseCondition = async (id, conditionData) => {
  return instance.put(`/system-phase-condition/${id}`, conditionData);
};
