package com.smartquit.smartquitiot.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class InterestCategory {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  String name;
  String description;
  @CreationTimestamp LocalDateTime createdAt;
  @UpdateTimestamp LocalDateTime updatedAt;

  @OneToMany(mappedBy = "interestCategory")
  List<Mission> missions;
}
