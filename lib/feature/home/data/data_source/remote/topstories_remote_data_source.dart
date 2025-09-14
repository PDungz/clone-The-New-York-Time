import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/api/api_service.dart';
import 'package:news_app/core/base/api/base_data/base_data_source_v2.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/home/data/model/article_model.dart';

abstract class TopStoriesRemoteDataSource {
  Future<Either<Failure, List<ArticleModel>>> getTopStories({required String section});
}

class TopStoriesRemoteDataSourceImpl extends BaseDataSourceV2
    implements TopStoriesRemoteDataSource {
  
  final ApiService _apiService;

  TopStoriesRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  String get context => 'TopStoriesDataSource';

  @override
  ApiService? get apiService => _apiService;

  @override
  Future<Either<Failure, List<ArticleModel>>> getTopStories({required String section}) async {
    logRequestParams('getTopStories', {'section': section});

    return getNYTimesListData<ArticleModel>(
      AppConfigManagerBase.topStoriesUrl(section: section),
      (json) => ArticleModel.fromJson(json),
      'top stories articles',
      operationName: 'getTopStories',
    );
  }
}
