package com.smartquit.smartquitiot.service;

import com.smartquit.smartquitiot.dto.response.PaymentDTO;
import java.util.Map;
import org.springframework.data.domain.Page;

public interface PaymentService {
  Map<String, Object> getPaymentStatistics();

  Page<PaymentDTO> getPayments(int page, int size, String search);
}
