import 'package:logger/logger.dart';

/// Global app logger. Use sparingly — prefer Riverpod state for UI signaling.
/// Wired separately so swapping the logger backend is a one-file change.
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
