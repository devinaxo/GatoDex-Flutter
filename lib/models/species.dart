class Species {
  final int id;
  final String name;

  Species({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Species.fromMap(Map<String, dynamic> map) {
    return Species(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  String toString() {
    return 'Species{id: $id, name: $name}';
  }
}
