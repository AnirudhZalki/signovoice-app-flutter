import 'package:equatable/equatable.dart';

import 'user_preferences.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.preferredLanguage = 'en',
    this.preferredMode = CommunicationMode.signToText,
    this.accessibilityNeeds = const {},
    this.createdAt,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final String preferredLanguage;
  final CommunicationMode preferredMode;
  final Set<AccessibilityNeed> accessibilityNeeds;
  final DateTime? createdAt;

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    CommunicationMode? preferredMode,
    Set<AccessibilityNeed>? accessibilityNeeds,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        preferredMode: preferredMode ?? this.preferredMode,
        accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'preferredLanguage': preferredLanguage,
        'preferredMode': preferredMode.name,
        'accessibilityNeeds': accessibilityNeeds.map((e) => e.name).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        uid: j['uid'] as String,
        displayName: (j['displayName'] as String?) ?? '',
        photoUrl: j['photoUrl'] as String?,
        preferredLanguage: (j['preferredLanguage'] as String?) ?? 'en',
        preferredMode: CommunicationMode.values.firstWhere(
          (m) => m.name == j['preferredMode'],
          orElse: () => CommunicationMode.signToText,
        ),
        accessibilityNeeds: {
          for (final n in (j['accessibilityNeeds'] as List<dynamic>? ?? const []))
            for (final v in AccessibilityNeed.values)
              if (v.name == n) v,
        },
        createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? ''),
      );

  @override
  List<Object?> get props =>
      [uid, displayName, photoUrl, preferredLanguage, preferredMode, accessibilityNeeds, createdAt];
}
