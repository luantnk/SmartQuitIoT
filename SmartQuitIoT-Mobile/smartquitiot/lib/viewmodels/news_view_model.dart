import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/news_repository.dart';
import '../models/state/news_state.dart';

class NewsViewModel extends StateNotifier<NewsState> {
  final NewsRepository repository;

  NewsViewModel(this.repository) : super(NewsState.initial());

  Future<void> loadLatestNews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final news = await repository.getLatestNews();
      state = state.copyWith(isLoading: false, news: news);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllNews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final news = await repository.getAllNews();
      state = state.copyWith(isLoading: false, news: news);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchNews(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final news = await repository.getAllNews(query: query);
      state = state.copyWith(isLoading: false, news: news);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refreshNews() {
    if (state.news.isEmpty) {
      loadLatestNews();
    } else {
      loadAllNews();
    }
  }
}
