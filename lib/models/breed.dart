class Breed {
  final int id;
  final String name;
  final String? nameKey;

  Breed({
    required this.id,
    required this.name,
    this.nameKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_key': nameKey,
    };
  }

  factory Breed.fromMap(Map<String, dynamic> map) {
    return Breed(
      id: map['id'],
      name: map['name'],
      nameKey: map['name_key'],
    );
  }

  @override
  String toString() {
    return 'Breed{id: $id, name: $name, nameKey: $nameKey}';
  }
}
