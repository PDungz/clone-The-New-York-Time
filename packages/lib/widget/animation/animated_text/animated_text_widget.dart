import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Enum để định nghĩa trạng thái của animation
enum AnimatedTextState {
  playing,
  pausedByUser,
  pausedBetweenAnimations,
  pausedBetweenAnimationsByUser,
  reset,
  stopped,
}

/// Controller để quản lý trạng thái animation
class AnimatedTextController {
  final ValueNotifier<AnimatedTextState> _stateNotifier = ValueNotifier(
    AnimatedTextState.playing,
  );

  ValueNotifier<AnimatedTextState> get stateNotifier => _stateNotifier;

  AnimatedTextState get state => _stateNotifier.value;
  set state(AnimatedTextState newState) => _stateNotifier.value = newState;

  /// Bắt đầu hoặc tiếp tục animation
  void play() => state = AnimatedTextState.playing;

  /// Tạm dừng animation
  void pause() => state = AnimatedTextState.pausedByUser;

  /// Reset animation về trạng thái ban đầu
  void reset() => state = AnimatedTextState.reset;

  /// Dừng animation hoàn toàn
  void stop() => state = AnimatedTextState.stopped;

  void dispose() => _stateNotifier.dispose();
}

/// Abstract class cho các loại animation text
abstract class AnimatedText {
  final String text;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Duration duration;
  final Characters textCharacters;

  AnimatedText({
    required this.text,
    this.textAlign = TextAlign.start,
    this.textStyle,
    required this.duration,
  }) : textCharacters = text.characters;

  /// Thời gian còn lại của animation
  Duration? get remaining => null;

  /// Khởi tạo animation
  void initAnimation(AnimationController controller);

  /// Tạo Text widget với style
  Widget textWidget(String data) =>
      Text(data, textAlign: textAlign, style: textStyle);

  /// Widget hiển thị text hoàn chỉnh
  Widget completeText(BuildContext context) => textWidget(text);

  /// Widget hiển thị animation
  Widget animatedBuilder(BuildContext context, Widget? child);
}

/// Typewriter animation - text xuất hiện từng ký tự
class TypewriterAnimatedText extends AnimatedText {
  final TextStyle? _cursorStyle;
  final bool showCursor;
  final String cursor;
  late Animation<int> _typewriterAnimation;

  TypewriterAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    this.showCursor = true,
    this.cursor = '|',
    TextStyle? cursorStyle,
  }) : _cursorStyle = cursorStyle,
       super(text: text);

  @override
  void initAnimation(AnimationController controller) {
    _typewriterAnimation = IntTween(
      begin: 0,
      end: textCharacters.length,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    final textLen = _typewriterAnimation.value;
    final displayText = textCharacters.take(textLen).toString();

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: displayText, style: textStyle),
          if (showCursor && textLen < textCharacters.length)
            TextSpan(
              text: cursor,
              style: _cursorStyle ?? textStyle?.copyWith(color: Colors.grey),
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Fade animation - text xuất hiện với hiệu ứng mờ dần
class FadeAnimatedText extends AnimatedText {
  late Animation<double> _fadeAnimation;

  FadeAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
  }) : super(text: text);

  @override
  void initAnimation(AnimationController controller) {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return FadeTransition(opacity: _fadeAnimation, child: textWidget(text));
  }
}

/// Scale animation - text xuất hiện với hiệu ứng phóng to
class ScaleAnimatedText extends AnimatedText {
  late Animation<double> _scaleAnimation;
  final Alignment alignment;

  ScaleAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    this.alignment = Alignment.center,
  }) : super(text: text);

  @override
  void initAnimation(AnimationController controller) {
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: alignment,
      child: textWidget(text),
    );
  }
}

/// Rotate animation - text xuất hiện với hiệu ứng xoay
class RotateAnimatedText extends AnimatedText {
  late Animation<double> _rotateAnimation;
  final Alignment alignment;

  RotateAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    this.alignment = Alignment.center,
  }) : super(text: text);

  @override
  void initAnimation(AnimationController controller) {
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return RotationTransition(
      turns: _rotateAnimation,
      alignment: alignment,
      child: textWidget(text),
    );
  }
}

/// Enum định nghĩa các hướng di chuyển
enum SlideDirection {
  fromLeft, // Từ trái vào
  fromRight, // Từ phải vào
  fromTop, // Từ trên xuống
  fromBottom, // Từ dưới lên
  fromTopLeft, // Từ góc trên trái
  fromTopRight, // Từ góc trên phải
  fromBottomLeft, // Từ góc dưới trái
  fromBottomRight, // Từ góc dưới phải
}

/// Slide animation - text trượt vào từ một hướng
class SlideAnimatedText extends AnimatedText {
  late Animation<Offset> _slideAnimation;
  final Offset begin;
  final Offset end;
  final SlideDirection? direction;

  SlideAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    this.begin = const Offset(-1.0, 0.0),
    this.end = Offset.zero,
    this.direction,
  }) : super(text: text);

  /// Constructor với direction được định nghĩa sẵn
  SlideAnimatedText.withDirection(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    required SlideDirection direction,
  }) : direction = direction,
       begin = _getBeginOffset(direction),
       end = Offset.zero,
       super(text: text);

  /// Lấy vị trí bắt đầu dựa trên hướng
  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
      case SlideDirection.fromTopLeft:
        return const Offset(-1.0, -1.0);
      case SlideDirection.fromTopRight:
        return const Offset(1.0, -1.0);
      case SlideDirection.fromBottomLeft:
        return const Offset(-1.0, 1.0);
      case SlideDirection.fromBottomRight:
        return const Offset(1.0, 1.0);
    }
  }

  @override
  void initAnimation(AnimationController controller) {
    final actualBegin = direction != null ? _getBeginOffset(direction!) : begin;
    _slideAnimation = Tween<Offset>(
      begin: actualBegin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return SlideTransition(position: _slideAnimation, child: textWidget(text));
  }
}

/// Colorize animation - text thay đổi màu sắc
class ColorizeAnimatedText extends AnimatedText {
  final List<Color> colors;
  late Animation<Color?> _colorAnimation;

  ColorizeAnimatedText(
    String text, {
    super.textAlign,
    super.textStyle,
    required super.duration,
    required this.colors,
  }) : assert(colors.length > 1, 'Cần ít nhất 2 màu'),
       super(text: text);

  @override
  void initAnimation(AnimationController controller) {
    _colorAnimation = TweenSequence<Color?>(
      colors.asMap().entries.map((entry) {
        final index = entry.key;
        final color = entry.value;
        return TweenSequenceItem(
          tween: ColorTween(
            begin: index == 0 ? color : colors[index - 1],
            end: color,
          ),
          weight: 1.0,
        );
      }).toList(),
    ).animate(controller);
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return Text(
      text,
      textAlign: textAlign,
      style:
          textStyle?.copyWith(color: _colorAnimation.value) ??
          TextStyle(color: _colorAnimation.value),
    );
  }
}

/// Main widget để hiển thị animated text
class AnimatedTextWidget extends StatefulWidget {
  final List<AnimatedText> animatedTexts;
  final Duration pause;
  final bool displayFullTextOnTap;
  final bool stopPauseOnTap;
  final VoidCallback? onTap;
  final VoidCallback? onFinished;
  final void Function(int, bool)? onNext;
  final void Function(int, bool)? onNextBeforePause;
  final bool isRepeatingAnimation;
  final bool repeatForever;
  final int totalRepeatCount;
  final AnimatedTextController? controller;

  const AnimatedTextWidget({
    super.key,
    required this.animatedTexts,
    this.pause = const Duration(milliseconds: 1000),
    this.displayFullTextOnTap = false,
    this.stopPauseOnTap = false,
    this.onTap,
    this.onNext,
    this.onNextBeforePause,
    this.onFinished,
    this.controller,
    this.isRepeatingAnimation = true,
    this.totalRepeatCount = 3,
    this.repeatForever = false,
  }) : assert(animatedTexts.length > 0),
       assert(!isRepeatingAnimation || totalRepeatCount > 0 || repeatForever);

  @override
  AnimatedTextWidgetState createState() => AnimatedTextWidgetState();
}

