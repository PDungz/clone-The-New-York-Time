import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double height; // Chiều cao
  final double? width; // Chiều rộng
  final double borderRadius; // Bo góc
  final bool isCircular; // Hình tròn hoặc chữ nhật
  final Color baseColor; // Màu nền tối
  final Color highlightColor; // Màu sáng khi shimmer chạy
  final Duration duration; // Thời gian hoàn thành một vòng hiệu ứng
  final double opacity; // Độ trong suốt của màu nền
  final Alignment begin; // Hướng bắt đầu highlight
  final Alignment end; // Hướng kết thúc highlight
  final ShimmerDirection shimmerDirection; // Kiểu di chuyển shimmer
  final bool useFadeEffect; // Dùng hiệu ứng mờ dần thay vì trượt ngang

  const ShimmerWidget({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 8.0,
    this.isCircular = false,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
    this.opacity = 0.6,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.shimmerDirection = ShimmerDirection.ltr, // Mặc định từ trái qua phải
    this.useFadeEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      period: duration,
      direction: shimmerDirection, // Kiểm soát hướng di chuyển
      enabled: true, // Bật/tắt shimmer
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: [
          baseColor.withValues(alpha: opacity),
          highlightColor.withValues(alpha: opacity),
          baseColor.withValues(alpha: opacity),
        ],
        stops: const [0.2, 0.5, 0.8], // Điều chỉnh vị trí sáng tối
      ),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: opacity),
          borderRadius: isCircular ? null : BorderRadius.circular(borderRadius),
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}
