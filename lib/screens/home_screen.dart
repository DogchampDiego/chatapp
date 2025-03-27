import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_db_handler.dart';
import '../widgets/message_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseDbHandler _dbHandler = FirebaseDbHandler();
  late final DatabaseReference _messagesRef;

  @override
  void initState() {
    super.initState();
    _messagesRef = _dbHandler.getReference('messages');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveMessage() async {
    if (_textController.text.isEmpty) return;

    try {
      await _dbHandler.saveMessage(_textController.text);
      _textController.clear();
      _showSnackBar('Message sent');
    } catch (e) {
      String errorMsg = e.toString();

      // Provide helpful information for web users encountering permission issues
      if (kIsWeb && errorMsg.contains('permission-denied')) {
        _showPermissionErrorDialog();
      } else {
        _showSnackBar('Error: $errorMsg');
      }
    }
  }

  void _showPermissionErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Firebase Permission Error'),
            content: const Text(
              'Your Firebase Database rules need to be updated to allow web access. '
              'Go to the Firebase Console, open Realtime Database, and update the rules to:\n\n'
              '{\n'
              '  "rules": {\n'
              '    ".read": true,\n'
              '    ".write": true\n'
              '  }\n'
              '}\n\n'
              'Note: These rules allow public access and should be restricted in production.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Platform indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              kIsWeb ? Icons.web : Icons.phone_android,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [_buildMessageInput(), Expanded(child: _buildMessageList())],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: 'Enter message',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: _saveMessage,
          ),
        ),
        onSubmitted: (_) => _saveMessage(),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _messagesRef.orderByChild('timestamp').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text('No messages yet'));
        }

        try {
          // Convert data to list and sort
          final messagesMap = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final messagesList = messagesMap.entries.toList();
          messagesList.sort(
            (a, b) => (b.value['timestamp'] ?? 0).compareTo(
              a.value['timestamp'] ?? 0,
            ),
          );

          return ListView.builder(
            itemCount: messagesList.length,
            itemBuilder:
                (context, index) => MessageTile(
                  message: messagesList[index].value,
                  currentPlatform: kIsWeb ? 'web' : 'android',
                ),
          );
        } catch (e) {
          return Center(child: Text('Error loading messages: $e'));
        }
      },
    );
  }
}
