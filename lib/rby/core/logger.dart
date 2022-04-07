// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:harpy/rby/rby.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// A convenience mixin to expose a [Logger] instance for classes named after
/// their type.
mixin LoggerMixin {
  Logger get log => Logger('$runtimeType');
}

/// Adds a listener to the top-level root logger.
///
/// Clients can call the [Logger] singleton constructor to log messages or use
/// [Logger.detached] to create local short-living logger that can be
/// garbage-collected later.
void initializeLogger({String? prefix}) {
  if (kReleaseMode || isTest) return;

  Logger.root.level = Level.ALL;

  const separator = ' | ';
  const horizontalSeparator = '--------------------------------';

  Logger.root.onRecord.listen((rec) {
    final content = [
      DateFormat('HH:mm:s.S').format(DateTime.now()),
      separator,
      if (prefix != null) ...[
        prefix,
        separator,
      ],
      rec.level.name.padRight(7),
      separator,
      rec.loggerName.padRight(22),
      separator,
      rec.message,
    ];

    print(content.join());

    if (rec.error != null) {
      print(horizontalSeparator);
      print('ERROR');

      if (rec.error is Response) {
        print((rec.error as Response).body);
      } else {
        print(rec.error.toString());
      }

      print(horizontalSeparator);

      if (rec.stackTrace != null) {
        print('STACK TRACE');
        rec.stackTrace.toString().trim().split('\n').forEach(print);
        print(horizontalSeparator);
      }
    }
  });
}
