import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

class LocalCacheService {
  final Directory _cacheDir;

  LocalCacheService._(this._cacheDir);

  static Future<LocalCacheService> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/app_cache');
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    return LocalCacheService._(cacheDir);
  }

  File _fileFor(String key) => File('${_cacheDir.path}/$key.json');

  /// Read cached data. Returns null if missing or corrupt.
  Future<T?> read<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final file = _fileFor(key);
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      return fromJson(wrapper['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Read a cached list. Returns null if missing or corrupt.
  Future<List<T>?> readList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final file = _fileFor(key);
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final list = wrapper['data'] as List<dynamic>;
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Write a single object to cache.
  Future<void> write(String key, Map<String, dynamic> data) async {
    final wrapper = {
      'cachedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    };
    await _fileFor(key).writeAsString(jsonEncode(wrapper));
  }

  /// Write a list to cache.
  Future<void> writeList(String key, List<Map<String, dynamic>> data) async {
    final wrapper = {
      'cachedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    };
    await _fileFor(key).writeAsString(jsonEncode(wrapper));
  }

  /// Delete a cache entry.
  Future<void> delete(String key) async {
    final file = _fileFor(key);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
