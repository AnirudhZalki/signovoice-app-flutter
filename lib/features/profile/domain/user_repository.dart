import 'user_profile.dart';

abstract class UserRepository {
  /// Local cache first; remote when signed in and online.
  Future<UserProfile?> load(String uid);
  Future<void> save(UserProfile profile);

  /// Uploads a profile photo, returning its URL. Requires an account.
  Future<String> uploadAvatar(String uid, String localPath);

  /// Removes everything stored locally for this user.
  Future<void> clearLocal(String uid);

  /// Records a server-side erasure request (backend deletes all remote data).
  Future<void> requestDataDeletion(String uid, {required bool deleteAccount});
}
