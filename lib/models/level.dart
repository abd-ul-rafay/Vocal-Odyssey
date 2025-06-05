import '../utils/enums.dart';

class Level {
  final String _id;
  final String name;
  final String description;
  final int idealTime;
  final ContentType type;
  final List<String> content;

  Level(
      this._id, {
        required this.name,
        required this.description,
        required this.idealTime,
        required this.type,
        required this.content,
      });

  String get id => _id;

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      map['_id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      idealTime: map['ideal_time'] ?? 0,
      type: ContentType.values.firstWhere(
            (e) => e.name == (map['level_type'] ?? '').toLowerCase(),
        orElse: () => ContentType.phonics,
      ),
      content: List<String>.from(map['content'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'name': name,
      'description': description,
      'idealTime': idealTime,
      'type': type.name,
      'content': content,
    };
  }
}
