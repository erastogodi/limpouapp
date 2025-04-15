import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AvaliacoesView extends StatefulWidget {
  const AvaliacoesView({super.key});

  static const routeName = '/avaliacoes';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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
              _cardAvaliacao(),
              const SizedBox(height: 16),
              _cardNotaComentario(),
              const SizedBox(height: 16),
              _cardDetalhesAgendamento(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Implementar lógica de envio da avaliação aqui
                },
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

  Widget _cardAvaliacao() {
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
              children: const [
                Text(
                  'Avaliação do Serviço',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Como foi sua experiência?',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 12),
                Text(
                  'Quem você está avaliando?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
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
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.deepPurple,
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

  Widget _cardDetalhesAgendamento() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ID do Agendamento',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                '#AG12345',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Data do Serviço',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                '15/06/2023',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
