import 'package:flutter_fox_logging/flutter_fox_logging.dart';
import 'package:get_it/get_it.dart';

export 'package:flutter_fox_logging/flutter_fox_logging.dart';
export 'package:get_it/get_it.dart';

extension GetItExtensions on GetIt {
  Logger logger<T>([String? loggerName]) {
    return get<Logger>(param1: loggerName ?? T.runtimeType.toString());
  }
}
