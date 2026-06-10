extension StringExtensions on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');

  String get camelToSnake => replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );

  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(replaceAll(RegExp(r'[\s\-()]'), ''));
  }

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isNullOrEmpty => trim().isEmpty;
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  String? get nullIfEmpty => trim().isEmpty ? null : this;

  String obfuscate({int visibleChars = 4}) {
    if (length <= visibleChars) return this;
    return '${substring(0, visibleChars)}${'*' * (length - visibleChars)}';
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.trim().isNotEmpty;
  String get orEmpty => this ?? '';
}
