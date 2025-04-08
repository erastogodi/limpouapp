import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/providers/agendamento_provider.dart';
import 'package:limpou25k/views/agendamentos_list_view.dart';
import 'package:provider/provider.dart';

class AgendarServicoView extends StatefulWidget {
  final String contractorId;
  final String workerId;
  final Map<String, dynamic> receiverInfo; // ✅ agora armazenado corretamente
  final List<Map<String, dynamic>> properties;

  const AgendarServicoView({
    super.key,
    required this.contractorId,
    required this.workerId,
    required this.receiverInfo, // ✅ corrigido
    required this.properties,
  });

  @override
  State<AgendarServicoView> createState() => _AgendarServicoViewState();
}

class _AgendarServicoViewState extends State<AgendarServicoView> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 12, minute: 0);
  int selectedPrice = 100;
  String? selectedPropertyId;
  final TextEditingController _notesController = TextEditingController();
  List<DateTime> horarios = [];

  @override
  void initState() {
    super.initState();
    for (int hour = 0; hour <= 23; hour++) {
      horarios.add(DateTime(0, 1, 1, hour, 0)); // exemplo: 10:00, 11:00...
      horarios.add(DateTime(0, 1, 1, hour, 30)); // exemplo: 10:30, 11:30...
    }
  }

  String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);

  @override
  Widget build(BuildContext context) {
    final valorComTaxa = selectedPrice * 1.05;

    // ✅ Correção: usando os dados passados via receiverInfo corretamente
    final userData = widget.receiverInfo;
    final isDiarista = widget.contractorId != widget.workerId;
    final userType = isDiarista ? 'Doméstica' : 'Contratante';

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.contractorId)
          .collection('properties')
          .orderBy('createdAt', descending: true)
          .get(),
      builder: (context, propSnapshot) {
        if (!propSnapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final properties = propSnapshot.data!.docs;

        if (widget.contractorId == widget.workerId && properties.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Você precisa ter ao menos um anúncio ativo.")),
            );
          });
          return const Scaffold();
        }

        if (userType == 'Doméstica' &&
            properties.isEmpty &&
            widget.contractorId != widget.workerId) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Agendar Serviço"),
              backgroundColor: Colors.amber.shade700,
            ),
            body: const Center(
              child: Text(
                  "O usuário com quem você está conversando não possui nenhum anúncio ativo."),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber.shade700,
            title: const Text('Agendar Serviço'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      userType == 'Contratante' ? "Informações" : "Informações",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildUserCard(userData),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Selecione um dos anúncios abaixo para solicitar o serviço:",
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                _buildPropertyGrid(properties),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.calendar_today,
                  title: "Data do serviço*",
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: _boxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: GoogleFonts.poppins(fontSize: 16)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: const Text("Alterar"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.access_time,
                  title: "Horário do serviço*",
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: _boxDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateTime>(
                        value: horarios.first,
                        isExpanded: true,
                        items: horarios.map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Text(_formatTime(h)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() =>
                                selectedTime = TimeOfDay.fromDateTime(value));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.attach_money,
                  title: "Valor do serviço (R\$)*",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: _boxDecoration(),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedPrice,
                            isExpanded: true,
                            items: List.generate(
                                91,
                                (index) => DropdownMenuItem(
                                      value: 50 + index * 10,
                                      child: Text(
                                          'R\$ ${(50 + index * 10).toStringAsFixed(2)}'),
                                    )),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedPrice = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            "Valor com taxa (5%): R\$ ${valorComTaxa.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.notes,
                  title: "Observações (opcional)",
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: _boxDecoration(),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Informações adicionais...",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(color: Colors.black54),
                      ),
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.amber.shade300, // 🌟 amarelo mais forte
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (selectedPropertyId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Selecione uma propriedade.")),
                        );
                        return;
                      }

                      final dataHoraFinal = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final novoAgendamento = AgendamentoModel(
                        serviceId: '', // será gerado no provider
                        propertyId: selectedPropertyId!,
                        createdBy: FirebaseFirestore.instance
                            .collection('users')
                            .doc()
                            .id, // ou você pode usar: FirebaseAuth.instance.currentUser!.uid,
                        contractorId: widget.contractorId,
                        workerId: widget.workerId,
                        status: 'pending',
                        price: selectedPrice.toDouble(),
                        paymentConfirmed: false,
                        serviceDate: dataHoraFinal,
                        createdAt: DateTime.now(),
                        notes: _notesController.text.trim(),
                        confirmedByWorker: false,
                        confirmedByContractor: false,
                      );

                      await Provider.of<AgendamentoProvider>(context,
                              listen: false)
                          .criarAgendamento(novoAgendamento);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Solicitação enviada com sucesso.")),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AgendamentosListView(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: Text(
                      "Enviar solicitação de serviço",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54, // 🎨 texto um pouco mais fraco
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: userData['profilePicture'] != null &&
                    userData['profilePicture'].toString().isNotEmpty
                ? NetworkImage(userData['profilePicture'])
                : const AssetImage("assets/images/user_placeholder.png")
                    as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(
            userData['name'] ?? "Usuário",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text("5 serviços realizados",
              style: GoogleFonts.poppins(fontSize: 13),
              textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Icon(Icons.star,
                  color: i < 4 ? Colors.amber : Colors.grey.shade300, size: 16);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyGrid(List<QueryDocumentSnapshot> properties) {
    return Column(
      children: List.generate(
        (properties.length / 2).ceil(),
        (i) {
          final first = properties[i * 2];
          final second =
              (i * 2 + 1 < properties.length) ? properties[i * 2 + 1] : null;

          return Row(
            children: [
              Expanded(child: _buildPropertyCard(first)),
              const SizedBox(width: 10),
              Expanded(
                  child: second != null
                      ? _buildPropertyCard(second)
                      : Container()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bool selected = selectedPropertyId == doc.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPropertyId = doc.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? Colors.amber.shade700 : Colors.grey.shade300,
              width: selected ? 2.5 : 1),
          color: selected ? Colors.amber.shade50 : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/images/casa.jpg',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['address'] ?? "Sem endereço",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Tipo: ${data['propertyType'] ?? 'N/A'}",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  Text("Quartos: ${data['bedrooms'] ?? 'N/A'}",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  Text("Banheiros: ${data['bathrooms'] ?? 'N/A'}",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  Text("Materiais: ${data['materialsProvided'] ?? 'N/A'}",
                      style: GoogleFonts.poppins(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade400),
    );
  }

  Future<void> _enviarSolicitacao() async {
    if (selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma propriedade.")),
      );
      return;
    }

    final DateTime dataHoraFinal = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final novoAgendamento = AgendamentoModel(
      serviceId: '',
      propertyId: selectedPropertyId!,
      createdBy: widget.workerId, // Usando o workerId, conforme sua lógica
      contractorId: widget.contractorId,
      workerId: widget.workerId,
      status: 'pending',
      price: selectedPrice.toDouble(),
      paymentConfirmed: false,
      serviceDate: dataHoraFinal,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim(),
      confirmedByWorker: false,
      confirmedByContractor: false,
    );

    await Provider.of<AgendamentoProvider>(context, listen: false)
        .criarAgendamento(novoAgendamento);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitação enviada com sucesso.")),
      );
      // Redireciona para a tela de listagem de agendamentos
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AgendamentosListView(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
