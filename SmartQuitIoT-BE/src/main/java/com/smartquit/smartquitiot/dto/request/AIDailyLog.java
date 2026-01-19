package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AIDailyLog {
    private Integer id;
    private String date;

    @JsonProperty("have_smoked")
    private Integer haveSmoked;

    @JsonProperty("cigarettes_smoked")
    private Integer cigarettesSmoked;

    @JsonProperty("estimated_nicotine_intake")
    private Double estimatedNicotineIntake;

    @JsonProperty("mood_level")
    private Integer moodLevel;

    @JsonProperty("anxiety_level")
    private Integer anxietyLevel;

    @JsonProperty("craving_level")
    private Integer cravingLevel;

    @JsonProperty("confidence_level")
    private Integer confidenceLevel;

    @JsonProperty("is_connect_iotdevice")
    private Integer isConnectIoTDevice;

    @JsonProperty("heart_rate")
    private Double heartRate;

    @JsonProperty("spo2")
    private Double spo2;

    @JsonProperty("steps")
    private Integer steps;

    @JsonProperty("sleep_duration")
    private Double sleepDuration;

    @JsonProperty("is_use_nrt")
    private Integer isUseNrt;

    @JsonProperty("money_spent_on_nrt")
    private Double moneySpentOnNrt;

    @JsonProperty("reduction_percentage")
    private Double reductionPercentage;

    private List<String> triggers;
    private String note;
}