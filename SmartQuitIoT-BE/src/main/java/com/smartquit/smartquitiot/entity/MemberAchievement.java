package com.smartquit.smartquitiot.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MemberAchievement {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  int id;

  @ManyToOne(fetch = FetchType.LAZY)
  Member member;

  @ManyToOne(fetch = FetchType.LAZY)
  Achievement achievement;

  @CreationTimestamp LocalDateTime achievedAt;
}
