class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final String? status; // NY Times API status
  final String? copyright; // NY Times copyright info
  final int? numResults; // Number of results returned
  final List<String>? faults; // NY Times fault array

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.status,
    this.copyright,
    this.numResults,
    this.faults,
  });

  factory ApiResponse.success(
    T data, {
    String? message,
    int? statusCode,
    String? status,
    String? copyright,
    int? numResults,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      status: status,
      copyright: copyright,
      numResults: numResults,
    );
  }

  factory ApiResponse.error(
    String error, {
    int? statusCode,
    List<String>? faults,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
      faults: faults,
    );
  }

  // Factory constructor để parse từ NY Times API response
  factory ApiResponse.fromNyTimesResponse(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
  }) {
    try {
      final status = json['status'] as String?;
      final copyright = json['copyright'] as String?;
      final numResults = json['num_results'] as int?;
      final results = json['results'];
      final faults =
          json['faults'] != null ? List<String>.from(json['faults']) : null;

      // Check if API returned OK status
      if (status == 'OK' && results != null) {
        T? parsedData;
        if (dataParser != null) {
          parsedData = dataParser(results);
        } else {
          parsedData = results as T?;
        }

        return ApiResponse.success(
          parsedData as T,
          status: status,
          copyright: copyright,
          numResults: numResults,
          statusCode: 200,
        );
      } else {
        // Handle error cases
        String errorMessage = 'Unknown error occurred';

        if (faults != null && faults.isNotEmpty) {
          errorMessage = faults.join(', ');
        } else if (status != null && status != 'OK') {
          errorMessage = 'API returned status: $status';
        }

        return ApiResponse.error(
          errorMessage,
          faults: faults,
          statusCode: json['status_code'] as int?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse API response: $e',
        statusCode: 500,
      );
    }
  }
}
