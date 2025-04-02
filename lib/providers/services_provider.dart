import 'package:flutter/material.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final double rating;
  final int reviews;
  final String imagePath;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.imagePath,
  });
}

class ServicesProvider with ChangeNotifier {
  final List<Service> _services = [
    Service(
      id: '1',
      title: 'Limpeza Residencial',
      description: 'Uma limpeza completa e profissional para sua casa.',
      rating: 4.8,
      reviews: 120,
      imagePath: 'assets/images/limpeza.jpg', // Simulação de imagem local
    ),
    Service(
      id: '2',
      title: 'Limpeza de Escritório',
      description:
          'Serviço de limpeza profissional para ambientes de trabalho.',
      rating: 4.5,
      reviews: 85,
      imagePath: 'assets/images/limpeza.jpg',
    ),
    Service(
      id: '3',
      title: 'Faxina Completa',
      description: 'Limpeza profunda em todos os cômodos da sua casa.',
      rating: 4.9,
      reviews: 200,
      imagePath: 'assets/images/limpeza.jpg',
    ),
  ];

  List<Service> get services => _services;

  Service findById(String id) {
    return _services.firstWhere((service) => service.id == id);
  }
}
