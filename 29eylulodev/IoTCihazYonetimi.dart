// 1. ENUM
enum CihazTipi { sensor, gateway, edgeServer, router }

// 2. ÖZEL EXCEPTION
class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => "CihazErisilemezException: $mesaj";
}

// 3. CLASS, SET ve GETTER
class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set<String> acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool isOnline;

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    required this.acikPortlar,
    required this.sslSertifikasiGecerliMi,
    this.isOnline = true,
  });

  // GETTER: Güvenlik açığı kontrolü
  bool get guvenlikAcigiVarMi =>
      !sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET");

  // GETTER: Genel risk durumu
  bool get riskliMi => guvenlikAcigiVarMi || cpuYukYuzdesi > 85.0;
}

// 4. SWITCH EXPRESSION
String izolasyonBolgesiniGetir(CihazTipi tip) {
  return switch (tip) {
    CihazTipi.sensor => "ZONE-100-SENSORS",
    CihazTipi.gateway => "ZONE-200-GATEWAYS",
    CihazTipi.edgeServer => "ZONE-300-EDGE",
    CihazTipi.router => "ZONE-400-ROUTERS",
  };
}

// 5. RECORD ve EXCEPTION Fırlatma
(String cihazAdi, CihazTipi tip, bool alarmDurumu) cihazOzetiniGetir(
  List<IoTCihaz> cihazlar,
  String seriNo,
) {
  final cihaz = cihazlar.cast<IoTCihaz?>().firstWhere(
    (c) => c?.seriNo == seriNo,
    orElse: () => null,
  );

  if (cihaz == null) {
    throw CihazErisilemezException(
      "$seriNo seri numaralı cihaz ağda bulunamadı!",
    );
  }

  if (!cihaz.isOnline) {
    throw CihazErisilemezException(
      "${cihaz.cihazAdi} ($seriNo) cihazı kapalı olduğu için verilerine erişilemiyor!",
    );
  }

  return (cihaz.cihazAdi, cihaz.tip, cihaz.riskliMi);
}

void main() {
  print("*** IoT AĞ YÖNETİM SİSTEMİ BAŞLATILDI ***\n");

  // 6. LIST ve NESNE OLUŞTURMA
  final List<IoTCihaz> iotAgi = [
    IoTCihaz(
      seriNo: "SN-101",
      cihazAdi: "Sıcaklık Sensörü A1",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 25.5,
      bellekMb: 128,
      acikPortlar: {"80/HTTP", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-102",
      cihazAdi: "Saha Gateway B2",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 88.0,
      bellekMb: 1024,
      acikPortlar: {"22/SSH", "23/TELNET", "443/HTTPS"},
      sslSertifikasiGecerliMi: false,
    ),
    IoTCihaz(
      seriNo: "SN-103",
      cihazAdi: "Sınır Sunucu Alpha",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 62.1,
      bellekMb: 4096,
      acikPortlar: {"443/HTTPS", "8080/HTTP"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-104",
      cihazAdi: "Ana Yönlendirici C1",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 92.4,
      bellekMb: 512,
      acikPortlar: {"23/TELNET", "80/HTTP"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-105",
      cihazAdi: "Nem Sensörü A2 (Kapalı)",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 0.0,
      bellekMb: 64,
      acikPortlar: {"80/HTTP"},
      sslSertifikasiGecerliMi: false,
      isOnline: false, // Kapalı cihaz
    ),
    IoTCihaz(
      seriNo: "SN-106",
      cihazAdi: "Yedek Gateway B3",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 45.8,
      bellekMb: 2048,
      acikPortlar: {"22/SSH", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),
  ];

  // --- AÇIKLAMA VE BÖLGE TESPİTİ (Switch Expression) ---
  print("CİHAZ İZOLASYON BÖLGELERİ:");
  for (var cihaz in iotAgi) {
    final bolge = izolasyonBolgesiniGetir(cihaz.tip);
    print(
      "- ${cihaz.cihazAdi} [${cihaz.tip.name}] -> İzolasyon Bölgesi: $bolge",
    );
  }
  print("\n" + "-" * 50 + "\n");

  // 7. WHERE() KULLANIMI
  final List<IoTCihaz> riskliCihazlar = iotAgi
      .where((cihaz) => cihaz.riskliMi)
      .toList();

  print("RİSKLİ CİHAZLAR:");
  for (var cihaz in riskliCihazlar) {
    print(
      "- ${cihaz.cihazAdi} (CPU: %${cihaz.cpuYukYuzdesi}, Güvenlik Açığı: ${cihaz.guvenlikAcigiVarMi})",
    );
  }
  print("\n" + "-" * 50 + "\n");

  // 8. FOLD() KULLANIMI
  final int toplamBellek = iotAgi.fold<int>(
    0,
    (toplam, cihaz) => toplam + cihaz.bellekMb,
  );

  print("***AĞDAKİ TOPLAM BELLEK KULLANIMI:");
  print("- Toplam RAM: $toplamBellek MB\n");
  print("-" * 50 + "\n");

  // 9. TRY-CATCH, RECORD ve EXCEPTION YÖNETİMİ
  print("***CİHAZ SORGULAMA VE SİMÜLASYON:");

  final sorgulanacakSeriNolar = ["SN-101", "SN-105", "SN-999"];

  for (var seriNo in sorgulanacakSeriNolar) {
    try {
      // Record ile dönen veriyi karşılıyoruz
      final (cihazAdi, tip, alarm) = cihazOzetiniGetir(iotAgi, seriNo);
      print("Sorgu Başarılı [$seriNo]:");
      print(
        "---Adı: $cihazAdi | Tipi: ${tip.name} | Alarm Durumu: ${alarm ? 'VAR' : 'YOK'}",
      );
    } on CihazErisilemezException catch (e) {
      print("HATA YAKALANDI [$seriNo]: $e");
    } catch (e) {
      print("BİLİNMEYEN HATA: $e");
    }
  }

  print("\n*** İŞLEMLER TAMAMLANDI ***");
}
