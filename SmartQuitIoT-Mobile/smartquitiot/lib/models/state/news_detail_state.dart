import '../news_detail.dart';

class NewsDetailState {
  final bool isLoading;
  final NewsDetail? newsDetail;
  final String? error;

  NewsDetailState({this.isLoading = false, this.newsDetail, this.error});

  NewsDetailState copyWith({
    bool? isLoading,
    NewsDetail? newsDetail,
    String? error,
  }) {
    return NewsDetailState(
      isLoading: isLoading ?? this.isLoading,
      newsDetail: newsDetail ?? this.newsDetail,
      error: error ?? this.error,
    );
  }
}
