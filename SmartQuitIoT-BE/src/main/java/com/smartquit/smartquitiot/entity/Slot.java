package com.smartquit.smartquitiot.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalTime;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Slot {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  LocalTime startTime;
  LocalTime endTime;
}
