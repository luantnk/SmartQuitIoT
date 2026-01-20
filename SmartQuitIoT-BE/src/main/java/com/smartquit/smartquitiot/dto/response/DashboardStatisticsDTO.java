package com.smartquit.smartquitiot.dto.response;

import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DashboardStatisticsDTO {
  // Summary cards
  int appointmentsToday;
  int appointmentsYesterday;
  int pendingRequests;
  int completedThisWeek;
  int completedLastWeek;
  int activeMembers;
  int newMembersThisMonth;

  // Upcoming appointments
  List<UpcomingAppointmentDTO> upcomingAppointments;
}
