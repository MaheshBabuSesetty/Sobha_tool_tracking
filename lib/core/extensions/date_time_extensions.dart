import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get toDisplayDate => DateFormat('dd MMM yyyy').format(this);
  String get toDisplayDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  String get toDisplayTime => DateFormat('hh:mm a').format(this);
  String get toIso8601 => toIso8601String();
  String get toApiFormat => DateFormat('yyyy-MM-dd').format(this);
  String get toShortDate => DateFormat('dd/MM/yyyy').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  bool isOverdue({int toleranceDays = 0}) =>
      isBefore(DateTime.now().subtract(Duration(days: toleranceDays)));

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  int get daysDifference => DateTime.now().difference(this).inDays.abs();

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension NullableDateTimeExtensions on DateTime? {
  String get displayOrDash => this?.toDisplayDate ?? '—';
  bool get isNullOrPast => this == null || this!.isPast;
}
