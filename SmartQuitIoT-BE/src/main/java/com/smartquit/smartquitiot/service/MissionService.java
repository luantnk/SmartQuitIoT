package com.smartquit.smartquitiot.service;

import com.smartquit.smartquitiot.dto.request.CreateMissionRequest;
import com.smartquit.smartquitiot.dto.request.UpdateMissionRequest;
import com.smartquit.smartquitiot.dto.response.MissionDTO;
import com.smartquit.smartquitiot.entity.Account;
import com.smartquit.smartquitiot.entity.Mission;
import com.smartquit.smartquitiot.entity.QuitPlan;
import com.smartquit.smartquitiot.enums.MissionPhase;
import com.smartquit.smartquitiot.enums.MissionStatus;
import java.util.List;
import org.springframework.data.domain.Page;

public interface MissionService {
  List<Mission> filterMissionsForPhase(
      QuitPlan plan, Account account, MissionPhase missionPhase, MissionStatus missionStatus);

  Page<MissionDTO> getAllMissions(int page, int size, String search, String status, String phase);

  MissionDTO deleteMission(int id);

  MissionDTO getDetails(int id);

  MissionDTO createMission(CreateMissionRequest request);

  MissionDTO updateMission(int id, UpdateMissionRequest request);
}
