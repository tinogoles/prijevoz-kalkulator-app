// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static String _getVal(dynamic obj, String field) {
    if (obj == null) return '';
    try {
      if (obj is Map) {
        return (obj[field] ?? '').toString();
      }
      switch (field) {
        case 'naziv': return (obj.naziv ?? '').toString();
        case 'vlasnik': return (obj.vlasnik ?? '').toString();
        case 'adresa': return (obj.adresa ?? '').toString();
        case 'grad': return (obj.grad ?? '').toString();
        case 'oib': return (obj.oib ?? '').toString();
        case 'email': return (obj.email ?? '').toString();
        case 'telefon': return (obj.telefon ?? '').toString();
        case 'banka': return (obj.banka ?? '').toString();
        case 'iban': return (obj.iban ?? '').toString();
        case 'uSustavuPdv': return (obj.uSustavuPdv ?? false).toString();
        default: return '';
      }
    } catch (_) {
      return '';
    }
  }

  // Dinamička metoda za internu kalkulaciju troškova
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = false, dynamic klijentObjekt}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Provjera PDV statusa klijenta iz objekta ako postoji
    if (klijentObjekt != null) {
      if (klijentObjekt is Map) {
        klijentUsetPdv = klijentObjekt['uSustavuPdv'] ?? klijentObjekt['u_sustavu_pdva'] ?? klijentUsetPdv;
      } else {
        try {
          klijentUsetPdv = klijentObjekt.uSustavuPdv ?? klijentUsetPdv;
        } catch (_) {}
      }
    }

    // Podaci prijevoznika
    String pNaziv = _getVal(prijevoznik, 'naziv');
    String pOib = _getVal(prijevoznik, 'oib');

    // Podaci klijenta
    String kNaziv = _getVal(klijentObjekt, 'naziv');
    if (kNaziv.isEmpty) kNaziv = kalkulacija.klijentNaziv;

    // ID kalkulacije (skraćeni prikaz za gornji desni kut)
    String idSkel = kalkulacija.id.length >= 5 ? kalkulacija.id.substring(kalkulacija.id.length - 5) : (kalkulacija.id.isNotEmpty ? kalkulacija.id : '396798');

    // Dinamičke vrijednosti iz kalkulacije modela
    double trosakGoriva = double.tryParse(kalkulacija.trosakGoriva?.toString() ?? '0') ?? kalkulacija.trosakGoriva ?? 0.0;
    double trosakCestarine = double.tryParse(kalkulacija.trosakCestarine?.toString() ?? '0') ?? kalkulacija.trosakCestarine ?? 0.0;
    double trosakDnevnice = double.tryParse(kalkulacija.trosakDnevnice?.toString() ?? '0') ?? kalkulacija.trosakDnevnice ?? 0.0;
    double trosakNocenja = double.tryParse(kalkulacija.trosakNocenja?.toString() ?? '0') ?? kalkulacija.trosakNocenja ?? 0.0;
    
    double ukupniTroskoviNeto = trosakGoriva + trosakCestarine + trosakDnevnice + trosakNocenja;
    double iznosMarze = double.tryParse(kalkulacija.iznosMarze?.toString() ?? '0') ?? kalkulacija.iznosMarze ?? (ukupniTroskoviNeto * 0.20);
    double ukupniIznosBezPdv = ukupniTroskoviNeto + iznosMarze;
    double pdvIznos = klijentUsetPdv ? (ukupniIznosBezPdv * 0.25) : 0.0;
    double totalZaSve = ukupniIznosBezPdv + pdvIznos;

    String nazivVozila = kalkulacija.vozilo ?? 'Vozilo';

    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ZAGLAVLJE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INTERNA KALKULACIJA TROŠKOVA', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.red900)),
                  pw.Text('ID: $idSkel', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 8),

              // PODACI O PRIJEVOZNIKU I KLIJENTU
              pw.Text('Prijevoznik: "$pNaziv"${pOib.isNotEmpty ? " (OIB: $pOib)" : ""}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Klijent: $kNaziv (PDV sustav: ${klijentUsetPdv ? "DA" : "NE"})', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Ruta: ${kalkulacija.ruta} | Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.SizedBox(height: 14),

              // TABLICA STAVKI TROŠKOVA
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Zaglavlje tablice
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Stavka troška', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Bez PDV-a (Neto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('PDV (25%)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Ukupno (Bruto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                    ],
                  ),
                  // Red: Gorivo
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Gorivo ($nazivVozila)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakGoriva.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakGoriva * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakGoriva * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Cestarina
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Cestarina (HAC / Autoceste)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakCestarine.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakCestarine * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakCestarine * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Dnevnica
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Dnevnica vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('0.00 EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Noćenje
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Noćenje vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakNocenja.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('0.00 EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakNocenja.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

              // FINANCIJSKI SAŽETAK KUTIJA
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ukupni troškovi (Neto):', style: pw.TextStyle(font: font, fontSize: 10)),
                        pw.Text('${ukupniTroskoviNeto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Marža:', style: pw.TextStyle(font: font, fontSize: 10)),
                        pw.Text('${iznosMarze.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ],
                    ),
                    pw.Divider(thickness: 1, color: PdfColors.grey700),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ukupni iznos (bez PDV-a):', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.Text('${ukupniIznosBezPdv.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('PDV:', style: pw.TextStyle(font: font, fontSize: 10)),
                        pw.Text('${pdvIznos.toStringAsFixed(2)} EUR (${klijentUsetPdv ? "U sustavu PDV-a" : "Nije u sustavu PDV-a"})', style: pw.TextStyle(font: font, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // TOTAL ZA SVE TRAKA
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL ZA SVE:', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.red900)),
                    pw.Text('${totalZaSve.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.red900)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }

  static Future<void> printajPonuduPdf(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = false, dynamic klijentObjekt}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    String godina = DateTime.now().year.toString();
    String idSkel = kalkulacija.id.length >= 2 ? kalkulacija.id.substring(kalkulacija.id.length - 2) : '01';
    String brojPonude = '$idSkel/$godina';

    double ukupniIznosPonude = double.tryParse(kalkulacija.ukupnaCijena?.toString() ?? '0') ?? kalkulacija.ukupnaCijena;
    
    if (klijentObjekt != null) {
      if (klijentObjekt is Map) {
        klijentUsetPdv = klijentObjekt['uSustavuPdv'] ?? klijentObjekt['u_sustavu_pdva'] ?? klijentUsetPdv;
      } else {
        try {
          klijentUsetPdv = klijentObjekt.uSustavuPdv ?? klijentUsetPdv;
        } catch (_) {}
      }
    }

    double osnovica = klijentUsetPdv ? (ukupniIznosPonude / 1.25) : ukupniIznosPonude;
    double pdvIznos = klijentUsetPdv ? (ukupniIznosPonude - osnovica) : 0.0;

    bool povratno = kalkulacija.povratno ?? true;
    String tekstRelacije = '${kalkulacija.ruta} ${povratno ? "( i povratak )" : ""}';

    String rawGrad = _getVal(prijevoznik, 'grad');
    String mjestoIzdavanja = rawGrad.isNotEmpty 
        ? rawGrad.replaceAll(RegExp(r'^\d+\s*'), '') 
        : 'Mjesto';

    List<String> ukljucujeStavke = [];
    if (kalkulacija.koristiAutocestu) {
      ukljucujeStavke.add('korištenje autoceste');
    }
    if (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća') {
      ukljucujeStavke.add('noćenje vozača');
    }
    String tekstUkljucuje = ukljucujeStavke.isNotEmpty ? ukljucujeStavke.join(' i ') : 'standardne troškove prijevoza';

    String pNaziv = _getVal(prijevoznik, 'naziv');
    String pVlasnik = _getVal(prijevoznik, 'vlasnik');
    String pAdresa = _getVal(prijevoznik, 'adresa');
    String pGrad = _getVal(prijevoznik, 'grad');
    String pOib = _getVal(prijevoznik, 'oib');
    String pEmail = _getVal(prijevoznik, 'email');
    String pTelefon = _getVal(prijevoznik, 'telefon');
    String pBanka = _getVal(prijevoznik, 'banka');
    String pIban = _getVal(prijevoznik, 'iban');

    String kNaziv = _getVal(klijentObjekt, 'naziv');
    if (kNaziv.isEmpty) kNaziv = kalkulacija.klijentNaziv;
    String kVlasnik = _getVal(klijentObjekt, 'vlasnik');
    String kAdresa = _getVal(klijentObjekt, 'adresa');
    String kGrad = _getVal(klijentObjekt, 'grad');
    String kOib = _getVal(klijentObjekt, 'oib');
    String kTelefon = _getVal(klijentObjekt, 'telefon');
    String kEmail = _getVal(klijentObjekt, 'email');

    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(pNaziv, style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      if (pVlasnik.isNotEmpty)
                        pw.Text('Vlasnik / Odgovorna osoba: $pVlasnik', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pAdresa.isNotEmpty)
                        pw.Text('Adresa: $pAdresa', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pGrad.isNotEmpty)
                        pw.Text('Grad / Mjesto: $pGrad', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pOib.isNotEmpty)
                        pw.Text('OIB: $pOib', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pEmail.isNotEmpty)
                        pw.Text('E-mail tvrtke: $pEmail', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pTelefon.isNotEmpty)
                        pw.Text('Telefon / Mobitel: $pTelefon', style: pw.TextStyle(font: font, fontSize: 9)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Text('Ponuda br: $brojPonude', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('$mjestoIzdavanja, ${kalkulacija.datumPolaska}', style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.SizedBox(height: 6),
                      pw.Text('Za klijenta:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      pw.Text(kNaziv, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      if (kVlasnik.isNotEmpty)
                        pw.Text('Odgovorna osoba / Kontakt: $kVlasnik', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (kAdresa.isNotEmpty || kGrad.isNotEmpty)
                        pw.Text('Adresa: $kAdresa, $kGrad', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (kOib.isNotEmpty)
                        pw.Text('OIB: $kOib', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (kTelefon.isNotEmpty)
                        pw.Text('Telefon: $kTelefon', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (kEmail.isNotEmpty)
                        pw.Text('Email: $kEmail', style: pw.TextStyle(font: font, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(font: fontBold, fontSize: 15)),
              ),
              pw.SizedBox(height: 15),
              pw.Text('Predmet: ${kalkulacija.nazivKalkulacije}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 8),
              pw.Text('Datum polaska: ${kalkulacija.datumPolaska}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Datum povratka: ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Relacija: $tekstRelacije', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Vozilo: ${kalkulacija.vozilo}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Atributi vozila: Dodatna oprema (klima, wi-fi, utičnice)', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Ponuda uključuje: $tekstUkljucuje', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (klijentUsetPdv) ...[
                      pw.Text('Osnovica (Bez PDV-a): ${osnovica.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.SizedBox(height: 3),
                      pw.Text('PDV (25%): ${pdvIznos.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Container(width: 230, child: pw.Divider(thickness: 1, color: PdfColors.black)),
                      pw.SizedBox(height: 4),
                      pw.Text('UKUPNA CIJENA S PDV-om: ${ukupniIznosPonude.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    ] else ...[
                      pw.Text('UKUPNA CIJENA: ${ukupniIznosPonude.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              if (pIban.isNotEmpty)
                pw.Text('Plaćanje izvršiti na IBAN: $pIban${pBanka.isNotEmpty ? ", otvoren u banci: $pBanka" : ""}', style: pw.TextStyle(font: fontBold, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text('Ponuda vrijedi 7 dana', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Spacer(),
              pw.Divider(thickness: 0.8, color: PdfColors.grey700),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Ovaj dokument je neobvezujuća ponuda i ne smatra se računom. Na temelju ove ponude nije moguće koristiti pravo na odbitak pretporeza.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: font, fontSize: 7.5, color: PdfColors.grey800),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'Zahvaljujemo Vam što koristite naše usluge',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.grey900),
                ),
              ),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }
}
