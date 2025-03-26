import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDmRVEcWdRmrCyUTi3AZ2RsjHYBRFr2zmk',
    appId: '1:457835886375:web:63c52fd3e41b68fd8e9b02',
    messagingSenderId: '457835886375',
    projectId: 'chatapp-6539d',
    authDomain: 'chatapp-6539d.firebaseapp.com',
    storageBucket: 'chatapp-6539d.firebasestorage.app',
    measurementId: 'G-R11NLZ08C4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAA9EAxrRZ2M_uMQDHA55TaTxOLMZuKOCQ',
    appId: '1:457835886375:android:162beac296604b908e9b02',
    messagingSenderId: '457835886375',
    projectId: 'chatapp-6539d',
    storageBucket: 'chatapp-6539d.firebasestorage.app',
  );
}
