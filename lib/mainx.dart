

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay parseTimeOfDay(String timeString) {
  // Sanitize string: remove any invisible Unicode characters (e.g., U+202F)
  String cleaned = timeString
      .replaceAll(RegExp(r'[\u2000-\u206F\u00A0\u202F\uFEFF]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final DateFormat format = DateFormat.jm(); // "h:mm a"
  final DateTime dateTime = format.parse(cleaned);
  return TimeOfDay.fromDateTime(dateTime);
}


void main() {
  String timeString = "4:26 AM";
  TimeOfDay time = parseTimeOfDay(timeString);

  print("Hour: ${time.hour}, Minute: ${time.minute}");
}
