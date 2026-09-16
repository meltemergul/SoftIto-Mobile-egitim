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

id fullname email
1 Meltem Taşkıran meltem@gmail.com
2 Okan Taşkıran okan@gmail.com
3 Hatice Ergül hatice@gmail.com

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

id fullname email
1 Meltem Taşkıran meltem@gmail.com
2 Okan Taşkıran okan@gmail.com
3 Hatice Ergül hatice.ergul@gmail.com

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

id fullname email
2 Okan Taşkıran okan@gmail.com
3 Hatice Ergül hatice.ergul@gmail.com

## INNER JOIN

_INNER JOIN_, iki tablo arasında eşleşen kayıtları birleştirmek için kullanılır.

users table
id fullname email
1 Meltem Taşkıran meltem@gmail.com
2 Okan Taşkıran okan@gmail.com
3 Hatice Ergül hatice@gmail.com

orders table
| order_id | user_id |
| S11 | 1 |
| S12 | 1 |
| S13 | 2 |

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

**a- Ekran görüntüsü ve ekran kaydı**

Bankacılık uygulamalarında kart bilgileri ve bakiye gibi önemli bilgilerin ekran görüntüsünün alınmasını veya ekran kaydı yapılmasını engellemek gerekir. Çünkü bu bilgiler başka kişilerin eline geçebilir.

-_Android:_ FLAG*SECURE kullanılarak ekran görüntüsü ve ekran kaydı engellenebilir. -\_iOS:* Ekran kaydı veya ekran görüntüsü algılanarak hassas bilgiler gizlenebilir.

**b- Overlay saldırıları**

Saldırgan, başka bir uygulamanın üzerine sahte bir buton veya ekran koyarak kullanıcıyı kandırabilir.

Örnek: Kullanıcı bankacılık uygulamasında para gönderme butonuna bastığını düşünürken, aslında ekranda bulunan sahte butona basmış olabilir ve farklı bir işlem gerçekleşebilir.

**c- Root / Jailbreak**

Root veya Jailbreak yapılmış cihazlarda telefonun normal güvenlik kısıtlamaları azaltıldığı için uygulamaların dosyalarına veya belleğine ulaşmak daha kolay olabilir.

Örnek: Saldırgan uygulamanın belleğinde bulunan Access Token gibi bilgileri ele geçirebilir veya uygulamanın dosyalarındaki kullanıcı bilgilerine ulaşabilir.

**d- SQLite ve şifreleme**

Normal bir SQLite veritabanında bilgiler düz metin olarak tutuluyorsa, veritabanı dosyasına ulaşan biri bu bilgileri okuyabilir. Bu da kullanıcı bilgilerinin çalınmasına neden olabilir.

SQLCipher kullanıldığında veritabanı şifrelenir. Böylece dosya başkasının eline geçse bile şifreleme anahtarı olmadan içindeki bilgileri okumak daha zor olur.

**e- Access Token ve Refresh Token**
_Access Token:_ API'lere erişmek için kullanılır ve genellikle kısa süreli tutulur,güvenlik için. Böylece token ele geçirilirse saldırganın kullanabileceği süre sınırlı olur.

_Refresh Token:_ Yeni bir Access Token almak için kullanılır ve daha uzun süre geçerli olabilir. Bu yüzden Access Token'a göre daha güvenli bir yerde saklanması gerekir.

Kullanıcı çıkış yaptığında Refresh Token iptal edilebilir. Böylece eski token kullanılarak tekrar yeni bir Access Token alınmasının önüne geçilebilir.
