package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDate;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PhaseDetailResponseDTO {
  int id;
  String name;
  LocalDate date;
  int dayIndex;
  int missionCompleted;
  int totalMission;
  List<PhaseDetailMissionResponseDTO> missions;
}
