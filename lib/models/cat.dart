import 'cat_photo.dart';

class Cat {
  final int id;
  final String name;
  final int breedId;
  final int? furPatternId;
  final double? latitude;
  final double? longitude;
  final String? dateMet;
  final List<String> aliases;
  final List<CatPhoto> photos;

  Cat({
    required this.id,
    required this.name,
    required this.breedId,
    this.furPatternId,
    this.latitude,
    this.longitude,
    this.dateMet,
    this.aliases = const [],
    this.photos = const [],
  });

  // Helper method to check if location is available
  bool get hasLocation => latitude != null && longitude != null;

  // Primary photo path (first photo or null)
  String? get primaryPhotoPath =>
      photos.isNotEmpty ? photos.first.photoPath : null;

  // Helper method to get coordinates as a formatted string
  String? get coordinatesString {
    if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return null;
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'name': name,
      'breed_id': breedId,
      'fur_pattern_id': furPatternId,
      'latitude': latitude,
      'longitude': longitude,
      'date_met': dateMet,
    };

    // Only include ID if it's not 0 and includeId is true
    if (includeId && id != 0) {
      map['id'] = id;
    }

    return map;
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    return Cat(
      id: map['id'],
      name: map['name'],
      breedId: map['breed_id'] ?? map['species_id'],
      furPatternId: map['fur_pattern_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      dateMet: map['date_met'],
    );
  }

  Cat copyWith({
    int? id,
    String? name,
    int? breedId,
    int? furPatternId,
    double? latitude,
    double? longitude,
    String? dateMet,
    List<String>? aliases,
    List<CatPhoto>? photos,
  }) {
    return Cat(
      id: id ?? this.id,
      name: name ?? this.name,
      breedId: breedId ?? this.breedId,
      furPatternId: furPatternId ?? this.furPatternId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateMet: dateMet ?? this.dateMet,
      aliases: aliases ?? this.aliases,
      photos: photos ?? this.photos,
    );
  }

  @override
  String toString() {
    return 'Cat{id: $id, name: $name, breedId: $breedId, furPatternId: $furPatternId, latitude: $latitude, longitude: $longitude, dateMet: $dateMet, aliases: $aliases, photos: ${photos.length}}';
  }
}
