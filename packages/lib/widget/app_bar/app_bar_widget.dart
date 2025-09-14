import 'dart:ui';

import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final Color backgroundColor;
  final BoxShadow? boxShadow;
  final Brightness? brightness;
  final bool overlayColor;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double paddingBottom;

  const AppBarWidget({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.bottom,
    this.elevation = 4.0,
    this.backgroundColor = Colors.grey,
    this.brightness,
    this.boxShadow,
    this.overlayColor = false,
    this.paddingTop = 8,
    this.paddingLeft = 16,
    this.paddingRight = 16,
    this.paddingBottom = 12,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    
    return overlayColor
        ? Stack(
          children: [
            // Background layer với blur effect
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: statusBarHeight + paddingTop + paddingBottom + 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.1,
                    ), // Luôn có một layer sáng mỏng
                    boxShadow: boxShadow != null ? [boxShadow!] : null,
                  ),
                ),
              ),
            ),
            // Overlay layer với background color
            Container(
              height: statusBarHeight + paddingTop + paddingBottom + 56,
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.7),
                boxShadow: boxShadow != null ? [boxShadow!] : null,
              ),
            ),
            // Content layer
            _AppBarBody(
              backgroundColor: Colors.transparent,
              boxShadow: null,
              statusBarHeight: statusBarHeight,
              leading: leading,
              title: title,
              actions: actions,
              bottom: bottom,
              paddingTop: paddingTop,
              paddingLeft: paddingLeft,
              paddingRight: paddingRight,
              paddingBottom: paddingBottom,
            ),
          ],
        )
        : _AppBarBody(
          backgroundColor: backgroundColor,
          boxShadow: boxShadow,
          statusBarHeight: statusBarHeight,
          leading: leading,
          title: title,
          actions: actions,
          bottom: bottom,
          paddingTop: paddingTop,
          paddingLeft: paddingLeft,
          paddingRight: paddingRight,
          paddingBottom: paddingBottom,
        );
  }
}

class _AppBarBody extends StatelessWidget {
  const _AppBarBody({
    required this.backgroundColor,
    required this.boxShadow,
    required this.statusBarHeight,
    required this.leading,
    required this.title,
    required this.actions,
    required this.bottom,
    required this.paddingTop,
    required this.paddingLeft,
    required this.paddingRight,
    required this.paddingBottom,
  });

  final Color backgroundColor;
  final BoxShadow? boxShadow;
  final double statusBarHeight;
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    final hasLeading = leading != null;
    final hasActions = actions != null && actions!.isNotEmpty;
    Widget leadingWidget = hasLeading ? leading! : const SizedBox(width: 0);

    Widget actionsWidget =
        hasActions
            ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
            : const SizedBox(width: 0);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: boxShadow != null ? [boxShadow!] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + paddingTop,
              left: paddingLeft,
              right: paddingRight,
              bottom: paddingBottom,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (title != null) Center(child: title!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [leadingWidget, actionsWidget],
                ),
              ],
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
