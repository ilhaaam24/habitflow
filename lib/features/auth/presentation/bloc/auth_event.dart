import '../../../../shared/models/user_model.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final UserModel? user;
  AuthStatusChanged(this.user);
}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}
