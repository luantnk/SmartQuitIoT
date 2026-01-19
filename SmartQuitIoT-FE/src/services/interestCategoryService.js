import instance from "@/config/axiosConfig";

export const getAllInterestCategories = async () => {
  return instance.get("/interest-category/all");
};
