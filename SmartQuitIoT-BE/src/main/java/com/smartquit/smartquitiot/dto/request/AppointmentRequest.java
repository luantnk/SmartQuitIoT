package com.smartquit.smartquitiot.dto.request;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AppointmentRequest {
  @NotNull(message = "Coach ID is required")
  int coachId;

  @NotNull(message = "slot ID is required")
  int slotId;

  @NotNull(message = "Date is required")
  @FutureOrPresent(message = "Date must be today or in the future")
  LocalDate date;
}
