class User {
  final String _id;
  final String name;

  User(
      this._id, {
        required this.name,
      });

  String get id => _id;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['_id'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
