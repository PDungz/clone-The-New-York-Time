import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/dio_client.dart';
import 'package:news_app/core/base/api/dio_interceptor/dio_exception_handler.dart';
import 'package:news_app/core/base/api/response/response_handler.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:packages/core/service/logger_service.dart';

/// Base class cho tất cả DataSource classes
/// Cung cấp common functionality và error handling
abstract class BaseDataSource {
  final DioClient _dioClient = DioClient.instance;

  /// Context name cho logging, nên được override bởi subclasses
  String get context;

  /// Khởi tạo base URL trước khi gọi API
  void _initializeBaseUrl() {
    _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
  }

  /// Execute API call với error handling tự động
  Future<Either<Failure, T>> executeApiCall<T>(
    Future<Response> Function() apiCall,
    Either<Failure, T> Function(Response) responseHandler,
    String operationName,
  ) async {
    try {
      _initializeBaseUrl();

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

  /// Helper cho GET requests trả về page data
  Future<Either<Failure, BasePageModel<T>>> getPageData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<BasePageModel<T>>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsPage(fromJson, dataType, context: context),
      operationName ?? 'getPageData',
    );
  }

  /// Helper cho GET requests trả về list data
  Future<Either<Failure, List<T>>> getListData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<List<T>>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsList(fromJson, dataType, context: context),
      operationName ?? 'getListData',
    );
  }

  /// Helper cho GET requests trả về single object
  Future<Either<Failure, T>> getObjectData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<T>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsObject(fromJson, dataType, context: context),
      operationName ?? 'getObjectData',
    );
  }

  /// Helper cho GET requests trả về int
  Future<Either<Failure, int>> getIntData(
    String endpoint,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<int>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsInt(dataType, context: context),
      operationName ?? 'getIntData',
    );
  }

  /// Helper cho GET requests trả về bool
  Future<Either<Failure, bool>> getBoolData(
    String endpoint,
    String dataType, {
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<bool>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) => response.handleAsBool(dataType, context: context),
      operationName ?? 'getBoolData',
    );
  }

  /// Helper cho GET requests trả về string message
  Future<Either<Failure, String>> getStringData(
    String endpoint,
    String defaultMessage, {
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeApiCall<String>(
      () => _dioClient.dio.get(endpoint, queryParameters: queryParams),
      (response) =>
          response.handleAsString(defaultMessage, context: context, successCodes: successCodes),
      operationName ?? 'getStringData',
    );
  }

  /// Helper cho POST requests trả về string message
  Future<Either<Failure, String>> postStringData(
    String endpoint,
    String defaultMessage, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeApiCall<String>(
      () => _dioClient.dio.post(endpoint, data: data, queryParameters: queryParams),
      (response) =>
          response.handleAsString(defaultMessage, context: context, successCodes: successCodes),
      operationName ?? 'postStringData',
    );
  }

  /// Helper cho POST requests trả về object
  Future<Either<Failure, T>> postObjectData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<T>(
      () => _dioClient.dio.post(endpoint, data: data, queryParameters: queryParams),
      (response) => response.handleAsObject(fromJson, dataType, context: context),
      operationName ?? 'postObjectData',
    );
  }

  /// Helper cho POST requests trả về bool
  Future<Either<Failure, bool>> postBoolData(
    String endpoint,
    String dataType, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
  }) async {
    return executeApiCall<bool>(
      () => _dioClient.dio.post(endpoint, data: data, queryParameters: queryParams),
      (response) => response.handleAsBool(dataType, context: context),
      operationName ?? 'postBoolData',
    );
  }

  /// Helper cho PUT requests trả về string message
  Future<Either<Failure, String>> putStringData(
    String endpoint,
    String defaultMessage, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeApiCall<String>(
      () => _dioClient.dio.put(endpoint, data: data, queryParameters: queryParams),
      (response) =>
          response.handleAsString(defaultMessage, context: context, successCodes: successCodes),
      operationName ?? 'putStringData',
    );
  }

  /// Helper cho DELETE requests trả về string message
  Future<Either<Failure, String>> deleteStringData(
    String endpoint,
    String defaultMessage, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeApiCall<String>(
      () => _dioClient.dio.delete(endpoint, data: data, queryParameters: queryParams),
      (response) =>
          response.handleAsString(defaultMessage, context: context, successCodes: successCodes),
      operationName ?? 'deleteStringData',
    );
  }

  /// Helper cho void operations (như DELETE không trả về data)
  Future<Either<Failure, void>> executeVoidOperation(
    String endpoint,
    String httpMethod, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? operationName,
    List<int> successCodes = const [200, 201, 204],
  }) async {
    return executeApiCall<void>(
      () {
        switch (httpMethod.toUpperCase()) {
          case 'POST':
            return _dioClient.dio.post(endpoint, data: data, queryParameters: queryParams);
          case 'PUT':
            return _dioClient.dio.put(endpoint, data: data, queryParameters: queryParams);
          case 'DELETE':
            return _dioClient.dio.delete(endpoint, data: data, queryParameters: queryParams);
          case 'PATCH':
            return _dioClient.dio.patch(endpoint, data: data, queryParameters: queryParams);
          default:
            return _dioClient.dio.get(endpoint, queryParameters: queryParams);
        }
      },
      (response) => response.handleAsVoid(
        context: context,
        operation: operationName,
        successCodes: successCodes,
      ),
      operationName ?? 'executeVoidOperation',
    );
  }

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

  /// Log response info
  void logResponse(Response response, String operation) {
    printI('[$context] $operation completed - Status: ${response.statusCode}');
  }
}

/// Mixin để thêm pagination support
mixin PaginationMixin on BaseDataSource {
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
mixin FilteringMixin on BaseDataSource {
  /// Helper để xây dựng filter query params
  Map<String, dynamic> buildFilterParams({
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
    Map<String, dynamic>? additionalFilters,
  }) {
    final filters = <String, dynamic>{
      'status': status,
      'categoryName': categoryName,
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
