package com.smartquit.smartquitiot.dto.response;

import java.time.LocalTime;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class SlotDTO {

  Integer id;
  LocalTime startTime;
  LocalTime endTime;
}
