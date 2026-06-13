# Texnik topshiriq - BSK

# **📄 YANGILANGAN TEXNIK TOPSHIRIQ (v2.0)**

## **Ko'p Qavatli Binalarda FaceID Kirish Nazorati va Monitoring Tizimi**

| Hujjat raqami: | TT-FACEID-2025-001-v2.0 |
| --- | --- |
| **Versiya:** | 2.0 (Yangilangan) |
| **Tuzilgan sana:** | 2025-yil |
| **Buyurtmachi:** | Boshqaruv service kompaniyalari / GASN / Qurilish boshqarmasi |
| **Bajaruvchi:** | Senior Software Architect Team |
| **Holati:** | **Tasdiqlash uchun tayyor** |

---

## **1. UMUMIY MA'LUMOT**

### **1.1. Loyiha maqsadi**

Ushbu texnik topshiriq ko'p qavatli turar-joy binolarining kirish qismlarida FaceID (yuz tanish) texnologiyasi asosida ishlaydigan avtomatlashtirilgan kirish nazorati va monitoring tizimini yaratish uchun mo'ljallangan.

**Muhim o'zgarish:** Shaxsiy ma'lumotlar xavfsizligini ta'minlash maqsadida **pasport ma'lumotlari saqlanmaydi**. Identifikatsiya uchun faqat **telefon raqam** ishlatiladi.

Tizim quyidagi tashkilotlar tomonidan foydalanish va nazorat qilish uchun mo'ljallangan:

1. Boshqaruv service kompaniyalari va ularning yuqori turuvchi tashkilotlari
2. Davlat Arxitektura va Qurilish Nazorati (GASN)
3. Qurilish boshqarmasi
4. Prokuratura organlari
5. Ichki ishlar organlari

### **1.2. Loyiha doirasi**

Tizim kompleks yechim sifatida quyidagilarni qamrab oladi:

1. Ko'p qavatli bino kirish eshiklariga o'rnatiluvchi FaceID terminallar
2. Markaziy server va ma'lumotlar bazasi (PHP/Yii2 + PostgreSQL)
3. Web va mobil boshqaruv paneli (React.js)
4. Voqealar (events) jurnali va hisobotlar moduli
5. Nazorat organlari uchun monitoring paneli

### **1.3. Hujjatda qo'llanilgan qisqartmalar**

| Qisqartma | Ta'rif |
| --- | --- |
| **FaceID** | Yuz tanish texnologiyasi asosidagi identifikatsiya tizimi |
| **GASN** | Davlat Arxitektura va Qurilish Nazorati |
| **API** | Application Programming Interface |
| **SDK** | Software Development Kit |
| **DB** | Ma'lumotlar bazasi (Database) |
| **UI/UX** | Foydalanuvchi interfeysi va foydalanish qulayligi |
| **TT** | Texnik topshiriq |
| **JWT** | JSON Web Token — autentifikatsiya tokeni |
| **OTP** | One-Time Password — bir martalik parol (SMS) |

---

## **2. FUNKSIONAL TALABLAR**

### **2.1. FaceID Terminaliga Talablar**

