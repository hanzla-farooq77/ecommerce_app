import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/core/widgets/fluttertoast.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  void getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return SimpleToast.error("No account found with this email.");
      case 'wrong-password':
      case 'invalid-credential':
        return SimpleToast.error("Incorrect Email or Password");
      case 'email-already-in-use':
        return SimpleToast.error("An Account Already Exists With This Email");
      case 'weak-password':
        return SimpleToast.error("Password Should Be At least 6 Characters");
      case 'invalid-email':
        return SimpleToast.error("Please Enter Valid Email Address");
      case 'too-many-requests':
        return SimpleToast.error("Too Many Attempts please Try Again");
      case 'network-request-failed':
        return SimpleToast.error("Network Eroor! Check Your Internet");
      default:
        return SimpleToast.error("SomeThing Went Wrong! Please Try Again ");
    }
  }
}
