package com.smartquit.smartquitiot.event;

import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EmailMessageDTO {
  private String to;
  private String subject;
  private String templateName;
  private Map<String, Object> props;
}
