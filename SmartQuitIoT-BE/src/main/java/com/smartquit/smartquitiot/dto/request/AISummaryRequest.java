package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AISummaryRequest {
  @JsonProperty("member_name")
  private String memberName;

  @JsonProperty("logs")
  private List<AIDailyLog> logs;
}
