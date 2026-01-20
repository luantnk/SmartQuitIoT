package com.smartquit.smartquitiot.dto.response;

import com.smartquit.smartquitiot.enums.QuitPlanStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class QuitPlanResponse {
  int id;
  String name;
  QuitPlanStatus status;
  LocalDate startDate;
  LocalDate endDate;
  LocalDateTime createdAt;
  boolean useNRT;
  boolean active;
  int ftndScore;
  FormMetricDTO formMetricDTO;
  CurrentMetricDTO currentMetricDTO;
  List<PhaseDTO> phases;
}
