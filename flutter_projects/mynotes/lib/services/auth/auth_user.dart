import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String email;
  final String id;
  const AuthUser({
    required this.isEmailVerified,
    required this.email,
    required this.id,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email!,
        id: user.uid,
      );
//ensure that you don't expose Firebase interface to user, rather place values in AuthUser

}
