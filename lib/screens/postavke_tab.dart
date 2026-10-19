// lib/screens/postavke_tab.dart
import 'package:flutter/material.dart';
import '../models/prijevoznik_model.dart';
import 'vozni_park_screen.dart';

class PostavkeTab extends StatefulWidget {
  final PrijevoznikModel? prijevoznik;
  final ValueChanged<PrijevoznikModel>? onSpremiPrijevoznika;

  const PostavkeTab({
    Key? key,
    this.prijevoznik,
    this.onSpremiPrijevoznika,
  }) : super(key: key);

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  late TextEditingController _nazivTvrtkeController;
  late TextEditingController _vlasnikController;
  late TextEditingController _adresaController;
  late TextEditingController _gradController;
  late TextEditingController _oibController;
  late TextEditingController _emailTvrtkeController;
  late TextEditingController _telefonController;
  late TextEditingController _bankaController;
  late TextEditingController _ibanController;

  bool _uSustavuPdvA = true;

  final String _korisnikImePrezime = 'Tino Goleš';
  final String _korisnikEmail = 'tino.goles@gmail.com';

  bool _isInitializing = false;

  final List<Map<String, dynamic>> _klijenti = [
    {
      'id': '1',
      'naziv': 'Dječji vrtić Omiš',
      'odgovornaOsoba': 'Ravnateljica Ana Anić',
      'adresa': 'Četvrt Vrilo 23',
      'grad': '21250 Omiš',
      'oib': '32145678910',
      'email': 'info@dv-omis.hr',
      'telefon': '+385 21 862 111',
      'banka': 'Erste & Steiermärkische Bank',
      'iban': 'HR1224020061100000000',
      'uSustavuPdvA': false,
    },
    {
      'id': '2',
      'naziv': 'OŠ 1. listopada 1942 Čišla',
      'odgovornaOsoba': 'Ravnatelj Marko Marković',
      'adresa': 'Čišla bb',
      'grad': '21252 Gata',
      'oib': '12345678901',
      'email': 'os-cisla@skole.hr',
      'telefon': '+385 21 868 010',
      'banka': 'Privredna banka Zagreb',
      'iban': 'HR4023400091100000000',
      'uSustavuPdvA': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.prijevoznik;
    _nazivTvrtkeController = TextEditingController(text: p?.naziv ?? '"Klanac" obrt za prijevoz putnika');
    _vlasnikController = TextEditingController(text: p?.vlasnik ?? 'Ivan Jerčić');
    _adresaController = TextEditingController(text: p?.adresa ?? 'Težačka 25');
    _gradController = TextEditingController(text: p?.grad ?? 'Podgrađe');
    _oibController = TextEditingController(text: p?.oib ?? '52556102683');
    _emailTvrtkeController = TextEditingController(text: p?.email ?? 'prijevoz.klanac@gmail.com');
    _telefonController = TextEditingController(text: p?.telefon ?? '+385 98 244 823');
    _bankaController = TextEditingController(text: p?.banka ?? 'Zagrebačka banka');
    _ibanController = TextEditingController(text: p?.iban ?? 'HR6023600001102016872');
    _uSustavuPdvA = p?.uSustavuPdv ?? true;
  }

  @override
  void dispose() {
    _nazivTvrtkeController.dispose();
    _vlasnikController.dispose();
    _adresaController.dispose();
    _gradController.dispose();
    _oibController.dispose();
    _emailTvrtkeController.dispose();
    _telefonController.dispose();
    _bankaController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _spremiPodatkePrijevoznika() {
    final azuriraniPrijevoznik = PrijevoznikModel(
      naziv: _nazivTvrtkeController.text.trim(),
      vlasnik: _vlasnikController.text.trim(),
      adresa: _adresaController.text.trim(),
      grad: _gradController.text.trim(),
      oib: _oibController.text.trim(),
      email: _emailTvrtkeController.text.trim(),
      telefon: _telefonController.text.trim(),
      banka: _bankaController.text.trim(),
      iban: _ibanController.text.trim(),
      uSustavuPdv: _uSustavuPdvA,
    );

    if (widget.onSpremiPrijevoznika != null) {
      widget.onSpremiPrijevoznika!(azuriraniPrijevoznik);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Podaci o prijevozniku uspješno spremljeni!'),
        backgroundColor: Colors.green,
      ),
    );
  }

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

  void _otvoriDijalogKlijent([Map<String, dynamic>? klijent, StateSetter? setModalState]) {
    final _nazivCtrl = TextEditingController(text: klijent?['naziv'] ?? '');
    final _odgovornaOsobaCtrl = TextEditingController(text: klijent?['odgovornaOsoba'] ?? '');
    final _adresaCtrl = TextEditingController(text: klijent?['adresa'] ?? '');
    final _gradCtrl = TextEditingController(text: klijent?['grad'] ?? '');
    final _oibCtrl = TextEditingController(text: klijent?['oib'] ?? '');
    final _emailCtrl = TextEditingController(text: klijent?['email'] ?? '');
    final _telefonCtrl = TextEditingController(text: klijent?['telefon'] ?? '');
    final _bankaCtrl = TextEditingController(text: klijent?['banka'] ?? '');
    final _ibanCtrl = TextEditingController(text: klijent?['iban'] ?? '');

    bool _uSustavuPdvAKlijent = klijent?['uSustavuPdvA'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(klijent == null ? 'Dodaj novog klijenta' : 'Uredi klijenta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nazivCtrl,
                      decoration: const InputDecoration(labelText: 'Naziv tvrtke / agencije', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _odgovornaOsobaCtrl,
                      decoration: const InputDecoration(labelText: 'Odgovorna osoba / Kontakt', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _adresaCtrl,
                      decoration: const InputDecoration(labelText: 'Adresa', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _gradCtrl,
                      decoration: const InputDecoration(labelText: 'Grad / Mjesto', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _oibCtrl,
                      decoration: const InputDecoration(labelText: 'OIB', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail klijenta', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _telefonCtrl,
                      decoration: const InputDecoration(labelText: 'Telefon / Mobitel', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bankaCtrl,
                      decoration: const InputDecoration(labelText: 'Banka', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ibanCtrl,
                      decoration: const InputDecoration(labelText: 'IBAN za plaćanje', isDense: true),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('U sustavu PDV-a', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      value: _uSustavuPdvAKlijent,
                      onChanged: (val) => setDialogState(() => _uSustavuPdvAKlijent = val),
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
                  onPressed: () {
                    if (_nazivCtrl.text.trim().isEmpty) return;

                    final noviKlijent = {
                      'id': klijent?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      'naziv': _nazivCtrl.text.trim(),
                      'odgovornaOsoba': _odgovornaOsobaCtrl.text.trim(),
                      'adresa': _adresaCtrl.text.trim(),
                      'grad': _gradCtrl.text.trim(),
                      'oib': _oibCtrl.text.trim(),
                      'email': _emailCtrl.text.trim(),
                      'telefon': _telefonCtrl.text.trim(),
                      'banka': _bankaCtrl.text.trim(),
                      'iban': _ibanCtrl.text.trim(),
                      'uSustavuPdvA': _uSustavuPdvAKlijent,
                    };

                    setState(() {
                      if (klijent == null) {
                        _klijenti.add(noviKlijent);
                      } else {
                        final index = _klijenti.indexWhere((k) => k['id'] == klijent['id']);
                        if (index != -1) _klijenti[index] = noviKlijent;
                      }
                    });

                    if (setModalState != null) {
                      setModalState(() {});
                    }

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

  void _otvoriPopisKlijenata() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _otvoriDijalogKlijent(null, setModalState),
                      icon: const Icon(Icons.add_business),
                      label: const Text('Dodaj novog klijenta / agenciju'),
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: _klijenti.isEmpty
                        ? const Center(child: Text('Nema unesenih klijenata.'))
                        : ListView.separated(
                            itemCount: _klijenti.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final klijent = _klijenti[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        child: Text(
                                          klijent['naziv'].toString().isNotEmpty
                                              ? klijent['naziv'].toString().substring(0, 2).toUpperCase()
                                              : 'KL',
                                        ),
                                      ),
                                      title: Text(
                                        klijent['naziv'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text('Odgovorna osoba: ${klijent['odgovornaOsoba']}'),
                                          Text('Adresa: ${klijent['adresa']}, ${klijent['grad']} | OIB: ${klijent['oib']}'),
                                          Text('E-mail: ${klijent['email']} | Tel: ${klijent['telefon']}'),
                                          Text('Banka: ${klijent['banka']} | IBAN: ${klijent['iban']}'),
                                          Text('PDV status: ${klijent['uSustavuPdvA'] == true ? "U sustavu PDV-a" : "Nije u sustavu PDV-a"}'),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Pozivanje: ${klijent['telefon']}')),
                                            );
                                          },
                                          icon: const Icon(Icons.phone, size: 18, color: Colors.green),
                                          label: const Text('Nazovi', style: TextStyle(color: Colors.green)),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () => _otvoriDijalogKlijent(klijent, setModalState),
                                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                          label: const Text('Uredi', style: TextStyle(color: Colors.blue)),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _klijenti.removeWhere((k) => k['id'] == klijent['id']);
                                            });
                                            setModalState(() {});
                                          },
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          label: const Text('Obriši', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
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
                            controller: _adresaController,
                            decoration: const InputDecoration(labelText: 'Adresa', isDense: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _gradController,
                            decoration: const InputDecoration(labelText: 'Grad / Mjesto', isDense: true),
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
                              onPressed: _spremiPodatkePrijevoznika,
                              icon: const Icon(Icons.save),
                              label: const Text('Spremi podatke'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
