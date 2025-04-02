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

  // Get list of all chats
  Stream<DatabaseEvent> getChats() {
    return _database.ref('chats').onValue;
  }

  // Get messages for a specific chat
  Stream<DatabaseEvent> getChatMessages(String chatId) {
    return _database
        .ref('chat_messages/$chatId')
        .orderByChild('timestamp')
        .onValue;
  }

  // Create a new chat
  Future<String> createChat(String topic) async {
    final chatsRef = _database.ref('chats');
    final newChatRef = chatsRef.push();

    await newChatRef.set({'topic': topic, 'createdAt': ServerValue.timestamp});

    return newChatRef.key ?? '';
  }

  // Save a message to a specific chat
  Future<void> saveChatMessage(
    String chatId,
    String senderName,
    String text,
  ) async {
    final messagesRef = _database.ref('chat_messages/$chatId');
    final newMessageRef = messagesRef.push();

    await newMessageRef.set({
      'text': text,
      'sender': senderName,
      'platform': kIsWeb ? 'web' : 'android',
      'timestamp': ServerValue.timestamp,
    });
  }

  // Delete a specific message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _database.ref('chat_messages/$chatId/$messageId').remove();
  }

  // Delete a specific chat and all its messages
  Future<void> deleteChat(String chatId) async {
    // Delete the chat
    await _database.ref('chats/$chatId').remove();

    // Delete all messages for this chat
    await _database.ref('chat_messages/$chatId').remove();
  }
}
