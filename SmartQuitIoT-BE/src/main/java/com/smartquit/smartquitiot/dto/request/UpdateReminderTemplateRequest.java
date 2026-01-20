package com.smartquit.smartquitiot.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateReminderTemplateRequest {
  @NotNull(message = "content is required")
  private String content;
}
