import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Constructor for direct use without getInstance
  StorageService() {
    // This constructor is intentionally left empty
    // It's needed for direct dependency injection
  }

  // Initialize preferences if needed
  Future<void> _ensureInitialized() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Save data
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _preferences!.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _preferences!.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _preferences!.setBool(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _preferences!.setStringList(key, value);
  }
  
  // JSON verisini kaydet
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    return await _preferences!.setString(key, jsonEncode(value));
  }

  // Get data
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }
  
  // JSON verisini al
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _preferences?.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON parse error for key $key: $e');
      return null;
    }
  }

  // Remove data
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _preferences!.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    await _ensureInitialized();
    return await _preferences!.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  // Get all keys
  Set<String> getKeys() {
    return _preferences?.getKeys() ?? {};
  }
}
