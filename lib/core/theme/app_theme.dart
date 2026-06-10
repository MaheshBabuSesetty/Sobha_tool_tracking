import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_tool_tracking/core/constants/app_constants.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      textTheme: _buildTextTheme(isDark),
      appBarTheme: _buildAppBarTheme(isDark, colorScheme),
      cardTheme: _buildCardTheme(isDark),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(isDark, colorScheme),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 1,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      navigationBarTheme: _buildNavigationBarTheme(isDark, colorScheme),
      chipTheme: _buildChipTheme(isDark, colorScheme),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
    );
  }

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onPrimaryContainer,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: Color(0xFF410001),
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.grey400,
        outlineVariant: AppColors.grey300,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.grey900,
        onInverseSurface: AppColors.grey50,
        inversePrimary: AppColors.primaryLight,
      );

  static ColorScheme get _darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryContainer,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onPrimaryContainer,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.secondaryContainer,
        error: AppColors.errorLight,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.error,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.grey600,
        outlineVariant: AppColors.grey700,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.grey100,
        onInverseSurface: AppColors.grey900,
        inversePrimary: AppColors.primary,
      );

  static TextTheme _buildTextTheme(bool isDark) {
    final color = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: color),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: color),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: color),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: color),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: color),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: color),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: color),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: color),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: color),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: color),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: color),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: color),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: color),
    );
  }

  static AppBarTheme _buildAppBarTheme(bool isDark, ColorScheme colorScheme) =>
      AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontSize: 20,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        shadowColor: Colors.transparent,
      );

  static CardThemeData _buildCardTheme(bool isDark) => CardThemeData(
        elevation: AppConstants.cardElevation,
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      );

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 52),
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(double.infinity, 52),
        ),
      );

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      );

  static InputDecorationTheme _buildInputDecorationTheme(
    bool isDark,
    ColorScheme cs,
  ) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: isDark ? AppColors.grey700 : AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: isDark ? AppColors.grey700 : AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.grey500 : AppColors.grey400,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: cs.error),
      );

  static NavigationBarThemeData _buildNavigationBarTheme(
    bool isDark,
    ColorScheme cs,
  ) =>
      NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: cs.primary);
          }
          return AppTextStyles.labelSmall.copyWith(
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary);
          }
          return IconThemeData(
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          );
        }),
        elevation: 8,
      );

  static ChipThemeData _buildChipTheme(bool isDark, ColorScheme cs) => ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
        selectedColor: cs.primaryContainer,
        disabledColor: isDark ? AppColors.grey700 : AppColors.grey200,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
}
