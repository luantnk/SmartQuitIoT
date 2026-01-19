// lib/repositories/coach_detail_repository.dart
import '../models/coach_detail.dart';
import '../models/slot_available.dart';
import '../services/coach_detail_service.dart';
import '../services/token_storage_service.dart';
import '../core/errors/exception.dart';
import 'package:flutter/foundation.dart';

class CoachDetailRepository {
  final CoachDetailService _service;
  final TokenStorageService _tokenService = TokenStorageService();

  CoachDetailRepository({CoachDetailService? service})
      : _service = service ?? CoachDetailService();

  /// 🔹 Lấy chi tiết coach (parse từ JSON)
  Future<CoachDetail> getCoachDetail(int coachId) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const CoachException('Missing access token');
      }

      final data = await _service.fetchCoachDetail(token, coachId);
      return CoachDetail.fromJson(data);
    } catch (e, st) {
      debugPrint('[ERROR] getCoachDetail failed: $e\n$st');
      throw CoachException('Failed to load coach detail: $e');
    }
  }

  /// 🔹 Lấy danh sách slot khả dụng (parse từ JSON) — dedupe theo slotId
  Future<List<SlotAvailable>> getAvailableSlots(int coachId, String date) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const CoachException('Missing access token');
      }

      debugPrint('[DEBUG] getAvailableSlots calling service for coachId=$coachId date=$date');
      final dataList = await _service.fetchAvailableSlots(token, coachId, date);
      debugPrint('[DEBUG] getAvailableSlots raw list length=${dataList.length}');

      // Map -> SlotAvailable
      final parsed = dataList
          .map((e) => SlotAvailable.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Dedupe: giữ first occurrence mỗi slotId (nếu slotId là unique key cho slot)
      final Map<int, SlotAvailable> uniqueBySlotId = {};
      for (var s in parsed) {
        uniqueBySlotId.putIfAbsent(s.slotId, () => s);
      }

      final deduped = uniqueBySlotId.values.toList();

      debugPrint('[DEBUG] getAvailableSlots parsed length=${parsed.length} deduped=${deduped.length}');
      return deduped;
    } catch (e, st) {
      debugPrint('[ERROR] getAvailableSlots failed: $e\n$st');
      throw CoachException('Failed to load available slots: $e');
    }
  }
}
