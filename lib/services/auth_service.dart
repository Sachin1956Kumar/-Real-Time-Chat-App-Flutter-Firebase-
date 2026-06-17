import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Handles signup, login, logout, and keeps the user's
// online/offline presence updated in Firestore.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Currently logged-in user, null if no one is logged in.
  User? get currentUser => _auth.currentUser;

  // Stream that notifies listeners whenever auth state changes
  // (login, logout, app restart with cached session, etc.)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------------------------------------
  // Sign up a new user with email/password, then create
  // their profile document in Firestore's 'users' collection.
  // -------------------------------------------------------
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a corresponding user profile document.
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      return null; // null means success, no error
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed. Please try again.';
    }
  }

  // -------------------------------------------------------
  // Log in an existing user and mark them online.
  // -------------------------------------------------------
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await setOnlineStatus(result.user!.uid, true);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed. Please check your credentials.';
    }
  }

  // -------------------------------------------------------
  // Mark the current user offline, then sign them out.
  // -------------------------------------------------------
  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await setOnlineStatus(uid, false);
    }
    await _auth.signOut();
  }

  // -------------------------------------------------------
  // Update a user's online/offline status + lastSeen timestamp.
  // -------------------------------------------------------
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
