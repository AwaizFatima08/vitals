import 'package:cloud_firestore/cloud_firestore.dart';

/// The account holder. Maps 1:1 to a Firebase Auth user.
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String preferredLanguage; // 'en' or 'ur'
  final String activePatientId;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.preferredLanguage,
    required this.activePatientId,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      preferredLanguage: (map['preferredLanguage'] as String?) ?? 'en',
      activePatientId: (map['activePatientId'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'preferredLanguage': preferredLanguage,
      'activePatientId': activePatientId,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    };
  }

  AppUser copyWith({String? displayName, String? preferredLanguage, String? activePatientId}) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      activePatientId: activePatientId ?? this.activePatientId,
      createdAt: createdAt,
    );
  }
}
