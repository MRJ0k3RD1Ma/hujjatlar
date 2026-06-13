# Texnik topshiriq - BSK

# **📋 FACEID KIRISH NAZORATI TIZIMI - LOYIHA TALABLARI TAHLILI**

Men texnik topshiriqni o'rganib chiqdim. Quyida loyiha talablarini kengaytirilgan va tushunarli shaklda taqdim etaman:

---

## **🎯 1. LOYIHA MAQSADI VA DOIRASI**

### **1.1. Asosiy Maqsad**

Ko'p qavatli turar-joy binolarining kirish qismlarida **yuz tanish (FaceID)** texnologiyasi asosida avtomatlashtirilgan kirish nazorati va monitoring tizimini yaratish.

### **1.2. Foydalanuvchi Tashkilotlar**

| Tashkilot | Foydalanish Maqsadi |
| --- | --- |
| Boshqaruv Service Kompaniyalari | Rezidentlarni boshqarish, hisobotlar |
| GASN | Davlat nazorati, statistika |
| Qurilish Boshqarmasi | Bino faollik monitoringi |
| Prokuratura | Tekshiruv ishlari uchun ma'lumot |
| IIV (Ichki Ishlar) | Xavfsizlik va shubhali voqealar |

### **1.3. Tizim Komponentlari**

┌─────────────────────────────────────────────────────────┐
│                    FACEID TIZIMI                        │
├─────────────────────────────────────────────────────────┤
│  📱 FaceID Terminallar  │  🖥️ Markaziy Server          │
│  🌐 Web Boshqaruv Paneli │  📲 Mobil Ilova             │
│  📊 Voqealar Jurnali    │  📈 Hisobotlar Moduli        │
│  👮 Nazorat Paneli      │  🔔 Bildirishnomalar         │
└─────────────────────────────────────────────────────────┘

---

## **🔧 2. FUNKSIONAL TALABLAR**

### **2.1. FaceID Terminal Talablari**

### **2.1.1. Apparat (Hardware) Talablari**

| Parametr | Minimal Talab | Izoh |
| --- | --- | --- |
| **Protsessor** | Quad-core 1.8 GHz | ARM Cortex yoki x86 |
| **Kamera** | 2 MP, 30 fps, IR + RGB | Infraqizil + RGB ikki kamerali |
| **Yuz Tanish Aniqligi** | 99.5% | Deep Learning, 3D tahlil |
| **Tanish Tezligi** | < 0.5 soniya | Bir odamni tanish vaqti |
| **Simultanlik** | 5 yuz | Bir vaqtda bir nechta yuz |
| **Lokal DB** | 10,000 yuz | Qurilmadagi saqlash |
| **Ulanish** | Ethernet + Wi-Fi | Tarmoq aloqasi |
| **Ekran** | 7 inch, IPS | Touch-screen displey |
| **I/O Interfeys** | Wiegand / RS-485 | Eshik qulfi integratsiyasi |
| **IP Himoya** | IP65+ | Tashqi muhitdan himoya |
| **Harorat** | -20°C dan +50°C | Ishlash diapazoni |
| **Quvvat** | PoE / 12V DC + UPS | Asosiy va zaxira quvvat |

### **2.1.2. Dasturiy (Software) Talablari**

