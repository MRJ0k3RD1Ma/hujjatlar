# 09 — TELEGRAM BOT BUYRUQLARI VA DIALOG OQIMI

> Har bir bot buyrug'i va dialog qadamlarining to'liq scenariysi.
> **Dialog state** Redis'da saqlanadi: `bot:state:{telegram_id}` — TTL 24 soat.

---

## 0. UMUMIY KONVENTSIYALAR

### Reply ↔ Inline klaviatura tanlash
- **Reply keyboard** — telefon raqam, geolokatsiya kabi tezkor input uchun
- **Inline keyboard** — tasdiqlash, ro'yxatdan tanlash, navigatsiya uchun

### Dialog state Redis schema
```json
{
  "step": "app_inverter_select",
  "data": {
    "address": "Toshkent sh., Yunusobod...",
    "object_type": "house",
    "kw": 12,
    "inverter_id": null
  },
  "started_at": 1735689600,
  "expires_at": 1735776000
}
```

### Universal tugmalar
- ❌ **Bekor qilish** — `callback_data: cancel` → Redis state DEL
- ⬅️ **Orqaga** — `callback_data: back` → oldingi qadamga
- ⏭️ **O'tkazib yuborish** — `callback_data: skip` (faqat ixtiyoriy maydonlarda)

---

## 1. `/start` — RO'YXATDAN O'TISH

### Flow diagrammasi
```
/start
   ↓
Foydalanuvchi DB da bormi? — HA → "Salom, {name}! Asosiy menyu:" + main_menu
   ↓ YO'Q
"👋 Power Sun bot'iga xush kelibsiz!"
   ↓
Step 1: To'liq ism kiritish
   ↓
Step 2: Telefon raqam (📱 Telefonni ulashish tugmasi)
   ↓
Step 3: Mijoz turi (Inline: Jismoniy / Yuridik / YATT)
   ↓
Step 4: Yuridik nomi (faqat Yuridik/YATT bo'lsa, aks holda skip)
   ↓
Step 5: Viloyat (Inline list, public API: GET /api/v1/regions)
   ↓
Step 6: Tuman (Inline list, GET /api/v1/regions/{id}/districts)
   ↓
DB ga yozish: users.create()
   ↓
"✅ Ro'yxatdan o'tdingiz! Endi /new orqali ariza yuborishingiz mumkin"
```

### Step xabarlari

#### Step 1: Ism
```
👋 Power Sun bot'iga xush kelibsiz!

Iltimos, to'liq ism va familiyangizni yuboring:
(masalan: Ismoilov Abdulloh)
```
Validation: 3–100 belgi, faqat harflar va probel.

#### Step 2: Telefon
```
📞 Telefon raqamingizni yuboring:
[📱 Telefonni ulashish] (reply button, request_contact: true)

yoki qo'lda kiriting: +998901234567
```
Validation: `/^\+998\d{9}$/` regex.

#### Step 3: Mijoz turi
```
👤 Mijoz turingizni tanlang:

[👤 Jismoniy shaxs]   (callback: type:individual)
[🏢 Yuridik shaxs]    (callback: type:legal)
[💼 YATT]              (callback: type:sole_proprietor)
```

#### Step 4: Yuridik nomi (shartli)
```
🏢 Yuridik shaxs nomini yuboring:
(masalan: "Power Sun" MChJ)
```
Faqat `legal` yoki `sole_proprietor` tanlangan bo'lsa.

#### Step 5: Viloyat
```
🌍 Viloyatingizni tanlang:

[Toshkent shahri]      (callback: region:1)
[Toshkent viloyati]    (callback: region:2)
[Andijon viloyati]     (callback: region:3)
...
```

#### Step 6: Tuman
```
🏘️ Tumaningizni tanlang:

[Yunusobod]            (callback: district:5)
[Mirzo Ulug'bek]       (callback: district:6)
...
[⬅️ Orqaga]            (callback: back)
```

