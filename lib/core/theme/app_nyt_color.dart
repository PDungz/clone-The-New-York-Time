import 'package:flutter/material.dart';

class AppNYTColors {
  AppNYTColors._();
  
  // ===== Brand Colors (Shared) =====
  static const Color nytBlue = Color(
    0xFF567b95,
  ); // NYT signature blue for links/buttons
  static const Color nytSerif = Color(0xFF121212); // Nearly black for headlines
  static const Color nytAccent = Color(
    0xFF8a8f98,
  ); // Subtle accent for UI elements

  static const Color nytWhite = Color(0xFFf6f6f6); // Off-white for backgrounds and text

  // ===== Common Colors (Shared) =====
  static const Color redAccent = Color(0xFFc51f24); // NYT-style alert red
  static const Color success = Color(0xFF4d8060); // Muted success green
  static const Color warning = Color(0xFFd0a85c); // Muted warning amber
  static const Color info = Color(0xFF567b95); // Same as NYT blue
  static const Color error = Color(0xFFab2d2d); // Error/destructive actions

  // ===== Special Elements (Shared) =====
  static const Color premium = Color(
    0xFFc7a975,
  ); // Gold color for premium/subscription content
  static const Color linkVisited = Color(0xFF6b5c95); // Visited links
  static const Color specialSection = Color(
    0xFF9c6a4e,
  ); // Special news sections
  static const Color breakingNews = Color(
    0xFFe5323b,
  ); // Breaking news indicator

  // ===== Tags and Categories (Shared) =====
  static const Color politics = Color(0xFF7d7fb9); // Politics tag
  static const Color business = Color(0xFF4d8060); // Business tag
  static const Color technology = Color(0xFF6a8d9d); // Technology tag
  static const Color science = Color(0xFF508ca8); // Science tag
  static const Color arts = Color(0xFF9f7e7d); // Arts & Culture tag
  static const Color opinion = Color(0xFF887d64); // Opinion tag
  static const Color sports = Color(0xFF738d50); // Sports tag

  // ===== LIGHT THEME COLORS =====

  // === Light Theme Base Colors ===
  static const Color lightPrimary = Color(0xFF333333); // Dark charcoal
  static const Color lightPrimaryLight = Color(0xFF555555); // Mid-tone gray
  static const Color lightPrimaryDark = Color(0xFF1a1a1a); // Very dark gray
  static const Color lightSecondary = Color(0xFF8a8f98); // Muted bluish-gray
  
  // === Light Theme Background Colors ===
  static const Color lightBackground = Color(
    0xFFffffff,
  ); // Off-white background
  static const Color lightScaffold = Color(
    0xFFffffff,
  ); // Slightly more off-white
  static const Color lightCard = Color(0xFFffffff); // White for cards
  static const Color lightDialog = Color(0xFFffffff); // White for dialogs
  static const Color lightBottomSheet = Color(
    0xFFffffff,
  ); // Bottom sheet background
  static const Color lightSnackbar = Color(0xFF333333); // Snackbar background
  static const Color lightAppBar = Color(0xFFffffff); // App bar background
  
  // === Light Theme Text Colors ===
  static const Color lightTextPrimary = Color(
    0xFF1a1a1a,
  ); // Dark gray for primary text
  static const Color lightTextSecondary = Color(
    0xFF666666,
  ); // Medium gray for secondary text
  static const Color lightTextDisabled = Color(
    0xFFbbc0c4,
  ); // Light gray for disabled text

  // === Light Theme UI Colors ===
  static const Color lightDivider = Color(0xFFbbc0c4); // Light gray divider
  static const Color lightBorder = Color(0xFFdedfe0); // Very light gray border
  static const Color lightIcon = Color(0xFF1a1a1a); // Icon color
  static const Color lightUnsetIcon = Color(0xFF777777); // Unset icon color
  static const Color lightShadow = Color(0x1A000000); // Light shadow
  static const Color lightOverlay = Color(0x99000000); // Overlay color
  static const Color lightDim = Color(0xDDf6f6f6); // Dim effect for modals
  
  // === Light Theme Special Colors ===
  static const Color lightHighlight = Color(0xFFf7ecc5); // Text highlight color
  static const Color lightPrintStyle = Color(0xFF2b2b2b); // Print-like text
  static const Color lightPrintBackground = Color(
    0xFFf5f3ed,
  ); // Newspaper texture background
  
  // === Light Theme Interactive Elements ===
  static const Color lightButtonPrimary = Color(
    0xFF000000,
  ); // Primary button background
  static const Color lightButtonPrimaryText = Color(
    0xFFffffff,
  ); // Primary button text
  static const Color lightButtonSecondary = Color(
    0xFFf2f2f2,
  ); // Secondary button background
  static const Color lightButtonSecondaryText = Color(
    0xFF333333,
  ); // Secondary button text
  static const Color lightSelectionActive = Color(
    0xFFe5e5e5,
  ); // Active selection

  // === Light Theme Interactive States ===
  static const Color lightRipple = Color(0x1F000000); // Ripple effect
  static const Color lightHover = Color(0x0A000000); // Hover state
  static const Color lightFocus = Color(0x1A000000); // Focus state

