// Popis klijenata sa svim atributima identičnim prijevozniku
  final List<Map<String, dynamic>> _klijenti = [
    {
      'id': '1',
      'naziv': 'Dječji vrtić Omiš',
      'odgovornaOsoba': 'Ravnateljica Ana Anić',
      'sjediste': 'Četvrt Vrilo 23, 21250 Omiš',
      'adresa': 'Četvrt Vrilo 23, 21250 Omiš',
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
      'sjediste': 'Čišla bb, 21252 Gata',
      'adresa': 'Čišla bb, 21252 Gata',
      'oib': '12345678901',
      'email': 'os-cisla@skole.hr',
      'telefon': '+385 21 868 010',
      'banka': 'Privredna banka Zagreb',
      'iban': 'HR4023400091100000000',
      'uSustavuPdvA': false,
    },
  ];

  void _otvoriDijalogKlijent([Map<String, dynamic>? klijent, StateSetter? setModalState]) {
    final _nazivCtrl = TextEditingController(text: klijent?['naziv'] ?? '');
    final _odgovornaOsobaCtrl = TextEditingController(text: klijent?['odgovornaOsoba'] ?? '');
    final _sjedisteCtrl = TextEditingController(text: klijent?['sjediste'] ?? '');
    final _adresaCtrl = TextEditingController(text: klijent?['adresa'] ?? '');
    final _oibCtrl = TextEditingController(text: klijent?['oib'] ?? '');
    final _emailCtrl = TextEditingController(text: klijent?['email'] ?? '');
    final _telefonCtrl = TextEditingController(text: klijent?['telefon'] ?? '');
    final _bankaCtrl = TextEditingController(text: klijent?['banka'] ?? '');
    final _ibanCtrl = TextEditingController(text: klijent?['iban'] ?? '');

    bool _uSustavuPdvA = klijent?['uSustavuPdvA'] ?? true;

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
                      controller: _sjedisteCtrl,
                      decoration: const InputDecoration(labelText: 'Sjedište tvrtke / agencije', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _adresaCtrl,
                      decoration: const InputDecoration(labelText: 'Adresa za dostavu / Operativno sjedište', isDense: true),
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
                      value: _uSustavuPdvA,
                      onChanged: (val) => setDialogState(() => _uSustavuPdvA = val),
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
                      'sjediste': _sjedisteCtrl.text.trim(),
                      'adresa': _adresaCtrl.text.trim(),
                      'oib': _oibCtrl.text.trim(),
                      'email': _emailCtrl.text.trim(),
                      'telefon': _telefonCtrl.text.trim(),
                      'banka': _bankaCtrl.text.trim(),
                      'iban': _ibanCtrl.text.trim(),
                      'uSustavuPdvA': _uSustavuPdvA,
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
                                          Text('Kontakt: ${klijent['odgovornaOsoba']}'),
                                          Text('Sjedište: ${klijent['sjediste']} | OIB: ${klijent['oib']}'),
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
