package com.smartquit.smartquitiot.dto.request;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PredictRiskMobileRequest {
  private int age;
  private int gender_code;
  private int ftnd_score;
  private int smoke_avg_per_day;
  private int mood_level;
  private int anxiety_level;
  private int day_of_week;
}
