import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limpou25k/providers/property_provider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

import 'package:geocoding/geocoding.dart';

class CreatePropertyView extends StatefulWidget {
  final String? propertyId; // Adiciona um campo opcional para edição

  const CreatePropertyView({Key? key, this.propertyId}) : super(key: key);

  @override
  _CreatePropertyViewState createState() => _CreatePropertyViewState();
}

class _CreatePropertyViewState extends State<CreatePropertyView> {
  final _formKey = GlobalKey<FormState>();

  String? selectedPropertyType;
  String? selectedSpaceType;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String _selectedDate = "Selecionar Data";
  bool _materialsProvided = false;
  double _selectedSize = 50; // Tamanho inicial do imóvel
  bool isEditing = false;
  String? propertyId;
  double? _latitude;
  double? _longitude;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityStateController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  // Opções de áreas a serem limpas
  final List<String> _areasOptions = [
    "Espaço Inteiro",
    "Sala",
    "Cozinha",
    "Quartos",
    "Banheiros",
    "Varanda",
    "Garagem",
    "Área de Serviço",
    "Escritório",
    "Jardim"
  ];
  List<String> _selectedAreas = [];

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      _loadPropertyData();
    }
  }

  void _loadPropertyData() async {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    try {
      var property = await propertyProvider.getPropertyById(widget.propertyId!);
      setState(() {
        selectedPropertyType = property['propertyType'];
        selectedSpaceType = property['spaceType'];
        _addressController.text = property['address'];
        _cityStateController.text = "${property['city']}, ${property['state']}";
        _cepController.text = property['cep'];
        _selectedDate = property['date'];
        selectedBedrooms = property['bedrooms'];
        selectedBathrooms = property['bathrooms'];
        _selectedSize = double.parse(property['size'].replaceAll("m²", ""));
        _selectedAreas = List<String>.from(property['areasToClean']);
        _materialsProvided = property['materialsProvided'] == "Sim";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados do imóvel: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyId != null ? "Editar Anúncio" : "Criar Anúncio",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Tipo de Propriedade
              Center(
                child: Text(
                  "Tipo de Propriedade",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione o tipo de propriedade que deseja anunciar.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildDropdown(
                  "Selecione o tipo de propriedade", selectedPropertyType, [
                "Casa",
                "Apartamento",
                "Kitnet",
                "Studio",
                "Loft",
                "Sobrado",
                "Edícula",
                "Casa geminada",
                "Bangalô",
                "Imóvel Comercial",
                "Sala Comercial",
                "Depósito",
                "Imóvel Rural",
                "Fazenda",
                "Sítio",
                "Chácara"
              ], (val) {
                setState(() => selectedPropertyType = val);
              }),

              const SizedBox(height: 20),

              // Campo: Tipo de Espaço
              Center(
                child: Text(
                  "Tipo de Espaço",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione o tipo de espaço que será limpo.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildDropdown("Selecione o tipo de espaço", selectedSpaceType, [
                "Imóvel inteiro",
                "Quarto Privativo",
                "Quarto Compartilhado",
              ], (val) {
                setState(() => selectedSpaceType = val);
              }),

              const SizedBox(height: 20),

              // Campo: Endereço Completo
              Center(
                child: Text(
                  "Endereço Completo",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Informe o endereço completo do imóvel.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildTextField("Digite o endereço", _addressController),

              const SizedBox(height: 20),

              // Campo: Cidade e Estado
              Center(
                child: Text(
                  "Cidade e Estado",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Informe a cidade e o estado do imóvel.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildTextField(
                  "Digite a cidade e o estado", _cityStateController),

              const SizedBox(height: 20),

              // Campo: CEP
              Center(
                child: Text(
                  "CEP",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Informe o CEP do imóvel.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildTextField("Digite o CEP", _cepController),
              // Botão: Obter Localização Atual
              Center(
                child: ElevatedButton.icon(
                  onPressed: _preencherEnderecoComLocalizacaoAtual,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    "Usar Localização Atual",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Campo: Data
              Center(
                child: Text(
                  "Data da Limpeza",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione a data em que a limpeza será realizada.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildDatePicker(),

              const SizedBox(height: 20),

              // Campo: Tamanho do Imóvel
              Center(
                child: Text(
                  "Tamanho do Imóvel",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Ajuste o tamanho do imóvel em metros quadrados.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildSizeSelector(),

              const SizedBox(height: 20),

              // Campo: Número de Quartos
              Center(
                child: Text(
                  "Número de Quartos",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione o número de quartos no imóvel.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildDropdown("Selecione o número de quartos", selectedBedrooms,
                  ["1", "2", "3", "4", "5+"], (val) {
                setState(() => selectedBedrooms = val);
              }),

              const SizedBox(height: 20),

              // Campo: Número de Banheiros
              Center(
                child: Text(
                  "Número de Banheiros",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione o número de banheiros no imóvel.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildDropdown("Selecione o número de banheiros",
                  selectedBathrooms, ["1", "2", "3", "4+"], (val) {
                setState(() => selectedBathrooms = val);
              }),

              const SizedBox(height: 20),

              // Campo: Áreas a serem Limpas
              Center(
                child: Text(
                  "Áreas a serem Limpas",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecione as áreas que precisam de limpeza.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildAreaSelection(),

              const SizedBox(height: 20),

              // Campo: Materiais Fornecidos
              Center(
                child: Text(
                  "Materiais Fornecidos",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "O cliente fornecerá os materiais de limpeza?",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              _buildMaterialSelectionButtons(),

              const SizedBox(height: 20),

              // Botão de Salvar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// **📌 Campo Dropdown (Seleção de Opções)**
  Widget _buildDropdown(String label, String? selectedValue,
      List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: (value) => onChanged(value!),
        items: options.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type, style: GoogleFonts.poppins(fontSize: 16)),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        validator: (value) => value == null ? "Selecione uma opção" : null,
        alignment: Alignment.centerLeft, // Alinhamento à esquerda
      ),
    );
  }

  /// **📌 Campo de Texto**
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Campo obrigatório" : null,
      ),
    );
  }

  /// **📌 Seletor de Tamanho do Imóvel (Slider)**
  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _selectedSize,
            min: 10,
            max: 200,
            divisions: 190, // Incremento de 1 em 1
            label: "${_selectedSize.toInt()}m²",
            activeColor: Colors.amber.shade700,
            onChanged: (value) {
              setState(() {
                _selectedSize = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// **📌 Escolha das Áreas a serem limpas (Choice Box)**
  Widget _buildAreaSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 8.0,
        children: _areasOptions.map((area) {
          bool isSelected = _selectedAreas.contains(area);
          return ChoiceChip(
            label: Text(area, style: GoogleFonts.poppins(fontSize: 14)),
            selected: isSelected,
            selectedColor: Colors.amber.shade700,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedAreas.add(area);
                } else {
                  _selectedAreas.remove(area);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  /// **📌 Botões de Sim/Não para Materiais Fornecidos**
  Widget _buildMaterialSelectionButtons() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7, // Reduzindo o tamanho
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _materialsProvided = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _materialsProvided
                      ? Colors.amber.shade700
                      : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Reduzindo o padding
                ),
                child: Text(
                  "Sim",
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Reduzindo o tamanho da fonte
                    color: _materialsProvided ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _materialsProvided = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_materialsProvided
                      ? Colors.amber.shade700
                      : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Reduzindo o padding
                ),
                child: Text(
                  "Não",
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Reduzindo o tamanho da fonte
                    color: !_materialsProvided ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final propertyProvider =
                Provider.of<PropertyProvider>(context, listen: false);

            try {
              if (widget.propertyId != null) {
                // 🔹 Atualiza um imóvel existente
                await propertyProvider.updateProperty(
                  id: widget.propertyId!,
                  propertyType: selectedPropertyType!,
                  spaceType: selectedSpaceType!,
                  address: _addressController.text.trim(),
                  city: _cityStateController.text.split(", ").first.trim(),
                  state: _cityStateController.text.split(", ").last.trim(),
                  cep: _cepController.text.trim(),
                  date: _selectedDate,
                  bedrooms: selectedBedrooms!,
                  bathrooms: selectedBathrooms!,
                  size: "${_selectedSize.toInt()}m²",
                  areasToClean: _selectedAreas,
                  materialsProvided: _materialsProvided,
                  latitude: _latitude!,
                  longitude: _longitude!,
                );
              } else {
                // 🔹 Cria um novo imóvel
                await propertyProvider.addProperty(
                  propertyType: selectedPropertyType!,
                  spaceType: selectedSpaceType!,
                  address: _addressController.text.trim(),
                  city: _cityStateController.text.split(", ").first.trim(),
                  state: _cityStateController.text.split(", ").last.trim(),
                  cep: _cepController.text.trim(),
                  date: _selectedDate,
                  bedrooms: selectedBedrooms!,
                  bathrooms: selectedBathrooms!,
                  size: "${_selectedSize.toInt()}m²",
                  areasToClean: _selectedAreas,
                  materialsProvided: _materialsProvided,
                  latitude: _latitude!,
                  longitude: _longitude!,
                );
              }

              // ✅ Retornar "true" para que a tela anterior recarregue os imóveis
              Navigator.pop(context, true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erro ao salvar imóvel: $e")),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.amber.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text("Salvar Anúncio",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  /// **📅 Campo de Seleção de Data**
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _preencherEnderecoComLocalizacaoAtual() async {
    try {
      final location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      final currentLocation = await location.getLocation();
      _latitude = currentLocation.latitude;
      _longitude = currentLocation.longitude;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(_latitude!, _longitude!);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _addressController.text =
              "${placemark.street ?? ''}, ${placemark.subThoroughfare ?? ''}";
          _cityStateController.text =
              "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}";
          _cepController.text = placemark.postalCode ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Endereço preenchido com sucesso!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao obter localização: $e")),
      );
    }
  }
}
