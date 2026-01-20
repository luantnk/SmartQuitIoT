package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.MemberAchievement;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MemberAchievementRepository extends JpaRepository<MemberAchievement, Integer> {
  List<MemberAchievement> getMemberAchievementsByMember_Id(int memberId);

  boolean existsByMember_IdAndAchievement_Id(int memberId, int achievementId);

  List<MemberAchievement> getMemberAchievementsByMember_IdOrderByAchievedAt(int memberId);

  @Query(
      value =
          """
        SELECT member_id, COUNT(*) AS total_achievements
        FROM member_achievement
        GROUP BY member_id
        ORDER BY total_achievements DESC
        LIMIT 10
        """,
      nativeQuery = true)
  List<Object[]> findTop10MembersWithMostAchievements();
}
