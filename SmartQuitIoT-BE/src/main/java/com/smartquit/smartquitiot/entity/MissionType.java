package com.smartquit.smartquitiot.entity;

import jakarta.persistence.*;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MissionType {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  String name;
  String description;

  @OneToMany(cascade = CascadeType.ALL, mappedBy = "missionType")
  List<Mission> missions;
}
