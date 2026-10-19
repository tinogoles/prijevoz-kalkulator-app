// lib/screens/postavke_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _nazivTvrtkeController = TextEditingController();
  final _vlasnikController = TextEditingController();
  final _adresaController = TextEditingController();
  final _gradController = TextEditingController();
  final _oibController = TextEditingController();
  final _emailTvrtkeController = TextEditingController();
  final _telefonController = TextEditingController();
  final _bankaController = TextEditingController();
  final _ibanController = TextEditingController();

  bool _uSustavuPdvA = true;
  bool _isLoading = true;

  User? get currentUser => FirebaseAuth.instance.currentUser;
  String get userKey => currentUser?.email ?? currentUser?.uid ?? 'zadani_korisnik';

  bool _isInitializing = false;
  final List<Map<String, dynamic>> _klijenti = [];

  @override
  void initState() {
    super.initState();
    _ucitajKorisnickePodatke();
  }

  Future<void> _ucitajKorisnickePodatke() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(userKey)
          .collection('postavke')
          .doc('prijevoznik')
          .get();

      if (doc.exists && doc.data() != null) {
        final p = PrijevoznikModel.fromJson(doc.data()!);
        _postaviPolja(p);
      } else if (widget.prijevoznik != null) {
        _postaviPolja(widget.prijevoznik!);
      }
    } catch (e) {
      debugPrint('Greška pri učitavanju korisničkih podataka: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _postaviPolja(PrijevoznikModel p) {
    _nazivTvrtkeController.text = p.naziv;
    _vlasnikController.text = p.vlasnik;
    _adresaController.text = p.adresa;
    _gradController.text = p.grad;
    _oibController.text = p.oib;
    _emailTvrtkeController.text = p.email.isNotEmpty ? p.email : (currentUser?.email ?? '');
    _telefonController.text = p.telefon;
    _bankaController.text = p.banka;
    _ibanController.text = p.iban;
    _uSustavuPdvA = p.uSustavuPdv;
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

  Future<void> _spremiPodatkePrijevoznika() async {
    final noviPrijevoznik = PrijevoznikModel(
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

    try {
      await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(userKey)
          .collection('postavke')
          .doc('prijevoznik')
          .set(noviPrijevoznik.toJson(), SetOptions(merge: true));

      if (widget.onSpremiPrijevoznika != null) {
        widget.onSpremiPrijevoznika!(noviPrijevoznik);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Podaci o prijevozniku trajno spremljeni na Cloud!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri spremanju na Cloud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _inicijalizirajBazuCestarina() async {
    setState(() => _isInitializing = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('opci_podaci')
          .doc('cestarine')
          .get();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              snapshot.exists
                  ? 'Baza cestarina uspješno sinkronizirana iz Clouda!'
                  : 'Baza cestarina je spremna.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri sinkronizaciji cestarina: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
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
                    TextField(controller: _nazivCtrl, decoration: const InputDecoration(labelText: 'Naziv tvrtke / agencije', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _odgovornaOsobaCtrl, decoration: const InputDecoration(labelText: 'Odgovorna osoba / Kontakt', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _adresaCtrl, decoration: const InputDecoration(labelText: 'Adresa', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _gradCtrl, decoration: const InputDecoration(labelText: 'Grad / Mjesto', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _oibCtrl, decoration: const InputDecoration(labelText: 'OIB', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'E-mail klijenta', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _telefonCtrl, decoration: const InputDecoration(labelText: 'Telefon / Mobitel', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _bankaCtrl, decoration: const InputDecoration(labelText: 'Banka', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: _ibanCtrl, decoration: const InputDecoration(labelText: 'IBAN za plaćanje', isDense: true)),
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
                      const Text('Popis klijenata / agencija', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                                      title: Text(klijent['naziv'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pozivanje: ${klijent['telefon']}')));
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

  void _odjavaKorisnika() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Jeste li sigurni da se želite odjaviti iz aplikacije?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Odjavi se', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      appBar: AppBar(title: const Text('Postavke Aplikacije')),
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
                              Expanded(child: Text('Podaci o tvrtki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(height: 24),
                          TextField(controller: _nazivTvrtkeController, decoration: const InputDecoration(labelText: 'Naziv tvrtke / obrta', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _vlasnikController, decoration: const InputDecoration(labelText: 'Vlasnik / Odgovorna osoba', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _adresaController, decoration: const InputDecoration(labelText: 'Adresa', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _gradController, decoration: const InputDecoration(labelText: 'Grad / Mjesto', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _oibController, decoration: const InputDecoration(labelText: 'OIB', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _emailTvrtkeController, decoration: const InputDecoration(labelText: 'E-mail tvrtke', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon / Mobitel', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _bankaController, decoration: const InputDecoration(labelText: 'Banka', isDense: true)),
                          const SizedBox(height: 8),
                          TextField(controller: _ibanController, decoration: const InputDecoration(labelText: 'IBAN za plaćanje', isDense: true)),
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
                              Expanded(child: Text('Logistika & Baze', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
                              Expanded(child: Text('Korisnik aplikacije', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                            title: Text(currentUser?.displayName ?? 'Korisnik', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(currentUser?.email ?? 'Nije prijavljen'),
                          ),
                          const SizedBox(height: 16),
                          const Text('Sustav cestarina:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isInitializing ? null : _inicijalizirajBazuCestarina,
                              icon: _isInitializing
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.sync),
                              label: Text(_isInitializing ? 'Inicijalizacija...' : 'Sinkroniziraj bazu cestarina'),
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
        );
        
      },
    );
  }
}
