import 'package:flutter/material.dart';
import 'package:limpou25k/views/home_view.dart';
import 'package:limpou25k/views/home_contratante_view.dart';
import 'package:limpou25k/views/chat_list_view.dart';
import 'package:limpou25k/views/user_profile_view.dart';
import 'package:limpou25k/views/add_property_view.dart';

class BottomNavBar extends StatefulWidget {
  final bool isDomestic;

  const BottomNavBar({Key? key, required this.isDomestic}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  late final List<Widget> _domesticPages;
  late final List<Widget> _contratantePages;

  @override
  void initState() {
    super.initState();

    // 🔹 Páginas da Doméstica
    _domesticPages = [
      const HomePage(), // Página inicial da doméstica
      const ChatListView(), // Lista de chats
      const UserProfileView(
        isDomestic: true,
        userType: 'domestica',
      ), // Perfil da doméstica
    ];

    // 🔹 Páginas do Contratante (Corrigido para usar HomeContratanteView)
    _contratantePages = [
      const HomeContratanteView(), // ✅ Página inicial correta do contratante
      const AddPropertyView(), // ✅ Novo (Adicionar Imóvel)
      const ChatListView(), // ✅ Lista de chats
      const UserProfileView(
        isDomestic: false,
        userType: 'contratante',
      ), // ✅ Perfil do contratante
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.isDomestic
          ? _domesticPages[_selectedIndex]
          : _contratantePages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Colors.white.withOpacity(0.9), // 🔹 Cor branca translúcida
        selectedItemColor: Colors.amber.shade700,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: widget.isDomestic
            ? [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: 'Perfil',
                ),
              ]
            : [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                      Icons.add_circle_outline), // **Novo** como 2º ícone
                  label: 'Novo',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
      ),
    );
  }
}
