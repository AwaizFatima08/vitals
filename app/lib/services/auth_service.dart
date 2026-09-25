import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/firestore_paths.dart';
import '../models/app_user.dart';

/// Email/password auth against the shared LiveHealthy Firebase project, so
/// an account created in Medicine Reminder signs straight in here (and vice
/// versa).
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _db.collection(FirestorePaths.users).doc(uid);

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
    required String preferredLanguage,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(displayName);

    final appUser = AppUser(
      uid: uid,
      displayName: displayName,
      email: email,
      preferredLanguage: preferredLanguage,
      activePatientId: '',
      createdAt: DateTime.now(),
    );
    await _userDoc(uid).set(appUser.toMap());
    return appUser;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  /// Recovers from an account whose Firestore profile was never written
  /// (e.g. sign-up interrupted between Auth and Firestore). Merge-only and
  /// never blanks a field, so it can't clobber a profile being written by
  /// [signUp] at the same moment.
  Future<void> ensureUserProfile(User user) {
    final displayName = user.displayName ?? '';
    return _userDoc(
      user.uid,
    ).set({'email': user.email ?? '', if (displayName.isNotEmpty) 'displayName': displayName}, SetOptions(merge: true));
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(uid, doc.data()!);
    });
  }

  Future<void> setActivePatient(String uid, String patientId) =>
      _userDoc(uid).set({'activePatientId': patientId}, SetOptions(merge: true));

  Future<void> setPreferredLanguage(String uid, String languageCode) =>
      _userDoc(uid).set({'preferredLanguage': languageCode}, SetOptions(merge: true));
}
