import 'package:flutter/material.dart';
import 'package:limpou25k/models/agendamento_model.dart';
import 'package:limpou25k/views/add_property_view.dart';
import 'package:limpou25k/views/chat_list_view.dart';
import 'package:limpou25k/views/chat_view.dart';
import 'package:limpou25k/views/choose_user_type_view.dart';
import 'package:limpou25k/views/create_property_view.dart';
import 'package:limpou25k/views/home_contratante_view.dart';
import 'package:limpou25k/views/home_view.dart';
import 'package:limpou25k/views/login_view.dart';
import 'package:limpou25k/views/notifications_view.dart';
import 'package:limpou25k/views/perfil_domestica_view.dart';
import 'package:limpou25k/views/register_view.dart';
import 'package:limpou25k/views/service_detail_view.dart';
import 'package:limpou25k/views/agendar_servico_view.dart';
import 'package:limpou25k/views/agendamentos_list_view.dart';
import 'package:limpou25k/views/confirmar_agendamento_view.dart';
import 'package:limpou25k/views/avaliacoes_view.dart'; // ✅ NOVO IMPORT

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String homeDomestica = '/home_domestica';
  static const String homeContratante = '/home_contratante';
  static const String chooseUserType = '/choose_user_type';
  static const String chatList = '/chat_list';
  static const String chatView = '/chat_view';
  static const String agendarServico = '/agendar_servico';
  static const String agendamentosList = '/agendamentos_list';
  static const String confirmarAgendamento = '/confirmar_agendamento';
  static const String addProperty = '/add_property';
  static const String createProperty = '/create_property';
  static const String notifications = '/notifications';
  static const String perfilDomestica = '/perfil_domestica';
  static const String serviceDetail = '/service_detail';
  static const String userProfile = '/user_profile';
  static const String avaliacoes = '/avaliacoes'; // ✅ NOVA ROTA

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    register: (context) => const RegisterView(),
    homeDomestica: (context) => const HomePage(),
    homeContratante: (context) => const HomeContratanteView(),
    chooseUserType: (context) => const ChooseUserTypeView(),
    chatList: (context) => const ChatListView(),
    addProperty: (context) => const AddPropertyView(),
    createProperty: (context) => const CreatePropertyView(),
    notifications: (context) => const NotificationsView(),
    agendamentosList: (context) => const AgendamentosListView(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chatView:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ChatView(
              receiverId: args['receiverId'],
              receiverName: args['receiverName'],
              receiverImage: args['receiverImage'],
            ),
          );
        } else {
          return _errorPage('Erro: Nenhuma conversa encontrada.');
        }

      case agendarServico:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => AgendarServicoView(
              contractorId: args['contractorId'],
              workerId: args['workerId'],
              receiverInfo: args['receiverInfo'],
              properties: List<Map<String, dynamic>>.from(args['properties']),
            ),
          );
        } else {
          return _errorPage('Erro: Dados do agendamento não encontrados.');
        }

      case confirmarAgendamento:
        final agendamento = settings.arguments as AgendamentoModel?;
        if (agendamento != null) {
          return MaterialPageRoute(
            builder: (_) => ConfirmarAgendamentoView(
              agendamento: agendamento,
              contractorData: {},
              propertyData: {},
            ),
          );
        } else {
          return _errorPage('Erro: Agendamento não fornecido.');
        }

      case perfilDomestica:
        final userId = settings.arguments as String?;
        if (userId != null) {
          return MaterialPageRoute(
            builder: (_) => PerfilDomesticaView(userId: userId),
          );
        } else {
          return _errorPage('Erro: Nenhum usuário encontrado.');
        }

      case serviceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailsView(
              property: args.cast<String, String>(),
              serviceId: args['id'] ?? '',
            ),
          );
        } else {
          return _errorPage('Erro: Nenhum serviço encontrado.');
        }

      case avaliacoes:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => AvaliacoesView(
              agendamento: args['agendamento'],
              userData: args['userData'],
              propertyData: args['propertyData'],
            ),
          );
        } else {
          return _errorPage('Erro: Dados da avaliação não encontrados.');
        }

      default:
        return _errorPage('Rota não encontrada!');
    }
  }

  static MaterialPageRoute _errorPage(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
