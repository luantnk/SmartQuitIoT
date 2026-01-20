package com.smartquit.smartquitiot.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class TopMemberAchievementDTO {
  private int memberId;
  private String memberName;
  private String avatar_url;
  private long totalAchievements;
  private List<AchievementDTO> achievements;
}
