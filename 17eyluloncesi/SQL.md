# SQL CRUD İşlemleri

## 1. Tabloyu oluşturma — CREATE

```
CREATE TABLE users (
    id INT PRIMARY KEY,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL
);
```

Sonuç:
_Query OK, Table 'users' created successfully._

## 2.kullanıcı ekleme — INSERT

```
INSERT INTO users (id, fullname, email)
VALUES
(1, 'Meltem Taşkıran', 'meltem@gmail.com'),
(2, 'Okan Taşkıran', 'okan@gmail.com'),
(3, 'Hatice Ergüş', 'hatice@gmail.com');
```

Sonuç:
3 rows inserted successfully.

## 3.Kullanıcıları listeleme — SELECT

`SELECT * FROM users;`

_Sonuç:_

### Users Tablosu

|  id | fullname        | email            |
| --: | --------------- | ---------------- |
|   1 | Meltem Taşkıran | meltem@gmail.com |
|   2 | Okan Taşkıran   | okan@gmail.com   |
|   3 | Hatice Ergül    | hatice@gmail.com |

## 4.Kullanıcının email adresini güncelleme — UPDATE

Örneğin Hatice Ergül'ün email adresini güncelleyelim:

```
UPDATE users
SET email = 'hatice.ergul@gmail.com'
WHERE id = 3;
```

Sonuç:
_1 row updated successfully._

Güncel tabloyu görmek için:

`SELECT * FROM users;`

Sonuç:

### Users Tablosu

|  id | fullname        | email                  |
| --: | --------------- | ---------------------- |
|   1 | Meltem Taşkıran | meltem@gmail.com       |
|   2 | Okan Taşkıran   | okan@gmail.com         |
|   3 | Hatice Ergül    | hatice.ergul@gmail.com |

## 5. Bir kullanıcıyı silme — DELETE

Örneğin Meltem Taşkıran'ı silelim:

```
DELETE FROM users
WHERE id = 1;
```

Sonuç:

1 row deleted successfully.

Son durumu görmek için:

`SELECT * FROM users;`

### Users Tablosu

|  id | fullname      | email                  |
| --: | ------------- | ---------------------- |
|   2 | Okan Taşkıran | okan@gmail.com         |
|   3 | Hatice Ergül  | hatice.ergul@gmail.com |

## INNER JOIN

_INNER JOIN_, iki tablo arasında eşleşen kayıtları birleştirmek için kullanılır.

### Users Tablosu

|  id | fullname        | email                  |
| --: | --------------- | ---------------------- |
|   1 | Meltem Taşkıran | meltem@gmail.com       |
|   2 | Okan Taşkıran   | okan@gmail.com         |
|   3 | Hatice Ergül    | hatice.ergul@gmail.com |

### Orderss Tablosu

| order_id | user_id |
| -------: | ------- |
|      S11 | 1       |
|      S12 | 1       |
|      S13 | 2       |

Sorgu

```SELECT
    users.fullname,
    users.email,
    orders.order_id
FROM users
INNER JOIN orders
    ON users.id = orders.user_id;
```

SELECT ile kullanıcı adı, email ve sipariş numarasını seçiyoruz. FROM users ile users tablosundan başlıyoruz. INNER JOIN orders ile iki tabloyu birleştirip, ON users.id = orders.user_id sayesinde kullanıcı ID'si ile siparişin kullanıcı ID'sini eşleştiriyoruz. INNER JOIN sadece eşleşen kayıtları getirir, bu yüzden siparişi olmayan kullanıcılar sonuçta görünmez

## Mobil Uygulama Güvenliği

**a- Ekran Görüntüsü ve Ekran Kaydı**

- **Neden Önemli?** Kredi kartı numarası, CVV, bakiye veya OTP bildirimleri gibi hassas verilerin üçüncü taraf zararlı yazılımlar tarafından arka planda izinsiz kaydedilmesini veya kullanıcının galerisinde şifresiz şekilde depolanmasını engellemek için kritik önem taşır.
- **Güvenlik Mekanizmaları:**
- **Android:** Aktiviteye `FLAG_SECURE` bayrağının eklenmesi (ekran görüntüsü almayı engeller, ekran kaydında ilgili pencereyi siyah gösterir).
- **iOS:** `UIScreen.capturedDidChangeNotification` dinlenerek ekran kaydı tespit edildiğinde arayüzün gizlenmesi veya içerik görünümünün `UITextField(isSecureTextEntry = true)` katmanları kullanılarak gizlenmesi.

