import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can add it manually',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can add it manually',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can add it manually',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can add it manually',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDmRVEcWdRmrCyUTi3AZ2RsjHYBRFr2zmk",
    authDomain: "chatapp-6539d.firebaseapp.com",
    projectId: "chatapp-6539d",
    storageBucket: "chatapp-6539d.firebasestorage.app",
    messagingSenderId: "457835886375",
    appId: "1:457835886375:web:63c52fd3e41b68fd8e9b02",
    measurementId: "G-R11NLZ08C4",
    databaseURL:
        "https://chatapp-6539d-default-rtdb.europe-west1.firebasedatabase.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDmRVEcWdRmrCyUTi3AZ2RsjHYBRFr2zmk",
    appId: "1:457835886375:web:63c52fd3e41b68fd8e9b02",
    messagingSenderId: "457835886375",
    projectId: "chatapp-6539d",
    storageBucket: "chatapp-6539d.firebasestorage.app",
    databaseURL:
        "https://chatapp-6539d-default-rtdb.europe-west1.firebasedatabase.app",
  );
}
