import 'package:flutter/material.dart';

class VozniParkScreen extends StatefulWidget {
  const VozniParkScreen({Key? key}) : super(key: key);

  @override
  State<VozniParkScreen> createState() => _VozniParkScreenState();
}

class _VozniParkScreenState extends State<VozniParkScreen> {
  // Lista vozila u voznom parku
  final List<Map<String, dynamic>> _vozila = [
    {
      'id': '1',
      'naziv': 'Mercedes Tourismo',
      'kapacitet': '49 + 1 + 1',
      'kategorija': 'Veliki autobus 50',
      'potrosnja': '32.0',
      'oprema': {'Klima uređaj': true, 'WC': true, 'Wi-Fi': true, 'Utičnica 220V': true, 'USB Punjač za mobitel': true},
    },
    {
      'id': '2',
      'naziv': 'Ford Transit',
      'kapacitet': '8 + 1',
      'kategorija': 'Kombi 8+1',
      'potrosnja': '9.0',
      'oprema': {'Klima uređaj': true, 'WC': false, 'Wi-Fi': true, 'Utičnica 220V': false, 'USB Punjač za mobitel': true},
    },
  ];

  final List<String> _kategorijeVozila = [
    'Kombi 8+1',
    'Mini bus <20',
    'Midi bus 35',
    'Veliki autobus 50',
  ];

  void _otvoriDijalogVozilo([Map<String, dynamic>? vozilo]) {
    final _nazivCtrl = TextEditingController(text: vozilo?['naziv'] ?? '');
    final _kapacitetCtrl = TextEditingController(text: vozilo?['kapacitet'] ?? '');
    final _potrosnjaCtrl = TextEditingController(text: vozilo?['potrosnja'] ?? '');
    
    String _odabranaKategorija = vozilo?['kategorija'] ?? _kategorijeVozila.first;

    Map<String, bool> _oprema = vozilo?['oprema'] != null
        ? Map<String, bool>.from(vozilo!['oprema'])
        : {
            'Klima uređaj': false,
            'WC': false,
            'Wi-Fi': false,
            'Utičnica 220V': false,
            'USB Punjač za mobitel': false,
          };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(vozilo == null ? 'Dodaj novo vozilo' : 'Uredi vozilo'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nazivCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Naziv / Oznaka vozila (npr. Mercedes)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _kapacitetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kapacitet (broj sjedala)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _odabranaKategorija,
                        decoration: const InputDecoration(
                          labelText: 'Kategorija po cestarini',
                          isDense: true,
                        ),
                        items: _kategorijeVozila.map((kat) {
                          return DropdownMenuItem(value: kat, child: Text(kat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => _odabranaKategorija = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Dodano polje za potrošnju ispod kategorije
                      TextField(
                        controller: _potrosnjaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Potrošnja ( L/100km )',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Dodatna oprema:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      ..._oprema.keys.map((nazivOpreme) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(nazivOpreme),
                          value: _oprema[nazivOpreme],
                          onChanged: (bool? value) {
                            setDialogState(() {
                              _oprema[nazivOpreme] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nazivCtrl.text.trim().isEmpty) return;

                    final novoVozilo = {
                      'id': vozilo?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      'naziv': _nazivCtrl.text.trim(),
                      'kapacitet': _kapacitetCtrl.text.trim(),
                      'kategorija': _odabranaKategorija,
                      'potrosnja': _potrosnjaCtrl.text.trim().isNotEmpty ? _potrosnjaCtrl.text.trim() : '0.0',
                      'oprema': Map<String, bool>.from(_oprema),
                    };

                    setState(() {
                      if (vozilo == null) {
                        _vozila.add(novoVozilo);
                      } else {
                        final index = _vozila.indexWhere((v) => v['id'] == vozilo['id']);
                        if (index != -1) _vozila[index] = novoVozilo;
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
      _vozila.removeWhere((v) => v['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje voznim parkom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Dodaj vozilo',
            onPressed: () => _otvoriDijalogVozilo(null),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popis vozila i opreme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _otvoriDijalogVozilo(null),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj novo vozilo'),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: _vozila.isEmpty
                  ? const Center(child: Text('Nema unesenih vozila u voznom parku.'))
                  : ListView.separated(
                      itemCount: _vozila.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final vozilo = _vozila[index];
                        Map<String, bool> oprema = Map<String, bool>.from(vozilo['oprema'] ?? {});
                        List<String> aktivnaOprema = oprema.entries
                            .where((e) => e.value == true)
                            .map((e) => e.key)
                            .toList();

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.directions_bus),
                          ),
                          title: Text(
                            vozilo['naziv'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Kapacitet: ${vozilo['kapacitet']} sjedala | Kategorija: ${vozilo['kategorija']}'),
                              Text('Potrošnja: ${vozilo['potrosnja']} L/100km'),
                              if (aktivnaOprema.isNotEmpty)
                                Text('Oprema: ${aktivnaOprema.join(', ')}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _otvoriDijalogVozilo(vozilo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _obrisiVozilo(vozilo['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
