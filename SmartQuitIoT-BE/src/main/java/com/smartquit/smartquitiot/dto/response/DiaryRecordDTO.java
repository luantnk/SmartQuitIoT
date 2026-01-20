package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;
import java.util.List;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DiaryRecordDTO {

  Integer id;
  String date;
  Boolean haveSmoked;
  Integer cigarettesSmoked;
  List<String> triggers;
  Boolean isUseNrt;
  Double moneySpentOnNrt;
  Integer cravingLevel;
  Integer moodLevel;
  Integer confidenceLevel;
  Integer anxietyLevel;
  String note;
  Boolean isConnectIoTDevice;
  Integer steps;
  Integer heartRate;
  Integer spo2;
  Double sleepDuration;
  BigDecimal estimatedNicotineIntake;
  Double reductionPercentage;
}
