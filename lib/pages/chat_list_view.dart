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
  final Chat selectedChat;
  final void Function(Chat) onChatSelected;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[chats.length - index - 1];
          return ListTile(
            leading: chat.id == selectedChat.id
                ? const Icon(Icons.chevron_right)
                : const SizedBox(),
            title: Text(chat.title),
            selected: chat.id == selectedChat.id,
            onTap: () => onChatSelected(chat),
          );
        },
      );
}
