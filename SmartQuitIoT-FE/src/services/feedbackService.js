import instance from "@/config/axiosConfig";

const unwrap = (res) => {
  if (!res) return null;
  if (res.data && Object.prototype.hasOwnProperty.call(res.data, "data")) {
    return res.data.data;
  }
  return res.data;
};

export const getFeedbacksForCoach = async (page = 0, size = 8) => {
  const res = await instance.get("/coach/feedbacks", {
    params: { page, size },
  });
  return unwrap(res);
};

export const getFeedbacksByCoachIdForAdmin = async (
  coachId,
  page = 0,
  size = 8
) => {
  const res = await instance.get(`/admin/coaches/${coachId}/feedbacks`, {
    params: { page, size },
  });
  return unwrap(res);
};
