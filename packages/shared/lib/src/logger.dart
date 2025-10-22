import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

TalkerRouteObserver talkerRouteObserver() => TalkerRouteObserver(logger);

final logger = TalkerFlutter.init(
  logger: TalkerLogger(formatter: ExtendedLoggerFormatter(), settings: TalkerLoggerSettings(maxLineWidth: 100)),
);

TalkerDioLogger dioLogger() => TalkerDioLogger(
  talker: logger,
  settings: TalkerDioLoggerSettings(printRequestHeaders: true, printResponseTime: true, printErrorData: true),
);
