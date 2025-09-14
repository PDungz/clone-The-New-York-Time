// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';
import 'package:news_app/feature/home/domain/repository/topstories_repository.dart';

class TopStoriesUseCase {
  final TopStoriesRepository topStoriesRepository;

  TopStoriesUseCase({
    required this.topStoriesRepository,
  });

  Future<Either<Failure, List<Article>>> getTopStories({
    required String section,
  }) async {
    return topStoriesRepository.getTopStories(section: section);
  }
}
