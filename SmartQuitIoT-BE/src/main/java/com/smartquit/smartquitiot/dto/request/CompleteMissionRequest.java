package com.smartquit.smartquitiot.dto.request;

import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CompleteMissionRequest {
  int phaseId;
  int phaseDetailMissionId;
  List<String> triggered;
  String notes;
}
