import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:limpou25k/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatId(String receiverId) {
    final userId = _auth.currentUser!.uid;
    List<String> ids = [userId, receiverId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    if (message.trim().isEmpty) return;

    final chatId = getChatId(receiverId);

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('messages')
        .doc(chatId)
        .collection('items')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    notifyListeners();
  }

  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(receiverId);
    return _firestore
        .collection('messages')
        .doc(chatId)
        .collection('items')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserChats() async* {
    final userId = _auth.currentUser!.uid;

    await for (final snapshot in _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()) {
      final List<Map<String, dynamic>> chats = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherId = participants.firstWhere((id) => id != userId);

        // 🔍 Busca nome e imagem do outro usuário
        final userDoc = await _firestore.collection('users').doc(otherId).get();
        final userData = userDoc.data();

        chats.add({
          'chatId': doc.id,
          'receiverId': otherId,
          'receiverName': userData?['name']?.toString().trim() ?? 'Usuário',
          'receiverImage': userData?['profilePicture'] ?? '',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'],
        });
      }

      yield chats;
    }
  }
}
