import 'package:flutter/material.dart';

class SekcijaAutoputWidget extends StatelessWidget {
  final bool koristiAutocestu;
  final ValueChanged<bool?> onAutocestaChanged;
  final List<Map<String, dynamic>> dioniceAutocesta;
  final Function(int, bool) onDionicaToggled;
  final TextEditingController cestarinaController;

  const SekcijaAutoputWidget({
    super.key,
    required this.koristiAutocestu,
    required this.onAutocestaChanged,
    required this.dioniceAutocesta,
    required this.onDionicaToggled,
    required this.cestarinaController,
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
            SwitchListTile(
              title: const Text('9) Da li će se koristiti autoput?', style: TextStyle(fontWeight: FontWeight.bold)),
              value: koristiAutocestu,
              activeColor: const Color(0xFFEA580C),
              contentPadding: EdgeInsets.zero,
              onChanged: onAutocestaChanged,
            ),
            if (koristiAutocestu && dioniceAutocesta.isNotEmpty) ...[
              const Divider(),
              const Text('Autoput dionice na ruti:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...dioniceAutocesta.asMap().entries.map((entry) {
                int index = entry.key;
                var dionica = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${10 + index}) ${dionica['naziv']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${dionica['opis']} - ${(dionica['cijena'] as double).toStringAsFixed(2)} €', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: dionica['ukljuceno'],
                        activeColor: const Color(0xFFEA580C),
                        onChanged: (val) => onDionicaToggled(index, val),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: cestarinaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ukupan iznos cestarine (€, bruto)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.toll),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
