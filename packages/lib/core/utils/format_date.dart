import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:packages/generated/locales.g.dart';

import 'app_language_package.dart';

class FormatDate {
  //! Format DateTime to String
  //* Format a DateTime to 'HH:mm'
  static String formatHHMM(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  //* Format a DateTime to 'HH:mm:ss'
  static String formatHHMMSS(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  //* Format a DateTime to 'dd/MM/yyyy'
  static String formatDDMMYYYY(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  //* Format a DateTime to 'dd/MM/yyyy HH:mm'
  static String formatDDMMYYYYHHMM(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  //* Format a DateTime to 'dd/MM/yyyy HH:mm:ss'
  static String formatDDMMYYYYHHMMSS(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  //* Format a DateTime to 'dd-MM-yyyy'
  static String formatDDMMYYYYWithDash(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  //* Format a DateTime to 'dd-MM'
  static String formatDDMMWithDash(DateTime dateTime) {
    return DateFormat('dd-MM').format(dateTime);
  }

  //! Locale-specific formatting methods (auto-initialize locale)
  //* Format a DateTime to a short human-readable e.g., 'Jan 1' or 'Th1 1'
  static String formatShort(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.MMMd(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //* Format a DateTime to an abbreviated human-readable e.g., 'Jan 1, 2025' or 'Th1 1, 2025'
  static String formatAbbreviated(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.MMMEd(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //* Format a DateTime to a human-readable e.g., 'January 1, 2025' or 'Tháng 1 1, 2025'
  static String formatHumanReadable(DateTime dateTime) {
    return _formatWithLocale(
      () =>
          DateFormat.yMMMMd(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //* Format a DateTime to a human-readable e.g., 'Monday, January 1, 2025' or 'Thứ Hai, Tháng 1 1, 2025'
  static String formatFullHumanReadable(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat(
        'EEEE, MMMM d, y',
        AppLanguagePackage.currentLocale,
      ).format(dateTime),
    );
  }

  //* Format with custom pattern and locale
  static String formatCustom(DateTime dateTime, String pattern) {
    return _formatWithLocale(
      () => DateFormat(
        pattern,
        AppLanguagePackage.currentLocale,
      ).format(dateTime),
    );
  }

  //* Format to full date with locale e.g., 'Thứ Hai, ngày 1 tháng 1 năm 2025'
  static String formatFullDate(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.yMMMMEEEEd(
        AppLanguagePackage.currentLocale,
      ).format(dateTime),
    );
  }

  //* Format to medium date with locale e.g., '1 Th1 2025'
  static String formatMediumDate(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.yMMMd(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //* Format time with locale (12/24 hour based on locale)
  static String formatTime(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.jm(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //* Format time with seconds and locale
  static String formatTimeWithSeconds(DateTime dateTime) {
    return _formatWithLocale(
      () => DateFormat.jms(AppLanguagePackage.currentLocale).format(dateTime),
    );
  }

  //! Private helper method to handle locale initialization and formatting
  static String _formatWithLocale(String Function() formatFunction) {
    try {
      // Try to format with the current locale
      return formatFunction();
    } catch (e) {
      // If locale is not initialized, initialize it and try again
      try {
        initializeDateFormatting(AppLanguagePackage.currentLocale, null);
        return formatFunction();
      } catch (e2) {
        // If still fails, fallback to default locale
        return formatFunction();
      }
    }
  }

  //! Convert int to DateTime
  //* Convert minutes to 'HH:mm'
  static String convertMinutesToHHMM(int minutes) {
    int hours = (minutes / 60).floor();
    int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  //* Convert seconds to 'HH:mm:ss'
  static String convertSecondsToHHMMSS(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Format "time ago" based on current locale - simplest approach
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    return _formatRelativeTime(difference);
  }

  /// Enhanced version using RelativeDateFormat-like approach
  static String formatTimeAgoRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Use locale-aware pluralization and formatting
    if (difference.inSeconds < 60) {
      final seconds = difference.inSeconds;
      return _getLocalizedTimeUnit(seconds, 'second');
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return _getLocalizedTimeUnit(minutes, 'minute');
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return _getLocalizedTimeUnit(hours, 'hour');
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return _getLocalizedTimeUnit(days, 'day');
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return _getLocalizedTimeUnit(months, 'month');
    } else {
      final years = (difference.inDays / 365).floor();
      return _getLocalizedTimeUnit(years, 'year');
    }
  }

  /// Format "time ago" in short style like NY Times (2m ago, 1h ago, 3d ago)
  static String formatTimeAgoShort(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Use short format
    return _formatRelativeTimeShort(difference);
  }

  /// Get localized time unit using translation system
  static String _getLocalizedTimeUnit(int value, String unit) {
    switch (unit) {
      case 'second':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_second,
          args: [value.toString()],
        );
      case 'minute':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_minute,
          args: [value.toString()],
        );
      case 'hour':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_hour,
          args: [value.toString()],
        );
      case 'day':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_day,
          args: [value.toString()],
        );
      case 'month':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_month,
          args: [value.toString()],
        );
      case 'year':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_year,
          args: [value.toString()],
        );
      default:
        return '$value $unit ago';
    }
  }

  /// Get short localized time unit (2m ago, 1h ago style)
  static String _getShortLocalizedTimeUnit(int value, String unit) {
    switch (unit) {
      case 'second':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_second,
          args: [value.toString()],
        );
      case 'minute':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_minute,
          args: [value.toString()],
        );
      case 'hour':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_hour,
          args: [value.toString()],
        );
      case 'day':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_day,
          args: [value.toString()],
        );
      case 'month':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_month,
          args: [value.toString()],
        );
      case 'year':
        return AppLanguagePackage.tr(
          LocaleKeys.format_date_time_ago_short_year,
          args: [value.toString()],
        );
      default:
        return '$value${unit[0]} ago';
    }
  }

  /// Fallback method for manual relative time calculation (full format)
  static String _formatRelativeTime(Duration difference) {
    if (difference.inSeconds < 60) {
      return _getLocalizedTimeUnit(difference.inSeconds, 'second');
    } else if (difference.inMinutes < 60) {
      return _getLocalizedTimeUnit(difference.inMinutes, 'minute');
    } else if (difference.inHours < 24) {
      return _getLocalizedTimeUnit(difference.inHours, 'hour');
    } else if (difference.inDays < 30) {
      return _getLocalizedTimeUnit(difference.inDays, 'day');
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return _getLocalizedTimeUnit(months, 'month');
    } else {
      final years = (difference.inDays / 365).floor();
      return _getLocalizedTimeUnit(years, 'year');
    }
  }

  /// Short format relative time calculation (NY Times style)
  static String _formatRelativeTimeShort(Duration difference) {
    // Handle "just now" for very recent times
    if (difference.inSeconds < 10) {
      return AppLanguagePackage.tr(LocaleKeys.format_date_now);
    }

    if (difference.inSeconds < 60) {
      return _getShortLocalizedTimeUnit(difference.inSeconds, 'second');
    } else if (difference.inMinutes < 60) {
      return _getShortLocalizedTimeUnit(difference.inMinutes, 'minute');
    } else if (difference.inHours < 24) {
      return _getShortLocalizedTimeUnit(difference.inHours, 'hour');
    } else if (difference.inDays < 30) {
      return _getShortLocalizedTimeUnit(difference.inDays, 'day');
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return _getShortLocalizedTimeUnit(months, 'month');
    } else {
      final years = (difference.inDays / 365).floor();
      return _getShortLocalizedTimeUnit(years, 'year');
    }
  }

  //! Simple Time Comparison Methods

  /// Check if dateTime1 is before dateTime2
  static bool isBefore(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.isBefore(dateTime2);
  }

  /// Check if dateTime1 is after dateTime2
  static bool isAfter(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.isAfter(dateTime2);
  }

  /// Check if two DateTime objects are at the same moment
  static bool isSameTime(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.isAtSameMomentAs(dateTime2);
  }

  /// Check if the duration between dateTime1 and dateTime2 exceeds the threshold
  /// Returns true if |dateTime1 - dateTime2| > threshold
  static bool isDurationExceeded(
    DateTime dateTime1,
    DateTime dateTime2,
    Duration threshold,
  ) {
    final difference = dateTime1.difference(dateTime2).abs();
    return difference > threshold;
  }

  /// Check if the duration between dateTime1 and dateTime2 is within the threshold
  /// Returns true if |dateTime1 - dateTime2| <= threshold
  static bool isDurationWithin(
    DateTime dateTime1,
    DateTime dateTime2,
    Duration threshold,
  ) {
    final difference = dateTime1.difference(dateTime2).abs();
    return difference <= threshold;
  }

  //! Common locale constants for convenience
  static const String localeVi = 'vi'; // Vietnamese
  static const String localeEn = 'en'; // English (US)
  static const String localeJa = 'ja'; // Japanese
}