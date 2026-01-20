package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GenerateReportRequest {
    @JsonProperty("member_name")
    private String memberName;

    @JsonProperty("start_date")
    private String startDate;

    @JsonProperty("end_date")
    private String endDate;

    @JsonProperty("logs")
    private List<AIDailyLog> logs;
}