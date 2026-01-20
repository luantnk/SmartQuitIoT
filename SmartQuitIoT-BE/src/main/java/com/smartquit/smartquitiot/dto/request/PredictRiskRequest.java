package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PredictRiskRequest {
  private int age;

  @JsonProperty("gender_code")
  private int genderCode;

  @JsonProperty("ftnd_score")
  private int ftndScore;

  @JsonProperty("smoke_avg_per_day")
  private int smokeAvgPerDay;

  @JsonProperty("mood_level")
  private int moodLevel;

  @JsonProperty("anxiety_level")
  private int anxietyLevel;

  @JsonProperty("day_of_week")
  private int dayOfWeek;
}
