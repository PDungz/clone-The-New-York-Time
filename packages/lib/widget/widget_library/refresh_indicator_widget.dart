library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Thêm package này cho SVG

// Constants từ code gốc
const double _kDragContainerExtentPercentage = 0.25;
const double _kDragSizeFactorLimit = 1.5;
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

typedef RefreshCallback = Future<void> Function();

enum RefreshIndicatorStatus { drag, armed, snap, refresh, done, canceled }

enum RefreshIndicatorTriggerMode { anywhere, onEdge }

// ignore: unused_field
enum _IndicatorType { material, adaptive, noSpinner, customIcon, customWidget }

/// Custom RefreshIndicator với khả năng sử dụng Widget tùy chỉnh
class RefreshIndicatorWidget extends StatefulWidget {
  /// Constructor mặc định với Material spinner
  const RefreshIndicatorWidget({
    super.key,
    required this.child,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
  }) : _indicatorType = _IndicatorType.material,
       onStatusChange = null,
       customIcon = null,
       svgAsset = null,
       customWidget = null,
       iconSize = 24.0,
       animateIcon = true,
       assert(elevation >= 0.0);

  /// Constructor với icon tùy chỉnh
  const RefreshIndicatorWidget.withIcon({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.customIcon,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
    this.iconSize = 24.0,
    this.animateIcon = true,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.customIcon,
       strokeWidth = 0.0,
       svgAsset = null,
       customWidget = null,
       assert(elevation >= 0.0);

  /// Constructor với SVG tùy chỉnh
  const RefreshIndicatorWidget.withSvg({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.svgAsset,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
    this.iconSize = 24.0,
    this.animateIcon = true,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.customIcon,
       strokeWidth = 0.0,
       customIcon = null,
       customWidget = null,
       assert(elevation >= 0.0);

  /// Constructor với Widget tùy chỉnh
  const RefreshIndicatorWidget.withWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.customWidget,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
    this.animateIcon = true,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.customWidget,
       strokeWidth = 0.0,
       customIcon = null,
       svgAsset = null,
       iconSize = 24.0,
       assert(elevation >= 0.0);

  final Widget child;
  final double displacement;
  final double edgeOffset;
  final RefreshCallback onRefresh;
  final ValueChanged<RefreshIndicatorStatus?>? onStatusChange;
  final Color? color;
  final Color? backgroundColor;
  final ScrollNotificationPredicate notificationPredicate;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double strokeWidth;
  final RefreshIndicatorTriggerMode triggerMode;
  final double elevation;
  final _IndicatorType _indicatorType;

  // Thuộc tính cho custom icon
  final IconData? customIcon;
  final String? svgAsset;
  final double iconSize;
  final bool animateIcon;

  // Thuộc tính mới cho custom widget
  final Widget? customWidget;

  @override
  RefreshIndicatorWidgetState createState() => RefreshIndicatorWidgetState();
}

class RefreshIndicatorWidgetState extends State<RefreshIndicatorWidget>
    with TickerProviderStateMixin<RefreshIndicatorWidget> {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _rotationController; // Thêm controller cho rotation
  late Animation<double> _positionFactor;
  late Animation<double> _scaleFactor;
  late Animation<double> _value;
  late Animation<Color?> _valueColor;
  late Animation<double> _rotationAnimation; // Animation cho rotation

  RefreshIndicatorStatus? _status;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;
  late Color _effectiveValueColor =
      widget.color ?? Theme.of(context).colorScheme.primary;

  static final Animatable<double> _threeQuarterTween = Tween<double>(
    begin: 0.0,
    end: 0.75,
  );

  static final Animatable<double> _kDragSizeFactorLimitTween = Tween<double>(
    begin: 0.0,
    end: _kDragSizeFactorLimit,
  );

  static final Animatable<double> _oneToZeroTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _value = _positionController.drive(_threeQuarterTween);

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);

    // Khởi tạo rotation controller cho custom icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }

  @override
  void didChangeDependencies() {
    _setupColorTween();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant RefreshIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _setupColorTween();
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _setupColorTween() {
    _effectiveValueColor =
        widget.color ?? Theme.of(context).colorScheme.primary;
    final Color color = _effectiveValueColor;
    if (color.alpha == 0x00) {
      _valueColor = AlwaysStoppedAnimation<Color>(color);
    } else {
      _valueColor = _positionController.drive(
        ColorTween(
          begin: color.withAlpha(0),
          end: color.withAlpha(color.alpha),
        ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit)),
        ),
      );
    }
  }

  bool _shouldStart(ScrollNotification notification) {
    return ((notification is ScrollStartNotification &&
                notification.dragDetails != null) ||
            (notification is ScrollUpdateNotification &&
                notification.dragDetails != null &&
                widget.triggerMode == RefreshIndicatorTriggerMode.anywhere)) &&
        ((notification.metrics.axisDirection == AxisDirection.up &&
                notification.metrics.extentAfter == 0.0) ||
            (notification.metrics.axisDirection == AxisDirection.down &&
                notification.metrics.extentBefore == 0.0)) &&
        _status == null &&
        _start(notification.metrics.axisDirection);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }
    if (_shouldStart(notification)) {
      setState(() {
        _status = RefreshIndicatorStatus.drag;
        widget.onStatusChange?.call(_status);
      });
      return false;
    }
    final bool? indicatorAtTopNow = switch (notification
        .metrics
        .axisDirection) {
      AxisDirection.down || AxisDirection.up => true,
      AxisDirection.left || AxisDirection.right => null,
    };
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_status == RefreshIndicatorStatus.drag ||
          _status == RefreshIndicatorStatus.armed) {
        _dismiss(RefreshIndicatorStatus.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_status == RefreshIndicatorStatus.drag ||
          _status == RefreshIndicatorStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.scrollDelta!;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.scrollDelta!;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
      if (_status == RefreshIndicatorStatus.armed &&
          notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_status == RefreshIndicatorStatus.drag ||
          _status == RefreshIndicatorStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.overscroll;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.overscroll;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_status) {
        case RefreshIndicatorStatus.armed:
          if (_positionController.value < 1.0) {
            _dismiss(RefreshIndicatorStatus.canceled);
          } else {
            _show();
          }
        case RefreshIndicatorStatus.drag:
          _dismiss(RefreshIndicatorStatus.canceled);
        case RefreshIndicatorStatus.canceled:
        case RefreshIndicatorStatus.done:
        case RefreshIndicatorStatus.refresh:
        case RefreshIndicatorStatus.snap:
        case null:
          break;
      }
    }
    return false;
  }

  bool _handleIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0 || !notification.leading) {
      return false;
    }
    if (_status == RefreshIndicatorStatus.drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_status == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
      case AxisDirection.up:
        _isIndicatorAtTop = true;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(
      _status == RefreshIndicatorStatus.drag ||
          _status == RefreshIndicatorStatus.armed,
    );
    double newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_status == RefreshIndicatorStatus.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _positionController.value = clampDouble(newValue, 0.0, 1.0);

    if (_status == RefreshIndicatorStatus.drag &&
        _valueColor.value!.alpha == _effectiveValueColor.alpha) {
      _status = RefreshIndicatorStatus.armed;
      widget.onStatusChange?.call(_status);
    }
  }

