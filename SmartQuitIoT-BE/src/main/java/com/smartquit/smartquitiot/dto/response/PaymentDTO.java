package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.smartquit.smartquitiot.enums.PaymentStatus;
import java.time.LocalDateTime;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaymentDTO {

  int id;
  long orderCode;
  String paymentLinkId;
  @CreationTimestamp LocalDateTime createdAt;
  long amount;
  PaymentStatus status;
  MemberDTO member;
  MembershipSubscriptionDTO subscription;
}
