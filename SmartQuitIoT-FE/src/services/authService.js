import instance from "@/config/axiosConfig";

export const login = async (loginBody) => {
  return instance.post(`/auth/system`, loginBody);
};
