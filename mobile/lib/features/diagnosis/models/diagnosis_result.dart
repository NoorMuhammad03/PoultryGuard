class DiagnosisResult {
  const DiagnosisResult({
    required this.label,
    required this.confidence,
    required this.imagePath,
  });

  final String label;
  final double confidence;
  final String imagePath;

  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}
