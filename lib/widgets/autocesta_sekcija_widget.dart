// lib/widgets/autocesta_sekcija_widget.dart
import 'package:flutter/material.dart';

class AutocestaSekcijaWidget extends StatelessWidget {
  final bool koristiAutocestu;
  final ValueChanged<bool> onAutocestaChanged;
  final String odabranaAutocesta;
  final ValueChanged<String?> onAutocestaSelected;
  final TextEditingController cestarinaController;
  final List<String> opcijeAutocesta;

  const AutocestaSekcijaWidget({
    super.key,
    required this.koristiAutocestu,
    required this.onAutocestaChanged,
    required this.odabranaAutocesta,
    required this.onAutocestaSelected,
    required this.cestarinaController,
    required this.opcijeAutocesta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Korištenje Autoceste i Cestarina',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
            ),
            SwitchListTile(
              title: const Text('Hoće li se koristiti autocesta?', style: TextStyle(fontWeight: FontWeight.bold)),
              value: koristiAutocestu,
              activeColor: const Color(0xFFEA580C),
              contentPadding: EdgeInsets.zero,
              onChanged: onAutocestaChanged,
            ),
            if (koristiAutocestu) ...[
              DropdownButtonFormField<String>(
                value: odabranaAutocesta,
                decoration: const InputDecoration(
                  labelText: 'Sustav naplate / Autocesta',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: opcijeAutocesta.map((autocesta) => DropdownMenuItem(value: autocesta, child: Text(autocesta))).toList(),
                onChanged: onAutocestaSelected,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cestarinaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Iznos cestarine (€, bruto)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.toll),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