*(O'zgarishsiz qoladi, аппаратные требования прежние)*

### **2.1.1. Apparat (Hardware) talablari**

| Parametr | Tavsif | Minimal talab |
| --- | --- | --- |
| Protsessor | ARM Cortex yoki x86 arxitekturasi | Quad-core 1.8 GHz |
| Kamera | Infraqizil + RGB ikki kamerali modul | 2 MP, 30 fps, IR |
| Yuz tanish algoritmi | Deep Learning asosida, 3D yuz tahlili | 99.5% aniqliq |
| Tanish tezligi | Bir odamni tanish vaqti | < 0.5 soniya |
| Simultanlik | Bir vaqtda bir nechta yuz tanishi | Kamida 5 yuz |
| Ma'lumotlar bazasi | Qurilmadagi lokal saqlash | Kamida 10,000 yuz |
| Ulanish | Tarmoq aloqasi | Ethernet + Wi-Fi |
| Ekran | Touch-screen displey | 7 inch, IPS |
| Qo'shimcha I/O | Eshik qulfi bilan integratsiya | Wiegand / RS-485 |
| IP himoya darajasi | Tashqi muhitdan himoya | IP65 va yuqori |
| Ishlash harorati | Muhit harorati diapazoni | -20°C dan +50°C gacha |
| Quvvat | Asosiy va zaxira quvvat | PoE / 12V DC, UPS qo'llab |

### **2.1.2. Dasturiy (Software) talablar**

1. Linux yoki Android OS asosida ishlash
2. FaceID SDK integratsiyasi (liveness detection majburiy)
3. Oflayn rejimda mustaqil ishlash imkoniyati (tarmoq uzilganda ham lokal DB bilan ishlash)
4. Server bilan sinxronizatsiya (real-time va batch rejimda)
5. Qurilmada shifrlanmagan yuz ma'lumotlarini saqlamaslik (faqat vector/template)
6. Firmware masofadan yangilash imkoniyati (OTA update)

### **2.2. Asosiy Funksiyalar — Kirish Nazorati**

### **2.2.1. Yuz orqali eshikni ochish**

1. Shaxs kirish eshigiga yaqinlashadi (sensor yoki harakat detektori orqali terminal faollashadi)
2. Terminal kamera yordamida yuzni skanerlaydi
3. Liveness detection bajariladi (jonli shaxs tekshiruvi — foto yoki video aldashga qarshi)
4. Yuz vektori lokal ma'lumotlar bazasidagi ro'yxatga solishtiriladi
5. Mos kelgan holda: eshik qulfi ochiladi, ekranda salomlashuv xabari ko'rsatiladi
6. Mos kelmagan holda: eshik yopiq qoladi, ekranda xabar ko'rsatiladi, voqea serverga yuboriladi
7. Har qanday kirishda (tanilgan/tanilmagan) foto serverga yuklanadi

### **2.2.2. Tanilgan va tanilmagan shaxslarni ajratish**

| Kategoriya | Ta'rif | Tizim harakati |
| --- | --- | --- |
| **Tanilgan shaxs** | Ma'lumotlar bazasida ro'yxatdan o'tgan, kirish huquqi bor | Eshik ochiladi, log yoziladi, foto saqlanadi |
| **Tanilmagan shaxs** | Bazada yo'q yoki kirish huquqi bekor qilingan | Eshik yopiq, ogohlantirish, foto saqlanadi |
| **Shubhali urinish** | Bir necha bor tanilmagan urinish (3+ marta) | Qo'shimcha ogohlantirish va push-bildirishnoma |

### **2.3. Foydalanuvchilarni Boshqarish Moduli**

### **2.3.1. Resident (Yashovchi) qo'shish**

1. To'liq ism-sharif, **telefon raqami (unikal identifikator)**
2. Binoda qaysi xonadon/kvartiraga tegishli ekanligi
3. Bir nechta yuz foto/skan yuklash (turli burchak, yoritish)
4. Yuz shabloni (template) avtomatik yaratiladi
5. Qaysi terminallarga kirish huquqi berilishi (1 bino — 1 yoki bir nechta terminal)
6. Kirish vaqt oralig'ini cheklash imkoniyati (masalan, faqat 07:00–23:00)
7. **Pasport ma'lumotlari talab qilinmaydi va saqlanmaydi.**

### **2.3.2. Resident ma'lumotlarini tahrirlash**

1. Shaxsiy ma'lumotlarni yangilash (Ism, Telefon)
2. Yuz foto/templateni yangilash
3. Kirish huquqlarini o'zgartirish
4. Vaqtinchalik kirish taqiqi qo'yish/olib tashlash

### **2.3.3. Residentni o'chirish / chiqarish**

1. Residentni tizimdan o'chirish (barcha terminallardan sinxron o'chirish)
2. O'chirish tarixi log'da saqlanadi
3. Yumshoq o'chirish (soft delete) — arxivda qoladi, lekin kirish bloklanadi

