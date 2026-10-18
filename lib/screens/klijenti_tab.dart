import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/klijent_model.dart';

class KlijentiTab extends StatelessWidget {
  const KlijentiTab({super.key});

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
            .collection('users')
            .doc(currentUser.uid)
            .collection('klijenti')
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
              
              // Mapiranje podataka na vaš KlijentModel
              // Prilagodite nazive polja ('naziv', 'uSustavuPdv' / 'pdv') prema vašem modelu
              final String naziv = data['naziv'] ?? 'Bez naziva';
              final bool uSustavuPdv = data['uSustavuPdv'] ?? (data['pdv'] == 'DA');

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('PDV sustav: ${uSustavuPdv ? "Da" : "Ne"}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
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
    );
  }
}
