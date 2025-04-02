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
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchDomesticas();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
          : userProvider.domesticas.isEmpty
              ? const Center(
                  child: Text("Nenhum usuário encontrado",
                      style: TextStyle(fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: userProvider.domesticas.length,
                    itemBuilder: (context, index) {
                      final selectedUser = userProvider.domesticas[index];
                      return _buildUserCard(context, selectedUser);
                    },
                  ),
                ),
    );
  }

  /// **🔹 Constrói um card para cada usuário**
  Widget _buildUserCard(BuildContext context, UserModel selectedUser) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **📸 Imagem de perfil (logo padrão)**
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: const AssetImage('assets/logo.jpeg'),
                ),
                const SizedBox(width: 16),

                // **📌 Nome e distância**
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedUser.name,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 18),
                          Text(
                            "${_getSimulatedDistance().toStringAsFixed(2)} km de distância",
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

            // **⬇ Seção de "Serviços Concluídos" e "Avaliações" no canto inferior esquerdo**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ** Serviços concluídos simulados**
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "🔹 ${_getSimulatedServicesCompleted()} serviços concluídos",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
// **⭐ Avaliações (Agora centralizado com a Rating Bar)**
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Avaliações",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RatingBarIndicator(
                              rating: _getSimulatedRating(),
                              itemBuilder: (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 22.0,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _getSimulatedRating().toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // **🟡 Botão "Ver Perfil" alinhado com a Rating Bar**
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.perfilDomestica,
                      arguments: selectedUser.id, // ✅ Passa apenas o ID
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ver Perfil',
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Simula uma distância entre 1 e 20 km**
  double _getSimulatedDistance() {
    return (1 + (20 - 1) * (DateTime.now().millisecondsSinceEpoch % 100) / 100)
        .toDouble()
        .clamp(1, 20);
  }

  /// **🔹 Simula uma nota entre 3.5 e 5.0**
  double _getSimulatedRating() {
    return (3.5 +
            (5.0 - 3.5) * (DateTime.now().millisecondsSinceEpoch % 100) / 100)
        .toDouble()
        .clamp(3.5, 5.0);
  }

  /// **🔹 Simula serviços concluídos entre 10 e 100**
  int _getSimulatedServicesCompleted() {
    return 10 + (DateTime.now().millisecondsSinceEpoch % 91);
  }
}
