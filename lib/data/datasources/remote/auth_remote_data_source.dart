import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get userStream;
  Future<UserModel?> signInWithGoogle();
  Future<void> logOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Stream<UserModel?> get userStream {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
    });
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      User? user;

      if (kIsWeb) {
        // Trên Web: Dùng signInWithPopup từ firebase_auth trực tiếp
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        user = userCredential.user;
      } else {
        // Trên Android/iOS: Dùng google_sign_in package như bình thường
        await _googleSignIn.initialize(
          serverClientId:
              '900092231681-lktsec0m2ffgipu672vr29eht400c574.apps.googleusercontent.com',
        );

        final GoogleSignInAccount googleUser =
            await _googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;
        final authClient = await googleUser.authorizationClient
            .authorizationForScopes(['email', 'profile']);

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authClient?.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (user != null) {
        return UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }
}