class AnimatedTextWidgetState extends State<AnimatedTextWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimatedText _currentAnimatedText;
  late AnimatedTextController _animatedTextController;

  int _currentRepeatCount = 0;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animatedTextController = widget.controller ?? AnimatedTextController();
    _animatedTextController.stateNotifier.addListener(_stateChangedCallback);
    _initAnimation();
  }

  void _stateChangedCallback() {
    if (!mounted) return;

    switch (_animatedTextController.state) {
      case AnimatedTextState.playing:
        if (!_controller.isAnimating) _controller.forward();
        break;
      case AnimatedTextState.pausedByUser:
        _controller.stop();
        break;
      case AnimatedTextState.reset:
        _controller.reset();
        _index = 0;
        _currentRepeatCount = 0;
        _initAnimation();
        break;
      case AnimatedTextState.stopped:
        _controller.stop();
        _timer?.cancel();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _animatedTextController.stateNotifier.removeListener(_stateChangedCallback);
    if (widget.controller == null) _animatedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completeText = _currentAnimatedText.completeText(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child:
          _shouldShowCompleteText()
              ? completeText
              : AnimatedBuilder(
                animation: _controller,
                builder: _currentAnimatedText.animatedBuilder,
                child: completeText,
              ),
    );
  }

  bool _shouldShowCompleteText() {
    return _animatedTextController.state ==
            AnimatedTextState.pausedBetweenAnimations ||
        _animatedTextController.state == AnimatedTextState.stopped ||
        !_controller.isAnimating;
  }

  bool get _isLast => _index == widget.animatedTexts.length - 1;

  void _nextAnimation() {
    final isLast = _isLast;
    widget.onNext?.call(_index, isLast);

    if (isLast) {
      if (widget.isRepeatingAnimation &&
          (widget.repeatForever ||
              _currentRepeatCount < widget.totalRepeatCount - 1)) {
        _index = 0;
        if (!widget.repeatForever) _currentRepeatCount++;
      } else {
        widget.onFinished?.call();
        return;
      }
    } else {
      _index++;
    }

    if (mounted) {
      setState(() {});
      _controller.dispose();
      _initAnimation();
    }
  }

  void _initAnimation() {
    _currentAnimatedText = widget.animatedTexts[_index];

    _controller = AnimationController(
      duration: _currentAnimatedText.duration,
      vsync: this,
    );

    _currentAnimatedText.initAnimation(_controller);
    _controller.addStatusListener(_animationEndCallback);

    if (_animatedTextController.state !=
        AnimatedTextState.pausedBetweenAnimationsByUser) {
      _animatedTextController.state = AnimatedTextState.playing;
      _controller.forward();
    }
  }

  void _setPauseBetweenAnimations() {
    _animatedTextController.state = AnimatedTextState.pausedBetweenAnimations;
    if (mounted) setState(() {});
    widget.onNextBeforePause?.call(_index, _isLast);
  }

  void _animationEndCallback(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _setPauseBetweenAnimations();
      _timer?.cancel();
      _timer = Timer(widget.pause, _nextAnimation);
    }
  }

  void _onTap() {
    if (widget.displayFullTextOnTap) {
      if (_animatedTextController.state ==
          AnimatedTextState.pausedBetweenAnimations) {
        if (widget.stopPauseOnTap) {
          _timer?.cancel();
          _nextAnimation();
        }
      } else {
        final remaining =
            _currentAnimatedText.remaining ?? _currentAnimatedText.duration;
        _controller.stop();
        _setPauseBetweenAnimations();

        _timer?.cancel();
        _timer = Timer(
          Duration(
            milliseconds: max(
              widget.pause.inMilliseconds,
              remaining.inMilliseconds,
            ),
          ),
          _nextAnimation,
        );
      }
    }
    widget.onTap?.call();
  }
}

/// Utility class để tạo các animation phổ biến
class AnimatedTextPresets {
  /// Tạo typewriter animation đơn giản
  static TypewriterAnimatedText typewriter(
    String text, {
    Duration duration = const Duration(seconds: 2),
    TextStyle? textStyle,
  }) => TypewriterAnimatedText(text, duration: duration, textStyle: textStyle);

  /// Tạo fade animation đơn giản
  static FadeAnimatedText fade(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => FadeAnimatedText(text, duration: duration, textStyle: textStyle);

  /// Tạo slide animation từ trái
  static SlideAnimatedText slideFromLeft(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromLeft,
  );

  /// Tạo slide animation từ phải
  static SlideAnimatedText slideFromRight(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromRight,
  );

  /// Tạo slide animation từ trên xuống
  static SlideAnimatedText slideFromTop(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromTop,
  );

  /// Tạo slide animation từ dưới lên
  static SlideAnimatedText slideFromBottom(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromBottom,
  );

  /// Tạo slide animation từ góc trên trái
  static SlideAnimatedText slideFromTopLeft(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromTopLeft,
  );

  /// Tạo slide animation từ góc trên phải
  static SlideAnimatedText slideFromTopRight(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromTopRight,
  );

  /// Tạo slide animation từ góc dưới trái
  static SlideAnimatedText slideFromBottomLeft(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromBottomLeft,
  );

  /// Tạo slide animation từ góc dưới phải
  static SlideAnimatedText slideFromBottomRight(
    String text, {
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: SlideDirection.fromBottomRight,
  );

  /// Tạo rainbow colorize animation
  static ColorizeAnimatedText rainbow(
    String text, {
    Duration duration = const Duration(seconds: 2),
    TextStyle? textStyle,
  }) => ColorizeAnimatedText(
    text,
    duration: duration,
    textStyle: textStyle,
    colors: [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ],
  );

  /// Tạo slide animation với hướng tùy chỉnh
  static SlideAnimatedText slideWithDirection(
    String text, {
    required SlideDirection direction,
    Duration duration = const Duration(seconds: 1),
    TextStyle? textStyle,
  }) => SlideAnimatedText.withDirection(
    text,
    duration: duration,
    textStyle: textStyle,
    direction: direction,
  );
}
