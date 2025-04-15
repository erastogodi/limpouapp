import 'package:cloud_firestore/cloud_firestore.dart';

class AvaliacaoModel {
  final String avaliacaoId;
  final String agendamentoId;
  final String avaliadorId;
  final String avaliadoId;
  final int nota;
  final String comentario;
  final DateTime data;

  AvaliacaoModel({
    required this.avaliacaoId,
    required this.agendamentoId,
    required this.avaliadorId,
    required this.avaliadoId,
    required this.nota,
    required this.comentario,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'avaliacaoId': avaliacaoId,
      'agendamentoId': agendamentoId,
      'avaliadorId': avaliadorId,
      'avaliadoId': avaliadoId,
      'nota': nota,
      'comentario': comentario,
      'data': data,
    };
  }

  factory AvaliacaoModel.fromMap(Map<String, dynamic> map, String id) {
    return AvaliacaoModel(
      avaliacaoId: id,
      agendamentoId: map['agendamentoId'] ?? '',
      avaliadorId: map['avaliadorId'] ?? '',
      avaliadoId: map['avaliadoId'] ?? '',
      nota: map['nota'] ?? 0,
      comentario: map['comentario'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
    );
  }
}
