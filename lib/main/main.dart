import 'package:chopper/chopper.dart';
import 'package:jambu/app/app.dart';
import 'package:jambu/main/bootstrap/bootstrap.dart';
import 'package:jambu/ms_graph/ms_graph.dart';
import 'package:jambu/repository/repository.dart';
import 'package:jambu/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  bootstrap((firebaseMessaging, firebaseAuth) async {
    // TODO(tim): Replace with secure storage
    final sharedPrefs = await SharedPreferences.getInstance();
    final tokenStorage = SharedPrefsTokenStorage(sharedPrefs: sharedPrefs);

    final userRepository = UserRepository(
      firebaseAuth: firebaseAuth,
      tokenStorage: tokenStorage,
    );

    final msGraphChopperClient = ChopperClient(
      baseUrl: Uri.parse('https://graph.microsoft.com'),
      authenticator: AuthChallengeAuthenticator(
        tokenStorage: tokenStorage,
        userRepository: userRepository,
      ),
      interceptors: [
        LoggingInterceptor(),
        AuthInterceptor(tokenStorage: tokenStorage),
      ],
    );
    final msGraphAPI = MSGraphAPI.create(msGraphChopperClient);
    final msGraphDataSource = MSGraphDataSource(msGraphAPI: msGraphAPI);
    final msGraphRepository = MSGraphRepository(
      msGraphDataSource: msGraphDataSource,
    );

    return App(
      userRepository: userRepository,
      msGraphRepository: msGraphRepository,
    );
  });
}
