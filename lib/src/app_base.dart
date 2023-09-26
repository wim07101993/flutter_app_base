import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_app_base/src/feature/feature_manager.dart';
import 'package:flutter_app_base/src/get_it_extensions.dart';

Future<void> run<TRouter>({
  required List<Feature> features,
  required WidgetBuilder builder,
  Map<Object?, Object?>? zoneValues,
  ZoneSpecification? zoneSpecification,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final featureManager = FeatureManager();
  GetIt.I.registerSingleton(featureManager);
  return runZonedGuarded(
    () async {
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
