import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../models/level_with_progress.dart';

class LevelProvider with ChangeNotifier {
  List<LevelWithProgress> _levelsWithProgress = [];
  int _selectedLevelIndex = -1;

  List<LevelWithProgress> get levelsWithProgress => _levelsWithProgress;

  void setLevels(List<LevelWithProgress> levelsWithProgress) {
    _levelsWithProgress = levelsWithProgress;
    notifyListeners();
  }

  List<LevelWithProgress> getLevelsByType(ContentType type) {
    return _levelsWithProgress
        .where((lwp) => lwp.level.type == type)
        .toList();
  }

  void setSelectedLevel(int index) {
    _selectedLevelIndex = index;
    notifyListeners();
  }

  LevelWithProgress? getSelectedLevel() {
    if (_selectedLevelIndex >= 0 &&
        _selectedLevelIndex < _levelsWithProgress.length) {
      return _levelsWithProgress[_selectedLevelIndex];
    }
    return null;
  }
}
