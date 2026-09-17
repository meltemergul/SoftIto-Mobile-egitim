# Veritabanı Normalizasyonu

_1NF:_ Her sütun tek bir atomik (bölünemez) değer içermeli ve tekrarlayan gruplar olmamalıdır.

_2NF:_ 1NF sağlanmalı ve kısmi bağımlılıklar (Partial Dependency) giderilmelidir; birincil anahtarın parçasına bağımlı sütun olmamalıdır.

_3NF:_ 2NF sağlanmalı ve geçişli bağımlılıklar (Transitive Dependency) giderilmelidir; birincil anahtar dışındaki bir sütun, yine birincil anahtar dışındaki başka bir sütuna bağımlı olmamalıdır.

`PRAGMA foreign_keys = ON;`

-- =========================================
-- ÖĞRENCİLER
-- =========================================

```
CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    student_id TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

-- =========================================
-- BÖLÜMLER
-- =========================================

```
CREATE TABLE IF NOT EXISTS departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_name TEXT NOT NULL UNIQUE,
    department_head TEXT NOT NULL
);
```

-- =========================================
-- DERSLER
-- =========================================

```
CREATE TABLE IF NOT EXISTS courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_id INTEGER NOT NULL,
    course_name TEXT NOT NULL,
    course_credit INTEGER NOT NULL
        CHECK (course_credit > 0),

    FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE RESTRICT
);
```

-- =========================================
-- ÖĞRENCİ - DERS İLİŞKİSİ
-- =========================================

```
CREATE TABLE IF NOT EXISTS enrollments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    student_note INTEGER
        CHECK (student_note BETWEEN 0 AND 100),
    enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (student_id, course_id),

    FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE,

    FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);
```

## Örnek Veriler

-- Bölümler

```
INSERT INTO departments (department_name, department_head)
VALUES
('Bilişim Sistemleri Mühendisliği', 'Prof. Dr. Ahmet Yılmaz'),
('Bilgisayar Mühendisliği', 'Prof. Dr. Ayşe Demir');
```

-- Öğrenciler

```
INSERT INTO students (full_name, student_id, phone)
VALUES
('Meltem Ergül', '20210001', '05551234567'),
('Okan Taşkıran', '20210002', '05551234568'),
('Hatice Ergül', '20210003', '05551234569');
```

-- Dersler

```
INSERT INTO courses (department_id, course_name, course_credit)
VALUES
(1, 'Veritabanı Yönetimi', 4),
(1, 'Yazılım Mühendisliği', 3),
(2, 'Algoritmalar', 4),
(2, 'Programlama Dilleri', 3);
```

-- Öğrenci-Ders kayıtları

```
INSERT INTO enrollments (student_id, course_id, student_note)
VALUES
(1, 1, 85),
(1, 2, 90),
(2, 1, 75),
(2, 2, 80),
(3, 3, 95),
(3, 4, 88);
```

### Inner Join

```
SELECT
    s.id,
    s.full_name,
    s.student_id,
    d.department_name
FROM students s
JOIN departments d
    ON s.id = s.id
    AND d.id = (
        SELECT c.department_id
        FROM courses c
        JOIN enrollments e ON e.course_id = c.id
        WHERE e.student_id = s.id
        LIMIT 1
    );
```

### \*\*\*

SQL'de sütundaki sayısal değerleri toplamak için SUM() toplama (aggregate) fonksiyonu kullanılır.

Temel Kullanım
`SELECT SUM(sutun_adi) FROM tablo_adi;`

Örnek Senaryolar

### 1. Belli bir sütunun toplamını alma

Siparisler tablosundaki tüm tutarların toplamını bulmak için:

```
SELECT SUM(Tutar) AS ToplamTutar
FROM Siparisler;
```

### 2. Belli bir şarta göre toplama (WHERE ile)

Sadece 'Ankara' şehrindeki müşterilerin sipariş toplamını bulmak için:

```
SELECT SUM(Tutar) AS AnkaraToplamTutar
FROM Siparisler
WHERE Sehir = 'Ankara';
```

### 3. Gruplayarak toplama (GROUP BY ile)

Müşteri bazında yapılan toplam harcamaları görmek için:

```
SELECT MusteriID, SUM(Tutar) AS ToplamHarcama
FROM Siparisler
GROUP BY MusteriID;
```

Not: Tabloda NULL (boş) olan değerler varsa, SUM() fonksiyonu bu değerleri otomatik olarak yok sayar ve toplamaya dahil etmez.
