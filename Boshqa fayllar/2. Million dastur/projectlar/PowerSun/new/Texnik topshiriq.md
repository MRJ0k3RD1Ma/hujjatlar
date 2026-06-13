# TEXNIK TOPSHIRIQ — POWER SUN (v2.1)
## Invertor O'rnatuvchilar uchun Mukofot Tizimi
### Telegram Bot + Boshqaruv Paneli

> **Loyiha hujjati** | 2026-yil | Versiya 2.1 (Mijoz uchun) | Maxfiy hujjat

---

## 📋 Hujjat haqida

Ushbu hujjat invertor o'rnatuvchi ustalar uchun mo'ljallangan mukofot tizimining yangilangan texnik topshirig'i hisoblanadi. Hujjatda **qo'shimcha materiallar tizimi**, **ro'yxatdan o'tishda karta ma'lumotlarining olib tashlanishi** va **balansdan pul yechib olish (Chiqim So'rovlari) moduli** to'liq aks ettirilgan. Tizim biznes jarayonlarini soddalashtirish, naqd pul oqimini nazorat qilish va shaffoflikni oshirishga yo'naltirilgan.

---

## 1. LOYIHA HAQIDA UMUMIY MA'LUMOT

### 1.1 Loyihaning maqsadi
Invertor o'rnatuvchi ustalarning bajargan ishlarini rasman hisobga olish, ular uchun **shaffof va avtomatlashtirilgan ball-to'lov tizimini** yaratish. Tizim ustalar bilan aloqa uchun Telegram botdan foydalanadi va kompaniya administratorlari uchun qulay boshqaruv paneli taqdim etadi. Pul o'tkazmalari esa yig'ilgan balans asosida maxsus so'rovlar orqali amalga oshiriladi.

### 1.2 Tizim kimlar uchun

| Rol | Vazifasi | Kirish usuli |
|-----|----------|--------------|
| **Ustalar** | Telegram bot orqali ariza yuboradi, ball yig'adi, pul yechib olish so'rovini qoldiradi | Telegram Bot |
| **Adminlar** | Arizalarni ko'rib chiqadi, tasdiqlaydi/rad etadi, chiqim so'rovlarini tekshiradi va pul o'tkazmalarini boshqaradi | Veb-panel (login + parol) |
| **Superadmin** | Barcha sozlamalarni, invertorlar/materiallar ro'yxati, ball qiymatlari va adminlar huquqlarini boshqaradi | Veb-panel (kengaytirilgan huquqlar) |

### 1.3 Tizim nima beradi?

✅ **Usta uchun:**
- 📱 Ishni Telegram orqali daqiqalarda topshirish — ofisga kelish shart emas
- 💰 Yig'ilgan ballarni istalgan vaqtda pulga aylantirib kartaga o'tkazish so'rovini qoldirish
- 🔔 Har bir ariza holati va chiqim so'rovi haqida avtomatik xabar olish
- 📊 Shaxsiy hisob: balans, yig'ilgan ballar, chiqimlar tarixi

✅ **Admin uchun:**
- 🗂️ Barcha arizalar bitta joyda — tezkor ko'rib chiqish
- 🧮 Avtomatik mukofot hisoblash (invertor + materiallar) — inson xatosi yo'q
- 💳 Chiqim so'rovlarini markazlashtirilgan boshqarish, karta tekshiruvi, tasdiqlash/rad etish
- 📈 Hisobotlar: invertorlar, materiallar, viloyatlar va chiqim dinamikasi

✅ **Kompaniya uchun:**
- 🔒 Barcha ma'lumotlar xavfsiz, har bir o'zgarish qayd etiladi
- 💵 Pul oqimini rejalashtirish: ustaning so'rovi bo'lmaguncha pul o'tkazilmaydi
- ⚙️ Moslashuvchan sozlamalar va kelajakda kengaytirish imkoniyati

---

## 2. TIZIM QANDAY ISHLAYDI

