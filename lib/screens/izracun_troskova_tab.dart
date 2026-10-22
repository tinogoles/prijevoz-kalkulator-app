import 'package:flutter/material.dart';
import '../models/kalkulacija_model.dart';
import '../models/klijent_model.dart';
import '../models/prijevoznik_model.dart';
import 'lokacije_autocomplete_widget.dart';
import 'izracun_logic_mixin.dart';
import 'sekcija_autoput_widget.dart';
import 'sekcija_parametri_troskova_widget.dart';
import 'mapa_rute_screen.dart';

class IzracunTroskovaTab extends StatefulWidget {
  final PrijevoznikModel prijevoznik;
  final KlijentModel? aktivniKlijent;
  final KalkulacijaModel? kalkulacijaZaUredivanje;
  final ValueChanged<KlijentModel?> onKlijentChanged;
  final ValueChanged<KalkulacijaModel> onSpremiKalkulaciju;

  const IzracunTroskovaTab({
    super.key,
    required this.prijevoznik,
    required this.aktivniKlijent,
    required this.kalkulacijaZaUredivanje,
    required this.onKlijentChanged,
    required this.onSpremiKalkulaciju,
  });

  @override
  State<IzracunTroskovaTab> createState() => _IzracunTroskovaTabState();
}

class _IzracunTroskovaTabState extends State<IzracunTroskovaTab> with IzracunLogicMixin {
  @override
  void initState() {
    super.initState();
    inicijalizirajLogiku(kalkulacijaZaUredivanje: widget.kalkulacijaZaUredivanje);
  }

  @override
  void dispose() {
    disposeLogika();
    super.dispose();
  }

