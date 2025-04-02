import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/auth_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:limpou25k/widgets/bottom_nav_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3F2FD),
                Color(0xFFFFFDE7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBackButton(context),
              Text(
                'Crie sua conta',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFBC02D),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserTypeSelector(),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      hintText: 'Insira seu nome completo',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            controller: _cpfController,
                            label: 'CPF',
                            hintText: '000.000.000-00',
                            icon: Icons.perm_identity,
                            inputFormatters: [_cpfFormatter],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildDatePickerField(
                            label: 'Data de Nascimento',
                            hintText: 'DD/MM/AAAA',
                            icon: Icons.calendar_today,
                            controller: _dateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      hintText: '(18) 99999-9999',
                      icon: Icons.phone,
                      inputFormatters: [_phoneFormatter],
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hintText: 'Insira seu e-mail',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hintText: 'Crie uma senha',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirme a Senha',
                      hintText: 'Confirme sua senha',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    buildRegisterButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **🔙 Botão de Voltar**
  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// **🔸 Seletor de Tipo de Usuário**
  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Tipo de Usuário",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          "Selecione o seu tipo de usuário",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ToggleButtons(
          isSelected: [
            _selectedUserType == "Contratante",
            _selectedUserType == "Doméstica",
          ],
          onPressed: (index) {
            setState(() {
              _selectedUserType = index == 0 ? "Contratante" : "Doméstica";
            });
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: Colors.white,
          color: Colors.black,
          fillColor: const Color(0xFFFBC02D),
          selectedBorderColor: const Color(0xFFFBC02D),
          borderColor: const Color(0xFFFBC02D),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child:
                  Text("Contratante", style: GoogleFonts.poppins(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child:
                  Text("Doméstica", style: GoogleFonts.poppins(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }

  /// **📌 Campo de Texto**
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        if (isPassword && value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// **📅 Campo de Data**
  Widget buildDatePickerField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        }
      },
      child: buildTextField(
          controller: controller, label: label, hintText: hintText, icon: icon),
    );
  }

  /// **🚀 Botão de Registrar**
  /// **🚀 Botão de Registrar (Agora usa o Firebase Auth)**
  /// **🚀 Botão de Registrar**
  /// **🚀 Botão de Registrar (Agora com Firebase Auth e Debugging)**
  Widget buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          print("🛠 Tentando registrar usuário...");

          try {
            await authProvider.signUp(
              name: _nameController.text.trim(),
              cpf: _cpfFormatter.getUnmaskedText().trim(),
              phone: _phoneFormatter.getUnmaskedText().trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              userType: _selectedUserType ?? "Contratante",
            );

            print("✅ Usuário registrado com sucesso!");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBar(
                  isDomestic: _selectedUserType == "Doméstica",
                ),
              ),
            );
          } catch (e) {
            print("❌ Erro ao registrar: $e");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro ao registrar: ${e.toString()}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          print("⚠ Formulário inválido!");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFBC02D),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Registrar",
          style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}
