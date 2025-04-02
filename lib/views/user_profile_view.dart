import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:provider/provider.dart';

class UserProfileView extends StatefulWidget {
  final bool isDomestic;

  const UserProfileView({
    Key? key,
    required this.isDomestic,
    required userType,
  }) : super(key: key);

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _aboutMeController;

  List<String> _selectedAvailability = [];

  final List<String> _daysOfWeek = [
    "Segunda-feira",
    "Terça-feira",
    "Quarta-feira",
    "Quinta-feira",
    "Sexta-feira",
    "Sábado",
    "Domingo"
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    userProvider.fetchUserData().then((_) {
      if (userProvider.user != null) {
        setState(() {
          _nameController =
              TextEditingController(text: userProvider.user!.name);
          _emailController =
              TextEditingController(text: userProvider.user!.email);
          _phoneController =
              TextEditingController(text: userProvider.user!.phone);
          _aboutMeController =
              TextEditingController(text: userProvider.user!.aboutMe);
          _selectedAvailability =
              List<String>.from(userProvider.user!.availability);
        });
      } else {
        _initializeEmptyControllers();
      }
    });
  }

  void _initializeEmptyControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _aboutMeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDomestic ? "Seu perfil" : "Seu perfil",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
        elevation: 0,
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
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildTextField("Nome", _nameController, Icons.person),
                  _buildTextField("Email", _emailController, Icons.email,
                      enabled: false),
                  _buildTextField("Telefone", _phoneController, Icons.phone),
                  if (widget.isDomestic) ...[
                    _buildAvailabilitySelector(),
                    _buildTextField(
                        "Sobre Mim", _aboutMeController, null, // 🔹 Sem ícone
                        maxLines:
                            8, // 🔹 Define mais linhas apenas para "Sobre Mim"
                        hintText: "Escreva um pouco sobre você..."),
                  ],
                  const SizedBox(height: 30),
                  _buildSaveButton(userProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            InkWell(
              onTap: () {
                // Implementar funcionalidade para alterar a foto
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber,
                ),
                padding: const EdgeInsets.all(5),
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _nameController.text,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          widget.isDomestic ? "50 serviços concluídos" : "Usuário Contratante",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData? icon,
      {bool enabled = true, int maxLines = 1, String hintText = ""}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12),
                      child: Icon(icon, color: Colors.amber.shade700),
                    )
                  : null, // 🔹 Remove ícone se for null
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.amber.shade700,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical:
                    maxLines > 1 ? 16 : 14, // 🔹 Ajusta apenas para "Sobre Mim"
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Disponibilidade",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: _daysOfWeek.map((day) {
              bool isSelected = _selectedAvailability.contains(day);
              return ChoiceChip(
                label: Text(day, style: GoogleFonts.poppins(fontSize: 14)),
                selected: isSelected,
                selectedColor: Colors.amber.shade700,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAvailability.add(day);
                    } else {
                      _selectedAvailability.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final user = userProvider.user;

          if (user != null) {
            user.name = _nameController.text;
            user.phone = _phoneController.text;
            user.aboutMe = _aboutMeController.text;
            user.availability = _selectedAvailability;

            await userProvider.updateUserData(user);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Alterações salvas com sucesso!")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.amber.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          "Salvar Alterações",
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
