import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';

class PostavkeTab extends StatefulWidget {
  const PostavkeTab({super.key});

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  final _formKeyPrijevoznik = GlobalKey<FormState>();

  // Kontroleri za prijevoznika
  late TextEditingController _nazivPrijevoznikaController;
  late TextEditingController _oibPrijevoznikaController;
  late TextEditingController _adresaPrijevoznikaController;
  late TextEditingController _gradPrijevoznikaController;
  late TextEditingController _telefonPrijevoznikaController;
  late TextEditingController _emailPrijevoznikaController;
  late TextEditingController _bankaPrijevoznikaController;
  late TextEditingController _ibanPrijevoznikaController;
  bool _uSustavuPdvPrijevoznik = true;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _nazivPrijevoznikaController = TextEditingController();
    _oibPrijevoznikaController = TextEditingController();
    _adresaPrijevoznikaController = TextEditingController();
    _gradPrijevoznikaController = TextEditingController();
    _telefonPrijevoznikaController = TextEditingController();
    _emailPrijevoznikaController = TextEditingController();
    _bankaPrijevoznikaController = TextEditingController();
    _ibanPrijevoznikaController = TextEditingController();

    _ucitajPostavkePrijevoznika();
  }

  @override
  void dispose() {
    _nazivPrijevoznikaController.dispose();
    _oibPrijevoznikaController.dispose();
    _adresaPrijevoznikaController.dispose();
    _gradPrijevoznikaController.dispose();
    _telefonPrijevoznikaController.dispose();
    _emailPrijevoznikaController.dispose();
    _bankaPrijevoznikaController.dispose();
    _ibanPrijevoznikaController.dispose();
    super.dispose();
  }

  Future<void> _ucitajPostavkePrijevoznika() async {
    if (_userId.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('postavke')
        .doc('glavne')
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _nazivPrijevoznikaController.text = data['nazivPrijevoznika'] ?? data['naziv'] ?? '';
        _oibPrijevoznikaController.text = data['oib'] ?? '';
        _adresaPrijevoznikaController.text = data['adresa'] ?? '';
        _gradPrijevoznikaController.text = data['grad'] ?? '';
        _telefonPrijevoznikaController.text = data['telefon'] ?? '';
        _emailPrijevoznikaController.text = data['email'] ?? '';
        _bankaPrijevoznikaController.text = data['banka'] ?? '';
        _ibanPrijevoznikaController.text = data['iban'] ?? '';
        _uSustavuPdvPrijevoznik = data['uSustavuPdv'] ?? true;
      });
    }
  }

  Future<void> _spremiPostavkePrijevoznika() async {
    if (_userId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('postavke')
        .doc('glavne')
        .set({
      'nazivPrijevoznika': _nazivPrijevoznikaController.text.trim(),
      'oib': _oibPrijevoznikaController.text.trim(),
      'adresa': _adresaPrijevoznikaController.text.trim(),
      'grad': _gradPrijevoznikaController.text.trim(),
      'telefon': _telefonPrijevoznikaController.text.trim(),
      'email': _emailPrijevoznikaController.text.trim(),
      'banka': _bankaPrijevoznikaController.text.trim(),
      'iban': _ibanPrijevoznikaController.text.trim(),
      'uSustavuPdv': _uSustavuPdvPrijevoznik,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postavke prijevoznika uspješno spremljene!'), backgroundColor: Colors.green),
      );
    }
  }

  void _prikaziDijalogZaKlijenta({KlijentModel? klijent, String? docId}) {
    if (_userId.isEmpty) return;

    final _nazivController = TextEditingController(text: klijent?.naziv ?? '');
    final _vlasnikController = TextEditingController(text: klijent?.vlasnik ?? '');
    final _adresaController = TextEditingController(text: klijent?.adresa ?? '');
    final _gradController = TextEditingController(text: klijent?.grad ?? '');
    final _oibController = TextEditingController(text: klijent?.oib ?? '');
    final _telefonController = TextEditingController(text: klijent?.telefon ?? '');
    final _emailController = TextEditingController(text: klijent?.email ?? '');
    final _ibanController = TextEditingController(text: klijent?.iban ?? '');
    final _bankaController = TextEditingController(text: klijent?.banka ?? '');
    bool _uSustavuPdv = klijent?.uSustavuPdv ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(klijent == null ? 'Novi Klijent / Agencija' : 'Uredi Klijenta'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nazivController,
                        decoration: const InputDecoration(labelText: 'Naziv klijenta'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _vlasnikController,
                        decoration: const InputDecoration(labelText: 'Vlasnik / Kontakt osoba'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _adresaController,
                        decoration: const InputDecoration(labelText: 'Adresa'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _gradController,
                        decoration: const InputDecoration(labelText: 'Grad'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _oibController,
                        decoration: const InputDecoration(labelText: 'OIB'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _telefonController,
                        decoration: const InputDecoration(labelText: 'Telefon / Mobitel'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _bankaController,
                        decoration: const InputDecoration(labelText: 'Banka'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ibanController,
                        decoration: const InputDecoration(labelText: 'IBAN (npr. HR... - 21 znak)'),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text('Klijent je u sustavu PDV-a'),
                        value: _uSustavuPdv,
                        onChanged: (val) {
                          setStateDialog(() {
                            _uSustavuPdv = val ?? true;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final noviKlijent = KlijentModel(
                      id: docId,
                      userId: _userId,
                      naziv: _nazivController.text.trim(),
                      vlasnik: _vlasnikController.text.trim(),
                      adresa: _adresaController.text.trim(),
                      grad: _gradController.text.trim(),
                      oib: _oibController.text.trim(),
                      telefon: _telefonController.text.trim(),
                      email: _emailController.text.trim(),
                      iban: _ibanController.text.trim(),
                      banka: _bankaController.text.trim(),
                      uSustavuPdv: _uSustavuPdv,
                    );

                    final collectionRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_userId)
                        .collection('klijenti');

                    if (docId == null) {
                      await collectionRef.add(noviKlijent.toJson());
                    } else {
                      await collectionRef.doc(docId).update(noviKlijent.toJson());
                    }

                    if (mounted) Navigator.of(ctx).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke i Klijenti', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0284C7),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PODACI O PRIJEVOZNIKU
            const Text('Podaci o Prijevozniku', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKeyPrijevoznik,
              child: Column(
                children: [
                  TextField(controller: _nazivPrijevoznikaController, decoration: const InputDecoration(labelText: 'Naziv Prijevoznika / Obrta', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _oibPrijevoznikaController, decoration: const InputDecoration(labelText: 'OIB', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _adresaPrijevoznikaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _gradPrijevoznikaController, decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _telefonPrijevoznikaController, decoration: const InputDecoration(labelText: 'Telefon / Mobitel', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _emailPrijevoznikaController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _bankaPrijevoznikaController, decoration: const InputDecoration(labelText: 'Banka', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _ibanPrijevoznikaController, decoration: const InputDecoration(labelText: 'IBAN (npr. HR... - 21 znak)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Prijevoznik je u sustavu PDV-a'),
                    value: _uSustavuPdvPrijevoznik,
                    onChanged: (val) => setState(() => _uSustavuPdvPrijevoznik = val ?? true),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: _spremiPostavkePrijevoznika,
                      icon: const Icon(Icons.save),
                      label: const Text('Spremi Postavke Prijevoznika'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 12),

            // POPIS KLIJENATA / AGENCIJA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popis Klijenta / Agencija', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
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
                  .doc(_userId)
                  .collection('klijenti')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Nema unesenih klijenata.')),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (ctx, idx) {
                    final doc = docs[idx];
                    final data = doc.data() as Map<String, dynamic>;
                    final klijent = KlijentModel.fromJson(data, docId: doc.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(klijent.naziv.isNotEmpty ? klijent.naziv : 'Bez naziva', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Grad: ${klijent.grad} | OIB: ${klijent.oib}\nIBAN: ${klijent.iban} | Banka: ${klijent.banka}'),
                        isThreeLine: true,
                        onTap: () => _prikaziDijalogZaKlijenta(klijent: klijent, docId: doc.id),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_userId)
                                .collection('klijenti')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
