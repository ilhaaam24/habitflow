import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> signInWithGoogle() async {
    final firebase.UserCredential credential = await remoteDataSource.signInWithGoogle();
    final firebase.User? user = credential.user;
    if (user == null) {
      throw firebase.FirebaseAuthException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'Google Sign In succeeded but user was null',
      );
    }
    return _mapFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  UserModel? getCurrentUser() {
    final firebase.User? user = remoteDataSource.getCurrentUser();
    return user != null ? _mapFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((firebaseUser) {
      return firebaseUser != null ? _mapFirebaseUser(firebaseUser) : null;
    });
  }

  UserModel _mapFirebaseUser(firebase.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
    );
  }
}