### 2.1 Umumiy jarayon (6 bosqich)
```
1️⃣ Ish bajarish
   ↓
   Usta mijoz obyektida invertor va qo'shimcha materiallarni o'rnatadi

2️⃣ Ariza yuborish (Bot)
   ↓
   Usta /new buyrug'i orqali manzil, invertor modeli, soni va 
   qo'shimcha materiallar ro'yxatini tanlab, rasm/video yuklaydi

3️⃣ Admin tekshiradi
   ↓
   Admin panelida ariza ko'rib chiqiladi:
   ✅ Tasdiqlansa → ball va summa avtomatik hisoblanib usta balansiga qo'shiladi
   ❌ Rad etilsa → majburiy sabab bilan ustaga xabar ketadi

4️⃣ Balans yig'iladi
   ↓
   Tasdiqlangan arizalar ustaga "virtual balans" sifatida yoziladi.
   Pul hali kartaga o'tkazilmaydi, faqat hisobda saqlanadi.

5️⃣ Chiqim so'rovi (/withdraw)
   ↓
   Usta istagan vaqtda yig'ilgan balansni pulga aylantirib, 
   karta raqami va egasi ismi bilan chiqim so'rovi qoldiradi

6️⃣ Admin tekshiradi va o'tkazadi
   ↓
   Admin Telegram orqali bildirishnoma oladi → 
   Karta ma'lumotlarini tekshiradi → Pulni o'tkazadi → 
   Tizimda tasdiqlaydi → Usta xabar oladi
```

---

## 3. USTA UCHUN TELEGRAM BOT

### 3.1 Bot buyruqlari
| Buyruq | Nima qiladi |
|--------|-------------|
| `/start` | Ro'yxatdan o'tish va tizimga kirish |
| `/new` | Yangi ariza yuborishni boshlash |
| `/wallet` | Joriy balans, yig'ilgan ball va aktiv chiqim so'rovlarini ko'rish |
| `/balance` | To'lovlar tarixi va yig'ilgan ballar |
| `/history` | Barcha arizalar ro'yxati va holati |
| `/set_pin` | Chiqim so'rovi uchun 4 raqamli PIN-kod o'rnatish/yangilash |
| `/reset_pin` | Unutilgan PIN-kodni admin orqali tiklash so'rovi |
| `/help` | Yordam va qo'llab-quvvatlash |

