import 'package:firebase_auth/firebase_auth.dart';

/// Servicio simple para iniciar y cerrar sesion con Firebase Auth.
/// Sirve como punto unico si despues quieres ordenar mas la autenticacion.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
