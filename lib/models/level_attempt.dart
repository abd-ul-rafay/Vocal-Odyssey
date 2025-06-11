
class LevelAttempt {
  final String _id;
  final int score;
  final Map<String, int> mistakesCount;
  final double stars;

  LevelAttempt(
      this._id, {
        required this.score,
        required this.mistakesCount,
        required this.stars,
      });

  String get id => _id;

  int getTotalMistakes() {
    return mistakesCount.values.fold(0, (sum, count) => sum + count);
  }

  factory LevelAttempt.fromMap(Map<String, dynamic> map) {
    return LevelAttempt(
      map['_id'],
      score: map['score'] ?? 0,
      mistakesCount: Map<String, int>.from(map['mistakes_counts'] ?? {}),
      stars: (map['stars'] != null)
          ? (map['stars'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'score': score,
      'mistakes_counts': mistakesCount,
      'stars': stars,
    };
  }
}