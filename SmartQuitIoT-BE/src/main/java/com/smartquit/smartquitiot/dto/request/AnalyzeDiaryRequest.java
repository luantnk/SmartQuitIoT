package com.smartquit.smartquitiot.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AnalyzeDiaryRequest {
    @JsonProperty("anxiety_level")
    private int anxietyLevel;

    @JsonProperty("craving_level")
    private int cravingLevel;

    @JsonProperty("mood_level")
    private int moodLevel;

    @JsonProperty("have_smoked")
    private boolean haveSmoked;

    @JsonProperty("note")
    private String note;

    @JsonProperty("triggers")
    private List<String> triggers;
}