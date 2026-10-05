class Flock {
  const Flock({
    required this.id,
    required this.farmId,
    required this.name,
    required this.breed,
    required this.startDate,
    required this.initialBirdCount,
    required this.currentBirdCount,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String farmId;
  final String name;
  final String breed;
  final DateTime startDate;
  final int initialBirdCount;
  final int currentBirdCount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Flock.fromJson(Map<String, dynamic> json) {
    return Flock(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      initialBirdCount: json['initial_bird_count'] as int,
      currentBirdCount: json['current_bird_count'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
