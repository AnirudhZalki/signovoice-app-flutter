import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/storage.dart';
import '../domain/user_profile.dart';
import '../domain/user_repository.dart';

/// Profile snapshot lives in encrypted storage; when Firebase is available it
/// is mirrored to Firestore `users/{uid}` (see firestore.rules).
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.secure, required this.firebaseAvailable});

  final SecureStore secure;
  final bool firebaseAvailable;

  String _key(String uid) => 'profile_$uid';

  @override
  Future<UserProfile?> load(String uid) async {
    final cached = await secure.read(_key(uid));
    UserProfile? local;
    if (cached != null) {
      try {
        local = UserProfile.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    if (!firebaseAvailable || uid == 'guest') return local;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 6));
      final d = snap.data();
      if (d == null) return local;
      final remote = UserProfile.fromJson({...d, 'uid': uid});
      await secure.write(_key(uid), jsonEncode(remote.toJson()));
      return remote;
    } catch (_) {
      return local; // offline: use cache
    }
  }

  @override
  Future<void> save(UserProfile p) async {
    await secure.write(_key(p.uid), jsonEncode(p.toJson()));
    if (!firebaseAvailable || p.uid == 'guest') return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(p.uid).set({
        'displayName': p.displayName,
        'photoUrl': p.photoUrl,
        'preferredLanguage': p.preferredLanguage,
        'preferredMode': p.preferredMode.name,
        'accessibilityNeeds': p.accessibilityNeeds.map((e) => e.name).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw toFailure(e);
    }
  }

  @override
  Future<String> uploadAvatar(String uid, String localPath) async {
    if (!firebaseAvailable) throw const Failure(FailureType.notConfigured);
    try {
      final ref = FirebaseStorage.instance.ref('users/$uid/avatar.jpg');
      await ref.putFile(File(localPath), SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw toFailure(e);
    }
  }

  @override
  Future<void> clearLocal(String uid) => secure.delete(_key(uid));

  @override
  Future<void> requestDataDeletion(String uid, {required bool deleteAccount}) async {
    if (!firebaseAvailable) return; // nothing stored remotely
    try {
      await FirebaseFirestore.instance.collection('deletionRequests').doc(uid).set({
        'uid': uid,
        'deleteAccount': deleteAccount,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw toFailure(e);
    }
  }
}
