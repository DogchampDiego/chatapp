import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';
import 'firebase_options.dart';

// Secondary app name
const String secondaryAppName = 'secondary';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web platform uses secondary app
    await initializeSecondaryApp();
  } else {
    // Mobile platforms use default app
    await initializeDefaultApp();
  }

  runApp(const MyApp());
}

// Initialize the default Firebase app
Future<void> initializeDefaultApp() async {
  try {
    if (Firebase.apps.where((app) => app.name == '[DEFAULT]').isEmpty) {
      FirebaseApp app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Initialized default app: ${app.name}');
    } else {
      print('Default app already initialized');
    }
  } catch (e) {
    print('Error initializing default app: $e');
  }
}

// Initialize secondary Firebase app
Future<void> initializeSecondaryApp() async {
  try {
    if (Firebase.apps.where((app) => app.name == secondaryAppName).isEmpty) {
      FirebaseApp app = await Firebase.initializeApp(
        name: secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Initialized secondary app: ${app.name}');
    } else {
      print('Secondary app already initialized');
    }
  } catch (e) {
    print('Error initializing secondary app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Firebase Chat'),
    );
  }
}
