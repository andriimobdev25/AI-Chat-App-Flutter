import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

class ChatRepository extends ChangeNotifier {
  ChatRepository._({
    required CollectionReference collection,
    required List<ChatMessage> messages,
  })  : _messagesCollection = collection,
        _messages = messages;

  final CollectionReference _messagesCollection;
  final List<ChatMessage> _messages;

  static const newChatId = '__NEW_CHAT__';

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
          .collection('users/${_currentUser!.uid}/recipes');
      final messages = await ChatRepository._loadMessages(collection);
      _currentUserRepository = ChatRepository._(
        collection: collection,
        messages: messages,
      );
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

    // clear the repository cache to load the user's recipes on demand
    _currentUser = user;
    _currentUserRepository = null;
  }

  static Future<List<ChatMessage>> _loadMessages(
    CollectionReference collection,
  ) async {
    // If the collection exists and has documents, fetch all recipes
    final querySnapshot = await collection.get();
    final messages = <ChatMessage>[];
    for (final doc in querySnapshot.docs) {
      messages.add(ChatMessage.fromJson(doc.data()! as Map<String, dynamic>));
    }

    return messages;
  }

  Iterable<ChatMessage> get messages => _messages;

  ChatMessage getMessage(String chatId, String messageId) =>
      (messageId == newChatId)
          ? ChatMessage.empty(chatId, newChatId)
          : _messages.singleWhere((m) => m.id == messageId);

  Future<void> addNewMessage(ChatMessage newMessage) async {
    _messages.add(newMessage);
    await _messagesCollection.doc(newMessage.id).set(newMessage.toJson());
    notifyListeners();
  }

  Future<void> updateMessage(ChatMessage message) async {
    final i = _messages.indexWhere((m) => m.id == message.id);
    assert(i >= 0);
    _messages[i] = message;
    await _messagesCollection.doc(message.id).update(message.toJson());
    notifyListeners();
  }

  Future<void> deleteMessage(ChatMessage message) async {
    final removed = _messages.remove(message);
    assert(removed);
    await _messagesCollection.doc(message.id).delete();
    notifyListeners();
  }
}
