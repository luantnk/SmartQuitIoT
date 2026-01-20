package com.smartquit.smartquitiot.controller;

import com.smartquit.smartquitiot.dto.request.DiaryRecordRequest;
import com.smartquit.smartquitiot.dto.request.DiaryRecordUpdateRequest;
import com.smartquit.smartquitiot.dto.response.DiaryRecordDTO;
import com.smartquit.smartquitiot.service.DiaryRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/diary-records")
@RequiredArgsConstructor
public class DiaryRecordController {

  private final DiaryRecordService diaryRecordService;

  @PostMapping("/log")
  @PreAuthorize("hasRole('MEMBER')")
  @SecurityRequirement(name = "Bearer Authentication")
  public ResponseEntity<?> logDiaryRecord(@RequestBody @Valid DiaryRecordRequest request) {
    log.info("REST request to save new DiaryRecord");
    return ResponseEntity.ok(diaryRecordService.logDiaryRecord(request));
  }

  @GetMapping("/history")
  @SecurityRequirement(name = "Bearer Authentication")
  @Operation(summary = "Get diary record history for the authenticated member")
  public ResponseEntity<?> getDiaryRecordHistory() {
    log.debug("REST request to fetch personal diary history");
    return ResponseEntity.ok(diaryRecordService.getDiaryRecordsForMember());
  }

  @GetMapping("/{id}")
  @Operation(summary = "Get diary record detail")
  public ResponseEntity<?> getDiaryRecordById(@PathVariable Integer id) {
    log.debug("REST request to get DiaryRecord : {}", id);
    return ResponseEntity.ok(diaryRecordService.getDiaryRecordById(id));
  }

  @GetMapping("/charts")
  @SecurityRequirement(name = "Bearer Authentication")
  @Operation(summary = "Get diary record chart for the authenticated member")
  public ResponseEntity<?> getDiaryRecordsCharts() {
    log.debug("REST request to get charts for current user");
    return ResponseEntity.ok(diaryRecordService.getDiaryRecordsCharts());
  }

  @GetMapping("/charts/{memberId}")
  @Operation(summary = "Get diary record chart for member")
  public ResponseEntity<?> getDiaryRecordsChartsByMemberId(@PathVariable int memberId) {
    log.info("REST request to get charts for memberId: {}", memberId);
    return ResponseEntity.ok(diaryRecordService.getDiaryRecordsChartsByMemberId(memberId));
  }

  @GetMapping("/history/{memberId}")
  @Operation(summary = "Get diary record history for member")
  public ResponseEntity<?> getDiaryRecordHistoryByMemberId(@PathVariable int memberId) {
    log.info("REST request to view history of memberId: {}", memberId);
    return ResponseEntity.ok(diaryRecordService.getDiaryRecordsHistoryByMemberId(memberId));
  }

  @GetMapping("/check-today")
  @PreAuthorize("hasRole('MEMBER')")
  @SecurityRequirement(name = "Bearer Authentication")
  @Operation(summary = "Check if the authenticated member has created a diary record today")
  public ResponseEntity<?> hasCreatedDiaryRecordToday() {
    log.debug("Checking if today's diary record exists for user");
    boolean hasRecord = diaryRecordService.hasCreatedDiaryRecordToday();
    return ResponseEntity.ok(Map.of("hasRecordToday", hasRecord));
  }

  @PutMapping("/{recordId}")
  @PreAuthorize("hasRole('MEMBER')")
  @SecurityRequirement(name = "Bearer Authentication")
  public ResponseEntity<DiaryRecordDTO> updateDiaryRecord(
      @PathVariable Integer recordId, @RequestBody @Valid DiaryRecordUpdateRequest request) {
    log.info("REST request to update DiaryRecord ID: {}", recordId);
    DiaryRecordDTO updatedRecord = diaryRecordService.updateDiaryRecord(recordId, request);
    return ResponseEntity.ok(updatedRecord);
  }

  @GetMapping("/summary/{memberId}")
  @PreAuthorize("hasRole('ADMIN') or hasRole('COACH')")
  @SecurityRequirement(name = "Bearer Authentication")
  @Operation(summary = "Get weekly AI summary for a specific member (Admin/Coach only)")
  public ResponseEntity<?> getMemberWeeklySummary(@PathVariable int memberId) {
    log.info("REST request to get AI weekly summary for memberId: {}", memberId);
    Object summary = diaryRecordService.getWeeklySummaryFromAI(memberId);
    return ResponseEntity.ok(
        com.smartquit.smartquitiot.dto.response.GlobalResponse.ok(
            "Summary generated successfully", summary));
  }

  @GetMapping("/report-image/{memberId}")
  @PreAuthorize("hasRole('ADMIN') or hasRole('COACH')")
  @SecurityRequirement(name = "Bearer Authentication")
  @Operation(summary = "Generate a visual report (Base64 Image) for a member based on diary logs")
  public ResponseEntity<?> getMemberReportImage(
      @PathVariable int memberId,
      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
          LocalDate startDate,
      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
          LocalDate endDate) {
    log.info("REST request to generate report image for memberId: {}", memberId);
    if (endDate == null) endDate = LocalDate.now();
    if (startDate == null) startDate = endDate.minusDays(6);
    String base64Image = diaryRecordService.generateReportImage(memberId, startDate, endDate);
    return ResponseEntity.ok(Map.of("status", "success", "image_base64", base64Image));
  }
}
