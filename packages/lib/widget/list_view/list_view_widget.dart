import 'package:flutter/material.dart';
import 'package:packages/widget/widget_library/refresh_indicator_widget.dart';

class ListViewWidget<T> extends StatelessWidget {
  final List<T> data;
  final bool isLoading;
  final bool isLoadingMore;

  /// Builder function to create each list item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional refresh callback
  final Future<void> Function()? onRefresh;

  /// Load more callback
  final Future<void> Function()? onLoadMore;

  /// Custom refresh indicator widget
  final Widget? refreshWidget;

  /// Refresh icon for icon-based refresh
  final IconData? refreshIcon;

  /// SVG asset path for SVG-based refresh
  final String? refreshSvgAsset;

  /// Refresh indicator color
  final Color? refreshColor;

  /// Refresh indicator background color
  final Color? refreshBackgroundColor;

  /// Refresh indicator displacement
  final double refreshIndicatorDisplacement;

  /// Whether to animate refresh icon
  final bool animateRefreshIcon;

  /// Loading widget to show during initial load
  final Widget? loadingWidget;

  /// Loading widget to show during load more
  final Widget? loadMoreWidget;

  /// Custom scroll physics
  final ScrollPhysics? physics;

  /// Cache extent for performance optimization
  final double? cacheExtent;

  /// Padding for the entire list
  final EdgeInsets? padding;

  /// Scroll controller
  final ScrollController? controller;

  /// Whether to show refresh indicator
  final bool enableRefresh;

  /// Whether to enable load more
  final bool enableLoadMore;

  /// Custom empty state widget
  final Widget? emptyWidget;

  /// Loading displacement for refresh indicator
  final double refreshDisplacement;

  /// Threshold for triggering load more (pixels from bottom)
  final double loadMoreThreshold;

  /// Force allow refresh even when data is not empty or in loading state
  final bool forceEnableRefresh;

  /// Force allow load more even when hasReachedMax is true
  final bool forceEnableLoadMore;

  /// Always allow refresh regardless of data state
  final bool alwaysAllowRefresh;

  /// Always allow load more regardless of pagination state
  final bool alwaysAllowLoadMore;

  /// Minimum items required to enable load more (default: 0 means always enabled if onLoadMore is provided)
  final int minimumItemsForLoadMore;

  /// Whether to enable load more when data is empty
  final bool enableLoadMoreOnEmpty;

  const ListViewWidget({
    super.key,
    required this.data,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.loadingWidget,
    this.loadMoreWidget,
    this.refreshWidget,
    this.refreshIcon,
    this.refreshSvgAsset,
    this.refreshColor,
    this.refreshBackgroundColor,
    this.refreshIndicatorDisplacement = 40.0,
    this.animateRefreshIcon = true,
    this.physics = const BouncingScrollPhysics(),
    this.cacheExtent,
    this.padding,
    this.controller,
    this.enableRefresh = true,
    this.enableLoadMore = false,
    this.emptyWidget,
    this.refreshDisplacement = 40.0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.loadMoreThreshold = 200.0,
    this.forceEnableRefresh = false,
    this.forceEnableLoadMore = false,
    this.alwaysAllowRefresh = false,
    this.alwaysAllowLoadMore = false,
    this.minimumItemsForLoadMore = 0,
    this.enableLoadMoreOnEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    // Hiển thị loading state ban đầu
    if (isLoading && data.isEmpty) {
      content = _buildLoadingList();
    }
    // Hiển thị empty state khi không có dữ liệu
    else if (!isLoading && data.isEmpty) {
      content = _buildEmptyState(buildContext: context);
    }
    // Hiển thị danh sách dữ liệu
    else {
      content = _buildDataList(context);
    }

    // ONLY wrap with RefreshIndicator here at the top level
    if (_shouldEnableRefresh()) {
      return _buildRefreshIndicator(content);
    }

    return content;
  }

  /// Kiểm tra có nên enable refresh không
  bool _shouldEnableRefresh() {
    if (!enableRefresh || onRefresh == null) return false;

    // Luôn cho phép refresh nếu được config
    if (alwaysAllowRefresh || forceEnableRefresh) return true;

    // Cho phép refresh khi có dữ liệu hoặc empty state
    return true;
  }

  /// Kiểm tra có nên enable load more không
  bool _shouldEnableLoadMore() {
    if (!enableLoadMore || onLoadMore == null) return false;

    // Luôn cho phép load more nếu được config
    if (alwaysAllowLoadMore || forceEnableLoadMore) return true;

    // Kiểm tra số lượng item tối thiểu
    if (data.length < minimumItemsForLoadMore) return false;

    // Cho phép load more khi data rỗng nếu được enable
    if (data.isEmpty && enableLoadMoreOnEmpty) return true;

    // Cho phép load more khi có dữ liệu
    return data.isNotEmpty;
  }

  /// Widget hiển thị loading dạng list
  Widget _buildLoadingList() {
    final loadingItem = loadingWidget ?? _defaultLoadingItem();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: 10, // Hiển thị 10 loading items
      itemBuilder: (context, index) => loadingItem,
    );
  }

