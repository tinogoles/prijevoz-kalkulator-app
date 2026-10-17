// lib/widgets/unos_rute_widget.dart
import 'package:flutter/material.dart';

class UnosRuteWidget extends StatelessWidget {
  final TextEditingController polazisteController;
  final TextEditingController odrediste1Controller;
  final TextEditingController odrediste2Controller;
  final TextEditingController konacnoOdredisteController;
  final TextEditingController kmController;
  final TextEditingController datumPolaskaController;
  final TextEditingController datumPovratkaController;
  final bool povratnoPutovanje;
  final ValueChanged<bool?> onPovratnoChanged;
  final int izracunatiBrojDana;
  final VoidCallback onOdaberiDatumPolaska;
  final VoidCallback onOdaberiDatumPovratka;
  final VoidCallback onIzracunajRutu;
  final bool isLoadingRoute;

  const UnosRuteWidget({
    super.key,
    required this.polazisteController,
    required this.odrediste1Controller,
    required this.odrediste2Controller,
    required this.konacnoOdredisteController,
    required this.kmController,
    required this.datumPolaskaController,
    required this.datumPovratkaController,
    required this.povratnoPutovanje,
    required this.onPovratnoChanged,
    required this.izracunatiBrojDana,
    required this.onOdaberiDatumPolaska,
    required this.onOdaberiDatumPovratka,
    required this.onIzracunajRutu,
    required this.isLoadingRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: polazisteController, decoration: const InputDecoration(labelText: 'Polazište', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: odrediste1Controller, decoration: const InputDecoration(labelText: 'Međuodredište A (opcionalno)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: odrediste2Controller, decoration: const InputDecoration(labelText: 'Međuodredište B (opcionalno)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: konacnoOdredisteController, decoration: const InputDecoration(labelText: 'Konačno odredište', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Povratno putovanje'),
          value: povratnoPutovanje,
          onChanged: onPovratnoChanged,
        ),
        TextField(controller: kmController, decoration: const InputDecoration(labelText: 'Kilometri', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: datumPolaskaController, readOnly: true, onTap: onOdaberiDatumPolaska, decoration: const InputDecoration(labelText: 'Polazak', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: datumPovratkaController, readOnly: true, onTap: onOdaberiDatumPovratka, decoration: const InputDecoration(labelText: 'Polazak / Povratak', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Izračunato trajanje:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$izracunatiBrojDana dana (${izracunatiBrojDana > 1 ? izracunatiBrojDana - 1 : 0} noćenja)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isLoadingRoute ? null : onIzracunajRutu,
          icon: const Icon(Icons.route),
          label: Text(isLoadingRoute ? 'Računam...' : 'Izračunaj kilometre preko OSRM'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ],
    );
  }
}