  Future<void> _odaberiDatum(BuildContext context, bool jePolazak) async {
    final DateTime? odabir = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (odabir != null) {
      setState(() {
        String noviDatum = formatirajDatum(odabir);
        if (jePolazak) {
          datumPolaskaController.text = noviDatum;
          datumPovratkaController.text = noviDatum;
        } else {
          datumPovratkaController.text = noviDatum;
        }
        preracunajBrojDana();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> listaKlijenata = klijentiService.klijenti;
    String? aktivniKlijentId;
    if (widget.aktivniKlijent != null) {
      for (var kMap in listaKlijenata) {
        if ((kMap['id'] ?? '').toString() == widget.aktivniKlijent!.id ||
            (kMap['naziv'] ?? '').toString().trim().toLowerCase() == widget.aktivniKlijent!.naziv.trim().toLowerCase()) {
          aktivniKlijentId = kMap['id']?.toString() ?? '';
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          trenutniIdUredjivanja == null ? 'Izračun Troškova Prijevoza' : 'Uređivanje Kalkulacije',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: aktivniKlijentId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '1) Klijent', border: OutlineInputBorder()),
              items: listaKlijenata.map((kMap) {
                return DropdownMenuItem<String>(
                  value: kMap['id']?.toString() ?? '',
                  child: Text(kMap['naziv']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (idKlijenta) {
                if (idKlijenta != null && idKlijenta.isNotEmpty) {
                  var kMap = listaKlijenata.firstWhere((k) => (k['id'] ?? '').toString() == idKlijenta);
                  KlijentModel odabrani = KlijentModel(
                    id: kMap['id']?.toString() ?? '',
                    naziv: kMap['naziv']?.toString() ?? '',
                    adresa: kMap['adresa']?.toString() ?? '',
                    grad: kMap['grad']?.toString() ?? '',
                    oib: kMap['oib']?.toString() ?? '',
                    email: kMap['email']?.toString() ?? '',
                    telefon: kMap['telefon']?.toString() ?? '',
                    banka: kMap['banka']?.toString() ?? '',
                    iban: kMap['iban']?.toString() ?? '',
                    uSustavuPdv: kMap['uSustavuPdvA'] ?? kMap['uSustavuPdv'] ?? false,
                  );
                  widget.onKlijentChanged(odabrani);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nazivKalkulacijeController,
              decoration: const InputDecoration(labelText: '2) Naziv kalkulacije', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: TextField(
                  controller: datumPolaskaController,
                  readOnly: true,
                  onTap: () => _odaberiDatum(context, true),
                  decoration: const InputDecoration(labelText: '3a) Datum Polaska', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: datumPovratkaController,
                  readOnly: true,
                  onTap: () => _odaberiDatum(context, false),
                  decoration: const InputDecoration(labelText: '3b) Datum Povratka', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // 4) Polazište (Autocomplete)
            LokacijeAutocompleteWidget(
              label: '4) Polazište',
              controller: polazisteController,
              onSuggestionsFetch: dohvatiPrijedlogeLokacija,
              onSelected: (selection) {
                setState(() {
                  polazisteController.text = selection['display_name'];
                  polazisteCoords = {'lat': selection['lat'], 'lon': selection['lon']};
                });
              },
              onChanged: (val) => polazisteCoords = null,
            ),
            const SizedBox(height: 8),

            // 5) Međuodredište A (Autocomplete)
            LokacijeAutocompleteWidget(
              label: '5) Međuodredište A (opcionalno)',
              controller: odrediste1Controller,
              onSuggestionsFetch: dohvatiPrijedlogeLokacija,
              onSelected: (selection) {
                setState(() {
                  odrediste1Controller.text = selection['display_name'];
                });
              },
              onChanged: (val) {},
            ),
            const SizedBox(height: 8),

            // 6) Međuodredište B (Autocomplete)
            LokacijeAutocompleteWidget(
              label: '6) Međuodredište B (opcionalno)',
              controller: odrediste2Controller,
              onSuggestionsFetch: dohvatiPrijedlogeLokacija,
              onSelected: (selection) {
                setState(() {
                  odrediste2Controller.text = selection['display_name'];
                });
              },
              onChanged: (val) {},
            ),
            const SizedBox(height: 8),

            // 7) Konačno odredište (Autocomplete)
            LokacijeAutocompleteWidget(
              label: '7) Konačno odredište',
              controller: konacnoOdredisteController,
              onSuggestionsFetch: dohvatiPrijedlogeLokacija,
              onSelected: (selection) {
                setState(() {
                  konacnoOdredisteController.text = selection['display_name'];
                  konacnoOdredisteCoords = {'lat': selection['lat'], 'lon': selection['lon']};
                });
              },
              onChanged: (val) => konacnoOdredisteCoords = null,
            ),
            const SizedBox(height: 8),

            CheckboxListTile(
              title: const Text('Povratno putovanje'),
              value: povratnoPutovanje,
              onChanged: (val) {
                setState(() {
                  povratnoPutovanje = val ?? true;
                  kmController.text = (bazaKmJednosmjerno * (povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
                  preracunajCestarinuSOmogucenimDionicama();
                });
              },
            ),

            if (gradoviNaRuti.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('8) Gradovi na ruti (dinamički):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(gradoviNaRuti.map((g) => skratiNazivLokacije(g)).join(' -> '), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SekcijaAutoputWidget(
              koristiAutocestu: koristiAutocestu,
              onAutocestaChanged: (val) {
                setState(() {
                  koristiAutocestu = val ?? true;
                  if (!koristiAutocestu) {
                    cestarinaController.text = '0.00';
                  } else {
                    preracunajCestarinuSOmogucenimDionicama();
                  }
                });
              },
              dioniceAutocesta: dioniceAutocesta,
              onDionicaToggled: (index, val) {
                setState(() {
                  dioniceAutocesta[index]['ukljuceno'] = val;
                  preracunajCestarinuSOmogucenimDionicama();
                });
              },
              cestarinaController: cestarinaController,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('13) Izračunato trajanje:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '$izracunatiBrojDana dana (${izracunatiBrojDana > 1 ? izracunatiBrojDana - 1 : 0} noćenja)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SekcijaParametriTroskovaWidget(
              dostupnaVozila: dostupnaVozila,
              odabranoVoziloMap: odabranoVoziloMap,
              onVoziloChanged: (idVozila) {
                if (idVozila != null) {
                  setState(() {
                    odabranoVoziloMap = dostupnaVozila.firstWhere((v) => v['id'] == idVozila);
                  });
                }
              },
              cijenaGorivaController: cijenaGorivaController,
              dnevnicaController: dnevnicaController,
              tkoPlacaNocenje: tkoPlacaNocenje,
              opcijeNocenja: opcijeNocenja,
              onNocenjeTkoPlacaChanged: (val) {
                if (val != null) setState(() => tkoPlacaNocenje = val);
              },
              cijenaNocenjaController: cijenaNocenjaController,
              marzaController: marzaController,
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: isLoadingRoute ? null : () => izracunajRutuIKilometre(context),
              icon: isLoadingRoute ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.route),
              label: Text(isLoadingRoute ? 'Izračunavam rutu i cestarinu...' : 'Izračunaj rutu, km i cestarinu'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapaRuteScreen(
                      polaziste: skratiNazivLokacije(polazisteController.text.trim()),
                      odrediste: skratiNazivLokacije(konacnoOdredisteController.text.trim()),
                      koristiAutocestu: koristiAutocestu,
                      polazisteCoords: polazisteCoords,
                      odredisteCoords: konacnoOdredisteCoords,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Prikaži rutu na mapi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                KalkulacijaModel kalk = generirajModelKalkulacije(widget.aktivniKlijent);
                widget.onSpremiKalkulaciju(kalk);
                setState(() => trenutniIdUredjivanja = null);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              child: const Text('Spremi kalkulaciju', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
