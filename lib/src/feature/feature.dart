import 'dart:async';

abstract class Feature {
  const Feature();

  Iterable<Feature> get dependencies => const [];
  String get tag => runtimeType.toString();

  void registerTypes() {}

  FutureOr<void> install() => Future.value();

  FutureOr<void> dispose() {}
}

abstract class FeatureWithSubscriptions extends Feature {
  List<StreamSubscription> subscriptions = [];

  @override
  FutureOr<void> dispose() async {
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
  }
}
