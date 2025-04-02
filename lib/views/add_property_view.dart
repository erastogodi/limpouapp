import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/property_provider.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:limpou25k/views/create_property_view.dart';
import 'package:provider/provider.dart';

class AddPropertyView extends StatefulWidget {
  const AddPropertyView({Key? key}) : super(key: key);

  @override
  _AddPropertyViewState createState() => _AddPropertyViewState();
}

class _AddPropertyViewState extends State<AddPropertyView> {
  List<Map<String, dynamic>> properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProperties();

    // Recarregar os imóveis quando a tela voltar do CreatePropertyView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: deprecated_member_use
      ModalRoute.of(context)?.addScopedWillPopCallback(() {
        _loadUserProperties();
        return Future.value(true);
      });
    });
  }

  Future<void> _loadUserProperties() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      setState(() => properties = []); // 🔹 Limpa os dados antes de buscar

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("properties")
          .orderBy("createdAt", descending: true)
          .get();

      setState(() {
        properties = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  "id": doc.id, // Adiciona o ID do documento
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erro ao carregar propriedades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Adicionar Imóvel",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seus Anúncios Ativos",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  properties.isEmpty
                      ? Center(
                          child: Text(
                            "Nenhuma propriedade cadastrada.",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        )
                      : Column(
                          children: properties
                              .map((property) => _buildPropertyCard(property))
                              .toList(),
                        ),
                  const SizedBox(height: 20),
                  _buildAddPropertyButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/images/casa.jpg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['address'] ?? "Endereço não informado",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text('Tipo: ${property['propertyType'] ?? "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text('Quartos: ${property['bedrooms'] ?? "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text('Banheiros: ${property['bathrooms'] ?? "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text(
                    'Áreas a serem limpas: ${property['areasToClean'] ?? "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text(
                    'Materiais fornecidos: ${property['materialsProvided'] ?? "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreatePropertyView(propertyId: property['id']),
                          ),
                        );

                        // Se retornar "true", recarrega os dados
                        if (updated == true) {
                          _loadUserProperties();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Confirmar Exclusão"),
                            content: Text(
                                "Tem certeza que deseja excluir este anúncio?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Excluir",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete) {
                          await Provider.of<PropertyProvider>(context,
                                  listen: false)
                              .deleteProperty(property['id']);
                          _loadUserProperties(); // Recarrega a lista após exclusão
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPropertyButton() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ElevatedButton(
          onPressed: () async {
            bool? updated = await Navigator.pushNamed(
              context,
              AppRoutes.createProperty,
            ) as bool?;

            // Se um novo imóvel foi adicionado, recarrega os imóveis
            if (updated == true) {
              _loadUserProperties();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.amber.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Criar Anúncio",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
