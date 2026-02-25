import 'package:beariscope_scouter/data/local_data.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strat_state.g.dart';

mixin StratNotifier {
  final box = Hive.box(boxKey);
  void reorder(int oldIndex, int newIndex);
  List<String> get();
  void set(List<String> list);
}

@riverpod
class DriverSkillNotifier extends _$DriverSkillNotifier with StratNotifier {
  @override
  List<String> build() => box.get('driverSkill') ?? ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    box.put('driverSkill', state);
  }

  @override
  List<String> get() {
    return state;
  }

  @override
  void set(List<String> list) {
    state = list;
    box.put('driverSkill', state);
  }
}

@riverpod
class DefensiveSkillNotifier extends _$DefensiveSkillNotifier with StratNotifier {
  @override
  List<String> build() => box.get('defensiveskill') ?? ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    box.put('defensiveskill', state);
  }

  @override
  List<String> get() {
    return state;
  }

  @override
  void set(List<String> list) {
    state = list;
    box.put('defensiveskill', state);
  }
}


@riverpod
class MechanicalStabilityNotifier extends _$MechanicalStabilityNotifier with StratNotifier {
  @override
  List<String> build() => box.get('mechanicalStability') ?? ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    box.put('mechanicalStability', state);
  }

  @override
  List<String> get() {
    return state;
  }

  @override
  void set(List<String> list) {
    state = list;
    box.put('mechanicalStability', state);
  }
}

@riverpod
class HumanPlayerNotifier extends _$HumanPlayerNotifier {
  @override
  int build() {
    final box = Hive.box(boxKey);
    return box.get('humanPlayer') ?? 0;
  }

  void set(int value) {
    state = value;
    final box = Hive.box(boxKey);
    box.put('humanPlayer', value);
  }
}