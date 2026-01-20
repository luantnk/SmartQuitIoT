package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GenerateReportRequest {
  @JsonProperty("member_name")
  private String memberName;

  @JsonProperty("start_date")
  private String startDate;

  @JsonProperty("end_date")
  private String endDate;

  @JsonProperty("logs")
  private List<AIDailyLog> logs;
}
