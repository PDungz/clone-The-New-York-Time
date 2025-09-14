import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationItem {
  final String icon; // SVG asset path
  final String? label; // Optional label text

  const NavigationItem({required this.icon, this.label});
}

class BottomNavigationAppBarWidget extends StatefulWidget {
  const BottomNavigationAppBarWidget({
    super.key,
    this.padding,
    this.onNextPage,
    required this.navigationItems,
    this.showLabels = false,
    this.background, // Can be Color, Gradient or DecorationImage
    this.selectedIconColor = Colors.blue,
    this.unselectedIconColor = Colors.grey,
    this.labelStyle,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.initialSelectedIndex = 0,
    this.iconSize = 24.0,
    this.itemWidth,
    this.itemPadding,
    this.buttonEffect = ButtonEffect.noEffect,
    this.bottomPadding = 24.0,
    this.topPadding = 8.0,
    this.borderRadius,
    this.boxShadow,
    required this.buildContext,
  });

  final BuildContext buildContext;

  /// The list of navigation items (either as List<String> for SVG paths or List<NavigationItem>)
  final List<dynamic> navigationItems;

  /// Whether to show labels under the icons
  final bool showLabels;

  /// Text style for the labels
  final TextStyle? labelStyle;

  /// Color for selected label
  final Color? selectedLabelColor;

  /// Color for unselected label
  final Color? unselectedLabelColor;

  /// Width for each navigation item (optional)
  final double? itemWidth;

  /// Padding for each navigation button
  final EdgeInsets? itemPadding;

  /// Padding around the bottom navigation bar
  final EdgeInsets? padding;

  /// Border radius for the bottom navigation bar
  final BorderRadius? borderRadius;

  /// Box shadow for the bottom navigation bar
  final BoxShadow? boxShadow;

  /// Callback when a navigation item is tapped, passes the index of the selected item
  final Function(int index)? onNextPage;

  /// Background decoration - can be Color, Gradient or DecorationImage
  final dynamic background;

  /// Color of the selected icon
  final Color selectedIconColor;

  /// Color of unselected icons
  final Color unselectedIconColor;

  /// Index of the initially selected item
  final int initialSelectedIndex;

  /// Size of the navigation icons
  final double iconSize;

  /// Effect when button is pressed
  final ButtonEffect buttonEffect;

  /// Bottom padding of the navigation bar
  final double bottomPadding;

  /// Top padding of the navigation bar
  final double topPadding;

  @override
  State<BottomNavigationAppBarWidget> createState() =>
      _BottomNavigationAppBarWidgetState();
}

/// Enum for button effects
enum ButtonEffect { noEffect, ripple, scale, glow, customBackground }

