// lib/widgets/nocenje_sekcija_widget.dart
import 'package:flutter/material.dart';

class NocenjeSekcijaWidget extends StatelessWidget {
  final String tkoPlacaNocenje;
  final ValueChanged<String?> onTkoPlacaChanged;
  final TextEditingController cijenaNocenjaController;
  final List<String> opcijeNocenja;

  const NocenjeSekcijaWidget({
    super.key,
    required this.tkoPlacaNocenje,
    required this.onTkoPlacaChanged,
    required this.cijenaNocenjaController,
    required this.opcijeNocenja,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parametri Noćenja Vozača:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: tkoPlacaNocenje,
          decoration: const InputDecoration(
            labelText: 'Plaćanje noćenja',
            border: OutlineInputBorder(),
          ),
          items: opcijeNocenja.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onTkoPlacaChanged,
        ),
        if (tkoPlacaNocenje == 'Prijevoznik plaća') ...[
          const SizedBox(height: 8),
          TextField(
            controller: cijenaNocenjaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cijena noćenja po noći (€, bruto)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hotel),
            ),
          ),
        ],
      ],
    );
  }
}
