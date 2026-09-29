/// Small date helpers, all taking `now` explicitly so they are testable.
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 0=morning, 1=afternoon, 2=evening
enum DayPart { morning, afternoon, evening }

DayPart dayPartOf(DateTime now) {
  if (now.hour < 12) return DayPart.morning;
  if (now.hour < 17) return DayPart.afternoon;
  return DayPart.evening;
}

/// Whole days remaining until [end] (rounded up), never negative.
int daysRemaining(DateTime end, DateTime now) {
  final diff = end.difference(now);
  if (diff.isNegative) return 0;
  return (diff.inHours / 24).ceil();
}
