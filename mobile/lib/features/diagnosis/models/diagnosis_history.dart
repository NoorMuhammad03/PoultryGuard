class DiagnosisHistory {
  const DiagnosisHistory({
    required this.id,
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String label;
  final double confidence;
  final DateTime createdAt;

  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'label': label,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DiagnosisHistory.fromJson(Map<String, dynamic> json) {
    return DiagnosisHistory(
      id: json['id'] as String,
      imagePath: json['image_path'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
