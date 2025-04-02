import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final Map<dynamic, dynamic> message;
  final String currentPlatform;

  const MessageTile({
    super.key,
    required this.message,
    required this.currentPlatform,
  });

  @override
  Widget build(BuildContext context) {
    final userId = message['userId'] ?? 'Unknown';
    final platform = message['platform'] ?? 'unknown';

    // Highlight messages from the current platform
    final bool isFromCurrentPlatform = platform == currentPlatform;

    final shortUserId =
        userId.length > 6 ? '${userId.substring(0, 6)}...' : userId;

    return ListTile(
      title: Text(message['text'] ?? 'No text'),
      subtitle: Text('User: $shortUserId ($platform)'),
      tileColor:
          isFromCurrentPlatform
              ? const Color.fromRGBO(33, 150, 243, 0.1)
              : null,
      trailing:
          isFromCurrentPlatform
              ? Icon(
                platform == 'web' ? Icons.web : Icons.phone_android,
                color: Colors.blue,
              )
              : null,
    );
  }
}
