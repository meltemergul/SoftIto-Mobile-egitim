enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

//Danışan (müşteri) modeli

class Danisan {
  final String id;
  final String adSoyad;
  final String telefon;
  final bool vipUyeMi;
  final List<String> alerjiler; //boş olabilir ama null olamaz
  final String? ozelCiltNotu; //opsiyonel null olabilir

  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false,
    this.alerjiler = const [],
    this.ozelCiltNotu,
  });

  bool get hassasCiltMi => alerjiler.isNotEmpty;
  //bilgi özet kartı

  String get bilgiOzeti {
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(',')}";
    final String notBilgisi = ozelCiltNotu ?? "Özel Medikal not girilmemiş";
    final String vipRozeti = vipUyeMi ? "VIP" : "standart";
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
  }
}
//seans randevu modeli

class SeansKaydi {
  final String seansKodu;
  final Danisan danisan;
  final HizmetKategorisi kategori;
  final String islemAdi;
  final double birimFiyat;
  final int seansSayisi;
  final double indirimOrani;
  final String? sorumluUzman;
  SeansDurumu durum;
  OdemeYontemi? odemeTipi;

  SeansKaydi({
    required this.seansKodu,
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1,
    this.indirimOrani = 0.0,
    this.sorumluUzman,
    this.durum = SeansDurumu.bekliyor,
    this.odemeTipi,
  });

  double get brutTutar => birimFiyat * seansSayisi;
  double get indirimTutari {
    double toplamOran = indirimOrani;
    if (danisan.vipUyeMi) {
      toplamOran += 10;
    }
    return brutTutar * (toplamOran / 100.0);
  }

  double get netTutar => brutTutar - indirimTutari;
}

//yönetim servisi

class KlinikYoneticisi {
  final String subeAdi;
  final List<SeansKaydi> _seanslar = [];
  final Map<String, Danisan> _danisanRehberi = {};

  KlinikYoneticisi({required this.subeAdi});

  //danisan kaydetme

  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] = danisan;
    print(
      "rehbere eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VIP" : "Standart"})",
    );
  }

  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans);
    print(
      "randevu kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}-> ${seans.islemAdi}",
    );
  }

  void seansTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi;
        seans.odemeTipi = odeme;
        print(
          "seans tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
        );
        return;
      }
    }
    print("Hata [$seansKodu] kodlu seans bulunamadı");
  }

  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi;
        print(
          "seans iptal edildi [${seans.seansKodu}]: ${iptalNedeni ?? "gerekçe belirtilmedi"}",
        );
        return;
      }
    }
  }

  //Finansal Rapor Metotlrı(fonksiyonel dart)
  double get toplamTahsilEdilenCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  double get beklenenPotansiyelCiro => _seanslar
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  //kategori bazlı seans sayıları

  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {};
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0;
    }
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
    }
    return dagilim;
  }

  Set<String> gorevliUzmanKadrosu() {
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet();
  }

  //uzmansız kalan seanslar

  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
  }

  void gunSonuRaporuYazdir() {
    print("Günlük Seans ve İşlem Çizelgesi");
    print("-------------------------------");

    print(
      "${'Kod'.padRight(10)} | "
      "${'Danışan'.padRight(10)} | "
      "${'İşlem'.padRight(10)} | "
      "${'Uzman'.padRight(10)} | "
      "${'Tutar'.padRight(10)} | "
      "${'Durum'}",
    );

    print("-------------------------------");

    for (var s in _seanslar) {
      final String uzman = s.sorumluUzman ?? "Nöbetçi Bekliyor";

      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "tamamlandi",
        SeansDurumu.odadaIslemde => "Islemde",
        SeansDurumu.bekliyor => "bekliyor",
        SeansDurumu.iptalEdildi => "iptal",
      };

      print(
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        "$durumRozet",
      );
    }
    print("-------------------------------------------------------------");
    print("Finansal Özet:");
    print(
      "* Gerçekleşen(kasadaki net ciro): ${toplamTahsilEdilenCiro.toStringAsFixed((2))}",
    );
    print(
      "* Bekleyen potansiyel alacak: ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );
    print(" * Toplam Seans : ${_seanslar.length} Randevu");
    print("-------------------------------------------------------------");
    print("Aktif Uzmanlar");
    final uzmanlar = gorevliUzmanKadrosu();
    if (uzmanlar.isEmpty) {
      print("kayıtlı uzman bulunamadı");
    }
    print("${uzmanlar.join(',')}");

    final uzmansizlar = uzmansizSeanslariGetir();

    if (uzmansizlar.isNotEmpty) {
      print(
        "dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır.",
      );
      for (var u in uzmansizlar) {
        print("-->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
      print("----------------------------------------------------------");
    }
  }
}

void main() {
  print("klinik yönetim sistemi başlıyor.");
  final yonetici = KlinikYoneticisi(subeAdi: "softIto bağcılar şubesi");
  //danışan oluşturalım
  final d1 = Danisan(
    id: "dan-01",
    adSoyad: "ahmet yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: ["retinol,aspirin"],
    ozelCiltNotu: "cilt bariyeri hassas",
  );

  final d2 = Danisan(
    id: "dan-02",
    adSoyad: "ahmet yılan",
    telefon: "0555 555 55 55",
    vipUyeMi: false,
    alerjiler: [],
  );

  final d3 = Danisan(
    id: "dan-03",
    adSoyad: "mehmet yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: ["Retinol,Aspirin"],
  );

  final d4 = Danisan(
    id: "dan-04",
    adSoyad: "ahmet mehmet yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: [],
    ozelCiltNotu: "cilt bariyeri hassas",
  );

  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("danışan güvenlik kontrolü");
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("----------------------------------------");

  //randevular oluşturuluyor

  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1,
    kategori: HizmetKategorisi.Lipo,
    islemAdi: "lipo mipo",
    birimFiyat: 6500.0,
    seansSayisi: 2,
    indirimOrani: 5.0,
    sorumluUzman: "sümeyye arab",
  );
  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "siverex ile yüz temizleme",
    birimFiyat: 2500.0,
    seansSayisi: 5,
    indirimOrani: 15.0,
    sorumluUzman: null,
  );
  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "tüm vucüt",
    birimFiyat: 2500.0,
    seansSayisi: 15,
    indirimOrani: 0.0,
    sorumluUzman: "tuba aydın",
  );

  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "burun estetiği",
    birimFiyat: 1500.0,
    seansSayisi: 3,
    sorumluUzman: "alaadin odabaşı",
  );

  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);
  print("seanslar gonderiliyor");

  //seans 1 başarıyla tamamlanıyor(kredi kartı ile ödeme)
  yonetici.seansTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );

  //seans 2 başarıyla tamamlanıyor(kredi kartı ile ödeme)
  yonetici.seansTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);

  //seans 4 başarıyla tamamlanıyor(kredi kartı ile ödeme)
  yonetici.seansiIptalEt(
    "SNS-2026-4",
    iptalNedeni: "danışan şehir dışından taşındğı için gelemedş",
  );

  yonetici.gunSonuRaporuYazdir();
}
