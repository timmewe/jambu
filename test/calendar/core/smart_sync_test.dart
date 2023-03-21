import 'package:flutter_test/flutter_test.dart';
import 'package:jambu/backend/backend.dart';
import 'package:jambu/calendar/core/core.dart';
import 'package:jambu/model/model.dart';
import 'package:jambu/repository/repository.dart';
import 'package:mocktail/mocktail.dart';

class MocKMSGraphRepository extends Mock implements MSGraphRepository {}

class MocKFirestoreRepository extends Mock implements FirestoreRepository {}

void main() {
  late MSGraphRepository msGraphRepository;
  late FirestoreRepository firestoreRepository;
  late SmartSync smartSync;

  setUp(() {
    msGraphRepository = MocKMSGraphRepository();
    firestoreRepository = MocKFirestoreRepository();
    const currentUser = User(id: '0', name: 'Test User', email: 't@gmail.com');
    smartSync = SmartSync(
      currentUser: currentUser,
      firestoreRepository: firestoreRepository,
      msGraphRepository: msGraphRepository,
    );
  });

  group('SmartSync', () {
    test(
        'returns firestore attendances '
        'when the events from outlook are empty', () async {
      // arrange
      final fsAttendances = _attendances;
      when(msGraphRepository.eventsFromToday).thenAnswer((_) async => []);
      when(firestoreRepository.getAttendances).thenAnswer((_) async {
        return fsAttendances;
      });

      // act
      final result = await smartSync();

      // assert
      expect(result, fsAttendances);
    });
  });
}

List<Attendance> get _attendances {
  return [
    Attendance(date: DateTime.parse('2023-03-20'), userIds: const ['1']),
    Attendance(date: DateTime.parse('2023-03-21'), userIds: const ['2']),
  ];
}