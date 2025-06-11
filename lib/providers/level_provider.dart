import 'package:flutter/material.dart';
import '../models/level_attempt.dart';
import '../utils/enums.dart';
import '../models/level_with_progress.dart';

class LevelProvider with ChangeNotifier {
  List<LevelWithProgress> _levelsWithProgress = [];

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

  void addAttemptToLevel(String progressId, LevelAttempt newAttempt) {
    final index = _levelsWithProgress.indexWhere((lwp) => lwp.progress.id == progressId);
    if (index != -1) {
      _levelsWithProgress[index].attempts.add(newAttempt);
      notifyListeners();
    }
  }
}
