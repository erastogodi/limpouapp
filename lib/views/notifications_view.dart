import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> notifications = [
      {
        'title': 'Nova mensagem',
        'subtitle': 'Você recebeu uma nova mensagem de Ana Souza.',
        'icon': Icons.message,
        'color': Colors.blue.shade400,
        'time': 'Há 5 minutos',
      },
      {
        'title': 'Solicitação de serviço',
        'subtitle': 'Maria Oliveira aceitou sua solicitação de serviço.',
        'icon': Icons.work,
        'color': Colors.green.shade400,
        'time': 'Há 1 hora',
      },
      {
        'title': 'Pagamento Pendente',
        'subtitle': 'O pagamento do serviço de João Silva está pendente.',
        'icon': Icons.warning,
        'color': Colors.orange.shade400,
        'time': 'Ontem',
      },
      {
        'title': 'Serviço concluído',
        'subtitle': 'Carla Mendes finalizou o serviço com sucesso!',
        'icon': Icons.check_circle,
        'color': Colors.amber.shade600,
        'time': '2 dias atrás',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        title: Text("Notificações",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification['color'],
                child: Icon(notification['icon'], color: Colors.white),
              ),
              title: Text(notification['title'],
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(notification['subtitle'],
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
              trailing: Text(notification['time'],
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
            ),
          );
        },
      ),
    );
  }
}
