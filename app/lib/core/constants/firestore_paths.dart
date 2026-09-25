/// Central place for Firestore collection/field names so the rest of the
/// app never hardcodes path strings. Keep in sync with firebase/firestore.rules
/// and firebase/firestore.indexes.json.
///
/// `users` and `patients` are SHARED with LiveHealthy Pill Reminder (same
/// Firebase project, one LiveHealthy account). Never change their shape
/// here without updating that app too.
class FirestorePaths {
  FirestorePaths._();

  // Shared with LiveHealthy Pill Reminder.
  static const String users = 'users';
  static const String patients = 'patients';

  // Pill Reminder's per-patient subcollections. Vitals never reads them,
  // but account deletion must clean them up because the account is shared.
  static const String medicines = 'medicines';
  static const String schedules = 'schedules';
  static const String doseEvents = 'doseEvents';
  static const String purchases = 'purchases';

  // Vitals-only.
  static const String vitalReadings = 'vitalReadings'; // patients/{id}/vitalReadings
  static const String vitalReminders = 'vitalReminders'; // users/{uid}/vitalReminders
}
