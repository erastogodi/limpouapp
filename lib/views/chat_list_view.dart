import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/chat_provider.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mensagens',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatProvider.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('🔥 ERRO DETALHADO: ${snapshot.error}');
            debugPrintStack(label: '⛔ Stack trace erro StreamBuilder');
            return const Center(child: Text("Erro ao carregar conversas."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma conversa encontrada.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chatData = chats[index];
              return _buildChatItem(context, chatData);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chatData) {
    final String userId = chatData['receiverId'] ?? '';
    final String contactName = chatData['receiverName'] ?? 'Usuário';
    final String contactImage = chatData['receiverImage'] ?? '';
    final String lastMessage = chatData['lastMessage'] ?? 'Nenhuma mensagem';
    final Timestamp? lastMessageTime = chatData['lastMessageTime'];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chatView,
          arguments: {
            'receiverId': userId,
            'receiverName': contactName,
            'receiverImage': contactImage,
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  (contactImage.isNotEmpty && contactImage.startsWith('http'))
                      ? NetworkImage(contactImage)
                      : const AssetImage('assets/images/user_placeholder.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contactName,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatTimestamp(lastMessageTime),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }
}
