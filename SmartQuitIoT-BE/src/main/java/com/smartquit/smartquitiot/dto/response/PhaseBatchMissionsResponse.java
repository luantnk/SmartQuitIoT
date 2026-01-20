package com.smartquit.smartquitiot.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PhaseBatchMissionsResponse {
  private Integer phaseId;
  private String phaseName;
  private int durationDays;
  private List<PhaseDetailPlanToolDTO> phaseDetails;
}
