import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConfig {
  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: "AIzaSyDmRVEcWdRmrCyUTi3AZ2RsjHYBRFr2zmk",
    authDomain: "chatapp-6539d.firebaseapp.com",
    projectId: "chatapp-6539d",
    storageBucket: "chatapp-6539d.firebasestorage.app",
    messagingSenderId: "457835886375",
    appId: "1:457835886375:web:63c52fd3e41b68fd8e9b02",
    measurementId: "G-R11NLZ08C4",
    databaseURL: "https://chatapp-6539d-default-rtdb.firebaseio.com",
  );

  static Future<void> initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: webOptions);
      } else {
        // Use the existing app
        Firebase.app();
      }
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  static Future<User?> signInAnonymously() async {
    try {
      // Check if user is already signed in
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return currentUser;
      }

      // If not signed in, attempt anonymous sign-in
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      // Return null instead of rethrowing to allow the app to continue
      return null;
    }
  }
}
