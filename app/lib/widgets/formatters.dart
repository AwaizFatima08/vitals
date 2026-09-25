import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reading timestamps: "9:14 AM" today, otherwise "Sep 24, 9:14 AM".
String formatReadingTime(BuildContext context, DateTime time, {DateTime? now}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final current = now ?? DateTime.now();
  final sameDay = time.year == current.year && time.month == current.month && time.day == current.day;
  final timePart = DateFormat.jm(locale).format(time);
  if (sameDay) return timePart;
  final datePart = time.year == current.year
      ? DateFormat.MMMd(locale).format(time)
      : DateFormat.yMMMd(locale).format(time);
  return '$datePart, $timePart';
}

String formatTimeOfDay(BuildContext context, int hour, int minute) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.jm(locale).format(DateTime(2000, 1, 1, hour, minute));
}
