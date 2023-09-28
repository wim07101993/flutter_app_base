import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_app_base/src/feature/feature_manager.dart';
import 'package:flutter_app_base/src/get_it_extensions.dart';
import 'package:flutter_app_base/src/logging/logging_feature.dart';

Future<void> run({
  required WidgetBuilder builder,
  List<Feature> featuresToInstallBeforeRunning = const [],
  Map<Object?, Object?>? zoneValues,
  ZoneSpecification? zoneSpecification,
}) async {
  return runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final featureManager = FeatureManager();
      GetIt.I.registerSingleton(featureManager);

      if (GetIt.I.isRegistered<LoggingFeature>()) {
        await featureManager.ensureFeatureInstalled(GetIt.I<LoggingFeature>());
      } else {
        await featureManager.ensureFeatureInstalled(defaultLoggingFeature);
      }

      await Future.wait([
        for (final feature in featuresToInstallBeforeRunning)
          featureManager.ensureFeatureInstalled(feature),
      ]);

      runApp(Builder(builder: builder));
    },
    (error, stack) {
      if (GetIt.I.isRegistered<Logger>()) {
        GetIt.I
            .logger('run')
            .shout('an error happened at the root level', error, stack);
      } else {
        log(
          'an error happened at the root level',
          error: error,
          stackTrace: stack,
        );
      }
    },
    zoneValues: zoneValues,
    zoneSpecification: zoneSpecification,
  );
}
