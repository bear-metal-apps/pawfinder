import 'package:flutter/material.dart';

abstract class ActionCommand {
  void execute();
  void undo();
}

class UndoRedoManager extends ChangeNotifier {
  final List<ActionCommand> _undoStack = [];
  final List<ActionCommand> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void execute(ActionCommand command) {
    command.execute();
    _undoStack.add(command);
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (canUndo) {
      final command = _undoStack.removeLast();
      command.undo();
      _redoStack.add(command);
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      final command = _redoStack.removeLast();
      command.execute();
      _undoStack.add(command);
      notifyListeners();
    }
  }
}