- ✅ Linux yoki Android OS
- ✅ FaceID SDK (liveness detection majburiy)
- ✅ Oflayn rejimda mustaqil ishlash
- ✅ Server bilan real-time va batch sinxronizatsiya
- ✅ Faqat yuz vektori/template saqlash (shifrlanmagan rasm yo'q)
- ✅ OTA update (masofadan firmware yangilash)

### **2.2. Kirish Nazorati Funksiyalari**

### **2.2.1. Yuz Orqali Eshikni Ochish Jarayoni**

┌──────────────────────────────────────────────────────────────┐
│                    KIRISH JARAYONI                           │
├──────────────────────────────────────────────────────────────┤
│  1️⃣ Shaxs yaqinlashadi (sensor faollashadi)                  │
│  2️⃣ Kamera yuzni skanerlaydi                                  │
│  3️⃣ Liveness detection (jonli shaxs tekshiruvi)              │
│  4️⃣ Lokal DB bilan solishtirish                               │
│  5️⃣ Natija:                                                  │
│     ✅ Mos kelsa → Eshik ochiladi + Salomlashuv              │
│     ❌ Mos kelmasa → Eshik yopiq + Ogohlantirish             │
│  6️⃣ Har qanday holatda foto serverga yuklanadi               │
└──────────────────────────────────────────────────────────────┘

### **2.2.2. Shaxslarni Kategoriyalash**

| Kategoriya | Ta'rif | Tizim Harakati |
| --- | --- | --- |
| **Tanilgan** | Bazada ro'yxatdan o'tgan | Eshik ochiladi, log yoziladi, foto saqlanadi |
| **Tanilmagan** | Bazada yo'q yoki huquq bekor qilingan | Eshik yopiq, ogohlantirish, foto saqlanadi |
| **Shubhali** | 3+ marta tanilmagan urinish | Qo'shimcha ogohlantirish + Push-bildirishnoma |

### **2.3. Foydalanuvchilarni Boshqarish**

| Funksiya | Tavsif |
| --- | --- |
| **Rezident Qo'shish** | Ism, pasport, telefon, xonadon, yuz foto, kirish huquqlari, vaqt cheklovlari |
| **Tahrirlash** | Shaxsiy ma'lumotlar, yuz template, huquqlar, vaqtinchalik taqiq |
| **O'chirish** | Soft delete (arxivda qoladi), barcha terminallardan sinxron o'chirish |
| **Ko'chirish** | Bir binodan boshqasiga o'tkazish, avtomatik sinxronizatsiya |
| **Mehmon** | QR-kod/PIN generatsiya, amal qilish muddati, foydalanish soni cheklovi |

### **2.4. Voqealar (Events) va Loglash**

### **2.4.1. Yoziladigan Voqealar Turlari**

| Voqea Kodi | Trigger | Saqlanadigan Ma'lumot |
| --- | --- | --- |
| `DOOR_OPEN_SUCCESS` | Tanilgan shaxs kirdi | Vaqt, shaxs ID, terminal ID, foto |
| `DOOR_OPEN_DENIED` | Tanilmagan urinish | Vaqt, terminal ID, anonim foto |
| `DOOR_OPEN_MANUAL` | Qo'lda ochish | Vaqt, operator ID, sabab |
| `LIVENESS_FAIL` | Foto/video aldash | Vaqt, terminal ID, foto |
| `DEVICE_ONLINE/OFFLINE` | Terminal holati | Vaqt, terminal ID, IP |
| `SYNC_COMPLETE` | Sinxronizatsiya | Vaqt, o'zgarishlar soni |
| `USER_ADDED/DELETED/TRANSFERRED` | Foydalanuvchi amallari | Vaqt, admin ID, sabab |
| `SUSPICIOUS_ATTEMPT` | 3+ tanilmagan urinish | Vaqt, terminal ID, fotolar |
| `DOOR_FORCED` | Eshik majburiy ochildi | Vaqt, terminal ID, ogohlantirish |

### **2.4.2. Log Saqlash Talablari**

- 📦 Barcha voqealar markaziy DB da saqlanadi
- 📦 Oflayn bo'lganda lokal saqlash + keyin serverga yuborish
- 📦 Fotolar object storage (MinIO/S3) da, log'da URL ko'rsatiladi
- 📦 Saqlash muddati: **1 yil (aktiv)**, **5 yil (arxiv)**
- 📦 Log o'chirish faqat yuqori huquqli admin tomonidan + audit log

---

## **👥 3. FOYDALANUVCHI ROLLARI VA HUQUQLAR**

| Rol | Huquqlar | Cheklovlar |
| --- | --- | --- |
| **Super Admin** | Barcha amallar | Yo'q |
| **Boshqaruv Kompaniya Admin** | O'z binolari rezidentlarini boshqarish | Faqat o'z binolari |
| **Bino Operatori** | Bitta bino rezidentlarini ko'rish/boshqarish | Faqat bitta bino |
| **GASN Nazoratchi** | Ko'rish: barcha binolar statistikasi va log'lari | Faqat ko'rish |
| **Qurilish Boshqarma** | Ko'rish: binolar ro'yxati, faollik hisobotlari | Faqat ko'rish |
| **Prokuratura** | Ko'rish: ma'lum bino/davr log'lari | Rasmiy so'rov asosida |
| **IIV** | Ko'rish: shubhali voqealar, foto arxivi | Rasmiy so'rov asosida |

> ⚠️ **Prokuratura va IIV** uchun barcha kirish urinishlari audit log'da saqlanadi
> 

---

## **🏗️ 4. TIZIM ARXITEKTURASI**

### **4.1. Texnologik Stack**

| Komponent | Texnologiya | Vazifasi |
| --- | --- | --- |
| FaceID Terminal | Embedded Linux / Android | Yuz skanerlash, eshik boshqaruvi |
| API Server | Node.js / Python (FastAPI) | Biznes mantiq, REST API |
| Ma'lumotlar Bazasi | PostgreSQL | Rezidentlar, voqealar, konfiguratsiya |
| Foto Saqlash | MinIO / S3-compatible | Kirish fotolari arxivi |
| Real-time Aloqa | WebSocket / MQTT | Terminal-server sinxronizatsiya |
| Web Panel | React.js | Boshqaruv interfeysi |
| Mobil Ilova | React Native / Flutter | Android va iOS |
| Bildirishnomalar | Firebase FCM / Telegram Bot | Push va messenger |
| Monitoring | Prometheus + Grafana | Tizim metrikalari |
| Cache | Redis | Session, real-time cache |

### **4.2. Ma'lumotlar Oqimi**

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Terminal  │────▶│  API Server │────▶│  Database   │
│  (FaceID)   │     │  (Node.js)  │     │ (PostgreSQL)│
└─────────────┘     └─────────────┘     └─────────────┘
│                   │                   │
▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Lokal DB    │     │  WebSocket  │     │  MinIO/S3   │
│ (10,000)    │     │  (Real-time)│     │  (Fotolar)  │
└─────────────┘     └─────────────┘     └─────────────┘

### **4.3. Xavfsizlik Talablari**

- 🔐 Barcha aloqa **HTTPS/TLS 1.3** orqali
- 🔐 Terminal-server autentifikatsiya **sertifikat** asosida
- 🔐 Yuz templatelar **AES-256** bilan shifrlangan
- 🔐 Parollar **bcrypt** bilan xeshlangan
- 🔐 API kirish **JWT token** asosida
- 🔐 **RBAC** (Rol asosida kirish nazorati)
- 🔐 **Audit log**: barcha admin amallar qayd etiladi
- 🔐 Ma'lumotlar bazasi **kunlik backup**

---

## **🔌 5. INTEGRATSIYA TALABLARI**

### **5.1. Terminal Integratsiyasi**

- ✅ Qurilma producer SDK bilan to'liq integratsiya
- ✅ Wiegand 26/34 protokoli (eshik qulfi)
- ✅ RS-485 (alternativ eshik kontrolleri)
- ✅ Dry contact relay (universal qulf)

### **5.2. Tashqi Tizimlar**

- ✅ GASN va boshqaruv tizimlari → **REST API**
- ✅ 1C yoki uy boshqaruvi tizimlari → Rezidentlar sinxronizatsiyasi
- ✅ Telegram bot → Bildirishnomalar va so'rovlar

### **5.3. API Dokumentatsiyasi**

- ✅ Swagger/OpenAPI 3.0 formatida
- ✅ Sandbox muhiti (test API)
- ✅ Webhook qo'llab-quvvatlash

---

## **⚡ 6. ISHLASH VA SIFAT TALABLARI**

| Ko'rsatkich | Talab | Izoh |
| --- | --- | --- |
| Yuz tanish aniqligi (FAR) | < 0.001% | Noto'g'ri qabul qilish |
| Yuz tanish aniqligi (FRR) | < 0.1% | Noto'g'ri rad etish |
| Terminal javob vaqti | < 1 soniya | To'liq siklda |
| API javob vaqti | < 200ms | 95-percentil |
| Tizim uptime | > 99.5% | Oylik |
| Bir terminalga rezidentlar | 10,000+ | Lokal saqlash |
| Bir serverga terminallar | 500+ | Markaziy boshqaruv |
| Aktiv web foydalanuvchilar | 200+ | Bir vaqtda |
| Log saqlash | 1 yil / 5 yil | Aktiv / Arxiv |
| Foto hajmi | < 200 KB | Siqilgan |
| Oflayn ishlash | 72 soat | Lokal DB bilan |

---

## **📅 7. LOYIHA BOSQICHLARI VA MUDDATLAR**

| Bosqich | Mazmun | Muddat |
| --- | --- | --- |
| 1 | Analiz va dizayn (talablar, arxitektura, UI/UX) | 2 hafta |
| 2 | Backend ishlab chiqish (API, DB, terminal protokoli) | 4 hafta |
| 3 | Terminal integratsiya (SDK, dasturiy ta'minot) | 3 hafta |
| 4 | Web panel (boshqaruv interfeysi) | 4 hafta |
| 5 | Mobil ilova (Android/iOS) | 3 hafta |
| 6 | Sinov va test (QA, xato tuzatish) | 2 hafta |
| 7 | Pilot joriy etish (bitta bino) | 2 hafta |
| 8 | To'liq ishga tushirish | 2 hafta |
| **JAMI** |  | **~22 hafta (5-6 oy)** |

---

## **🛠️ 8. TEXNIK QO'LLAB-QUVVATLASH VA KAFOLAT**

| Xizmat | Talab |
| --- | --- |
| Kafolat muddati | 12 oy |
| Qo'llab-quvvatlash | 24/7 |
| Kritik xatolar javob vaqti | 4 soat |
| Oddiy xatolar javob vaqti | 24 ish soati |
| Hisobot | Oylik (uptime, xatolar statistikasi) |
| Yangilanishlar | Xavfsizlik patchlari majburiy |
| O'qitish | Har bir rol uchun amaliy o'quv |
| Hujjatlashtirish | O'zbek tilida to'liq qo'llanma |

---

## **✅ 9. QABUL QILISH MEZONLARI**

### **9.1. Funksional Testlar**

- ✅ Barcha foydalanuvchi scenariylari muvaffaqiyatli
- ✅ 50 ta shaxs × 3 marta kirish testi → 99%+ muvaffaqiyat
- ✅ 20 ta tanilmagan shaxs testi → 100% bloklanish
- ✅ Liveness detection (foto/video aldash) → 100% bloklanish
- ✅ 72 soat oflayn rejim testi
- ✅ Sinxronizatsiya testi (voqea yo'qolmasligi)

### **9.2. Yuklanish Testlari**

- ✅ 50 ta terminal bir vaqtda
- ✅ 1 daqiqada 200 ta kirish so'rovi
- ✅ 100,000 ta rezident bilan DB ishlashi

### **9.3. Xavfsizlik Auditi**

- ✅ Penetratsion test hisoboti
- ✅ API autentifikatsiya va avtorizatsiya testlari
- ✅ Ma'lumotlar shifrlash tekshiruvi

---

## **📝 10. MENING TAKLIFLARIM (Senior Architect Sifatida)**

### **10.1. Texnologik Tanlovlar**

Backend:    PHP 8.2 + Yii2 Framework (sizning tajribangizga mos)
Database:   PostgreSQL 15+
Frontend:   React.js 18+
Mobile:     React Native
Cache:      Redis 7+
Storage:    MinIO (S3-compatible)
Real-time:  WebSocket + Redis Pub/Sub

### **10.2. Arxitektura Takomillashtirish**

- **Microservices** o'rniga **Modular Monolith** (loyiha hajmi uchun optimal)
- **Message Queue** (RabbitMQ/Redis) - voqealar uchun
- **Load Balancer** (Nginx) - yuqori yuklanish uchun
- **CI/CD** (GitHub Actions/GitLab CI) - avtomatik deploy

### **10.3. Xavfsizlik Qo'shimchalari**

- 2FA (Super Admin uchun)
- IP whitelist (GASN, Prokuratura, IIV uchun)
- Data encryption at rest (PostgreSQL TDE)
- Regular security scanning (OWASP ZAP)