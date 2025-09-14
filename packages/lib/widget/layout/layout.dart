import 'package:flutter/material.dart';

class LayoutWidget extends StatefulWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? background;
  final Widget? bottomSheet;
  final Color loadingOverlayColor;
  final bool isLoadingOverlay;
  final Widget? draggable;
  final EdgeInsets? bottomNavigationBarMargin;

  const LayoutWidget({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.background,
    this.bottomSheet,
    this.loadingOverlayColor = Colors.black,
    this.isLoadingOverlay = false,
    this.draggable,
    this.bottomNavigationBarMargin,
  });

  @override
  State<LayoutWidget> createState() => _LayoutWidgetState();
}

class _LayoutWidgetState extends State<LayoutWidget> {
  late Offset _startDragOffset = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.draggable != null) {
        setState(() {
          _startDragOffset = Offset(
            MediaQuery.of(context).size.width - 68,
            MediaQuery.of(context).size.height - 160,
          );
        });
      }
    });
  }

  double get _bottomNavigationBarHeight {
    if (widget.bottomNavigationBar == null) return 0;

    // Tính toán margin bottom navigation bar
    final margin = widget.bottomNavigationBarMargin ?? EdgeInsets.zero;
    return kBottomNavigationBarHeight + margin.top + margin.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: LayoutBuilder(
          builder:
              (context, constraints) => Stack(
                children: [
                  if (widget.background != null) Positioned.fill(child: widget.background!),

                  // Body với padding bottom để tránh bị che bởi bottomNavigationBar
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: widget.bottomNavigationBar != null ? _bottomNavigationBarHeight : 0,
                      ),
                      child: widget.appBar != null ? SafeArea(child: widget.body) : widget.body,
                    ),
                  ),

                  if (widget.appBar != null)
                    Positioned(top: 0, left: 0, right: 0, child: widget.appBar!),

                  if (widget.floatingActionButton != null)
                    Positioned(
                      bottom:
                          16 +
                          (widget.bottomNavigationBar != null ? _bottomNavigationBarHeight : 0),
                      right: 16,
                      child: widget.floatingActionButton!,
                    ),

                  if (widget.bottomNavigationBar != null)
                    Positioned(
                      bottom: widget.bottomNavigationBarMargin?.bottom ?? 0,
                      left: widget.bottomNavigationBarMargin?.left ?? 0,
                      right: widget.bottomNavigationBarMargin?.right ?? 0,
                      child: Container(
                        margin: EdgeInsets.only(top: widget.bottomNavigationBarMargin?.top ?? 0),
                        child: widget.bottomNavigationBar!,
                      ),
                    ),

                  if (widget.drawer != null)
                    Positioned(top: 0, left: 0, bottom: 0, child: widget.drawer!),

                  if (widget.bottomSheet != null)
                    Positioned(
                      bottom: widget.bottomNavigationBar != null ? _bottomNavigationBarHeight : 0,
                      left: 0,
                      right: 0,
                      child: widget.bottomSheet!,
                    ),

                  if (widget.draggable != null)
                    Positioned(
                      top: _startDragOffset.dy,
                      left: _startDragOffset.dx,
                      child: Draggable(
                        feedback: widget.draggable!,
                        onDragEnd:
                            (details) => setState(() {
                              final adjustmentHeight =
                                  AppBar().preferredSize.height +
                                  MediaQuery.of(context).padding.top;
                              final maxX = constraints.maxWidth - 68;
                              final maxY = constraints.maxHeight - 68 - _bottomNavigationBarHeight;
                              double dx = details.offset.dx.clamp(0, maxX);
                              double dy = (details.offset.dy - adjustmentHeight).clamp(0, maxY);
                              if (dx > MediaQuery.of(context).size.width - 100) {
                                dx = MediaQuery.of(context).size.width - 80;
                              }
                              _startDragOffset = Offset(dx, dy);
                            }),
                        child: widget.draggable!,
                      ),
                    ),

                  if (widget.isLoadingOverlay)
                    Positioned.fill(
                      child: Container(
                        color: widget.loadingOverlayColor.withAlpha((0.5 * 255).round()),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
