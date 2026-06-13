# Milliy Universiteti — Davomat Tizimi
## FaceID asosidagi avtomatik davomat va monitoring platformasi

---

## Muammo: Hozirgi holat

- Davomat qog'oz yoki qo'lda kiritish orqali olinadi
- Soxtalashtirish va xatolar yuqori
- Real vaqtda kim qayerdaligini bilish imkonsiz
- Hisobotlar tayyorlash ko'p vaqt talab qiladi
- HEMIS bilan integratsiya yo'q — ma'lumotlar ikki joyda alohida saqlanadi

---

## Yechim: Avtomatik FaceID Tizimi

Binolar kirishiga o'rnatilgan **Hikvision FaceID qurilmalar** yuzni taniydi va davomat avtomatik yoziladi

- ✅ Qo'lda kiritish talab qilinmaydi
- ✅ Real vaqtda monitoring
- ✅ HEMIS bilan to'liq integratsiya
- ✅ Hisobotlar bir tugmada

---

## Tizim Arxitekturasi

```
HEMIS (talaba, o'qituvchi, xodim ma'lumotlari)
          ↓ Kunlik sync
    NestJS Backend  ←──── FaceID Qurilmalar
    (asosiy server)         (binolarda)
          ↓
    React Admin Panel
    (brauzer orqali)
          ↕
    ISUP Server (ASP.NET)
    (qurilmalarni boshqarish)
```

**4 ta asosiy komponent:**
NestJS · PostgreSQL · ISUP Server · React Panel

---

## FaceID Qurilma Qanday Ishlaydi

1. **Odam binoga kiradi** → qurilma yuzini skanerlaydi
2. **0.3 soniyada** yuzni taniydi (97%+ aniqlik)
3. **Avtomatik signal** → NestJS serveriga yuboriladi
4. **Davomat yoziladi** → kirish vaqti, bino, qurilma
5. **Admin panelda** real vaqtda ko'rinadi

> Qurilma har 60 soniyada server bilan aloqasini tekshiradi — offline bo'lsa admin bildirishnoma oladi

---

## HEMIS Integratsiyasi

Barcha talaba, o'qituvchi va xodim ma'lumotlari HEMIS tizimidan avtomatik olinadi

| Nima olinadi | Qachon |
|---|---|
| Talabalar ro'yxati | Har kuni 02:00 |
| O'qituvchilar | Har kuni 02:00 |
| Xodimlar | Har kuni 02:00 |
| Dars jadvali | Har kuni 02:00 |

**Delta-sync:** HEMIS dan o'chirilgan shaxs → tizimda avtomatik noaktiv + qurilmadan yuz o'chiriladi

---

## Ish Grafigi Turlari

### O'qituvchilar
- **Jadval asosida** — faqat dars vaqtida hisob yuritiladi
- **Soatbay** — belgilangan ish soatlari

### Xodimlar
- **Standart** — kunlik ish vaqti shabloni
- **Qoravullar** — 4 kunlik tsikl, 24 soatlik smena (tungi smenalar to'g'ri hisoblanadi)

### Talabalar
- Dars jadvaliga ko'ra davomat

---

## Davomat Avtomatik Hisoblanadi

Har kuni soat **04:00** da barcha davomat yozuvlari tahlil qilinadi:

| Holat | Qoida |
|---|---|
| ✅ Keldi | Vaqtida kirgan, vaqtida ketgan |
| ⏰ Kechikkan | Belgilangan vaqtdan keyin kirgan |
| 🚪 Erta ketgan | Belgilangan vaqtdan oldin chiqqan |
| ❌ Kelmadi | Kirish hodisasi yo'q |
| 📋 Ruxsatli | Admin tomonidan qo'lda kiritilgan |
| 🎉 Bayram | Bayram kunlari avtomatik aniqlanadi |

---

## Admin Panel Imkoniyatlari

### Real vaqtda monitoring
- Hozir qaysi binoda necha kishi bor
- Oxirgi kirish/chiqishlar jonli oqim
- Qurilmalar online/offline holati

### Tarix va hisobotlar
- Davomat jadvali (sana, bino, rol bo'yicha filter)
- Ishlagan soatlar hisoboti
- Kechikishlar statistikasi
- Excel va PDF export

---

## Foydalanuvchilar va Rollar

| Rol | Imkoniyatlar |
|---|---|
| **Super Admin** | Hamma narsa |
| **HR Menejer** | Ko'rish, davomat, hisobot, HEMIS sync |
| **Operator** | Ko'rish, qo'lda davomat, export |
| **Xavfsizlik** | Ko'rish, eshik ochish |

**Eshik ochish:** Qurilmaga ulanib, bir tugma bilan eshikni masofadan ochish imkoni

---

## Texnologiyalar

| Qatlam | Texnologiya |
|---|---|
| Backend | NestJS (Node.js) + PostgreSQL |
| FaceID server | ASP.NET 8.0 + MySQL |
| FaceID SDK | Hikvision ISUP 5.0 |
| Frontend | React.js + Tailwind CSS |
| Queue | Bull + Redis |
| Deploy | Docker + Docker Compose |

**Platforma:** Ubuntu 22.04 Linux server

---

## Xavfsizlik

- JWT token autentifikatsiya (15 daqiqa + refresh)
- Har bir FaceID qurilmaga alohida token
- Barcha amallar audit logga yoziladi (kim, qachon, nima qildi)
- Yuz rasmlari **30 kun** saqlanadi, keyin avtomatik o'chiriladi
- Export hisobotlarida biometrik ma'lumotlar yo'q

---

## Natija

**Milliy Universiteti uchun:**

- ⏱ Davomat olish vaqti: **daqiqalardan → 0 ga**
- 📊 Real vaqtda 5,000+ talaba/o'qituvchi/xodim monitoringi
- 🔄 HEMIS bilan to'liq integratsiya — ikki tomonlama ish yo'q
- 📈 Har qanday kesimda bir daqiqada hisobot
- 🏢 Barcha binolar bitta panelda

---

## Loyiha Tarkibi

| Komponent | Texnologiya | Holat |
|---|---|---|
| NestJS Backend | TypeScript + PostgreSQL | Loyihalash |
| ISUP Server | ASP.NET 8.0 | Loyihalash |
| Admin Panel | React.js | Loyihalash |
| FaceID Qurilmalar | Hikvision DS-K1T671 | Mavjud |
| HEMIS Integratsiya | REST API | Kelishilgan |