**b- Overlay (Üst Üste Bindirme) Saldırıları**

- **Nasıl Gerçekleşir?** Zararlı bir uygulama, sistemdeki "diğer uygulamaların üzerinde gösterilme" iznini kullanarak hedef uygulamanın (ör. banka uygulaması) tam üzerine şeffaf veya tamamen aynı görünen sahte bir katman (View) yerleştirir.
- **Örnek:** Kullanıcı banka uygulamasını açtığında, saldırganın arka planda çalışan uygulaması durumu tespit edip tam o anda ekrana sahte bir "Oturum Süreniz Doldu, Lütfen Şifrenizi Girin" penceresi çıkarır. Kullanıcı veriyi ana uygulamaya girdiğini sanarak şifresini saldırgana kaptırır.

---

**c- Root / Jailbreak**

- **Neden Riskli?** İşletim sisteminin sunduğu Sandboxing (uygulamaların birbirinden izole çalışması) ve erişim kısıtlama mimarisi tamamen devre dışı kalır. Tüm süreçler `root` yetkisiyle çalıştırılabildiği için bir uygulamanın güvenlik sınırları aşılmış olur.
- **Bellek ve Dosya Erişimi Örneği:** Normal şartlarda bir uygulama sadece kendi özel dosya dizinine (`/data/data/com.ornek.app`) erişebilir. Root'lu bir cihazda saldırgan, Frida veya Objection gibi araçlarla çalışan uygulamanın RAM belleğine (memory dump) bağlanarak bellekte şifrelenmeden tutulan Access Token'ları, şifreleri veya SQLite dosyasından düz metin verileri doğrudan okuyabilir.

---

**d- SQLite ve Şifreleme**

- **Düz Metin Riski:** Standart SQLite veritabanı dosyaları şifresizdir. Cihaz çalındığında, yedeklendiğinde veya Root/Jailbreak erişimi sağlandığında, saldırgan veritabanı dosyasını (`.db`/`.sqlite`) cihazdan çekerek bir SQLite Görüntüleyici ile tüm kullanıcı bilgilerini düz metin olarak okuyabilir.
- **SQLCipher ile Ne Değişir?** SQLCipher, veritabanı sayfa seviyesinde AES-256 algoritması ile tam disk şifrelemesi sağlar. Doğru şifreleme anahtarı verilmeden veritabanı dosyası dışarıdan açıldığında tamamen anlamsız bayt yığınından ibaret görünür.

---

**e- Access Token ve Refresh Token**

- **Temel Fark:**
  **Access Token**, korumalı kaynaklara (API endpoints) erişim sağlayan kısa ömürlü bir yetki belgesidir. **Refresh Token** ise Access Token'ın süresi dolduğunda kullanıcıyı tekrar giriş ekranına yönlendirmeden yeni bir Access Token almak için kullanılan uzun ömürlü anahtardır.
- **Access Token Neden Kısa Süreli?** Çalınması veya ağda dinlenmesi (MITM) durumunda saldırganın sisteme erişim süresini ve verebileceği zararı minimumda tutmak için (ör. 15-30 dakika).
- **Refresh Token Neden Güvenli Yerde Saklanmalı?** Çalındığı takdirde saldırgan uzun süre boyunca sistemden yeni Access Token'lar üreterek kullanıcı adına işlem yapabilir. Bu yüzden Android'de _EncryptedSharedPreferences/Keystore_, iOS'ta _Keychain_ gibi güvenli alanlarda tutulmalıdır.
- **Çıkış Yapıldığında İptal Edilme Nedeni:** Kullanıcı güvenli çıkış yaptığında, ilgili Refresh Token sunucu tarafında (ör. Redis veya DB) kara listeye alınarak (revoke) yetkisiz kişilerin bu token ile tekrar yeni oturum açması kesin olarak engellenir.
