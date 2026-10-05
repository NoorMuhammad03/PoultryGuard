import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diagnosis_history.dart';

class DiagnosisHistoryService {
  DiagnosisHistoryService._();

  static const String _storageKey = 'diagnosis_history';

  static Future<List<DiagnosisHistory>> getHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final storedHistory = preferences.getStringList(_storageKey) ?? [];

    final history = storedHistory.map((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;

      return DiagnosisHistory.fromJson(json);
    }).toList();

    history.sort(
      (first, second) => second.createdAt.compareTo(first.createdAt),
    );

    return history;
  }

  static Future<void> saveDiagnosis(DiagnosisHistory diagnosis) async {
    final preferences = await SharedPreferences.getInstance();
    final storedHistory = preferences.getStringList(_storageKey) ?? [];

    storedHistory.add(jsonEncode(diagnosis.toJson()));

    await preferences.setStringList(_storageKey, storedHistory);
  }

  static Future<void> deleteDiagnosis(DiagnosisHistory diagnosis) async {
    final preferences = await SharedPreferences.getInstance();
    final storedHistory = preferences.getStringList(_storageKey) ?? [];

    storedHistory.removeWhere((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      final storedDiagnosis = DiagnosisHistory.fromJson(json);

      return storedDiagnosis.id == diagnosis.id;
    });

    await preferences.setStringList(_storageKey, storedHistory);
  }

  static Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
