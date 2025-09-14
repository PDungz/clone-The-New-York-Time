import 'package:packages/generated/locales.g.dart';

import 'app_language_package.dart';

class Validator {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_email_required);
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return AppLanguagePackage.tr(LocaleKeys.validator_email_invalid);
    }

    return null;
  }

  // Validate password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_required);
    }

    if (value.length < minLength) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_password_min_length,
        args: [minLength.toString()],
      );
    }

    return null;
  }

  // Validate strong password
  static String? validateStrongPassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_required);
    }

    if (value.length < minLength) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_password_min_length,
        args: [minLength.toString()],
      );
    }

    // Check uppercase
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_uppercase);
    }

    // Check lowercase
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_lowercase);
    }

    // Check number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_number);
    }

    // Check special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppLanguagePackage.tr(LocaleKeys.validator_password_special);
    }

    return null;
  }

  // Validate phone number (Vietnam format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_phone_required);
    }

    // Remove spaces and special characters
    String cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vietnam phone number patterns
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return AppLanguagePackage.tr(LocaleKeys.validator_phone_invalid);
    }

    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      final field =
          fieldName ?? AppLanguagePackage.getDefaultFieldName('field');
      return AppLanguagePackage.tr(
        LocaleKeys.validator_field_required,
        args: [field],
      );
    }
    return null;
  }

  // Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      final field =
          fieldName ?? AppLanguagePackage.getDefaultFieldName('field');
      return AppLanguagePackage.tr(
        LocaleKeys.validator_field_required,
        args: [field],
      );
    }

    if (value.length < minLength) {
      final field =
          fieldName ?? AppLanguagePackage.getDefaultFieldName('field');
      return AppLanguagePackage.tr(
        LocaleKeys.validator_field_min_length,
        args: [field, minLength.toString()],
      );
    }

    return null;
  }

  // Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      final field =
          fieldName ?? AppLanguagePackage.getDefaultFieldName('field');
      return AppLanguagePackage.tr(
        LocaleKeys.validator_field_max_length,
        args: [field, maxLength.toString()],
      );
    }

    return null;
  }

  // Validate number
  static String? validateNumber(String? value, {String? fieldName}) {
    final field = fieldName ?? AppLanguagePackage.getDefaultFieldName('number');

    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_number_required,
        args: [field],
      );
    }

    if (double.tryParse(value) == null) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_number_invalid,
        args: [field],
      );
    }

    return null;
  }

  // Validate positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final field = fieldName ?? AppLanguagePackage.getDefaultFieldName('number');

    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_number_required,
        args: [field],
      );
    }

    final number = double.tryParse(value);
    if (number == null) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_number_invalid,
        args: [field],
      );
    }

    if (number <= 0) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_number_positive,
        args: [field],
      );
    }

    return null;
  }

  // Validate age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_age_required);
    }

    final age = int.tryParse(value);
    if (age == null) {
      return AppLanguagePackage.tr(LocaleKeys.validator_age_invalid);
    }

    if (age < 0 || age > 150) {
      return AppLanguagePackage.tr(LocaleKeys.validator_age_range);
    }

    return null;
  }

  // Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_url_required);
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return AppLanguagePackage.tr(LocaleKeys.validator_url_invalid);
    }

    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_confirm_password_required,
      );
    }

    if (value != originalPassword) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_confirm_password_mismatch,
      );
    }

    return null;
  }

  // Validate name (only letters and spaces)
  static String? validateName(String? value, {String? fieldName}) {
    final field = fieldName ?? AppLanguagePackage.getDefaultFieldName('name');

    if (value == null || value.trim().isEmpty) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_name_required,
        args: [field],
      );
    }

    // Allow Vietnamese characters, letters, and spaces
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return AppLanguagePackage.tr(
        LocaleKeys.validator_name_invalid,
        args: [field],
      );
    }

    return null;
  }

  // Validate date format (dd/mm/yyyy)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return AppLanguagePackage.tr(LocaleKeys.validator_date_required);
    }

    final dateRegex = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return AppLanguagePackage.tr(LocaleKeys.validator_date_format_invalid);
    }

    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return AppLanguagePackage.tr(LocaleKeys.validator_date_invalid);
      }
    } catch (e) {
      return AppLanguagePackage.tr(LocaleKeys.validator_date_invalid);
    }

    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
