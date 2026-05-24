import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}
