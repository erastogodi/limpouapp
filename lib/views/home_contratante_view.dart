import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/models/user_model.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomeContratanteView extends StatefulWidget {
  const HomeContratanteView({Key? key}) : super(key: key);

  @override
  _HomeContratanteViewState createState() => _HomeContratanteViewState();
}

class _HomeContratanteViewState extends State<HomeContratanteView> {
  double _raioFiltro = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserData();
      await userProvider.fetchDomesticas(); // ← ainda chama assim internamente
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    List<Map<String, dynamic>> diaristasFiltradas = [];

    if (user != null && user.latitude != null && user.longitude != null) {
      diaristasFiltradas = userProvider.domesticas
          .where((d) => d.latitude != null && d.longitude != null)
          .map((diarista) {
            final distancia = _calcularDistancia(
              user.latitude!,
              user.longitude!,
              diarista.latitude!,
              diarista.longitude!,
            );
            return {
              'diarista': diarista,
              'distancia': distancia,
            };
          })
          .where((item) =>
              (item['distancia'] as double? ?? double.infinity) <= _raioFiltro)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bem-vindo ao Limpou',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFBC02D),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: const Color(0xFFFFF8E1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Filtrar por distância",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.amber,
                          thumbColor: Colors.amber,
                          overlayColor: Colors.amber.withOpacity(0.2),
                          inactiveTrackColor: Colors.amber.shade100,
                        ),
                        child: Slider(
                          min: 1,
                          max: 100,
                          divisions: 99,
                          value: _raioFiltro,
                          label: "${_raioFiltro.toStringAsFixed(0)} km",
                          onChanged: (value) {
                            setState(() {
                              _raioFiltro = value;
                            });
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Raio atual: ${_raioFiltro.toStringAsFixed(0)} km",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: diaristasFiltradas.isEmpty
                      ? const Center(
                          child: Text("Nenhuma diarista encontrada nesse raio.",
                              style: TextStyle(fontSize: 18)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: diaristasFiltradas.length,
                          itemBuilder: (context, index) {
                            final diarista = diaristasFiltradas[index]
                                ['diarista'] as UserModel;
                            final distancia = diaristasFiltradas[index]
                                ['distancia'] as double;
                            return _buildUserCard(context, diarista, distancia);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, UserModel diarista, double distancia) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _carregarDadosAdicionaisDiarista(diarista.id),
      builder: (context, snapshot) {
        final mediaNota = snapshot.data?['mediaNota'] ?? 0.0;
        final totalServicos = snapshot.data?['totalServicos'] ?? 0;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: const AssetImage('assets/logo.jpeg'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diarista.name,
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 18),
                              Text(
                                "${distancia.toStringAsFixed(2)} km de distância",
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$totalServicos serviços concluídos",
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text("Avaliações",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            RatingBarIndicator(
                              rating: mediaNota,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 22.0,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              mediaNota.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ]),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.perfilDomestica,
                          arguments: diarista.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Ver Perfil',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  double _calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    final double dLat = _grausParaRadianos(lat2 - lat1);
    final double dLon = _grausParaRadianos(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_grausParaRadianos(lat1)) *
            cos(_grausParaRadianos(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _grausParaRadianos(double graus) => graus * pi / 180;
  Future<Map<String, dynamic>> _carregarDadosAdicionaisDiarista(
      String userId) async {
    final firestore = FirebaseFirestore.instance;

    // Buscar média de avaliações
    final avaliacoesSnap = await firestore
        .collection('avaliacoes')
        .where('avaliadoId', isEqualTo: userId)
        .get();

    final avaliacoes = avaliacoesSnap.docs;
    double mediaNota = 0;
    if (avaliacoes.isNotEmpty) {
      final totalNotas =
          avaliacoes.fold<double>(0.0, (sum, doc) => sum + (doc['nota'] ?? 0));
      mediaNota = totalNotas / avaliacoes.length;
    }

    // Buscar número de serviços finalizados
    final agendamentosSnap = await firestore
        .collection('agendamentos')
        .where('workerId', isEqualTo: userId)
        .where('status', isEqualTo: 'finalizado')
        .get();

    final totalServicos = agendamentosSnap.docs.length;

    return {
      'mediaNota': mediaNota,
      'totalServicos': totalServicos,
    };
  }
}
