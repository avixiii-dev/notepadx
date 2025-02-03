class HistoryState {
  final String content;
  final int cursorPosition;

  const HistoryState({
    required this.content,
    required this.cursorPosition,
  });
}

class HistoryService {
  final List<HistoryState> _undoStack = [];
  final List<HistoryState> _redoStack = [];
  static const int maxStackSize = 1000; // Maximum number of undo/redo states

  void pushState(HistoryState state) {
    _undoStack.add(state);
    _redoStack.clear(); // Clear redo stack when new state is added

    // Limit stack size
    if (_undoStack.length > maxStackSize) {
      _undoStack.removeAt(0);
    }
  }

  HistoryState? undo(HistoryState currentState) {
    if (_undoStack.isEmpty) return null;

    // Save current state to redo stack
    _redoStack.add(currentState);

    // Pop and return last state from undo stack
    final state = _undoStack.removeLast();
    return state;
  }

  HistoryState? redo(HistoryState currentState) {
    if (_redoStack.isEmpty) return null;

    // Save current state to undo stack
    _undoStack.add(currentState);

    // Pop and return last state from redo stack
    final state = _redoStack.removeLast();
    return state;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
}
