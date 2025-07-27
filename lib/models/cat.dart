class Cat {
  final int id;
  final String name;
  final int speciesId;
  final int? furPatternId;
  final double? latitude;
  final double? longitude;
  final String? dateMet;
  final String? picturePath;

  Cat({
    required this.id,
    required this.name,
    required this.speciesId,
    this.furPatternId,
    this.latitude,
    this.longitude,
    this.dateMet,
    this.picturePath,
  });

  // Helper method to check if location is available
  bool get hasLocation => latitude != null && longitude != null;

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
      'species_id': speciesId,
      'fur_pattern_id': furPatternId,
      'latitude': latitude,
      'longitude': longitude,
      'date_met': dateMet,
      'picture_path': picturePath,
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
      speciesId: map['species_id'],
      furPatternId: map['fur_pattern_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      dateMet: map['date_met'],
      picturePath: map['picture_path'],
    );
  }

  @override
  String toString() {
    return 'Cat{id: $id, name: $name, speciesId: $speciesId, furPatternId: $furPatternId, latitude: $latitude, longitude: $longitude, dateMet: $dateMet, picturePath: $picturePath}';
  }
}
