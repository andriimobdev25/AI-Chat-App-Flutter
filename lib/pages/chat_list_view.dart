import 'package:flutter/material.dart';

import '../data/chat.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({
    required this.chats,
    required this.selectedChat,
    required this.onChatSelected,
    super.key,
  });

  final List<Chat> chats;
  final Chat? selectedChat;
  final void Function(Chat) onChatSelected;

  @override
  Widget build(BuildContext context) => ListView.builder(
        reverse: true,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(chat.title),
            selected: chat.id == selectedChat?.id,
            onTap: () => onChatSelected(chat),
          );
        },
      );
}
