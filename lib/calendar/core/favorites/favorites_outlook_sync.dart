import 'package:collection/collection.dart';
import 'package:jambu/calendar/core/favorites/favorites_outlook_updates.dart';
import 'package:jambu/calendar/model/model.dart';
import 'package:jambu/constants.dart';
import 'package:jambu/ms_graph/api/api.dart';
import 'package:jambu/repository/repository.dart';

class FavoritesOutlookSync {
  const FavoritesOutlookSync({
    required MSGraphRepository msGraphRepository,
    required List<CalendarWeek> attendances,
    required Iterable<String> favoriteUserIds,
  })  : _msGraphRepository = msGraphRepository,
        _attendances = attendances,
        _favoriteUserIds = favoriteUserIds;

  final MSGraphRepository _msGraphRepository;
  final List<CalendarWeek> _attendances;
  final Iterable<String> _favoriteUserIds;

  Future<void> call() async {
    final calendars = await _msGraphRepository.fetchCalendars();

    // Check if calendar contains favorites calendar -> otherwise create it
    final calendarId = calendars
            .firstWhereOrNull((c) => c.name == Constants.favoritesCalendarName)
            ?.id ??
        await _msGraphRepository.createCalendar(
          name: Constants.favoritesCalendarName,
        );

    if (calendarId == null) return;

    // Fetch all events from calendar
    final existingEvents =
        await _msGraphRepository.fetchEventsFromCalendar(calendarId);

    final updates = FavoritesOutlookUpdates(
      favoriteUserIds: _favoriteUserIds.toList(),
      attendances: _attendances,
      favoriteEvents: existingEvents,
    )();

    //  Convert events to batch requests
    var requestIndex = 0;
    final addRequests = updates.eventsToAdd.map(
      (event) => MSBatchRequest.createEvent(
        id: requestIndex++,
        event: event,
        calendarId: calendarId,
      ),
    );

    final deleteRequests =
        updates.eventsToRemove.map((e) => e.id).whereNotNull().map(
              (id) => MSBatchRequest.deleteEvent(
                id: requestIndex++,
                eventId: id,
                calendarId: calendarId,
              ),
            );

    //  Upload batch requests
    final requests = [...deleteRequests, ...addRequests];
    await _msGraphRepository.uploadBatchRequest(requests);
  }
}