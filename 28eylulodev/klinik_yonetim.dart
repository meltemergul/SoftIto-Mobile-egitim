//1.Enumlar (Derleme Zamanı Güvenliği - Hatalı metin girişlerini önler)
enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

// 1. DANIŞAN (MÜŞTERİ) MODELİ
class Danisan {
  final String id; // Her danışana özel benzersiz kimlik numarası (Örn: "D1")
  final String adSoyad; // Danışanın adı ve soyadı
  final String telefon; // İletişim numarası
  final bool
  vipUyeMi; // Danışanın VIP statüsünde olup olmadığı (%10 ekstra indirim sağlar)
  final List<String>
  alerjiler; // Danışanın alerjileri (Liste boş olabilir ama null/yok olamaz)
  final String?
  ozelCiltNotu; // İsteğe bağlı medikal veya cilt detay notu (Null olabilir)

  // Kurucu Metot (Constructor) - Yeni bir danışan nesnesi oluştururken kullanılır
  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false, // Varsayılan olarak herkes standart üyedir
    this.alerjiler = const [], // Varsayılan olarak alerji listesi boştur
    this.ozelCiltNotu,
  });

  // Getter (Sezgisel özellik) - Alerji listesi doluysa danışanın hassas ciltli olduğunu belirtir
  bool get hassasCiltMi => alerjiler.isNotEmpty;

  // Bilgi özet kartı oluşturan Getter - Danışan bilgilerini tek bir metin (String) halinde birleştirir
  String get bilgiOzeti {
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(', ')}"; // Alerjileri aralarına virgül koyarak birleştirir
    final String notBilgisi =
        ozelCiltNotu ??
        "Özel medikal not girilmemiş"; // Null ise bu metni yazar
    final String vipRozeti = vipUyeMi
        ? "VİP"
        : "Standart"; // VIP durumuna göre etiket belirler
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
  }
}

// Seans (randevu) Modeli

// 2. SEANS (RANDEVU) MODELİ
class SeansKaydi {
  final String seansKodu; // Her seansa özel benzersiz kod (Örn: "S101")
  final Danisan
  danisan; // Seansın ait olduğu danışan nesnesi (Danisan sınıfından)
  final HizmetKategorisi kategori; // İşlemin hangi kategoride olduğu (Enum)
  final String islemAdi; // Yapılacak spesifik işlemin adı (Örn: "Hydrafacial")
  final double birimFiyat; // Tek bir seansın ücreti
  final int
  seansSayisi; // Satın alınan veya uygulanacak seans adedi (Varsayılan: 1)
  final double
  indirimOrani; // Bu seansa özel yapılan indirim yüzdesi (Örn: 10.0)
  final String?
  sorumluUzman; // İşlemi yapacak olan estetisyen/doktor adı (Boş kalabilir)
  SeansDurumu
  durum; // Seansın anlık durumu (Değiştirilebilir, varsayılan: bekliyor)
  OdemeYontemi?
  odemeTipi; // Seans tamamlandığında seçilen ödeme yöntemi (Başta null'dur)

  // Kurucu Metot (Constructor) - Yeni bir seans/randevu kaydı oluşturur
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

  // Getter - Toplam brüt tutarı hesaplar (Birim Fiyat x Seans Sayısı)
  double get brutTutar => birimFiyat * seansSayisi;

  // Getter - Yapılacak toplam indirim miktarını hesaplar
  double get indirimTutari {
    double toplamOran = indirimOrani;
    if (danisan.vipUyeMi) {
      toplamOran +=
          10.0; // Eğer danışan VIP ise fiyata ek olarak %10 indirim daha eklenir
    }
    return brutTutar * (toplamOran / 100.0); // İndirim tutarı formülü
  }

  // Getter - İndirimler düşüldükten sonra danışanın ödemesi gereken net tutar
  double get netTutar => brutTutar - indirimTutari;
}

// Yönetim Servisi

// 3. YÖNETİM SERVİSİ (Klinik Operasyonlarını Yöneten Ana Sınıf)
class KlinikYoneticisi {
  final String subeAdi; // Yönetilen şubenin adı (Örn: "Kadıköy Şubesi")
  final List<SeansKaydi> _seanslar =
      []; // Şubedeki tüm seansların tutulduğu gizli (private) liste
  final Map<String, Danisan> _danisanRehberi =
      {}; // Danışan ID'sine göre hızlı arama yapan gizli rehber haritası

  KlinikYoneticisi({required this.subeAdi});

