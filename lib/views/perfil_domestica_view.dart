import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:limpou25k/models/user_model.dart';

class PerfilDomesticaView extends StatefulWidget {
  final String userId; // ✅ ID do usuário passado pela HomeContratanteView

  const PerfilDomesticaView({Key? key, required this.userId}) : super(key: key);

  @override
  _PerfilDomesticaViewState createState() => _PerfilDomesticaViewState();
}

class _PerfilDomesticaViewState extends State<PerfilDomesticaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final selectedUser = userProvider.selectedUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil da Diarista"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (selectedUser == null) {
            return const Center(
              child: Text(
                "Erro: Usuário não encontrado.",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          return Stack(
            children: [
              _buildBackground(),

              /// 🔹 Garante que o botão fique sempre no final
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(selectedUser),
                          const SizedBox(height: 20),
                          _buildMainInfo(selectedUser),
                        ],
                      ),
                    ),
                  ),
                  _buildSolicitarContatoButton(), // 🔹 Mantém o botão fixo no final
                  const SizedBox(height: 20),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// **🔹 Fundo minimalista**
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9C4), // Amarelo claro
      ),
    );
  }

  /// **🔹 Cabeçalho com foto, nome e nota simulada**
  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          backgroundImage: user.profilePicture.isNotEmpty
              ? NetworkImage(user.profilePicture)
              : null,
          child: user.profilePicture.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          user.name.isNotEmpty ? user.name : "Nome não disponível",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        RatingBarIndicator(
          rating: 4.5, // 🔹 Simulado
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 24.0,
        ),
        Text(
          '🔹 30 serviços concluídos', // 🔹 Simulado
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  /// **🔹 Informações principais organizadas**
  Widget _buildMainInfo(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              Icons.access_time,
              "Disponibilidade",
              user.availability.isNotEmpty
                  ? user.availability.join(", ")
                  : "Não informada"),
          _divider(),
          _buildDescriptionSection(user),
        ],
      ),
    );
  }

  /// **🔹 Linha de informação com ícone**
  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber.shade800, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$label: ",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **🔹 Linha divisória suave**
  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(thickness: 1, color: Colors.black12),
    );
  }

  /// **🔹 Seção de descrição profissional**
  Widget _buildDescriptionSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sobre Mim",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          user.aboutMe.isNotEmpty
              ? user.aboutMe
              : "Nenhuma descrição adicionada.",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// **🔹 Botão estilizado de "Solicitar Contato" (sem funcionalidade no momento)**
  Widget _buildSolicitarContatoButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final selectedUser = userProvider.selectedUser;

          if (selectedUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erro: Usuário não encontrado.")),
            );
            return;
          }

          Navigator.pushNamed(
            context,
            '/chat_view',
            arguments: {
              'receiverId': widget.userId, // ID da diarista
              'receiverName': selectedUser.name,
              'receiverImage':
                  selectedUser.profilePicture, // Enviamos a foto também
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue.shade400, // 🔹 Azul claro vibrante
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5, // 🔹 Dá um efeito de destaque ao botão
        ),
        child: Text(
          'Solicitar Contato',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
