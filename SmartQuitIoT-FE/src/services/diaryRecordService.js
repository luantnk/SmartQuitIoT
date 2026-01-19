import instance from "@/config/axiosConfig";

export const getDiaryRecordChartsByMemberId = async (memberId) => {
  return instance.get(`/diary-records/charts/${memberId}`);
};

export const getDiaryRecordHistoryByMemberId = async (memberId) => {
  return instance.get(`/diary-records/history/${memberId}`);
};
