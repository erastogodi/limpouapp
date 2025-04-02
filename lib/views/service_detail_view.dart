import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServiceDetailsView extends StatefulWidget {
  final Map<String, dynamic> property; // Alterado para dynamic
  final String serviceId;

  const ServiceDetailsView({
    Key? key,
    required this.property,
    required this.serviceId,
  }) : super(key: key);

  @override
  _ServiceDetailsViewState createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  final PageController _pageController = PageController();

  // Método para converter listas em strings
  String _listToString(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceInfo(),
                      const SizedBox(height: 20),
                      _buildClientInfo(),
                      const SizedBox(height: 20),
                      _buildPaymentInfo(),
                      const SizedBox(height: 30),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView(
            controller: _pageController,
            children: [
              _buildImagePlaceholder(),
              _buildImagePlaceholder(),
              _buildImagePlaceholder(),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: MediaQuery.of(context).size.width * 0.4,
          child: SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: const ExpandingDotsEffect(
              expansionFactor: 2,
              spacing: 8,
              radius: 16,
              dotWidth: 8,
              dotHeight: 8,
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          'Imagem do Serviço',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Endereço: ${widget.property['address']}, ${widget.property['city']}, ${widget.property['state']}',
              style: _textStyle(),
            ),
            const SizedBox(height: 10),
            Text('📅 Data: ${_listToString(widget.property['date'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text(
                '🏠 Tipo de propriedade: ${_listToString(widget.property['propertyType'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text(
                '🏠 Tipo de espaço: ${_listToString(widget.property['spaceType'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text(
                '📏 Tamanho do imóvel: ${_listToString(widget.property['size'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text('🛏️ Quartos: ${_listToString(widget.property['bedrooms'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text('🚿 Banheiros: ${_listToString(widget.property['bathrooms'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text(
                '🛋️ Áreas a serem limpas: ${_listToString(widget.property['areasToClean'])}',
                style: _textStyle()),
            const SizedBox(height: 10),
            Text(
              '🧽 Materiais fornecidos pelo cliente: ${_listToString(widget.property['materialsProvided'])}',
              style: _textStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(' Cliente: João Silva',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                RatingBarIndicator(
                  rating: 4.5,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                Text('🔄 25 serviços concluídos',
                    style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 Valor do Serviço: R\$ 150,00', style: _textStyle()),
            const SizedBox(height: 10),
            Text('💳 Método de Pagamento: Pix', style: _textStyle()),
            const SizedBox(height: 10),
            Text(
              '🔹 Cliente fornecerá materiais de limpeza: ${_listToString(widget.property['materialsProvided'])}',
              style: _textStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navegação para solicitação do serviço
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        ),
        child: Text(
          'Solicitar Serviço',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);
  }
}
