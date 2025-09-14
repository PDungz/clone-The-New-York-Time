import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';

abstract class TopStoriesRepository {
  Future<Either<Failure, List<Article>>> getTopStories({
    required String section,
  });
}
