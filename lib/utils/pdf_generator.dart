// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  // 1. Predložak za Internu Kalkulaciju
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik) async {
    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INTERNA KALKULACIJA PRIJEVOZA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 10),
              pw.Text('Prijevoznik: ${prijevoznik.naziv}, ${prijevoznik.adresa}, ${prijevoznik.grad}'),
              pw.Text('OIB: ${prijevoznik.oib} | IBAN: ${prijevoznik.iban}'),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Text('Naziv kalkulacije: ${kalkulacija.nazivKalkulacije}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Klijent: ${kalkulacija.klijentNaziv}'),
              pw.Text('Relacija: ${kalkulacija.ruta} (${kalkulacija.km} km)'),
              pw.Text('Termin: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}'),
              pw.Text('Vozilo: ${kalkulacija.vozilo}'),
              pw.SizedBox(height: 10),
              pw.Text('Cestarina: ${kalkulacija.cestarina} € (${kalkulacija.odabranaAutocesta})'),
              pw.Text('Noćenje vozača: ${kalkulacija.tkoPlacaNocenje} (${kalkulacija.cijenaNocenja} €)'),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Text('UKUPNA CIJENA: ${kalkulacija.ukupnaCijena.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }

  // 2. Predložak za Ponudu PDF
  static Future<void> printajPonuduPdf(dynamic kalkulacija, dynamic prijevoznik) async {
    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 10),
              pw.Text('Izdavatelj: ${prijevoznik.naziv}'),
              pw.Text('Adresa: ${prijevoznik.adresa}, ${prijevoznik.grad}'),
              pw.Text('OIB: ${prijevoznik.oib} | Banka: ${prijevoznik.banka} | IBAN: ${prijevoznik.iban}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Za klijenta: ${kalkulacija.klijentNaziv}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Predmet ponude: ${kalkulacija.nazivKalkulacije}'),
              pw.Text('Relacija: ${kalkulacija.ruta}'),
              pw.Text('Datum izvođenja: ${kalkulacija.datumPolaska} - ${kalkulacija.datumPovratka}'),
              pw.SizedBox(height: 20),
              pw.Text('UKUPNI IZNOS PONUDE: ${kalkulacija.ukupnaCijena.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              pw.SizedBox(height: 40),
              pw.Text('Zahvaljujemo na ukazanom povjerenju!'),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }
}
