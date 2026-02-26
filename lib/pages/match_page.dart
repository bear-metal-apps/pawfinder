import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/match_widgets/2026_specifc/big_number.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/segmented_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/tristate.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

import '../data/ui_json_serialization.dart';
import '../providers/scouting_providers.dart';

Box dataBox = Hive.box(boxKey);

Future<Map<String, dynamic>> loadUiConfig() async {
  final jsonString = await rootBundle.loadString('resources/ui_creator.json');
  return jsonDecode(jsonString);
}

// MatchIdentity currentMatchIdentity = (eventKey: "eventKey", matchNumber: 0, isRedAlliance: false, position: 0, robotNum: 0);
// class matchPagesProvider extends ChangeNotifier {
//
// }
final matchPagesProvider =
    AsyncNotifierProvider<MatchPagesNotifier, List<List<Widget>>>(
      MatchPagesNotifier.new,
    );

class MatchPagesNotifier extends AsyncNotifier<List<List<Widget>>> {
  String _buildDataKey(String fieldId) {
    final session = ref.read(scoutingSessionProvider);
    final eventKey = session.event?.key ?? 'unknown_event';
    final matchNumber = session.matchNumber?.toString() ?? 'unknown_match';
    final positionKey = session.position?.name ?? 'unknown_position';
    return 'MATCH_${eventKey}_${matchNumber}_${positionKey}_$fieldId';
  }

  void _trackAndUpdateValue(String dataBoxKey, dynamic newValue) {
    final oldValue = dataBox.get(dataBoxKey);
    debugPrint('[TRACK_VALUE] $dataBoxKey: $oldValue → $newValue');
    dataBox.put(dataBoxKey, newValue);
    ref.read(undoRedoProvider.notifier).trackChange(dataBoxKey, oldValue, newValue);
  }

  @override
  Future<List<List<Widget>>> build() async {
    // Provider starts empty until load() is called
    return [];
  }

  Future<void> loadUI(BuildContext context) async {
    await _buildPages(context, resetHistory: true, showLoading: true);
  }

  Future<void> refreshUI(BuildContext context) async {
    debugPrint('[REFRESH] Starting refresh UI');
    await _buildPages(context, resetHistory: false, showLoading: false);
    debugPrint('[REFRESH] Refresh UI complete');
  }

