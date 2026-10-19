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

  // Metoda za internu kalkulaciju koja je nedostajala
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = false}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    String pNaziv = _getVal(prijevoznik, 'naziv');
    double ukupniIznos = double.tryParse(kalkulacija.ukupnaCijena?.toString() ?? '0') ?? kalkulacija.ukupnaCijena;

    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(pNaziv.isNotEmpty ? pNaziv : 'Prijevoznik', style: pw.TextStyle(font: fontBold, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('INTERNA KALKULACIJA', style: pw.TextStyle(font: fontBold, fontSize: 14)),
              ),
              pw.SizedBox(height: 15),
              pw.Text('Naziv: ${kalkulacija.nazivKalkulacije}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.Text('Ruta: ${kalkulacija.ruta}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Relacija / Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Vozilo: ${kalkulacija.vozilo}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Divider(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('UKUPNA KALKULACIJA: ${ukupniIznos.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: fontBold, fontSize: 12)),
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

    // Dinamički podaci prijevoznika zadanog redoslijeda
    String pNaziv = _getVal(prijevoznik, 'naziv');
    String pVlasnik = _getVal(prijevoznik, 'vlasnik');
    String pAdresa = _getVal(prijevoznik, 'adresa');
    String pGrad = _getVal(prijevoznik, 'grad');
    String pOib = _getVal(prijevoznik, 'oib');
    String pEmail = _getVal(prijevoznik, 'email');
    String pTelefon = _getVal(prijevoznik, 'telefon');
    String pBanka = _getVal(prijevoznik, 'banka');
    String pIban = _getVal(prijevoznik, 'iban');

    // Podaci klijenta
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
              // ZAGLAVLJE: Prijevoznik (lijevo) i Broj ponude (desno)
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

              // Datum izdavanja i Klijent (desno)
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

              // Naslov PONUDA ZA PRIJEVOZ
              pw.Center(
                child: pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(font: fontBold, fontSize: 15)),
              ),
              pw.SizedBox(height: 15),

              // Predmet
              pw.Text('Predmet: ${kalkulacija.nazivKalkulacije}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 8),

              // Detalji vožnje
              pw.Text('Datum polaska: ${kalkulacija.datumPolaska}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Datum povratka: ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Relacija: $tekstRelacije', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Vozilo: ${kalkulacija.vozilo}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Atributi vozila: Dodatna oprema (klima, wi-fi, utičnice)', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Ponuda uključuje: $tekstUkljucuje', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              // Financijski dio
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

              // Banka i IBAN na dnu ponude
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
