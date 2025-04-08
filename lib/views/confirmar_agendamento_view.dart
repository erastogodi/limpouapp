import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/providers/agendamento_provider.dart';
import 'package:provider/provider.dart';

class ConfirmarAgendamentoView extends StatefulWidget {
  final AgendamentoModel agendamento;

  const ConfirmarAgendamentoView({Key? key, required this.agendamento})
      : super(key: key);

  @override
  State<ConfirmarAgendamentoView> createState() =>
      _ConfirmarAgendamentoViewState();
}

class _ConfirmarAgendamentoViewState extends State<ConfirmarAgendamentoView> {
  Map<String, dynamic>? contractorData;
  Map<String, dynamic>? propertyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final ag = widget.agendamento;
    try {
      final contractorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ag.contractorId)
          .get();

      final propertySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ag.contractorId)
          .collection('properties')
          .doc(ag.propertyId)
          .get();

      setState(() {
        contractorData = contractorSnapshot.data();
        propertyData = propertySnapshot.data();
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDateTime(DateTime dt) {
    final formatter = DateFormat('dd/MM/yyyy – HH:mm');
    return formatter.format(dt);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _atualizarStatus(String status) async {
    await Provider.of<AgendamentoProvider>(context, listen: false)
        .atualizarStatus(widget.agendamento.serviceId, status);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('Agendamento ${status == 'accepted' ? 'aceito' : 'recusado'}.'),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ag = widget.agendamento;
    final valorComTaxa = (ag.price * 1.05).toStringAsFixed(2);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Agendamento"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informações do Agendamento",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Data e Hora", formatDateTime(ag.serviceDate)),
            _buildInfoRow("Valor com taxa", "R\$ $valorComTaxa"),
            _buildInfoRow("Notas", ag.notes),
            const Divider(height: 32),
            Text(
              "Informações do Local",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow("Endereço", propertyData?['endereco'] ?? '---'),
            _buildInfoRow("Tipo", propertyData?['tipo'] ?? '---'),
            _buildInfoRow("Tamanho", propertyData?['tamanho'] ?? '---'),
            const Divider(height: 32),
            Text(
              "Contratante",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildInfoRow("Nome", contractorData?['name'] ?? '---'),
            _buildInfoRow("Telefone", contractorData?['telefone'] ?? '---'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _atualizarStatus('accepted'),
                  icon: const Icon(Icons.check),
                  label: const Text("Aceitar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _atualizarStatus('refused'),
                  icon: const Icon(Icons.close),
                  label: const Text("Recusar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/agendar-servico',
                      arguments: {
                        'contractorId': ag.workerId,
                        'workerId': ag.contractorId,
                        'receiverInfo': contractorData ?? {},
                        'properties': [], // você pode buscar se quiser
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text("Propor Novo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
