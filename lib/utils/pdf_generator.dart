// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  // 1. Interna kalkulacija troškova
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = true}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double km = double.tryParse(kalkulacija.km?.toString() ?? '0') ?? 0;
    double cestarinaBruto = double.tryParse(kalkulacija.cestarina?.toString() ?? '0') ?? 0;
    double gorivoBruto = double.tryParse(kalkulacija.cijenaGoriva?.toString() ?? '1.96') ?? 1.96;
    double dnevnica = double.tryParse(kalkulacija.dnevnica?.toString() ?? '100') ?? 100;
    double nocenjeBruto = double.tryParse(kalkulacija.cijenaNocenja?.toString() ?? '60') ?? 60;
    double marzaPosto = double.tryParse(kalkulacija.marza?.toString() ?? '20') ?? 20;

    Map<String, double> potrosnjaVozila = {
      'Kombi 8+1': 9.0,
      'Mini bus <20': 15.0,
      'Midi bus 35': 30.0,
      'Veliki autobus 50': 35.0,
    };
    double potrosnja = potrosnjaVozila[kalkulacija.vozilo] ?? 35.0;

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

    double gorivoUkupnoBruto = (km / 100) * potrosnja * gorivoBruto;
    double gorivoNeto = gorivoUkupnoBruto / 1.25;
    double gorivoPdv = gorivoUkupnoBruto - gorivoNeto;

    bool koristiCestarinu = kalkulacija.koristiAutocestu && cestarinaBruto > 0;
    double cestarinaUkupnoBruto = koristiCestarinu ? cestarinaBruto : 0;
    double cestarinaNeto = cestarinaUkupnoBruto / 1.25;
    double cestarinaPdv = cestarinaUkupnoBruto - cestarinaNeto;

    double trosakVozaca = dnevnica * brojDana;
    double nocenjeUkupnoBruto = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0);
    double nocenjeNeto = nocenjeUkupnoBruto / 1.25;
    double nocenjePdv = nocenjeUkupnoBruto - nocenjeNeto;

    double cistiTrosakNeto = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double iznosMarze = cistiTrosakNeto * (marzaPosto / 100);

    double totalZaSve = double.tryParse(kalkulacija.ukupnaCijena?.toString() ?? '0') ?? kalkulacija.ukupnaCijena;
    double osnovicaZaPonudu = klijentUsetPdv ? (totalZaSve / 1.25) : totalZaSve;
    double izlazniPdv = klijentUsetPdv ? (totalZaSve - osnovicaZaPonudu) : 0.0;

    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INTERNA KALKULACIJA TROŠKOVA', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.red900)),
                  pw.Text('ID: ${kalkulacija.id.substring(kalkulacija.id.length > 6 ? kalkulacija.id.length - 6 : 0)}', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 5),
              pw.Text('Prijevoznik: ${prijevoznik.naziv} (OIB: ${prijevoznik.oib})', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Klijent: ${kalkulacija.klijentNaziv} (PDV sustav: ${klijentUsetPdv ? "DA" : "NE"})', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text('Ruta: ${kalkulacija.ruta} (${kalkulacija.km} km) | Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 10)),
              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0F2C59)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Stavka troška', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Bez PDV-a (Neto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('PDV (25%)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Ukupno (Bruto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                    ],
                  ),
                  _buildRedTablice('Gorivo (${kalkulacija.vozilo})', gorivoNeto, gorivoPdv, gorivoUkupnoBruto, font),
                  _buildRedTablice('Cestarina (${kalkulacija.odabranaAutocesta})', cestarinaNeto, cestarinaPdv, cestarinaUkupnoBruto, font),
                  _buildRedTablice('Dnevnica vozača', trosakVozaca, 0.0, trosakVozaca, font),
                  _buildRedTablice('Noćenje vozača', nocenjeNeto, nocenjePdv, nocenjeUkupnoBruto, font),
                ],
              ),
              pw.SizedBox(height: 15),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Column(
                  children: [
                    _buildRedZbroja('Ukupni troškovi (Neto):', '${cistiTrosakNeto.toStringAsFixed(2)} EUR', font),
                    _buildRedZbroja('Marža (${marzaPosto.toStringAsFixed(0)}%):', '${iznosMarze.toStringAsFixed(2)} EUR', font),
                    pw.Divider(thickness: 0.5),
                    if (klijentUsetPdv) ...[
                      _buildRedZbroja('Osnovica za ponudu:', '${osnovicaZaPonudu.toStringAsFixed(2)} EUR', font),
                      _buildRedZbroja('Izlazni PDV (25%):', '${izlazniPdv.toStringAsFixed(2)} EUR', font),
                    ] else ...[
                      _buildRedZbroja('Ukupan iznos (bez PDV razrade):', '${totalZaSve.toStringAsFixed(2)} EUR', font),
                    ],
                    pw.Divider(thickness: 1, color: PdfColors.red900),
                    _buildRedZbroja('TOTAL ZA SVE:', '${totalZaSve.toStringAsFixed(2)} EUR', font, isBold: true, color: PdfColors.red900, fontSize: 14),
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

  // 2. Ponuda za prijevoz
  static Future<void> printajPonuduPdf(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = true, dynamic klijentObjekt}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    String godina = DateTime.now().year.toString();
    String idSkel = kalkulacija.id.length >= 2 ? kalkulacija.id.substring(kalkulacija.id.length - 2) : '01';
    String brojPonude = '$idSkel/$godina';

    double ukupniIznosPonude = double.tryParse(kalkulacija.ukupnaCijena?.toString() ?? '0') ?? kalkulacija.ukupnaCijena;
    double osnovica = klijentUsetPdv ? (ukupniIznosPonude / 1.25) : ukupniIznosPonude;
    double pdvIznos = klijentUsetPdv ? (ukupniIznosPonude - osnovica) : 0.0;

    bool povratno = kalkulacija.povratno ?? true;
    String tekstRelacije = '${kalkulacija.ruta} ${povratno ? "( i povratak )" : ""}';

    String mjestoIzdavanja = (prijevoznik.grad != null && prijevoznik.grad.toString().isNotEmpty) 
        ? prijevoznik.grad.toString().replaceAll(RegExp(r'^\d+\s*'), '') // Uklanja poštanski broj ako je spojen (npr. "21207 Kostanje" -> "Kostanje")
        : 'Mjesto';

    List<String> ukljucujeStavke = [];
    if (kalkulacija.koristiAutocestu) {
      ukljucujeStavke.add('korištenje autoceste');
    }
    if (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća') {
      ukljucujeStavke.add('noćenje vozača');
    }
    String tekstUkljucuje = ukljucujeStavke.isNotEmpty ? ukljucujeStavke.join(' i ') : 'standardne troškove prijevoza';

    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Zaglavlje: Podaci prijevoznika (lijevo) i Broj ponude (desno)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(prijevoznik.naziv ?? '', style: pw.TextStyle(font: fontBold, fontSize: 13)),
                      if (prijevoznik.vlasnik != null && prijevoznik.vlasnik.isNotEmpty)
                        pw.Text('Vlasnik: ${prijevoznik.vlasnik}', style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.Text('Adresa: ${prijevoznik.adresa}, ${prijevoznik.grad}', style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.Text('OIB: ${prijevoznik.oib}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (prijevoznik.telefon != null && prijevoznik.telefon.isNotEmpty)
                        pw.Text('Tel: ${prijevoznik.telefon}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (prijevoznik.email != null && prijevoznik.email.isNotEmpty)
                        pw.Text('Email: ${prijevoznik.email}', style: pw.TextStyle(font: font, fontSize: 9)),
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

              // Datum izdavanja i svi atributi klijenta (desno poravnato)
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
                      pw.Text(kalkulacija.klijentNaziv, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      if (klijentObjekt != null && klijentObjekt.vlasnik != null && klijentObjekt.vlasnik.isNotEmpty)
                        pw.Text('Vlasnik/kontakt osoba: ${klijentObjekt.vlasnik}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (klijentObjekt != null && klijentObjekt.adresa != null && klijentObjekt.adresa.isNotEmpty)
                        pw.Text('Adresa: ${klijentObjekt.adresa}, ${klijentObjekt.grad}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (klijentObjekt != null && klijentObjekt.oib != null && klijentObjekt.oib.isNotEmpty)
                        pw.Text('OIB: ${klijentObjekt.oib}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (klijentObjekt != null && klijentObjekt.telefon != null && klijentObjekt.telefon.isNotEmpty)
                        pw.Text('Telefon: ${klijentObjekt.telefon}', style: pw.TextStyle(font: font, fontSize: 9)),
                      if (klijentObjekt != null && klijentObjekt.email != null && klijentObjekt.email.isNotEmpty)
                        pw.Text('Email: ${klijentObjekt.email}', style: pw.TextStyle(font: font, fontSize: 9)),
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

              // Predmet i linija
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

              // Financijski dio (DINAMIČKI PREMA SUSTAVU PDV-a KLIJENTA)
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

              // Upute za plaćanje i valjanost
              pw.Text('Plaćanje izvršiti na IBAN: ${prijevoznik.iban}, otvoren u banci: ${prijevoznik.banka}', style: pw.TextStyle(font: fontBold, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text('Ponuda vrijedi 7 dana', style: pw.TextStyle(font: font, fontSize: 9)),

              // Zakonska napomena i zahvala na dnu
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

  static pw.TableRow _buildRedTablice(String naziv, double neto, double pdv, double bruto, dynamic font) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(naziv, style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${neto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${pdv.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${bruto.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
      ],
    );
  }

  static pw.Widget _buildRedZbroja(String labela, String iznos, dynamic font, {bool isBold = false, PdfColor? color, double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(labela, style: pw.TextStyle(font: isBold ? pw.Font.helveticaBold() : font, fontSize: fontSize, color: color ?? PdfColors.black)),
          pw.Text(iznos, style: pw.TextStyle(font: isBold ? pw.Font.helveticaBold() : font, fontSize: fontSize, color: color ?? PdfColors.black)),
        ],
      ),
    );
  }
}
