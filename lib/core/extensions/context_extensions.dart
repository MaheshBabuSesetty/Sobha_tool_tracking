import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);

  // Snackbar
  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorSnackBar(String message) => showSnackBar(
        message,
        backgroundColor: colorScheme.error,
      );

  void showSuccessSnackBar(String message) => showSnackBar(
        message,
        backgroundColor: Colors.green,
      );

  // Dialog
  Future<T?> showAppDialog<T>({required Widget child, bool barrierDismissible = true}) =>
      showDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (_) => child,
      );

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: colorScheme.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Focus
  void hideKeyboard() => FocusScope.of(this).unfocus();

  // Responsive
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
}
