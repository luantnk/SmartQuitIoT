import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/coach.dart';

class CoachService {
  final Dio _dio = Dio();

  Future<List<Coach>> fetchCoaches(String token) async {
    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final coachUrl = '$apiBaseUrl/coaches';

      final response = await _dio.get(
        coachUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final result = CoachListResponse.fromJson(response.data);
      return result.data;
    } catch (e) {
      throw Exception('Failed to fetch coaches: $e');
    }
  }
}
