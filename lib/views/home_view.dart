import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:location/location.dart' as loc;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePage> {
  List<Map<String, dynamic>> properties = [];
  double _raioFiltro = 50;
  bool isLoading = true;
  double? userLat;
  double? userLon;

  @override
  void initState() {
    super.initState();
    _initLocationAndLoadProperties();
  }

  Future<void> _initLocationAndLoadProperties() async {
    final location = loc.Location();
    final hasPermission = await location.hasPermission();
    if (hasPermission == loc.PermissionStatus.denied) {
      await location.requestPermission();
    }

    final locData = await location.getLocation();
    userLat = locData.latitude;
    userLon = locData.longitude;

    await _loadAllProperties();
  }

  Future<void> _loadAllProperties() async {
    try {
      setState(() => isLoading = true);

      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('properties')
          .orderBy('createdAt', descending: true)
          .get();

      final allProps = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final lat = data['latitude'];
            final lon = data['longitude'];

            if (lat != null &&
                lon != null &&
                userLat != null &&
                userLon != null) {
              final distancia =
                  _calcularDistancia(userLat!, userLon!, lat, lon);
              return {
                ...data,
                'id': doc.id,
                'distancia': distancia,
              };
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        properties = allProps
            .where((prop) => (prop['distancia'] as double) <= _raioFiltro)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar propriedades: $e");
      setState(() => isLoading = false);
    }
  }

  double _calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _grausParaRadianos(lat2 - lat1);
    final dLon = _grausParaRadianos(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_grausParaRadianos(lat1)) *
            cos(_grausParaRadianos(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _grausParaRadianos(double graus) => graus * pi / 180;

  Future<void> _simularPropriedades() async {
    final firestore = FirebaseFirestore.instance;
    final userLat = this.userLat ?? 0.0;
    final userLon = this.userLon ?? 0.0;

    for (int km = 10; km <= 50; km += 10) {
      final deslocLat = km / 111;
      final deslocLon = km / (111 * cos(userLat * pi / 180));

      final data = {
        'propertyType': 'Casa Simulada',
        'description': 'Serviço simulado a $km km de distância',
        'date': '10/10/2025',
        'createdAt': Timestamp.now(),
        'latitude': userLat + deslocLat,
        'longitude': userLon + deslocLon,
        'city': 'Cidade Exemplo',
        'state': 'Estado',
      };

      await firestore
          .collection("users")
          .doc("simulado_dono_$km")
          .collection("properties")
          .add(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propriedades simuladas adicionadas')),
    );

    _loadAllProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vinda ao Limpou",
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _simularPropriedades,
            tooltip: "Adicionar propriedades simuladas",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.amber.shade50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Filtrar anúncios por distância",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.amber,
                          thumbColor: Colors.amber,
                          overlayColor: Colors.amber.withOpacity(0.2),
                          inactiveTrackColor: Colors.amber.shade100,
                        ),
                        child: Slider(
                          min: 1,
                          max: 100,
                          value: _raioFiltro,
                          divisions: 99,
                          label: "${_raioFiltro.toStringAsFixed(0)} km",
                          onChanged: (value) {
                            setState(() {
                              _raioFiltro = value;
                            });
                            _loadAllProperties();
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            "Raio: ${_raioFiltro.toStringAsFixed(0)} km",
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: properties.isEmpty
                      ? const Center(child: Text("Nenhum anúncio disponível."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: properties.length,
                          itemBuilder: (context, index) =>
                              _buildPropertyCard(properties[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.serviceDetail,
              arguments: property);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property['propertyType'] ?? "Tipo não informado",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Cidade: ${property['city'] ?? 'N/A'}",
                  style: GoogleFonts.poppins(fontSize: 14)),
              Text("Estado: ${property['state'] ?? 'N/A'}",
                  style: GoogleFonts.poppins(fontSize: 14)),
              Text(
                  "Distância: ${property['distancia']?.toStringAsFixed(2) ?? 'N/A'} km",
                  style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.serviceDetail,
                      arguments: property);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Ver mais",
                    style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
