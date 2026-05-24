import '../../../../shared/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}
