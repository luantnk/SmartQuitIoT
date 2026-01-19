import 'package:riverpod/riverpod.dart';

import '../models/state/news_detail_state.dart';
import '../repositories/news_repository.dart';

class NewsDetailViewModel extends StateNotifier<NewsDetailState> {
  final NewsRepository repository;

  NewsDetailViewModel({required this.repository}) : super(NewsDetailState());

  Future<void> loadNewsDetail(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newsDetail = await repository.fetchNewsDetail(id);
      state = state.copyWith(isLoading: false, newsDetail: newsDetail);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
