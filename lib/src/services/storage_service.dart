import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/meat_sample.dart';

/// Local storage service for training samples
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize storage
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save training samples
  Future<void> saveSamples(List<MeatSample> samples) async {
    await initialize();
    final jsonList = samples.map((s) => s.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(AppConstants.samplesKey, jsonString);
  }

  /// Load training samples
  Future<List<MeatSample>> loadSamples() async {
    await initialize();
    final jsonString = _prefs!.getString(AppConstants.samplesKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MeatSample.fromJson(json)).toList();
  }

  /// Add a new sample
  Future<void> addSample(MeatSample sample) async {
    final samples = await loadSamples();
    samples.add(sample);
    await saveSamples(samples);
  }

  /// Clear all samples
  Future<void> clearSamples() async {
    await initialize();
    await _prefs!.remove(AppConstants.samplesKey);
  }

  /// Get model version
  Future<String?> getModelVersion() async {
    await initialize();
    return _prefs!.getString(AppConstants.modelVersionKey);
  }

  /// Set model version
  Future<void> setModelVersion(String version) async {
    await initialize();
    await _prefs!.setString(AppConstants.modelVersionKey, version);
  }
}
