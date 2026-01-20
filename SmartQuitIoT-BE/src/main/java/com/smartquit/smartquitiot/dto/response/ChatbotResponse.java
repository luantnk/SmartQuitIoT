package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.content.Media;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ChatbotResponse {
  String messageType;
  List<AssistantMessage.ToolCall> toolCalls;
  List<Media> media;
  String text;
  //    String audioBase64;
  String audioUrl;
}