#### Yakuniy
```
✅ Tabriklaymiz, ro'yxatdan o'tdingiz!

👤 Ism: Ismoilov Abdulloh
📞 Telefon: +998901234567
🏘️ Viloyat: Toshkent shahri
🏘️ Tuman: Yunusobod

Endi /new buyrug'i orqali yangi ariza yuborishingiz mumkin.
```

### Bot ↔ Backend so'rovlari
| Qadam | Backend so'rov |
|-------|---------------|
| Telegram ID tekshirish | `SELECT * FROM users WHERE telegram_id = ?` |
| Viloyat ro'yxati | `GET /api/v1/regions` (yoki to'g'ridan-to'g'ri DB) |
| Tuman ro'yxati | `GET /api/v1/regions/{id}/districts` |
| Foydalanuvchi yaratish | `INSERT INTO users (...)` |

---

## 2. `/new` — YANGI ARIZA YUBORISH

### Flow
```
/new
   ↓
Bloklangan? → "❌ Akkauntingiz bloklangan" → STOP
   ↓
Bugungi ariza limit > max_daily_apps? → "⚠️ Bugun {N} ta ariza yubordingiz, limit tugadi" → STOP
   ↓
Step 1: Lokatsiya (matn yoki geo)
Step 2: Manzil (matn)
Step 3: Obyekt turi (inline)
Step 4: Quvvat (raqam)
Step 5: Invertor model (inline list)
Step 6: Invertor soni (raqam)
Step 7: Material qo'shish (inline: Ha/Yo'q)
   ↓ Ha → Material loop:
       Material tanlash (inline) → Miqdor (raqam) → Yana qo'shish? (Ha/Yo'q)
Step 8: Izoh (matn yoki skip)
Step 9: Rasmlar yuklash (kamida 3 ta)
Step 10: Video (1 daqiqagacha)
   ↓
Confirm screen + tugma "✅ Yuborish"
   ↓
DB: installations.create() + photos + materials
   ↓
"✅ Arizangiz qabul qilindi! ID: #1234"
```

### Step xabarlari

#### Step 1: Lokatsiya
```
📍 Lokatsiyani yuboring:
- Geolokatsiya: [📍 Lokatsiya yuborish] (reply, request_location: true)
- Yoki matn ko'rinishida: "Toshkent sh., Yunusobod"

[❌ Bekor qilish]
```

#### Step 2: Manzil
```
🏠 Obyekt to'liq manzilini yuboring:
(masalan: Bog'ishamol ko'chasi 12-uy, kv. 5)
```

#### Step 3: Obyekt turi
```
🏗️ Obyekt turini tanlang:

[🏠 Uy]        (callback: obj:house)
[🏭 Zavod]     (callback: obj:factory)
[🏢 Ofis]      (callback: obj:office)
[📦 Boshqa]    (callback: obj:other)
```

#### Step 4: Quvvat
```
⚡ Quvvatni kiriting (kW):
(masalan: 12 yoki 12.5)

ℹ️ Eslatma: Quvvat hisoblashga ta'sir qilmaydi, faqat ma'lumot uchun
```
Validation: `min_kw ≤ X ≤ max_kw`.

#### Step 5: Invertor
```
🔌 Invertor modelini tanlang:

[Deye SUN-12K — 120 ball/dona]      (callback: inv:5)
[Huawei SUN2000-10K — 100 ball/dona] (callback: inv:8)
[Sungrow SG10K — 110 ball/dona]      (callback: inv:12)
...
[⬅️ Orqaga] [❌ Bekor qilish]
```

#### Step 6: Invertor soni
```
🔢 Necha dona invertor o'rnatdingiz?
(raqam kiriting, masalan: 2)
```
Validation: 1–100.

#### Step 7: Material qo'shish (loop)
```
🔧 Qo'shimcha material qo'shasizmi?

[✅ Ha, qo'shaman]   (callback: mat:add)
[➡️ Yo'q, davom]    (callback: mat:skip)
```

