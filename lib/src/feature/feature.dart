import 'dart:async';

abstract class Feature {
  const Feature();

  List<Type> get dependencies => const [];

  void registerTypes() {}

  Future<void> install() => Future.value();

  FutureOr<void> dispose() {}

  @override
  String toString() => runtimeType.toString();
}

abstract class FeatureWithSubscriptions extends Feature {
  FeatureWithSubscriptions();

  List<StreamSubscription> subscriptions = [];

  @override
  List<Type> get dependencies => const [];

  @override
  void registerTypes() {}

  @override
  Future<void> install() => Future.value();

  @override
  FutureOr<void> dispose() async {
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
  }
}
