import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_db_handler.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String topic;

  const ChatScreen({super.key, required this.chatId, required this.topic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final FirebaseDbHandler _dbHandler = FirebaseDbHandler();

  @override
  void dispose() {
    _messageController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      _showSnackBar('Please enter a message');
      return;
    }

    if (_senderController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

    try {
      await _dbHandler.saveChatMessage(
        widget.chatId,
        _senderController.text,
        _messageController.text,
      );
      _messageController.clear();
      _showSnackBar('Message sent');
    } catch (e) {
      _showSnackBar('Error sending message: ${e.toString()}');
    }
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
        title: Text(widget.topic),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          const Divider(thickness: 1),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _senderController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _dbHandler.getChatMessages(widget.chatId),
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text('No messages yet. Start the conversation!'),
          );
        }

        try {
          final messagesMap = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final messagesList = messagesMap.entries.toList();

          // Sort messages by timestamp (newest last)
          messagesList.sort(
            (a, b) => (a.value['timestamp'] ?? 0).compareTo(
              b.value['timestamp'] ?? 0,
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(5),
                        },
                        border: TableBorder.all(color: Colors.grey.shade300),
                        children: [
                          // Header row
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.grey),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Sender',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Content',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          // Message rows
                          ...messagesList.map((entry) {
                            final messageData =
                                entry.value as Map<dynamic, dynamic>;
                            final sender =
                                messageData['sender'] as String? ?? 'Unknown';
                            final text = messageData['text'] as String? ?? '';

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sender),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(text),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          return Center(child: Text('Error loading messages: $e'));
        }
      },
    );
  }
}
