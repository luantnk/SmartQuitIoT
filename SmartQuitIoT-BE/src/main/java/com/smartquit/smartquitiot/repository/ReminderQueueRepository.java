package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.ReminderQueue;
import com.smartquit.smartquitiot.enums.ReminderQueueStatus;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReminderQueueRepository extends JpaRepository<ReminderQueue, Integer> {
  List<ReminderQueue> findByStatusAndScheduledAtBefore(
      ReminderQueueStatus reminderQueueStatus, LocalDateTime now);

  List<ReminderQueue> findAllByStatusAndScheduledAtBefore(
      ReminderQueueStatus status, LocalDateTime now);
}
