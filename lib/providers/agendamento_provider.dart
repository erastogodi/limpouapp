import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';

class AgendamentoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo agendamento
  Future<void> criarAgendamento(AgendamentoModel agendamento) async {
    await _firestore.collection('agendamentos').add(agendamento.toMap());
  }

  Stream<List<AgendamentoModel>> getAgendamentosPorUsuario(String uid) {
    return _firestore
        .collection('agendamentos')
        .where(
          Filter.or(
            Filter("contractorId", isEqualTo: uid),
            Filter("workerId", isEqualTo: uid),
          ),
        )
        .orderBy("serviceDate")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgendamentoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Atualiza o status de um agendamento
  Future<void> atualizarStatus(String agendamentoId, String status) async {
    await _firestore.collection('agendamentos').doc(agendamentoId).update({
      'status': status,
    });
  }

  /// Atualiza confirmação de pagamento
  Future<void> confirmarPagamento(String agendamentoId) async {
    await _firestore.collection('agendamentos').doc(agendamentoId).update({
      'paymentConfirmed': true,
    });
  }

  /// Atualiza confirmação do contratante ou trabalhador
  Future<void> atualizarConfirmacoes({
    required String agendamentoId,
    bool? confirmadoPeloTrabalhador,
    bool? confirmadoPeloContratante,
  }) async {
    Map<String, dynamic> updates = {};
    if (confirmadoPeloTrabalhador != null) {
      updates['confirmedByWorker'] = confirmadoPeloTrabalhador;
    }
    if (confirmadoPeloContratante != null) {
      updates['confirmedByContractor'] = confirmadoPeloContratante;
    }
    if (updates.isNotEmpty) {
      await _firestore
          .collection('agendamentos')
          .doc(agendamentoId)
          .update(updates);
    }
  }

  Future<void> atualizarAgendamentoCompleto(
      AgendamentoModel agendamento) async {
    try {
      await _firestore
          .collection('agendamentos')
          .doc(agendamento.serviceId)
          .update(agendamento.toMap());
    } catch (e) {
      throw Exception("Erro ao atualizar agendamento: $e");
    }
  }
}
