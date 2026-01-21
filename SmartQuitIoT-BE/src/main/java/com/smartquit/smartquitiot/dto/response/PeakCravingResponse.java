package com.smartquit.smartquitiot.dto.response;

import lombok.Data;

@Data
public class PeakCravingResponse {
  private String peak_time;
  private double peak_craving_level;
  private String message;
}
