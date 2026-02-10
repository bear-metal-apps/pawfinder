import 'package:flutter/material.dart';

abstract class ActionCommand {
  void execute();
  void undo();
  /// Called when the command is no longer valid (e.g. widget disposed).
  void cancel() {}
}

class PropertyChangeCommand<T> extends ActionCommand {
  final Function(T) setter;
  final T newValue;
  final T oldValue;
  bool _active = true;

  PropertyChangeCommand({
    required this.setter,
    required this.newValue,
    required this.oldValue,
  });

  @override
  void execute() {
    if (_active) setter(newValue);
  }

  @override
  void undo() {
    if (_active) setter(oldValue);
  }

  @override
  void cancel() {
    _active = false;
  }
}
enum MatchPhase { auto, tele, end }

class UndoRedoManager extends ChangeNotifier {
  // Singleton implementation so every part of the app shares the same manager
  static final UndoRedoManager _instance = UndoRedoManager._internal();
  factory UndoRedoManager() => _instance;
  UndoRedoManager._internal();

  final Map<MatchPhase, List<ActionCommand>> _undoStacks = {
    MatchPhase.auto: [],
    MatchPhase.tele: [],
    MatchPhase.end: [],
  };

  final Map<MatchPhase, List<ActionCommand>> _redoStacks = {
    MatchPhase.auto: [],
    MatchPhase.tele: [],
    MatchPhase.end: [],
  };

  MatchPhase _active = MatchPhase.auto;

  MatchPhase get activePhase => _active;

  void setActivePhase(MatchPhase p) {
    if (_active == p) return;
    _active = p;
    // Defer notifying listeners until after the current frame to avoid
    // causing setState/markNeedsBuild during widget build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  bool get canUndo => _undoStacks[_active]!.isNotEmpty;
  bool get canRedo => _redoStacks[_active]!.isNotEmpty;

  void execute(ActionCommand command) {
    try {
      command.execute();
      _undoStacks[_active]!.add(command);
      _redoStacks[_active]!.clear();
      notifyListeners();
    } catch (e, st) {
        final information = <DiagnosticsNode>[
        ErrorSummary('Exception while executing command'),
        ErrorDescription('Command: ${command.runtimeType}'),
        ErrorDescription('Exception: $e'),
        ErrorDescription('StackTrace:\n$st'),
      ];
      // mark command cancelled to avoid later calls
      try {
        command.cancel();
      } catch (_) {}
      throw FlutterError.fromParts(information);
    }
  }

  void undo() {
    final stack = _undoStacks[_active]!;
    if (stack.isNotEmpty) {
      final command = stack.removeLast();
      try {
        command.undo();
        _redoStacks[_active]!.add(command);
        notifyListeners();
      } catch (e, st) {
        final information = <DiagnosticsNode>[
          ErrorSummary('Exception while undoing command'),
          ErrorDescription('Command: ${command.runtimeType}'),
          ErrorDescription('Exception: $e'),
          ErrorDescription('StackTrace:\n$st'),
        ];
        // Cancel to prevent later execution against disposed widgets
        try {
          command.cancel();
        } catch (_) {}
        throw FlutterError.fromParts(information);
      }
    }
  }

  void redo() {
    final stack = _redoStacks[_active]!;
    if (stack.isNotEmpty) {
      final command = stack.removeLast();
      try {
        command.execute();
        _undoStacks[_active]!.add(command);
        notifyListeners();
      } catch (e, st) {
        final information = <DiagnosticsNode>[
          ErrorSummary('Exception while redoing command'),
          ErrorDescription('Command: ${command.runtimeType}'),
          ErrorDescription('Exception: $e'),
          ErrorDescription('StackTrace:\n$st'),
        ];
        try {
          command.cancel();
        } catch (_) {}
        throw FlutterError.fromParts(information);
      }
    }
  }

  /// Clear undo/redo for the active phase.
  void clearActivePhase() {
    for (final c in _undoStacks[_active]!) {
      c.cancel();
    }
    for (final c in _redoStacks[_active]!) {
      c.cancel();
    }
    _undoStacks[_active]!.clear();
    _redoStacks[_active]!.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  /// Clear all phases.
  void clearAll() {
    for (final p in MatchPhase.values) {
      for (final c in _undoStacks[p]!) {
        c.cancel();
      }
      for (final c in _redoStacks[p]!) {
        c.cancel();
      }
      _undoStacks[p]!.clear();
      _redoStacks[p]!.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}