package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class GenerateReportResponse {
  private String status;

  @JsonProperty("image_base64")
  private String imageBase64;
}
