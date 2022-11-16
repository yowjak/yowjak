import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;
  const AuthUser({
    required this.isEmailVerified,
    required this.email,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email,
      );
//ensure that you don't expose Firebase interface to user, rather place values in AuthUser

}
