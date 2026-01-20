package com.smartquit.smartquitiot.entity;

import com.smartquit.smartquitiot.enums.AppointmentStatus;
import com.smartquit.smartquitiot.enums.CancelledBy;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Appointment {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  String name;

  LocalDate date;

  @ManyToOne(fetch = FetchType.LAZY)
  Member member;

  @ManyToOne(fetch = FetchType.LAZY)
  Coach coach;

  @Enumerated(EnumType.STRING)
  AppointmentStatus appointmentStatus; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED

  @Enumerated(EnumType.STRING)
  CancelledBy cancelledBy; // MEMBER, COACH

  LocalDateTime cancelledAt;

  LocalDateTime createdAt;

  @ManyToOne(fetch = FetchType.LAZY)
  CoachWorkSchedule coachWorkSchedule;

  @ElementCollection
  @CollectionTable(
      name = "appointment_snapshots",
      joinColumns = @JoinColumn(name = "appointment_id"))
  @Column(name = "image_url")
  List<String> snapshotUrls = new ArrayList<>();
}
