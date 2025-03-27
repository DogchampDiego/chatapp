import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// From main.dart
const String secondaryAppName = 'secondary';

class FirebaseDbHandler {
  final FirebaseDatabase _database;

  // Constructor that selects the appropriate Firebase app based on platform
  FirebaseDbHandler()
    : _database =
          kIsWeb
              ? FirebaseDatabase.instanceFor(
                app: Firebase.app(secondaryAppName),
              )
              : FirebaseDatabase.instance;

  // Get reference to a specific path in the database
  DatabaseReference getReference(String path) {
    return _database.ref(path);
  }

  // Save a message to the database
  Future<void> saveMessage(String text) async {
    final messagesRef = _database.ref('messages');
    final newMessageRef = messagesRef.push();

    await newMessageRef.set({
      'text': text,
      'userId': _generateUserId(),
      'platform': kIsWeb ? 'web' : 'android',
      'timestamp': ServerValue.timestamp,
    });
  }

  // Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    await _database.ref('messages/$messageId').remove();
  }

  // Delete all messages (use with caution)
  Future<void> deleteAllMessages() async {
    await _database.ref('messages').remove();
  }

  // Generate a simple user ID based on timestamp
  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }
}
