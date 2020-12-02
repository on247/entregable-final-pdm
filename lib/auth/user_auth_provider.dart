import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class UserAuthProvider {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Map<String, String> errorMessages = {
    "LOGIN_CANCELLED": "Se cancelo el inicio de sesión",
    "MISSING_EMAIL": "Indica un correo electronico",
    "MISSING_PASSWORD": "Indica una contraseña",
    "email-already-in-use": "El usuario ya existe",
    "user-not-found": "El usuario no existe",
    "wrong-password": "Contraseña Incorrecta",
    "invalid-email": "Indica un correo valido",
    "error": "error al inciar sesion",
    "weak-password": "Indica una contraseña de al menos 6 caracteres",
  };

  bool isAlreadyLogged() {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  void signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  void signOutFirebase() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> signInWithEmail(String email, String password) async {
    if (email == "") {
      return "MISSING_EMAIL";
    }
    if (password == "") {
      return "MISSING_PASSWORD";
    }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(e);
        return e.code;
      }
    }
    return null;
  }

  Future<String> resetPassword(String email) async {
    if (email == "") {
      return "MISSING_EMAIL";
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(e);
        return e.code;
      }
    }
    return null;
  }

  Future<String> registerWithEmail(String email, String password) async {
    if (email == "") {
      return "MISSING_EMAIL";
    }
    if (password == "") {
      return "MISSING_PASSWORD";
    }
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(e);
        return e.code;
      }
    }
    return null;
  }

  Future<String> signInWithGoogle() async {
    // Google sign in
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return "LOGIN_CANCELLED";
    }
    final googleAuth = await googleUser.authentication;
    print("googleAuth $googleAuth");
    print("googleUser ${googleUser.displayName}");
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Firebase authentication
    final authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    final String firebaseAuthToken = await user.getIdToken();
    assert(!user.isAnonymous);
    assert(firebaseAuthToken != null);
    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print("Google auth token: ${googleAuth.accessToken}");
    print("Firebase auth token: $firebaseAuthToken");
    return null;
  }

  Future<String> signInWithFacebook() async {
    // Facebook sign in
    try {
      AccessToken accessToken = await FacebookAuth.instance.login();
      final FacebookAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      // Firebase authentication
      final authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user;
      final String firebaseAuthToken = await user.getIdToken();
      assert(!user.isAnonymous);
      assert(firebaseAuthToken != null);
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print("Facebook auth token: ${accessToken.token}");
      print("Firebase auth token: $firebaseAuthToken");
    } catch (e) {
      if (e is FacebookAuthException) {
        return e.errorCode;
      }
      if (e is FacebookAuthException) {
        if (e.errorCode == "CANCELLED") {
          return "LOGIN_CANCELLED";
        }
        return e.errorCode;
      }
      return "error";
    }
    return null;
  }
}
