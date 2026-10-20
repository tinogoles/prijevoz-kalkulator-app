// lib/screens/kalkulacije_tab.dart
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

  void _potvrdiBrisanje(BuildContext context, String id, String naziv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text('Jeste li sigurni da želite obrisati kalkulaciju "$naziv"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onObrisi(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kalkulacija obrisana.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spremljene Kalkulacije i Ponude', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: kalkulacije.isEmpty
          ? const Center(child: Text('Nema spremljenih kalkulacija.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kalkulacije.length,
              itemBuilder: (ctx, idx) {
                var k = kalkulacije[idx];

                // Fleksibilno pronalaženje klijenta po ID-u ili nazivu
                KlijentModel? pronadjeniKlijent;
                try {
                  pronadjeniKlijent = klijenti.firstWhere(
                    (kl) => (kl.id.isNotEmpty && kl.id == k.klijentId) ||
                            kl.naziv.trim().toLowerCase() == k.klijentNaziv.trim().toLowerCase() ||
                            kl.naziv.trim().toLowerCase().contains(k.klijentNaziv.trim().toLowerCase()) ||
                            k.klijentNaziv.trim().toLowerCase().contains(kl.naziv.trim().toLowerCase()),
                  );
                } catch (_) {
                  pronadjeniKlijent = null;
                }

                // Određivanje PDV statusa klijenta s fallbackom na podatke iz same kalkulacije
                bool klijentPdv = pronadjeniKlijent?.uSustavuPdv ?? k.klijentUSustavuPdv ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.nazivKalkulacije,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                        const SizedBox(height: 4),
                        Text('Klijent: ${k.klijentNaziv} ${klijentPdv ? "(U sustavu PDV-a)" : "(Nije u sustavu PDV-a)"}', 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Ruta: ${k.ruta}'),
                        Text('Termin: ${k.datumPolaska} - ${k.datumPovratka}'),
                        const SizedBox(height: 6),
                        Text(
                          'Ukupno: ${k.ukupnaCijena.toStringAsFixed(2)} EUR',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                  label: const Text('Interna kalkulacija', style: TextStyle(color: Colors.red, fontSize: 13)),
                                  onPressed: () => PdfGenerator.printajInternuKalkulaciju(
                                    k, 
                                    prijevoznik, 
                                    klijentUsetPdv: klijentPdv,
                                    klijentObjekt: pronadjeniKlijent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.description, color: Colors.blue, size: 20),
                                  label: const Text('Print ponude', style: TextStyle(color: Colors.blue, fontSize: 13)),
                                  onPressed: () {
                                    PdfGenerator.printajPonuduPdf(
                                      k, 
                                      prijevoznik, 
                                      klijentUsetPdv: klijentPdv, 
                                      klijentObjekt: pronadjeniKlijent,
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                  label: const Text('Uredi', style: TextStyle(color: Colors.orange, fontSize: 13)),
                                  onPressed: () => onUredi(k),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  label: const Text('Obriši', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                  onPressed: () => _potvrdiBrisanje(context, k.id, k.nazivKalkulacije),
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
