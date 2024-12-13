import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:uuid/uuid.dart';

import 'chat.dart';

class ChatRepository extends ChangeNotifier {
  ChatRepository._({
    required CollectionReference collection,
    required List<Chat> chats,
  })  : _chatsCollection = collection,
        _chats = chats;

  static const newChatTitle = 'Untitled';
  static User? _currentUser;
  static ChatRepository? _currentUserRepository;

  static bool get hasCurrentUser => _currentUser != null;
  static Future<ChatRepository> get forCurrentUser async {
    // no user, no repository
    if (_currentUser == null) throw Exception('No user logged in');

    // load the repository for the current user if it's not already loaded
    if (_currentUserRepository == null) {
      assert(_currentUser != null);
      final collection = FirebaseFirestore.instance
          .collection('users/${_currentUser!.uid}/chats');

      // load the chats from the database
      final chats = await ChatRepository._loadChats(collection);

      _currentUserRepository = ChatRepository._(
        collection: collection,
        chats: chats,
      );

      // if there are no chats, add a new one
      if (chats.isEmpty) {
        await _currentUserRepository!.addChat();
      }
    }

    return _currentUserRepository!;
  }

  static User? get user => _currentUser;

  static set user(User? user) {
    // clear the repository cache when the user is logged out
    if (user == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    // ignore if the same user is already logged in
    if (user.uid == _currentUser?.uid) return;

    // clear the repository cache to load the user's chats on demand
    _currentUser = user;
    _currentUserRepository = null;
  }

  static Future<List<Chat>> _loadChats(CollectionReference collection) async {
    final chats = <Chat>[];
    final querySnapshot = await collection.get();
    for (final doc in querySnapshot.docs) {
      chats.add(Chat.fromJson(doc.data()! as Map<String, dynamic>));
    }

    return chats;
  }

  final CollectionReference _chatsCollection;
  final List<Chat> _chats;

  CollectionReference _historyCollection(Chat chat) =>
      _chatsCollection.doc(chat.id).collection('history');

  List<Chat> get chats => _chats;

  Future<Chat> addChat() async {
    final chat = Chat(
      id: const Uuid().v4(),
      title: newChatTitle,
    );

    _chats.add(chat);
    notifyListeners();
    await _chatsCollection.doc(chat.id).set(chat.toJson());

    return chat;
  }

  Future<void> updateChat(Chat chat) async {
    final i = _chats.indexWhere((m) => m.id == chat.id);
    assert(i >= 0);
    _chats[i] = chat;
    notifyListeners();
    await _chatsCollection.doc(chat.id).update(chat.toJson());
  }

  Future<void> deleteChat(Chat chat) async {
    final removed = _chats.remove(chat);
    assert(removed);

    // TODO: does this delete the history, too? it should.
    await _chatsCollection.doc(chat.id).delete();
    notifyListeners();

    // if we've deleted the last chat, add a new one
    if (_chats.isEmpty) await addChat();
  }

  Future<List<ChatMessage>> getHistory(Chat chat) async {
    final querySnapshot = await _historyCollection(chat).get();

    final indexedMessages = <int, ChatMessage>{};
    for (final doc in querySnapshot.docs) {
      final index = int.parse(doc.id);
      final message = ChatMessage.fromJson(doc.data()! as Map<String, dynamic>);
      indexedMessages[index] = message;
    }

    final messages = indexedMessages.entries
        .sortedBy((e) => e.key)
        .map((e) => e.value)
        .toList();
    return messages;
  }

  Future<void> updateHistory(Chat chat, List<ChatMessage> history) async {
    for (var i = 0; i != history.length; ++i) {
      // skip if the message already exists
      final id = i.toString().padLeft(3, '0');
      final querySnapshot = await _historyCollection(chat).doc(id).get();
      if (querySnapshot.exists) continue;

      final message = history[i];
      final json = message.toJson();
      await _historyCollection(chat).doc(id).set(json);
    }
  }
}
