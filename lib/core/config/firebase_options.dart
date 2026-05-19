// Placeholder. Replace by running `flutterfire configure` once a real Firebase
// project is connected. The app boots into offline mode when initialization
// fails, so this stub is safe for development without credentials.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    // Forcing initialization failure on the stub so the app falls back to the
    // in-memory repositories until a real config is dropped in.
    throw UnsupportedError(
      'firebase_options.dart is a placeholder. Run `flutterfire configure` '
      'to generate the real file. Platform: ${defaultTargetPlatform.name}.',
    );
  }
}
