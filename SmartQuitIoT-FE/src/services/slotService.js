import instance from "@/config/axiosConfig";

export const getAllSlots = async (page, size) => {
  return instance.get(`/slots?page=${page}&size=${size}`);
};

export const reseedSlots = async (start, end, slotMinutes, gapMinutes) => {
  return instance.post(`/slots/reseed`, {
    start,
    end,
    slotMinutes,
    gapMinutes,
  });
};
