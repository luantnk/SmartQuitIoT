package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import java.util.Map;
import lombok.Data;

@Data
public class PredictRiskResponse {
  private RiskOverview overview;
  private RiskAnalytics analytics;

  @JsonProperty("chart_data")
  private RiskChartData chartData;

  @Data
  public static class RiskOverview {
    @JsonProperty("peak_time")
    private String peakTime;

    @JsonProperty("peak_level")
    private Double peakLevel;

    @JsonProperty("average_daily_risk")
    private Double averageDailyRisk;

    @JsonProperty("risk_status")
    private String riskStatus;
  }

  @Data
  public static class RiskAnalytics {
    @JsonProperty("worst_time_of_day")
    private String worstTimeOfDay;

    @JsonProperty("high_risk_duration_minutes")
    private Integer highRiskDurationMinutes;

    private Map<String, Double> segments;
  }

  @Data
  public static class RiskChartData {
    private List<String> labels;
    private List<Double> values;
  }
}
