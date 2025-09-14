import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconButtonWidget extends StatefulWidget {
  final String? svgPath;
  final IconData? icon;
  final double size;
  final Color color;
  final Color? splashColor;
  final Color? highlightColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enableShadow;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const IconButtonWidget({
    super.key,
    this.svgPath,
    this.icon,
    this.size = 24.0,
    this.color = Colors.black,
    this.splashColor,
    this.highlightColor,
    this.padding = const EdgeInsets.all(8.0),
    this.onPressed,
    this.onLongPress,
    this.enableShadow = false,
    this.shadows,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : assert(
         svgPath != null || icon != null,
         'Either svgPath or icon must be provided',
       );

  @override
  State<IconButtonWidget> createState() => _IconButtonWidgetState();
}

class _IconButtonWidgetState extends State<IconButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BoxShadow> effectiveShadows =
        widget.enableShadow
            ? widget.shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ]
            : [];

    final BorderRadius effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(8.0);

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              boxShadow: effectiveShadows,
            ),
            child: InkWell(
              borderRadius: effectiveBorderRadius,
              splashColor: widget.splashColor,
              highlightColor: widget.highlightColor,
              child: Container(padding: widget.padding, child: _buildIcon()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.svgPath != null) {
      return SvgPicture.asset(
        widget.svgPath!,
        width: widget.size,
        height: widget.size,
        colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
      );
    } else {
      return Icon(widget.icon, size: widget.size, color: widget.color);
    }
  }
}
