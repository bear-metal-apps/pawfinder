// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strat_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverSkillNotifier)
final driverSkillProvider = DriverSkillNotifierProvider._();

final class DriverSkillNotifierProvider
    extends $NotifierProvider<DriverSkillNotifier, List<String>> {
  DriverSkillNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverSkillProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverSkillNotifierHash();

  @$internal
  @override
  DriverSkillNotifier create() => DriverSkillNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$driverSkillNotifierHash() =>
    r'010311d3afb99d24425c763aee34ee612d52034f';

abstract class _$DriverSkillNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DefensiveSkillNotifier)
final defensiveSkillProvider = DefensiveSkillNotifierProvider._();

final class DefensiveSkillNotifierProvider
    extends $NotifierProvider<DefensiveSkillNotifier, List<String>> {
  DefensiveSkillNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defensiveSkillProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defensiveSkillNotifierHash();

  @$internal
  @override
  DefensiveSkillNotifier create() => DefensiveSkillNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$defensiveSkillNotifierHash() =>
    r'4ee60c674f13d65069fb1210d040b7c085afe794';

abstract class _$DefensiveSkillNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MechanicalStabilityNotifier)
final mechanicalStabilityProvider = MechanicalStabilityNotifierProvider._();

final class MechanicalStabilityNotifierProvider
    extends $NotifierProvider<MechanicalStabilityNotifier, List<String>> {
  MechanicalStabilityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mechanicalStabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mechanicalStabilityNotifierHash();

  @$internal
  @override
  MechanicalStabilityNotifier create() => MechanicalStabilityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$mechanicalStabilityNotifierHash() =>
    r'9656db8e6a9d6d3f2082f86df4ebf21d63b98f2b';

abstract class _$MechanicalStabilityNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HumanPlayerNotifier)
final humanPlayerProvider = HumanPlayerNotifierProvider._();

final class HumanPlayerNotifierProvider
    extends $NotifierProvider<HumanPlayerNotifier, int> {
  HumanPlayerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'humanPlayerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$humanPlayerNotifierHash();

  @$internal
  @override
  HumanPlayerNotifier create() => HumanPlayerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$humanPlayerNotifierHash() =>
    r'c92551b160b65ba4ff55ffefdc71a323903aa3ab';

abstract class _$HumanPlayerNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
