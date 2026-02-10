import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/big_number.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/tristate.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/data/ui_json_serialization.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final matchConfigProvider = FutureProvider<MatchConfig>((ref) async {
  final jsonString = await rootBundle.loadString('resources/ui_creator.json');
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  return MatchConfig.fromJson(json);
});

class MatchPage extends ConsumerWidget {
  final int index;

  const MatchPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scoutingSessionProvider);
    final configAsync = ref.watch(matchConfigProvider);

    if (!session.isConfigured) {
      return const Center(child: Text('Finish scouting setup first.'));
    }

    final eventKey = session.event?.key ?? '';
    final position = session.position;
    final matchNumber = session.matchNumber ?? 0;

    if (eventKey.isEmpty || position == null || matchNumber <= 0) {
      return const Center(child: Text('Missing match context.'));
    }

    final matchesAsync = ref.watch(matchesProvider(eventKey));

    return matchesAsync.when(
      loading: () =>
          _buildFromConfig(
            context,
            configAsync,
            _identityFromSession(session, 0),
          ),
      error: (err, _) =>
          _buildFromConfig(
            context,
            configAsync,
            _identityFromSession(session, 0),
          ),
      data: (matches) {
        final scoutingMatch = matches.firstWhere(
              (match) => match.matchNumber == matchNumber,
          orElse: () =>
              ScoutingMatch(
                key: '',
                compLevel: 'qm',
                matchNumber: matchNumber,
                eventKey: eventKey,
              ),
        );
        final robotNum = _robotNumberForMatch(scoutingMatch, position);
        return _buildFromConfig(
          context,
          configAsync,
          _identityFromSession(session, robotNum),
        );
      },
    );
  }

  Widget _buildFromConfig(BuildContext context,
      AsyncValue<MatchConfig> configAsync,
      MatchIdentity identity,) {
    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Match UI load failed: $err')),
      data: (config) {
        if (index < 0 || index >= config.pages.length) {
          return const Center(child: Text('Match page not found.'));
        }

        final page = config.pages[index];
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = _finiteOrFallback(
                constraints.maxWidth,
                MediaQuery
                    .of(context)
                    .size
                    .width,
              );
              final height = _finiteOrFallback(
                constraints.maxHeight,
                MediaQuery
                    .of(context)
                    .size
                    .height,
              );

              final horizontalStep = width / page.width;
              final verticalStep = height / page.height;

              return SizedBox(
                width: width,
                height: height,
                child: _buildStack(
                  page,
                  horizontalStep,
                  verticalStep,
                  identity,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStack(PageConfig page,
      double horizontalStep,
      double verticalStep,
      MatchIdentity identity,) {
    final dataBox = Hive.box(boxKey);

    final widgets = page.components.map((component) {
      final width = component.layout.w * horizontalStep;
      final height = component.layout.h * verticalStep;
      final left = component.layout.x * horizontalStep;
      final top = component.layout.y * verticalStep;

      final dataBoxKey = matchDataKey(
          identity, page.sectionId, component.fieldId);
      final storedValue = dataBox.get(dataBoxKey);

      final widget = _buildComponent(
        component,
        width,
        height,
        storedValue,
            (value) => dataBox.put(dataBoxKey, value),
      );

      return Positioned(
        top: top,
        left: left,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRect(child: widget),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  Widget _buildComponent(ComponentConfig component,
      double width,
      double height,
      dynamic storedValue,
      ValueChanged<dynamic> onChanged,) {
    final params = component.parameters;

    switch (component.type) {
      case 'volumetric_button':
        return BigNumberWidget(
          buttons: _intListParam(
              params, 'buttons', fallback: [1, 5, 10, -1, -5, -10]),
          xLength: width,
          yLength: height,
          text: component.alias,
          initialValue: _asInt(storedValue) ?? 0,
          onChanged: (value) => onChanged(value),
        );
      case 'int_button':
        return NumberButton(
          backgroundColor: _parseColor(params['color']) ?? Colors.white,
          dataName: component.alias,
          xLength: width,
          yLength: height,
          initialValue: _asInt(storedValue) ?? 0,
          negativeAllowed: _asBool(params['negative_allowed']) ?? false,
          onChanged: (value) => onChanged(value),
        );
      case 'toggle_switch':
      case 'checkbox':
        return BoolButton(
          dataName: component.alias,
          xLength: width,
          yLength: height,
          initialValue: _asBool(storedValue) ?? false,
          onChanged: (value) => onChanged(value),
          visualFeedback: true,
        );
      case 'text_box':
        return StringTextbox(
          dataName: component.alias,
          xLength: width,
          yLength: height,
          initialString: storedValue?.toString(),
          onChanged: (value) => onChanged(value),
        );
      case 'dropdown':
        final items = _stringListParam(params, 'items') ??
            _stringListParam(params, 'options') ??
            [component.alias];
        return Dropdown(
          title: component.alias,
          backgroundColor: _parseColor(params['color']) ?? Colors.white,
          items: items,
          initialIndex: _asInt(params['initial_index']),
          xValue: width,
          yValue: height,
          onChanged: (value) => onChanged(value ?? ''),
        );
      case 'tristate':
        return TristateButton(
          dataName: component.alias,
          xLength: width,
          yLength: height,
          initialState: _asInt(storedValue) ?? 0,
          onChanged: (value) => onChanged(value),
        );
      case 'slider':
        final minValue = _asInt(params['min']) ?? 0;
        final maxValue = _asInt(params['max']) ?? 10;
        final segment = _asInt(params['segment_length']);
        return CustomSlider(
          title: component.alias,
          xValue: width,
          yValue: height,
          minValue: minValue,
          maxValue: maxValue,
          segmentLength: segment,
          initialValue: _asDouble(storedValue) ?? minValue.toDouble(),
          onChanged: (value) => onChanged(value),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  MatchIdentity _identityFromSession(ScoutingSession session, int robotNum) {
    final position = session.position!;
    return (
    eventKey: session.event!.key,
    matchNumber: session.matchNumber!,
    isRedAlliance: position.isRed,
    position: position.allianceIndex,
    robotNum: robotNum,
    );
  }

  int _robotNumberForMatch(ScoutingMatch match, ScoutPosition position) {
    final teamNumber = match.teamNumberAt(position);
    return int.tryParse(teamNumber) ?? 0;
  }

  double _finiteOrFallback(double value, double fallback) {
    return value.isFinite ? value : fallback;
  }

  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is int) return Color(value);
    if (value is String) {
      final hex = value.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  List<String>? _stringListParam(Map<String, dynamic> params, String key) {
    final value = params[key];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  List<int> _intListParam(Map<String, dynamic> params,
      String key, {
        required List<int> fallback,
      }) {
    final value = params[key];
    if (value is List) {
      final parsed = value
          .map((e) => _asInt(e))
          .whereType<int>()
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }
    return fallback;
  }
}
