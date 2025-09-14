import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/api_service.dart';
import 'package:news_app/core/base/api/dio_client.dart';
import 'package:news_app/core/base/api/dio_interceptor/dio_exception_handler.dart';
import 'package:news_app/core/base/api/model/api_response.dart';
import 'package:news_app/core/base/api/response/response_handler.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:packages/core/service/logger_service.dart';

/// Enhanced Base DataSource hỗ trợ cả ApiService và DioClient
abstract class BaseDataSourceV2 {
  /// Context name cho logging
  String get context;

  /// Optional ApiService cho legacy APIs (như NY Times)
  ApiService? get apiService => null;

  /// DioClient cho modern APIs
  final DioClient _dioClient = DioClient.instance;

  /// Khởi tạo base URL cho DioClient
  void _initializeDioBaseUrl() {
    _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
  }

  /// Khởi tạo base URL cho ApiService
  void _initializeApiServiceBaseUrl(String baseUrl) {
    apiService?.updateBaseUrl(baseUrl);
  }

  // ===============================
  // DIOCLIENT METHODS (Modern APIs)
  // ===============================

  /// Execute API call với DioClient
  Future<Either<Failure, T>> executeDioCall<T>(
    Future<Response> Function() apiCall,
    Either<Failure, T> Function(Response) responseHandler,
    String operationName,
  ) async {
    try {
      _initializeDioBaseUrl();

      printI('[$context] Starting $operationName');

      final response = await apiCall();

      return responseHandler(response);
    } on DioException catch (dioError) {
      return dioError.handle<T>(operationName, context);
    } catch (e) {
      printE('[$context] Unexpected exception in $operationName: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Helper cho GET requests với DioClient trả về page data
  Future<Either<Failure, BasePageModel<T>>> getDioPageData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeDioCall<BasePageModel<T>>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsPage(fromJson, dataType, context: context),
      operationName ?? 'getDioPageData',
    );
  }

  /// Helper cho GET requests với DioClient trả về list data
  Future<Either<Failure, List<T>>> getDioListData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeDioCall<List<T>>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsList(fromJson, dataType, context: context),
      operationName ?? 'getDioListData',
    );
  }

  /// Helper cho POST requests với DioClient
  Future<Either<Failure, String>> postDioStringData(
    String endpoint,
    String defaultMessage, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeDioCall<String>(
      () => _dioClient.dio.post(endpoint, data: data, queryParameters: queryParams),
      (response) =>
          response.handleAsString(defaultMessage, context: context, successCodes: successCodes),
      operationName ?? 'postDioStringData',
    );
  }

  // ===============================
  // APISERVICE METHODS (Legacy APIs)
  // ===============================

  /// Execute API call với ApiService
  Future<Either<Failure, T>> executeApiServiceCall<T>(
    Future<ApiResponse<dynamic>> Function() apiCall,
    Either<Failure, T> Function(Map<String, dynamic>) dataHandler,
    String operationName, {
    String? baseUrl,
  }) async {
    try {
      if (apiService == null) {
        return Left(ServerFailure('ApiService not available'));
      }

      if (baseUrl != null) {
        _initializeApiServiceBaseUrl(baseUrl);
      }

      printI('[$context] Starting $operationName');

      final response = await apiCall();

      return _handleApiResponse<T>(response, dataHandler, operationName);
    } catch (e) {
      printE('[$context] Unexpected exception in $operationName: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Helper để xử lý ApiResponse
  Either<Failure, T> _handleApiResponse<T>(
    ApiResponse<dynamic> response,
    Either<Failure, T> Function(Map<String, dynamic>) dataHandler,
    String operationName,
  ) {
    // Check API response success
    if (!response.success || response.data == null) {
      printE('[$context] API error in $operationName: ${response.error}');
      return Left(ServerFailure(response.error ?? 'Unknown API error'));
    }

    final responseData = response.data;

    // Handle different data types
    Map<String, dynamic> dataMap;
    if (responseData is Map<String, dynamic>) {
      dataMap = responseData;
    } else if (responseData is String) {
      try {
        // Try to parse as JSON if it's a string
        dataMap = {'data': responseData};
      } catch (e) {
        return Left(ServerFailure('Invalid response format'));
      }
    } else {
      return Left(ServerFailure('Unexpected response data type'));
    }

    return dataHandler(dataMap);
  }

  /// Helper cho NY Times API pattern
  Future<Either<Failure, List<T>>> getNYTimesListData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    if (apiService == null) {
      return Left(ServerFailure('ApiService not available for NY Times API'));
    }

    return executeApiServiceCall<List<T>>(
      () => apiService!.get<Map<String, dynamic>>(endpoint),
      (dataMap) => _handleNYTimesResponse<T>(dataMap, fromJson, dataType),
      operationName ?? 'getNYTimesListData',
      baseUrl: AppConfigManagerBase.apiBaseUrlNYT,
    );
  }

  /// Xử lý NY Times API response format
  Either<Failure, List<T>> _handleNYTimesResponse<T>(
    Map<String, dynamic> responseData,
    T Function(Map<String, dynamic>) fromJson,
    String dataType,
  ) {
    try {
      // Check NY Times API status
      final String? status = responseData['status'];
      if (status != 'OK') {
        final List<String>? faults = responseData['faults']?.cast<String>();
        final String errorMsg = faults?.join(', ') ?? 'API status not OK';
        return Left(ServerFailure(errorMsg));
      }

      // Parse results
      final List<dynamic>? results = responseData['results'];
      if (results == null) {
        return Left(ServerFailure('No results found'));
      }

      final List<T> items = results.map((json) => fromJson(json as Map<String, dynamic>)).toList();

      printI('[$context] Successfully parsed ${items.length} $dataType');
      return Right(items);
    } catch (e) {
      printE('[$context] Error parsing NY Times response: $e');
      return Left(ServerFailure('Failed to parse NY Times response: $e'));
    }
  }

  // ===============================
  // UTILITY METHODS
  // ===============================

  /// Build query parameters, filtering out null values
  Map<String, dynamic> buildQueryParams(Map<String, dynamic> params) {
    final queryParams = <String, dynamic>{};

    params.forEach((key, value) {
      if (value != null) {
        queryParams[key] = value;
      }
    });

    return queryParams;
  }

  /// Log request parameters for debugging
  void logRequestParams(String endpoint, Map<String, dynamic>? params) {
    if (params != null && params.isNotEmpty) {
      printI('[$context] Request to $endpoint with params: $params');
    } else {
      printI('[$context] Request to $endpoint');
    }
  }
}

/// Mixin để thêm pagination support
mixin PaginationMixinV2 on BaseDataSourceV2 {
  /// Helper để xây dựng pagination query params
  Map<String, dynamic> buildPaginationParams({
    int page = 0,
    int size = 20,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = <String, dynamic>{'page': page, 'size': size};

    if (additionalParams != null) {
      params.addAll(buildQueryParams(additionalParams));
    }

    return params;
  }

  /// Log pagination info
  void logPagination(int page, int size, String operation) {
    printI('[$context] $operation - page: $page, size: $size');
  }
}

/// Mixin để thêm filtering support
mixin FilteringMixinV2 on BaseDataSourceV2 {
  /// Helper để xây dựng filter query params
  Map<String, dynamic> buildFilterParams({
    String? status,
    String? categoryId,
    String? type,
    String? startDate,
    String? endDate,
    Map<String, dynamic>? additionalFilters,
  }) {
    final filters = <String, dynamic>{
      'status': status,
      'categoryId': categoryId,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
    };

    if (additionalFilters != null) {
      filters.addAll(additionalFilters);
    }

    return buildQueryParams(filters);
  }

  /// Log filter info
  void logFilters(Map<String, dynamic> filters, String operation) {
    if (filters.isNotEmpty) {
      printI('[$context] $operation with filters: $filters');
    }
  }
}
