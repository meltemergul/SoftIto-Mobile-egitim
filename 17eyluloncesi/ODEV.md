"KahveGo" Mobil Kahve Sipariş Uygulaması

GÖREV 1: Sözde Kod

BAŞLA
Uygulamayı aç
EĞER
kullanıcı giriş yapmış mı?
İSE
Ürünler ekranını göster
DEĞİLSE
Giriş ekranına yönlendir
Kullanıcının giriş yapmasını bekle
Ürünler ekranını göster
SON

    Sepeti oluştur

    DÖNGÜ
        Kullanıcı kahve ürünlerinden birini seçer
        Seçilen ürünü sepete ekle

        EĞER

kullanıcı alışverişe devam etmek istiyor mu?
İSE
Ürün seçmeye devam et
DEĞİLSE
Sepete git
DÖNGÜDEN ÇIK
SON
SON DÖNGÜ

    Sepet tutarını hesapla

    EĞER

sepet boş mu?
İSE
"Sepet boş" uyarısı göster
Ürünler ekranına dön
DEĞİLSE
Kullanıcının cüzdan bakiyesini kontrol et
SON

    EĞER

cüzdan bakiyesi >= sepet tutarı mı?
İSE
Siparişi onayla
Sepet tutarını cüzdan bakiyesinden düş
Sipariş paketini hazırla
Sipariş paketini arka planda sunucuya gönder
"Siparişiniz başarıyla oluşturuldu" mesajını göster
DEĞİLSE
"Yetersiz bakiye. Bakiye Yükle" uyarısı göster
Bakiye yükleme ekranına yönlendir
SON

BİTİR

GÖREV 2: REST API Uç Noktası (Endpoint) & JSON Tasarımı

1. Sipariş Oluşturma Endpoint'i
   HTTP Metodu: POST
   URL / Endpoint:/api/v1/siparisler
   Header'lar:
   Authorization: Bearer <token>
   Content-Type: application/json
   Örnek Request Body (JSON):
   {
   "urunler": [
   {
   "kahve_adi": "Ice Latte",
   "boyut": "Grande",
   "adet": 2,
   "birim_fiyat": 85.50
   },
   {
   "kahve_adi": "Americano",
   "boyut": "Tall",
   "adet": 1,
   "birim_fiyat": 65.00
   }
   ],
   "toplam_tutar": 236.00
   }

Başarılı Sonuç:201 Created
Örnek Response:
{
"siparis_id": "a81f52d4",
"mesaj": "Sipariş başarıyla oluşturuldu.",
"toplam_tutar": 236.00,
"durum": "Onaylandı"
}

Kullanıcı giriş yapmamışsa:401 Unauthorized
Örnek Response:
{
"mesaj": "Yetkilendirme başarısız. Lütfen giriş yapın."
}

2. Cüzdan Bakiye Sorgulama Endpoint'i
   HTTP Metodu: GET
   URL / Endpoint:/api/v1/kullanici/bakiye
   Header:Authorization: Bearer <token>
   Örnek Response (JSON):
   {
   "bakiye": 885.50,
   "para_birimi": "TRY"
   }

Sunucuda beklenmeyen bir hata oluşursa:500 Internal Server Error
Örnek Response:
{
"mesaj": "Sunucuda beklenmeyen bir hata oluştu."
}

Mini Mülakat Sorusu
GET isteği Idempotenttir(eş güçlü bir istek); POST isteği ise idempotent değildir, çünkü aynı GET isteği tekrarlandığında sunucudaki kaynak değişmezken, aynı POST isteğinin birden fazla gönderilmesi birden fazla sipariş oluşturabilir.

GÖREV 3: Clean Code & SOLID Prensip Teşhisi

1. Single Responsibility Principle (SRP)
   KahveSiparisYoneticisi sınıfı; sepet hesaplama ve indirim uygulama, kredi kartından ödeme alma, veritabanına sipariş kaydetme ve müşteriye SMS gönderme gibi birden fazla sorumluluğu var. SRP'ye uygun olarak bu sınıf; SiparisHesaplayici/IndirimServisi, OdemeServisi, SiparisRepository ve BildirimServisi gibi her biri tek bir sorumluluğa sahip küçük parçalara ayrılmalıdır.
2. Open/Closed Principle (OCP)
   Yeni bir müşteri tipi eklendiğinde mevcut if-else yapısını değiştirmek zorunda kalmak Open/Closed Principle (OCP) prensibine aykırıdır. OCP'ye göre sınıflar geliştirmeye açık, değişime kapalı olmalıdır; bu nedenle yeni müşteri tipleri mevcut kodu değiştirmeden eklenmelidir.
