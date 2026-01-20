package com.smartquit.smartquitiot.repository;

import com.smartquit.smartquitiot.entity.Account;
import com.smartquit.smartquitiot.entity.Conversation;
import com.smartquit.smartquitiot.entity.Participant;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ParticipantRepository extends JpaRepository<Participant, Integer> {
  Optional<Participant> findByConversationAndAccount(Conversation conversation, Account account);

  Optional<Participant> findByConversationIdAndAccountId(int conversationId, int accountId);
}
