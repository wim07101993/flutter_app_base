import 'package:flutter/widgets.dart';
import 'package:flutter_app_base/src/feature/feature.dart';
import 'package:flutter_app_base/src/feature/feature_manager.dart';
import 'package:flutter_app_base/src/feature/feature_manager_extensions.dart';
import 'package:get_it/get_it.dart';

class FeatureWidgetBuilder<TFeature extends Feature> extends StatelessWidget {
  const FeatureWidgetBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, bool isFeatureInstalled) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I<FeatureManager>()
          .ensureFeatureTypeInstalled<TFeature>()
          .then((_) => true),
      builder: (context, snapshot) => builder(context, snapshot.hasData),
    );
  }
}
