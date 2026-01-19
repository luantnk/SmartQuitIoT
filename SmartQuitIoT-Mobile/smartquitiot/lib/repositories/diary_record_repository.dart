import 'package:dio/dio.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/models/diary_history.dart';
import 'package:SmartQuitIoT/models/diary_charts.dart';
import 'package:SmartQuitIoT/models/diary_create_result.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';
import '../services/diary_service.dart';
import '../repositories/auth_repository.dart';

class DiaryRecordRepository {
  final DiaryService _diaryService;
  final AuthRepository _authRepository;

  DiaryRecordRepository(this._authRepository, this._diaryService);

  /// Create diary record
  Future<DiaryCreateResult> createDiaryRecord(
    DiaryRecordRequest request,
  ) async {
    try {
      print('📝 Creating diary record...');
      final response = await _diaryService.createDiaryRecord(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Diary API call successful, checking response...');
        try {
          // Parse response structure
          final dataMap = response.data is Map ? response.data : {};
          final recordData = dataMap['data'] ?? response.data;
          final customCode = dataMap['code'] as int?; // Check custom code field
          final message = dataMap['message'] as String?;

          print('📊 Response code field: $customCode');
          print('📝 Response message: $message');

          // Check if custom code is 209 (smoked during quit plan)
          if (customCode == 209) {
            print('⚠️ User smoked during quit plan (code: 209)');
            final diaryRecord = DiaryRecord.fromJson(recordData);
            print('✅ Parsed diary record with ID: ${diaryRecord.id}');
            return DiaryCreateResult(
              diaryRecord: diaryRecord,
              statusCode: 209,
              message:
                  message ?? 'Oh no you have smoked when you on quit plan!',
            );
          }

          // Normal success (code 200 or null)
          final diaryRecord = DiaryRecord.fromJson(recordData);
          print('✅ Successfully parsed DiaryRecord with ID: ${diaryRecord.id}');
          return DiaryCreateResult(
            diaryRecord: diaryRecord,
            statusCode: customCode ?? response.statusCode ?? 200,
            message: message,
          );
        } catch (parseError) {
          print('❌ JSON Parsing Error: $parseError');
          print('❌ Response data: ${response.data}');
          throw ServerFailure('Failed to parse diary record: $parseError');
        }
      } else {
        throw ServerFailure(
          'Failed to create diary record: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException during create diary: ${e.message}');
      print('❌ HTTP Status code: ${e.response?.statusCode}');

      // Check if response has custom code 209 in body
      if (e.response?.statusCode == 200 || e.response?.statusCode == 201) {
        try {
          final dataMap = e.response?.data is Map ? e.response!.data : {};
          final customCode = dataMap['code'] as int?;

          if (customCode == 209) {
            print(
              '⚠️ DioException with code 209 - User smoked during quit plan',
            );
            final recordData = dataMap['data'];
            final message =
                dataMap['message'] ??
                'Oh no you have smoked when you on quit plan!';

            if (recordData != null) {
              final diaryRecord = DiaryRecord.fromJson(recordData);
              return DiaryCreateResult(
                diaryRecord: diaryRecord,
                statusCode: 209,
                message: message,
              );
            }
          }
        } catch (parseError) {
          print('❌ Failed to parse response from DioException: $parseError');
        }
      }

      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      print('❌ Unexpected error during create diary: $e');
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get diary history (list summary)
  Future<List<DiaryHistory>> getDiaryHistory() async {
    try {
      final response = await _diaryService.getDiaryHistory();

      if (response.statusCode == 200) {
        print('🔍 Parsing Diary History from data...');
        try {
          final List data = response.data is List ? response.data : [];
          print('   - Diary entries count: ${data.length}');
          final diaryList = data
              .map((json) => DiaryHistory.fromJson(json))
              .toList();
          print('✅ Successfully parsed ${diaryList.length} diary entries');
          return diaryList;
        } catch (parseError) {
          print('❌ JSON Parsing Error: $parseError');
          print('❌ Response data type: ${response.data.runtimeType}');
          throw ServerFailure('Failed to parse diary history: $parseError');
        }
      } else {
        throw ServerFailure(
          'Failed to fetch diary history: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get diary record by ID (full details)
  Future<DiaryRecord> getDiaryRecordById(int id) async {
    try {
      final response = await _diaryService.getDiaryRecordById(id);

      if (response.statusCode == 200) {
        return DiaryRecord.fromJson(response.data);
      } else {
        throw ServerFailure(
          'Failed to fetch diary record: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get today's diary record
  Future<DiaryRecord?> getTodayDiaryRecord() async {
    try {
      final response = await _diaryService.getTodayDiaryRecord();

      if (response.statusCode == 200) {
        final data = response.data;
        return data != null ? DiaryRecord.fromJson(data) : null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerFailure(
          'Failed to fetch today diary record: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Check if user has already created a diary record today
  Future<bool> hasDiaryRecordToday() async {
    try {
      final response = await _diaryService.checkTodayDiaryRecord();

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final value = data['hasRecordToday'];
          if (value is bool) return value;
          if (value is num) return value != 0;
          if (value is String) {
            final normalized = value.toLowerCase();
            return normalized == 'true' ||
                normalized == '1' ||
                normalized == 'yes';
          }
        } else if (data is bool) {
          return data;
        } else if (data is num) {
          return data != 0;
        }
        return false;
      } else {
        throw ServerFailure(
          'Failed to check today diary record: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get diary charts data
  Future<DiaryCharts> getDiaryCharts() async {
    try {
      final response = await _diaryService.getDiaryCharts();

      if (response.statusCode == 200) {
        return DiaryCharts.fromJson(response.data);
      } else {
        throw ServerFailure(
          'Failed to fetch diary charts: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get all diary records
  Future<List<DiaryRecord>> getAllDiaryRecords() async {
    try {
      final response = await _diaryService.getAllDiaryRecords();

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => DiaryRecord.fromJson(json)).toList();
      } else {
        throw ServerFailure(
          'Failed to fetch diary records: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Update diary record
  Future<DiaryRecord> updateDiaryRecord(
    int id,
    DiaryRecordUpdateRequest request,
  ) async {
    try {
      print('📝 Updating diary record with ID: $id...');
      final response = await _diaryService.updateDiaryRecord(id, request);

      if (response.statusCode == 200) {
        print('✅ Diary record updated successfully');
        try {
          // Handle response structure (may be wrapped in data field)
          final dataMap = response.data is Map ? response.data : {};
          final recordData = dataMap['data'] ?? response.data;
          return DiaryRecord.fromJson(recordData);
        } catch (parseError) {
          print('❌ JSON Parsing Error: $parseError');
          print('❌ Response data: ${response.data}');
          throw ServerFailure('Failed to parse updated diary record: $parseError');
        }
      } else {
        throw ServerFailure(
          'Failed to update diary record: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException during update diary: ${e.message}');
      print('❌ HTTP Status code: ${e.response?.statusCode}');
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      print('❌ Unexpected error during update diary: $e');
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Helper: xử lý lỗi từ Dio
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server responded with status $status';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No Internet connection';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    } else {
      return 'Unexpected network error: ${e.message}';
    }
  }
}
