import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Widget chung để hiển thị ảnh với cache - Tối ưu để tránh nhảy giao diện
/// Fallback: Network → Locale → Error (với kiểm tra kết nối mạng thông minh)
class CachedImageWidget extends StatefulWidget {
  /// URL của ảnh
  final String imageUrl;

  /// Đường dẫn file ảnh trong thiết bị (fallback khi network lỗi)
  final String? localImagePath;

  /// Chiều rộng gốc của ảnh (để tính aspect ratio)
  final double? originalWidth;

  /// Chiều cao gốc của ảnh (để tính aspect ratio)
  final double? originalHeight;

  /// Chiều rộng tối đa hiển thị (mặc định sẽ lấy theo màn hình)
  final double? maxDisplayWidth;

  /// Chiều cao tối đa hiển thị
  final double? maxDisplayHeight;

  /// Cách hiển thị ảnh
  final BoxFit fit;

  /// Widget hiển thị khi đang tải
  final Widget? placeholder;

  /// Widget hiển thị khi có lỗi
  final Widget? errorWidget;

  /// Màu nền của placeholder
  final Color? placeholderColor;

  /// Màu nền của error widget
  final Color? errorColor;

  /// Kích thước icon loading
  final double loadingIconSize;

  /// Kích thước icon error
  final double errorIconSize;

  /// Tỷ lệ cache memory (mặc định 2x cho high DPI)
  final double memoryCacheRatio;

  /// Có sử dụng kích thước cố định không (để tránh nhảy giao diện)
  final bool useFixedSize;

  /// Aspect ratio mặc định khi không có thông tin kích thước
  final double defaultAspectRatio;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.localImagePath,
    this.originalWidth,
    this.originalHeight,
    this.maxDisplayWidth,
    this.maxDisplayHeight,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.errorColor,
    this.loadingIconSize = 24.0,
    this.errorIconSize = 32.0,
    this.memoryCacheRatio = 2.0,
    this.useFixedSize = true,
    this.defaultAspectRatio = 16 / 9,
  });

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  bool _hasLocalFile = false;
  bool _isCheckingConnectivity = false;
  bool? _hasInternet; // null = chưa check, true/false = đã check

  // Global cache để tránh check internet liên tục
  static bool? _globalInternetStatus;
  static DateTime? _lastInternetCheck;
  static const Duration _cacheDuration = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
    _checkInternetWithCache();
  }

  /// Kiểm tra file local có tồn tại không
  void _checkLocalFile() {
    if (widget.localImagePath?.isNotEmpty == true) {
      try {
        _hasLocalFile = File(widget.localImagePath!).existsSync();
      } catch (e) {
        _hasLocalFile = false;
      }
    }
  }

  /// Kiểm tra internet với cache để tránh check liên tục
  Future<void> _checkInternetWithCache() async {
    // Sử dụng cache nếu còn hạn
    final now = DateTime.now();
    if (_globalInternetStatus != null &&
        _lastInternetCheck != null &&
        now.difference(_lastInternetCheck!) < _cacheDuration) {
      setState(() {
        _hasInternet = _globalInternetStatus;
      });
      return;
    }

    // Check internet mới
    setState(() {
      _isCheckingConnectivity = true;
    });

    try {
      final hasInternet = await _checkInternetConnection();
      _globalInternetStatus = hasInternet;
      _lastInternetCheck = now;

      if (mounted) {
        setState(() {
          _hasInternet = hasInternet;
          _isCheckingConnectivity = false;
        });
      }
    } catch (e) {
      _globalInternetStatus = false;
      _lastInternetCheck = now;

      if (mounted) {
        setState(() {
          _hasInternet = false;
          _isCheckingConnectivity = false;
        });
      }
    }
  }

  /// Kiểm tra kết nối internet thực tế (đơn giản và nhanh)
  Future<bool> _checkInternetConnection() async {
    try {
      // Bước 1: Check connectivity nhanh
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Bước 2: Ping test đơn giản
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán kích thước hiển thị
    final imageWidth = widget.originalWidth ?? 300.0;
    final imageHeight = widget.originalHeight ?? 200.0;
    final aspectRatio = imageWidth / imageHeight;

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = widget.maxDisplayWidth ?? screenWidth;

    final displayWidth = imageWidth > maxWidth ? maxWidth : imageWidth;
    final displayHeight = displayWidth / aspectRatio;

    Widget imageWidget = _buildImageWidget(displayWidth, displayHeight);

    // Wrap trong SizedBox để cố định kích thước
    if (widget.useFixedSize) {
      return SizedBox(
        width: displayWidth,
        height: displayHeight,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Xây dựng widget ảnh chính
  Widget _buildImageWidget(double displayWidth, double displayHeight) {
    // Nếu đang check internet, hiển thị placeholder
    if (_hasInternet == null || _isCheckingConnectivity) {
      return _buildPlaceholder(displayWidth, displayHeight);
    }

    // Nếu không có internet, thử hiển thị local ngay
    if (_hasInternet == false) {
      if (_hasLocalFile) {
        return _buildLocalImage(displayWidth, displayHeight);
      } else {
        return _buildErrorWidget(
          displayWidth,
          displayHeight,
          "Không có kết nối internet",
        );
      }
    }

    // Có internet, thử load từ network
    return _buildNetworkImage(displayWidth, displayHeight);
  }

  /// Widget ảnh từ network với fallback
  Widget _buildNetworkImage(double displayWidth, double displayHeight) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,

      placeholder:
          (context, url) =>
              widget.placeholder ??
              _buildPlaceholder(displayWidth, displayHeight),

      errorWidget: (context, url, error) {
        // Network error, fallback to local
        if (_hasLocalFile) {
          return _buildLocalImage(displayWidth, displayHeight);
        }
        return _buildErrorWidget(displayWidth, displayHeight, "Lỗi tải ảnh");
      },

      // Cache settings
      memCacheWidth: (displayWidth * widget.memoryCacheRatio).toInt(),
      memCacheHeight: (displayHeight * widget.memoryCacheRatio).toInt(),
      maxWidthDiskCache: displayWidth.toInt(),
      maxHeightDiskCache: displayHeight.toInt(),
    );
  }

  /// Widget ảnh từ file local
  Widget _buildLocalImage(double displayWidth, double displayHeight) {
    return Image.file(
      File(widget.localImagePath!),
      fit: widget.fit,
      width: displayWidth,
      height: displayHeight,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(
          displayWidth,
          displayHeight,
          "Lỗi đọc file local",
        );
      },
    );
  }

  /// Widget placeholder khi đang loading
  Widget _buildPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: widget.placeholderColor ?? Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: widget.loadingIconSize,
          height: widget.loadingIconSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Widget hiển thị lỗi
  Widget _buildErrorWidget(double width, double height, [String? message]) {
    return widget.errorWidget ??
        Container(
          width: width,
          height: height,
          color: widget.errorColor ?? Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: widget.errorIconSize,
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
  }
}
