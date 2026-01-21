package com.smartquit.smartquitiot.cron;

import com.smartquit.smartquitiot.entity.Account;
import com.smartquit.smartquitiot.entity.Member;
import com.smartquit.smartquitiot.entity.ReminderQueue;
import com.smartquit.smartquitiot.enums.ReminderQueueStatus;
import com.smartquit.smartquitiot.repository.ReminderQueueRepository;
import com.smartquit.smartquitiot.service.NotificationService;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationScheduler {

  private final ReminderQueueRepository reminderQueueRepository;
  private final NotificationService notificationService;

  @Scheduled(fixedRate = 60000)
  @Transactional
  public void processScheduledReminders() {
    LocalDateTime now = LocalDateTime.now();

    List<ReminderQueue> dueTasks =
        reminderQueueRepository.findAllByStatusAndScheduledAtBefore(
            ReminderQueueStatus.PENDING, now);

    for (ReminderQueue task : dueTasks) {
      Account account = task.getAccount();
      Member member = account.getMember();

      if (member.getFcmToken() != null) {
        notificationService.sendPushNotification(
            member.getFcmToken(), "SmartQuit Peak Warning", task.getContent());

        task.setStatus(ReminderQueueStatus.SENT);
        log.info("FCM sent to member ID: {}", member.getId());
      } else {
        task.setStatus(ReminderQueueStatus.FAILED);
        log.warn("No FCM token for member ID: {}", member.getId());
      }
    }
    reminderQueueRepository.saveAll(dueTasks);
  }
}