##### Material tanlash:
```
📦 Materialni tanlang:

[Kabel 4mm² — 2 ball/m]              (callback: matsel:1)
[Montaj to'plami — 5 ball/to'plam]   (callback: matsel:2)
[Akkumulyator BAT-100 — 50 ball/dona] (callback: matsel:3)
...
[⬅️ Orqaga]
```

##### Miqdor:
```
📏 Necha {unit} o'rnatdingiz?

Masalan: 15 (metr uchun) yoki 3 (dona/to'plam)
```
Validation: > 0, ≤ 10000.

##### Yana qo'shish:
```
✅ Qo'shildi: Kabel 4mm² — 15 m (30 ball)

Yana material qo'shasizmi?
[➕ Ha]       (callback: mat:add)
[✅ Tayyor]   (callback: mat:done)
```

#### Step 8: Izoh
```
💬 Qo'shimcha izoh (ixtiyoriy):
Yozing yoki [⏭️ O'tkazib yuborish] (callback: skip)
```

#### Step 9: Rasmlar
```
📸 Kamida 3 ta rasm yuboring:
1️⃣ Invertor yaqindan
2️⃣ O'rnatilgan holat
3️⃣ Kabel ulanishi
(qo'shimcha rasmlar ham yuborishingiz mumkin)

Yuklangan rasmlar: 0/3

[✅ Tayyor — keyingi qadam]   (faqat 3+ rasm bo'lganda)
[❌ Bekor qilish]
```

Har rasm yuborilganda:
```
✅ Rasm qabul qilindi (2/3)
```

#### Step 10: Video
```
🎥 Video yuboring (1 daqiqagacha):
- Maks. 60 sekund
- Maks. 50 MB
```

#### Confirm screen
```
📋 ARIZA TASDIQLASH

📍 Manzil: Bog'ishamol 12, Yunusobod
🏠 Obyekt: Uy
⚡ Quvvat: 12 kW

🔌 Invertor: Deye SUN-12K × 2 = 240 ball
🔧 Materiallar:
   - Kabel 4mm² × 15 m = 30 ball
   - Montaj to'plami × 3 = 15 ball

🎯 JAMI: 285 ball
💰 Summa: 1 425 000 so'm

📸 Rasmlar: 4 ta
🎥 Video: 45 sek

[✅ Yuborish]   (callback: app:confirm)
[❌ Bekor]      (callback: app:cancel)
```

#### Yakuniy javob
```
✅ Arizangiz qabul qilindi!

🆔 ID: #1234
🎯 Ball: 285
💰 Summa: 1 425 000 so'm
🟡 Holat: Ko'rib chiqilmoqda

Adminlar tekshirib, sizga xabar yuborishadi.
```

---

## 3. `/wallet` — BALANS

### Response
```
💰 SIZNING HISOBINGIZ

✅ Mavjud balans: 2 650 000 so'm (530 ball)

📊 Statistika:
- Jami yig'ilgan: 8 950 000 so'm
- Jami chiqarilgan: 6 300 000 so'm

⏳ Aktiv chiqim so'rovlari: 1 ta (1 200 000 so'm)

[💵 Pul yechib olish]   (callback: cmd:withdraw)
[📋 Tarix]              (callback: cmd:history)
```

---

## 4. `/balance` — BALANS TARIXI (qisqartirilgan)

```
📜 SO'NGI 10 TA HARAKAT

✅ +1 425 000 so'm — Ariza #1234 tasdiqlandi (18.04.2026)
❌ -1 200 000 so'm — Chiqim #567 to'landi (15.04.2026)
✅ +750 000 so'm — Ariza #1230 tasdiqlandi (12.04.2026)
...

[📄 To'liq tarix (web)]  (URL: https://admin.powersun.uz/users/15/balance)
```

---

## 5. `/history` — ARIZALAR TARIXI

