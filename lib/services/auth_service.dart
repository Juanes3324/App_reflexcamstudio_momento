import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  const AuthUser({required this.uid, this.email});

  final String uid;
  final String? email;
}

abstract interface class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<void> signIn(String email, String password);
  Future<void> createAccount(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(uid: user.uid, email: user.email);
  }

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> createAccount(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
