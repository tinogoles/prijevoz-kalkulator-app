import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/klijent_model.dart';

class KlijentiTab extends StatelessWidget {
  const KlijentiTab({super.key});

  void _prikaziDijalogZaKlijenta(BuildContext context, {KlijentModel? klijent, String? docId}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _nazivController, decoration: const InputDecoration(labelText: 'Naziv klijenta')),
                    const SizedBox(height: 10),
                    TextField(controller: _vlasnikController, decoration: const InputDecoration(labelText: 'Vlasnik / Kontakt osoba')),
                    const SizedBox(height: 10),
                    TextField(controller: _adresaController, decoration: const InputDecoration(labelText: 'Adresa')),
                    const SizedBox(height: 10),
                    TextField(controller: _gradController, decoration: const InputDecoration(labelText: 'Grad')),
                    const SizedBox(height: 10),
                    TextField(controller: _oibController, decoration: const InputDecoration(labelText: 'OIB')),
                    const SizedBox(height: 10),
                    TextField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon / Mobitel')),
                    const SizedBox(height: 10),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 10),
                    TextField(controller: _ibanController, decoration: const InputDecoration(labelText: 'IBAN')),
                    const SizedBox(height: 10),
                    TextField(controller: _bankaController, decoration: const InputDecoration(labelText: 'Banka')),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final noviKlijent = KlijentModel(
                      id: docId,
                      userId: currentUser.uid,
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

                    if (docId == null) {
                      await FirebaseFirestore.instance.collection('klijenti').add(noviKlijent.toJson());
                    } else {
                      await FirebaseFirestore.instance.collection('klijenti').doc(docId).update(noviKlijent.toJson());
                    }

                    Navigator.of(ctx).pop();
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
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Korisnik nije prijavljen.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje Klijentima', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('klijenti')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nema unesenih klijenata.'));
          }

          final klijentiDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: klijentiDocs.length,
            itemBuilder: (ctx, idx) {
              var doc = klijentiDocs[idx];
              var data = doc.data() as Map<String, dynamic>;
              
              final klijent = KlijentModel.fromJson(data, docId: doc.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(klijent.naziv.isNotEmpty ? klijent.naziv : 'Bez naziva', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Grad: ${klijent.grad} | OIB: ${klijent.oib}\nPDV: ${klijent.uSustavuPdv ? "Da" : "Ne"}'),
                  isThreeLine: true,
                  onTap: () => _prikaziDijalogZaKlijenta(context, klijent: klijent, docId: doc.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await FirebaseFirestore.instance
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _prikaziDijalogZaKlijenta(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
