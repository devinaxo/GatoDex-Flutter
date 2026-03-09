class CatPhoto {
  final int id;
  final int catId;
  final String photoPath;
  final int displayOrder;
  final String? createdAt;

  CatPhoto({
    required this.id,
    required this.catId,
    required this.photoPath,
    required this.displayOrder,
    this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'cat_id': catId,
      'photo_path': photoPath,
      'display_order': displayOrder,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
    if (includeId && id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory CatPhoto.fromMap(Map<String, dynamic> map) {
    return CatPhoto(
      id: map['id'],
      catId: map['cat_id'],
      photoPath: map['photo_path'],
      displayOrder: map['display_order'] ?? 0,
      createdAt: map['created_at'],
    );
  }

  @override
  String toString() {
    return 'CatPhoto{id: $id, catId: $catId, photoPath: $photoPath, displayOrder: $displayOrder}';
  }
}
