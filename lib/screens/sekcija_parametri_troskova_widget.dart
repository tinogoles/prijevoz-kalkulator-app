import 'package:flutter/material.dart';

class SekcijaParametriTroskovaWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dostupnaVozila;
  final Map<String, dynamic>? odabranoVoziloMap;
  final ValueChanged<String?> onVoziloChanged;
  final TextEditingController cijenaGorivaController;
  final TextEditingController dnevnicaController;
  final String tkoPlacaNocenje;
  final List<String> opcijeNocenja;
  final ValueChanged<String?> onNocenjeTkoPlacaChanged;
  final TextEditingController cijenaNocenjaController;
  final TextEditingController marzaController;

  const SekcijaParametriTroskovaWidget({
    super.key,
    required this.dostupnaVozila,
    required this.odabranoVoziloMap,
    required this.onVoziloChanged,
    required this.cijenaGorivaController,
    required this.dnevnicaController,
    required this.tkoPlacaNocenje,
    required this.opcijeNocenja,
    required this.onNocenjeTkoPlacaChanged,
    required this.cijenaNocenjaController,
    required this.marzaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: odabranoVoziloMap?['id'],
          isExpanded: true,
          decoration: const InputDecoration(labelText: '14) Vozilo iz voznog parka', border: OutlineInputBorder()),
          items: dostupnaVozila.map((vozilo) {
            String nazivPrikaz = '${vozilo['naziv']} (${vozilo['kapacitet']} sjedala) - ${vozilo['potrosnja']} L/100km';
            return DropdownMenuItem<String>(
              value: vozilo['id'],
              child: Text(nazivPrikaz, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onVoziloChanged,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: cijenaGorivaController,
              decoration: const InputDecoration(labelText: '15) Gorivo (€/L)', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: dnevnicaController,
              decoration: const InputDecoration(labelText: '16) Dnevnica/dan (€)', border: OutlineInputBorder()),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: tkoPlacaNocenje,
          decoration: const InputDecoration(
            labelText: '17) Parametri noćenja vozača; Plaćanje noćenja',
            border: OutlineInputBorder(),
          ),
          items: opcijeNocenja.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onNocenjeTkoPlacaChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: cijenaNocenjaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cijena noćenja po noći (€, bruto)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.hotel),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: marzaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '18) Marža (%)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.percent),
          ),
        ),
      ],
    );
  }
}
