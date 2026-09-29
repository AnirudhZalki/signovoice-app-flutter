import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/sign_asset_repository.dart';
import '../domain/sign_dictionary.dart';

final signAssetRepositoryProvider = Provider<SignAssetRepository>((ref) => CachedRemoteSignAssetRepository(
      bundled: BundledSignAssetRepository(),
      api: ref.watch(apiClientProvider),
      store: ref.watch(collectionStoreProvider),
    ));

/// The dictionary (bundled pack, or a newer cached remote pack). Refreshes the
/// remote pack in the background once per app run.
final dictionaryProvider = FutureProvider<SignDictionary>((ref) async {
  final repo = ref.watch(signAssetRepositoryProvider);
  final dict = await repo.load();
  Future<void>(() async {
    if (await repo.sync() && ref.mounted) ref.invalidateSelf();
  });
  return dict;
});
