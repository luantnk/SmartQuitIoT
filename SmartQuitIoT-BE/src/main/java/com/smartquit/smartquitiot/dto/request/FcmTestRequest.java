package com.smartquit.smartquitiot.dto.request;

import lombok.Data;

@Data
public class FcmTestRequest {
  private String token;
  private String title;
  private String body;
}
