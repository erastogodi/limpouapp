import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/providers/agendamento_provider.dart';
import 'package:limpou25k/providers/property_provider.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ConfirmarAgendamentoView extends StatefulWidget {
  final AgendamentoModel agendamento;
  final Map propertyData;
  final Map contractorData;

  const ConfirmarAgendamentoView({
    super.key,
    required this.agendamento,
    required this.propertyData,
    required this.contractorData,
  });

  @override
  State<ConfirmarAgendamentoView> createState() =>
      _ConfirmarAgendamentoViewState();
}

class _ConfirmarAgendamentoViewState extends State<ConfirmarAgendamentoView> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? propertyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      final authUser = FirebaseAuth.instance.currentUser;

      final isLogadoContratante =
          authUser?.uid == widget.agendamento.contractorId;
      final uidOutroUsuario = isLogadoContratante
          ? widget.agendamento.workerId
          : widget.agendamento.contractorId;

      await userProvider.fetchUserById(uidOutroUsuario);
      userData = userProvider.selectedUser?.toMap();

      propertyData = await propertyProvider.getPropertyByIdFromUser(
        widget.agendamento.propertyId,
        widget.agendamento.contractorId,
      );

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _atualizarStatusAceitar() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    final agendamento = widget.agendamento;
    final isLogadoContratante = authUser.uid == agendamento.contractorId;

    bool novoConfirmedByContractor = agendamento.confirmedByContractor;
    bool novoConfirmedByWorker = agendamento.confirmedByWorker;
    String novoStatus = "aguardando confirmação";

    if (isLogadoContratante) {
      novoConfirmedByContractor = true;
    } else {
      novoConfirmedByWorker = true;
    }

    if (novoConfirmedByContractor && novoConfirmedByWorker) {
      novoStatus = "aguardando pagamento";
    }

    final novoAgendamento = agendamento.copyWith(
      confirmedByContractor: novoConfirmedByContractor,
      confirmedByWorker: novoConfirmedByWorker,
      status: novoStatus,
    );

    await Provider.of<AgendamentoProvider>(context, listen: false)
        .atualizarAgendamentoCompleto(novoAgendamento);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento atualizado: $novoStatus')),
      );
      Navigator.pop(context);
    }
  }

  TextStyle get _sectionTitle => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );

  TextStyle get _text => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black87,
      );

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(title, style: _sectionTitle)),
        const SizedBox(height: 12),
        ...children,
        const Divider(height: 40, thickness: 0.8),
      ],
    );
  }

  String _listToString(dynamic value) {
    if (value is List) return value.join(', ');
    return value?.toString() ?? '---';
  }

  Widget _buildBotaoVerde(String texto, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFAEEEC4), Color(0xFF7DD89C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVermelho(String texto, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF9D1D1), Color(0xFFF47777)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoAmarelo(String texto, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFEE58)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotoesPorStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child:
                        _buildBotaoVerde("Aceitar", _atualizarStatusAceitar)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildBotaoVermelho("Recusar", () async {
                  await FirebaseFirestore.instance
                      .collection('agendamentos')
                      .doc(widget.agendamento.serviceId)
                      .delete();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Agendamento recusado.")),
                    );
                    Navigator.pop(context);
                  }
                })),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/agendar-servico',
                    arguments: {
                      'contractorId': widget.agendamento.workerId,
                      'workerId': widget.agendamento.contractorId,
                      'receiverInfo': userData ?? {},
                      'properties': [],
                    },
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.amber.shade800, width: 1.5),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                child: const Text("Fazer Contra Proposta"),
              ),
            ),
          ],
        );
      case 'aguardando confirmação':
      case 'aguardando pagamento':
      case 'confirmado':
        return Row(
          children: [
            Expanded(
                child: _buildBotaoAmarelo("Editar Proposta", () {
              Navigator.pushNamed(
                context,
                '/agendar-servico',
                arguments: {
                  'contractorId': widget.agendamento.workerId,
                  'workerId': widget.agendamento.contractorId,
                  'receiverInfo': userData ?? {},
                  'properties': [],
                },
              );
            })),
            const SizedBox(width: 10),
            Expanded(
                child: _buildBotaoVermelho("Cancelar", () async {
              await FirebaseFirestore.instance
                  .collection('agendamentos')
                  .doc(widget.agendamento.serviceId)
                  .delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Agendamento cancelado.")),
                );
                Navigator.pop(context);
              }
            })),
          ],
        );
      case 'finalizado':
        return Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              // Recarrega o agendamento diretamente do Firestore
              final docSnapshot = await FirebaseFirestore.instance
                  .collection('agendamentos')
                  .doc(widget.agendamento.serviceId)
                  .get();

              if (docSnapshot.exists) {
                final agendamentoAtualizado = AgendamentoModel.fromMap(
                  docSnapshot.data()!,
                  docSnapshot.id,
                );

                Navigator.pushNamed(
                  context,
                  '/avaliacoes',
                  arguments: {
                    'agendamento': agendamentoAtualizado,
                    'userData': userData,
                    'propertyData': propertyData,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Erro ao carregar agendamento.")),
                );
              }
            },
            icon: const Icon(Icons.star),
            label: const Text("Avaliar Serviço Realizado"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 251, 255, 0),
              foregroundColor: const Color.fromARGB(255, 85, 85, 85),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ag = widget.agendamento;
    final valorComTaxa = (ag.price * 1.05).toStringAsFixed(2);
    final horaFormatada =
        DateFormat('dd/MM/yyyy – HH:mm').format(ag.serviceDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        title: const Text("Confirmar Agendamento"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Usuário", [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundImage: userData?['profilePicture'] != null
                                ? NetworkImage(userData!['profilePicture'])
                                : const AssetImage(
                                        "assets/images/user_placeholder.png")
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 10),
                          Text(userData?['name'] ?? 'Usuário',
                              style: GoogleFonts.poppins(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text("6 serviços realizados", style: _text),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return Icon(Icons.star,
                                  color: i < 4
                                      ? Colors.amber
                                      : Colors.grey.shade300,
                                  size: 16);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  _buildSection("Agendamento", [
                    Text("Data e Hora: $horaFormatada", style: _text),
                    const SizedBox(height: 8),
                    Text("Valor com taxa: R\$ $valorComTaxa", style: _text),
                    const SizedBox(height: 8),
                    Text(
                        "Observações: ${ag.notes.isNotEmpty ? ag.notes : 'Nenhuma'}",
                        style: _text),
                  ]),
                  _buildSection("Propriedade", [
                    Text(
                        "Endereço: ${propertyData?['address']}, ${propertyData?['city']}, ${propertyData?['state']}",
                        style: _text),
                    const SizedBox(height: 8),
                    Text("Data: ${_listToString(propertyData?['date'])}",
                        style: _text),
                    Text(
                        "Tipo: ${_listToString(propertyData?['propertyType'])}",
                        style: _text),
                    Text("Espaço: ${_listToString(propertyData?['spaceType'])}",
                        style: _text),
                    Text("Tamanho: ${_listToString(propertyData?['size'])}",
                        style: _text),
                    Text("Quartos: ${_listToString(propertyData?['bedrooms'])}",
                        style: _text),
                    Text(
                        "Banheiros: ${_listToString(propertyData?['bathrooms'])}",
                        style: _text),
                    Text(
                        "Áreas a limpar: ${_listToString(propertyData?['areasToClean'])}",
                        style: _text),
                    Text(
                        "Materiais fornecidos: ${_listToString(propertyData?['materialsProvided'])}",
                        style: _text),
                  ]),
                  const SizedBox(height: 10),
                  _buildBotoesPorStatus(ag.status, context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
