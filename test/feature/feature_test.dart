import 'dart:async';

import 'package:flutter_app_base/flutter_app_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Feature, () {
    group('tag', () {
      test('should be the name of the type by default', () {
        // arrange
        const feature = _Feature();

        // act
        final tag = feature.tag;

        // assert
        expect(tag, '_Feature');
      });
    });
  });

  group(FeatureWithSubscriptions, () {
    group('dispose', () {
      test('automatically cancels subscriptions', () async {
        // arrange
        final streamController = StreamController();
        var listenerHasBeenTriggered = false;
        // ignore: cancel_subscriptions
        final subscription = streamController.stream.listen((e) {
          listenerHasBeenTriggered = true;
        });
        final feature = _FeatureWithSubscriptions(subscription);

        // act
        await feature.dispose();
        streamController.add('random value');
        await Future.delayed(const Duration(milliseconds: 1));

        // assert
        expect(listenerHasBeenTriggered, isFalse);
      });
    });
  });
}

class _Feature extends Feature {
  const _Feature();
}

class _FeatureWithSubscriptions extends FeatureWithSubscriptions {
  _FeatureWithSubscriptions(StreamSubscription subscription) {
    subscriptions.add(subscription);
  }
}
