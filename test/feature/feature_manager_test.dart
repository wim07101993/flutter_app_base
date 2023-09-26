import 'package:flutter_app_base/flutter_app_base.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late FeatureManager featureManager;

  setUp(() {
    featureManager = FeatureManager();
  });

  group('ensureFeatureInstalled', () {
    test(
      'should install feature with dependencies in order and no other',
      () async {
        // arrange
        final aNoDependency = _FakeFeature('a');
        final bDependentOnA = _FakeFeature('b')..dependencies = [aNoDependency];
        final cDependentOnB = _FakeFeature('c')..dependencies = [bDependentOnA];

        // act
        await featureManager.ensureFeatureInstalled(cDependentOnB);

        // assert
        verifyInOrder([
          () => aNoDependency.registerTypes(),
          () => aNoDependency.install(),
          () => bDependentOnA.registerTypes(),
          () => bDependentOnA.install(),
          () => cDependentOnB.registerTypes(),
          () => cDependentOnB.install(),
        ]);
      },
    );

    test('should install each installer only once', () async {
      // arrange
      final aNoDependency = _FakeFeature('a');
      final bDependentOnA = _FakeFeature('b')..dependencies = [aNoDependency];
      final cDependentOnB = _FakeFeature('c')..dependencies = [bDependentOnA];
      final dDependentOnB = _FakeFeature('d')..dependencies = [bDependentOnA];

      // act
      await Future.wait([
        featureManager.ensureFeatureInstalled(cDependentOnB),
        featureManager.ensureFeatureInstalled(dDependentOnB),
      ]);

      // assert
      verify(() => aNoDependency.registerTypes()).called(1);
      verify(() => aNoDependency.install()).called(1);
      verify(() => bDependentOnA.registerTypes()).called(1);
      verify(() => bDependentOnA.install()).called(1);
      verify(() => cDependentOnB.registerTypes()).called(1);
      verify(() => cDependentOnB.install()).called(1);
      verify(() => dDependentOnB.registerTypes()).called(1);
      verify(() => dDependentOnB.install()).called(1);
    });

    test('should install features in parallel', () async {
      // arrange
      // arrange
      final aNoDependency = _FakeFeature('a')
        ..installDuration = const Duration(milliseconds: 100);
      final bNoDependency = _FakeFeature('b')
        ..installDuration = const Duration(seconds: 1);
      final cDependentOnA = _FakeFeature('c')..dependencies = [aNoDependency];
      final dDependentOnBAndC = _FakeFeature('d')
        ..dependencies = [bNoDependency, cDependentOnA];

      // act
      final installFuture =
          featureManager.ensureFeatureInstalled(dDependentOnBAndC);
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      expect(aNoDependency.isInstalling, isTrue);
      expect(bNoDependency.isInstalling, isTrue);

      await installFuture;
    });
  });
}

class _FakeFeature extends Mock implements Feature {
  _FakeFeature(String tag) {
    when(() => this.tag).thenReturn(tag);
    when(() => install()).thenAnswer((i) async {
      isInstalling = true;
      final installDuration = this.installDuration;
      if (installDuration != null) {
        await Future.delayed(installDuration);
      }
      isInstalled = true;
      isInstalling = false;
    });
  }

  bool isInstalling = false;
  bool isInstalled = false;
  Duration? installDuration;

  @override
  Iterable<Feature> dependencies = [];
}
