import 'package:cloud_firestore/cloud_firestore.dart';

/// A person whose vitals are being tracked. Same document (and same shape)
/// as LiveHealthy Pill Reminder's patient — Vitals only adds [heightCm],
/// which Pill Reminder simply ignores.
class Patient {
  final String id;
  final String name;
  final String ownerUid;
  final List<String> memberUids; // includes ownerUid + any co-caregivers
  final String? photoUrl;
  final String relationship; // e.g. "self", "mother", "father", "spouse"
  final double? heightCm; // captured once, used for BMI
  final DateTime? createdAt;

  const Patient({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.memberUids,
    required this.photoUrl,
    required this.relationship,
    required this.heightCm,
    required this.createdAt,
  });

  factory Patient.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return Patient(
      id: doc.id,
      name: (map['name'] as String?) ?? '',
      ownerUid: (map['ownerUid'] as String?) ?? '',
      memberUids: List<String>.from((map['memberUids'] as List?) ?? const []),
      photoUrl: map['photoUrl'] as String?,
      relationship: (map['relationship'] as String?) ?? 'self',
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerUid': ownerUid,
      'memberUids': memberUids,
      'photoUrl': photoUrl,
      'relationship': relationship,
      if (heightCm != null) 'heightCm': heightCm,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    };
  }

  bool get isSelf => relationship == 'self';
}
