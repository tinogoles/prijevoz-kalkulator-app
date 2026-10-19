import 'package:flutter/material.dart';
import 'vozni_park_screen.dart';

class PostavkeTab extends StatefulWidget {
  const PostavkeTab({Key? key}) : super(key: key);

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  // Kontroleri za podatke o tvrtki prijevoznika
  final _nazivTvrtkeController = TextEditingController(text: 'Prijevoz d.o.o.');
  final _adresaController = TextEditingController(text: 'Ulica Prijevoznika 1, Zagreb');
  final _oibController = TextEditingController(text: '12345678901');
  final _emailTvrtkeController = TextEditingController(text: 'info@prijevoz.hr');
  final _telefonController = TextEditingController(text: '+385 1 2345 678');
  final _ibanController = TextEditingController(text: 'HR1234567890123456789');

  // Podaci o prijavljenom korisniku
  final String _korisnikImePrezime = 'Ivan Horvat';
  final String _korisnikEmail = 'ivan.horvat@prijevoz.hr';

  bool _isInitializing = false;

  void _inicijalizirajBazuCestarina() async {
    setState(() => _isInitializing = true);

    // Simulacija poziva inicijalizacije baze cestarina
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isInitializing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baza cestarina uspješno inicijalizirana!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _odjavaKorisnika() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Jeste li sigurni da se želite odjaviti iz aplikacije?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // Ovdje dodajte logiku za odjavu (npr. FirebaseAuth ili povratak na LoginScreen)
            },
            child: const Text('Odjavi se', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke Aplikacije'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Prilagodba širine kartica (na širim ekranima idu 3 u red, s lijeva na desno)
            double cardWidth = constraints.maxWidth > 950
                ? (constraints.maxWidth - 48) / 3
                : (constraints.maxWidth > 600 ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth);

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // -------------------------------------------------------------
                // MODUL 1: Podaci o Vašoj tvrtki (Prijevoznik)
                // -------------------------------------------------------------
                SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.business, color: Colors.blue, size: 28),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Podaci o tvrtki',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          TextField(
                            controller: _nazivTvrtkeController,
                            decoration: const InputDecoration(labelText: 'Naziv tvrtke', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _adresaController,
                            decoration: const InputDecoration(labelText: 'Adresa i sjedište', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _oibController,
                            decoration: const InputDecoration(labelText: 'OIB', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailTvrtkeController,
                            decoration: const InputDecoration(labelText: 'E-mail tvrtke', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _telefonController,
                            decoration: const InputDecoration(labelText: 'Telefon / Mobitel', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ibanController,
                            decoration: const InputDecoration(labelText: 'IBAN za plaćanje', isDense: true),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Podaci o tvrtki su spremljeni.')),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Spremi podatke'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // MODUL 2: Popis klijenata / agencija & Vozni park
                // -------------------------------------------------------------
                SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.directions_bus, color: Colors.orange, size: 28),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Logistika & Baze',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.people_alt, color: Colors.indigo),
                            title: const Text('Popis klijenata / agencija'),
                            subtitle: const Text('Upravljanje adresarom klijenata'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Otvaranje modula za klijente
                            },
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.directions_bus_filled, color: Colors.green),
                            title: const Text('Vozni park'),
                            subtitle: const Text('Dodavanje vozila i opreme'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VozniParkScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // MODUL 3: Korisnik aplikacije (User, Inicijalizacija & Log-out)
                // -------------------------------------------------------------
                SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.person, color: Colors.green, size: 28),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Korisnik aplikacije',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(
                              _korisnikImePrezime,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(_korisnikEmail),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sustav cestarina:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isInitializing ? null : _inicijalizirajBazuCestarina,
                              icon: _isInitializing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.sync),
                              label: Text(_isInitializing ? 'Inicijalizacija...' : 'Inicijaliziraj bazu cestarina'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _odjavaKorisnika,
                              icon: const Icon(Icons.logout),
                              label: const Text('Odjavi se (Log-out)'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
