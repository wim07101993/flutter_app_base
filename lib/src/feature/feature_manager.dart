import 'dart:async';

import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_fox_logging/flutter_fox_logging.dart';

class FeatureManager {
  final Map<Feature, Completer?> _featureInstallationCompleters = {};
  Logger? _logger;
  LogSink? _logSink;

  Iterable<Feature> get features => _featureInstallationCompleters.keys;

  Logger get logger {
    if (_logger != null) {
      return _logger!;
    }
    final logSink = _logSink = PrintSink(SimpleFormatter());
    return _logger = Logger('FeatureManager')..onRecord.listen(logSink.write);
  }

  Future<void> ensureFeatureInstalled(Feature feature) {
    return _ensureFeatureInstalled(feature, []);
  }

  set logger(Logger value) => _logger = value;

  Future<void> _ensureFeatureInstalled(
    Feature feature,
    List<Feature> dependencyHierarchy,
  ) async {
    if (dependencyHierarchy.contains(feature)) {
      throw Exception(
        'A circular dependency was found while installing $feature. '
        'Call hierarchy: $dependencyHierarchy',
      );
    }
    final hierarchyWithFeature = [...dependencyHierarchy, feature];

    var installCompleter = _featureInstallationCompleters[feature];
    if (installCompleter != null) {
      return installCompleter.future;
    }

    _featureInstallationCompleters[feature] = installCompleter = Completer();
    try {
      final tag = feature.tag;

      logger.d('$tag: installing dependencies');
      await Future.wait(
        feature.dependencies
            .map((d) => _ensureFeatureInstalled(d, hierarchyWithFeature)),
      );
      logger.d('$tag: installed dependencies');

      logger.d('$tag: registering types');
      feature.registerTypes();
      logger.d('$tag: registered types');

      logger.d('$tag: installing');
      await feature.install();
      logger.d('$tag: installed');

      installCompleter.complete();
    } catch (error, stacktrace) {
      installCompleter.completeError(error, stacktrace);
    }
  }

  FutureOr<void> dispose() => _logSink?.dispose();
}
