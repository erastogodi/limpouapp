import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:limpou25k/models/agendamento_model.dart';

class AgendamentoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> criarAgendamento(AgendamentoModel agendamento) async {
    try {
      final docRef = _firestore.collection('agendamentos').doc();

      final novoAgendamento = agendamento.copyWith(
        serviceId: docRef.id,
        createdAt: DateTime.now(),
        status: 'pending',
        paymentConfirmed: false,
        confirmedByContractor: false,
        confirmedByWorker: false,
      );

      await docRef.set(novoAgendamento.toMap());
    } catch (e) {
      throw Exception("Erro ao criar agendamento: $e");
    }
  }

  Future<void> atualizarStatus(String serviceId, String novoStatus) async {
    try {
      await _firestore.collection('agendamentos').doc(serviceId).update({
        'status': novoStatus,
      });
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao atualizar status: $e");
    }
  }

  Future<void> aceitarAgendamento(String serviceId) async {
    await atualizarStatus(serviceId, 'accepted');
  }

  Future<void> recusarAgendamento(String serviceId) async {
    await atualizarStatus(serviceId, 'refused');
  }
}
