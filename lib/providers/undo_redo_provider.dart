import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_ce/hive.dart';
import '../data/local_data.dart';

/// Represents a snapshot of state at a point in time
class HistorySnapshot {
  final Map<String, dynamic> state;
          
  HistorySnapshot(this.state);

  /// Create a deep copy of the snapshot
  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.from(state);
  }
}

/// Base class for undo/redo history management
class UndoRedoNotifier extends StateNotifier<UndoRedoState> {
  final List<HistorySnapshot> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;
  final Box dataBox;
  
  Timer? _debounceTimer;

  UndoRedoNotifier(this.dataBox, {this.maxHistorySize = 50})
      : super(
          UndoRedoState(
            canUndo: false,
            canRedo: false,
          ),
        ) {
    _pushSnapshot(_captureCurrentState());
  }

  Map<String, dynamic> _captureCurrentState() {
    final Map<String, dynamic> snapshot = {};
    for (final key in dataBox.keys) {
      snapshot[key] = dataBox.get(key);
    }
    return snapshot;
  }

  void _pushSnapshot(Map<String, dynamic> newState) {
    // Remove any redo history if we make a new change
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Add new snapshot (make a deep copy)
    _history.add(HistorySnapshot(Map<String, dynamic>.from(newState)));
    _currentIndex = _history.length - 1;

    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }

    _updateState();
  }

  void _updateState() {
    state = UndoRedoState(
      canUndo: _currentIndex > 0,
      canRedo: _currentIndex < _history.length - 1,
    );
  }

  void recordSnapshot() {
    _debounceTimer?.cancel();
    _pushSnapshot(_captureCurrentState());
  }

  bool get canUndo => state.canUndo;
  bool get canRedo => state.canRedo;

  void undo() {
    if (canUndo) {
      _currentIndex--;
      _restoreSnapshot(_history[_currentIndex].state);
      _updateState();
    }
  }

  void redo() {
    if (canRedo) {
      _currentIndex++;
      _restoreSnapshot(_history[_currentIndex].state);
      _updateState();
    }
  }

  void _restoreSnapshot(Map<String, dynamic> snapshot) {
    // Clear current state
    for (final key in dataBox.keys.toList()) {
      dataBox.delete(key);
    }
    // Restore snapshot
    for (final entry in snapshot.entries) {
      dataBox.put(entry.key, entry.value);
    }
  }

  void clearHistory() {
    _debounceTimer?.cancel();
    _history.clear();
    _currentIndex = -1;
    _pushSnapshot(_captureCurrentState());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class UndoRedoState {
  final bool canUndo;
  final bool canRedo;

  UndoRedoState({
    required this.canUndo,
    required this.canRedo,
  });
}

/// Provider for match page undo/redo (auto, tele, endgame)
final matchUndoRedoProvider =
    StateNotifierProvider<UndoRedoNotifier, UndoRedoState>((ref) {
  final dataBox = Hive.box(boxKey);
  return UndoRedoNotifier(dataBox, maxHistorySize: 100);
});

/// Provider for strat page undo/redo
final stratUndoRedoProvider =
    StateNotifierProvider<UndoRedoNotifier, UndoRedoState>((ref) {
  final dataBox = Hive.box(boxKey);
  return UndoRedoNotifier(dataBox, maxHistorySize: 50);
});
