import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:packages/core/service/logger_service.dart';

class ResponseHandler {
  ResponseHandler._();

  /// Xử lý response cho BasePageModel với generic type
  static Either<Failure, BasePageModel<T>> handlePageResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final data = response.data['data'] ?? response.data;
        final pageModel = BasePageModel<T>.fromJson(data, fromJson);

        printI('$contextInfo Successfully parsed ${pageModel.content.length} $dataType');
        return Right(pageModel);
      } catch (parseError) {
        printE('$contextInfo JSON parsing error: $parseError');
        return Left(ServerFailure('Failed to parse $dataType response'));
      }
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Server error: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho List với generic type
  static Either<Failure, List<T>> handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final data = response.data['data'] as List<dynamic>? ?? [];
        final items = data.map((json) => fromJson(json as Map<String, dynamic>)).toList();

        printI('$contextInfo Successfully parsed ${items.length} $dataType');
        return Right(items);
      } catch (parseError) {
        printE('$contextInfo JSON parsing error: $parseError');
        return Left(ServerFailure('Failed to parse $dataType response'));
      }
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Server error: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho String messages
  static Either<Failure, String> handleStringResponse(
    Response response,
    String defaultMessage, {
    String? context,
    List<int> successCodes = const [200, 201, 204],
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (successCodes.contains(response.statusCode)) {
      final message = _extractMessage(response.data) ?? defaultMessage;
      printI('$contextInfo Operation successful: $message');
      return Right(message);
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Operation failed: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho int values
  static Either<Failure, int> handleIntResponse(
    Response response,
    String dataType, {
    String? context,
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final value = response.data['data'] as int? ?? 0;
        printI('$contextInfo Successfully got $dataType: $value');
        return Right(value);
      } catch (parseError) {
        printE('$contextInfo JSON parsing error: $parseError');
        return Left(ServerFailure('Failed to parse $dataType response'));
      }
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Server error: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho bool values
  static Either<Failure, bool> handleBoolResponse(
    Response response,
    String dataType, {
    String? context,
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final value = response.data['data'] as bool? ?? false;
        printI('$contextInfo Successfully got $dataType: $value');
        return Right(value);
      } catch (parseError) {
        printE('$contextInfo JSON parsing error: $parseError');
        return Left(ServerFailure('Failed to parse $dataType response'));
      }
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Server error: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho single object
  static Either<Failure, T> handleObjectResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = response.data['data'] ?? response.data;
        final object = fromJson(data as Map<String, dynamic>);

        printI('$contextInfo Successfully parsed $dataType');
        return Right(object);
      } catch (parseError) {
        printE('$contextInfo JSON parsing error: $parseError');
        return Left(ServerFailure('Failed to parse $dataType response'));
      }
    } else {
      printE('$contextInfo Server error - Status: ${response.statusCode}');
      return Left(ServerFailure('Server error: ${response.statusCode}'));
    }
  }

  /// Xử lý response cho void operations (delete, update, etc.)
  static Either<Failure, void> handleVoidResponse(
    Response response, {
    String? context,
    String? operation,
    List<int> successCodes = const [200, 201, 204],
  }) {
    final contextInfo = context != null ? '[$context]' : '[ResponseHandler]';
    final operationName = operation ?? 'Operation';

    printI('$contextInfo Response status: ${response.statusCode}');

    if (successCodes.contains(response.statusCode)) {
      printI('$contextInfo $operationName completed successfully');
      return const Right(null);
    } else {
      printE('$contextInfo $operationName failed - Status: ${response.statusCode}');
      return Left(ServerFailure('$operationName failed: ${response.statusCode}'));
    }
  }

  /// Extract message từ response data với multiple patterns
  static String? _extractMessage(dynamic responseData) {
    if (responseData == null) return null;

    try {
      if (responseData is Map<String, dynamic>) {
        // Pattern 1: {"message": "..."}
        if (responseData['message'] is String) {
          return responseData['message'];
        }

        // Pattern 2: {"data": {"message": "..."}}
        if (responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data['message'] is String) {
            return data['message'];
          }
        }

        // Pattern 3: {"success": true, "message": "..."}
        if (responseData['success'] == true && responseData['message'] is String) {
          return responseData['message'];
        }
      }
    } catch (e) {
      printW('[ResponseHandler] Failed to extract message: $e');
    }

    return null;
  }

  /// Validate response structure
  static bool isValidResponse(Response response) {
    return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
  }

  /// Extract error message từ failed response
  static String extractErrorMessage(Response? response, [String defaultMessage = 'Unknown error']) {
    if (response?.data == null) return defaultMessage;

    try {
      final data = response!.data;

      if (data is Map<String, dynamic>) {
        // Thử các patterns khác nhau
        final patterns = ['message', 'error', 'details', 'description'];

        for (final pattern in patterns) {
          if (data[pattern] is String) {
            return data[pattern];
          }
        }

        // Nested data
        if (data['data'] is Map<String, dynamic>) {
          final nestedData = data['data'] as Map<String, dynamic>;
          for (final pattern in patterns) {
            if (nestedData[pattern] is String) {
              return nestedData[pattern];
            }
          }
        }
      }

      return data.toString();
    } catch (e) {
      return defaultMessage;
    }
  }
}

/// Extension methods cho Response để sử dụng ResponseHandler dễ dàng hơn
extension ResponseHandling on Response {
  /// Handle page response
  Either<Failure, BasePageModel<T>> handleAsPage<T>(
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) => ResponseHandler.handlePageResponse(this, fromJson, dataType, context: context);

  /// Handle list response
  Either<Failure, List<T>> handleAsList<T>(
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) => ResponseHandler.handleListResponse(this, fromJson, dataType, context: context);

  /// Handle string response
  Either<Failure, String> handleAsString(
    String defaultMessage, {
    String? context,
    List<int> successCodes = const [200, 201, 204],
  }) => ResponseHandler.handleStringResponse(
    this,
    defaultMessage,
    context: context,
    successCodes: successCodes,
  );

  /// Handle int response
  Either<Failure, int> handleAsInt(String dataType, {String? context}) =>
      ResponseHandler.handleIntResponse(this, dataType, context: context);

  /// Handle bool response
  Either<Failure, bool> handleAsBool(String dataType, {String? context}) =>
      ResponseHandler.handleBoolResponse(this, dataType, context: context);

  /// Handle object response
  Either<Failure, T> handleAsObject<T>(
    T Function(Map<String, dynamic>) fromJson,
    String dataType, {
    String? context,
  }) => ResponseHandler.handleObjectResponse(this, fromJson, dataType, context: context);

  /// Handle void response
  Either<Failure, void> handleAsVoid({
    String? context,
    String? operation,
    List<int> successCodes = const [200, 201, 204],
  }) => ResponseHandler.handleVoidResponse(
    this,
    context: context,
    operation: operation,
    successCodes: successCodes,
  );

  /// Check if response is valid
  bool get isValid => ResponseHandler.isValidResponse(this);

  /// Extract error message
  String extractError([String defaultMessage = 'Unknown error']) =>
      ResponseHandler.extractErrorMessage(this, defaultMessage);
}
