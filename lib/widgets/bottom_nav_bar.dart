import 'package:flutter/material.dart';
import 'package:limpou25k/views/home_view.dart';
import 'package:limpou25k/views/home_contratante_view.dart';
import 'package:limpou25k/views/chat_list_view.dart';
import 'package:limpou25k/views/user_profile_view.dart';
import 'package:limpou25k/views/add_property_view.dart';
import 'package:limpou25k/views/agendamentos_list_view.dart'; // ✅ IMPORTAR DIRETO

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
      const HomePage(),
      const ChatListView(),
      const AgendamentosListView(), // ✅ Aqui usamos o widget direto
      const UserProfileView(
        isDomestic: true,
        userType: 'domestica',
      ),
    ];

    // 🔹 Páginas do Contratante
    _contratantePages = [
      const HomeContratanteView(),
      const AddPropertyView(),
      const ChatListView(),
      const AgendamentosListView(), // ✅ Aqui também
      const UserProfileView(
        isDomestic: false,
        userType: 'contratante',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDomestic = widget.isDomestic;
    final selectedPages = isDomestic ? _domesticPages : _contratantePages;

    return Scaffold(
      body: selectedPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: Colors.amber.shade700,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: isDomestic
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Início',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: 'Agendamentos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ]
            : [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Início',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Novo',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: 'Agendamentos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
      ),
    );
  }
}