  Future<void> _dismiss(RefreshIndicatorStatus newMode) async {
    await Future<void>.value();
    assert(
      newMode == RefreshIndicatorStatus.canceled ||
          newMode == RefreshIndicatorStatus.done,
    );

    // Dừng animation xoay khi dismiss
    if ((widget._indicatorType == _IndicatorType.customIcon ||
            widget._indicatorType == _IndicatorType.customWidget) &&
        widget.animateIcon) {
      _rotationController.stop();
    }

    setState(() {
      _status = newMode;
      widget.onStatusChange?.call(_status);
    });
    switch (_status!) {
      case RefreshIndicatorStatus.done:
        await _scaleController.animateTo(
          1.0,
          duration: _kIndicatorScaleDuration,
        );
      case RefreshIndicatorStatus.canceled:
        await _positionController.animateTo(
          0.0,
          duration: _kIndicatorScaleDuration,
        );
      case RefreshIndicatorStatus.armed:
      case RefreshIndicatorStatus.drag:
      case RefreshIndicatorStatus.refresh:
      case RefreshIndicatorStatus.snap:
        assert(false);
    }
    if (mounted && _status == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _status = null;
      });
    }
  }

  void _show() {
    assert(_status != RefreshIndicatorStatus.refresh);
    assert(_status != RefreshIndicatorStatus.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _status = RefreshIndicatorStatus.snap;
    widget.onStatusChange?.call(_status);

    // Bắt đầu animation xoay cho custom icon/widget khi refresh
    if ((widget._indicatorType == _IndicatorType.customIcon ||
            widget._indicatorType == _IndicatorType.customWidget) &&
        widget.animateIcon) {
      _rotationController.repeat();
    }

    _positionController
        .animateTo(
          1.0 / _kDragSizeFactorLimit,
          duration: _kIndicatorSnapDuration,
        )
        .then<void>((void value) {
          if (mounted && _status == RefreshIndicatorStatus.snap) {
            setState(() {
              _status = RefreshIndicatorStatus.refresh;
            });

            final Future<void> refreshResult = widget.onRefresh();
            refreshResult.whenComplete(() {
              if (mounted && _status == RefreshIndicatorStatus.refresh) {
                completer.complete();
                _dismiss(RefreshIndicatorStatus.done);
              }
            });
          }
        });
  }

  Future<void> show({bool atTop = true}) {
    if (_status != RefreshIndicatorStatus.refresh &&
        _status != RefreshIndicatorStatus.snap) {
      if (_status == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  Widget _buildCustomIndicator() {
    final bool showIndeterminateIndicator =
        _status == RefreshIndicatorStatus.refresh ||
        _status == RefreshIndicatorStatus.done;

    // Xây dựng custom widget, icon hoặc SVG
    Widget indicatorWidget;

    if (widget._indicatorType == _IndicatorType.customWidget &&
        widget.customWidget != null) {
      // Sử dụng Custom Widget
      indicatorWidget = widget.customWidget!;
    } else if (widget.svgAsset != null) {
      // Sử dụng SVG
      indicatorWidget = SvgPicture.asset(
        widget.svgAsset!,
        width: widget.iconSize,
        height: widget.iconSize,
        colorFilter:
            widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
      );
    } else if (widget.customIcon != null) {
      // Sử dụng Icon
      indicatorWidget = Icon(
        widget.customIcon!,
        size: widget.iconSize,
        color: widget.color ?? _effectiveValueColor,
      );
    } else {
      // Fallback về Material indicator
      return RefreshProgressIndicator(
        semanticsLabel:
            widget.semanticsLabel ??
            MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
        semanticsValue: widget.semanticsValue,
        value: showIndeterminateIndicator ? null : _value.value,
        valueColor: _valueColor,
        backgroundColor: widget.backgroundColor,
        strokeWidth: widget.strokeWidth,
        elevation: widget.elevation,
      );
    }

    // Wrap với animation nếu cần (chỉ áp dụng cho icon và SVG, không áp dụng cho custom widget)
    if (widget.animateIcon &&
        showIndeterminateIndicator &&
        widget._indicatorType != _IndicatorType.customWidget) {
      indicatorWidget = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: indicatorWidget,
          );
        },
      );
    }

    // Thêm background circle nếu có backgroundColor (chỉ cho icon và SVG)
    if (widget.backgroundColor != null &&
        widget._indicatorType != _IndicatorType.customWidget) {
      indicatorWidget = Container(
        width: widget.iconSize + 16,
        height: widget.iconSize + 16,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
          boxShadow:
              widget.elevation > 0
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ]
                  : null,
        ),
        child: Center(child: indicatorWidget),
      );
    }

    return indicatorWidget;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );

    return Stack(
      children: <Widget>[
        child,
        if (_status != null)
          Positioned(
            top: _isIndicatorAtTop! ? widget.edgeOffset : null,
            bottom: !_isIndicatorAtTop! ? widget.edgeOffset : null,
            left: 0.0,
            right: 0.0,
            child: SizeTransition(
              axisAlignment: _isIndicatorAtTop! ? 1.0 : -1.0,
              sizeFactor: _positionFactor,
              child: Padding(
                padding:
                    _isIndicatorAtTop!
                        ? EdgeInsets.only(top: widget.displacement)
                        : EdgeInsets.only(bottom: widget.displacement),
                child: Align(
                  alignment:
                      _isIndicatorAtTop!
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: _scaleFactor,
                    child: AnimatedBuilder(
                      animation: _positionController,
                      builder: (BuildContext context, Widget? child) {
                        if (widget._indicatorType ==
                                _IndicatorType.customIcon ||
                            widget._indicatorType ==
                                _IndicatorType.customWidget) {
                          return _buildCustomIndicator();
                        }

                        // Material indicator mặc định
                        return RefreshProgressIndicator(
                          semanticsLabel:
                              widget.semanticsLabel ??
                              MaterialLocalizations.of(
                                context,
                              ).refreshIndicatorSemanticLabel,
                          semanticsValue: widget.semanticsValue,
                          value:
                              (_status == RefreshIndicatorStatus.refresh ||
                                      _status == RefreshIndicatorStatus.done)
                                  ? null
                                  : _value.value,
                          valueColor: _valueColor,
                          backgroundColor: widget.backgroundColor,
                          strokeWidth: widget.strokeWidth,
                          elevation: widget.elevation,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
