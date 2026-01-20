package com.smartquit.smartquitiot.dto.request;

import java.time.LocalDate;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class RedoPhaseRequest {
  int phaseId;
  LocalDate anchorStart;
}
