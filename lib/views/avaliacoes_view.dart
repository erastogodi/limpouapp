import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/models/avaliacao_model.dart';
import 'package:limpou25k/providers/avaliacao_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvaliacoesView extends StatefulWidget {
  final AgendamentoModel agendamento;
  final Map userData;
  final Map propertyData;

  const AvaliacoesView({
    super.key,
    required this.agendamento,
    required this.userData,
    required this.propertyData,
  });

  @override
  State<AvaliacoesView> createState() => _AvaliacoesViewState();
}

class _AvaliacoesViewState extends State<AvaliacoesView> {
  final _comentarioController = TextEditingController();
  double _nota = 0.0;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _enviarAvaliacao() async {
    final authUser = FirebaseAuth.instance.currentUser;

    // Validação básica
    if (authUser == null ||
        _nota == 0.0 ||
        _comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos para avaliar.')),
      );
      return;
    }

    // 1. Tenta obter o serviceId (documentId do Firestore)
    String agendamentoDocId = widget.agendamento.serviceId;

    // 2. Verifica se está vazio
    if (agendamentoDocId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro interno: ID do agendamento está vazio.')),
      );
      return;
    }

    // 3. Tenta buscar o agendamento no Firestore
    final docSnapshot = await FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoDocId)
        .get();

    // 4. Verifica se o documento existe
    if (!docSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao localizar o agendamento.')),
      );
      return;
    }

    // 5. Se o campo serviceId estiver desatualizado, sincroniza
    final data = docSnapshot.data()!;
    final docId = docSnapshot.id;

    if (data['serviceId'] != docId) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(docId)
          .update({'serviceId': docId});
    }

    // 6. Recria o agendamento com ID sincronizado
    final agendamentoAtualizado = widget.agendamento.copyWith(serviceId: docId);

    // 7. Determina quem é o avaliado (a outra parte)
    final String avaliadoId = authUser.uid == agendamentoAtualizado.contractorId
        ? agendamentoAtualizado.workerId
        : agendamentoAtualizado.contractorId;

    final avaliacao = AvaliacaoModel(
      avaliacaoId: '',
      agendamentoId: docId,
      avaliadorId: authUser.uid,
      avaliadoId: avaliadoId,
      nota: _nota.toInt(),
      comentario: _comentarioController.text.trim(),
      data: DateTime.now(),
    );

    // 8. Envia para o Firestore via Provider
    await Provider.of<AvaliacaoProvider>(context, listen: false)
        .enviarAvaliacao(avaliacao);

    // 9. Feedback + redirecionamento
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação enviada com sucesso!')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/agendamentos_list', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataServico =
        DateFormat('dd/MM/yyyy').format(widget.agendamento.serviceDate);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Avaliar Serviço',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cardAvaliacao(dataServico),
              const SizedBox(height: 16),
              _cardNotaComentario(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _enviarAvaliacao,
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardAvaliacao(String dataServico) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avaliação do Serviço',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data do Serviço:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  dataServico,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nome do usuário avaliado:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.userData['name'] ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 18, // AUMENTADO
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: widget.userData['profilePicture'] != null
                ? NetworkImage(widget.userData['profilePicture'])
                : const AssetImage('assets/images/user_placeholder.png')
                    as ImageProvider,
          ),
        ],
      ),
    );
  }

  Widget _cardNotaComentario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nota',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Center(
            child: RatingBar.builder(
              initialRating: _nota,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber.shade700,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _nota = rating;
                });
              },
            ),
          ),
          const Divider(height: 24),
          const Text(
            'Comentário',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _comentarioController,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: 'Compartilhe sua experiência...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
