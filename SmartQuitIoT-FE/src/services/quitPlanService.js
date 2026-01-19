import instance from "@/config/axiosConfig";

export const getQuitPlanByMemberId = async (memberId) => {
  return instance.get(`/quit-plan/${memberId}`);
};

// Swagger trả về :
// http://localhost:8080/api/quit-plan/1
// {
//   "id": 1,
//   "name": "dat",
//   "status": "IN_PROGRESS",
//   "startDate": "2025-11-08",
//   "endDate": "2026-01-01",
//   "useNRT": false,
//   "ftndScore": 2,
//   "formMetricDTO": {
//     "id": 1,
//     "smokeAvgPerDay": 2,
//     "numberOfYearsOfSmoking": 2,
//     "cigarettesPerPackage": 10,
//     "minutesAfterWakingToSmoke": 30,
//     "smokingInForbiddenPlaces": false,
//     "cigaretteHateToGiveUp": false,
//     "morningSmokingFrequency": false,
//     "smokeWhenSick": false,
//     "moneyPerPackage": 10000,
//     "estimatedMoneySavedOnPlan": 110000,
//     "amountOfNicotinePerCigarettes": 1,
//     "estimatedNicotineIntakePerDay": 2,
//     "interests": [
//       "Sports and Exercise"
//     ],
//     "triggered": null
//   },
//   "phases": [
//     {
//       "id": 1,
//       "name": "Preparation",
//       "startDate": "2025-11-08",
//       "endDate": "2025-11-09",
//       "durationDay": 2,
//       "reason": "Based on your FTND score of 2, average smoking of 2 cigarettes per day, 2 years of smoking, age 24, and gender MALE, your preparation phase is set for 2 days to help you get ready to quit.",
//       "keepPhase": false,
//       "totalMissions": 8,
//       "completedMissions": 0,
//       "progress": 0,
//       "avg_craving_level": 0,
//       "avg_cigarettes": 0,
//       "fm_cigarettes_total": 0,
//       "condition": {
//         "logic": "AND",
//         "rules": [
//           {
//             "field": "progress",
//             "value": 80,
//             "operator": ">="
//           }
//         ]
//       },
//       "details": [
//         {
//           "id": 1,
//           "name": "Day 1",
//           "date": "2025-11-08",
//           "dayIndex": 1,
//           "missionCompleted": 0,
//           "totalMission": 0,
//           "missions": [
//             {
//               "id": 1,
//               "code": "PREP_LIST_TRIGGERS",
//               "name": "List Your Smoking Triggers",
//               "description": "List trigger events (Morning, After Meal, Gaming, Party, Coffee, Stress, Boredom, Driving, Sadness, Work). For each, define one alternative action you can take instead.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 2,
//               "code": "PREP_WRT_FUTURE_LETTER",
//               "name": "Write a Letter to Your Future Self",
//               "description": "Write a short letter to your future self about why you want to quit and how proud you will feel staying smoke free.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 3,
//               "code": "PREP_POST_TOP_REASON",
//               "name": "Post Your Top1 Reason Where You Can See It",
//               "description": "Choose your most important reason (health, family, savings, self-image) and place it somewhere highly visible as a daily motivator.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 4,
//               "code": "PREP_CLEAR_SMOKING_ITEMS",
//               "name": "Clear Out Smoking Items",
//               "description": "Remove all cigarettes, lighters, ashtrays, and related items from your home, workspace, and vehicle to break environmental cues.",
//               "status": "INCOMPLETED"
//             }
//           ]
//         },
//         {
//           "id": 2,
//           "name": "Day 2",
//           "date": "2025-11-09",
//           "dayIndex": 2,
//           "missionCompleted": 0,
//           "totalMission": 0,
//           "missions": [
//             {
//               "id": 5,
//               "code": "PREP_LEARN_HARMS",
//               "name": "Learn the Harms of Smoking",
//               "description": "Read a credible article or watch a short video about how smoking affects you, your family, and society. Summarize 3 takeaways.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 6,
//               "code": "PREP_TELL_SUPPORT_PERSON",
//               "name": "Tell a Close Friend or Family Member",
//               "description": "Tell someone you trust about your quit plan and ask them to check in on you.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 7,
//               "code": "PREP_BUDGET_SAVINGS_PLAN",
//               "name": "Plan Your Savings Reward",
//               "description": "Make a plan for how you will use your saved money from not buying cigarettes to purchase something you truly enjoy.",
//               "status": "INCOMPLETED"
//             },
//             {
//               "id": 8,
//               "code": "PREP_DELAY_FIRST_CIG",
//               "name": "Delay Your First Cigarette by 15–20 Minutes",
//               "description": "After waking up, wait 15–20 minutes before your first cigarette. Practice breathing or drink water to observe your habit loop.",
//               "status": "INCOMPLETED"
//             }
//           ]
//         }
//       ]
//     },
//     {
//       "id": 2,
//       "name": "Onset",
//       "startDate": "2025-11-10",
//       "endDate": "2025-11-13",
//       "durationDay": 4,
//       "reason": "Based on your FTND score of 2, average smoking of 2 cigarettes per day, 2 years of smoking, age 24, and gender MALE, your onset phase is set for 4 days as you begin your quit journey.",
//       "keepPhase": false,
//       "totalMissions": 0,
//       "completedMissions": 0,
//       "avg_craving_level": 0,
//       "avg_cigarettes": 0,
//       "fm_cigarettes_total": 0,
//       "condition": {
//         "logic": "AND",
//         "rules": [
//           {
//             "logic": "OR",
//             "rules": [
//               {
//                 "field": "craving_level_avg",
//                 "value": 8,
//                 "operator": "<="
//               },
//               {
//                 "field": "avg_cigarettes",
//                 "formula": {
//                   "base": "fm_cigarettes_total",
//                   "percent": 0.8,
//                   "operator": "*"
//                 },
//                 "operator": "<="
//               }
//             ]
//           },
//           {
//             "field": "progress",
//             "value": 80,
//             "operator": ">="
//           }
//         ]
//       },
//       "details": []
//     },
//     {
//       "id": 3,
//       "name": "Peak Craving",
//       "startDate": "2025-11-14",
//       "endDate": "2025-11-19",
//       "durationDay": 6,
//       "reason": "Based on your FTND score of 2, average smoking of 2 cigarettes per day, 2 years of smoking, age 24, and gender MALE, your peak craving phase is set for 6 days, as this is when cravings are typically strongest.",
//       "keepPhase": false,
//       "totalMissions": 0,
//       "completedMissions": 0,
//       "avg_craving_level": 0,
//       "avg_cigarettes": 0,
//       "fm_cigarettes_total": 0,
//       "condition": {
//         "logic": "AND",
//         "rules": [
//           {
//             "logic": "OR",
//             "rules": [
//               {
//                 "field": "craving_level_avg",
//                 "value": 7,
//                 "operator": "<="
//               },
//               {
//                 "field": "avg_cigarettes",
//                 "formula": {
//                   "base": "fm_cigarettes_total",
//                   "percent": 0.7,
//                   "operator": "*"
//                 },
//                 "operator": "<="
//               }
//             ]
//           },
//           {
//             "field": "progress",
//             "value": 80,
//             "operator": ">="
//           }
//         ]
//       },
//       "details": []
//     },
//     {
//       "id": 4,
//       "name": "Subsiding",
//       "startDate": "2025-11-20",
//       "endDate": "2025-12-02",
//       "durationDay": 13,
//       "reason": "Based on your FTND score of 2, average smoking of 2 cigarettes per day, 2 years of smoking, age 24, and gender MALE, your subsiding phase is set for 13 days, as cravings gradually decrease.",
//       "keepPhase": false,
//       "totalMissions": 0,
//       "completedMissions": 0,
//       "avg_craving_level": 0,
//       "avg_cigarettes": 0,
//       "fm_cigarettes_total": 0,
//       "condition": {
//         "logic": "AND",
//         "rules": [
//           {
//             "logic": "OR",
//             "rules": [
//               {
//                 "field": "craving_level_avg",
//                 "value": 5,
//                 "operator": "<="
//               },
//               {
//                 "field": "avg_cigarettes",
//                 "formula": {
//                   "base": "fm_cigarettes_total",
//                   "percent": 0.6,
//                   "operator": "*"
//                 },
//                 "operator": "<="
//               }
//             ]
//           },
//           {
//             "field": "progress",
//             "value": 80,
//             "operator": ">="
//           }
//         ]
//       },
//       "details": []
//     },
//     {
//       "id": 5,
//       "name": "Maintenance",
//       "startDate": "2025-12-03",
//       "endDate": "2026-01-01",
//       "durationDay": 30,
//       "reason": "Based on your FTND score of 2, average smoking of 2 cigarettes per day, 2 years of smoking, age 24, and gender MALE, your maintenance phase is set for 30 days to reinforce your commitment and prevent relapse.",
//       "keepPhase": false,
//       "totalMissions": 0,
//       "completedMissions": 0,
//       "avg_craving_level": 0,
//       "avg_cigarettes": 0,
//       "fm_cigarettes_total": 0,
//       "condition": {
//         "logic": "AND",
//         "rules": [
//           {
//             "logic": "OR",
//             "rules": [
//               {
//                 "field": "craving_level_avg",
//                 "value": 3,
//                 "operator": "<="
//               },
//               {
//                 "field": "avg_cigarettes",
//                 "formula": {
//                   "base": "fm_cigarettes_total",
//                   "percent": 0.5,
//                   "operator": "*"
//                 },
//                 "operator": "<="
//               }
//             ]
//           },
//           {
//             "field": "progress",
//             "value": 80,
//             "operator": ">="
//           }
//         ]
//       },
//       "details": []
//     }
//   ]
// }
