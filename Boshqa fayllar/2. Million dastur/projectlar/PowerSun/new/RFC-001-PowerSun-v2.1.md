# RFC-001: POWER SUN v2.1 — Invertor O'rnatuvchilar uchun Mukofot Tizimi

| Maydon | Qiymat |
|--------|--------|
| **RFC raqami** | RFC-001 |
| **Sarlavha** | Power Sun v2.1 — Bot + Admin Panel + Withdrawal Flow |
| **Muallif** | Dilmurod Madrimov (madrimov5014@gmail.com) |
| **Holat** | 🟡 Draft → ⏳ Ko'rib chiqilmoqda |
| **Versiya** | 2.1.0 |
| **Yaratilgan sana** | 2026-04-18 |
| **Maqsadli yetkazib berish** | 30 ish kuni |
| **Manbalar** | `Texnik topshiriq.md`, `For Programmer.md`, `database.sql` |

---

## 1. ABSTRAKT (TL;DR)

Power Sun v2.1 — invertor o'rnatuvchi ustalar uchun **ball asosidagi mukofot tizimi**. Ustalar Telegram bot orqali ariza yuboradi, admin tasdiqlagandan so'ng ballarni virtual balansga oladi va istalgan vaqtda kartaga pul yechib olish so'rovini qoldiradi. Tizim Yii2 (PHP 8.1) backend, React 18 admin panel va MySQL 8 + Redis dan iborat.

> **v2.0 dan asosiy farqi:** karta ma'lumotlari ro'yxatdan o'tishda emas, faqat chiqim so'rovi paytida so'raladi (PCI-DSS yaqinlashish). Qo'shimcha materiallar tizimi, `withdrawal_requests` moduli va **chiqim so'rovi uchun PIN-kod tasdiqlash** qo'shilgan.

---

## 2. MOTIVATSIYA VA MUAMMO BAYONI

### 2.1 Hozirgi muammo
- Invertor o'rnatuvchi ustalar bilan hisob-kitob **qo'lda olib boriladi** (Excel, qog'oz)
- Mukofot hisoblash **inson xatolariga moyil**, shaffof emas
- Ustalar **qachon va qancha** olishini bilmaydi → motivatsiya pasayadi
- Karta ma'lumotlari **noxavfsiz** saqlanadi
- To'lov rejalashtirilmagan — naqd pul oqimi prognozsiz

### 2.2 Nima uchun hozir?
- Kompaniya o'sib bormoqda, qo'lda boshqarish miqyoslanmaydi
- Raqobatchilar avtomatlashtirilgan tizimga o'tmoqda
- Yangi compliance talablar (karta ma'lumotlarini xavfsiz saqlash)

### 2.3 Muvaffaqiyat mezonlari (Success Metrics)
| Metric | Maqsad (3 oy ichida) |
|--------|----------------------|
| Ariza ko'rib chiqish vaqti | < 24 soat (hozir: 3–7 kun) |
| Mukofot hisoblash xatosi | 0% (hozir: ~5%) |
| Aktiv ustalar soni | +40% |
| Chiqim so'rov → to'lov vaqti | < 48 soat |
| Sistema uptime | ≥ 99.5% |

---

## 3. MAQSADLAR VA MAQSAD EMAS

### ✅ Maqsadlar (Goals)
1. Telegram bot orqali ariza yuborish jarayonini avtomatlashtirish
2. Tasdiqlangan arizalardan **avtomatik ball/summa hisoblash** (snapshot bilan)
3. Virtual balans → kartaga chiqim so'rovi to'liq oqimini ta'minlash
4. Admin uchun zamonaviy React panel (filter, eksport, dashboard, audit)
5. Karta ma'lumotlarini **xavfsiz** boshqarish (mask + validate)
6. Barcha o'zgarishlar uchun **o'chirilmaydigan audit log**
7. **Chiqim so'rovini PIN-kod bilan tasdiqlash** — Telegram akkaunti o'g'irlangan/ruxsatsiz kirilgan holatda ham pul yechishning oldini olish

### ❌ Maqsad emas (Non-goals)
1. Bank API bilan **avtomatik to'lov** (qo'lda, moliya xodimi orqali)
2. Mobil ilova (faqat bot + web)
3. Ko'p tillilik (faqat o'zbekcha)
4. Public API (faqat Telegram + Admin panel)
5. Reyting/Gamification tizimi (kelajakda)
6. Real-time chat support

