import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendamentosListView extends StatelessWidget {
  const AgendamentosListView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> agendamentos = [
      {
        'nome': 'Maria Doméstica',
        'data': '10/04/2025',
        'hora': '14:00',
        'status': 'Pendente',
        'valor': 120.0,
      },
      {
        'nome': 'Carlos Silva',
        'data': '12/04/2025',
        'hora': '08:30',
        'status': 'Confirmado',
        'valor': 150.0,
      },
      {
        'nome': 'Joana Lima',
        'data': '15/04/2025',
        'hora': '16:00',
        'status': 'Aguardando Confirmação',
        'valor': 100.0,
      },
    ];

    // Cores de fundo mais visíveis
    Color _getCardColor(String status) {
      switch (status) {
        case 'Confirmado':
          return Colors.green.withOpacity(0.25);
        case 'Pendente':
          return Colors.amber.withOpacity(0.3);
        case 'Aguardando Confirmação':
          return Colors.blueGrey.withOpacity(0.3);
        default:
          return Colors.grey.withOpacity(0.2);
      }
    }

    // Ícones pequenos ao lado do texto do status
    Icon _getStatusIcon(String status) {
      switch (status) {
        case 'Confirmado':
          return const Icon(Icons.check_circle, color: Colors.green, size: 18);
        case 'Pendente':
          return const Icon(Icons.access_time, color: Colors.amber, size: 18);
        case 'Aguardando Confirmação':
          return const Icon(Icons.hourglass_empty,
              color: Colors.blueGrey, size: 18);
        default:
          return const Icon(Icons.info_outline, size: 18);
      }
    }

    // Ícone grande decorativo no canto superior
    IconData _getDecorativeIcon(String status) {
      switch (status) {
        case 'Confirmado':
          return Icons.verified;
        case 'Pendente':
          return Icons.schedule;
        case 'Aguardando Confirmação':
          return Icons.hourglass_top;
        default:
          return Icons.info;
      }
    }

    Color _getIconColor(String status) {
      switch (status) {
        case 'Confirmado':
          return Colors.green.shade800;
        case 'Pendente':
          return Colors.amber.shade800;
        case 'Aguardando Confirmação':
          return Colors.blueGrey.shade700;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: ListView.builder(
        itemCount: agendamentos.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final agendamento = agendamentos[index];
          final status = agendamento['status'];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCardColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Conteúdo do card
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agendamento['nome'],
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
                        Text(
                            '${agendamento['data']} às ${agendamento['hora']}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _getStatusIcon(status),
                        const SizedBox(width: 6),
                        Text(
                          'Status: $status',
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
                          'Valor: R\$ ${agendamento['valor'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          // ação de detalhes
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

                // Ícone decorativo no canto superior direito
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
        },
      ),
    );
  }
}
