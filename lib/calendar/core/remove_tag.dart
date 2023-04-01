import 'package:jambu/calendar/model/model.dart';

class RemoveTag {
  const RemoveTag({
    required this.tag,
    required this.userId,
    required this.weeks,
  });

  final String tag;
  final String userId;
  final List<CalendarWeek> weeks;

  List<CalendarWeek> call() {
    final updatedWeeks = <CalendarWeek>[];
    for (final week in weeks) {
      final updatedDays = <CalendarDay>[];
      for (final day in week.days) {
        final updatedUsers = day.users.map((u) {
          return u.id == userId
              ? u.copyWith(tags: u.tags.where((t) => t != tag).toList())
              : u;
        }).toList();
        updatedDays.add(day.copyWith(users: updatedUsers));
      }
      updatedWeeks.add(week.copyWith(days: updatedDays));
    }

    return updatedWeeks;
  }
}
