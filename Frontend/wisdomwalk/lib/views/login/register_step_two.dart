import 'package:flutter/material.dart';

class RegisterStepTwo extends StatefulWidget {
  final Function(Map<String, String>) onNext;
  final VoidCallback onBack;
  final Map<String, String?> initialData;

  const RegisterStepTwo({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.initialData,
  }) : super(key: key);

  @override
  State<RegisterStepTwo> createState() => _RegisterStepTwoState();
}

class _RegisterStepTwoState extends State<RegisterStepTwo> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _subcityController = TextEditingController();

  final List<String> _countries = [
    'Ethiopia',
    'United States',
    'Canada',
    'United Kingdom',
    'Kenya',
    'Nigeria',
    'South Africa',
    'Ghana',
    'Other',
  ];

  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.initialData['city'] ?? '';
    _subcityController.text = widget.initialData['subcity'] ?? '';
    _selectedCountry = widget.initialData['country'];
  }

  @override
  void dispose() {
    _cityController.dispose();
    _subcityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your location details',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 30),
              _buildCountryDropdown(),
              const SizedBox(height: 20),
              _buildCityField(),
              const SizedBox(height: 20),
              _buildSubcityField(),
              const SizedBox(height: 40),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _countries.contains(_selectedCountry) ? _selectedCountry : null,
      decoration: InputDecoration(
        labelText: 'Country',
        prefixIcon: const Icon(Icons.public, color: Color(0xFFD4A017)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A017)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          _countries.map((String country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(country),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCountry = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your country';
        }
        return null;
      },
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'City',
        hintText: 'Enter your city',
        prefixIcon: const Icon(Icons.location_city, color: Color(0xFFD4A017)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A017)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your city';
        }
        return null;
      },
    );
  }

  Widget _buildSubcityField() {
    return TextFormField(
      controller: _subcityController,
      decoration: InputDecoration(
        labelText: 'Subcity/Area',
        hintText: 'Enter your subcity or area',
        prefixIcon: const Icon(Icons.map, color: Color(0xFFD4A017)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A017)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your subcity or area';
        }
        return null;
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4A017)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Color(0xFFD4A017)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext({
                    'city': _cityController.text,
                    'subcity': _subcityController.text,
                    'country': _selectedCountry ?? '',
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A017),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
