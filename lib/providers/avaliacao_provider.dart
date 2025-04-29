import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limpou25k/models/avaliacao_model.dart';

class AvaliacaoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Envia uma nova avaliação e gera um ID automático
  Future<void> enviarAvaliacao(AvaliacaoModel avaliacao) async {
    final docRef = _firestore.collection('avaliacoes').doc();
    final novaAvaliacao = avaliacao.copyWith(avaliacaoId: docRef.id);

    await docRef.set(novaAvaliacao.toMap());
  }

  /// Busca todas as avaliações recebidas por um usuário
  Future<List<AvaliacaoModel>> buscarAvaliacoesDoUsuario(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('avaliacoes')
          .where('avaliadoId', isEqualTo: userId)
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AvaliacaoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar avaliações: $e');
      return [];
    }
  }

  /// Calcula a média das avaliações de um usuário
  Future<double> calcularMediaAvaliacoes(String userId) async {
    final avaliacoes = await buscarAvaliacoesDoUsuario(userId);
    if (avaliacoes.isEmpty) return 0;

    final total = avaliacoes.fold(0, (sum, a) => sum + a.nota);
    return total / avaliacoes.length;
  }
}
