import instance from "@/config/axiosConfig";

export const getAllPayments = async (page, size, search) => {
  return instance.get(
    `/payments/all?page=${page}&size=${size}&search=${search}`
  );
};
