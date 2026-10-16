//zindan ve eşya(crafting) sistemi

extension AltinFormatUzantisi on int {
  //sayiyi formatlı altın metnine çevir
  String get toAltinKese => "${this} Altın";
}

extension AgirlikFormatUzantisi on double {
  //ağırlık Kg olarak göster
  String get toAgirlikKg => "${this.toStringAsFixed(1)} kg";
}

//eşyaların nadirlik dereceeleri
enum EsyaNadirligi { yaygin, nadir, destansi, efsanevi }

//genel zindan hata sınıfları

class ZindanException implements Exception {
  final String hataKodu;
  final String mesaj;
  final DateTime zaman = DateTime.now();

  ZindanException(this.hataKodu, this.mesaj);

  @override
  String toString() => "[$hataKodu] $mesaj ($zaman)";
}

//çanta ağırlık aşıldığında hata kodu
class CantadaYerYokException extends ZindanException {
  CantadaYerYokException(double asim)
    : super(
        "ERR_BAG_FULL",
        "Çanta kapasitesi $asim kg açıldı.eşyayı alamazsınız.",
      );
}

//yetersiz altın durumunda hata
class YetersizAltinException extends ZindanException {
  YetersizAltinException(int eksik)
    : super("ERR_NO_GOLD", "Bu işlem için $eksik altın, daha gerekiyor.");
}

//mixler

mixin ParcalanabilirYetisi {
  void tozaDonustur(String esyaAdi) {
    print("demirci $esyaAdi parçalandı ve 5 adet 'mavi büyü tozu elde edildi");
  }
}

mixin RuneBasmaYetisi {
  void runKusa(String runeTuru) {
    print("rum büyüsü: esyaya '$runeTuru' rümü mühürlendi.(+15 büyü hasarı)");
  }
}

//eşya/item modeli

class Esya with ParcalanabilirYetisi, RuneBasmaYetisi {
  final String id;
  final String ad;
  final double agirlik;
  final EsyaNadirligi nadirlik;
  final String? aciklama;
  bool efsunlumu;

  Esya({
    required this.id,
    required this.ad,
    required this.agirlik,
    required this.nadirlik,
    this.aciklama,
    this.efsunlumu = false,
  });
  Esya.kucukCanIksiri()
    : id = "POT-001",
      ad = "Küçük Şifa İksiri",
      agirlik = 0.5,
      nadirlik = EsyaNadirligi.yaygin,
      aciklama = "içiliğinde anında 30 can yeniler",
      efsunlumu = false;

  ({String etiket, double carpan, int satisFiyati}) degerlemeYap() {
    final (etiket, carpan, bazFiyat) = switch (nadirlik) {
      EsyaNadirligi.yaygin => ("Yaygın", 1.0, 50),
      EsyaNadirligi.nadir => ("Nadir", 1.5, 200),
      EsyaNadirligi.destansi => ("Destansı", 2.5, 750),
      EsyaNadirligi.efsanevi when efsunlumu => ("Kadim Efsanevi", 5.0, 3000),
      EsyaNadirligi.efsanevi => ("Efsanevi", 4.0, 2000),
    };
    return (
      etiket: etiket,
      carpan: carpan,
      satisFiyati: (bazFiyat * carpan).toInt(),
    );
  }

  //oyuncunun çantası
}

class OyuncuCantasi {
  final String sahipAdi;
  final double maxAgirlikKapasitesi;
  final List<Esya> _esyalar = [];
  int _altin = 500;

  OyuncuCantasi({required this.sahipAdi, this.maxAgirlikKapasitesi = 25.0});

  int get altin => _altin;

  //altın harcama metodu
  void altinHarca(int miktar) {
    if (miktar > _altin) {
      throw YetersizAltinException(miktar - _altin);
    }
    _altin = miktar;
    print(
      "[Ticaret]: $miktar altın harcandı.Kalan cüzdan: ${_altin.toAltinKese}",
    );
  }

  //çanta ağırlığı hesaplama
  double get mevcutAgirlik => _esyalar.fold(0.0, (acc, e) => acc + e.agirlik);

