import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/klijent_model.dart';

class KlijentiTab extends StatelessWidget {
  final List<KlijentModel> klijenti;
  final String userId;

  const KlijentiTab({
    super.key,
    required this.klijenti,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje Klijentima', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: klijenti.isEmpty
          ? const Center(child: Text('Nema unesenih klijenata.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: klijenti.length,
              itemBuilder: (ctx, idx) {
                var klijent = klijenti[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(klijent.naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('PDV sustav: ${klijent.uSustavuPdv ? "Da" : "Ne"}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        if (userId.isNotEmpty && klijent.id.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('klijenti')
                              .doc(klijent.id)
                              .delete();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
