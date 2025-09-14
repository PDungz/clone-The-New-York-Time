import 'package:flutter/material.dart';
import 'package:packages/widget/shadow/shadow_widget.dart';

/// Một widget đơn giản để lắng nghe thay đổi khi cuộn
class ScrollNotificationListener extends StatefulWidget {
  final ScrollController controller;
  final Widget Function(BuildContext context, ScrollNotification? scrollInfo)
  builder;

  const ScrollNotificationListener({
    super.key,
    required this.controller,
    required this.builder,
  });

  @override
  _ScrollNotificationListenerState createState() =>
      _ScrollNotificationListenerState();
}

class _ScrollNotificationListenerState
    extends State<ScrollNotificationListener> {
  ScrollNotification? _scrollInfo;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          setState(() {
            _scrollInfo = notification;
          });
        }
        return false;
      },
      child: widget.builder(context, _scrollInfo),
    );
  }
}

class TabLabelWidget extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final double indicatorHeight;
  final EdgeInsets? paddingTabel;

  // Xác định xem có khoảng cách hay không
  final bool spaceBetweenLabelAndIndicator;
  // Khoảng cách giữa nhãn và indicator, chỉ có tác dụng khi spaceBetweenLabelAndIndicator = true
  final double gapSize;

  // Tăng khoảng trống cho vùng touch
  final EdgeInsets touchAreaPadding;
  final double minTouchWidth;
  final double minTouchHeight;

  // Shadow customization options
  final bool showSelectedShadow;
  final bool showUnselectedShadow;
  final double selectedShadowSpreadRadius;
  final double unselectedShadowSpreadRadius;
  final Offset selectedShadowOffset;
  final Offset unselectedShadowOffset;
  final Color selectedShadowColor;
  final Color unselectedShadowColor;

  // Indicator bar customization
  final Color indicatorColor;
  final Color underlineColor;
  final double underlineHeight;
  final bool fitIndicatorToText;

  // Scrollable options
  final bool isScrollable;
  final ScrollPhysics? scrollPhysics;
  final bool scrollToSelectedTab;
  final Duration scrollAnimationDuration;
  final Curve scrollAnimationCurve;

  const TabLabelWidget({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.indicatorHeight = 2.0,
    this.paddingTabel,
    this.spaceBetweenLabelAndIndicator = true, // Mặc định có khoảng cách
    this.gapSize = 4.0, // Khoảng cách mặc định là 4.0 pixels
    // Vùng tăng thêm cho touch area
    this.touchAreaPadding = const EdgeInsets.symmetric(
      horizontal: 8.0, // Mở rộng 8px cho mỗi bên trái và phải
      vertical: 4.0, // Mở rộng 4px cho mỗi bên trên và dưới
    ),
    this.minTouchWidth = 48.0,
    this.minTouchHeight = 48.0,

    // Shadow options with default values
    this.showSelectedShadow = true,
    this.showUnselectedShadow = false,
    this.selectedShadowSpreadRadius = 1.0,
    this.unselectedShadowSpreadRadius = 0.5,
    this.selectedShadowOffset = const Offset(0, 0),
    this.unselectedShadowOffset = const Offset(0, 0),
    this.selectedShadowColor = const Color.fromRGBO(0, 0, 0, 0.1),
    this.unselectedShadowColor = const Color.fromRGBO(0, 0, 0, 0.05),

    // Indicator bar options
    this.indicatorColor = Colors.black,
    this.underlineColor = Colors.transparent,
    this.underlineHeight = 2.0,
    this.fitIndicatorToText = true,

    // Scrollable options
    this.isScrollable = false,
    this.scrollPhysics,
    this.scrollToSelectedTab = true,
    this.scrollAnimationDuration = const Duration(milliseconds: 300),
    this.scrollAnimationCurve = Curves.easeInOut,
  });

  @override
  State<TabLabelWidget> createState() => _TabLabelWidgetState();
}

