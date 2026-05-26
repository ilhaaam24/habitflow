import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _syncUserProfile(user);
    }
    return userCredential;
  }

  Future<void> _syncUserProfile(User user) async {
    try {
      developer.log(
        'Syncing user profile for ${user.uid} to Firestore...',
        name: 'AuthRemoteDataSource',
      );
      final userRef = firestore.collection('users').doc(user.uid);
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      developer.log(
        'Successfully synced user profile for ${user.uid} to Firestore.',
        name: 'AuthRemoteDataSource',
      );
    } catch (e) {
      developer.log(
        'Error syncing user profile to Firestore',
        error: e,
        name: 'AuthRemoteDataSource',
      );
      rethrow;
    }
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
