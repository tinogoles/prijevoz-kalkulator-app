// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  // 1. Interna kalkulacija troškova (sa tablicom i svim izračunima)
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double km = double.tryParse(kalkulacija.km.toString()) ?? 0;
    double cestarinaBruto = double.tryParse(kalkulacija.cestarina.toString()) ?? 0;
    double gorivoBruto = double.tryParse(kalkulacija.cijenaGoriva.toString()) ?? 1.45;
    double dnevnica = double.tryParse(kalkulacija.dnevnica.toString()) ?? 80;
    double nocenjeBruto = double.tryParse(kalkulacija.cijenaNocenja.toString()) ?? 60;
    double marzaPosto = double.tryParse(kalkulacija.marza.toString()) ?? 20;

    Map<String, double> potrosnjaVozila = {
      'Kombi 8+1': 9.0,
      'Mini bus <20': 15.0,
      'Midi bus 35': 30.0,
      'Veliki autobus 50': 35.0
    };
    double potrosnja = potrosnjaVozila[kalkulacija.vozilo] ?? 9.0;
    
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

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double gorivoPdv = ((km / 100) * potrosnja * gorivoBruto) - gorivoNeto;
    double gorivoBrutoUkupno = (km / 100) * potrosnja * gorivoBruto;

    double cestarinaNeto = (kalkulacija.koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double cestarinaPdv = (kalkulacija.koristiAutocestu ? cestarinaBruto : 0) - cestarinaNeto;
    double cestarinaBrutoUkupno = kalkulacija.koristiAutocestu ? cestarinaBruto : 0;

    double trosakVozaca = dnevnica * brojDana;

    double nocenjeNeto = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;
    double nocenjePdv = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) - nocenjeNeto;
    double nocenjeBrutoUkupno = kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0;

    double ukupnoNeto = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double ukupnoPdv = gorivoPdv + cestarinaPdv + nocenjePdv;
    double ukupnoBruto = gorivoBrutoUkupno + cestarinaBrutoUkupno + trosakVozaca + nocenjeBrutoUkupno;

    double iznosMarze = ukupnoNeto * (marzaPosto / 100);
    double osnovicaZaPonudu = ukupnoNeto + iznosMarze;
    double izlazniPdv = osnovicaZaPonudu * 0.25;
    double totalZaSve = osnovicaZaPonudu + izlazniPdv;

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
              pw.Text('Klijent: ${kalkulacija.klijentNaziv} (PDV sustav: DA)', style: pw.TextStyle(font: font, fontSize: 10)),
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
                  _buildRedTablice('Gorivo (${kalkulacija.vozilo})', gorivoNeto, gorivoPdv, gorivoBrutoUkupno, font),
                  _buildRedTablice('Cestarina', cestarinaNeto, cestarinaPdv, cestarinaBrutoUkupno, font),
                  _buildRedTablice('Dnevnica vozača', trosakVozaca, 0.0, trosakVozaca, font),
                  _buildRedTablice('Noćenje vozača', nocenjeNeto, nocenjePdv, nocenjeBrutoUkupno, font),
                ],
              ),
              pw.SizedBox(height: 15),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Column(
                  children: [
                    _buildRedZbroja('Ukupni troškovi (Neto):', '${ukupnoNeto.toStringAsFixed(2)} €', font),
                    _buildRedZbroja('Marža (${marzaInfo(kalkulacija)}%):', '${iznosMarze.toStringAsFixed(2)} €', font),
                    pw.Divider(thickness: 0.5),
                    _buildRedZbroja('Osnovica za ponudu:', '${osnovicaZaPonudu.toStringAsFixed(2)} €', font),
                    _buildRedZbroja('Izlazni PDV (25%):', '${izlazniPdv.toStringAsFixed(2)} €', font),
                    pw.Divider(thickness: 1, color: PdfColors.red900),
                    _buildRedZbroja('TOTAL ZA SVE:', '${totalZaSve.toStringAsFixed(2)} €', font, isBold: true, color: PdfColors.red900, fontSize: 14),
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

  // 2. Ponuda za prijevoz (s podacima za plaćanje: IBAN i banka)
  static Future<void> printajPonuduPdf(dynamic kalkulacija, dynamic prijevoznik) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double osnovica = kalkulacija.ukupnaCijena / 1.25;
    double pdvIznos = kalkulacija.ukupnaCijena - osnovica;

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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(prijevoznik.naziv, style: pw.TextStyle(font: fontBold, fontSize: 16)),
                      pw.Text('Adresa: ${prijevoznik.adresa}, ${prijevoznik.grad}', style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('OIB: ${prijevoznik.oib} | Tel: ${prijevoznik.telefon}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Za klijenta:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      pw.Text(kalkulacija.klijentNaziv, style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('Datum: ${kalkulacija.datumPolaska}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey800),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.blue800)),
              ),
              pw.SizedBox(height: 15),
              pw.Text('Predmet: ${kalkulacija.nazivKalkulacije}', style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 10),

              // Kartica specifikacije
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SPECIFIKACIJA USLUGE', style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.blue800)),
                    pw.SizedBox(height: 5),
                    pw.Text('Ruta: ${kalkulacija.ruta}', style: pw.TextStyle(font: font, fontSize: 10)),
                    pw.Text('Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}', style: pw.TextStyle(font: font, fontSize: 10)),
                    pw.Text('Kategorija vozila: ${kalkulacija.vozilo}', style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // Cijene i PDV blok
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEA580C),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  children: [
                    _buildRedPonude('Osnovica (Bez PDV-a):', '${osnovica.toStringAsFixed(2)} €', font, fontBold),
                    pw.SizedBox(height: 6),
                    _buildRedPonude('PDV (25%):', '${pdvIznos.toStringAsFixed(2)} €', font, fontBold),
                    pw.Divider(color: PdfColors.white, thickness: 1),
                    _buildRedPonude('UKUPNA CIJENA S PDV-om:', '${kalkulacija.ukupnaCijena.toStringAsFixed(2)} €', font, fontBold, isTotal: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Podaci za plaćanje (IBAN i Banka)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Plaćanje izvršiti na IBAN: ${prijevoznik.iban}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text('otvoren u banci: ${prijevoznik.banka}', style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Zahvaljujemo na ukazanom povjerenju!', style: pw.TextStyle(font: font, fontSize: 11)),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }

  static String marzaInfo(dynamic k) => k.marza.toString();

  static pw.TableRow _buildRedTablice(String naziv, double neto, double pdv, double bruto, dynamic font) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(naziv, style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${neto.toStringAsFixed(2)} €', style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${pdv.toStringAsFixed(2)} €', style: pw.TextStyle(font: font, fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${bruto.toStringAsFixed(2)} €', style: pw.TextStyle(font: font, fontSize: 9))),
      ],
    );
  }

  static pw.Widget _buildRedZbroja(String labela, String iznos, dynamic font, {bool isBold = false, PdfColor? color, double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(labela, style: pw.TextStyle(font: isBold ? fontBoldReference() : font, fontSize: fontSize, color: color ?? PdfColors.black)),
          pw.Text(iznos, style: pw.TextStyle(font: isBold ? fontBoldReference() : font, fontSize: fontSize, color: color ?? PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Font fontBoldReference() {
    return pw.Font.helveticaBold();
  }

  static pw.Widget _buildRedPonude(String labela, String iznos, dynamic font, dynamic fontBold, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(labela, style: pw.TextStyle(font: isTotal ? fontBold : font, fontSize: isTotal ? 12 : 11, color: PdfColors.white)),
        pw.Text(iznos, style: pw.TextStyle(font: fontBold, fontSize: isTotal ? 13 : 11, color: PdfColors.white)),
      ],
    );
  }
}
