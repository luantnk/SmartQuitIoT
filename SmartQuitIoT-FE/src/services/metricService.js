import instance from "@/config/axiosConfig";

export const getMemberMetrics = async (memberId) => {
  return instance.get(`/metrics/health-data/${memberId}`);
};
// Swagger trả về :
// http://localhost:8080/api/metrics/health-data/1
// Server response
// Code	Details
// 200
// Response body
// Download
// {
//  "healthRecoveries": [
//   {
//     "id": 1,
//     "name": "PULSE_RATE",
//     "value": 100,
//     "description": "Pulse rate returns to normal",
//     "timeTriggered": "2025-11-08T15:58:38.074575",
//     "recoveryTime": 20,
//     "targetTime": "2025-11-08T15:58:38.074575"
//   },
//   {
//     "id": 2,
//     "name": "OXYGEN_LEVEL",
//     "value": 100,
//     "description": "Oxygen level in blood returns to normal",
//     "timeTriggered": "2025-11-08T15:58:38.159499",
//     "recoveryTime": 480,
//     "targetTime": "2025-11-08T15:58:38.159499"
//   },
//   {
//     "id": 3,
//     "name": "CARBON_MONOXIDE_LEVEL",
//     "value": 100,
//     "description": "Carbon monoxide level in blood returns to normal",
//     "timeTriggered": "2025-11-08T15:58:38.164015",
//     "recoveryTime": 720,
//     "targetTime": "2025-11-08T15:58:38.164015"
//   },
//   {
//     "id": 4,
//     "name": "TASTE_AND_SMELL",
//     "value": 100,
//     "description": "Taste and smell improvement",
//     "timeTriggered": "2025-11-08T15:58:38.16953",
//     "recoveryTime": 1440,
//     "targetTime": "2025-11-08T15:58:38.16953"
//   },
//   {
//     "id": 5,
//     "name": "NICOTINE_EXPELLED_FROM_BODY",
//     "value": 100,
//     "description": "Nicotine is expelled from body",
//     "timeTriggered": "2025-11-08T15:58:38.17453",
//     "recoveryTime": 4320,
//     "targetTime": "2025-11-08T15:58:38.17453"
//   },
//   {
//     "id": 6,
//     "name": "CIRCULATION",
//     "value": null,
//     "description": "Circulation and lung function improvement",
//     "timeTriggered": "2025-11-08T15:58:38.179102",
//     "recoveryTime": 20160,
//     "targetTime": "2025-11-08T15:58:38.179102"
//   },
//   {
//     "id": 7,
//     "name": "BREATHING",
//     "value": null,
//     "description": "Coughing and breathing improvement",
//     "timeTriggered": "2025-11-08T15:58:38.183101",
//     "recoveryTime": 43200,
//     "targetTime": "2025-11-08T15:58:38.183101"
//   },
//   {
//     "id": 8,
//     "name": "REDUCED_RISK_OF_HEART_DISEASE",
//     "value": null,
//     "description": "Reduced risk of heart disease",
//     "timeTriggered": "2025-11-08T15:58:38.187417",
//     "recoveryTime": 525600,
//     "targetTime": "2025-11-08T15:58:38.187417"
//   },
//   {
//     "id": 9,
//     "name": "DECREASED_RISK_OF_HEART_ATTACK",
//     "value": null,
//     "description": "Stroke risk and Heart attack reduction",
//     "timeTriggered": "2025-11-08T15:58:38.192615",
//     "recoveryTime": 2628000,
//     "targetTime": "2025-11-08T15:58:38.192615"
//   },
//   {
//     "id": 10,
//     "name": "IMMUNITY_AND_LUNG_FUNCTION",
//     "value": null,
//     "description": "Your risk of lung cancer falls to about half that of a smoker and your risk of cancer of the mouth, throat, esophagus, bladder, cervix, and pancreas decreases.",
//     "timeTriggered": "2025-11-08T15:58:38.196635",
//     "recoveryTime": 5256000,
//     "targetTime": "2025-11-08T15:58:38.196635"
//   }
// ],
//   "metrics": {
//     "id": 1,
//     "streaks": 0,
//     "relapseCountInPhase": 0,
//     "post_count": 0,
//     "comment_count": 0,
//     "total_mission_completed": 0,
//     "completed_all_mission_in_day": 0,
//     "avgCravingLevel": 0,
//     "avgMood": 0,
//     "avgAnxiety": 0,
//     "avgConfidentLevel": 0,
//     "avgCigarettesPerDay": 0,
//     "currentCravingLevel": 0,
//     "currentMoodLevel": 0,
//     "currentConfidenceLevel": 0,
//     "currentAnxietyLevel": 0,
//     "steps": 0,
//     "heartRate": 0,
//     "spo2": 0,
//     "sleepDuration": 0,
//     "annualSaved": 0,
//     "moneySaved": 0,
//     "reductionPercentage": 0,
//     "smokeFreeDayPercentage": 0,
//     "createdAt": "2025-11-08T12:31:37.778661",
//     "updatedAt": "2025-11-08T12:31:37.778661"
//   }
// }
