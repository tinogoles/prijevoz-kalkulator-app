import 'package:flutter/material.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';

class PostavkeTab extends StatelessWidget {
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final VoidCallback onUpdate;

  const PostavkeTab({
    super.key,
    required this.prijevoznik,
    required this.klijenti,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke Obrta', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Podaci o prijevozniku',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: prijevoznik.naziv),
            decoration: const InputDecoration(labelText: 'Naziv obrta/tvrtke', border: OutlineInputBorder()),
            onChanged: (val) {
              prijevoznik.naziv = val;
              onUpdate();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: prijevoznik.oib),
            decoration: const InputDecoration(labelText: 'OIB', border: OutlineInputBorder()),
            onChanged: (val) {
              prijevoznik.oib = val;
              onUpdate();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: prijevoznik.grad),
            decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder()),
            onChanged: (val) {
              prijevoznik.grad = val;
              onUpdate();
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              onUpdate();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Postavke spremljene!'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Spremi postavke'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
