// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  /// Univerzalna metoda za vađenje vrijednosti bez obzira radi li se o Map-i ili Dart modelu
  static String _getVal(dynamic obj, String field) {
    if (obj == null) return '';
    try {
      if (obj is Map) {
        if (field == 'naziv') {
          return (obj['naziv'] ?? obj['nazivTvrtke'] ?? obj['naziv_tvrtke'] ?? obj['nazivObrta'] ?? '').toString();
        }
        if (field == 'vlasnik') {
          return (obj['vlasnik'] ?? obj['odgovornaOsoba'] ?? obj['odgovorna_osoba'] ?? obj['vlasnikObrta'] ?? '').toString();
        }
        if (field == 'adresa') return (obj['adresa'] ?? obj['adresaTvrtke'] ?? '').toString();
        if (field == 'grad') return (obj['grad'] ?? obj['mjesto'] ?? obj['gradTvrtke'] ?? '').toString();
        if (field == 'oib') return (obj['oib'] ?? obj['oibTvrtke'] ?? '').toString();
        if (field == 'email') return (obj['email'] ?? obj['emailTvrtke'] ?? '').toString();
        if (field == 'telefon') return (obj['telefon'] ?? obj['mobitel'] ?? obj['telefonTvrtke'] ?? '').toString();
        if (field == 'banka') return (obj['banka'] ?? '').toString();
        if (field == 'iban') return (obj['iban'] ?? obj['ibanZiro'] ?? '').toString();
        return (obj[field] ?? '').toString();
      }

      // Kada se prosljeđuju instancirani Dart modeli (PrijevoznikModel, KlijentModel, itd.)
      switch (field) {
        case 'naziv':
          try { return (obj.naziv ?? '').toString(); } catch (_) {
            try { return (obj.nazivTvrtke ?? '').toString(); } catch (_) { return ''; }
          }
        case 'vlasnik':
          try { return (obj.vlasnik ?? '').toString(); } catch (_) {
            try { return (obj.odgovornaOsoba ?? '').toString(); } catch (_) { return ''; }
          }
        case 'adresa':
          try { return (obj.adresa ?? '').toString(); } catch (_) { return ''; }
        case 'grad':
          try { return (obj.grad ?? '').toString(); } catch (_) { return ''; }
        case 'oib':
          try { return (obj.oib ?? '').toString(); } catch (_) { return ''; }
        case 'email':
          try { return (obj.email ?? '').toString(); } catch (_) { return ''; }
        case 'telefon':
          try { return (obj.telefon ?? obj.mobitel ?? '').toString(); } catch (_) { return ''; }
        case 'banka':
          try { return (obj.banka ?? '').toString(); } catch (_) { return ''; }
        case 'iban':
          try { return (obj.iban ?? '').toString(); } catch (_) { return ''; }
        case 'uSustavuPdv':
          try { return (obj.uSustavuPdv ?? false).toString(); } catch (_) { return 'false'; }
        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  // Dinamička metoda za internu kalkulaciju troškova
  static Future<void> printajInternuKalkulaciju(
    dynamic kalkulacija, 
    dynamic prijevoznik, {
    bool klijentUsetPdv = false, 
    dynamic klijentObjekt
  }) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Ažuriranje PDV statusa klijenta iz objekta ako postoji
    if (klijentObjekt != null) {
      if (klijentObjekt is Map) {
        klijentUsetPdv = klijentObjekt['uSustavuPdv'] ?? klijentObjekt['uSustavuPdvA'] ?? klijentObjekt['u_sustavu_pdva'] ?? klijentUsetPdv;
      } else {
        try {
          klijentUsetPdv = klijentObjekt.uSustavuPdv ?? klijentUsetPdv;
        } catch (_) {}
      }
    }

    // Podaci prijevoznika iz Clouda
    String pNaziv = _getVal(prijevoznik, 'naziv');
    String pOib = _getVal(prijevoznik, 'oib');

    // Podaci klijenta iz Clouda
    String kNaziv = _getVal(klijentObjekt, 'naziv');
    if (kNaziv.isEmpty) kNaziv = kalkulacija.klijentNaziv;

    String idSkel = kalkulacija.id.length >= 5 
        ? kalkulacija.id.substring(kalkulacija.id.length - 5) 
        : (kalkulacija.id.isNotEmpty ? kalkulacija.id : '07743');

    double km = double.tryParse(kalkulacija.km?.toString() ?? '0') ?? 0.0;
    double cestarinaBruto = double.tryParse(kalkulacija.cestarina?.toString() ?? '0') ?? 0.0;
    double cijenaGoriva = double.tryParse(kalkulacija.cijenaGoriva?.toString() ?? '1.96') ?? 1.96;
    double dnevnicaPoDanu = double.tryParse(kalkulacija.dnevnica?.toString() ?? '100') ?? 100.0;
    double cijenaNocenjaVal = double.tryParse(kalkulacija.cijenaNocenja?.toString() ?? '50') ?? 50.0;
    double marzaPostotak = double.tryParse(kalkulacija.marza?.toString() ?? '20') ?? 20.0;

    double potrosnjaVozila = 35.0; 
    double trosakGorivaNeto = ((km / 100) * potrosnjaVozila * cijenaGoriva) / 1.25;
    double trosakCestarineNeto = (kalkulacija.koristiAutocestu == true ? cestarinaBruto : 0.0) / 1.25;
    
    int brojDana = 1;
    try {
      String d1Str = kalkulacija.datumPolaska.replaceAll('.', '').trim();
      String d2Str = kalkulacija.datumPovratka.replaceAll('.', '').trim();
      if (d1Str.length >= 8 && d2Str.length >= 8) {
        DateTime d1 = DateTime(int.parse(d1Str.substring(4, 8)), int.parse(d1Str.substring(2, 4)), int.parse(d1Str.substring(0, 2)));
        DateTime d2 = DateTime(int.parse(d2Str.substring(4, 8)), int.parse(d2Str.substring(2, 4)), int.parse(d2Str.substring(0, 2)));
        int razlika = d2.difference(d1).inDays + 1;
        brojDana = razlika > 0 ? razlika : 1;
      }
    } catch (_) {}

    int brojNocenja = brojDana > 1 ? brojDana - 1 : 0;
    double trosakDnevnice = dnevnicaPoDanu * brojDana;
    
    // Ispravan izračun neto i PDV-a za noćenje
    double nocenjeBrutoTotal = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (cijenaNocenjaVal * brojNocenja) : 0.0);
    double trosakNocenjaNeto = nocenjeBrutoTotal > 0 ? (nocenjeBrutoTotal / 1.25) : 0.0;
    double trosakNocenjaPdv = nocenjeBrutoTotal - trosakNocenjaNeto;

    double ukupniTroskoviNeto = trosakGorivaNeto + trosakCestarineNeto + trosakDnevnice + trosakNocenjaNeto;
    double iznosMarze = ukupniTroskoviNeto * (marzaPostotak / 100);
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

              pw.Text('Prijevoznik: "${pNaziv.isNotEmpty ? pNaziv : 'Moj Obrt'}"${pOib.isNotEmpty ? " (OIB: $pOib)" : ""}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Klijent: $kNaziv (PDV sustav: ${klijentUsetPdv ? "DA" : "NE"})', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Ruta: ${kalkulacija.ruta} | Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.SizedBox(height: 14),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Stavka troška', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Bez PDV-a (Neto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('PDV (25%)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Ukupno (Bruto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Gorivo ($nazivVozila)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakGorivaNeto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakGorivaNeto * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakGorivaNeto * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Cestarina (HAC / Autoceste)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakCestarineNeto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakCestarineNeto * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(trosakCestarineNeto * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Dnevnica vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('0.00 EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Noćenje vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakNocenjaNeto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${trosakNocenjaPdv.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${nocenjeBrutoTotal.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

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
                        pw.Text('Marža (${marzaPostotak.toStringAsFixed(0)}%):', style: pw.TextStyle(font: font, fontSize: 10)),
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

  static Future<void> printajPonuduPdf(
    dynamic kalkulacija, 
    dynamic prijevoznik, {
    bool klijentUsetPdv = false, 
    dynamic klijentObjekt
  }) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    String godina = DateTime.now().year.toString();
    String idSkel = kalkulacija.id.length >= 2 
        ? kalkulacija.id.substring(kalkulacija.id.length - 2) 
        : '43';
    String brojPonude = '$idSkel/$godina';

    double ukupniIznosPonude = double.tryParse(kalkulacija.ukupnaCijena?.toString() ?? '0') ?? kalkulacija.ukupnaCijena;
    
    if (klijentObjekt != null) {
      if (klijentObjekt is Map) {
        klijentUsetPdv = klijentObjekt['uSustavuPdv'] ?? klijentObjekt['uSustavuPdvA'] ?? klijentObjekt['u_sustavu_pdva'] ?? klijentUsetPdv;
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
        : 'Podgrađe';

    List<String> ukljucujeStavke = [];
    if (kalkulacija.koristiAutocestu) {
      ukljucujeStavke.add('korištenje autoceste');
    }
    if (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća') {
      ukljucujeStavke.add('noćenje vozača');
    }
    String tekstUkljucuje = ukljucujeStavke.isNotEmpty ? ukljucujeStavke.join(' i ') : 'standardne troškove prijevoza';

    // Podaci prijevoznika s Clouda
    String pNaziv = _getVal(prijevoznik, 'naziv');
    String pVlasnik = _getVal(prijevoznik, 'vlasnik');
    String pAdresa = _getVal(prijevoznik, 'adresa');
    String pGrad = _getVal(prijevoznik, 'grad');
    String pOib = _getVal(prijevoznik, 'oib');
    String pEmail = _getVal(prijevoznik, 'email');
    String pTelefon = _getVal(prijevoznik, 'telefon');
    String pBanka = _getVal(prijevoznik, 'banka');
    String pIban = _getVal(prijevoznik, 'iban');

    // Podaci klijenta s Clouda
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
              // ZAGLAVLJE PRIJEVOZNIKA I BROJ PONUDE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(pNaziv.isNotEmpty ? '"$pNaziv"' : '"Čagalj prijevoz"', style: pw.TextStyle(font: fontBold, fontSize: 13)),
                      if (pVlasnik.isNotEmpty)
                        pw.Text('Vlasnik: $pVlasnik', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pAdresa.isNotEmpty || pGrad.isNotEmpty)
                        pw.Text('Adresa: $pAdresa${pGrad.isNotEmpty ? ", $pGrad" : ""}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pOib.isNotEmpty)
                        pw.Text('OIB: $pOib', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pTelefon.isNotEmpty)
                        pw.Text('Tel: $pTelefon', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (pEmail.isNotEmpty)
                        pw.Text('Email: $pEmail', style: pw.TextStyle(font: font, fontSize: 9)),
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

              // MJESTO, DATUM I PODACI KLIJENTA
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
                        pw.Text('Vlasnik/kontakt osoba: $kVlasnik', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (kAdresa.isNotEmpty || kGrad.isNotEmpty)
                        pw.Text('Adresa: $kAdresa${kGrad.isNotEmpty ? ", $kGrad" : ""}', style: pw.TextStyle(font: font, fontSize: 9)),
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
              pw.SizedBox(height: 20),

              // NASLOV DOKUMENTA
              pw.Center(
                child: pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(font: fontBold, fontSize: 15)),
              ),
              pw.SizedBox(height: 15),

              // PREDMET I STRUKTURA IZRAČUNA
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

              // REKAPITULACIJA CIJENE S PDV-OM
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

              // NAPOMENA O PLAĆANJU I IBAN
              if (pIban.isNotEmpty)
                pw.Text('Plaćanje izvršiti na IBAN: $pIban${pBanka.isNotEmpty ? ", otvoren u banci: $pBanka" : ""}', style: pw.TextStyle(font: fontBold, fontSize: 9))
              else
                pw.Text('Plaćanje izvršiti na IBAN prijevoznika.', style: pw.TextStyle(font: fontBold, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text('Ponuda vrijedi 7 dana', style: pw.TextStyle(font: font, fontSize: 9)),
              
              pw.Spacer(),

              // PODNOŽJE DOKUMENTA
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
