class NotificationCount {
  final bool? hasNewMessage;
  final int? unreadCount;
  final DateTime? timestamp;
  final int? serverTime;

  const NotificationCount({this.hasNewMessage, this.unreadCount, this.timestamp, this.serverTime});

  /// Factory constructor for initial state
  factory NotificationCount.initial() {
    return NotificationCount(hasNewMessage: false, unreadCount: 0, timestamp: DateTime.now());
  }

  /// Business logic: Check if badge should be shown
  bool get shouldShowBadge => (unreadCount ?? 0) > 0 || (hasNewMessage ?? false);

  /// Business logic: Get display text for badge
  String get displayText {
    final count = unreadCount ?? 0;
    if (count == 0) return '';
    if (count > 99) return '99+';
    return count.toString();
  }

  /// Business logic: Check if should animate badge
  bool get shouldAnimate => hasNewMessage ?? false;

  /// Business logic: Check if notification count is critical
  bool get isCritical => (unreadCount ?? 0) > 50;

  /// Business rule: Create updated count
  NotificationCount copyWith({
    bool? hasNewMessage,
    int? unreadCount,
    DateTime? timestamp,
    int? serverTime,
  }) {
    return NotificationCount(
      hasNewMessage: hasNewMessage ?? this.hasNewMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      timestamp: timestamp ?? this.timestamp,
      serverTime: serverTime ?? this.serverTime,
    );
  }

  /// Business rule: Mark all as read
  NotificationCount markAllAsRead() {
    return copyWith(hasNewMessage: false, unreadCount: 0, timestamp: DateTime.now());
  }

  /// Business rule: Mark single as read
  NotificationCount markSingleAsRead() {
    final currentCount = unreadCount ?? 0;
    return copyWith(
      unreadCount: currentCount > 0 ? currentCount - 1 : 0,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'NotificationCount(hasNewMessage: $hasNewMessage, unreadCount: $unreadCount, timestamp: $timestamp, serverTime: $serverTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationCount &&
        other.hasNewMessage == hasNewMessage &&
        other.unreadCount == unreadCount &&
        other.timestamp == timestamp &&
        other.serverTime == serverTime;
  }

  @override
  int get hashCode => Object.hash(hasNewMessage, unreadCount, timestamp, serverTime);
}
