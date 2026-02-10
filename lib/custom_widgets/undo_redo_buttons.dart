import 'package:flutter/material.dart';
import 'package:beariscope_scouter/custom_widgets/undo_redo.dart';

class UndoRedoButtons extends StatelessWidget {
  final UndoRedoManager manager;

  const UndoRedoButtons({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: manager.canUndo ? () => manager.undo() : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: manager.canRedo ? () => manager.redo() : null,
            ),
          ],
        );
      },
    );
  }
}