import 'dart:async';

import 'package:get_it/get_it.dart';

abstract class Feature {
  List<Type> get dependencies;

  void registerTypes(GetIt getIt);

  Future<void> install(GetIt getIt);

  FutureOr<dynamic> dispose();
}
