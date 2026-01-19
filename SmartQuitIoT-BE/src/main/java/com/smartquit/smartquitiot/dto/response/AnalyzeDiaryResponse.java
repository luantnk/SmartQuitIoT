package com.smartquit.smartquitiot.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class AnalyzeDiaryResponse {
    private String message;

    @JsonProperty("is_high_risk")
    private boolean isHighRisk;

    @JsonProperty("status_color")
    private String statusColor;
}