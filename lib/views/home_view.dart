import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/utils/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePage> {
  List<Map<String, dynamic>> properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllProperties(); // 🔥 Carrega todas as propriedades
  }

  Future<void> _loadAllProperties() async {
    try {
      setState(() => isLoading = true);

      // 🔥 Busca todas as subcoleções "properties" de todos os usuários
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('properties')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        properties = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  "id": doc.id,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Erro ao carregar propriedades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bem-vinda ao Limpou',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade700,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 28),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? Center(
                  child: Text(
                    "Nenhuma propriedade cadastrada.",
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return _buildPropertyCard(property);
                  },
                ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // 🔥 Aqui você define o redirecionamento para a página de detalhes
          Navigator.pushNamed(context, AppRoutes.serviceDetail,
              arguments: property);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property['propertyType'] ?? "Tipo não informado",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Cidade: ${property['city'] ?? "N/A"}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Estado: ${property['state'] ?? "N/A"}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Data do serviço: ${property['date'] ?? "N/A"}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.serviceDetail,
                    arguments: property,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Ver mais",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
