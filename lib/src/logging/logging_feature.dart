import 'package:ansicolor/ansicolor.dart';
import 'package:beaver_dependency_management/src/feature/feature.dart';
import 'package:beaver_dependency_management/src/feature/feature_extensions.dart';
import 'package:beaver_dependency_management/src/get_it_extensions.dart';
import 'package:beaver_dependency_management/src/logging/get_it_behaviour_monitor.dart';
import 'package:beaver_dependency_management/src/logging/logging_track.dart';
import 'package:behaviour/behaviour.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fox_logging/flutter_fox_logging.dart';

abstract class LoggingFeature<TBehaviourTrack extends BehaviourTrack>
    extends Feature {
  const LoggingFeature();

  void registerLogSink();
  void registerBehaviourTrack();

  @override
  @mustCallSuper
  void registerTypes() {
    getIt.registerLazySingleton(() {
      final prettyFormatter = PrettyFormatter();
      return PrintSink(
        LevelDependentFormatter(
          defaultFormatter: SimpleFormatter(),
          severe: prettyFormatter,
          shout: prettyFormatter,
        ),
      );
    });

    getIt.registerFactoryParam<Logger, String, dynamic>(
      (loggerName, _) => _loggerFactory(loggerName),
    );

    getIt.registerFactory<BehaviourMonitor>(
      () => GetItBehaviourMonitor<TBehaviourTrack>(getIt: getIt),
    );
    getIt.registerFactoryParam<LoggingTrack, BehaviourMixin, dynamic>(
      (behaviour, _) => LoggingTrack(
        behaviour: behaviour,
        logger: getIt.logger(behaviour.tag),
      ),
    );
  }

  @override
  Future<void> install() {
    hierarchicalLoggingEnabled = true;
    recordStackTraceAtLevel = Level.SEVERE;
    Logger.root.level = Level.ALL;
    ansiColorDisabled = false;
    return Future.value();
  }

  Logger _loggerFactory(String loggerName) {
    final instanceName = '$loggerName-logger';
    if (getIt.isRegistered<Logger>(instanceName: instanceName)) {
      return getIt.get<Logger>(instanceName: instanceName);
    } else {
      final logger = Logger.detached(loggerName)..level = Level.ALL;
      getIt.registerSingleton<Logger>(
        logger,
        instanceName: instanceName,
        dispose: (instance) => instance.clearListeners(),
      );
      getIt<LogSink>().listenTo(logger.onRecord);
      return logger;
    }
  }
}