  // Yeni bir danışanı sisteme (rehbere) kaydeder
  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] =
        danisan; // ID'yi anahtar (key) yaparak rehbere ekler
    print(
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VİP" : "Standart"})",
    );
  }

  // Yeni bir randevu/seans oluşturup listeye ekler
  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans); // Seansı listeye ekler
    print(
      "Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}->${seans.islemAdi}",
    );
  }

  // Belirli bir seansı başarıyla sonlandırır ve ödemesini alır
  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum =
            SeansDurumu.tamamlandi; // Durumu "tamamlandı" olarak günceller
        seans.odemeTipi = odeme; // Ödeme tipini kaydeder
        print(
          "Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
        );
        return; // İşlem başarılı olduğu için metottan çıkar ve döngüyü sonlandırır
      }
    }
    // Eğer döngü biter ve kod yukarıdaki return'e uğramazsa seans bulunamamış demektir
    print("Hata [$seansKodu] kodlu seans bulunamadı");
  }

  // Belirli bir seansı gerekçe belirterek iptal eder
  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi; // Durumu "iptal edildi" yapar
        print(
          "Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",
        );
        return; // İşlemi bitirip döngüden ve metottan çıkar
      }
    }
  }

  // FİNANSAL RAPOR METOTLARI (Fonksiyonel Dart / Koleksiyon İşlemleri)

  // Sadece "tamamlanan" seansların net tutarlarını toplayarak kasaya giren gerçek ciroyu bulur
  double get toplamTahsilEdilenCiro => _seanslar
      .where(
        (s) => s.durum == SeansDurumu.tamamlandi,
      ) // Sadece tamamlananları filtreler
      .fold(
        0.0,
        (toplam, s) => toplam + s.netTutar,
      ); // Tüm net tutarları üst üste toplar

  // "Bekleyen" veya "İşlemde" olan seansların net tutarlarını toplayarak kazanılması beklenen potansiyel ciroyu bulur
  double get beklenenPotansiyelCiro => _seanslar
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      ) // Aktif ve bekleyen seansları filtreler
      .fold(0.0, (toplam, s) => toplam + s.netTutar); // Tutarları toplar

  // Hangi kategoriden kaç adet seans randevusu alındığını hesaplar (İstatistiksel Dağılım)
  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {};
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0; // Başlangıçta tüm kategorilerin seans sayısını 0 yapar
    }
    for (var s in _seanslar) {
      dagilim[s.kategori] =
          (dagilim[s.kategori] ?? 0) +
          1; // Her seans için ilgili kategoriyi 1 artırır
    }
    return dagilim;
  }

  // Listede adı geçen tüm benzersiz (tekil) uzmanların isimlerini Set (küme) olarak döndürür
  Set<String> gorevliUzmanKadrosu() {
    return _seanslar
        .map((s) => s.sorumluUzman) // Seanslardaki uzman isimlerini alır
        .whereType<
          String
        >() // Null (boş) olmayan, sadece String olanları filtreler
        .toSet(); // Aynı isimlerin tekrarlanmaması için Set'e (kümeye) çevirir
  }

  // Henüz bir uzman (estetisyen) atanmamış olan sahipsiz seansları listeler
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar
        .where((s) => s.sorumluUzman == null)
        .toList(); // Uzmanı null olanları listeye çevirir
  }

  // Konsola tüm günün detaylı özetini ve mali raporunu şık bir tablo halinde yazdırır
  void gunSonuRaporuYazdir() {
    print("Günlük Seans ve İşlem Çizelgesi");
    print("---------------------------------------");
    // Tablo başlıklarını sağa doğru boşluk bırakarak hizalar (padRight) ve yazdırır
    print(
      "${'Kod'.padRight((10))} | "
      "${'Danışan'.padRight(16)} | "
      "${'İşlem'.padRight(20)} | "
      "${'Uzman'.padRight(18)} | "
      "${'Tutar'.padRight(10)} | "
      "${'Durum'} | ",
    );
    print("---------------------------------------");

    // Tüm seansları tek tek dolaşarak tablo satırlarını doldurur
    for (var s in _seanslar) {
      final String uzman =
          s.sorumluUzman ??
          " Nöbetçi Bekliyor"; // Uzman yoksa geçici metin yazar

      // Enum durumunu kullanıcı dostu Türkçe bir metne dönüştürür (Pattern Matching / Switch)
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };

      // Seans bilgilerini sütunlar halinde ekrana yazdırır
      print(
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | " // Kuruş hassasiyeti için virgülden sonra 2 basamak
        "$durumRozet",
      );
    }

    print("---------------------------------------");
    print("Finansal Özet:");
    print(
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}", //sayıyı yuvarlar,karmaşık görünmesini engeler.
    );
    print(
      " * Bekleyen Potansiyen Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );
    print(" * Toplam Seans : ${_seanslar.length} Randevu");
    print("---------------------------------------");

    print("Aktif Uzmanlar");
    final uzmanlar = gorevliUzmanKadrosu(); // Aktif uzman listesini çağırır
    if (uzmanlar.isEmpty) {
      print("Kayıtlı Uzman Bulunamadı");
    } else {
      print(
        " ${uzmanlar.join(', ')}",
      ); // Uzmanları aralarına virgül koyarak yan yana yazdırır
    }

    // Uzmanı olmayan kritik seanslar varsa uyarır ve listeler
    final uzmansizlar = uzmansizSeanslariGetir();
    if (uzmansizlar.isNotEmpty) {
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",
      );
      for (var u in uzmansizlar) {
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
    }
    print("---------------------------------------");
  }
} // KlinikYoneticisi sınıfının sonu