### **2.3.4. Residentni bir binodан boshqasiga ko'chirish**

1. Bir bino/kirish terminali ma'lumotlar bazasidan boshqasiga o'tkazish
2. Avvalgi terminaldan avtomatik o'chirish
3. Yangi terminalga avtomatik qo'shish
4. Ko'chirish tarixi va sababi qayd etiladi

### **2.3.5. Mehmon va vaqtinchalik kirish**

1. Vaqtinchalik QR-kod yoki PIN generatsiya qilish
2. Amal qilish muddatini belgilash (1 soatdan 30 kungacha)
3. Foydalanish soni cheklovi (1 marta, 5 marta, cheksiz)
4. Mehmon kirish tarixi alohida kategoriyada saqlanadi

### **2.4. Voqealar (Events) va Loglash Moduli**

### **2.4.1. Yoziladigan voqealar turlari**

| Voqea turi | Trigger | Saqlanadigan ma'lumot |
| --- | --- | --- |
| **DOOR_OPEN_SUCCESS** | Tanilgan shaxs kirdi | Vaqt, shaxs ID (Phone), terminal ID, foto |
| **DOOR_OPEN_DENIED** | Tanilmagan shaxs urinishi | Vaqt, terminal ID, foto (anonim) |
| **DOOR_OPEN_MANUAL** | Qo'lda ochish (operator) | Vaqt, operator ID, sabab |
| **LIVENESS_FAIL** | Jonli shaxs bo'lmagan (foto/video) | Vaqt, terminal ID, foto |
| **DEVICE_ONLINE** | Terminal tarmoqqa ulandi | Vaqt, terminal ID, IP |
| **DEVICE_OFFLINE** | Terminal aloqani yo'qotdi | Vaqt, terminal ID |
| **SYNC_COMPLETE** | Terminal ma'lumotlar yangilandi | Vaqt, o'zgarishlar soni |
| **USER_ADDED** | Yangi resident qo'shildi | Vaqt, admin ID, resident ID (Phone) |
| **USER_DELETED** | Resident o'chirildi | Vaqt, admin ID, sabab |
| **USER_TRANSFERRED** | Resident ko'chirildi | Vaqt, eski/yangi terminal |
| **SUSPICIOUS_ATTEMPT** | 3+ marta tanilmagan urinish | Vaqt, terminal ID, fotolar |
| **DOOR_FORCED** | Eshik majburiy ochildi (sensor) | Vaqt, terminal ID, ogohlantirish |

### **2.4.2. Log saqlash talablari**

1. Barcha voqealar server tomonida markaziy DB da saqlanadi
2. Terminal oflayn bo'lganda voqealar lokal saqlanib, aloqa tiklanganda serverga yuboriladi
3. Fotosuratlar alohida fayl serverida (object storage) saqlanadi, log'da URL ko'rsatiladi
4. Saqlash muddati: kamida 1 yil (arxiv: 5 yil)
5. Log o'chirish faqat yuqori huquqli admin tomonidan amalga oshiriladi va o'zi ham log yoziladi
6. **Shaxsiy telefon raqamlari loglarda maskalanishi mumkin (masalan: +99890***1234)*

---

## **3. FOYDALANUVCHI ROLLARI VA HUQUQLAR**

| Rol | Ta'rif | Asosiy huquqlar |
| --- | --- | --- |
| **Super Admin** | Tizim boshqaruvchisi | Barcha amallar, foydalanuvchilarni boshqarish, hisobotlar |
| **Boshqaruv Kompaniya Admin** | Service kompaniya xodimi | O'z binolari rezidentlarini boshqarish, hisobotlar |
| **Bino operatori** | Bino masul shaxsi | Faqat bitta bino rezidentlarini ko'rish/boshqarish |
| **GASN Nazoratchi** | Davlat nazorat organi xodimi | Faqat ko'rish: barcha binolar statistikasi va log'lar |
| **Qurilish Boshqarma** | Qurilish organi xodimi | Ko'rish: binolar ro'yxati, faollik hisobotlari |
| **Prokuratura** | Tekshiruv organi | Ko'rish: ma'lum bino/davr log'lari (so'rov asosida) |
| **IIV (Ichki Ishlar)** | Xavfsizlik organi | Ko'rish: shubhali voqealar, foto arxivi (so'rov asosida) |

