import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_app_base/src/feature/feature_manager.dart';
import 'package:get_it/get_it.dart';

extension FeatureManagerExtensions on FeatureManager {
  Future<void> ensureFeatureTypeInstalled<TFeature extends Feature>() {
    return ensureFeatureInstalled(GetIt.I<TFeature>());
  }
}

extension FeatureExtensions on Feature {
  Future<void> ensureInstalled() {
    return GetIt.I<FeatureManager>().ensureFeatureInstalled(this);
  }
}
