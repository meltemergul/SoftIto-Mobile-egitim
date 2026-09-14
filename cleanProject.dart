abstract class Urun {
  final String id;
  final String ad;
  final double fiyat;
  int stok;

  Urun({
    required this.id,
    required this.ad,
    required this.fiyat,
    required this.stok,
  });

  double kargoUcreti();
}

class FizikselUrun extends Urun {
  FizikselUrun({
    required super.id,
    required super.ad,
    required super.fiyat,
    required super.stok,
  });

  @override
  double kargoUcreti() => 29.90;
}

class DijitalUrun extends Urun {
  DijitalUrun({
    required super.id,
    required super.ad,
    required super.fiyat,
    required super.stok,
  });

  @override
  double kargoUcreti() => 0;
}

abstract class OdemeYontemi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements OdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL kredi kartından POS ile çekildi.");
  }
}

class HavaleOdeme implements OdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL havale kontrol edildi.");
  }
}

class KapidaOdeme implements OdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL kapıda ödeme tahsil edilecek.");
  }
}

class CryptoOdeme implements OdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL USDT transferi onaylandı.");
  }
}

abstract class Indirim {
  double uygula(double tutar);
}

class YuzdeOnIndirim implements Indirim {
  @override
  double uygula(double tutar) {
    return tutar * 0.90;
  }
}

class YuzdeYirmiIndirim implements Indirim {
  @override
  double uygula(double tutar) {
    return tutar * 0.80;
  }
}

class ElliLiraIndirim implements Indirim {
  @override
  double uygula(double tutar) {
    return tutar - 50;
  }
}

class IndirimYok implements Indirim {
  @override
  double uygula(double tutar) {
    return tutar;
  }
}

abstract class Veritabani {
  void siparisKaydet(String orderId, double tutar);
}

class SqliteVeritabani implements Veritabani {
  @override
  void siparisKaydet(String orderId, double tutar) {
    print("DB kaydedildi: $orderId - $tutar TL");
  }
}

abstract class MailServisi {
  void mailGonder(String email, String mesaj);
}

class SmtpMailServisi implements MailServisi {
  @override
  void mailGonder(String email, String mesaj) {
    print("SMTP mail gönderildi: $email");
  }
}

abstract class SmsServisi {
  void smsGonder(String telefon, String mesaj);
}

class NetgsmSmsServisi implements SmsServisi {
  @override
  void smsGonder(String telefon, String mesaj) {
    print("SMS gönderildi: $telefon");
  }
}

abstract class KargoServisi {
  void kargoGonder(String orderId, String adres);
}

class MngKargoServisi implements KargoServisi {
  @override
  void kargoGonder(String orderId, String adres) {
    print("MNG Kargo gönderildi: $orderId - $adres");
  }
}

abstract class FaturaServisi {
  void faturaOlustur(String orderId);
}

class PdfFaturaServisi implements FaturaServisi {
  @override
  void faturaOlustur(String orderId) {
    print("PDF fatura oluşturuldu: $orderId");
  }
}

class SiparisServisi {
  final Veritabani veritabani;
  final MailServisi mailServisi;
  final SmsServisi smsServisi;
  final KargoServisi kargoServisi;
  final FaturaServisi faturaServisi;

  SiparisServisi({
    required this.veritabani,
    required this.mailServisi,
    required this.smsServisi,
    required this.kargoServisi,
    required this.faturaServisi,
  });

  void siparisiTamamla({
    required String orderId,
    required List<Urun> sepet,
    required OdemeYontemi odemeYontemi,
    required Indirim indirim,
    required String musteriAdi,
    required String email,
    required String telefon,
    required String adres,
  }) {
    _stokKontrolEt(sepet);

    final araToplam = _araToplamHesapla(sepet);
    final indirimliTutar = indirim.uygula(araToplam);
    final sonTutar = _kdvEkle(indirimliTutar);

    odemeYontemi.odemeYap(sonTutar);

    veritabani.siparisKaydet(
      orderId,
      sonTutar,
    );

    faturaServisi.faturaOlustur(orderId);

    mailServisi.mailGonder(
      email,
      "Sayın $musteriAdi, siparişiniz alındı. "
      "Tutar: $sonTutar TL",
    );

    smsServisi.smsGonder(
      telefon,
      "Siparişiniz onaylandı: $orderId",
    );

    kargoServisi.kargoGonder(
      orderId,
      adres,
    );

    _stokDus(sepet);
  }

  void _stokKontrolEt(List<Urun> sepet) {
    for (final urun in sepet) {
      if (urun.stok <= 0) {
        throw Exception("${urun.ad} stokta yok.");
      }
    }
  }

  double _araToplamHesapla(List<Urun> sepet) {
    double toplam = 0;

    for (final urun in sepet) {
      toplam += urun.fiyat;
      toplam += urun.kargoUcreti();
    }

    return toplam;
  }

  double _kdvEkle(double tutar) {
    return tutar * 1.20;
  }

  void _stokDus(List<Urun> sepet) {
    for (final urun in sepet) {
      urun.stok--;
    }
  }
}

void main() {
  final siparisServisi = SiparisServisi(
    veritabani: SqliteVeritabani(),
    mailServisi: SmtpMailServisi(),
    smsServisi: NetgsmSmsServisi(),
    kargoServisi: MngKargoServisi(),
    faturaServisi: PdfFaturaServisi(),
  );

  final mouse = FizikselUrun(
    id: "1",
    ad: "Kablosuz Mouse",
    fiyat: 450.0,
    stok: 5,
  );

  final flutterKursu = DijitalUrun(
    id: "2",
    ad: "Flutter Kursu E-Kitap",
    fiyat: 150.0,
    stok: 100,
  );

  final sepet = <Urun>[
    mouse,
    flutterKursu,
  ];

  siparisServisi.siparisiTamamla(
    orderId: "SP-9921",
    sepet: sepet,
    odemeYontemi: KrediKartiOdeme(),
    indirim: YuzdeOnIndirim(),
    musteriAdi: "Selahaddin",
    email: "selahaddin@kodvance.com",
    telefon: "05551112233",
    adres: "Kadıköy / İstanbul",
  );
}

