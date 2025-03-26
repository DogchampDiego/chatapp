import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseConfig.initializeFirebase();
    // Try to sign in anonymously, but continue even if it fails
    await FirebaseConfig.signInAnonymously();
  } catch (e) {
    print('Startup error: $e');
    // Continue with app startup even if there's an error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RealtimeDatabaseInputPage(title: 'Realtime Database Chat'),
    );
  }
}

class RealtimeDatabaseInputPage extends StatefulWidget {
  const RealtimeDatabaseInputPage({super.key, required this.title});

  final String title;

  @override
  State<RealtimeDatabaseInputPage> createState() =>
      _RealtimeDatabaseInputPageState();
}

class _RealtimeDatabaseInputPageState extends State<RealtimeDatabaseInputPage> {
  final TextEditingController _textController = TextEditingController();
  late final DatabaseReference _messagesRef;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Initialize the database reference in initState
    _messagesRef = FirebaseDatabase.instance.ref('messages');
  }

  void _saveToDatabase() async {
    if (_textController.text.isNotEmpty) {
      try {
        // Check if user is authenticated
        if (_auth.currentUser == null) {
          // If not authenticated, try to sign in anonymously
          final user = await FirebaseConfig.signInAnonymously();
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to authenticate. Please try again.'),
              ),
            );
            return;
          }
        }

        // Create a new message entry with a unique key
        final newMessageRef = _messagesRef.push();
        await newMessageRef.set({
          'text': _textController.text,
          'timestamp': ServerValue.timestamp,
          'userId': _auth.currentUser?.uid ?? 'unknown',
        });

        _textController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message saved to Realtime Database')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Show sign-in status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<User?>(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const Icon(Icons.verified_user, color: Colors.green);
                } else {
                  return const Icon(Icons.no_accounts, color: Colors.red);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter message',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _saveToDatabase,
                ),
              ),
              onSubmitted: (_) => _saveToDatabase(),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('No messages yet'));
                }

                // Convert the data to a usable format
                Map<dynamic, dynamic> messagesMap = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                // Convert to list and sort by timestamp (newest first)
                List<MapEntry<dynamic, dynamic>> messagesList =
                    messagesMap.entries.toList();
                messagesList.sort(
                  (a, b) => (b.value['timestamp'] ?? 0).compareTo(
                    a.value['timestamp'] ?? 0,
                  ),
                );

                return ListView.builder(
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    final message = messagesList[index].value;
                    final userId = message['userId'] ?? 'Unknown';
                    final isCurrentUser = userId == _auth.currentUser?.uid;

                    return ListTile(
                      title: Text(message['text'] ?? 'No text'),
                      subtitle: Text('User: ${userId.substring(0, 6)}...'),
                      tileColor:
                          isCurrentUser ? Colors.blue.withOpacity(0.1) : null,
                      trailing: isCurrentUser ? const Icon(Icons.person) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
