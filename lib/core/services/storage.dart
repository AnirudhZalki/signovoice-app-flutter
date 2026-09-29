import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple string key-value store for settings/flags.
abstract class KeyValueStore {
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  bool? getBool(String key) => _prefs.getBool(key);
  @override
  int? getInt(String key) => _prefs.getInt(key);
  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
  @override
  Future<void> clear() => _prefs.clear();
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _m = {};
  @override
  String? getString(String key) => _m[key] as String?;
  @override
  bool? getBool(String key) => _m[key] as bool?;
  @override
  int? getInt(String key) => _m[key] as int?;
  @override
  Future<void> setString(String key, String value) async => _m[key] = value;
  @override
  Future<void> setBool(String key, bool value) async => _m[key] = value;
  @override
  Future<void> setInt(String key, int value) async => _m[key] = value;
  @override
  Future<void> remove(String key) async => _m.remove(key);
  @override
  Future<void> clear() async => _m.clear();
}

/// Persists lists of JSON objects (history, progress, cached content).
/// Scales far better than SharedPreferences for thousands of records.
abstract class CollectionStore {
  Future<List<Map<String, dynamic>>> read(String name);
  Future<void> write(String name, List<Map<String, dynamic>> items);
  Future<void> delete(String name);
  Future<void> deleteAll();
}

class FileCollectionStore implements CollectionStore {
  Directory? _dir;

  Future<File> _file(String name) async {
    _dir ??= Directory('${(await getApplicationSupportDirectory()).path}/collections');
    if (!await _dir!.exists()) await _dir!.create(recursive: true);
    return File('${_dir!.path}/$name.json');
  }

  @override
  Future<List<Map<String, dynamic>>> read(String name) async {
    try {
      final f = await _file(name);
      if (!await f.exists()) return [];
      final decoded = jsonDecode(await f.readAsString());
      return (decoded as List).cast<Map<String, dynamic>>();
    } catch (_) {
      // Corrupt file: start fresh rather than crash.
      return [];
    }
  }

  @override
  Future<void> write(String name, List<Map<String, dynamic>> items) async {
    final f = await _file(name);
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode(items), flush: true);
    await tmp.rename(f.path);
  }

  @override
  Future<void> delete(String name) async {
    final f = await _file(name);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<void> deleteAll() async {
    final f = await _file('_');
    final d = f.parent;
    if (await d.exists()) await d.delete(recursive: true);
  }
}

class InMemoryCollectionStore implements CollectionStore {
  final Map<String, List<Map<String, dynamic>>> _m = {};
  @override
  Future<List<Map<String, dynamic>>> read(String name) async =>
      [for (final e in _m[name] ?? const <Map<String, dynamic>>[]) Map<String, dynamic>.from(e)];
  @override
  Future<void> write(String name, List<Map<String, dynamic>> items) async =>
      _m[name] = [for (final e in items) Map<String, dynamic>.from(e)];
  @override
  Future<void> delete(String name) async => _m.remove(name);
  @override
  Future<void> deleteAll() async => _m.clear();
}

/// Encrypted storage for tokens, profile snapshot and entitlement cache.
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? s]) : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  @override
  Future<String?> read(String key) async {
    try {
      return await _s.read(key: key);
    } catch (_) {
      return null; // keystore corruption after restore: treat as empty
    }
  }

  @override
  Future<void> write(String key, String value) => _s.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _s.delete(key: key);
  @override
  Future<void> deleteAll() => _s.deleteAll();
}

class InMemorySecureStore implements SecureStore {
  final Map<String, String> _m = {};
  @override
  Future<String?> read(String key) async => _m[key];
  @override
  Future<void> write(String key, String value) async => _m[key] = value;
  @override
  Future<void> delete(String key) async => _m.remove(key);
  @override
  Future<void> deleteAll() async => _m.clear();
}