class _BottomNavigationAppBarWidgetState
    extends State<BottomNavigationAppBarWidget>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  AnimationController? _animationController;
  List<Animation<double>>? _animations;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;

    if (widget.buttonEffect == ButtonEffect.scale) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      _animations = List.generate(
        widget.navigationItems.length,
        (index) => Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Call the onNextPage callback if provided
    if (widget.onNextPage != null) {
      widget.onNextPage!(index);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          boxShadow: [
            widget.boxShadow ??
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
          ],
          // Handle different background types
          color: widget.background is Color ? widget.background : null,
          gradient: widget.background is Gradient ? widget.background : null,
          image:
              widget.background is DecorationImage ? widget.background : null,
        ),
        padding:
            widget.padding ??
            EdgeInsets.only(
              top: widget.topPadding,
              bottom: widget.bottomPadding,
            ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildNavigationItems(),
        ),
      ),
    );
  }

  /// Process navigation items - handles both List<String> and List<NavigationItem>
  List<NavigationItem> _processNavItems() {
    if (widget.navigationItems.isEmpty) return [];

    if (widget.navigationItems[0] is String) {
      // Handle List<String> (SVG paths only)
      return (widget.navigationItems as List<String>)
          .map((path) => NavigationItem(icon: path))
          .toList();
    } else if (widget.navigationItems[0] is NavigationItem) {
      // Already in NavigationItem format
      return widget.navigationItems as List<NavigationItem>;
    } else {
      throw ArgumentError(
        'navigationItems must be List<String> or List<NavigationItem>',
      );
    }
  }

  /// Build navigation items
  List<Widget> _buildNavigationItems() {
    final items = _processNavItems();

    return List.generate(items.length, (index) {
      final bool isSelected = _selectedIndex == index;
      final item = items[index];

      Widget navButton = _buildNavigationButton(
        index: index,
        isSelected: isSelected,
        icon: item.icon,
        label: widget.showLabels ? item.label : null,
      );

      // Apply button width if specified
      if (widget.itemWidth != null) {
        navButton = SizedBox(width: widget.itemWidth, child: navButton);
      }

      return navButton;
    });
  }

  /// Build a single navigation button with icon and optional label
  Widget _buildNavigationButton({
    required int index,
    required bool isSelected,
    required String icon,
    String? label,
  }) {
    // Build the button content with icon and optional label
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            isSelected ? widget.selectedIconColor : widget.unselectedIconColor,
            BlendMode.srcIn,
          ),
          width: widget.iconSize,
          height: widget.iconSize,
        ),
        if (widget.showLabels && label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: (widget.labelStyle ?? const TextStyle()).copyWith(
              color:
                  isSelected
                      ? widget.selectedLabelColor ?? widget.selectedIconColor
                      : widget.unselectedLabelColor ??
                          widget.unselectedIconColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );

    // Apply different button effects
    final padding = widget.itemPadding ?? const EdgeInsets.all(12.0);

    switch (widget.buttonEffect) {
      case ButtonEffect.ripple:
        return Padding(
          padding:
              EdgeInsets.zero, // Outer padding is zero to maximize touch area
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.iconSize),
            splashColor: widget.selectedIconColor.withOpacity(0.2),
            highlightColor: widget.selectedIconColor.withOpacity(0.1),
            onTap: () => _onItemTapped(index),
            child: Padding(
              padding: padding, // Apply padding to the inner content
              child: content,
            ),
          ),
        );

      case ButtonEffect.scale:
        return Padding(
          padding:
              EdgeInsets.zero, // Outer padding is zero to maximize touch area
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Ensures the entire area is tappable
            onTapDown: (_) {
              _animationController?.forward();
            },
            onTapUp: (_) {
              _animationController?.reverse();
              _onItemTapped(index);
            },
            onTapCancel: () {
              _animationController?.reverse();
            },
            child: Padding(
              padding: padding, // Apply padding to the inner content
              child: ScaleTransition(
                scale: _animations![index],
                child: content,
              ),
            ),
          ),
        );

      case ButtonEffect.glow:
        return Padding(
          padding:
              EdgeInsets.zero, // Outer padding is zero to maximize touch area
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Ensures the entire area is tappable
            onTap: () => _onItemTapped(index),
            child: Padding(
              padding: padding, // Apply padding to the inner content
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration:
                    isSelected
                        ? BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.iconSize),
                          boxShadow: [
                            BoxShadow(
                              color: widget.selectedIconColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        )
                        : null,
                child: content,
              ),
            ),
          ),
        );

      case ButtonEffect.customBackground:
        return Padding(
          padding:
              EdgeInsets.zero, // Outer padding is zero to maximize touch area
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Ensures the entire area is tappable
            onTap: () => _onItemTapped(index),
            child: Padding(
              padding: padding, // Apply padding to the inner content
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? widget.selectedIconColor.withOpacity(0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(widget.iconSize),
                ),
                child: content,
              ),
            ),
          ),
        );

      case ButtonEffect.noEffect:
        return Padding(
          padding:
              EdgeInsets.zero, // Outer padding is zero to maximize touch area
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Ensures the entire area is tappable
            onTap: () => _onItemTapped(index),
            child: Padding(
              padding: padding, // Apply padding to the inner content
              child: content,
            ),
          ),
        );
    }
  }
}
