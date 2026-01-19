import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news.dart';
import '../core/errors/exception.dart';
import '../models/news_detail.dart';

class NewsService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  final Dio _dio;
  static const Duration _timeout = Duration(seconds: 30);

  NewsService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
    print('🌍 [NewsService] Base URL loaded: $_baseUrl');
  }

  Future<List<News>> getAllNews({String? query, String? accessToken}) async {
    try {
      print('📰 [NewsService] Getting all news...');

      final url = query != null && query.isNotEmpty
          ? '$_baseUrl/news?query=$query'
          : '$_baseUrl/news';

      print('🌐 [NewsService] URL: $url');

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      final response = await _dio.get(url, options: options);

      if (response.statusCode == 200) {
        final jsonBody = response.data as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'] ?? [];
        print('✅ [NewsService] Parsed ${data.length} news items');
        return data.map((e) => News.fromJson(e)).toList();
      } else {
        throw NewsException(
          'Failed to load news. Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [NewsService] Dio error: ${e.message}');
      throw NewsException('Failed to load news: ${e.message}');
    } catch (e) {
      print('❌ [NewsService] Unexpected error: $e');
      throw NewsException('Failed to load news: ${e.toString()}');
    }
  }

  Future<List<News>> getLatestNews({
    int limit = 5,
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/news/latest?limit=$limit';
      print('📰 [NewsService] Getting latest news...');
      print('🌐 [NewsService] URL: $url');
      print('🔑 [NewsService] Token: ${accessToken.substring(0, 20)}...');

      final options = Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      final response = await _dio.get(url, options: options);

      print('📊 [NewsService] Response Status: ${response.statusCode}');
      print('📦 [NewsService] Response Type: ${response.data.runtimeType}');
      print('📦 [NewsService] Raw Response: ${response.data}');

      if (response.statusCode == 200) {
        final jsonBody = response.data as Map<String, dynamic>;
        print('✅ [NewsService] JSON Body Keys: ${jsonBody.keys.toList()}');

        final List<dynamic> data = jsonBody['data'] ?? [];
        print('✅ [NewsService] Data length: ${data.length}');
        print(
          '✅ [NewsService] First item: ${data.isNotEmpty ? data[0] : "empty"}',
        );

        final newsList = data.map((e) {
          print('🔄 [NewsService] Parsing item: $e');
          return News.fromJson(e);
        }).toList();

        print(
          '✅ [NewsService] Successfully parsed ${newsList.length} news items',
        );
        return newsList;
      } else {
        throw NewsException(
          'Failed to fetch latest news. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [NewsService] Dio error: ${e.type}');
      print('❌ [NewsService] Error message: ${e.message}');
      print('❌ [NewsService] Response: ${e.response?.data}');
      throw NewsException('Failed to fetch latest news: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ [NewsService] Unexpected error: $e');
      print('❌ [NewsService] StackTrace: $stackTrace');
      throw NewsException('Failed to fetch latest news: ${e.toString()}');
    }
  }

  Future<NewsDetail> getNewsDetail(int id, {String? accessToken}) async {
    try {
      final url = '$_baseUrl/news/$id';
      print('🌐 [NewsService] URL: $url');

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      final response = await _dio.get(url, options: options);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return NewsDetail.fromJson(data);
      } else {
        throw NewsException('Failed to load news detail');
      }
    } on DioException catch (e) {
      throw NewsException('Failed to load news detail: ${e.message}');
    }
  }
}
