package com.smartquit.smartquitiot.dto.response;

import com.smartquit.smartquitiot.enums.MessageType;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LastMessageDTO {
  private int id;
  private int senderId;
  private MessageType messageType;
  private String content;
  private LocalDateTime sentAt;
}
