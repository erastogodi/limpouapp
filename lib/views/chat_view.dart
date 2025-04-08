import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/views/agendar_servico_view.dart';
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
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _updateLastSeen();
  }

  void _updateLastSeen() {
    final userId = _auth.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lastSeen': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
            color: Colors.black), // <-- seta de voltar preta
        title: Row(
          children: [
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 22,
              backgroundImage: (widget.receiverImage.isNotEmpty &&
                      widget.receiverImage.startsWith('http'))
                  ? NetworkImage(widget.receiverImage)
                  : const AssetImage('assets/images/user_placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.receiverId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox();
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final Timestamp? lastSeen = data?['lastSeen'];

                      if (lastSeen == null) return const SizedBox();

                      final seen = lastSeen.toDate();
                      final diff = DateTime.now().difference(seen);
                      final status = diff.inSeconds < 60
                          ? 'Online'
                          : diff.inMinutes < 60
                              ? 'Visto há ${diff.inMinutes} min'
                              : diff.inHours < 24
                                  ? 'Visto há ${diff.inHours} horas'
                                  : 'Visto há ${diff.inDays} d';

                      return Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(10, 36),
                backgroundColor: Colors.white.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black.withOpacity(0.2)),
                ),
              ),
              onPressed: () async {
                final receiverId = widget.receiverId;
                final receiverSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(receiverId)
                    .get();

                if (!receiverSnapshot.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário não encontrado')),
                  );
                  return;
                }

                final receiverData = receiverSnapshot.data()!;
                final userType = receiverData['userType'];
                final name = receiverData['name'] ?? 'Usuário';
                final image = receiverData['profilePicture'] ?? '';
                final email = receiverData['email'] ?? '';

                // 🔎 Busca as propriedades do contratante
                final propertiesSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(receiverId)
                    .collection('properties')
                    .orderBy('createdAt', descending: true)
                    .get();

                final properties = propertiesSnapshot.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data(),
                        })
                    .toList();

                // ⚠️ Se for contratante e não tiver propriedades
                if (userType == 'Contratante' && properties.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Este contratante não possui anúncios ativos no momento.')),
                  );
                  return;
                }

                final isCurrentUserContratante =
                    receiverData['userType'] == 'Doméstica';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgendarServicoView(
                      contractorId: isCurrentUserContratante
                          ? currentUserId
                          : receiverId, // 👈 Contratante é o dono dos anúncios
                      workerId: isCurrentUserContratante
                          ? receiverId
                          : currentUserId, // 👈 Diarista é quem prestará o serviço
                      receiverInfo: {
                        'name': name,
                        'email': email,
                        'profilePicture': image,
                      },
                      properties: properties,
                    ),
                  ),
                );
              },
              child: Text(
                "Solicitar Agendamento",
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon:
                  const Icon(Icons.more_vert, color: Colors.black), // <-- preto
              onSelected: (value) async {
                if (value == 'excluir') {
                  await chatProvider.deleteChat(widget.receiverId);
                  if (mounted) Navigator.pop(context);
                } else if (value == 'denunciar') {
                  _mostrarDialogoDenuncia();
                } else if (value == 'agendar') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Funcionalidade de agendamento em desenvolvimento.'),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'excluir', child: Text('Excluir conversa')),
                PopupMenuItem(
                    value: 'denunciar', child: Text('Denunciar usuário')),
                PopupMenuItem(
                    value: 'agendar', child: Text('Realizar agendamento')),
              ],
            ),
            const SizedBox(width: 2),
          ],
        ),
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
                                  ? Colors.blue.shade100
                                  : Colors.amber.shade700,
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
                                color: isMe ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, left: 8, bottom: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeString,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (isMe)
                                  Icon(
                                    message.read ? Icons.done_all : Icons.done,
                                    size: 16,
                                    color: message.read
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                              ],
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

  void _mostrarDialogoDenuncia() {
    final TextEditingController _motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Denunciar usuário",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Informe o motivo da denúncia. Isso será encaminhado à equipe de suporte.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _motivoController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Digite aqui o motivo...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final motivo = _motivoController.text.trim();

                      if (motivo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Por favor, escreva o motivo da denúncia."),
                          ),
                        );
                        return;
                      }

                      Navigator.of(ctx).pop();

                      await Provider.of<ChatProvider>(context, listen: false)
                          .blockAndReportUser(widget.receiverId, motivo);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Usuário denunciado e bloqueado com sucesso."),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Confirmar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '...';
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} horas';
    return '${diff.inDays} d';
  }
}
