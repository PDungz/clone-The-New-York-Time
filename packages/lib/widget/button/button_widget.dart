import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ButtonSizeMode {
  fixed, // Kích thước cố định (sử dụng width/height)
  fitContent, // Điều chỉnh theo nội dung
  minimumSize, // Sử dụng minimumSize của Flutter
}

class ButtonWidget extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final String? svgPathIcon;
  final Widget? widgetIcon;
  final double borderRadius;
  final double elevation;
  final bool isOutlined;
  final BorderSide? border;
  final TextStyle? textStyle;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? overlayColor;
  final bool useMinSize;
  final double? width;
  final double? height;

  // Thêm các tham số mới cho auto-sizing
  final ButtonSizeMode sizeMode;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final MainAxisSize mainAxisSize;

  // Thêm các tham số cho hiệu ứng ấn giữ
  final bool enablePressEffect; // Bật/tắt hiệu ứng khi ấn
  final bool enableSplashEffect; // Bật/tắt splash effect
  final Color? pressedColor; // Màu khi được ấn
  final Color? pressedTextColor; // Màu text khi được ấn
  final Color? splashColor; // Màu splash effect
  final Color? highlightColor; // Màu highlight effect
  final double pressedOpacity; // Độ trong suốt khi ấn (0.0 - 1.0)
  final double pressedScale; // Scale khi ấn (0.0 - 1.0)
  final Duration pressAnimationDuration; // Thời gian animation
  final Curve pressAnimationCurve; // Curve animation

  const ButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.svgPathIcon,
    this.widgetIcon,
    this.borderRadius = 8.0,
    this.elevation = 0.0,
    this.isOutlined = false,
    this.border,
    this.textStyle,
    this.iconSize = 24.0,
    this.iconColor,
    this.padding,
    this.backgroundColor,
    this.overlayColor = Colors.white,
    this.useMinSize = true,
    this.width,
    this.height,

    // Các tham số mới
    this.sizeMode = ButtonSizeMode.fixed,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.mainAxisSize = MainAxisSize.min,

    // Hiệu ứng ấn giữ
    this.enablePressEffect = true,
    this.enableSplashEffect = true,
    this.pressedColor,
    this.pressedTextColor,
    this.splashColor,
    this.highlightColor,
    this.pressedOpacity = 0.8,
    this.pressedScale = 0.95,
    this.pressAnimationDuration = const Duration(milliseconds: 150),
    this.pressAnimationCurve = Curves.easeInOut,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pressAnimationController = AnimationController(
      duration: widget.pressAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _pressAnimationController,
        curve: widget.pressAnimationCurve,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(
      CurvedAnimation(
        parent: _pressAnimationController,
        curve: widget.pressAnimationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enablePressEffect && !widget.isLoading && !widget.isDisabled) {
      setState(() {
        _isPressed = true;
      });
      _pressAnimationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enablePressEffect) {
      setState(() {
        _isPressed = false;
      });
      _pressAnimationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enablePressEffect) {
      setState(() {
        _isPressed = false;
      });
      _pressAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = widget.border?.color ?? theme.primaryColor;

    // Điều chỉnh màu dựa trên trạng thái pressed
    final currentBackgroundColor = _getCurrentBackgroundColor(theme);
    final currentTextColor = _getCurrentTextColor(borderColor);

    final buttonTextStyle =
        widget.textStyle ??
        theme.textTheme.labelLarge?.copyWith(color: currentTextColor);

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize:
          widget.sizeMode == ButtonSizeMode.fitContent
              ? widget.mainAxisSize
              : MainAxisSize.max,
      children: [
        if (widget.isLoading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        if (_shouldShowIcon() && !widget.isLoading)
          _buildIcon(currentTextColor),
        if (_shouldShowIcon() && !widget.isLoading) const SizedBox(width: 8),
        if (!widget.isLoading)
          Text(
            widget.label,
            style: buttonTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    Widget button = ElevatedButton(
      onPressed:
          widget.isLoading || widget.isDisabled ? null : widget.onPressed,
      style: _buildButtonStyle(theme, currentBackgroundColor),
      child: buttonChild,
    );

    // Wrap với gesture detector để handle press effects
    Widget gestureButton = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: button,
    );

    // Wrap với animation nếu press effect được bật
    if (widget.enablePressEffect) {
      gestureButton = AnimatedBuilder(
        animation: _pressAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _opacityAnimation.value, child: child),
          );
        },
        child: gestureButton,
      );
    }

    return _wrapWithSizeConstraints(gestureButton);
  }

  // Lấy màu background hiện tại dựa trên trạng thái
  Color _getCurrentBackgroundColor(ThemeData theme) {
    // Nếu là outline và được ấn, vẫn có thể có màu nền
    if (widget.isOutlined) {
      if (_isPressed && widget.pressedColor != null) {
        return widget.pressedColor!;
      }
      return Colors.transparent;
    }

    // Button thường
    if (_isPressed && widget.pressedColor != null) {
      return widget.pressedColor!;
    }

    return widget.backgroundColor ?? theme.primaryColor;
  }

  // Lấy màu text hiện tại dựa trên trạng thái
  Color _getCurrentTextColor(Color borderColor) {
    // Ưu tiên màu text khi ấn
    if (_isPressed && widget.pressedTextColor != null) {
      return widget.pressedTextColor!;
    }

    // Màu text mặc định
    if (widget.isOutlined) {
      return borderColor;
    }

    return Colors.white;
  }

  // Build button style với WidgetStateProperty
  ButtonStyle _buildButtonStyle(ThemeData theme, Color backgroundColor) {
    return ButtonStyle(
      elevation: WidgetStateProperty.all(
        widget.isOutlined ? 0 : widget.elevation,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side:
              widget.isOutlined
                  ? (widget.border ??
                      BorderSide(color: theme.primaryColor, width: 1.2))
                  : BorderSide.none,
        ),
      ),
      padding: WidgetStateProperty.all(
        widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      minimumSize: WidgetStateProperty.all(_getMinimumSize()),
      maximumSize: WidgetStateProperty.all(_getMaximumSize()),

      // Sử dụng WidgetStateProperty để handle background color động
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (_isPressed && widget.pressedColor != null) {
          return widget.pressedColor!;
        }
        if (widget.isOutlined) {
          return Colors.transparent;
        }
        return widget.backgroundColor ?? theme.primaryColor;
      }),

      foregroundColor: WidgetStateProperty.all(widget.overlayColor),

      // Cấu hình splash effects
      splashFactory:
          widget.enableSplashEffect
              ? InkRipple.splashFactory
              : NoSplash.splashFactory,

      overlayColor:
          widget.enableSplashEffect
              ? WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return widget.splashColor ??
                      widget.overlayColor?.withValues(alpha: 0.1) ??
                      Colors.white.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return widget.highlightColor ??
                      widget.overlayColor?.withValues(alpha: 0.05) ??
                      Colors.white.withValues(alpha: 0.05);
                }
                return null;
              })
              : WidgetStateProperty.all(Colors.transparent),

      animationDuration: widget.pressAnimationDuration,
    );
  }

  // Kiểm tra có nên hiển thị icon không
  bool _shouldShowIcon() {
    return widget.widgetIcon != null || widget.svgPathIcon != null;
  }

  // Build icon widget dựa trên priority: widgetIcon > svgPathIcon
  Widget _buildIcon(Color textColor) {
    if (widget.widgetIcon != null) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: widget.widgetIcon!,
      );
    } else if (widget.svgPathIcon != null) {
      return SvgPicture.asset(
        widget.svgPathIcon!,
        height: widget.iconSize,
        width: widget.iconSize,
        colorFilter: ColorFilter.mode(
          widget.iconColor ?? textColor,
          BlendMode.srcIn,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Size _getMinimumSize() {
    switch (widget.sizeMode) {
      case ButtonSizeMode.fixed:
        return widget.useMinSize
            ? Size(widget.width ?? 64, widget.height ?? 36)
            : Size.zero;
      case ButtonSizeMode.fitContent:
        return Size(widget.minWidth ?? 0, widget.minHeight ?? 36);
      case ButtonSizeMode.minimumSize:
        return Size(widget.minWidth ?? 64, widget.minHeight ?? 36);
    }
  }

  Size _getMaximumSize() {
    switch (widget.sizeMode) {
      case ButtonSizeMode.fixed:
        return Size(
          widget.width ?? double.infinity,
          widget.height ?? double.infinity,
        );
      case ButtonSizeMode.fitContent:
        return Size(
          widget.maxWidth ?? double.infinity,
          widget.maxHeight ?? double.infinity,
        );
      case ButtonSizeMode.minimumSize:
        return Size(
          widget.maxWidth ?? double.infinity,
          widget.maxHeight ?? double.infinity,
        );
    }
  }

  Widget _wrapWithSizeConstraints(Widget button) {
    switch (widget.sizeMode) {
      case ButtonSizeMode.fixed:
        if (widget.width != null || widget.height != null) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: button,
          );
        }
        return button;

      case ButtonSizeMode.fitContent:
        return IntrinsicWidth(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minWidth ?? 0,
              minHeight: widget.minHeight ?? 0,
              maxWidth: widget.maxWidth ?? double.infinity,
              maxHeight: widget.maxHeight ?? double.infinity,
            ),
            child: button,
          ),
        );

      case ButtonSizeMode.minimumSize:
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minWidth ?? 64,
            minHeight: widget.minHeight ?? 36,
            maxWidth: widget.maxWidth ?? double.infinity,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          child: button,
        );
    }
  }
}
