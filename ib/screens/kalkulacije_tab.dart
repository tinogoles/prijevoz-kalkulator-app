import 'package:flutter/material.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import '../utils/pdf_generator.dart';

class KalkulacijeTab extends StatelessWidget {
  final List<KalkulacijaModel> kalkulacije;
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final ValueChanged<String> onObrisi;
  final ValueChanged<KalkulacijaModel> onUredi;

  const KalkulacijeTab({
    super.key,
    required this.kalkulacije,
    required this.prijevoznik,
    required this.klijenti,
    required this.onObrisi,
    required this.onUredi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spremljene Kalkulacije i Ponude', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: kalkulacije.isEmpty ? const Center(child: Text('Nema spremljenih kalkulacija.')) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kalkulacije.length,
        itemBuilder: (ctx, idx) {
          var k = kalkulacije[idx];
          bool klijentPdv = klijenti.firstWhere((kl) => kl.naziv == k.klijentNaziv, orElse: () => KlijentModel(id: '', uSustavuPdv: true)).uSustavuPdv;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.nazivKalkulacije, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  const SizedBox(height: 4),
                  Text('Klijent: ${k.klijentNaziv}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Ruta: ${k.ruta}'),
                  Text('Termin: ${k.datumPolaska} - ${k.datumPovratka}'),
                  const SizedBox(height: 6),
                  Text('Ukupno: ${k.ukupnaCijena.toStringAsFixed(2)} EUR', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            tooltip: 'Interna kalkulacija (PDF)',
                            onPressed: () => PdfGenerator.printajInternuKalkulaciju(k, prijevoznik, klijentUsetPdv: klijentPdv),
                          ),
                          IconButton(
                            icon: const Icon(Icons.description, color: Colors.blue),
                            tooltip: 'Ponuda (PDF)',
                            onPressed: () {
                              var pronadjeniKlijent = klijenti.firstWhere((kl) => kl.naziv == k.klijentNaziv, orElse: () => KlijentModel(id: ''));
                              PdfGenerator.printajPonuduPdf(k, prijevoznik, klijentUsetPdv: klijentPdv, klijentObjekt: pronadjeniKlijent);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Uredi',
                            onPressed: () => onUredi(k),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            tooltip: 'Obriši',
                            onPressed: () => onObrisi(k.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
