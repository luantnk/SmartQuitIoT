package com.smartquit.smartquitiot.dto.request;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.smartquit.smartquitiot.dto.request.AIDailyLog;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AISummaryRequest {
    @JsonProperty("member_name")
    private String memberName;

    @JsonProperty("logs")
    private List<AIDailyLog> logs;
}