---

## 4. GLOSSARIY

| Termin | Ta'rifi |
|--------|---------|
| **Usta** | Invertor o'rnatuvchi xodim, Telegram bot foydalanuvchisi |
| **Ariza (Installation)** | Bajarilgan ish bo'yicha topshirilgan hujjat |
| **Ball (Point)** | Mukofot birligi (1 ball = N so'm, sozlanadi) |
| **Snapshot** | Ariza paytidagi ball/qiymat — keyinchalik o'zgarmaydi |
| **Balans** | `Σ(approved arizalar) − Σ(approved chiqimlar)` |
| **Chiqim so'rovi (Withdrawal)** | Balansdan kartaga pul yechish so'rovi |
| **Status FSM** | `pending → approved/rejected → paid` o'tish mantiqi |
| **PIN-kod** | Chiqim so'rovini tasdiqlash uchun 4 raqamli maxfiy kod, bcrypt hash bilan saqlanadi |
| **PIN Lockout** | 3 marta noto'g'ri urinishdan keyin 30 daqiqaga PIN bloklash mexanizmi |

---

## 5. ARXITEKTURA

### 5.1 Yuqori darajadagi diagramma
```
┌────────────────┐         ┌──────────────────┐
│  Telegram Bot  │◄────────┤  api/ (Yii2)     │
│   (Ustalar)    │  HTTPS  │  Webhook + Bot   │
└────────────────┘         └────────┬─────────┘
                                    │
                                    ▼
┌────────────────┐         ┌──────────────────┐
│   React SPA    │◄────────┤ backend/ (Yii2)  │
│ (Admin Panel)  │  JWT    │  REST API + RBAC │
└────────────────┘         └────────┬─────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
       ┌──────────┐          ┌──────────┐         ┌────────────┐
       │ MySQL 8  │          │ Redis 7  │         │ Cloudinary │
       │  (data)  │          │ (state)  │         │  (media)   │
       └──────────┘          └──────────┘         └────────────┘
                                    ▲
                                    │
                            ┌───────┴────────┐
                            │ console/       │
                            │ Queue Workers  │
                            │ (Notifications)│
                            └────────────────┘
```

### 5.2 Texnologik stek
| Qatlam | Texnologiya | Sabab |
|--------|-------------|-------|
| Backend framework | **Yii2 Advanced** (PHP 8.1+) | Mavjud ekspertiza, RBAC, ActiveRecord |
| Frontend | **React 18 + Vite + Ant Design 5** | Tez build, professional UI komponentlari |
| Database | **MySQL 8.0** (InnoDB) | ACID, FK, JSON, transactional integrity |
| Cache/State | **Redis 7** | Bot dialog state, rate limiting, queue |
| Auth | **JWT** (firebase/php-jwt) | Stateless, 15m access + 7d refresh |
| Queue | **yii2-queue** (Redis driver) | Notification retry, async webhook processing |
| File storage | **Cloudinary** | Auto-format, image/video optimization |
| Server | **Nginx + PHP-FPM** | Production standard |
| CI/CD | **GitHub Actions** | Test + auto-deploy to VPS |

### 5.3 Modul strukturasi
```
powersun/
├── common/      # ActiveRecord modellari, validators, enums
├── api/         # Telegram webhook + bot mantiq
├── backend/     # Admin REST API + RBAC
├── console/     # Queue workers, cron, backup
├── frontend/    # React SPA (Vite build)
└── environments/ # dev / prod configlar
```

---

## 6. MA'LUMOTLAR MODELI

### 6.1 Asosiy jadvallar (12 ta)
| Guruh | Jadvallar |
|-------|-----------|
| **Hududlar** | `region`, `district` |
| **Foydalanuvchilar** | `users` (ustalar), `admins` |
| **Katalog** | `inverters`, `materials`, `settings` |
| **Arizalar** | `installations`, `installation_photos`, `installation_materials`, `installation_status_history` |
| **To'lovlar** | `payments` (legacy), `withdrawal_requests` |
| **Audit** | `action_logs` |

> 📌 To'liq schema: [database.sql](database.sql)

### 6.2 Kalit dizayn qarorlari
1. **Snapshot fields** (`points_per_unit_snapshot`, `point_value_snapshot`) — ariza yaratilganda saqlanadi va **o'zgarmaydi**. Bu sozlamalar o'zgarganda eski arizalarning hisobi buzilmasligini kafolatlaydi.
2. **Optimistic locking** (`installations.version`) — concurrent update'lardan himoya
3. **Status history table** — har bir o'tish + notification holati alohida yoziladi
4. **Soft delete o'rniga `status` ENUM** — audit log uchun saqlanadi
5. **Bot state** — birinchi navbatda Redis (TTL 24h), zaxira `users.state_data` JSON

### 6.3 Balans hisoblash formulasi
```
mavjud_balans = Σ(installations.total_amount WHERE status IN ('approved','paid'))
              − Σ(withdrawal_requests.amount_som WHERE status IN ('approved','paid'))
```

> ⚠️ **Implementatsiya:** `v_user_balance` MySQL VIEW yoki `Balance::getAvailable($userId)` helper. Race condition'dan himoya uchun `SELECT ... FOR UPDATE` ishlatiladi.

---

## 7. ASOSIY OQIMLAR (USER FLOWS)

### 7.1 Ustaning ariza yuborishi
```
/start → Ro'yxat (ism, telefon, tip, viloyat, tuman)
   ↓
/new   → 10 qadam (lokatsiya, manzil, invertor, materiallar, rasmlar, video)
   ↓
DB     → installations (pending) + status_history yozuvi
   ↓
Bot    → "Arizangiz qabul qilindi #ID"
   ↓
Admin  → tasdiqlash/rad etish
   ↓
Queue  → Telegram xabar (retry x3)
```

### 7.2 Chiqim so'rovi (Withdrawal) — PIN bilan

```
/withdraw → Balans ko'rsatiladi
   ↓
Summa kiritish (validatsiya: min ≤ X ≤ balans)
   ↓
Karta raqami (16 raqam + Luhn + BIN check)
   ↓
Karta egasi ismi
   ↓
Vizual tasdiqlash [✅ Ha] [❌ Yo'q]
   ↓
🔐 PIN-kod kiritish (PinService::verify)
   ├─ ✅ To'g'ri → davom
   ├─ ❌ Noto'g'ri → urinish + 1, qolgan urinishlar ko'rsatiladi
   └─ 🚫 3 marta noto'g'ri → 30 daq lockout, audit log yoziladi
   ↓
Bot PIN xabarini deleteMessage orqali O'CHIRADI
   ↓
withdrawal_requests (pending) yaratiladi
   ↓
Admin guruhiga inline-tugma bilan xabar
   ↓
Admin: tasdiqlash → moliya xodimi pul o'tkazadi → "To'lov yakunlandi"
   ↓
Status: paid + Bot xabar ustaga
```

### 7.3 PIN-kod boshqaruvi

```
/set_pin (birinchi marta)        /set_pin (almashtirish)        /reset_pin (unutilgan)
   ↓                                ↓                                ↓
4 raqamli PIN kiritish           Eski PIN tasdiqlash               Admin panelda
   ↓                                ↓                                so'rov ko'rinadi
Qaytadan kiritish (tasdiq)       Yangi PIN 2 marta                   ↓
   ↓                                ↓                              Admin telefon
Weak-PIN tekshiruv               bcrypt hash + DB save              orqali tasdiqlab
   ↓                                ↓                              PIN'ni reset qiladi
bcrypt hash + DB save            ✅ Tayyor                            ↓
   ↓                                                              Usta /set_pin orqali
✅ Tayyor                                                          yangi PIN o'rnatadi
```

### 7.4 Status FSM (Finite State Machine)

**Installation:**
```
pending ──► approved ──► (paid via withdrawal)
   │
   └──────► rejected (reject_reason majburiy)
```

**Withdrawal:**
```
pending ──► approved ──► paid
   │
   └──────► rejected (rejection_reason majburiy)
```

---

## 8. API DIZAYNI

### 8.1 Standart javob format
```json
// Muvaffaqiyat
{"success": true, "data": {...}, "message": "..."}

// Xatolik
{"success": false, "error": {"code": 422, "message": "...", "details": {...}}}
```

### 8.2 Asosiy endpointlar
| Method | URL | Auth |
|--------|-----|------|
| POST | `/api/v1/bot/webhook` | Secret header |
| POST | `/api/v1/auth/login` | ❌ |
| POST | `/api/v1/auth/refresh` | Refresh token |
| GET | `/api/v1/admin/installations` | JWT Admin |
| PUT | `/api/v1/admin/installations/{id}/approve` | JWT Admin |
| PUT | `/api/v1/admin/installations/{id}/reject` | JWT Admin |
| GET | `/api/v1/admin/withdrawals` | JWT Admin |
| PUT | `/api/v1/admin/withdrawals/{id}/approve` | JWT Admin |
| PUT | `/api/v1/admin/withdrawals/{id}/mark-paid` | JWT Admin |
| POST | `/api/v1/bot/pin/set` | Bot user |
| POST | `/api/v1/bot/pin/verify` | Bot user |
| POST | `/api/v1/bot/pin/reset-request` | Bot user |
| PUT | `/api/v1/admin/users/{id}/pin-reset` | JWT Admin |
| GET | `/api/v1/health` | ❌ |

> To'liq specifikatsiya: [For Programmer.md §4](For Programmer.md)

---

## 9. XAVFSIZLIK

| Tahdid | Yumshatish |
|--------|------------|
| **Karta raqami leak** | UI/log da `****1234`, DB'da AES_ENCRYPT (production), Redis'da saqlamaydi |
| **JWT theft** | 15m short TTL + refresh rotation + Redis blacklist |
| **Brute-force login** | Rate limit 10/min (auth), 60/min (umumiy) |
| **Bot impersonation** | `X-Telegram-Bot-Api-Secret-Token` webhook header |
| **Race condition (balans)** | `SELECT ... FOR UPDATE` + queue serialization |
| **Concurrent admin update** | Optimistic lock (`version` column) |
| **SQL injection** | Yii2 Query Builder, raw SQL taqiqlanadi |
| **XSS** | `Html::encode()` + React escaping |
| **CORS** | Faqat ro'yxatga olingan domenlar |
| **Karta validatsiya bypass** | Backend Luhn + BIN check (UI emas) |
| **Telegram akkaunt o'g'irlash** | 🔐 Chiqim so'rovi PIN-kod bilan tasdiqlanadi (bcrypt hash) |
| **PIN brute-force** | 3 noto'g'ri urinish → 30 daq lockout, audit log + admin xabar |
| **Weak PIN** | `0000`, `1234`, `1111` kabi PIN-lar `PinService::validateFormat()` da rad etiladi |
| **PIN Telegram chatda qoladi** | Bot `deleteMessage` orqali PIN matnli xabarni darhol o'chiradi |

### 🛡️ PCI-DSS yaqinlashish
- Karta ma'lumotlari **ro'yxatdan o'tishda yig'ilmaydi** (faqat chiqim paytida)
- Karta raqami `****` mask bilan loglar/UI'da
- Production'da `card_number` ustun **shifrlanadi** (AES-256 yoki KMS)

---

## 10. TESTLASH STRATEGIYASI

| Tur | Vosita | Qamrov | Maqsad |
|-----|--------|--------|--------|
| Unit | PHPUnit | Modellar, validators, formulalar | ≥ 90% |
| Integration | Codeception REST | API endpoints + DB | ≥ 80% |
| E2E (Bot) | Mock Telegram API | `/new`, `/withdraw` flow | Critical paths 100% |
| E2E (Admin) | Cypress | Login → approve → paid | Critical paths 100% |
| Load | k6 / Apache Bench | Webhook 100 req/s | < 200ms p95 |
| Security | OWASP ZAP | OWASP Top 10 | 0 high/critical |

---

## 11. DEPLOY VA OPERATSIYA

### 11.1 CI/CD pipeline
```yaml
push → lint + test (unit + integration) → build → deploy (main only)
                                                   ↓
                                          SSH → git pull → composer → migrate → restart
```

### 11.2 Monitoring
- **Health check:** `GET /api/v1/health` (DB + Redis + disk)
- **Loglar:** Yii2 file log (rotate kunlik) + critical alertlar Telegram'ga
- **Queue:** `yii queue/listen` (systemd) + dead-letter qayta ishlash
- **Backup:** MySQL dump kunlik 02:00, 7 kun saqlanadi

### 11.3 Rollback strategiyasi
- DB migratsiya: `php yii migrate/down 1`
- Code: `git revert <commit> && git push` → CI avto-deploy
- Critical bug: maintenance page (Nginx) + manual revert

---

## 12. KO'RILGAN MUQOBIL VARIANTLAR

| Muqobil | Sabab tanlanmadi |
|---------|------------------|
| **Laravel** o'rniga Yii2 | Mavjud ekspertiza, mijoz infrastrukturasi |
| **PostgreSQL** o'rniga MySQL | Mijoz hosting MySQL bilan |
| **Vue.js** o'rniga React | Komponent kutubxonalari, talabalar bozori |
| **WebApp Bot** (TWA) o'rniga klassik bot | Sodda UX, oddiy ustalar uchun qulay |
| **Stripe/payment gateway** | Bank API integratsiyasi keyingi bosqichda |
| **Microservice** arxitekturasi | Ortiqcha murakkablik, bitta jamoa |

---

## 13. RIVOJLANTIRISH BOSQICHLARI (MILESTONES)

| Bosqich | Muddat | Natija | Acceptance |
|---------|--------|--------|------------|
| **M1: Asos** | 1–3 kun | Server, Yii2 setup, DB, webhook, region/district seed | `/health` 200 OK |
| **M2: Bot** | 4–10 kun | `/start`, `/new`, `/withdraw`, materiallar, notifications | E2E bot test ✅ |
| **M3: Backend** | 11–17 kun | Ball hisoblash, balans, chiqim API, validatsiya, audit | Integration test 80% |
| **M4: Admin Panel** | 18–26 kun | Dashboard, arizalar, withdrawals, CRUD, loglar | Cypress E2E ✅ |
| **M5: Test + Deploy** | 27–30 kun | Security audit, perf test, prod deploy, qo'llanma | UAT mijoz tomonidan ✅ |

> **Critical Path:** M1 → M2 → M3 (parallel: M4) → M5

---

## 14. RISKLAR VA YUMSHATISH

| Risk | Ehtimollik | Ta'sir | Yumshatish |
|------|-----------|--------|------------|
| Telegram API rate limit | O'rta | Yuqori | Queue + retry, 30 msg/sec limit |
| Cloudinary bepul tier limit | Past | O'rta | Monitoring, paid plan'ga o'tish tayyor |
| Mijoz spec o'zgarishi | Yuqori | O'rta | Har bosqich oxirida sign-off |
| Karta validatsiya false-negative | O'rta | Yuqori | BIN baza yangilash + manual override |
| Server downtime | Past | Yuqori | Health check + uptime monitoring |
| Race condition (balans) | O'rta | Kritik | `FOR UPDATE` + queue serialization + tests |
| Migration failure (prod) | Past | Kritik | Staging'da to'liq test + rollback plan |
| Ustalar adoption past | O'rta | Yuqori | Video qo'llanma + admin yordami |

---

## 15. OCHIQ SAVOLLAR (OPEN QUESTIONS)

Quyidagi savollar mijoz va jamoa bilan kelishilishi kerak:

1. **🔴 Karta shifrlash:** AES_ENCRYPT (MySQL) vs Vault/KMS — mijozning byudjeti?
2. **🟡 `payments` jadvali:** legacy sifatida saqlanadi yoki olib tashlanadi? `paid_amount` qachon yangilanadi?
3. **🟡 `partially_paid` status:** v2.1'da kerakmi yoki ENUM'dan olib tashlash?
4. **🟡 Bot guruhi:** admin notification qaysi guruhga ketadi? Mijoz yaratadimi?
5. **🟢 Ko'p tillilik:** kelajakda kerak bo'lsa, hozirdan i18n strukturani tayyorlash kerakmi?
6. **🟢 Mobil ilova:** v3.0 da rejada bormi? Bot API uni qo'llab-quvvatlash uchun universal qilish kerakmi?
7. **🔴 Min/max chiqim:** kunlik / haftalik limit kerakmi (fraud prevention)?
8. **🟡 Admin ikki bosqichli auth:** 2FA (TOTP) qo'shilsinmi?
9. **🟡 PIN uzunligi:** 4 raqam yetarlimi yoki 6 raqamli PIN tavsiya etiladi (UX vs xavfsizlik)?
10. **🟡 PIN reset usuli:** faqat admin orqali (xavfsizroq) yoki Telegram OTP orqali (qulayroq)?
11. **🟢 Biometric auth:** kelajakda Telegram WebApp orqali Touch/Face ID qo'shilsinmi?

> 🔴 = blocker, 🟡 = muhim, 🟢 = ixtiyoriy

---

## 16. NARX VA RESURS

| Modul | Narx (USD) | Vaqt |
|-------|-----------|------|
| Backend (bot, balans, withdrawals, validatsiya) | $300 | 10 kun |
| Telegram bot (materiallar, withdraw flow, inline) | $150 | 7 kun |
| Admin panel (chiqim, karta UI, CRUD) | $230 | 9 kun |
| Database + migration | $50 | 2 kun |
| Deploy + monitoring | $70 | 2 kun |
| **JAMI** | **$800** | **30 kun** |

**Mijoz tomonidan ta'minlanadi:** VPS, domen, Telegram bot tokeni, invertor/material ro'yxati, ball qiymati, admin loginlar.

**Kafolat:** 14 kun bepul xato tuzatish.

---

## 17. QABUL QILISH MEZONLARI (DEFINITION OF DONE)

- [ ] Barcha 12 jadval `database.sql` ga mos, FK + index ishlaydi
- [ ] `installations.total_*` snapshot create paytida hisoblanadi, update da o'zgarmaydi
- [ ] `WithdrawalRequest::create()` transaction + balance check + Luhn validation + PIN verify
- [ ] PIN bcrypt hash (cost=12), weak PIN rad etiladi, 3 urinish → 30 daq lockout
- [ ] Bot PIN matnli xabari `deleteMessage` orqali darhol o'chiriladi
- [ ] `/set_pin`, `/reset_pin` flow ishlaydi, admin panelda PIN reset tugmasi mavjud
- [ ] Bot webhook 200 OK < 5s, og'ir jarayon queue da
- [ ] Redis bot state TTL 24h, idempotent step handling
- [ ] JWT 15m/7d, rotation + Redis blacklist
- [ ] Karta UI/log da `****1234`, DB'da shifrlangan (production)
- [ ] Notification retry queue + status tracking
- [ ] Test coverage: unit ≥ 90%, integration ≥ 80%
- [ ] CI/CD pipeline yashil, staging deploy muvaffaqiyatli
- [ ] OWASP ZAP scan: 0 high/critical
- [ ] Mijoz UAT sign-off (admin + 2 sinov ustasi)
- [ ] Admin va usta uchun PDF qo'llanma topshirilgan

---

## 18. KELAJAK ISHLARI (FUTURE WORK)

v2.1 dan keyin ko'rib chiqiladigan funksiyalar:

- 🔄 **v2.2:** Bank API integratsiya (Click/Payme/Uzcard API) → avtomatik to'lov
- 🏆 **v2.3:** Reyting tizimi, top-10 ustalar, oylik mukofotlar
- 🌐 **v2.4:** Ko'p tillilik (UZ/RU/EN), web dashboard ustalar uchun
- 📱 **v3.0:** Mobil ilova (React Native), push notifications
- 🤖 **v3.1:** AI fraud detection (rasm tahlili, anomaly detection)
- 📊 **v3.2:** Power BI / Metabase integratsiya, advanced analytics

---

## 19. TASDIQLASH

| Rol | Ism | Sana | Imzo |
|-----|-----|------|------|
| Mahsulot egasi (Mijoz) | _____________ | __________ | _________ |
| Texnik lead | Dilmurod Madrimov | 2026-04-18 | _________ |
| QA lead | _____________ | __________ | _________ |
| DevOps | _____________ | __________ | _________ |

---

## 20. ILOVALAR

- 📄 [Texnik topshiriq.md](Texnik topshiriq.md) — Mijoz uchun biznes spec
- 📄 [For Programmer.md](For Programmer.md) — Dasturchi texnik spec
- 🗄️ [database.sql](database.sql) — MySQL schema
- 🔗 [Yii2 Documentation](https://www.yiiframework.com/doc/guide/2.0/en)
- 🔗 [Telegram Bot API](https://core.telegram.org/bots/api)
- 🔗 [PCI-DSS Quick Reference](https://www.pcisecuritystandards.org/)

---

> **Eslatma:** Ushbu RFC `Texnik topshiriq.md (v2.1)`, `For Programmer.md` va `database.sql` asosida tuzilgan. Har qanday biznes mantiq o'zgarishi avval ushbu RFC'da yangilanadi, keyin implementatsiya qilinadi. Versiya nazorati git orqali olib boriladi.