  Future<void> _buildPages(
    BuildContext context, {
    required bool resetHistory,
    required bool showLoading,
  }) async {
    debugPrint('[BUILD] Starting build pages. resetHistory=$resetHistory');
    if (showLoading) {
      state = const AsyncLoading();
    }
    if (resetHistory) {
      // Clear undo/redo history when loading a new page
      ref.read(undoRedoProvider.notifier).clearHistory();
    }

    state = await AsyncValue.guard(() async {
      debugPrint('[BUILD] Building widgets from Hive');
      final mediaQuery = MediaQuery.of(context);
      final ultimateHeight = mediaQuery.size.height;
      final ultimateWidth = mediaQuery.size.width;

      final json = jsonDecode(
        await rootBundle.loadString('resources/ui_creator.json'),
      );

      final pages = MatchConfig.fromJson(json).pages;
      final List<List<Widget>> matchPages = [];

      for (int index = 0; index < pages.length; index++) {
        matchPages.add([]);

        final page = pages[index];
        final horizontalStep = ultimateWidth / page.width;
        final verticalStep = (ultimateHeight - 130) / page.height;

        for (final data in page.components) {
          final dataBoxKey = _buildDataKey(data.fieldId);
          final storedValue = dataBox.get(dataBoxKey);
          // Include value in key so widget recreates when value changes
          final widgetKey = ValueKey('${dataBoxKey}_${storedValue ?? "null"}');
          debugPrint('[BUILD_WIDGET] ${data.fieldId} = $storedValue (key: ${widgetKey.value})');

          Widget widget;
          try {
            switch (data.type) {
            case 'volumetric_button':
              widget = BigNumberWidget(
                key: widgetKey,
                buttons: [
                  1, 5, -1, -5,
                ],
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                text: data.alias,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
              );
              break;
            case "int_button":
              widget = NumberButton(
                key: widgetKey,
                backgroundColor: Colors.white,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
              );
              break;
            case "int_text_box":
              widget = IntTextbox(
                key: widgetKey,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
              );
              break;
            case "toggle_switch":
              widget = BoolButton(
                key: widgetKey,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
                visualFeedback: true,
              );
              break;

            case "text_box":
              widget = StringTextbox(
                key: widgetKey,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialString: storedValue is String ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
              );
              break;

            case "dropdown":
            List<dynamic> items = data.parameters["options"];
            int? initialIndex;
            if (items.isNotEmpty && storedValue != null) {
              final idx = items.indexOf(storedValue);
              // Only set initialIndex if the item was found
              if (idx >= 0) {
                initialIndex = idx;
              }
            }

              widget = Dropdown(
                key: widgetKey,
                title: data.alias,
                backgroundColor: Colors.blueAccent,
                items: items.isEmpty ? ['No options'] : items.map((x) => x.toString()).toList(),
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
                initialIndex: initialIndex,
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
              );
              break;
            case "tristate":
              widget = TristateButton(
                key: widgetKey,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialState: storedValue is int ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
              );
              break;
            case "checkbox":
              widget = BoolButton(
                key: widgetKey,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                visualFeedback: true,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
              );
              break;
            case "slider":
              // Ensure slider value is within valid range
              double? sliderValue = null;
              if (storedValue is num) {
                final numValue = storedValue.toDouble();
                // Clamp to valid range
                if (numValue >= 0 && numValue <= 10) {
                  sliderValue = numValue;
                }
              }
              widget = CustomSlider(
                key: widgetKey,
                onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
                title: data.alias,
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
                minValue: 0,
                maxValue: 10,
                initialValue: sliderValue,
              );
              break;
            case "segmented_button":
              List<dynamic> items = data.parameters["options"] ?? [];
              int? initialIndex;
              if (items.isNotEmpty) {
                if (storedValue is int) {
                  // Ensure index is within bounds
                  if (storedValue >= 0 && storedValue < items.length) {
                    initialIndex = storedValue;
                  }
                } else if (storedValue is String) {
                  final idx = items.indexOf(storedValue);
                  if (idx >= 0) {
                    initialIndex = idx;
                  }
                }
              }
              // Default to empty list representation if no items
              final segmentItems = items.isEmpty ? ['No options'] : items.map((x) => x.toString()).toList();
              widget = CustomSegmentedButton(
                  key: widgetKey,
                  segments: segmentItems,
                  onChanged: (value) => _trackAndUpdateValue(dataBoxKey, value),
                  initialIndex: initialIndex,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep
              );
              break;
            case "Nxt":
              widget = SizedBox(
                  height: data.layout.h * verticalStep,
                  width: data.layout.w * horizontalStep,
                  child: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: (){
                        ref.read(scoutingSessionProvider.notifier).nextMatch();
                        ctx.go('/match/auto');
                      },
                      child: Text("Next Match")
                    )
                  )
              );
              break;
            default:
              continue;
            }
          } catch (e) {
            // If widget creation fails, skip this component
            debugPrint('Error creating widget for ${data.fieldId}: $e');
            continue;
          }
          matchPages[index].add(
            Positioned(
              top: data.layout.y * verticalStep,
              left: data.layout.x * horizontalStep,
              child: widget,
            ),
          );
        }
      }
      return matchPages;
    });
  }
}

class MatchPage extends ConsumerStatefulWidget {
  final index;

  const MatchPage({super.key, required this.index});

  @override
  ConsumerState<MatchPage> createState() => MatchPageState();
}

class MatchPageState extends ConsumerState<MatchPage> {
  @override
  void initState() {
    super.initState();
    // Load UI immediately when page mounts to ensure widgets are initialized
    // with the current scouting session (don't wait for a change)
    Future.microtask(() {
      if (mounted) {
        ref.read(matchPagesProvider.notifier).loadUI(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScoutingSession>(
      scoutingSessionProvider,
      (previous, next) {
        final prevEvent = previous?.event?.key;
        final nextEvent = next.event?.key;
        final prevPos = previous?.position?.name;
        final nextPos = next.position?.name;
        if (prevEvent != nextEvent ||
            prevPos != nextPos ||
            previous?.matchNumber != next.matchNumber) {
          if (!mounted) return;
          ref.read(matchPagesProvider.notifier).loadUI(context);
        }
      },
    );
    final pagesAsync = ref.watch(matchPagesProvider);

    return pagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      data: (pages) {
        if (pages.isEmpty) {
          return const Center(child: Text('No pages loaded'));
        }
        if (widget.index >= pages.length) {
          return Center(child: Text('Invalid page index: ${widget.index}'));
        }
        return Stack(children: pages[widget.index]);
      },
    );
  }
}

// Box dataBox = Hive.box(boxKey);
// MatchIdentity currentMatchIdentity = (eventKey: "eventKey", matchNumber: 0, isRedAlliance: false, position: 0, robotNum: 0);