### Birinchi xabar
```
📋 SIZNING ARIZALARINGIZ (oxirgi 10 ta)

🟢 #1234 — Deye SUN-12K × 2 — 1 425 000 so'm — Tasdiqlandi (18.04)
🟡 #1230 — Huawei × 1 — 500 000 so'm — Ko'rib chiqilmoqda (17.04)
🔴 #1225 — Deye × 1 — Rad etildi (15.04)
...

[📊 Filtr]  (callback: hist:filter)
[➡️ Keyingi sahifa]  (callback: hist:next:2)
```

### Ariza tafsiloti (callback `hist:view:1234`)
```
📋 ARIZA #1234

📍 Manzil: Bog'ishamol 12
🔌 Invertor: Deye SUN-12K × 2
🔧 Materiallar: Kabel 15m, Montaj × 3
🎯 285 ball = 1 425 000 so'm
🟢 Tasdiqlandi: 18.04.2026 13:30

[⬅️ Orqaga]
```

---

## 6. `/withdraw` — CHIQIM SO'ROVI (PIN bilan)

### Flow
```
/withdraw
   ↓
PIN o'rnatilganmi? — YO'Q → /set_pin flow'ga yo'naltirish
   ↓ HA
Balans yetarlimi? (≥ min_withdrawal_som) — YO'Q → "Min: 50 000 so'm" → STOP
   ↓ HA
Step 1: Summa kiritish (yoki MAX tugmasi)
Step 2: Karta raqami (16 raqam)
Step 3: Karta egasi ismi
Step 4: Vizual tasdiqlash
Step 5: PIN-kod
   ↓ noto'g'ri → 3 urinish → 30 daq lockout
   ↓ to'g'ri
Bot deleteMessage(PIN)
DB: withdrawal_requests.create()
   ↓
"✅ So'rov qabul qilindi #567"
```

### Step xabarlari

#### Step 1: Summa
```
💰 BALANS: 2 650 000 so'm

Yechib olmoqchi summani kiriting (so'm):
Min: 50 000 so'm

[💯 MAX (2 650 000)]   (callback: amt:max)
[❌ Bekor]
```

#### Step 2: Karta raqami
```
💳 Karta raqamini kiriting (16 raqam):

Qo'llab-quvvatlanadi: Uzcard, HUMO, Visa, Mastercard

⚠️ Karta ma'lumotlari faqat to'lov uchun ishlatiladi va xavfsiz saqlanadi
```
Validation: 16 raqam, Luhn algoritmi, BIN [8600/9860/4/5].

Xato javob:
```
❌ Karta raqami noto'g'ri.
- Format: 16 raqam (probelsiz)
- Faqat Uzcard (8600), HUMO (9860), Visa (4...), Mastercard (5...) qabul qilinadi

Qaytadan kiriting:
```

#### Step 3: Karta egasi ismi
```
👤 Karta egasining ism-familiyasini lotin harflarida kiriting:
(masalan: ABDULLOH ISMOILOV)
```
Validation: 3–255 belgi.

#### Step 4: Vizual tasdiqlash
```
✅ SO'ROV TASDIQLANISHI

💰 Summa: 1 200 000 so'm (240 ball)
💳 Karta: 8600 **** **** 4567
👤 Karta egasi: ABDULLOH ISMOILOV

Hammasi to'g'rimi?

[✅ Ha, davom]   (callback: wd:confirm)
[❌ Bekor]       (callback: cancel)
```

#### Step 5: PIN
```
🔐 So'rovni tasdiqlash uchun 4 raqamli PIN-kodingizni kiriting:

⚠️ Xavfsizlik uchun bot xabaringizni darhol o'chiradi
```

PIN qabul qilingach **darhol** `deleteMessage` chaqiriladi.

#### PIN noto'g'ri:
```
❌ Noto'g'ri PIN-kod
Qolgan urinishlar: 2

Qaytadan kiriting:
```

#### PIN bloklandi:
```
🚫 PIN-kod 3 marta noto'g'ri kiritildi.
30 daqiqaga bloklandi.

Yordam kerak bo'lsa /reset_pin orqali admin bilan bog'laning.
```

