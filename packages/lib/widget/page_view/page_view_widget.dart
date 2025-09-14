import 'package:flutter/material.dart';

class PageViewWidget extends StatefulWidget {
  const PageViewWidget({
    super.key,
    required this.pages,
    this.controller,
    this.onPageChanged,
    this.showIndicator = true,
    this.initialPage = 0,
    this.scrollDirection = Axis.horizontal,
    this.physics,
  });

  final List<Widget> pages;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool showIndicator;
  final int initialPage;
  final Axis scrollDirection;
  final ScrollPhysics? physics;

  @override
  State<PageViewWidget> createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? PageController(initialPage: widget.initialPage);
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() => _currentPage = page);
        widget.onPageChanged?.call(page);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.pages.length,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics ?? const BouncingScrollPhysics(),
            itemBuilder: (context, index) => widget.pages[index],
          ),
        ),
      ],
    );
  }
}
