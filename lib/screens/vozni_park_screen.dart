// lib/screens/vozni_park_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VozniParkScreen extends StatefulWidget {
  const VozniParkScreen({Key? key}) : super(key: key);

  @override
  State<VozniParkScreen> createState() => _VozniParkScreenState();
}

class _VozniParkScreenState extends State<VozniParkScreen> {
  List<Map<String, dynamic>> _vozila = [];
  bool _isLoading = true;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<String> _hacSkupineCestarine = [
    'I. Skupina (Osobna vozila / motocikli)',
    'II. Skupina (Vozila do 3.5t / kombi)',
    'III. Skupina (Vozila preko 3.5t / midi bus)',
    'IV. Skupina (Vozila preko 3.5t / veliki autobus)',
  ];

  @override
  void initState() {
    super.initState();
    _dohvatiVozilaIzFirestore();
  }

  void _dohvatiVozilaIzFirestore() {
    if (_userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    debugPrint('Slušam vozni park za korisnika UID: $_userId');

    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('vozni_park')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        debugPrint('Dohvaćeno vozila iz Firestorea: ${snapshot.docs.length}');
        setState(() {
          _vozila = snapshot.docs.map((d) {
            var data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();
          _isLoading = false;
        });
      }
    }, onError: (e) {
      debugPrint('Greška pri slušanju voznog parka: $e');
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _otvoriDijalogVozilo([Map<String, dynamic>? vozilo]) {
    final _nazivCtrl = TextEditingController(text: vozilo?['naziv'] ?? '');
    final _kapacitetCtrl = TextEditingController(text: vozilo?['kapacitet'] ?? '');
    final _potrosnjaCtrl = TextEditingController(text: vozilo?['potrosnja'] ?? '');
    
    String ucitanaKategorija = vozilo?['kategorija'] ?? '';

    // Normalizacija / mapiranje ako je ostao stari dugački naziv
    if (ucitanaKategorija.contains('II.')) {
      ucitanaKategorija = _hacSkupineCestarine[1];
    } else if (ucitanaKategorija.contains('III.')) {
      ucitanaKategorija = _hacSkupineCestarine[2];
    } else if (ucitanaKategorija.contains('IV.')) {
      ucitanaKategorija = _hacSkupineCestarine[3];
    } else if (ucitanaKategorija.contains('I.')) {
      ucitanaKategorija = _hacSkupineCestarine[0];
    }

    String _odabranaSkupina = _hacSkupineCestarine.contains(ucitanaKategorija)
        ? ucitanaKategorija
        : _hacSkupineCestarine[1];

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
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nazivCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Naziv / Oznaka vozila (npr. Mercedes Tourismo)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _kapacitetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kapacitet (broj sjedala, npr. 49 + 1 + 1)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _potrosnjaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Potrošnja ( L/100km )',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _hacSkupineCestarine.contains(_odabranaSkupina) ? _odabranaSkupina : _hacSkupineCestarine[1],
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategorija vozila za cestarinu (HAC)',
                          isDense: true,
                        ),
                        items: _hacSkupineCestarine.map((kat) {
                          return DropdownMenuItem(value: kat, child: Text(kat, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => _odabranaSkupina = val);
                          }
                        },
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
                  onPressed: () async {
                    if (_nazivCtrl.text.trim().isEmpty) return;

                    final docId = vozilo?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
                    final novoVozilo = {
                      'id': docId,
                      'naziv': _nazivCtrl.text.trim(),
                      'kapacitet': _kapacitetCtrl.text.trim(),
                      'kategorija': _odabranaSkupina,
                      'potrosnja': _potrosnjaCtrl.text.trim().isNotEmpty ? _potrosnjaCtrl.text.trim() : '0.0',
                      'oprema': Map<String, bool>.from(_oprema),
                    };

                    if (_userId.isNotEmpty) {
                      debugPrint('Pokušavam spremiti vozilo na: users/$_userId/vozni_park/$docId');
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_userId)
                            .collection('vozni_park')
                            .doc(docId)
                            .set(novoVozilo);
                        debugPrint('Vozilo uspješno spremljeno u Firestore!');
                      } catch (e) {
                        debugPrint('GREŠKA pri spremanju vozila: $e');
                      }
                    } else {
                      debugPrint('GREŠKA: _userId je prazan!');
                    }

                    if (mounted) Navigator.pop(context);
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

  void _obrisiVozilo(String id) async {
    if (_userId.isNotEmpty) {
      debugPrint('Brišem vozilo: users/$_userId/vozni_park/$id');
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('vozni_park')
            .doc(id)
            .delete();
        debugPrint('Vozilo obrisano iz Firestorea.');
      } catch (e) {
        debugPrint('GREŠKA pri brisanju vozila: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje voznim parkom'),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _vozila.isEmpty
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
                                '${vozilo['naziv']} (${vozilo['kapacitet']} sjedala)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Kategorija: ${vozilo['kategorija']}'),
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
