import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/state/news_detail_state.dart';
import '../repositories/news_repository.dart';
import '../services/news_service.dart';
import '../viewmodels/news_detail_view_model.dart';
import '../viewmodels/news_view_model.dart';
import '../models/state/news_state.dart';
import '../models/news.dart';

// Dio Provider - shared instance
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  return dio;
});

// Service Provider
final newsServiceProvider = Provider<NewsService>((ref) {
  final dio = ref.watch(dioProvider);
  return NewsService(dio: dio);
});

// Repository Provider
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final newsService = ref.watch(newsServiceProvider);
  return NewsRepository(newsService: newsService);
});

// ViewModels
final newsViewModelProvider = StateNotifierProvider<NewsViewModel, NewsState>((ref) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsViewModel(repo);
});

final newsDetailViewModelProvider = StateNotifierProvider<NewsDetailViewModel, NewsDetailState>((ref) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsDetailViewModel(repository: repo);
});

// Latest News Provider
final latestNewsProvider = FutureProvider<List<News>>((ref) async {
  final viewModel = ref.read(newsViewModelProvider.notifier);
  await viewModel.loadLatestNews();
  return ref.read(newsViewModelProvider).news;
});
