import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.isGuest = false,
    this.emailVerified = false,
    this.isNewUser = false,
  });

  static const guest = AppUser(uid: 'guest', isGuest: true);

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phone;
  final bool isGuest;
  final bool emailVerified;

  /// True right after the account was created (drives the trial offer).
  final bool isNewUser;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, phone, isGuest, emailVerified, isNewUser];
}

/// Result of asking Firebase to text a code.
class PhoneVerification extends Equatable {
  const PhoneVerification({this.verificationId, this.resendToken, this.autoSignedIn = false});
  final String? verificationId;
  final int? resendToken;

  /// Android instant verification / auto-retrieval already signed the user in.
  final bool autoSignedIn;

  @override
  List<Object?> get props => [verificationId, resendToken, autoSignedIn];
}