  /// Widget mặc định cho loading item
  Widget _defaultLoadingItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị empty state
  Widget _buildEmptyState({required BuildContext buildContext}) {
    // Tạo scrollable content để refresh indicator hoạt động
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép scroll
      child: SizedBox(
        height: MediaQuery.of(buildContext).size.height * 0.8, // Đủ cao để có thể scroll
        child: emptyWidget ?? _defaultEmptyWidget(),
      ),
    );
  }

  /// Widget mặc định cho empty state
  Widget _defaultEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Not found data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again later.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị danh sách dữ liệu - FIX CHÍNH TẠI ĐÂY
  Widget _buildDataList(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Xử lý load more với logic mới
            if (_shouldEnableLoadMore() &&
                !isLoadingMore &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - loadMoreThreshold) {
              onLoadMore!();
            }
            return false;
          },
          child: ListView.builder(
            controller: controller,
            // *** FIX CHÍNH: Đảm bảo luôn có thể scroll để refresh hoạt động ***
            physics: _shouldEnableRefresh() ? const AlwaysScrollableScrollPhysics() : physics,
            cacheExtent: cacheExtent,
            padding: _buildPadding(context, constraints),
            itemCount: _getItemCount(),
            itemBuilder: (context, index) {
              // Hiển thị item dữ liệu
              if (index < data.length) {
                return itemBuilder(context, data[index], index);
              }

              // Hiển thị load more widget ở cuối danh sách
              if (_shouldEnableLoadMore() && isLoadingMore) {
                return _buildLoadMoreWidget();
              }

              // *** FIX CHÍNH: Thêm invisible spacer để đảm bảo có thể scroll ***
              if (index == data.length && _shouldEnableRefresh()) {
                return _buildInvisibleSpacer(constraints);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  /// *** FIX CHÍNH: Tạo padding động để đảm bảo scroll space ***
  EdgeInsets? _buildPadding(BuildContext context, BoxConstraints constraints) {
    if (_shouldEnableRefresh() && data.isNotEmpty) {
      // Thêm padding bottom để tạo scroll space cho refresh
      final defaultPadding = padding ?? EdgeInsets.zero;
      final extraPadding = constraints.maxHeight * 0.1; // 10% chiều cao màn hình

      return EdgeInsets.only(
        top: defaultPadding.top,
        left: defaultPadding.left,
        right: defaultPadding.right,
        bottom: defaultPadding.bottom + extraPadding,
      );
    }
    return padding;
  }

  /// *** FIX CHÍNH: Tạo invisible spacer để đảm bảo có scroll space ***
  Widget _buildInvisibleSpacer(BoxConstraints constraints) {
    if (!_shouldEnableRefresh()) return const SizedBox.shrink();

    // Tạo một khoảng trống invisible để đảm bảo có thể scroll
    return SizedBox(
      height: constraints.maxHeight * 0.2, // 20% chiều cao màn hình
      child: const SizedBox.shrink(),
    );
  }

  /// Xây dựng RefreshIndicator tùy chỉnh
  Widget _buildRefreshIndicator(Widget child) {
    // Nếu có custom widget
    if (refreshWidget != null) {
      return RefreshIndicatorWidget.withWidget(
        onRefresh: onRefresh!,
        customWidget: refreshWidget!,
        displacement: refreshIndicatorDisplacement,
        backgroundColor: refreshBackgroundColor,
        animateIcon: animateRefreshIcon,
        child: child,
      );
    }

    // Nếu có SVG asset
    if (refreshSvgAsset != null) {
      return RefreshIndicatorWidget.withSvg(
        onRefresh: onRefresh!,
        svgAsset: refreshSvgAsset!,
        displacement: refreshIndicatorDisplacement,
        color: refreshColor,
        backgroundColor: refreshBackgroundColor,
        animateIcon: animateRefreshIcon,
        child: child,
      );
    }

    // Nếu có custom icon
    if (refreshIcon != null) {
      return RefreshIndicatorWidget.withIcon(
        onRefresh: onRefresh!,
        customIcon: refreshIcon!,
        displacement: refreshIndicatorDisplacement,
        color: refreshColor,
        backgroundColor: refreshBackgroundColor,
        animateIcon: animateRefreshIcon,
        child: child,
      );
    }

    // Sử dụng RefreshIndicator mặc định
    return RefreshIndicatorWidget(
      onRefresh: onRefresh!,
      displacement: refreshIndicatorDisplacement,
      color: refreshColor,
      backgroundColor: refreshBackgroundColor,
      child: child,
    );
  }

  /// Tính toán số lượng item trong danh sách
  int _getItemCount() {
    int count = data.length;
    
    // Thêm load more widget nếu đang loading more
    if (_shouldEnableLoadMore() && isLoadingMore) {
      count += 1;
    }
    
    // *** FIX CHÍNH: Thêm invisible spacer item nếu cần refresh ***
    if (_shouldEnableRefresh() && data.isNotEmpty && !isLoadingMore) {
      count += 1; // Cho invisible spacer
    }
    
    return count;
  }

  /// Widget hiển thị load more
  Widget _buildLoadMoreWidget() {
    return loadMoreWidget ?? _defaultLoadMoreWidget();
  }

  /// Widget mặc định cho load more
  Widget _defaultLoadMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Loading more...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Extension để dễ sử dụng
extension ListViewWidgetExtension<T> on ListViewWidget<T> {
  /// Tạo ListView với cấu hình cơ bản
  static ListViewWidget<T> basic<T>({
    required List<T> data,
    required Widget Function(BuildContext, T, int) itemBuilder,
    bool isLoading = false,
    Widget? emptyWidget,
    Widget? loadingWidget,
    bool forceEnableRefresh = false,
    bool alwaysAllowRefresh = false,
  }) {
    return ListViewWidget<T>(
      data: data,
      itemBuilder: itemBuilder,
      isLoading: isLoading,
      enableRefresh: false,
      refreshDisplacement: 40.0,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      forceEnableRefresh: forceEnableRefresh,
      alwaysAllowRefresh: alwaysAllowRefresh,
    );
  }

  /// Tạo ListView với refresh
  static ListViewWidget<T> withRefresh<T>({
    required List<T> data,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required Future<void> Function() onRefresh,
    bool isLoading = false,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? refreshWidget,
    IconData? refreshIcon,
    String? refreshSvgAsset,
    Color? refreshColor,
    Color? refreshBackgroundColor,
    double refreshIndicatorDisplacement = 40.0,
    bool animateRefreshIcon = true,
    bool forceEnableRefresh = false,
    bool alwaysAllowRefresh = false,
  }) {
    return ListViewWidget<T>(
      data: data,
      itemBuilder: itemBuilder,
      onRefresh: onRefresh,
      isLoading: isLoading,
      enableRefresh: true,
      refreshDisplacement: 40.0,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      refreshWidget: refreshWidget,
      refreshIcon: refreshIcon,
      refreshSvgAsset: refreshSvgAsset,
      refreshColor: refreshColor,
      refreshBackgroundColor: refreshBackgroundColor,
      refreshIndicatorDisplacement: refreshIndicatorDisplacement,
      animateRefreshIcon: animateRefreshIcon,
      forceEnableRefresh: forceEnableRefresh,
      alwaysAllowRefresh: alwaysAllowRefresh,
    );
  }

  /// Tạo ListView với refresh và load more
  static ListViewWidget<T> withPagination<T>({
    required List<T> data,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required Future<void> Function() onRefresh,
    required Future<void> Function() onLoadMore,
    bool isLoading = false,
    bool isLoadingMore = false,
    Widget? emptyWidget,
    Widget? loadingWidget,
    Widget? loadMoreWidget,
    Widget? refreshWidget,
    IconData? refreshIcon,
    String? refreshSvgAsset,
    Color? refreshColor,
    Color? refreshBackgroundColor,
    double refreshIndicatorDisplacement = 40.0,
    bool animateRefreshIcon = true,
    bool forceEnableRefresh = false,
    bool forceEnableLoadMore = false,
    bool alwaysAllowRefresh = false,
    bool alwaysAllowLoadMore = false,
    int minimumItemsForLoadMore = 0,
    bool enableLoadMoreOnEmpty = true,
  }) {
    return ListViewWidget<T>(
      data: data,
      itemBuilder: itemBuilder,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      enableRefresh: true,
      enableLoadMore: true,
      refreshDisplacement: 40.0,
      emptyWidget: emptyWidget,
      loadingWidget: loadingWidget,
      loadMoreWidget: loadMoreWidget,
      refreshWidget: refreshWidget,
      refreshIcon: refreshIcon,
      refreshSvgAsset: refreshSvgAsset,
      refreshColor: refreshColor,
      refreshBackgroundColor: refreshBackgroundColor,
      refreshIndicatorDisplacement: refreshIndicatorDisplacement,
      animateRefreshIcon: animateRefreshIcon,
      forceEnableRefresh: forceEnableRefresh,
      forceEnableLoadMore: forceEnableLoadMore,
      alwaysAllowRefresh: alwaysAllowRefresh,
      alwaysAllowLoadMore: alwaysAllowLoadMore,
      minimumItemsForLoadMore: minimumItemsForLoadMore,
      enableLoadMoreOnEmpty: enableLoadMoreOnEmpty,
    );
  }
}
