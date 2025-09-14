import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:packages/core/service/logger_service.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';
import 'package:news_app/feature/home/domain/use_case/topstories_use_case.dart';

part 'top_stories_event.dart';
part 'top_stories_state.dart';

class TopStoriesBloc extends Bloc<TopStoriesEvent, TopStoriesState> {
  final TopStoriesUseCase _topStoriesUseCase = getIt<TopStoriesUseCase>();

  TopStoriesBloc() : super(TopStoriesInitial()) {
    on<LoadTopStoriesEvent>(_onLoadTopStories);
    on<RefreshTopStoriesEvent>(_onRefreshTopStories);
  }

  Future<void> _onLoadTopStories(
    LoadTopStoriesEvent event,
    Emitter<TopStoriesState> emit,
  ) async {
    // Chỉ emit loading nếu chưa có dữ liệu
    if (state is! TopStoriesLoaded) {
      emit(TopStoriesLoading());
    }

    try {
      final result = await _topStoriesUseCase.getTopStories(
        section: event.section,
      );

      result.fold(
        (failure) {
          printE('[TopStoriesBloc] Load failed: ${failure.message}');
          // Nếu đã có dữ liệu cũ, giữ lại và chỉ thông báo lỗi
          if (state is TopStoriesLoaded) {
            final currentState = state as TopStoriesLoaded;
            emit(
              TopStoriesError(
                message: failure.message,
                previousArticles: currentState.articles,
                section: currentState.section,
              ),
            );
          } else {
            emit(TopStoriesError(message: failure.message));
          }
        },
        (articles) {
          printI(
            '[TopStoriesBloc] Loaded ${articles.length} articles for section: ${event.section}',
          );
          emit(TopStoriesLoaded(articles: articles, section: event.section));
        },
      );
    } catch (e) {
      printE('[TopStoriesBloc] Unexpected error: $e');
      // Tương tự như trên, giữ dữ liệu cũ nếu có
      if (state is TopStoriesLoaded) {
        final currentState = state as TopStoriesLoaded;
        emit(
          TopStoriesError(
            message: 'An unexpected error occurred',
            previousArticles: currentState.articles,
            section: currentState.section,
          ),
        );
      } else {
        emit(TopStoriesError(message: 'An unexpected error occurred'));
      }
    }
  }

  Future<void> _onRefreshTopStories(
    RefreshTopStoriesEvent event,
    Emitter<TopStoriesState> emit,
  ) async {
    // Luôn giữ dữ liệu cũ khi refresh
    List<Article> previousArticles = [];
    String previousSection = event.section;

    if (state is TopStoriesLoaded) {
      final currentState = state as TopStoriesLoaded;
      previousArticles = currentState.articles;
      previousSection = currentState.section;

      // Emit refreshing state với dữ liệu cũ
      emit(
        TopStoriesRefreshing(
          articles: previousArticles,
          section: previousSection,
        ),
      );
    } else if (state is TopStoriesError) {
      final currentState = state as TopStoriesError;
      if (currentState.previousArticles != null) {
        previousArticles = currentState.previousArticles!;
        previousSection = currentState.section ?? event.section;

        emit(
          TopStoriesRefreshing(
            articles: previousArticles,
            section: previousSection,
          ),
        );
      } else {
        emit(TopStoriesLoading());
      }
    } else {
      emit(TopStoriesLoading());
    }

    try {
      final result = await _topStoriesUseCase.getTopStories(
        section: event.section,
      );

      result.fold(
        (failure) {
          printE('[TopStoriesBloc] Refresh failed: ${failure.message}');
          // Giữ dữ liệu cũ và thông báo lỗi
          emit(
            TopStoriesError(
              message: failure.message,
              previousArticles:
                  previousArticles.isNotEmpty ? previousArticles : null,
              section: previousSection,
            ),
          );
        },
        (articles) {
          printI(
            '[TopStoriesBloc] Refreshed ${articles.length} articles for section: ${event.section}',
          );
          emit(TopStoriesLoaded(articles: articles, section: event.section));
        },
      );
    } catch (e) {
      printE('[TopStoriesBloc] Unexpected refresh error: $e');
      // Giữ dữ liệu cũ và thông báo lỗi
      emit(
        TopStoriesError(
          message: 'An unexpected error occurred',
          previousArticles:
              previousArticles.isNotEmpty ? previousArticles : null,
          section: previousSection,
        ),
      );
    }
  }
}