### 3.2 Ro'yxatdan o'tish — YANGILANGAN
Usta `/start` buyrug'ini yuborganda bot quyidagi ma'lumotlarni so'raydi:
1. **To'liq ism**
2. **Telefon raqami** (Telegram share yoki qo'lda)
3. **Mijoz turi** (Jismoniy / Yuridik / YATT)
4. **Yuridik nomi** (agar kerak bo'lsa)
5. **Viloyat** (ro'yxatdan tanlash)
6. **Tuman** (viloyatga mos ro'yxatdan tanlash)

> ⚠️ **Muhim o'zgarish:** Ro'yxatdan o'tishda **bank karta raqami kiritilmaydi**. Karta ma'lumotlari faqat chiqim so'rovi qoldirilganda so'raladi va tekshiriladi.

### 3.3 Yangi ariza yuborish (`/new`)
Bot har bir qadamni alohida so'raydi. Xato formatda kiritilsa ogohlantiradi.

| # | Ma'lumot | Majburiy | Izoh |
|---|----------|----------|------|
| 1 | Lokatsiya | ✅ | Matn yoki geolokatsiya |
| 2 | Obyekt manzili | ✅ | To'liq manzil |
| 3 | Obyekt turi | ✅ | Uy / Zavod / Ofis / Boshqa |
| 4 | Quvvat (kW) | ✅ | Raqam (**faqat ma'lumot uchun**) |
| 5 | Invertor modeli | ✅ | Admin ro'yxatidan tanlanadi |
| 6 | Invertor soni | ✅ | Raqam (**asosiy hisob parametri**) |
| 7 | Qo'shimcha materiallar | ✅ | Ro'yxatdan tanlash + soni kiritish. Har bir material birligi uchun ball ko'paytiriladi |
| 8 | Izoh | ❌ | Ixtiyoriy |
| 9 | Rasmlar | ✅ | Kamida 3 ta (yaqindan, o'rnatilgan holat, ulanish) |
| 10 | Video | ✅ | Maks 1 daqiqa |

### 3.4 Chiqim so'rovi qoldirish (`/withdraw`)
```
1️⃣ Bot balansni ko'rsatadi:
   "💰 Mavjud balans: {balance_som} so'm ({balance_points} ball)"

2️⃣ Summa kiritish:
   "Yechib olmoqchi bo'lgan summani kiriting (so'm):"
   → Validatsiya: min ≤ summa ≤ balans
   → "MAX" tugmasi orqali to'liq balansni yechish imkoniyati

3️⃣ Karta ma'lumotlari:
   "💳 Karta raqami (16 raqam):"
   "👤 Karta egasining ism-familiyasi:"
   → Format va karta turi (Uzcard/HUMO) avtomatik tekshiriladi

4️⃣ Tasdiqlash:
   "✅ So'rov tafsilotlari:
    Summa: {amount} so'm
    Karta: ****{last4} ({holder_name})
    Tasdiqlaysizmi? [✅ Ha] [❌ Yo'q]"

5️⃣ PIN-kod tasdiqlash (YANGI — XAVFSIZLIK):
   "🔐 So'rovni tasdiqlash uchun 4 raqamli PIN-kodingizni kiriting:"
   → Bot xabarni darhol o'chiradi (PIN ko'rinmasligi uchun)
   → bcrypt hash bilan tekshiriladi
   → Noto'g'ri bo'lsa: "❌ Noto'g'ri PIN. Qolgan urinishlar: {n}"
   → 3 marta noto'g'ri → 30 daqiqa lockout

6️⃣ Natija:
   "📤 So'rov qabul qilindi! ID: #{id}
    Adminlar ko'rib chiqquncha kuting."
```

#### 🔐 PIN-kod tizimi

- **PIN o'rnatish:** Birinchi `/withdraw` paytida yoki `/set_pin` orqali ustadan 4 raqamli PIN so'raladi (2 marta tasdiqlash uchun)
- **Saqlash:** PIN bcrypt hash bilan saqlanadi, raw ko'rinishda hech qayerda turmaydi
- **Lockout:** 3 marta noto'g'ri kiritsa, 30 daqiqaga PIN bloklanadi
- **PIN almashtirish:** `/set_pin` → eski PIN tasdiqlangach, yangi PIN o'rnatiladi
- **PIN unutilsa:** `/reset_pin` → admin panelda so'rov ko'rinadi → admin telefon orqali tasdiqlab, PIN'ni reset qiladi
- **Bot xavfsizligi:** PIN matnini o'z ichiga olgan xabar bot tomonidan **darhol o'chiriladi** (`deleteMessage`)
- **Maxsus holatlar:** Oson PIN-lar (`0000`, `1234`, `1111` kabi) qabul qilinmaydi

### 3.5 Ariza holatlari va bildirishnomalar
| Holat | Ma'nosi | Usta ko'radi |
|-------|---------|--------------|
| 🟡 Ko'rib chiqilmoqda | Tekshirilmoqda | "Arizangiz qabul qilindi..." |
| 🟢 Tasdiqlandi | Ball balansga o'tdi | "✅ Tasdiqlandi! Ball: X, Summa: Y so'm balansingizga qo'shildi." |
| 🔴 Rad etildi | Ariza rad etildi | "❌ Rad etildi. Sabab: {reason}" |
| 💵 Chiqim so'rovi ko'rib chiqilmoqda | Admin tekshirmoqda | "💵 Chiqim so'rovingiz #{id} qabul qilindi..." |
| ✅ Chiqim tasdiqlandi | Pul o'tkazildi | "🎉 {amount} so'm kartangizga o'tkazildi!" |
| ❌ Chiqim rad etildi | So'rov rad etildi | "❌ Chiqim so'rovingiz rad etildi. Sabab: {reason}" |

---

## 4. BOSHQARUV PANELI (ADMIN WEB PANEL)

### 4.1 Kirish tizimi
- Login + parol, JWT token bilan himoyalangan
- "Eslab qol" funksiyasi
- Superadmin yangi adminlar yaratadi

### 4.2 Dashboard (Bosh sahifa)
| Widget | Ma'lumot |
|--------|----------|
| 📦 Jami o'rnatilgan invertorlar | Tasdiqlangan arizalar yig'indisi |
| 🔧 Jami tanlangan materiallar | Materiallar soni va turlari |
| 🔢 Jami yig'ilgan ball | Tasdiqlangan arizalar bo'yicha |
| 💰 Jami kutilayotgan chiqimlar | `pending` holatdagi so'rovlar yig'indisi |
| 📊 Arizalar soni | Bugun / Hafta / Oy / Jami |
| 👥 Aktiv ustalar | Ariza yuborgan ustalar |
| 📈 Oylik dinamika | Invertor, material, ball va chiqim grafikasi |

### 4.3 Arizalarni boshqarish
- Jadval: ID \| Usta \| Invertor \| Soni \| Materiallar \| Ball \| Summa \| Holat \| Sana \| Amal
- Filtrlar: Status, sana, invertor modeli, material turi, usta, viloyat/tuman
- Eksport: Excel / CSV
- Tafsilot: Rasmlar, video, ball hisoblash tafsiloti, status tarixi (timeline)

**Amallar:**
- ✅ **Tasdiqlash** → Ball balansga qo'shiladi
- ❌ **Rad etish** → Majburiy sabab (10–1000 belgi)
- 📝 **Qayta ko'rish** (ixtiyoriy) → Rad etilgan arizani qayta pending ga o'tkazish

### 4.4 Chiqim So'rovlari bo'limi (YANGI)
- Jadval: ID \| Usta \| Ball \| Summa (so'm) \| Karta **** \| Holat \| Sana \| Amal
- Filtrlar: Status, sana, usta, summa diapazoni
- **Tafsilot sahifasi:**
  ```
  📋 So'rov #12345
  Usta: Ismoilov A. (+998901234567)
  Ball: 240 → 1 200 000 so'm
  Karta: **** 4567 (Abdulloh Ismoilov)
  Holat: pending
  Sana: 2026-01-15 14:30

  [🟢 Tasdiqlash]  [🔴 Rad etish]
  ```
- **Karta tekshiruv interfeysi:** Admin karta raqami va egasi ismini kiritadi → Tizim formatni (Luhn), karta turini (Uzcard/HUMO) tekshiradi → Admin pulni o'tkazgach "To'lov amalga oshirildi" tugmasini bosadi.
- **Rad etish:** Majburiy sabab (10–500 belgi), ustaga avtomatik xabar ketadi.

### 4.5 Invertorlar va Materiallar bo'limi
- **Invertorlar:** CRUD, 1 dona uchun ball, faol/nofaol
- **Qo'shimcha materiallar:** CRUD, o'lchov birligi (metr/dona/to'plam), 1 birlik uchun ball, faol/nofaol
- Har ikkala ro'yxat botda inline tugmalar orqali ko'rsatiladi

### 4.6 Sozlamalar
- 1 ball uchun to'lanadigan summa (so'm)
- Minimal chiqim limiti (masalan: 50 000 so'm)
- Minimal/maksimal kW limitlari (faqat validatsiya)
- Kunlik ariza limiti
- Admin paroli, yangi admin qo'shish

### 4.7 Loglar va audit
- Barcha admin harakatlari, status o'zgarishlari, chiqim so'rovlari holatlari
- Karta tekshiruv natijalari va to'lov tasdiqlash vaqtlari
- O'chirilmaydigan audit yozuvlari

---

## 5. MUKOFOT HISOBLOV TIZIMI

### 5.1 Asosiy formula
```
📐 Invertor balli = Invertor birligi balli × Invertor soni
🔧 Material balli = Σ(Material birligi balli × Tanlangan soni)
🎯 Jami ariza balli = Invertor balli + Material balli
💰 Ariza summasi (so'm) = Jami ariza balli × 1 ball qiymati (so'm)
```

> 🔴 **Muhim:** `kW` (quvvat) maydoni hisoblashga **hech qanday ta'sir qilmaydi**. `kW` faqat ma'lumot va fraud-oldini olish chegaralari uchun ishlatiladi.

### 5.2 Amaliy misol
| Parametr | Qiymat |
|----------|--------|
| Invertor: Deye SUN-12K | 120 ball/dona × 2 = **240 ball** |
| Material: Kabel | 2 ball/m × 15m = **30 ball** |
| Material: Montaj to'plami | 5 ball/to'plam × 3 = **15 ball** |
| **Jami ball** | **285 ball** |
| 1 ball qiymati | 5 000 so'm |
| **Ariza summasi** | **1 425 000 so'm** |

### 5.3 Snapshot qoidasi
> ⚠️ Ariza yuborilgan paytdagi ball va 1 ball qiymati arizaga biriktiriladi. Keyinchalik sozlamalar o'zgarsa ham **oldingi arizalar hisobi o'zgarmaydi**. Bu adolatlilik kafolatidir.

---

## 6. BALANS VA CHIQIM SO'ROVLARI TIZIMI

### 6.1 Balans qanday shakllanadi?
```
Mavjud balans (so'm) = 
  Σ(Tasdiqlangan arizalar summasi) 
  − Σ(Tasdiqlangan chiqim so'rovlari summasi)
```
Balans har safar dinamik hisoblanadi. Hech qanday ustun qo'lda o'zgartirilmaydi.

### 6.2 Chiqim so'rovi oqimi
1. Usta `/withdraw` orqali so'rov qoldiradi
2. Tizim admin guruhiga/kanaliga avtomatik xabar yuboradi:
   ```
   🆕 YANGI CHIQIM SO'ROVI
   👤 Usta: {name} ({phone})
   💰 Summa: {amount} so'm ({points} ball)
   💳 Karta: ****{last4} ({holder})
   [✅ Tasdiqlash] [❌ Rad etish]
   ```
3. Admin inline tugma orqam yoki admin panel orqali tekshiradi
4. Haqiqiy pul o'tkazmasi amalga oshirilgach, admin "To'lov yakunlandi" ni bosadi
5. Usta balansdan summa yechiladi va `paid` statusi beriladi
6. Xavfsizlik: Karta raqami faqat oxirgi 4 ta raqam ko'rinishida saqlanadi

### 6.3 To'lov kim amalga oshiradi?
> 💡 Pulni haqiqiy o'tkazishni kompaniya moliya xodimi amalga oshiradi (bank ilovasi, Uzcard/HUMO yoki boshqa usul). Ushbu tizim faqat **so'rovni qabul qilish, karta ma'lumotlarini validatsiya qilish, hisobdan yechish va ogohlantirish** uchun xizmat qiladi.

---

## 7. XAVFSIZLIK

### 7.1 Ma'lumotlar himoyasi
- 🔐 Barcha aloqalar HTTPS orqali shifrlangan
- 🔑 Parollar bcrypt bilan shifrlangan
- 🛡️ DB kirish cheklangan, faqat maxsus huquqlar
- 💳 Karta raqamlari faqat `****1234` formatida loglanadi (PCI DSS standartlariga yaqin)

### 7.2 Firibgarlikdan himoya
- Kunlik ariza limiti (sozlamadan boshqariladi)
- kW chegaralari faqat validatsiya uchun
- Rasmsiz ariza qabul qilinmaydi
- Invertor va materiallar faqat tasdiqlangan ro'yxatdan tanlanadi
- Karta formati va Luhn algoritmi majburiy tekshiriladi
- Bloklangan ustalar bot bilan ishlamaydi
- 🔐 **Chiqim so'rovi PIN-kod bilan tasdiqlanadi** — Telegram akkaunti o'g'irlangan taqdirda ham pul yechishning oldi olinadi

### 7.3 Audit va shaffoflik
- Har bir admin harakati, status o'zgarishi va chiqim so'rovi qayd etiladi
- Tarix hech qachon o'chirilmaydi
- Superadmin istalgan vaqtda tekshiruv o'tkazishi mumkin

---

## 8. LOYIHA BOSQICHLARI VA MUDDATI

Loyiha **30 ish kuni** ichida topshiriladi.

| Bosqich | Muddat | Natija |
|---------|--------|--------|
| 1. Tayyorgarlik | 1–3 kun | Server, DB, Yii2 asosi, webhook, region/district ma'lumotlari |
| 2. Telegram bot | 4–10 kun | Ro'yxat, ariza+material tanlash, `/withdraw` flow, bildirishnomalar |
| 3. Backend mantiq | 11–17 kun | Ball hisoblash, balans logikasi, chiqim so'rovlari API, karta validatsiya |
| 4. Admin panel | 18–26 kun | Dashboard, arizalar, chiqim so'rovlari sahifasi, invertor/material CRUD, loglar |
| 5. Test & Deploy | 27–30 kun | Integratsion test, xavfsizlik tekshiruvi, server joylash, qo'llanmalar |

---

## 9. NARX VA TO'LOV SHARTLARI

### 9.1 Loyiha narxi
| Moduli | Narx (USD) |
|--------|------------|
| Backend tizim — bot, balans, chiqim so'rovlari, validatsiya | $300 |
| Telegram bot — material tanlash, `/withdraw` flow, inline tugmalar | $150 |
| Admin Panel — chiqim so'rovlari, karta tekshiruv UI, materiallar CRUD | $230 |
| Ma'lumotlar bazasi tuzilmasi va migratsiya | $50 |
| Deploy, sozlash, test, monitoring | $70 |
| **JAMI** | **$800** |


### 9.2 Narxga kiradigan xizmatlar
✅ Barcha funksional imkoniyatlar (yuqorida batafsil)  
✅ Test qilish va xatolarni tuzatish  
✅ Serverga joylashtirish va ishga tushirish  
✅ Admin va usta qo'llanmalari  
✅ 14 kun kafolat (xatolarni bepul tuzatish)  

### 9.3 Narxga kirmaydigan xizmatlar
❌ Server ijarasi, domen, SSL, Cloudinary (bepul tier mavjud)  
❌ Telegram bot tokeni (mijoz o'zi yaratadi, bepul)  
❌ Bank API integratsiyasi (ixtiyoriy, keyingi bosqichda)  
❌ 14 kundan keyingi yangi funksiyalar (alohida kelishiladi)  

---

## 10. MIJOZ TOMONIDAN TA'MINLANISHI KERAK

### 10.1 Loyiha boshida
1. Server VPS va domen
2. Telegram bot tokeni
3. Invertorlar ro'yxati + 1 dona uchun ball
4. **Qo'shimcha materiallar ro'yxati** + 1 birlik uchun ball + o'lchov birligi
5. 1 ball uchun so'mda qiymat
6. Minimal chiqim limiti (masalan: 50 000 so'm)
7. Admin login va ismlari

### 10.2 Loyiha davomida
1. Oraliq natijalarni ko'rib chiqish (har bosqichda)
2. Savollarga tezkor javob (24 soat ichida)
3. Test uchun 2-3 sinov ustasi

---

## 11. YAKUNIY NATIJA VA QABUL QILISH

### 11.1 Mijoz nimani oladi?
1. ✅ To'liq ishlaydigan Telegram bot
2. ✅ Veb-boshqaruv paneli (mijoz domeni orqali)
3. ✅ Serverga joylashtirilgan tizim
4. ✅ Admin va usta qo'llanmalari
5. ✅ Superadmin kirish ma'lumotlari
6. ✅ Loyiha manba kodi (talab bo'yicha)


### 11.2 Kafolat
- 🛡️ 14 kun bepul xato tuzatish
- 🔄 Yangi funksiyalar alohida kelishiladi
- 🌐 Kelajakda kengaytirish: Bank API, reyting tizimi, ko'p tillilik, mobil ilova
