import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyDetailsView extends StatefulWidget {
  const PropertyDetailsView(
      {Key? key,
      required Map<String, String> propertyData,
      required Map property})
      : super(key: key);

  @override
  _PropertyDetailsViewState createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<PropertyDetailsView> {
  final _formKey = GlobalKey<FormState>();

  String _propertyType = "Casa"; // Default inicial
  String _spaceType = "Imóvel inteiro";
  String _cityState = "";
  String _cep = "";
  int _bedrooms = 1;
  int _bathrooms = 1;
  int _beds = 1;
  double _propertySize = 50.0;
  bool _acceptTerms = false;

  final List<String> propertyTypes = [
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
  ];

  final List<String> spaceTypes = [
    "Imóvel inteiro",
    "Quarto Privativo",
    "Quarto Compartilhado",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalhes do Imóvel",
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
              _buildDropdown(
                  "Tipo de Propriedade", _propertyType, propertyTypes, (val) {
                setState(() => _propertyType = val);
              }),
              _buildDropdown("Tipo de Espaço", _spaceType, spaceTypes, (val) {
                setState(() => _spaceType = val);
              }),
              _buildTextField(
                  "Cidade e Estado", _cityState, (val) => _cityState = val),
              _buildTextField("CEP", _cep, (val) => _cep = val),
              _buildStepper("Número de Quartos", _bedrooms,
                  (val) => setState(() => _bedrooms = val)),
              _buildStepper("Número de Camas", _beds,
                  (val) => setState(() => _beds = val)),
              _buildStepper("Número de Banheiros", _bathrooms,
                  (val) => setState(() => _bathrooms = val)),
              _buildSlider("Tamanho da Propriedade (m²)", _propertySize, (val) {
                setState(() => _propertySize = val);
              }),
              _buildCheckbox("Aceito os termos e condições", _acceptTerms,
                  (val) {
                setState(() => _acceptTerms = val!);
              }),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// **📌 Campo Dropdown (Seleção de Opções)**
  Widget _buildDropdown(String label, String selectedValue,
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
        decoration: _inputDecoration(label),
      ),
    );
  }

  /// **📌 Campo de Texto**
  Widget _buildTextField(
      String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: (value) => onSaved(value),
        decoration: _inputDecoration(label),
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }

  /// **📌 Campo Stepper (Selecionar Quantidade)**
  Widget _buildStepper(
      String label, int currentValue, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  if (currentValue > 1) onChanged(currentValue - 1);
                },
              ),
              Text("$currentValue",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => onChanged(currentValue + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **📌 Campo Slider (Selecionar Metragem)**
  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16)),
        Slider(
          value: value,
          min: 20,
          max: 500,
          divisions: 48,
          label: "${value.round()} m²",
          onChanged: onChanged,
          activeColor: Colors.amber.shade700,
        ),
      ],
    );
  }

  /// **📌 Checkbox (Aceite de Termos)**
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label, style: GoogleFonts.poppins(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.amber.shade700,
    );
  }

  /// **📌 Botão de Salvar**
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Imóvel salvo com sucesso!")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.amber.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          "Salvar Imóvel",
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  /// **📌 Estilização de Inputs**
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
