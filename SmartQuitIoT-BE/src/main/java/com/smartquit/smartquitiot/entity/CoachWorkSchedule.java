package com.smartquit.smartquitiot.entity;

import com.smartquit.smartquitiot.enums.CoachWorkScheduleStatus;
import jakarta.persistence.*;
import java.time.LocalDate;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CoachWorkSchedule {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  LocalDate date;

  @Enumerated(EnumType.STRING)
  CoachWorkScheduleStatus status; // AVAILABLE,BOOKED,UNAVAILABLE

  @ManyToOne(fetch = FetchType.LAZY)
  Slot slot;

  @ManyToOne(fetch = FetchType.LAZY)
  Coach coach;
}
