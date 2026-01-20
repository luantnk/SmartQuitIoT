package com.smartquit.smartquitiot.dto.response;

import java.time.LocalDate;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ScheduleByDayResponse {
  LocalDate date;
  List<CoachSummaryDTO> coaches;
}
