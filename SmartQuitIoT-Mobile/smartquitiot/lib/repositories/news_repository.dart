import 'package:dio/dio.dart';
import '../models/news.dart';
import '../models/news_detail.dart';
import '../services/news_service.dart';
import '../repositories/auth_repository.dart';
import '../core/errors/exception.dart';

class NewsRepository {
  final NewsService _newsService;
  final AuthRepository _authRepository;

  NewsRepository({NewsService? newsService, AuthRepository? authRepository})
    : _newsService = newsService ?? NewsService(dio: Dio()),
      _authRepository = authRepository ?? AuthRepository();

  Future<List<News>> getLatestNews({int limit = 5}) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw NewsException('No access token found');
    return _newsService.getLatestNews(limit: limit, accessToken: token);
  }

  Future<List<News>> getAllNews({String? query}) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw NewsException('No access token found');
    return _newsService.getAllNews(query: query, accessToken: token);
  }

  Future<NewsDetail> fetchNewsDetail(int id) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw NewsException('No access token found');
    return _newsService.getNewsDetail(id, accessToken: token);
  }
}
