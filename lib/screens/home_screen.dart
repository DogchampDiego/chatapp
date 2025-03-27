import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_db_handler.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _chatTopicController = TextEditingController();
  final FirebaseDbHandler _dbHandler = FirebaseDbHandler();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _chatTopicController.dispose();
    super.dispose();
  }

  void _createNewChat() async {
    if (_chatTopicController.text.isEmpty) {
      _showSnackBar('Please enter a chat topic');
      return;
    }

    try {
      final chatId = await _dbHandler.createChat(_chatTopicController.text);
      _chatTopicController.clear();

      if (chatId.isNotEmpty) {
        _showSnackBar('Chat created successfully');
      }
    } catch (e) {
      _showSnackBar('Error creating chat: ${e.toString()}');
    }
  }

  void _openChat(String chatId, String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, topic: topic),
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
        children: [
          _buildNewChatInput(),
          const Divider(thickness: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Available Chats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildChatsList()),
        ],
      ),
    );
  }

  Widget _buildNewChatInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Chat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatTopicController,
                  decoration: const InputDecoration(
                    labelText: 'Chat Topic',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _createNewChat,
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder(
      stream: _dbHandler.getChats(),
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text('No chats available. Create a new one!'),
          );
        }

        try {
          final chatsMap = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          if (chatsMap.isEmpty) {
            return const Center(
              child: Text('No chats available. Create a new one!'),
            );
          }

          final chatsList = chatsMap.entries.toList();

          // Sort chats by creation time (newest first)
          chatsList.sort(
            (a, b) => (b.value['createdAt'] ?? 0).compareTo(
              a.value['createdAt'] ?? 0,
            ),
          );

          return ListView.builder(
            itemCount: chatsList.length,
            itemBuilder: (context, index) {
              final chatId = chatsList[index].key as String;
              final chatData = chatsList[index].value as Map<dynamic, dynamic>;
              final topic = chatData['topic'] as String? ?? 'Unnamed Chat';

              return ListTile(
                title: Text(topic),
                leading: const Icon(Icons.chat),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _openChat(chatId, topic),
              );
            },
          );
        } catch (e) {
          return Center(child: Text('Error loading chats: $e'));
        }
      },
    );
  }
}
