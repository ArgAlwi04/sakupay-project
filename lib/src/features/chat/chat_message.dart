// lib/src/features/chat/chat_message.dart

enum ChatRole { user, model }

class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final ChatRole role;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.role,
  });
}
