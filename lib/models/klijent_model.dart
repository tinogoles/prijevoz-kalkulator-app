class KlijentModel {
  String? id;
  String userId;
  String naziv;
  String vlasnik;
  String adresa;
  String grad;
  String oib;
  String telefon;
  String email;
  String iban;
  String banka;
  bool uSustavuPdv;

  KlijentModel({
    this.id,
    this.userId = '',
    this.naziv = '',
    this.vlasnik = '',
    this.adresa = '',
    this.grad = '',
    this.oib = '',
    this.telefon = '',
    this.email = '',
    this.iban = '',
    this.banka = '',
    this.uSustavuPdv = true,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': userId,
        'naziv': naziv,
        'vlasnik': vlasnik,
        'adresa': adresa,
        'grad': grad,
        'oib': oib,
        'telefon': telefon,
        'email': email,
        'iban': iban,
        'banka': banka,
        'uSustavuPdv': uSustavuPdv,
      };

  factory KlijentModel.fromJson(Map<String, dynamic> json, {String? docId}) => KlijentModel(
        id: docId ?? json['id'],
        userId: json['userId'] ?? '',
        naziv: json['naziv'] ?? '',
        vlasnik: json['vlasnik'] ?? '',
        adresa: json['adresa'] ?? '',
        grad: json['grad'] ?? '',
        oib: json['oib'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
        iban: json['iban'] ?? '',
        banka: json['banka'] ?? '',
        uSustavuPdv: json['uSustavuPdv'] ?? true,
      );
}
