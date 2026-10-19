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
              pw.Text('Klijent: $klijentNazivPrikaz(PDV sustav: ${klijentUsetPdv ? "DA" : "NE"})', style: pw.TextStyle(font: font, fontSize: 10)),
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
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Stavka troška', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Bez PDV-a (Neto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('PDV (25%)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Ukupno (Bruto)', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10))),
                    ],
                  ),
                  // Red: Gorivo
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Gorivo ($nazivVozila)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakGoriva.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${(trosakGoriva * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${(trosakGoriva * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Cestarina
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Cestarina (HAC / Autoceste)', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakCestarine.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${(trosakCestarine * 0.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${(trosakCestarine * 1.25).toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Dnevnica
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Dnevnica vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('0.00 EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakDnevnice.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                    ],
                  ),
                  // Red: Noćenje
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('Noćenje vozača', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakNocenja.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('0.00 EUR', style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.Padding(padding: const EdgeInsets.all(6), child: pw.Text('${trosakNocenja.toStringAsFixed(2)} EUR', style: pw.TextStyle(font: font, fontSize: 9))),
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

  // Ovdje ostaje vaša postojeća metoda printajPonuduPdf...
  static Future<void> printajPonuduPdf(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = false, dynamic klijentObjekt}) async {
    // ... (zadržati postojeći kod za ponudu)
  }
}
