import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class AppointmentScheduleParser {
  static DateTime? parse(Object? dateValue, Object? timeValue) {
    final date = switch (dateValue) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      String value => DateTime.tryParse(value),
      _ => null,
    };
    if (date == null) return null;

    final time = _parseTime(timeValue is String ? timeValue : '');
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.$1, time.$2);
  }

  static (int, int)? _parseTime(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;

    final hourValue = match.group(1);
    final minuteValue = match.group(2);
    if (hourValue == null || minuteValue == null) return null;
    var hour = int.tryParse(hourValue);
    final minute = int.tryParse(minuteValue);
    final meridiem = match.group(3)?.toUpperCase();
    if (hour == null || minute == null || minute > 59) return null;
    if (meridiem != null) {
      if (hour < 1 || hour > 12) return null;
      if (meridiem == 'PM' && hour != 12) hour += 12;
      if (meridiem == 'AM' && hour == 12) hour = 0;
    } else if (hour > 23) {
      return null;
    }
    return (hour, minute);
  }
}
