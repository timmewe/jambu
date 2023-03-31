import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jambu/calendar/model/model.dart';
import 'package:jambu/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({
    required CalendarRepository calendarRepository,
  })  : _calendarRepository = calendarRepository,
        super(const CalendarState()) {
    on<CalendarRequested>(_onCalendarRequested);
    on<CalendarAttendanceUpdate>(_onCalenderAttendanceUpdate);
    on<CalendarGoToWeek>(_onCalendarGoToWeek);
    on<CalendarFilterUpdate>(
      _onCalendarFilterUpdate,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 500))
            .switchMap(mapper);
      },
    );
  }

  final CalendarRepository _calendarRepository;

  FutureOr<void> _onCalendarRequested(
    CalendarRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));
    final weeks = await _calendarRepository.fetchCalendar(filter: state.filter);
    final filteredWeeks = _calendarRepository.updateFilter(
      filter: state.filter,
      weeks: weeks,
    );
    emit(
      state.copyWith(
        status: CalendarStatus.success,
        weeks: filteredWeeks,
        unfilteredWeeks: weeks,
      ),
    );
  }

  FutureOr<void> _onCalenderAttendanceUpdate(
    CalendarAttendanceUpdate event,
    Emitter<CalendarState> emit,
  ) async {
    final weeks = _calendarRepository.updateAttendanceAt(
      date: event.date,
      isAttending: event.isAttending,
      weeks: state.unfilteredWeeks,
      filter: state.filter,
      reason: event.reason,
    );

    final filteredWeeks = _calendarRepository.updateFilter(
      filter: state.filter,
      weeks: weeks,
    );

    emit(state.copyWith(weeks: filteredWeeks, unfilteredWeeks: weeks));
  }

  FutureOr<void> _onCalendarGoToWeek(
    CalendarGoToWeek event,
    Emitter<CalendarState> emit,
  ) async {
    if (event.weekNumber < 0 || event.weekNumber > 3) return;
    emit(state.copyWith(selectedWeek: event.weekNumber));
  }

  FutureOr<void> _onCalendarFilterUpdate(
    CalendarFilterUpdate event,
    Emitter<CalendarState> emit,
  ) async {
    final filter = CalendarFilter(
      search: event.searchText ?? '',
      tags: event.tags,
    );
    final filteredWeeks = _calendarRepository.updateFilter(
      filter: filter,
      weeks: state.unfilteredWeeks,
    );
    emit(state.copyWith(weeks: filteredWeeks, filter: filter));
  }
}
