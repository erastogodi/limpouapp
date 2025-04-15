import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/widgets/bottom_nav_bar.dart';
import 'package:limpou25k/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController =
      TextEditingController(text: "erastogod@outlook.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "senhateste");

  bool _isLoading = false;

  void _loginUser(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isLoading = true); // Mostra loading

    try {
      final user = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // Verifica o tipo de usuário para redirecionar corretamente
        final userType = await authProvider.getUserType(user.user!.uid);

        if (userType == "Doméstica") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BottomNavBar(
                  isDomestic: true), // ✅ estrutura da doméstica
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BottomNavBar(
                  isDomestic: false), // ✅ estrutura do contratante
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false); // Esconde loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFDE7), Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Logo do App
                  Text(
                    'Limpou',
                    style: GoogleFonts.poppins(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFBC02D),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 🔹 Campo de Email (Pré-preenchido)
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Insira seu email',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Campo de Senha (Pré-preenchido)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Insira sua senha',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Botões de Login e Cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 Botão de Login (Agora autentica no Firebase)
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _loginUser(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor:
                              const Color(0xFFFBC02D).withOpacity(0.85),
                          shadowColor: Colors.black26,
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Entrar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // 🔹 Botão de Registro
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/register");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor:
                              const Color(0xFFFBC02D).withOpacity(0.85),
                          shadowColor: Colors.black26,
                          elevation: 3,
                        ),
                        child: Text(
                          'Registrar',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Links para Alternar Entre Login e Cadastro
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/register");
                    },
                    child: Text(
                      'Não tem conta? Cadastre-se',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[800],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
