package com.smartquit.smartquitiot.client;

import com.smartquit.smartquitiot.dto.request.*;
import com.smartquit.smartquitiot.dto.response.*;
import feign.Response;
import java.util.Map;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

@FeignClient(name = "ai-service", url = "${app.ai.service.url}")
public interface AiServiceClient {

  @PostMapping("/check-content")
  ContentCheckResponseDTO checkText(@RequestBody Map<String, String> requestBody);

  @PostMapping("/check-image-url")
  ContentCheckResponseDTO checkImage(@RequestBody Map<String, String> requestBody);

  @PostMapping("/check-video-url")
  ContentCheckResponseDTO checkVideo(@RequestBody Map<String, String> requestBody);

  @PostMapping("/predict-quit-status")
  AiPredictionResponse predictQuitStatus(@RequestBody AiPredictionRequest request);

  @PostMapping("/summarize-week")
  Object getWeeklySummary(@RequestBody AISummaryRequest request);

  @PostMapping("/analyze-diary")
  AnalyzeDiaryResponse analyzeDiaryRecord(@RequestBody AnalyzeDiaryRequest request);

  @PostMapping(value = "/voice-to-text", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  VoiceToTextResponse voiceToText(@RequestPart("file") MultipartFile file);

  @PostMapping(value = "/text-to-voice")
  byte[] textToVoice(@RequestBody TextToVoiceRequest request);

  @PostMapping(value = "/text-to-voice")
  Response textToVoiceStream(@RequestBody TextToVoiceRequest request);

  @PostMapping("/generate-report-image")
  GenerateReportResponse generateReportImage(@RequestBody GenerateReportRequest request);

  @PostMapping("/predict-risk/dashboard")
  PredictRiskResponse getRiskPredictionDashboard(@RequestBody PredictRiskRequest request);

  @PostMapping("/predict-risk/mobile")
  PeakCravingResponse getPeakCravingPrediction(@RequestBody PredictRiskMobileRequest request);
}
