import 'dart:async';
import 'dart:developer';

import 'package:beaver_dependency_management/src/feature/feature.dart';
import 'package:beaver_dependency_management/src/feature/feature_manager.dart';
import 'package:beaver_dependency_management/src/get_it_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fox_logging/flutter_fox_logging.dart';
import 'package:get_it/get_it.dart';

Future<void> run<TRouter>({
  required List<Feature> features,
  required WidgetBuilder builder,
  Map<Object?, Object?>? zoneValues,
  ZoneSpecification? zoneSpecification,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final featureManager = FeatureManager(features: features);
  return runZonedGuarded(
    () async {
      featureManager.registerTypes();
      await featureManager.install();
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
