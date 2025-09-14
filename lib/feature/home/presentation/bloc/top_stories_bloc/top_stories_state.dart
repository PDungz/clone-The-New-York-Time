part of 'top_stories_bloc.dart';

abstract class TopStoriesState extends Equatable {
  const TopStoriesState();

  @override
  List<Object?> get props => [];

  // Helper method để lấy articles từ bất kỳ state nào
  List<Article> get articles {
    if (this is TopStoriesLoaded) {
      return (this as TopStoriesLoaded).articles;
    } else if (this is TopStoriesRefreshing) {
      return (this as TopStoriesRefreshing).articles;
    } else if (this is TopStoriesError) {
      return (this as TopStoriesError).previousArticles ?? [];
    }
    return [];
  }

  // Helper method để check xem có dữ liệu không
  bool get hasData => articles.isNotEmpty;

  // Helper method để check loading states
  bool get isLoading => this is TopStoriesLoading;
  bool get isRefreshing => this is TopStoriesRefreshing;
  bool get isError => this is TopStoriesError;
}

class TopStoriesInitial extends TopStoriesState {}

class TopStoriesLoading extends TopStoriesState {}

class TopStoriesLoaded extends TopStoriesState {
  @override
  final List<Article> articles;
  final String section;

  const TopStoriesLoaded({required this.articles, required this.section});

  @override
  List<Object?> get props => [articles, section];
}

class TopStoriesError extends TopStoriesState {
  final String message;
  final List<Article>? previousArticles; // Giữ dữ liệu cũ
  final String? section;

  const TopStoriesError({
    required this.message,
    this.previousArticles,
    this.section,
  });

  @override
  List<Object?> get props => [message, previousArticles, section];
}

class TopStoriesRefreshing extends TopStoriesState {
  @override
  final List<Article> articles;
  final String section;

  const TopStoriesRefreshing({required this.articles, required this.section});

  @override
  List<Object?> get props => [articles, section];
}
