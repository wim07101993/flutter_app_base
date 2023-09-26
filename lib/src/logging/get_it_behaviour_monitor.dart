import 'package:behaviour/behaviour.dart';
import 'package:get_it/get_it.dart';

class GetItBehaviourMonitor<T extends BehaviourTrack>
    implements BehaviourMonitor {
  const GetItBehaviourMonitor();

  @override
  BehaviourTrack? createBehaviourTrack(BehaviourMixin behaviour) {
    return GetIt.I<T>(param1: behaviour);
  }
}
