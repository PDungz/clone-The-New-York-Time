import 'package:equatable/equatable.dart';

class BasePageModel<T> extends Equatable {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool last;
  final bool first;
  final int numberOfElements;
  final bool empty;

  const BasePageModel({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.last,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  // Factory constructor from JSON - khớp với API response
  factory BasePageModel.fromJson(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    if (json == null) return BasePageModel.empty();

    try {
      // Parse content array
      final contentList = json['content'] as List<dynamic>? ?? [];
      final List<T> parsedContent = [];

      for (final item in contentList) {
        try {
          if (item is Map<String, dynamic>) {
            parsedContent.add(fromJsonT(item));
          }
        } catch (e) {
          // Skip invalid items
          print('Skipping invalid item: $e');
        }
      }

      return BasePageModel<T>(
        content: parsedContent,
        totalElements: json['totalElements'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
        size: json['size'] as int? ?? 0,
        number: json['number'] as int? ?? 0,
        last: json['last'] as bool? ?? true,
        first: json['first'] as bool? ?? true,
        numberOfElements: json['numberOfElements'] as int? ?? 0,
        empty: json['empty'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing BasePageModel: $e');
      return BasePageModel.empty();
    }
  }

  // Empty constructor
  factory BasePageModel.empty() {
    return BasePageModel<T>(
      content: const [],
      totalElements: 0,
      totalPages: 0,
      size: 0,
      number: 0,
      last: true,
      first: true,
      numberOfElements: 0,
      empty: true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'content': content.map(toJsonT).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'size': size,
      'number': number,
      'last': last,
      'first': first,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }

  // ===============================
  // COMPUTED PROPERTIES
  // ===============================

  /// Có dữ liệu hay không
  bool get hasContent => !empty && content.isNotEmpty;

  /// Có trang tiếp theo hay không
  bool get hasNext => !last;

  /// Có trang trước hay không
  bool get hasPrevious => !first;

  /// Trang hiện tại (1-indexed)
  int get currentPage => number + 1;

  /// Tiến trình phân trang (0.0 - 1.0)
  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;

  /// Số phần tử còn lại
  int get remainingElements => totalElements - ((number + 1) * size);

  /// Có phải trang cuối không
  bool get isLastPage => last || number >= totalPages - 1;

  /// Có phải trang đầu không
  bool get isFirstPage => first || number == 0;

  /// Vị trí bắt đầu của trang (1-indexed)
  int get startIndex => number * size + 1;

  /// Vị trí kết thúc của trang (1-indexed)
  int get endIndex => startIndex + numberOfElements - 1;

  /// Thông tin trang dạng "1-20 của 84"
  String get pageInfo => totalElements > 0 ? '$startIndex-$endIndex của $totalElements' : '0 của 0';

  /// Hiển thị trang dạng "Page 3/5"
  String get pageDisplay => 'Page $currentPage/$totalPages';

  /// Tổng số items đã load (cho infinite scroll)
  int get loadedItemsCount => (number * size) + numberOfElements;

  /// Phần trăm đã load
  double get loadedPercentage => totalElements > 0 ? loadedItemsCount / totalElements : 0.0;

  // ===============================
  // UTILITY METHODS
  // ===============================

  /// Copy với các giá trị mới
  BasePageModel<T> copyWith({
    List<T>? content,
    int? totalElements,
    int? totalPages,
    int? size,
    int? number,
    bool? last,
    bool? first,
    int? numberOfElements,
    bool? empty,
  }) {
    return BasePageModel<T>(
      content: content ?? this.content,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      size: size ?? this.size,
      number: number ?? this.number,
      last: last ?? this.last,
      first: first ?? this.first,
      numberOfElements: numberOfElements ?? this.numberOfElements,
      empty: empty ?? this.empty,
    );
  }

  /// Merge với trang tiếp theo (cho infinite scroll)
  BasePageModel<T> mergeWithNextPage(BasePageModel<T> nextPage) {
    return BasePageModel<T>(
      content: [...content, ...nextPage.content],
      totalElements: nextPage.totalElements,
      totalPages: nextPage.totalPages,
      size: size,
      number: nextPage.number,
      last: nextPage.last,
      first: first,
      numberOfElements: content.length + nextPage.content.length,
      empty: false,
    );
  }

  /// Lấy item theo index (safe)
  T? getItemAt(int index) {
    if (index >= 0 && index < content.length) {
      return content[index];
    }
    return null;
  }

  /// Tìm item theo điều kiện
  T? findItem(bool Function(T) predicate) {
    try {
      return content.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  /// Lọc items theo điều kiện
  List<T> filterItems(bool Function(T) predicate) {
    return content.where(predicate).toList();
  }

  /// Kiểm tra có item nào thỏa mãn điều kiện không
  bool hasItemWhere(bool Function(T) predicate) {
    return content.any(predicate);
  }

  /// Đếm số items thỏa mãn điều kiện
  int countWhere(bool Function(T) predicate) {
    return content.where(predicate).length;
  }

  // ===============================
  // VALIDATION
  // ===============================

  /// Kiểm tra tính hợp lệ của model
  bool get isValid {
    return totalElements >= 0 &&
        totalPages >= 0 &&
        size >= 0 &&
        number >= 0 &&
        numberOfElements >= 0 &&
        numberOfElements <= size &&
        content.length == numberOfElements &&
        (empty ? numberOfElements == 0 : numberOfElements > 0);
  }

  /// Lấy thông tin debug
  Map<String, dynamic> get debugInfo {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': size,
      'itemsInCurrentPage': numberOfElements,
      'totalItems': totalElements,
      'loadedItems': loadedItemsCount,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'isValid': isValid,
      'progress': '${(progress * 100).toStringAsFixed(1)}%',
    };
  }

  // ===============================
  // EQUATABLE
  // ===============================

  @override
  List<Object?> get props => [
    content,
    totalElements,
    totalPages,
    size,
    number,
    last,
    first,
    numberOfElements,
    empty,
  ];

  @override
  String toString() {
    return 'BasePageModel<$T>('
        'page: $currentPage/$totalPages, '
        'items: ${content.length}/$totalElements, '
        'hasNext: $hasNext'
        ')';
  }
}

// ===============================
// EXTENSION METHODS
// ===============================

// Extension cho List<BasePageModel>
extension BasePageModelListExtension<T> on List<BasePageModel<T>> {
  /// Merge tất cả pages thành một danh sách
  List<T> get allContent {
    final List<T> result = [];
    for (final page in this) {
      result.addAll(page.content);
    }
    return result;
  }

  /// Tổng số items trong tất cả pages
  int get totalContentCount => fold(0, (sum, page) => sum + page.numberOfElements);

  /// Page cuối cùng
  BasePageModel<T>? get lastPage => isEmpty ? null : last;

  /// Page đầu tiên
  BasePageModel<T>? get firstPage => isEmpty ? null : first;
}
