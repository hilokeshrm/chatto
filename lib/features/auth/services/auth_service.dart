import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    GoogleSignIn googleSignIn;

    if (kIsWeb) {
      googleSignIn = GoogleSignIn(
        clientId: '574184186632-lana80k1j5o0vsdeu1ht638gjh2231ng.apps.googleusercontent.com',
      );
    } else {
      googleSignIn = GoogleSignIn(); // For Android/iOS
    }

    // Optional: sign out previous Google session to force fresh account pick
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign in aborted by user');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
