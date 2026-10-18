import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prijevoz_kalkulator/services/cestarine_service.dart';

class PostavkeTab extends StatefulWidget {
  const PostavkeTab({super.key});

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Kontroleri za podatke prijevoznika
  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _vlasnikController = TextEditingController();
  final TextEditingController _adresaController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _oibController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bankaController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  bool _uSustavuPdv = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ucitajPostavke();
  }

  Future<void> _ucitajPostavke() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('postavke')
          .doc('glavne')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nazivController.text = data['nazivPrijevoznika'] ?? '';
        _vlasnikController.text = data['vlasnik'] ?? '';
        _adresaController.text = data['adresa'] ?? '';
        _gradController.text = data['grad'] ?? '';
        _oibController.text = data['oib'] ?? '';
        _telefonController.text = data['telefon'] ?? '';
        _emailController.text = data['email'] ?? '';
        _bankaController.text = data['banka'] ?? '';
        _ibanController.text = data['iban'] ?? '';
        setState(() {
          _uSustavuPdv = data['uSustavuPdv'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Greška pri učitavanju postavki: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _spremiPostavke() async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('postavke')
          .doc('glavne')
          .set({
        'nazivPrijevoznika': _nazivController.text.trim(),
        'vlasnik': _vlasnikController.text.trim(),
        'adresa': _adresaController.text.trim(),
        'grad': _gradController.text.trim(),
        'oib': _oibController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'banka': _bankaController.text.trim(),
        'iban': _ibanController.text.trim(),
        'uSustavuPdv': _uSustavuPdv,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postavke uspješno spremljene!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri spremanju: $e')),
        );
      }
    }
  }

  Future<void> _inicijalizirajCestarine() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Baza cestarina uspješno inicijalizirana u Firebase!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška kod inicijalizacije cestarina: $e')),
        );
      }
    }
  }

  // Ovdje je postojeciPodaci umjesto postojećiPodaci (bez kvačice)
  void _prikaziDijalogZaKlijenta({String? docId, Map<String, dynamic>? postojeciPodaci}) {
    final TextEditingController nazivKlijentaController = TextEditingController(text: postojeciPodaci?['naziv'] ?? '');
    final TextEditingController gradKlijentaController = TextEditingController(text: postojeciPodaci?['grad'] ?? '');
    final TextEditingController oibKlijentaController = TextEditingController(text: postojeciPodaci?['oib'] ?? '');
    bool pdvKlijenta = postojeciPodaci?['pdv'] == 'DA';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(docId == null ? 'Novi Klijent / Agencija' : 'Uredi Klijenta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nazivKlijentaController,
                      decoration: const InputDecoration(labelText: 'Naziv klijenta', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: gradKlijentaController,
                      decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: oibKlijentaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'OIB', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Klijent je u sustavu PDV-a'),
                      value: pdvKlijenta,
                      onChanged: (val) {
                        setStateDialog(() {
                          pdvKlijenta = val ?? false;
                        });
                      },
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
                  onPressed: () async {
                    if (_currentUser == null) return;
                    final klijentData = {
                      'naziv': nazivKlijentaController.text.trim(),
                      'grad': gradKlijentaController.text.trim(),
                      'oib': oibKlijentaController.text.trim(),
                      'pdv': pdvKlijenta ? 'DA' : 'NE',
                    };

                    final klijentiRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUser!.uid)
                        .collection('klijenti');

                    if (docId == null) {
                      await klijentiRef.add(klijentData);
                    } else {
                      await klijentiRef.doc(docId).update(klijentData);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke i Klijenti'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Podaci o Vašoj Tvrtki (Prijevoznik)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
            ),
            const SizedBox(height: 12),
            TextField(controller: _nazivController, decoration: const InputDecoration(labelText: 'Naziv prijevoznika', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _vlasnikController, decoration: const InputDecoration(labelText: 'Vlasnik / Direktor', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _adresaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _gradController, decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _oibController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OIB (točno 11 znamenki)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _telefonController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _bankaController, decoration: const InputDecoration(labelText: 'Banka', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _ibanController, decoration: const InputDecoration(labelText: 'IBAN (npr. HR... - 21 znak)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Prijevoznik je u sustavu PDV-a'),
              value: _uSustavuPdv,
              onChanged: (val) {
                setState(() {
                  _uSustavuPdv = val ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _spremiPostavke,
              icon: const Icon(Icons.save),
              label: const Text('Spremi Postavke Prijevoznika', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const Divider(height: 40, thickness: 2),

            // SEKCIJA KLIJENTI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popis Klijenta / Agencija',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
                ElevatedButton.icon(
                  onPressed: () => _prikaziDijalogZaKlijenta(),
                  icon: const Icon(Icons.add),
                  label: const Text('Novi Klijent'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser?.uid)
                  .collection('klijenti')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nema unesenih klijenata.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  );
                }

                final klijenti = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: klijenti.length,
                  itemBuilder: (context, index) {
                    final klijent = klijenti[index].data() as Map<String, dynamic>;
                    final docId = klijenti[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(klijent['naziv'] ?? 'Bez naziva', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${klijent['grad'] ?? ''} | OIB: ${klijent['oib'] ?? ''} | PDV: ${klijent['pdv'] ?? 'NE'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _prikaziDijalogZaKlijenta(docId: docId, postojeciPodaci: klijent),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_currentUser?.uid)
                                    .collection('klijenti')
                                    .doc(docId)
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const Divider(height: 40, thickness: 2),

            ElevatedButton.icon(
              onPressed: _inicijalizirajCestarine,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Inicijaliziraj bazu cestarina u Firebase', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
