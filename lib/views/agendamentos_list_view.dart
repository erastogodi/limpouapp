import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:limpou25k/providers/agendamento_provider.dart';
import 'package:limpou25k/providers/auth_provider.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AgendamentosListView extends StatelessWidget {
  const AgendamentosListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.getCurrentUser();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: StreamBuilder<List<AgendamentoModel>>(
        stream: Provider.of<AgendamentoProvider>(context)
            .getAgendamentosPorUsuario(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final agendamentos = snapshot.data ?? [];

          if (agendamentos.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado.'));
          }

          return ListView.builder(
            itemCount: agendamentos.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              final isContratante = agendamento.contractorId == userId;
              final outroId = isContratante
                  ? agendamento.workerId
                  : agendamento.contractorId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(outroId)
                    .get(),
                builder: (context, snapshotUser) {
                  String nome = 'Carregando...';

                  if (snapshotUser.hasData && snapshotUser.data!.exists) {
                    nome = snapshotUser.data!['name'] ?? 'Nome não disponível';
                  }

                  return _buildAgendamentoCard(context, agendamento, nome);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAgendamentoCard(
      BuildContext context, AgendamentoModel agendamento, String nome) {
    final status = agendamento.status;
    final dataHoraFormatada =
        DateFormat('dd/MM/yyyy – HH:mm').format(agendamento.serviceDate);

    Color _getCardColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.grey.withOpacity(0.2); // 🔘 Pendente
        case 'aguardando confirmação':
          return Colors.lightBlue[100]!; // 🔵 Aguardando Confirmação
        case 'aguardando pagamento':
          return Colors.amber.withOpacity(0.3); // 🟨 Aguardando Pagamento
        case 'confirmado':
          return Colors.green[100]!; // ✅ Verde claro para Confirmado
        case 'finalizado':
          return Colors.green[200]!; // 🟢 Verde médio para Finalizado
        default:
          return Colors.grey[200]!;
      }
    }

    Icon _getStatusIcon(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return const Icon(Icons.access_time, color: Colors.grey, size: 18);
        case 'aguardando confirmação':
          return const Icon(Icons.hourglass_top,
              color: Colors.lightBlue, size: 18);
        case 'aguardando pagamento':
          return const Icon(Icons.payment, color: Colors.amber, size: 18);
        case 'confirmado':
          return const Icon(Icons.check_circle, color: Colors.green, size: 18);
        case 'finalizado':
          return const Icon(Icons.done_all, color: Colors.green, size: 18);
        default:
          return const Icon(Icons.info_outline, color: Colors.grey, size: 18);
      }
    }

    IconData _getDecorativeIcon(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Icons.schedule;
        case 'aguardando confirmação':
          return Icons.hourglass_empty;
        case 'aguardando pagamento':
          return Icons.attach_money;
        case 'confirmado':
          return Icons.verified;
        case 'finalizado':
          return Icons.done_all;
        default:
          return Icons.info;
      }
    }

    Color _getIconColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.grey;
        case 'aguardando confirmação':
          return Colors.lightBlue;
        case 'aguardando pagamento':
          return Colors.amber;
        case 'confirmado':
          return Colors.green;
        case 'finalizado':
          return Colors.green[800]!;
        default:
          return Colors.grey;
      }
    }

    String _formatarStatus(String status) {
      if (status.toLowerCase() == 'pending') return 'Pendente';

      return status.isNotEmpty
          ? status[0].toUpperCase() + status.substring(1)
          : status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(dataHoraFormatada),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _getStatusIcon(status),
                  const SizedBox(width: 6),
                  Text(
                    'Status: ${_formatarStatus(status)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Valor: R\$ ${agendamento.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.confirmarAgendamento,
                      arguments: agendamento,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text(
                    "Ver detalhes",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              _getDecorativeIcon(status),
              size: 36,
              color: _getIconColor(status).withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