#### Yakuniy
```
✅ CHIQIM SO'ROVI QABUL QILINDI!

🆔 ID: #567
💰 Summa: 1 200 000 so'm
💳 Karta: 8600 **** **** 4567
🟡 Holat: Ko'rib chiqilmoqda

Adminlar tasdiqlagach, pul kartangizga o'tkaziladi.
Tahminiy vaqt: 24-48 soat
```

### Bot ↔ Backend
| Qadam | Backend so'rov |
|-------|---------------|
| Balans | `GET /api/v1/bot/balance?telegram_id=X` |
| Karta validatsiya | Local Luhn + BIN check |
| PIN tasdiqlash + so'rov yaratish | `POST /api/v1/bot/withdraw` (atomik) |

---

## 7. `/set_pin` — PIN O'RNATISH/YANGILASH

### Birinchi marta o'rnatish
```
/set_pin
   ↓
PIN bormi? YO'Q → birinchi PIN flow
   ↓
"🔐 4 raqamli yangi PIN kiriting:"
   ↓ deleteMessage
"🔐 Tasdiqlash uchun PIN'ni qaytadan kiriting:"
   ↓ deleteMessage
PIN'lar mos? + Weak PIN tekshiruv
   ↓
DB: users.pin_hash = bcrypt(pin)
   ↓
"✅ PIN muvaffaqiyatli o'rnatildi. Endi /withdraw ishlatishingiz mumkin"
```

### Yangilash
```
/set_pin
   ↓
PIN bormi? HA → almashtirish flow
   ↓
"🔐 Joriy PIN'ni kiriting:" (deleteMessage)
   ↓ verify
"🔐 Yangi PIN'ni kiriting:" (deleteMessage)
   ↓
"🔐 Yangi PIN'ni qaytadan kiriting:" (deleteMessage)
   ↓
"✅ PIN muvaffaqiyatli yangilandi"
```

### Weak PIN xato:
```
❌ Bu PIN juda oson (masalan: 1234, 0000, 1111).
Boshqa kombinatsiya tanlang:
```

### Backend
- `POST /api/v1/bot/pin/set` — eski PIN bilan yoki bo'sh (birinchi marta)

---

## 8. `/reset_pin` — PIN UNUTILGAN

### Flow
```
/reset_pin
   ↓
"❓ PIN-kodni unutdingizmi?
Admin sizga aloqaga chiqishi uchun bog'lanish ma'lumotlaringizni tasdiqlang:

📞 +998901234567
👤 Ismoilov Abdulloh

Tasdiqlaysizmi?

[✅ Ha]   (callback: pinrst:confirm)
[❌ Yo'q] (callback: cancel)"
   ↓
DB: PIN reset request yaratish + admin'ga notification
   ↓
"✅ So'rov qabul qilindi.

📞 Admin tez orada (24 soat ichida) sizga qo'ng'iroq qiladi.
Shaxsingiz tasdiqlangach, PIN reset qilinadi va siz keyingi /withdraw paytida yangi PIN o'rnatasiz."
```

### Backend
- `POST /api/v1/bot/pin/reset-request` — admin panel'da pending so'rov ko'rinadi

### Admin PIN reset qilgach:
```
🔐 Sizning PIN-kodingiz admin tomonidan reset qilindi.
Keyingi /withdraw paytida yangi PIN o'rnatasiz.

Yordam: /help
```

---

## 9. `/help` — YORDAM

```
ℹ️ POWER SUN BOT — YORDAM

📌 Buyruqlar:
/start - Ro'yxatdan o'tish / asosiy menyu
/new - Yangi ariza yuborish
/wallet - Balans va statistika
/balance - Balans tarixi
/history - Arizalarim tarixi
/withdraw - Pul yechib olish
/set_pin - PIN-kod o'rnatish/yangilash
/reset_pin - Unutilgan PIN'ni reset qilish
/help - Bu yordam

📞 Qo'llab-quvvatlash:
+998 (XX) XXX-XX-XX
support@powersun.uz

📚 Qo'llanma:
[📖 To'liq qo'llanma]  (URL)
```

