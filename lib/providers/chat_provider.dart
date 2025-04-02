import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:limpou25k/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Obtém o ID do chat entre dois usuários
  String getChatId(String receiverId) {
    final userId = _auth.currentUser!.uid;
    List<String> ids = [userId, receiverId];
    ids.sort();
    return ids.join('_');
  }

  // 🔹 Envia mensagem para o Firestore
  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser!;
    final chatId = getChatId(receiverId);

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // ✅ Adiciona a mensagem à coleção de mensagens do chat
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // ✅ Atualiza a última mensagem no documento principal do chat
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),

      // 🔹 Armazena corretamente os dados dos usuários
      'user1Id': senderId,
      'user1Name': currentUser.displayName ?? 'Usuário',
      'user1Image': currentUser.photoURL ?? '',

      'user2Id': receiverId,
    }, SetOptions(merge: true));

    notifyListeners();
  }

  // 🔹 Obtém as mensagens do chat em tempo real
  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  // 🔹 Obtém as conversas do usuário logado
  Stream<List<Map<String, dynamic>>> getUserChats() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'chatId': doc.id,
          'user1Id': data['user1Id'],
          'user1Name': data['user1Name'],
          'user1Image': data['user1Image'],
          'user2Id': data['user2Id'],
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'] as Timestamp?,
        };
      }).toList();
    });
  }
}
