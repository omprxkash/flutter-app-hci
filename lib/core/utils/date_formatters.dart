import 'package:intl/intl.dart';

/// Centralized date/time formatting. Avoid raw `DateFormat(...).format(...)`
/// in widgets — go through here so locale + style stay consistent.
class DateFormatters {
  const DateFormatters._();

  static final DateFormat _short = DateFormat('d MMM y');
  static final DateFormat _long = DateFormat('EEE, d MMM y');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _full = DateFormat('d MMM y, h:mm a');
  static final DateFormat _iso = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  static String short(DateTime date) => _short.format(date);
  static String long(DateTime date) => _long.format(date);
  static String timeOfDay(DateTime date) => _time.format(date);
  static String full(DateTime date) => _full.format(date);
  static String iso(DateTime date) => _iso.format(date.toUtc());

  /// Human "x ago" formatter. Falls back to a short date once >7 days.
  static String relative(DateTime date, {DateTime? now}) {
    final DateTime n = now ?? DateTime.now();
    final Duration diff = n.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return short(date);
  }
}
