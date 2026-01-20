package com.smartquit.smartquitiot.dto.response;

import java.time.LocalDate;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PhaseDetailPlanToolDTO {
  private Integer phaseDetailId;
  String phaseDetailName;
  LocalDate date;
  int dayIndex;
  private List<PhaseDetailMissionPlanToolDTO> missions;
}
