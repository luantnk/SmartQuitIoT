import 'package:SmartQuitIoT/models/diary_record.dart';

/// Result type for diary creation that can handle special response codes
class DiaryCreateResult {
  final DiaryRecord? diaryRecord;
  final int statusCode;
  final String? message;
  
  const DiaryCreateResult({
    this.diaryRecord,
    required this.statusCode,
    this.message,
  });

  /// Check if creation was successful (200/201)
  bool get isSuccess => statusCode == 200 || statusCode == 201;

  // /// Check if user smoked during quit plan (209)
  bool get isSmokedDuringQuitPlan => statusCode == 209;

  /// Check if there was an error
  bool get isError => !isSuccess;
}
