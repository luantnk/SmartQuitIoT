package com.smartquit.smartquitiot.dto.request;

import java.time.LocalDate;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateNewQuitPlanRequest {
  LocalDate startDate;
  boolean useNRT;
  String quitPlanName;
}
