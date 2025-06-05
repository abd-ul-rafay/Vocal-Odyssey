import 'package:vocal_odyssey/models/level_attempt.dart';

class LevelProgress {
  final String _id;
  final String childId;
  final String levelId;
  List<LevelAttempt> attempts = [];

  LevelProgress(
      this._id, {
        required this.childId,
        required this.levelId,
        List<LevelAttempt>? attempts,
      }) {
    this.attempts = attempts ?? [];
  }

  String get id => _id;

  factory LevelProgress.fromMap(Map<String, dynamic> map) {
    return LevelProgress(
      map['_id'],
      childId: map['childId'] ?? '',
      levelId: map['levelId'] ?? '',
      attempts: map['attempts'] != null
          ? List<LevelAttempt>.from(
          (map['attempts'] as List).map((x) => LevelAttempt.fromMap(x)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'childId': childId,
      'levelId': levelId,
      'attempts': attempts.map((x) => x.toMap()).toList(),
    };
  }
}

