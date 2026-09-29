import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage.dart';
import '../domain/sign_dictionary.dart';

/// Where sign data comes from. The bundled pack always works offline; a remote
/// pack (thousands of signs, https media URLs) can supersede it when newer.
abstract class SignAssetRepository {
  Future<SignDictionary> load();

  /// Best-effort refresh of the remote pack. Returns true if a newer pack was stored.
  Future<bool> sync();
}

class BundledSignAssetRepository implements SignAssetRepository {
  BundledSignAssetRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  @override
  Future<SignDictionary> load() async {
    try {
      final raw = await _bundle.loadString('assets/data/sign_dictionary.json');
      return SignDictionary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw const Failure(FailureType.unknown, debugDetail: 'bundled dictionary unreadable');
    }
  }

  @override
  Future<bool> sync() async => false;
}

/// Bundled pack + optional remote pack cached on disk (offline after first sync).
/// Contract: GET /v1/dictionary → same JSON schema as the bundled file.
class CachedRemoteSignAssetRepository implements SignAssetRepository {
  CachedRemoteSignAssetRepository({required this.bundled, required this.api, required this.store});
  final SignAssetRepository bundled;
  final ApiClient api;
  final CollectionStore store;
  static const _name = 'dictionary_pack';

  @override
  Future<SignDictionary> load() async {
    final base = await bundled.load();
    try {
      final rows = await store.read(_name);
      if (rows.isNotEmpty) {
        final cached = SignDictionary.fromJson(rows.first);
        if (cached.version > base.version) return cached;
      }
    } catch (_) {/* corrupt cache: ignore, use bundled */}
    return base;
  }

  @override
  Future<bool> sync() async {
    if (!api.isConfigured) return false;
    try {
      final current = await load();
      final data = await api.get('/v1/dictionary', query: {'since': current.version});
      if (data is! Map<String, dynamic>) return false;
      final remote = SignDictionary.fromJson(data);
      if (remote.version <= current.version || remote.entries.isEmpty) return false;
      await store.write(_name, [data]);
      return true;
    } catch (e) {
      final f = toFailure(e);
      if (f.type == FailureType.offline) return false;
      return false;
    }
  }
}