void main() {
  // Konsola sistemin başladığına dair bilgilendirme mesajı yazdırır
  print("Klinik yönetim sistemi başlatılıyor....");

  // 'KlinikYoneticisi' sınıfından "Softito Bağcılar Şubesi" adında ana yönetim nesnesini oluşturur
  final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi");

  // --- DANIŞANLARI OLUŞTURMA ADIMI ---
  // VIP olan, alerjisi bulunan ve özel cilt notu olan bir danışan tanımlar
  final d1 = Danisan(
    id: "DAN-101",
    adSoyad: "Ahmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true, // VIP indirimi alacak (%10 ek indirim)
    alerjiler: ["Retinol,Aspirin"],
    ozelCiltNotu: "Cilt bariyeri hassas",
  );

  // Standart üye olan ve alerjisi bulunmayan bir danışan tanımlar
  final d2 = Danisan(
    id: "DAN-102",
    adSoyad: "Ahmet Yılan",
    telefon: "0555 555 55 55",
    vipUyeMi: false, // Standart indirim kuralları geçerli
    alerjiler: [],
  );

  // VIP olan ve alerjisi bulunan ancak özel notu olmayan bir danışan tanımlar
  final d3 = Danisan(
    id: "DAN-103",
    adSoyad: "Mehmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true, // VIP indirimi alacak (%10 ek indirim)
    alerjiler: ["Retinol,Aspirin"],
  );

  // VIP olan, alerjisi olmayan ama özel notu olan bir danışan tanımlar
  final d4 = Danisan(
    id: "DAN-104",
    adSoyad: "Ahmet Mehmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true, // VIP indirimi alacak (%10 ek indirim)
    alerjiler: [],
    ozelCiltNotu: "Cilt bariyeri hassas",
  );

  // Oluşturulan 4 danışanı da klinik yöneticisinin rehberine (Map yapısına) kaydeder
  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("Danışan güvenlik kontrolü");
  // Danisan sınıfındaki 'bilgiOzeti' getter'ını çağırarak d1 ve d2'nin kart formatındaki bilgilerini ekrana basar
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("----------------------------------");

  // --- RANDEVU / SEANS OLUŞTURMA ADIMI ---
  // d1 danışanı için Lipo kategorisinde, Sümeyye Arab uzmanına 2 seanslık randevu kaydı oluşturur
  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1,
    kategori: HizmetKategorisi.Lipo,
    islemAdi: "Lipo gerisini bilmiyorum",
    birimFiyat: 6500.0,
    seansSayisi:
        2, // Brüt: 13000 TL, d1 VIP olduğu için ek %10 indirimle Net hesaplanacak
    indirimOrani: 5.0,
    sorumluUzman: "Sümeyye Arab",
  );

  // d2 danışanı için uzmanı henüz belli olmayan (null) 5 seanslık cilt yenileme randevusu oluşturur
  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "Siverex ile tyüz temizleme",
    birimFiyat: 2500.0,
    seansSayisi: 5,
    indirimOrani: 15.0,
    sorumluUzman:
        null, // Gün sonu raporunda "Uzman atanmadı" uyarısı tetikleyecek
  );

  // d3 danışanı için Tuba Aydın uzmanına 15 seanslık lazer epilasyon randevusu oluşturur
  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "Tüm Vücut",
    birimFiyat: 25000.0,
    seansSayisi: 15,
    indirimOrani: 0.0,
    sorumluUzman: "Tuba Aydın",
  );

  // d4 danışanı için Alaaddin Odabaşı uzmanına 3 seanslık medikal estetik randevusu oluşturur
  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "Burun Estetiği",
    birimFiyat: 1500.0,
    seansSayisi: 3,
    sorumluUzman: "Alaaddin Odabaşı", // Dikkat: Bu seansın kodu "SNS-2026-4"
  );

  // Oluşturulan tüm seans kartlarını yöneticinin ana listesine (_seanslar) ekler
  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);
  print("Seanslar Gönderiliyor");

  // --- İŞLEM VE SİMÜLASYON ADIMI ---
  // SNS-2026-1 kodlu seansı Kredi Kartı ödemesi ile başarıyla tamamlandı durumuna getirir (Ciroya eklenir)
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );

  // SNS-2026-2 kodlu seansı Nakit ödemeyle tamamlandı durumuna getirir (Ciroya eklenir)
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);

  // Hata Avcısı Satırı: Burada "SNS-2026-04" aranıyor ancak yukarıda "SNS-2026-4" (sıfırsız) açılmıştı.
  // Bu yüzden sistem bu seansı bulamayacak ve konsola "Hata [SNS-2026-04] kodlu seans bulunamadı" yazacaktır.
  yonetici.seansiIptalEt(
    "SNS-2026-04",
    iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
  );

  // En son adımda kasadaki parayı, bekleyen alacakları, aktif uzmanları ve atanmamış seansları tablo halinde yazdırır
  yonetici.gunSonuRaporuYazdir();
}
