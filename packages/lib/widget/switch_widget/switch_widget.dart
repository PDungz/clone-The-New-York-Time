import 'package:flutter/material.dart';

class SwitchWidget extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;
  final double trackWidth;
  final double trackHeight;
  final double thumbSize;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;

  const SwitchWidget({super.key, this.initialValue = false, this.onChanged, this.activeColor = Colors.blue, this.inactiveColor = Colors.grey, this.activeThumbColor = Colors.white, this.inactiveThumbColor = Colors.black, this.trackWidth = 50.0, this.trackHeight = 28.0, this.thumbSize = 20.0, this.padding = const EdgeInsets.all(4.0), this.duration = const Duration(milliseconds: 200), this.curve = Curves.easeInOut});

  @override
  // ignore: library_private_types_in_public_api
  _SwitchWidgetState createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool isSwitched;
  double dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.initialValue;
    dragPosition = isSwitched ? widget.trackWidth - widget.thumbSize - widget.padding.horizontal : 0.0;
  }

  void _toggleSwitch() {
    setState(() {
      isSwitched = !isSwitched;
      dragPosition = isSwitched ? widget.trackWidth - widget.thumbSize - widget.padding.horizontal : 0.0;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(isSwitched);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragPosition += details.primaryDelta ?? 0;
      dragPosition = dragPosition.clamp(0.0, widget.trackWidth - widget.thumbSize - widget.padding.horizontal);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    bool newValue = dragPosition > (widget.trackWidth - widget.thumbSize - widget.padding.horizontal) / 2;
    setState(() {
      isSwitched = newValue;
      dragPosition = isSwitched ? widget.trackWidth - widget.thumbSize - widget.padding.horizontal : 0.0;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(isSwitched);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSwitch,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        width: widget.trackWidth,
        height: widget.trackHeight,
        padding: widget.padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.trackHeight / 2), color: isSwitched ? widget.activeColor : widget.inactiveColor),
        child: Stack(children: [AnimatedPositioned(duration: widget.duration, curve: widget.curve, left: dragPosition, child: Container(width: widget.thumbSize, height: widget.thumbSize, decoration: BoxDecoration(shape: BoxShape.circle, color: isSwitched ? widget.activeThumbColor : widget.inactiveThumbColor)))]),
      ),
    );
  }
}
