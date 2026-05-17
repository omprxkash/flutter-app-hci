import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final bool firebaseAvailable = await _initFirebase();

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(firebaseAvailable),
      ],
      child: const MedQuizApp(),
    ),
  );
}

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (e, st) {
    appLogger.w('Firebase init failed — running in offline mode', error: e, stackTrace: st);
    return false;
  }
}

final Provider<bool> firebaseAvailableProvider = Provider<bool>((Ref ref) => false);
