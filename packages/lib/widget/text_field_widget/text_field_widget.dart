import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:packages/widget/button/icon_button_widget.dart';

enum BorderType { outline, underline, none }

class TextFieldWidget extends StatefulWidget {
  final String? label;
  final Widget? labelWidget;
  final String? hint;
  final String? svgPrefixIcon;
  final Color? prefixIconColor;
  final String? svgSuffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;
  final String? svgSuffixIconToggled;
  final Color primaryColor;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool isEnabled;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool autoFocus;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool isFilled;
  final BorderType borderType;
  final BorderRadius? borderRadius;
  final InputDecorationTheme? decorationTheme;
  final Color? textColor;
  final Color? labelColor;
  final Color? borderColor;
  final Color? hintTextColor;
  final TextStyle? hintStyle;
  final TextAlign textAlign;
  final bool showClearButton;

  const TextFieldWidget({
    super.key,
    this.label,
    this.labelWidget,
    this.hint,
    required this.controller,
    required this.focusNode,
    this.svgPrefixIcon,
    this.svgSuffixIcon,
    this.svgSuffixIconToggled,
    this.onSuffixIconTap,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.isEnabled = true,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autoFocus = false,
    this.textStyle,
    this.contentPadding,
    this.fillColor,
    this.isFilled = false,
    this.borderType = BorderType.outline,
    this.borderRadius,
    this.decorationTheme,
    this.textColor,
    this.labelColor,
    this.borderColor,
    this.hintTextColor,
    this.hintStyle,
    this.textAlign = TextAlign.left,
    required this.primaryColor,
    this.showClearButton = false,
    this.suffixIconSize,
    this.prefixIconColor,
    this.suffixIconColor,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late bool _obscureText;
  late bool _hasText;
  late bool _hasFocus;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _hasText = widget.controller.text.isNotEmpty;
    _hasFocus = widget.focusNode.hasFocus;

    // Thêm listener để theo dõi thay đổi text
    widget.controller.addListener(_onTextChanged);

    // Thêm listener để theo dõi focus
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    // Nhớ remove listener để tránh memory leak
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  // Hàm callback khi text thay đổi
  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  // Hàm callback khi focus thay đổi
  void _onFocusChanged() {
    final hasFocus = widget.focusNode.hasFocus;
    if (hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = hasFocus;
      });
    }
  }

  void toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void clearText() {
    widget.controller.clear();
    // Gọi onChanged callback nếu có
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    // Focus vào field sau khi clear (optional)
    widget.focusNode.requestFocus();
  }

  InputBorder getBorder(Color color, double width) {
    switch (widget.borderType) {
      case BorderType.outline:
        return OutlineInputBorder(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );
      case BorderType.underline:
        return UnderlineInputBorder(borderSide: BorderSide(color: color, width: width));
      case BorderType.none:
        return InputBorder.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final InputBorder border = getBorder(widget.borderColor ?? widget.primaryColor, 1);
    final InputBorder focusedBorder = getBorder(widget.primaryColor, 2);
    final InputBorder enabledBorder = getBorder(widget.primaryColor, 1);
    final InputBorder disabledBorder = getBorder(widget.primaryColor.withValues(alpha: 0.5), 1);

    final decoration =
        widget.decorationTheme ??
        InputDecorationTheme(
          labelStyle: TextStyle(color: widget.labelColor ?? widget.primaryColor),
          contentPadding:
              widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelWidget != null)
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: widget.labelWidget!)
        else if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                color: widget.labelColor ?? widget.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          enabled: widget.isEnabled,
          textInputAction: widget.textInputAction,
          autofocus: widget.autoFocus,
          onChanged: (value) {
            // Gọi callback của widget parent nếu có
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          textAlign: widget.textAlign,
          style:
              widget.textStyle?.copyWith(color: widget.textColor) ??
              TextStyle(color: widget.textColor ?? theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: widget.hint ?? '',
            hintStyle:
                widget.hintStyle ??
                TextStyle(
                  color: widget.hintTextColor ?? theme.hintColor,
                  fontWeight: FontWeight.normal,
                ),
            prefixIcon:
                widget.svgPrefixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        widget.svgPrefixIcon!,
                        height: 12.0,
                        colorFilter: ColorFilter.mode(
                          widget.prefixIconColor ?? widget.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                    : null,
            suffixIcon:
                widget.showClearButton && _hasText && _hasFocus
                    ? IconButtonWidget(icon: Icons.clear, onPressed: clearText)
                    : (widget.svgSuffixIcon != null
                        ? GestureDetector(
                          onTap: widget.obscureText ? toggleVisibility : widget.onSuffixIconTap,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              _obscureText
                                  ? widget.svgSuffixIcon!
                                  : widget.svgSuffixIconToggled ?? widget.svgSuffixIcon!,
                              height: widget.suffixIconSize ?? 12.0,
                              colorFilter: ColorFilter.mode(
                                widget.suffixIconColor ?? widget.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        )
                        : null),
            border: border,
            focusedBorder: focusedBorder,
            enabledBorder: enabledBorder,
            disabledBorder: disabledBorder,
            contentPadding: decoration.contentPadding,
            fillColor: widget.isFilled ? widget.fillColor : null,
            filled: widget.isFilled,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
