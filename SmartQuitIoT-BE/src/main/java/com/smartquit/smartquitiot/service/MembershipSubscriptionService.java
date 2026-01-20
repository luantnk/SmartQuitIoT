package com.smartquit.smartquitiot.service;

import com.smartquit.smartquitiot.dto.response.MembershipSubscriptionDTO;
import java.util.List;
import org.springframework.data.domain.Page;

public interface MembershipSubscriptionService {

  MembershipSubscriptionDTO getMyMembershipSubscription();

  Page<MembershipSubscriptionDTO> getAllMembershipSubscriptions(
      Integer page, Integer size, String sortBy, String sortDir, String orderCode, String status);

  List<MembershipSubscriptionDTO> getMembershipSubscriptionsByUserId(int memberId);
}
