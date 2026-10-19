import 'package:flutter/material.dart';
import '../models/vozilo_model.dart';

class VozniParkScreen extends StatefulWidget {
  const VozniParkScreen({Key? key}) : super(key: key);

  @override
  State<VozniParkScreen> createState() => _VozniParkScreenState();
}

class _VozniParkScreenState extends State<VozniParkScreen> {
  // Privremena lista u memoriji (naknadno povežemo s Firestore baze ili servisom)
  final List<VoziloModel> _vozila = [];

  final List<String> _kategorijeCestarine = [
    'Kombi 8+1',
    'Mini bus <20',
    'Midi bus 35',
    'Veliki autobus 50',
  ];

  void _otvoriDijalogZaVozilo([VoziloModel? postojeceVozilo]) {
    final _nazivController =
        TextEditingController(text: postojeceVozilo?.naziv ?? '');
    final _kapacitetController = TextEditingController(
        text: postojeceVozilo != null ? postojeceVozilo.kapacitet.toString() : '');

    String odabranaKategorija = postojeceVozilo?.kategorijaCestarine ?? _kategorijeCestarine.first;
    bool imaKlimu = postojeceVozilo?.imaKlimu ?? true;
    bool imaWc = postojeceVozilo?.imaWc ?? false;
    bool imaWifi = postojeceVozilo?.imaWifi ?? false;
    bool ima220V = postojeceVozilo?.ima220V ?? false;
    bool imaPunjac = postojeceVozilo?.imaPunjac ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(postojeceVozilo == null ? 'Dodaj novo vozilo' : 'Uredi vozilo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nazivController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv / Oznaka vozila (npr. Mercedes Sprinter)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kapacitetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kapacitet (broj sjedala)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: odabranaKategorija,
                      decoration: const InputDecoration(
                        labelText: 'Kategorija po cestarini',
                        border: OutlineInputBorder(),
                      ),
                      items: _kategorijeCestarine.map((kat) {
                        return DropdownMenuItem(
                          value: kat,
                          child: Text(kat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            odabranaKategorija = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dodatna oprema:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Klima uredaj'),
                      value: imaKlimu,
                      onChanged: (val) => setDialogState(() => imaKlimu = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('WC'),
                      value: imaWc,
                      onChanged: (val) => setDialogState(() => imaWc = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Wi-Fi'),
                      value: imaWifi,
                      onChanged: (val) => setDialogState(() => imaWifi = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Uticnica 220V'),
                      value: ima220V,
                      onChanged: (val) => setDialogState(() => ima220V = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('USB Punjac za mobitel'),
                      value: imaPunjac,
                      onChanged: (val) => setDialogState(() => imaPunjac = val ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nazivController.text.trim().isEmpty) return;

                    final vozilo = VoziloModel(
                      id: postojeceVozilo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      naziv: _nazivController.text.trim(),
                      kapacitet: int.tryParse(_kapacitetController.text.trim()) ?? 0,
                      kategorijaCestarine: odabranaKategorija,
                      imaKlimu: imaKlimu,
                      imaWc: imaWc,
                      imaWifi: imaWifi,
                      ima220V: ima220V,
                      imaPunjac: imaPunjac,
                    );

                    setState(() {
                      if (postojeceVozilo == null) {
                        _vozila.add(vozilo);
                      } else {
                        final idx = _vozila.indexWhere((v) => v.id == postojeceVozilo.id);
                        if (idx != -1) _vozila[idx] = vozilo;
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Spremi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _obrisiVozilo(String id) {
    setState(() {
      _vozila.removeWhere((v) => v.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vozni Park'),
      ),
      body: _vozila.isEmpty
          ? const Center(
              child: Text(
                'Nema unesenih vozila.\nKliknite na "+" za dodavanje novog vozila.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _vozila.length,
              itemBuilder: (context, index) {
                final vozilo = _vozila[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      vozilo.naziv,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Kapacitet: ${vozilo.kapacitet} sjedala | Cestarina: ${vozilo.kategorijaCestarine}'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (vozilo.imaKlimu) const Chip(label: Text('Klima'), avatar: Icon(Icons.ac_unit, size: 16)),
                            if (vozilo.imaWc) const Chip(label: Text('WC'), avatar: Icon(Icons.wc, size: 16)),
                            if (vozilo.imaWifi) const Chip(label: Text('Wi-Fi'), avatar: Icon(Icons.wifi, size: 16)),
                            if (vozilo.ima220V) const Chip(label: Text('220V'), avatar: Icon(Icons.power, size: 16)),
                            if (vozilo.imaPunjac) const Chip(label: Text('USB'), avatar: Icon(Icons.battery_charging_full, size: 16)),
                          ],
                        )
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _otvoriDijalogZaVozilo(vozilo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _obrisiVozilo(vozilo.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _otvoriDijalogZaVozilo(),
        icon: const Icon(Icons.add),
        label: const Text('Novo vozilo'),
      ),
    );
  }
}
