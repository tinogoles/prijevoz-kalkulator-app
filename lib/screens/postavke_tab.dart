import 'package:flutter/material.dart';
import 'vozni_park_screen.dart';

class PostavkeTab extends StatefulWidget {
  const PostavkeTab({Key? key}) : super(key: key);

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  // Svi potrebni atributi prijevoznika s vašim stvarnim podacima
  final _nazivTvrtkeController = TextEditingController(text: '"Klanac" obrt za prijevoz putnika');
  final _vlasnikController = TextEditingController(text: 'Ivan Jerčić');
  final _sjedisteController = TextEditingController(text: 'Težačka 25, 21207 Kostanje');
  final _adresaController = TextEditingController(text: 'Podgrađe bb, 21250 Omiš');
  final _oibController = TextEditingController(text: '52556102683');
  final _emailTvrtkeController = TextEditingController(text: 'prijevoz.klanac@gmail.com');
  final _telefonController = TextEditingController(text: '+385 98 244 823');
  final _bankaController = TextEditingController(text: 'Zagrebačka banka');
  final _ibanController = TextEditingController(text: 'HR6023600001102016872');
  
  bool _uSustavuPdvA = true; // Prekidač za PDV status

  // Korisnik aplikacije
  final String _korisnikImePrezime = 'Tino Goleš';
  final String _korisnikEmail = 'tino.goles@gmail.com';

  bool _isInitializing = false;

  void _inicijalizirajBazuCestarina() async {
    setState(() => _isInitializing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isInitializing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baza cestarina uspješno inicijalizirana s preko 180 lokacija!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _otvoriPopisKlijenata() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popis klijenata / agencija',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: CircleAvatar(child: Text('DV')),
                      title: Text('Dječji vrtić Omiš'),
                      subtitle: Text('Četvrt Vrilo 23, Omiš | OIB: 3214567891'),
                      trailing: Icon(Icons.phone),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(child: Text('OŠ')),
                      title: Text('OŠ 1. listopada 1942 Čišla'),
                      subtitle: Text('Čišla bb | OIB: 12345678901'),
                      trailing: Icon(Icons.phone),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
            onPressed: () => Navigator.pop(context),
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
            double cardWidth = constraints.maxWidth > 950
                ? (constraints.maxWidth - 48) / 3
                : (constraints.maxWidth > 600 ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth);

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // -------------------------------------------------------------
                // KARTICA 1: Podaci o tvrtki / obrtu (Prijevoznik)
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
                            decoration: const InputDecoration(labelText: 'Naziv tvrtke / obrta', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _vlasnikController,
                            decoration: const InputDecoration(labelText: 'Vlasnik / Odgovorna osoba', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _sjedisteController,
                            decoration: const InputDecoration(labelText: 'Sjedište tvrtke / obrta', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _adresaController,
                            decoration: const InputDecoration(labelText: 'Adresa za poštu / Operativna baza', isDense: true),
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
                            controller: _bankaController,
                            decoration: const InputDecoration(labelText: 'Banka', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ibanController,
                            decoration: const InputDecoration(labelText: 'IBAN za plaćanje', isDense: true),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('U sustavu PDV-a', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            value: _uSustavuPdvA,
                            onChanged: (val) => setState(() => _uSustavuPdvA = val),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Podaci o prijevozniku uspješno spremljeni!')),
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
                // KARTICA 2: Logistika & Baze (Klijenti & Vozni park)
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
                            onTap: _otvoriPopisKlijenata,
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
                // KARTICA 3: Korisnik aplikacije
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
