class FurPattern {
  final int id;
  final String name;

  FurPattern({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory FurPattern.fromMap(Map<String, dynamic> map) {
    return FurPattern(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  String toString() {
    return 'FurPattern{id: $id, name: $name}';
  }
}