class _TabLabelWidgetState extends State<TabLabelWidget>
    with SingleTickerProviderStateMixin {
  late final ScrollController scrollController;
  final List<GlobalKey> textKeys = [];
  late AnimationController _indicatorAnimController;
  bool _hasInitialScrolled = false;
  bool _isLayoutComplete = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _indicatorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _initTextKeys();

    // Thêm listener cho scrollController để biết khi nó có clients
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _attemptScrollToSelectedTab();
      }
    });
  }

  @override
  void didUpdateWidget(TabLabelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Khởi tạo lại textKeys nếu số lượng labels thay đổi
    if (oldWidget.labels.length != widget.labels.length) {
      _initTextKeys();
      _isLayoutComplete = false;
    }

    // Tự động cuộn đến tab được chọn nếu selectedIndex thay đổi
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        widget.isScrollable &&
        widget.scrollToSelectedTab) {
      _indicatorAnimController.forward(from: 0.0);

      if (scrollController.hasClients) {
        _scrollToSelectedTab();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _attemptScrollToSelectedTab();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _indicatorAnimController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _initTextKeys() {
    textKeys.clear();
    for (int i = 0; i < widget.labels.length; i++) {
      textKeys.add(GlobalKey());
    }
  }

  // Hàm mới để đảm bảo chúng ta kiểm tra layout đã hoàn thành
  void _attemptScrollToSelectedTab() {
    if (!_isLayoutComplete) {
      // Đợi một frame để layout hoàn thành
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _isLayoutComplete = true;

          // Đảm bảo ScrollController đã sẵn sàng
          if (widget.isScrollable &&
              widget.scrollToSelectedTab &&
              scrollController.hasClients &&
              !_hasInitialScrolled) {
            _scrollToSelectedTab();
            _hasInitialScrolled = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đợi một frame để kiểm tra nếu có thể cuộn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.isScrollable &&
          widget.scrollToSelectedTab &&
          scrollController.hasClients &&
          !_hasInitialScrolled) {
        _scrollToSelectedTab();
        _hasInitialScrolled = true;
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(),
        // Chỉ hiển thị khoảng cách nếu spaceBetweenLabelAndIndicator = true
        // if (widget.spaceBetweenLabelAndIndicator)
        //   SizedBox(height: widget.gapSize),
        // _buildIndicator(),
      ],
    );
  }

  Widget _buildTabBar() {
    // Tạo danh sách các tab
    final List<Widget> tabItems = List.generate(widget.labels.length, (index) {
      final isSelected = index == widget.selectedIndex;

      Widget textWidget = Text(
        widget.labels[index],
        key: textKeys[index],
        textAlign: TextAlign.center,
        style:
            isSelected
                ? (widget.selectedTextStyle ??
                    TextStyle(
                      color: widget.selectedColor,
                      fontWeight: FontWeight.bold,
                    ))
                : (widget.unselectedTextStyle ??
                    TextStyle(color: widget.unselectedColor)),
      );

      if ((isSelected && widget.showSelectedShadow) ||
          (!isSelected && widget.showUnselectedShadow)) {
        textWidget = ShadowWidget(
          spreadRadius:
              isSelected
                  ? widget.selectedShadowSpreadRadius
                  : widget.unselectedShadowSpreadRadius,
          shadowOffset:
              isSelected
                  ? widget.selectedShadowOffset
                  : widget.unselectedShadowOffset,
          shadowColor:
              isSelected
                  ? widget.selectedShadowColor
                  : widget.unselectedShadowColor,
          child: textWidget,
        );
      }

      // Tạo widget cho text với padding từ touchAreaPadding
      final textWithInnerPadding = Container(
        padding:
            widget.paddingTabel ??
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom:
                widget.selectedIndex == index
                    ? BorderSide(
                      color: widget.indicatorColor,
                      width: widget.indicatorHeight,
                    )
                    : BorderSide.none,
          ),
        ),
        alignment: Alignment.center,
        child: textWidget,
      );

      // Bao bên ngoài textWidget bằng một GestureDetector với vùng touch rộng hơn
      return GestureDetector(
        onTap: () {
          if (index != widget.selectedIndex) {
            widget.onTap(index);
            _indicatorAnimController.forward(from: 0.0);
          }
        },
        // Sử dụng thêm padding bên ngoài để mở rộng vùng touch
        child: Container(
          padding: widget.touchAreaPadding,
          constraints: BoxConstraints(
            minWidth: widget.minTouchWidth,
            minHeight: widget.minTouchHeight,
          ),
          // Dùng color: Colors.transparent để vùng touch được mở rộng nhưng không nhìn thấy
          color: Colors.transparent,
          child: textWithInnerPadding,
        ),
      );
    });

    // Luôn sử dụng SingleChildScrollView với NeverScrollableScrollPhysics khi không cần cuộn
    // Nhưng vẫn giữ ScrollController để có thể tự động cuộn khi chọn tab
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics:
          widget.isScrollable
              ? (widget.scrollPhysics ?? const BouncingScrollPhysics())
              : const NeverScrollableScrollPhysics(), // Không cho phép cuộn thủ công khi isScrollable = false
      child: Row(
        mainAxisAlignment:
            widget.isScrollable
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceAround,
        children: tabItems,
      ),
    );
  }

  // Hàm tính toán vị trí tuyệt đối của tab (không phụ thuộc vào scroll offset)
  double _calculateAbsoluteTabPosition(int index) {
    double position = 0.0;

    // Tính tổng chiều rộng của các tab trước tab được chọn
    for (int i = 0; i < index; i++) {
      position += _calculateTabWidth(i);
    }

    // Nếu cần căn giữa indicator với văn bản
    if (widget.fitIndicatorToText) {
      final tabWidth = _calculateTabWidth(index);
      final textWidth = _getTextWidth(index);
      position += (tabWidth - textWidth) / 2;
    }

    return position;
  }

  // Hàm tính toán chiều rộng của một tab
  double _calculateTabWidth(int index) {
    final RenderBox? renderBox =
        textKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      // Tính tổng chiều rộng bao gồm padding và touch area
      final double textWidth = renderBox.size.width;
      final double paddingHorizontal =
          (widget.paddingTabel?.horizontal ?? 32.0) +
          (widget.touchAreaPadding.horizontal);
      return textWidth + paddingHorizontal;
    }
    // Nếu không thể đo được, sử dụng giá trị mặc định
    return widget.minTouchWidth + widget.touchAreaPadding.horizontal;
  }

  // Hàm lấy chiều rộng của text
  double _getTextWidth(int index) {
    final RenderBox? renderBox =
        textKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size.width;
    }
    return 0.0;
  }

  // Hàm cuộn đến tab được chọn
  void _scrollToSelectedTab() {
    // Đảm bảo rằng ScrollController đã sẵn sàng
    if (!scrollController.hasClients) return;

    // Đảm bảo rằng render đã hoàn thành
    final RenderBox? renderBox =
        textKeys[widget.selectedIndex].currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Nếu render chưa hoàn thành, đặt lịch lại
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToSelectedTab();
        }
      });
      return;
    }

    // Tính vị trí tuyệt đối của tab được chọn
    double tabPosition = _calculateAbsoluteTabPosition(widget.selectedIndex);
    double tabWidth =
        widget.fitIndicatorToText
            ? _getTextWidth(widget.selectedIndex)
            : _calculateTabWidth(widget.selectedIndex);

    // Tính toán vị trí cuộn để tab được chọn hiển thị ở giữa màn hình
    double screenWidth = scrollController.position.viewportDimension;
    double scrollOffset = tabPosition - (screenWidth - tabWidth) / 2;

    // Đảm bảo không vượt quá giới hạn
    final double maxScrollExtent = scrollController.position.maxScrollExtent;
    scrollOffset = scrollOffset.clamp(0.0, maxScrollExtent);

    // Cuộn đến vị trí
    scrollController.jumpTo(scrollOffset);
    _hasInitialScrolled = true;
  }
}