*Prokuratura va IIV uchun ma'lumotlarga kirish rasmiy so'rov asosida amalga oshiriladi va barcha urinishlar audit log'da saqlanadi.*

---

## **4. BOSHQARUV PANELI (WEB VA MOBIL)**

### **4.1. Autentifikatsiya va Xavfsizlik**

1. **Tizimga kirish usuli:** Telefon raqam + Parol.
2. **Parol tiklash:** Telefon raqamga SMS kod (OTP) yuborish orqali.
3. **Session boshqaruvi:** JWT token asosida, sessiya muddati cheklangan.
4. **Xavfsizlik:** 5 marta noto'g'ri parol kiritishda account vaqtincha bloklanadi.

### **4.2. Asosiy Ekranlar va Funksiyalar**

### **4.2.1. Dashboard (Asosiy ko'rinish)**

1. Real-time statistika: joriy kunda kirganlar soni, tanilmaganlar soni
2. Barcha terminallar holati (online/offline) xaritada ko'rsatish
3. So'nggi voqealar lentasi (real-time yangilanuvchi)
4. Shubhali voqealar uchun alohida widget
5. Binolar kesimida statistika (grafik ko'rinishda)

### **4.2.2. Rezidentlar bo'limi**

1. Ro'yxat ko'rinishi: filtrlash (bino, kirish huquqi holati, qo'shilgan sana)
2. Qidirish: **ism, xonadon raqami, telefon raqami** bo'yicha
3. Rezident kartochkasi: barcha ma'lumotlar, kirish tarixi, foto
4. Bulk amallar: bir nechta residentni bir vaqtda ko'chirish/o'chirish
5. **Pasport ustuni mavjud emas.**

### **4.2.3. Terminallar bo'limi**

1. Terminal ro'yxati: bino, manzil, holat, oxirgi aloqa vaqti
2. Terminal konfiguratsiyasi: sezgirlik darajasi, vaqt oralig'i sozlamalari
3. Sinxronizatsiya holati: terminalda va serverda nechi nafar resident farqi
4. Remote restart / lock funksiyasi

### **4.2.4. Hisobotlar va Analitika**

1. Kunlik/haftalik/oylik kirish hisoboti
2. Tanilmagan urinishlar statistikasi (grafik + jadval)
3. Terminal faollik darajasi (uptime hisoboti)
4. Eksport: Excel, PDF, CSV formatlarida
5. Avtomatik hisobot yuborish (email/Telegram)

### **4.2.5. Voqealar jurnali**

1. Filtrlash: sana, bino, terminal, voqea turi, shaxs (telefon)
2. Har bir voqea bo'yicha foto ko'rish
3. Eksport imkoniyati
4. Shubhali voqealarni belgilash va izoh qo'shish

---

## **5. TIZIM ARXITEKTURASI**

### **5.1. Komponentlar**

| Komponent | Texnologiya / Platform | Vazifasi |
| --- | --- | --- |
| **FaceID Terminal** | Embedded Linux / Android | Yuz skanerlash, eshikni boshqarish, lokal DB |
| **API Server** | **PHP 8.2 + Yii2 Framework** | Biznes mantiq, terminal bilan aloqa, REST API |
| **Ma'lumotlar bazasi** | **PostgreSQL 15+** | Rezidentlar, voqealar, konfigurasyon |
| **Fotosuratlar saqlash** | MinIO / S3-compatible | Kirish fotolari arxivi |
| **Real-time aloqa** | WebSocket / Redis Pub/Sub | Terminal — server real-time sinxronizatsiya |
| **Web Panel** | React.js 18+ | Boshqaruv interfeysi |
| **Mobil ilova** | React Native | Android va iOS ilovasi |
| **Bildirishnomalar** | Firebase FCM / Telegram Bot | Push va messenjer bildirishnomalar |
| **Monitoring** | Prometheus + Grafana | Tizim ishlash ko'rsatkichlari |
| **Cache** | Redis 7+ | Session, real-time ma'lumotlar cache |

### **5.2. Ma'lumotlar Oqimi**

1. Terminal yuz skanerini amalga oshiradi va lokal DB bilan solishtiradi
2. Natija (kirish ruxsati / rad) darhol terminalda qayta ishlanadi
3. Voqea (event) MQTT/WebSocket orqali serverga yuboriladi
4. Server voqeani DB ga yozadi, foto object storage ga saqlaydi
5. Real-time dashboard yangilanadi (WebSocket orqali)
6. Shubhali voqea aniqlansa — bildirishnoma yuboriladi

### **5.3. Ma'lumotlar Xavfsizligi**

1. Barcha aloqa HTTPS/TLS 1.3 orqali
2. Terminal — server autentifikatsiyasi sertifikat asosida
3. Yuz templatelar AES-256 bilan shifrlangan holda saqlanadi
4. **Parollar bcrypt/argon2 bilan xeshlangan**
5. **Telefon raqamlar bazada shifrlangan holda saqlanishi tavsiya etiladi**
6. API ga kirish JWT token asosida (Phone/Password orqali generatsiya)
7. Rol asosida kirish nazorati (RBAC)
8. Audit log: barcha admin amallar qayd etiladi
9. Ma'lumotlar bazasi muntazam backup (kunlik)

---

## **6. INTEGRATSIYA TALABLARI**

### **6.1. Terminal integratsiyasi**

1. Qurilma producer SDK bilan to'liq integratsiya
2. Standart Wiegand 26/34 protokoli orqali eshik qulfi boshqaruvi
3. RS-485 orqali alternativ eshik kontrolleri
4. Dry contact relay chiqishi (universal qulf kompatibilligi)

### **6.2. Tashqi tizimlar**

1. GASN va boshqaruv tashkilotlarining mavjud tizimlariga REST API orqali integratsiya
2. 1C yoki boshqa uy boshqaruvi tizimlari bilan rezidentlar ro'yxatini sinxronlashtirish imkoniyati (**Telefon raqam orqali**)
3. Telegram bot orqali bildirishnomalar va oddiy so'rovlar
4. SMS Provayder (Ucell/Beeline/Perfectum) integratsiyasi (OTP uchun)

### **6.3. API Dokumentatsiyasi**

1. Swagger/OpenAPI 3.0 formatida to'liq API hujjati
2. Sandbox muhiti (test API)
3. Webhook qo'llab-quvvatlash (tashqi tizimlarga voqealar yuborish)

---

## **7. ISHLASH VA SIFAT TALABLARI**

| Ko'rsatkich | Talab |
| --- | --- |
| Yuz tanish aniqligi (FAR) | < 0.001% (noto'g'ri qabul qilish ehtimoli) |
| Yuz tanish aniqligi (FRR) | < 0.1% (noto'g'ri rad etish ehtimoli) |
| Terminal javob vaqti | < 1 soniya (to'liq siklda) |
| API javob vaqti | < 200ms (95-percentil) |
| Tizim uptime | > 99.5% (oylik) |
| Bir terminalga maksimal rezidentlar | Kamida 10,000 nafar |
| Bir serverga maksimal terminallar | Kamida 500 ta terminal |
| Bir vaqtdagi aktiv foydalanuvchilar (web) | Kamida 200 nafar |
| Log saqlash muddati | 1 yil (aktiv), 5 yil (arxiv) |
| Foto saqlash hajmi | Bir voqea uchun < 200 KB (siqilgan) |
| Oflayn ishlash muddati | Kamida 72 soat lokal DB bilan |
| **Autentifikatsiya vaqti** | **< 3 soniya (Phone+Password)** |

---

## **8. QABUL QILISH MEZONLARI**

### **8.1. Funksional testlar**

1. Barcha ro'yxatdagi foydalanuvchi scenariylari muvaffaqiyatli bajarilishi
2. Tanilgan shaxsning eshikni ochish testi: 50 ta turli shaxs, har biri 3 marta — 99%+ muvaffaqiyat
3. Tanilmagan shaxsning bloklanishi testi: 20 ta sinov — 100% bloklanish
4. Liveness detection testi: foto va video bilan aldash urinishlari — 100% bloklanish
5. Oflayn rejim testi: 72 soat serversiz ishlash
6. Sinxronizatsiya testi: oflayndan onlayn o'tganda hech qanday voqea yo'qolmasligi
7. **Auth testi: Telefon+Parol orqali kirish va SMS tiklash ishlaydi**
8. **Privacy testi: Bazada pasport ma'lumotlari yo'qligi tekshiriladi**

### **8.2. Yuklanish testlari**

1. Bir vaqtda 50 ta terminal faol ishlashi
2. Bir daqiqada 200 ta kirish so'rovi
3. DB da 100,000 ta rezident bilan tizim ishlashi

### **8.3. Xavfsizlik auditi**

1. Penetratsion test (pen-test) hisoboti
2. API autentifikatsiya va avtorizatsiya testlari
3. Ma'lumotlar shifrlash tekshiruvi (Telefon raqamlar va FaceID template)

---

## **9. LOYIHA BOSQICHLARI VA MUDDATLAR**

| Bosqich | Mazmun | Muddat |
| --- | --- | --- |
| 1. Analiz va dizayn | Talablar tahlili, arxitektura dizayni, UI/UX prototip | 2 hafta |
| 2. Backend ishlab chiqish | API server (Yii2), DB schema, terminal protokoli | 4 hafta |
| 3. Terminal integratsiya | SDK integratsiya, terminal dasturiy ta'minotini sozlash | 3 hafta |
| 4. Web panel | Boshqaruv paneli, barcha bo'limlar (React) | 4 hafta |
| 5. Mobil ilova | Android/iOS ilova (React Native) | 3 hafta |
| 6. Sinov va test | QA testlash, xato tuzatish | 2 hafta |
| 7. Pilot joriy etish | Bitta bino uchun pilot | 2 hafta |
| 8. To'liq ishga tushirish | Barcha binolarga kengaytirish, o'qitish | 2 hafta |
| **Jami** |  | **~22 hafta (5-6 oy)** |

---

## **10. TEXNIK QO'LLAB-QUVVATLASH VA KAFOLAT**

1. Ishga tushirishdan keyin 12 oy kafolat muddati
2. 24/7 texnik qo'llab-quvvatlash liniyasi
3. Kritik xatolar uchun javob vaqti: 4 soat ichida
4. Oddiy xatolar uchun: 24 ish soati ichida
5. Oylik texnik hisobot (uptime, xatolar statistikasi)
6. Dasturiy ta'minotni yangilash: xavfsizlik patchlari majburiy, funksional yangilanishlar reja asosida
7. Xodimlarni o'qitish: boshqaruv paneli bo'yicha amaliy o'quv (har bir rol uchun)
8. Foydalanuvchi qo'llanmasi: o'zbek tilida to'liq hujjatlashtirish

---

## **11. KELISHUV VA IMZOLAR**

| Lavozim | Ism-sharif | Sana | Imzo |
| --- | --- | --- | --- |
| Buyurtmachi vakili |  | __**.__**.2025 | ___________ |
| Bajaruvchi rahbar |  | __**.__**.2025 | ___________ |
| Texnik rahbar (Architect) |  | __**.__**.2025 | ___________ |
| GASN vakili |  | __**.__**.2025 | ___________ |

*Ushbu texnik topshiriq loyiha uchun asosiy hujjat bo'lib xizmat qiladi. O'zgartirish kiritish barcha tomonlarning yozma roziligi bilan amalga oshiriladi.*

**Maxfiy | Faqat ichki foydalanish uchun**