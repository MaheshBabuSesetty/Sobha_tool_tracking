import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.large,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonType type;
  final AppButtonSize size;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final minSize = Size(width ?? double.infinity, _getHeight());

    return switch (type) {
      AppButtonType.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(minimumSize: minSize),
          child: child,
        ),
      AppButtonType.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(minimumSize: minSize),
          child: child,
        ),
      AppButtonType.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(minimumSize: minSize),
          child: child,
        ),
      AppButtonType.destructive => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            minimumSize: minSize,
          ),
          child: child,
        ),
    };
  }

  double _getHeight() => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 52,
      };
}

enum AppButtonType { primary, secondary, text, destructive }

enum AppButtonSize { small, medium, large }
