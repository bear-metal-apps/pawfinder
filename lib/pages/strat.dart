import 'package:beariscope_scouter/store/strat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../providers/scouting_providers.dart';

class StratPage extends ConsumerStatefulWidget {
  const StratPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StratPageState();
  }
}

class StratPageState extends ConsumerState<StratPage> {
  @override
  void initState() {
    super.initState();
    // Reset undo/redo history when entering strat page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(stratUndoRedoProvider.notifier).clearHistory();
      }
    });
  }

  Column createList(
    String text,
    String storageKey,
    StratNotifier stratNotifier,
    List<String> items,
  ) {
    return Column(
      children: [
        Text(text, textScaler: TextScaler.linear(2)),

        SizedBox(
          width: 400,
          height: 160,
          child: ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              final oldList = stratNotifier.get().toList();
              setState(() => stratNotifier.reorder(oldIndex, newIndex));
              final newList = stratNotifier.get().toList();
              ref.read(stratUndoRedoProvider.notifier).trackChange(
                storageKey,
                oldList,
                newList,
              );
            },
            children: [
              for (final String item in items)
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    final driverSkill = ref.read(driverSkillProvider.notifier);
    final defensiveSkill = ref.read(defensiveSkillProvider.notifier);
    final mechanicalStability = ref.read(mechanicalStabilityProvider.notifier);
    final defensiveSusceptibility = ref.read(mechanicalStabilityProvider.notifier);
    final driverSkillItems = ref.watch(driverSkillProvider);
    final defensiveSkillItems = ref.watch(defensiveSkillProvider);
    final mechanicalStabilityItems = ref.watch(mechanicalStabilityProvider);
    final humanPlayer = ref.watch(humanPlayerProvider);
    final humanPlayerNotifier = ref.read(humanPlayerProvider.notifier);
    double defensiveSlider = 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(width: size.width),

                createList(
                  "Driver Skill",
                  'driverSkill',
                  driverSkill,
                  driverSkillItems,
                ),
                createList(
                  "Defensive Susceptibility",
                  'defensiveskill',
                  defensiveSusceptibility,
                  mechanicalStabilityItems,
                ),
                createList(
                  "Defensive Skill",
                  'defensiveskill',
                  defensiveSkill,
                  defensiveSkillItems,
                ),
                SfSlider(
                  min: 0.0,
                  max: 10,
                  value: defensiveSlider,
                  onChanged: (value) {
                    setState(() => defensiveSlider = value);
                  },
                  interval: 1.0,
                  showTicks: true,
                  showLabels: true,
                ),
                createList(
                  "Mechanical Stability",
                  'mechanicalStability',
                  mechanicalStability,
                  mechanicalStabilityItems,
                ),

                ElevatedButton(
                  onPressed: () {
                    final oldValue = humanPlayer;
                    humanPlayerNotifier.set(humanPlayer + 1);
                    ref.read(stratUndoRedoProvider.notifier).trackChange(
                      'humanPlayer',
                      oldValue,
                      humanPlayer + 1,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                          'Human Player: $humanPlayer',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 56,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove, color: Colors.black),
                            onPressed: () {
                              final oldValue = humanPlayer;
                              if (humanPlayer > 0) {
                                humanPlayerNotifier.set(humanPlayer - 1);
                              }
                              ref.read(stratUndoRedoProvider.notifier).trackChange(
                                'humanPlayer',
                                oldValue,
                                humanPlayer > 0 ? humanPlayer - 1 : humanPlayer,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: (){
                  ref.read(scoutingSessionProvider.notifier).nextMatch();
                },
                child: Text("Next Match")
            )
          ],
        ),
      ),
    );
  }
}
