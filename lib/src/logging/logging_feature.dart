import 'package:ansicolor/ansicolor.dart';
import 'package:behaviour/behaviour.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_app_base/src/get_it_extensions.dart';
import 'package:flutter_app_base/src/logging/get_it_behaviour_monitor.dart';
import 'package:flutter_app_base/src/logging/logging_track.dart';

abstract class LoggingFeature<TBehaviourTrack extends BehaviourTrack>
    extends Feature {
  const LoggingFeature();

  void registerLogSink();
  void registerBehaviourTrack();

  @override
  @mustCallSuper
  void registerTypes() {
    GetIt.I.registerLazySingleton(() {
      final prettyFormatter = PrettyFormatter();
      return PrintSink(
        LevelDependentFormatter(
          defaultFormatter: SimpleFormatter(),
          severe: prettyFormatter,
          shout: prettyFormatter,
        ),
      );
    });

    GetIt.I.registerFactoryParam<Logger, String, dynamic>(
      (loggerName, _) => _loggerFactory(loggerName),
    );

    GetIt.I.registerFactory<BehaviourMonitor>(
      () => GetItBehaviourMonitor<TBehaviourTrack>(),
    );
    GetIt.I.registerFactoryParam<LoggingTrack, BehaviourMixin, dynamic>(
      (behaviour, _) => LoggingTrack(
        behaviour: behaviour,
        logger: GetIt.I.logger(behaviour.tag),
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
    if (GetIt.I.isRegistered<Logger>(instanceName: instanceName)) {
      return GetIt.I.get<Logger>(instanceName: instanceName);
    } else {
      final logger = Logger.detached(loggerName)..level = Level.ALL;
      GetIt.I.registerSingleton<Logger>(
        logger,
        instanceName: instanceName,
        dispose: (instance) => instance.clearListeners(),
      );
      GetIt.I<LogSink>().listenTo(logger.onRecord);
      return logger;
    }
  }
}
