import 'dart:async';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../data/chat.dart';
import '../data/chat_repository.dart';
import '../login_info.dart';
import 'chat_list_view.dart';
import 'split_or_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LlmProvider? _provider;
  ChatRepository? _repository;
  Chat? _currentChat;

  @override
  void initState() {
    super.initState();
    unawaited(_setRepository());
    _setProvider();
  }

  Future<void> _setRepository() async {
    assert(_repository == null);
    _repository = await ChatRepository.forCurrentUser;
    await _setChat(_repository!.chats.first);
    setState(() {});
  }

  Future<void> _setChat(Chat chat) async {
    assert(_currentChat?.id != chat.id);
    debugPrint('Chat selected: ${chat.id}');
    _currentChat = chat;
    final history = await _repository!.getHistory(chat);
    _setProvider(history);
    setState(() {});
  }

  void _setProvider([Iterable<ChatMessage>? history]) {
    _provider?.removeListener(_onHistoryChanged);

    setState(
      () => _provider = VertexProvider(
        history: history,
        model: FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-1.5-flash',
        ),
      ),
    );

    _provider!.addListener(_onHistoryChanged);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter AI Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout: ${LoginInfo.instance.displayName!}',
              onPressed: () async => LoginInfo.instance.logout(),
            ),
            IconButton(
              onPressed: _repository == null ? null : _onAdd,
              tooltip: 'New Chat',
              icon: const Icon(Icons.edit_square),
            ),
          ],
        ),
        body: _repository == null
            ? const Center(child: CircularProgressIndicator())
            : SplitOrTabs(
                tabs: const [
                  Tab(text: 'Chats'),
                  Tab(text: 'Chat'),
                ],
                children: [
                  ChatListView(
                    chats: _repository!.chats,
                    selectedChat: _currentChat!,
                    onChatSelected: _onChatSelected,
                    onRenameChat: _onRenameChat,
                    onDeleteChat: _onDeleteChat,
                  ),
                  LlmChatView(provider: _provider!),
                ],
              ),
      );

  Future<void> _onAdd() async {
    final chat = await _repository!.addChat();
    await _onChatSelected(chat);
  }

  Future<void> _onChatSelected(Chat chat) async {
    if (_currentChat?.id == chat.id) return;
    await _setChat(chat);
  }

  Future<void> _onHistoryChanged() => _repository!.updateHistory(
        _currentChat!,
        _provider!.history.toList(),
      );

  Future<void> _onRenameChat(Chat chat) async {
    final controller = TextEditingController(text: chat.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Chat: ${chat.title}'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newTitle != null) {
      await _repository!.updateChat(Chat(id: chat.id, title: newTitle));
      setState(() {});
    }
  }

  Future<void> _onDeleteChat(Chat chat) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat: ${chat.title}'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await _repository!.deleteChat(chat);
      if (_currentChat!.id == chat.id) await _setChat(_repository!.chats.first);
      setState(() {});
    }
  }
}
