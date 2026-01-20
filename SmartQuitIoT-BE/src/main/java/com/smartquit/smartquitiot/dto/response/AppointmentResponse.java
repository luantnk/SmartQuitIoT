package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.smartquit.smartquitiot.enums.AppointmentStatus;
import com.smartquit.smartquitiot.enums.CancelledBy;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppointmentResponse {
  int appointmentId;

  // coach info
  Integer coachId;
  String coachName;

  // member info
  Integer memberId;
  String memberName;

  int slotId;
  LocalDate date;
  LocalTime startTime;
  LocalTime endTime;
  String runtimeStatus;
  String channelName; // ex: "appointment_3"
  String meetingUrl; // ex: "/meeting/3"
  Instant joinWindowStart;
  Instant joinWindowEnd;
  CancelledBy cancelledBy;
  LocalDateTime cancelledAt;
  LocalDateTime createdAt;
  AppointmentStatus realAppointmentStatus;
  boolean hasRated = false;
}
