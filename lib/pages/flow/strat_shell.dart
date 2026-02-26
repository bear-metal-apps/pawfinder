import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:beariscope_scouter/store/strat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StratShell extends ConsumerWidget {
  final Widget child;

  const StratShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final matchNumber = session.matchNumber ?? 0;
    final stratUndoRedoState = ref.watch(stratUndoRedoProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Exit to Scout Selection',
          onPressed: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Scouting'),
                content: const Text(
                  'Are you sure you want to exit this match?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            if (shouldExit ?? false) {
              notifier.exitToScoutSelect();
              if (context.mounted) {
                context.go('/scout');
              }
            }
          },
        ),
        title: Row(
          children: [
            Text('Match $matchNumber'),
            const VerticalDivider(),
            Text(session.position?.displayName ?? 'Strategy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: stratUndoRedoState.undoStack.isEmpty
                ? null
                : () async {
                    try {
                      ref.read(stratUndoRedoProvider.notifier).undo();
                      await Future.delayed(const Duration(milliseconds: 50));
                      // Invalidate all strat providers to force rebuild
                      ref.invalidate(driverSkillProvider);
                      ref.invalidate(defensiveSkillProvider);
                      ref.invalidate(mechanicalStabilityProvider);
                      ref.invalidate(humanPlayerProvider);
                    } catch (e) {
                      debugPrint('Strat undo error: $e');
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: stratUndoRedoState.redoStack.isEmpty
                ? null
                : () async {
                    try {
                      ref.read(stratUndoRedoProvider.notifier).redo();
                      await Future.delayed(const Duration(milliseconds: 50));
                      // Invalidate all strat providers to force rebuild
                      ref.invalidate(driverSkillProvider);
                      ref.invalidate(defensiveSkillProvider);
                      ref.invalidate(mechanicalStabilityProvider);
                      ref.invalidate(humanPlayerProvider);
                    } catch (e) {
                      debugPrint('Strat redo error: $e');
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: 'Previous Match',
            onPressed: matchNumber > 1 ? () => notifier.previousMatch() : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next Match',
            onPressed: () => notifier.nextMatch(),
          ),
        ],
      ),
      body: child,
    );
  }
}