  //çantaya eşya ekleme
  void esyaEkle(Esya yeniEsya) {
    if (mevcutAgirlik + yeniEsya.agirlik > maxAgirlikKapasitesi) {
      final double asim =
          (mevcutAgirlik + yeniEsya.agirlik) - maxAgirlikKapasitesi;
      throw CantadaYerYokException(asim);
    }
    _esyalar.add(yeniEsya);
    print(
      "[Çanta]: '${yeniEsya.ad}' çantaya yerleştirildi. (${yeniEsya.agirlik.toAgirlikKg})",
    );
  }

  List<Esya> get degerliEsyalar => _esyalar
      .where(
        (e) =>
            e.nadirlik == EsyaNadirligi.destansi ||
            e.nadirlik == EsyaNadirligi.efsanevi,
      )
      .toList();

  //çanta döküm raporu

  void envanterRaporuBas() {
    print(""" 

  =============================================
  KAHRAMAN ENVANTER RAPORU
  Sahip: $sahipAdi : Altın : ${_altin.toAltinKese} | Yük: ${mevcutAgirlik.toAgirlikKg}/${maxAgirlikKapasitesi.toAgirlikKg};
  =============================================
  """);
    for (var esya in _esyalar) {
      final deger = esya.degerlemeYap();
      final aciklamaMetni = esya.aciklama ?? "Özel nitelik belirtilmemiş";
      print(
        "${deger.etiket.padRight(20)} | ${esya.ad.padRight(24)} | ${esya.agirlik.toAgirlikKg.padLeft(8)} | Değer: ${deger.satisFiyati.toAltinKese.padLeft(12)}",
      );
      print("Not: $aciklamaMetni ");
    }
    print("Değerli eşya sayısı:  ${degerliEsyalar.length} Adet");
    print("===================================================");
  }
}

void main() {
  print("Zindan & Envanter Motoru Başlatılıyor.........");

  final bool vipUyelik = true;

  //çantamızı oluşturuyoruz

  final canta = OyuncuCantasi(
    sahipAdi: "Elf Okçusu Ayberk",
    maxAgirlikKapasitesi: 20.0,
  );
  final List<Esya> zindanGirisPaketi = [
    Esya.kucukCanIksiri(),
    Esya(
      id: "SWD-101",
      ad: "GÜMÜŞ Ejder Kılıcı",
      agirlik: 4.5,
      nadirlik: EsyaNadirligi.destansi,
      aciklama: "Karanlık yaratıkla karşı %25 ek hasar",
      efsunlumu: true,
    ),
    if (vipUyelik)
      Esya(
        id: "RNG-99",
        ad: "Zamanın Sonu Yüzüğü",
        agirlik: 0.2,
        nadirlik: EsyaNadirligi.efsanevi,
        aciklama: "bekleme sürelerini %20 azalitr",
        efsunlumu: true,
      ),
  ];

  //eşyaları çantaya ekleme
  for (var esya in zindanGirisPaketi) {
    canta.esyaEkle(esya);
  }

  //zindan
  print("Zanaar ve büyü masası:");
  final kilic = zindanGirisPaketi[1];
  kilic.runKusa("Kutsal Işık");
  kilic.tozaDonustur(kilic.ad);

  print("Ticaret ve Altın Harcama");
  try {
    canta.altinHarca(200);
    canta.altinHarca(800);
  } on YetersizAltinException catch (e) {
    print("Hata Yakalandı: ${e.mesaj}");
  } catch (e) {
    print("Genel Hata $e");
  }

  //kapasite aşım testi
  print("Çanta Kapasitesi Aşımı");
  try {
    final devKaya = Esya(
      id: "BLD-777",
      ad: "Göktaşı Parçası",
      agirlik: 28.0,
      nadirlik: EsyaNadirligi.yaygin,
    );
    canta.esyaEkle(devKaya);
  } on CantadaYerYokException catch (e) {
    print("Aşırı yük engellendi -> ${e.mesaj}");
  }

  canta.envanterRaporuBas();
}
