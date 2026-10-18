// 1. Interna kalkulacija troškova
  static Future<void> printajInternuKalkulaciju(dynamic kalkulacija, dynamic prijevoznik, {bool klijentUsetPdv = true}) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double km = double.tryParse(kalkulacija.km.toString()) ?? 0;
    double cestarinaUnesena = double.tryParse(kalkulacija.cestarina.toString()) ?? 0;
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

    bool koristiCestarinu = kalkulacija.koristiAutocestu && cestarinaUnesena > 0;
    double cestarinaBrutoUkupno = koristiCestarinu ? cestarinaUnesena : 0;
    double cestarinaNeto = cestarinaBrutoUkupno / 1.25;
    double cestarinaPdv = cestarinaBrutoUkupno - cestarinaNeto;

    double trosakVozaca = dnevnica * brojDana;

    double nocenjeNeto = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;
    double nocenjePdv = (kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) - nocenjeNeto;
    double nocenjeBrutoUkupno = kalkulacija.tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0;

    double ukupnoNeto = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double iznosMarze = ukupnoNeto * (marzaPosto / 100);
    double osnovicaZaPonudu = ukupnoNeto + iznosMarze;
    double izlazniPdv = klijentUsetPdv ? (osnovicaZaPonudu * 0.25) : 0.0;
    double totalZaSve = klijentUsetPdv ? (osnovicaZaPonudu + izlazniPdv) : kalkulacija.ukupnaCijena;
