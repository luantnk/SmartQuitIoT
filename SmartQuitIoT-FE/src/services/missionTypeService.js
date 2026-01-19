import instance from "@/config/axiosConfig";

export const getAllMissionTypes = async () => {
  return instance.get("/mission-type/all");
};
