class ApiResponseV2<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponseV2({required this.success, this.data, this.message, this.statusCode});

  // Factory constructor cho success response
  factory ApiResponseV2.success(T data, {String? message, int? statusCode}) {
    return ApiResponseV2<T>(success: true, data: data, message: message ?? 'Request completed successfully', statusCode: statusCode ?? 200);
  }

  // Factory constructor cho error response
  factory ApiResponseV2.error(String message, {T? data, int? statusCode}) {
    return ApiResponseV2<T>(success: false, data: data, message: message, statusCode: statusCode ?? 400);
  }

  // Factory constructor để parse từ JSON response
  factory ApiResponseV2.fromJson(Map<String, dynamic> json, {T Function(dynamic)? dataParser}) {
    try {
      final success = json['success'] as bool? ?? false;
      final message = json['message'] as String?;
      final statusCode = json['statusCode'] as int?;
      final dataJson = json['data'];

      T? parsedData;
      if (dataJson != null && dataParser != null) {
        parsedData = dataParser(dataJson);
      } else if (dataJson != null) {
        parsedData = dataJson as T?;
      }

      return ApiResponseV2<T>(success: success, data: parsedData, message: message, statusCode: statusCode);
    } catch (e) {
      return ApiResponseV2<T>(success: false, data: null, message: 'Failed to parse API response: $e', statusCode: 500);
    }
  }

  // Factory constructor để parse từ API response (giữ lại nếu cần)
  factory ApiResponseV2.fromNyTimesResponse(Map<String, dynamic> json, {T Function(dynamic)? dataParser}) {
    try {
      final status = json['status'] as String?;
      final results = json['results'];
      final faults = json['faults'] != null ? List<String>.from(json['faults']) : null;

      // Check if API returned OK status
      if (status == 'OK' && results != null) {
        T? parsedData;
        if (dataParser != null) {
          parsedData = dataParser(results);
        } else {
          parsedData = results as T?;
        }

        return ApiResponseV2.success(parsedData as T, message: 'Data fetched successfully', statusCode: 200);
      } else {
        // Handle error cases
        String errorMessage = 'Unknown error occurred';

        if (faults != null && faults.isNotEmpty) {
          errorMessage = faults.join(', ');
        } else if (status != null && status != 'OK') {
          errorMessage = 'API returned status: $status';
        }

        return ApiResponseV2.error(errorMessage, statusCode: 400);
      }
    } catch (e) {
      return ApiResponseV2.error('Failed to parse NY Times API response: $e', statusCode: 500);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson({Object? Function(T?)? dataSerializer}) {
    return {'success': success, 'message': message, 'statusCode': statusCode, 'data': dataSerializer != null ? dataSerializer(data) : data};
  }

  // Check if response is successful and has data
  bool get hasData => success && data != null;

  // Get data or throw exception if failed
  T get dataOrThrow {
    if (success && data != null) {
      return data!;
    }
    throw Exception(message ?? 'API request failed');
  }

  @override
  String toString() {
    return 'ApiResponseV2(success: $success, message: $message, statusCode: $statusCode, data: $data)';
  }
}

// Extension để làm việc với Future<ApiResponseV2>
extension ApiResponseV2Extensions<T> on Future<ApiResponseV2<T>> {
  Future<T> getDataOrThrow() async {
    final response = await this;
    return response.dataOrThrow;
  }

  Future<T?> getDataOrNull() async {
    final response = await this;
    return response.success ? response.data : null;
  }
}
