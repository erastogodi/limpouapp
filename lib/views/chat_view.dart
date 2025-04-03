import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:limpou25k/providers/chat_provider.dart';
import 'package:limpou25k/models/message_model.dart';

class ChatView extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ChatView({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  }) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: (widget.receiverImage.isNotEmpty &&
                      widget.receiverImage.startsWith('http'))
                  ? NetworkImage(widget.receiverImage)
                  : const AssetImage('assets/images/user_placeholder.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverName.isNotEmpty ? widget.receiverName : 'Usuário',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream:
                  chatProvider.getMessages(currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhuma mensagem ainda."));
                }

                return ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    final isMe = message.senderId == currentUserId;
                    final timeString = _formatTimestamp(message.timestamp);

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.amber.shade700
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isMe
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottomRight: isMe
                                    ? Radius.zero
                                    : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              message.message,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: isMe ? Colors.white : Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, left: 8, bottom: 5),
                            child: Text(
                              timeString,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(chatProvider, currentUserId),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider, String senderId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Digite uma mensagem...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.amber, size: 24),
            onPressed: () {
              chatProvider.sendMessage(
                  senderId, widget.receiverId, _messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '...';
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }
}