---

## 10. STATUS BILDIRISHNOMALARI (Bot → Usta)

Backend status o'zgarganda quyidagi xabarlarni avtomatik yuboradi:

### 10.1 Ariza tasdiqlandi
```
✅ ARIZA TASDIQLANDI #1234

🎯 Ball: 285
💰 Summa: 1 425 000 so'm

✨ Sizning balansingizga qo'shildi.
Joriy balans: 2 650 000 so'm

[💵 Pul yechib olish]  (callback: cmd:withdraw)
[📋 Ariza tafsiloti]   (callback: hist:view:1234)
```

### 10.2 Ariza rad etildi
```
❌ ARIZA RAD ETILDI #1234

📝 Sabab: Rasmlar sifatsiz. Iltimos, qaytadan yuboring va aniq ko'rsating

Qayta ariza yuborish: /new
```

### 10.3 Chiqim so'rovi tasdiqlandi (admin tomonidan)
```
💵 CHIQIM SO'ROVI TASDIQLANDI #567

💰 Summa: 1 200 000 so'm
💳 Karta: 8600 **** **** 4567

⏳ Pul kartangizga 24 soat ichida o'tkaziladi
```

### 10.4 Pul kartangizga o'tkazildi
```
🎉 TO'LOV YAKUNLANDI #567

💰 1 200 000 so'm kartangizga o'tkazildi!
💳 Karta: 8600 **** **** 4567

✅ Joriy balans: 1 450 000 so'm

Rahmat! Yana ariza yuborish: /new
```

### 10.5 Chiqim so'rovi rad etildi
```
❌ CHIQIM SO'ROVI RAD ETILDI #567

📝 Sabab: Karta egasi ismi noto'g'ri kiritilgan. Iltimos, qaytadan so'rov yuboring

✅ Balansdan summa yechilmadi: 2 650 000 so'm
Qayta urinish: /withdraw
```

---

## 11. XATOLAR VA EDGE CASES

### Bloklangan foydalanuvchi
```
🚫 Sizning akkauntingiz bloklangan.

Sabab: {reason}
Murojaat: support@powersun.uz
```

### Sessiya muddati o'tdi
```
⏱️ Dialog muddati o'tdi (24 soat).
Iltimos, qaytadan boshlang: /new
```

### Noto'g'ri input
```
❌ Noto'g'ri format.
{aniq xatolik tushuntirishi}

Qaytadan urinib ko'ring yoki [❌ Bekor qilish]
```

### Rate limit (5/min PIN)
```
⏱️ Juda ko'p urinish.
30 sekunddan keyin urinib ko'ring.
```

---

## 12. BOT KOMAND MENYUSI (Telegram BotFather setup)

```bash
/setcommands
```

```
start - 🚀 Boshlash / ro'yxat
new - 📝 Yangi ariza
wallet - 💰 Balans
balance - 📜 Balans tarixi
history - 📋 Arizalarim
withdraw - 💵 Pul yechib olish
set_pin - 🔐 PIN o'rnatish
reset_pin - 🔓 PIN reset
help - ℹ️ Yordam
```

---

## 13. XULOSA — BOT FLOW MAP

```
┌──────────────────────────────────────────────────┐
│                  /start                          │
│         ↓                                        │
│  Ro'yxat (yangi) yoki Main menu (mavjud)         │
└────────────┬─────────────────────────────────────┘
             ↓
   ┌────────────────────────────────────┐
   │ /new   /wallet   /history          │
   │ /withdraw   /set_pin   /reset_pin  │
   │ /balance   /help                   │
   └────────────────────────────────────┘
             ↓
   ┌────────────────────────────────────┐
   │ Backend → Status notifications:    │
   │  - Ariza tasdiqlandi/rad etildi    │
   │  - Chiqim tasdiqlandi/to'landi/rad │
   │  - PIN reset qilindi               │
   └────────────────────────────────────┘
```
