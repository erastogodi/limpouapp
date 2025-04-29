import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class UserProfileView extends StatefulWidget {
  final bool isDomestic;

  const UserProfileView({
    Key? key,
    required this.isDomestic,
    required String userType,
  }) : super(key: key);

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  List<String> _selectedAvailability = [];

  final _daysOfWeek = [
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData().then((_) {
        final user = userProvider.user;
        if (user != null) {
          setState(() {
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone;
            _aboutMeController.text = user.aboutMe;
            _selectedAvailability = List<String>.from(user.availability);
            _streetController.text = user.street ?? '';
            _neighborhoodController.text = user.neighborhood ?? '';
            _cityController.text = user.city ?? '';
            _stateController.text = user.state ?? '';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aboutMeController.dispose();
    _streetController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _atualizarLocalizacao(UserProvider userProvider) async {
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      if (userProvider.user != null) {
        await userProvider.atualizarLocalizacaoAtual();
        setState(() {
          _streetController.text = userProvider.user!.street ?? '';
          _neighborhoodController.text = userProvider.user!.neighborhood ?? '';
          _cityController.text = userProvider.user!.city ?? '';
          _stateController.text = userProvider.user!.state ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Localização atualizada com sucesso!")),
        );
      }
    } catch (e) {
      print("Erro ao atualizar localização: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Seu perfil",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
        elevation: 0,
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    _buildTextField("Sobre Mim", _aboutMeController, null,
                        maxLines: 6, hintText: "Fale um pouco sobre você"),
                  ],
                  _buildLocationSection(userProvider), // 👈 mover para cima
                  const SizedBox(height: 20),
                  _buildTextField("Rua", _streetController, Icons.home),
                  _buildTextField("Bairro", _neighborhoodController, Icons.map),
                  _buildTextField(
                      "Cidade", _cityController, Icons.location_city),
                  _buildTextField(
                      "Estado", _stateController, Icons.location_on),
                  const SizedBox(height: 30),
                  _buildSaveButton(userProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData? icon,
      {bool enabled = true, int maxLines = 1, String hintText = ""}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon, color: Colors.amber) : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          Text("Disponibilidade",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _daysOfWeek.map((day) {
              final selected = _selectedAvailability.contains(day);
              return ChoiceChip(
                label: Text(day),
                selected: selected,
                selectedColor: Colors.amber,
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _selectedAvailability.add(day)
                        : _selectedAvailability.remove(day);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "Localização",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () => _atualizarLocalizacao(userProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Atualizar Localização",
              style: TextStyle(
                  color: Color.fromARGB(255, 34, 32, 32), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(_nameController.text,
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(
            widget.isDomestic
                ? "50 serviços concluídos"
                : "Usuário Contratante",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
      ],
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
            user.street = _streetController.text;
            user.neighborhood = _neighborhoodController.text;
            user.city = _cityController.text;
            user.state = _stateController.text;

            await userProvider.updateUserData(user);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Alterações salvas com sucesso!")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text("Salvar Alterações",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