  // === Light Theme Gradients ===
  static const List<Color> lightFadeGradient = [
    Color(0x00000000),
    Color(0x99000000),
  ]; // Content fade gradient

  // ===== DARK THEME COLORS =====

  // === Dark Theme Base Colors ===
  static const Color darkPrimary = Color(0xFFf6f6f6); // Off-white primary
  static const Color darkPrimaryLight = Color(0xFFffffff); // Pure white
  static const Color darkPrimaryDark = Color(0xFF8a8f98); // Mid-tone gray
  static const Color darkSecondary = Color(0xFF6e7480); // Muted bluish-gray
  
  // === Dark Theme Background Colors ===
  static const Color darkBackground = Color(0xFF000000); // Pure black
  static const Color darkScaffold = Color(0xFF000000); // Pure black
  static const Color darkCard = Color(
    0xFF242424,
  ); // Slightly lighter than background
  static const Color darkDialog = Color(0xFF2c2c2c); // Dialog background
  static const Color darkBottomSheet = Color(
    0xFF242424,
  ); // Bottom sheet background
  static const Color darkSnackbar = Color(0xFF333333); // Snackbar background
  static const Color darkAppBar = Color(0xFF000000); // App bar background
  
  // === Dark Theme Text Colors ===
  static const Color darkTextPrimary = Color(
    0xFFf6f6f6,
  ); // Off-white for primary text
  static const Color darkTextSecondary = Color(
    0xFFbbc0c4,
  ); // Light gray for secondary text
  static const Color darkTextDisabled = Color(
    0xFF666666,
  ); // Darker gray for disabled text

  // === Dark Theme UI Colors ===
  static const Color darkDivider = Color(0xFFffffff); // Dark gray divider
  static const Color darkBorder = Color(0xFF444444); // Dark border
  static const Color darkIcon = Color(0xFFffffff); // Icon color
  static const Color darkUnsetIcon = Color(0xFF777777); // Unset icon color
  static const Color darkShadow = Color(0xFF333333); // Darker shadow
  static const Color darkOverlay = Color(0xCC000000); // Overlay color
  static const Color darkDim = Color(0xEE121212); // Dim effect for modals
  
  // === Dark Theme Special Colors ===
  static const Color darkHighlight = Color(0xFF3a3723); // Text highlight color
  static const Color darkPrintStyle = Color(
    0xFFdedede,
  ); // Print-like text for dark mode
  static const Color darkPrintBackground = Color(
    0xFF1e1e1e,
  ); // Dark newspaper texture

  // === Dark Theme Interactive Elements ===
  static const Color darkButtonPrimary = Color(
    0xFFf6f6f6,
  ); // Primary button background
  static const Color darkButtonPrimaryText = Color(
    0xFF1a1a1a,
  ); // Primary button text
  static const Color darkButtonSecondary = Color(
    0xFF333333,
  ); // Secondary button background
  static const Color darkButtonSecondaryText = Color(
    0xFFf6f6f6,
  ); // Secondary button text
  static const Color darkSelectionActive = Color(
    0xFF333333,
  ); // Active selection

  // === Dark Theme Interactive States ===
  static const Color darkRipple = Color(0x1Fffffff); // Ripple effect
  static const Color darkHover = Color(0x0Affffff); // Hover state
  static const Color darkFocus = Color(0x1Affffff); // Focus state

  // === Dark Theme Gradients ===
  static const List<Color> darkFadeGradient = [
    Color(0x00121212),
    Color(0xCC121212),
  ]; // Content fade gradient

  // ===== SHARED GRADIENTS & READING MODES =====

  // === Premium & Featured Gradients ===
  static const List<Color> premiumGradient = [
    Color(0xFFd9c48f),
    Color(0xFFc7a975),
  ]; // Premium content gradient
  
  static const List<Color> featuredGradient = [
    Color(0xFF38506c),
    Color(0xFF567b95),
  ]; // Featured content

  // === Reading Modes (Shared) ===
  static const Color sepia = Color(0xFFf9f3e8); // Sepia reading background
  static const Color sepiaText = Color(0xFF5b4636); // Sepia reading text
  static const Color nightMode = Color(0xFF121212); // Night reading background
  static const Color nightModeText = Color(0xFF777777); // Night reading text
  static const Color printMode = Color(0xFFf5f3ed); // Print reading background
  static const Color printModeText = Color(0xFF1a1a1a); // Print reading text

  // ===== DEPRECATED (Keep for backward compatibility) =====

  static const Color highlight = lightHighlight;

  static const Color buttonPrimary = lightButtonPrimary;

  static const Color buttonPrimaryText = lightButtonPrimaryText;

  static const Color buttonSecondary = lightButtonSecondary;

  static const Color buttonSecondaryText = lightButtonSecondaryText;

  static const Color selectionActive = lightSelectionActive;

  static const Color rippleLight = lightRipple;

  static const Color rippleDark = darkRipple;

  static const Color hoverLight = lightHover;

  static const Color hoverDark = darkHover;

  static const Color focusLight = lightFocus;

  static const Color focusDark = darkFocus;

  static const List<Color> fadeGradient = lightFadeGradient;
}
