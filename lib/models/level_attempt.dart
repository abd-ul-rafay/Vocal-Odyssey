
class LevelAttempt {
  final String _id;
  final int timeTaken;
  final Map<String, int> mistakesCount;
  final double stars;

  LevelAttempt(
      this._id, {
        required this.timeTaken,
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
      timeTaken: map['time_taken'] ?? 0,
      mistakesCount: Map<String, int>.from(map['mistakes_counts'] ?? {}),
      stars: (map['stars'] != null)
          ? (map['stars'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'time_taken': timeTaken,
      'mistakes_counts': mistakesCount,
      'stars': stars,
    };
  }
}