import 'package:flutter/material.dart';

import '../data/chat.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({
    required this.chats,
    required this.selectedChatId,
    required this.onChatSelected,
    required this.onRenameChat,
    required this.onDeleteChat,
    super.key,
  });

  final List<Chat> chats;
  final String selectedChatId;
  final void Function(Chat) onChatSelected;
  final void Function(Chat) onRenameChat;
  final void Function(Chat) onDeleteChat;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[chats.length - index - 1];
          return ListTile(
            leading: chat.id == selectedChatId
                ? const Icon(Icons.chevron_right)
                : const SizedBox(),
            title: Tooltip(
              message: chat.title,
              child: Text(
                chat.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: OverflowBar(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Rename Chat',
                  onPressed: () => onRenameChat(chat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Chat',
                  onPressed: () => onDeleteChat(chat),
                ),
              ],
            ),
            selected: chat.id == selectedChatId,
            onTap: () => onChatSelected(chat),
          );
        },
      );
}
