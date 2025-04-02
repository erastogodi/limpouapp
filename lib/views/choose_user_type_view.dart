import 'package:flutter/material.dart';

class ChooseUserTypeView extends StatelessWidget {
  const ChooseUserTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Doméstica Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register',
                    arguments: 'domestica');
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/limpeza.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.cleaning_services,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Doméstica',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Clique aqui se você deseja se cadastrar como profissional de serviços domésticos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contratante Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register',
                    arguments: 'contratante');
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/contratante.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.home,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contratante',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Clique aqui se você deseja contratar profissionais para serviços domésticos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
