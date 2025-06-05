import 'level.dart';
import 'level_attempt.dart';
import 'level_progress.dart';

class LevelWithProgress {
  final Level level;
  final LevelProgress progress;
  final List<LevelAttempt> attempts;

  LevelWithProgress({
    required this.level,
    required this.progress,
    required this.attempts,
  });

  factory LevelWithProgress.fromMap(Map<String, dynamic> map) {
    final levelMap = map['level'] as Map<String, dynamic>? ?? {};
    final progressMap = map['progress'] as Map<String, dynamic>? ?? {};
    final attemptsList = map['attempts'] as List<dynamic>? ?? [];

    return LevelWithProgress(
      level: Level.fromMap(levelMap),
      progress: LevelProgress.fromMap(progressMap),
      attempts: attemptsList
          .map((attemptMap) => LevelAttempt.fromMap(attemptMap))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level.toMap(),
      'progress': progress.toMap(),
      'attempts': attempts.map((a) => a.toMap()).toList(),
    };
  }
}
