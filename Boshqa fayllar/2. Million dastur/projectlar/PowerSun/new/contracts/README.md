# 📡 POWER SUN v2.1 — API CONTRACTS

> **Maqsad:** Frontend (React Admin Panel) va Telegram Bot bilan Backend (Yii2) o'rtasidagi to'liq aloqa kontrakti.
> **Auditoriya:** Frontend dasturchi, Backend dasturchi, QA, Bot integratsiya muhandisi
> **Versiya:** 2.1.0
> **Sana:** 2026-04-18
> **Base URL:** `https://api.powersun.uz` (production), `http://localhost:8080` (dev)

---

## 📚 Hujjatlar ro'yxati

| # | Fayl | Mazmun |
|---|------|--------|
| 0 | [00-common.md](00-common.md) | Umumiy javob format, xato kodlari, paginatsiya, sana formatlari |
| 1 | [01-auth.md](01-auth.md) | Admin login, JWT refresh, logout, current user |
| 2 | [02-installations.md](02-installations.md) | Arizalar: list, detail, approve/reject, eksport |
| 3 | [03-withdrawals.md](03-withdrawals.md) | Chiqim so'rovlari: list, detail, approve/reject/mark-paid |
| 4 | [04-catalog.md](04-catalog.md) | Invertorlar, materiallar, hududlar, sozlamalar CRUD |
| 5 | [05-users.md](05-users.md) | Ustalar boshqaruvi, blok/unblok, PIN reset |
| 6 | [06-dashboard.md](06-dashboard.md) | Dashboard statistikalari va grafiklar |
| 7 | [07-logs.md](07-logs.md) | Audit log, action_logs, status history |
| 8 | [08-bot-webhook.md](08-bot-webhook.md) | Telegram webhook payload va backend javobi |
| 9 | [09-bot-flows.md](09-bot-flows.md) | Bot buyruqlari, dialog oqimi, xabarlar matni |

---

## 🌐 Umumiy konventsiyalar

### URL strukturasi
```
https://api.powersun.uz/api/v1/{module}/{resource}/{id?}/{action?}
                                  ↑          ↑          ↑
                               admin/bot   resurs    ixtiyoriy
```

### HTTP metodlari
| Method | Maqsad |
|--------|--------|
| `GET` | O'qish (list, detail) |
| `POST` | Yaratish |
| `PUT` | To'liq yangilash / FSM action (approve, reject) |
| `PATCH` | Qisman yangilash |
| `DELETE` | O'chirish (soft delete = `status='inactive'`) |

### Headerlar (har bir so'rovda)
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {access_token}      # Auth required endpointlarda
X-Request-ID: uuid-v4                     # Ixtiyoriy, debugging uchun
Accept-Language: uz                        # Hozircha faqat uz
```

### Status kodlari
| Code | Ma'nosi |
|------|---------|
| `200` | OK — muvaffaqiyatli |
| `201` | Created — yaratildi |
| `204` | No Content — javob tanasiz |
| `400` | Bad Request — noto'g'ri so'rov |
| `401` | Unauthorized — token yo'q yoki muddati o'tgan |
| `403` | Forbidden — huquq yo'q |
| `404` | Not Found — topilmadi |
| `409` | Conflict — FSM violation, race condition |
| `422` | Unprocessable Entity — validatsiya xatosi |
| `423` | Locked — PIN lockout, resource locked |
| `429` | Too Many Requests — rate limit |
| `500` | Server Error |

---

## 🔐 Autentifikatsiya umumiy ko'rinishi

```
1. Frontend: POST /api/v1/auth/login {login, password}
   Backend → {access_token (15m), refresh_token (7d)}

2. Frontend: har so'rovga Authorization: Bearer {access_token}

3. Access expired → 401 → Frontend: POST /api/v1/auth/refresh {refresh_token}
   Backend → yangi {access_token, refresh_token} (rotation)

4. Logout → POST /api/v1/auth/logout → backend tokenlarni Redis blacklist'ga qo'shadi
```

> Telegram bot endpointlari **ichki** — webhook secret token bilan himoyalangan, JWT ishlatmaydi.

---

## 🤖 Telegram Bot kontrakti

Bot Backend bilan ikki tomonlama:
1. **Telegram → Backend (Webhook):** Telegram serveri foydalanuvchi xabarini Backend'ga POST qiladi → [08-bot-webhook.md](08-bot-webhook.md)
2. **Backend → Telegram API:** Backend `https://api.telegram.org/bot{token}/sendMessage` orqali javob yuboradi → [09-bot-flows.md](09-bot-flows.md)

Frontend (React) bot bilan to'g'ridan-to'g'ri muloqot qilmaydi. Faqat admin panel orqali bot foydalanuvchilarini boshqaradi.

---

## 📦 Versiyalash

API versiyasi URL'da: `/api/v1/...`

**Breaking changes** uchun yangi versiya: `/api/v2/...`. Eski versiya kamida 6 oy parallel ishlaydi.

**Non-breaking** o'zgarishlar (yangi field qo'shish, yangi endpoint) bir versiya ichida amalga oshiriladi.

---

## 🧪 Testlash

- **Postman collection:** `contracts/postman/PowerSun.v2.1.postman_collection.json` (keyin tayyorlanadi)
- **OpenAPI spec:** `contracts/openapi.yaml` (avtomatik generatsiya qilinadi `php yii openapi/export`)
- **Mock server:** dev muhitda `php yii serve` + `php yii bot/poll` (webhook o'rnatish kerak emas)

---

## 📞 Aloqa

| Rol | Mas'ul | Aloqa |
|-----|--------|-------|
| Backend lead | Dilmurod Madrimov | madrimov5014@gmail.com |
| Frontend lead | _____________ | _____________ |
| Bot integratsiya | _____________ | _____________ |
| QA lead | _____________ | _____________ |

---

> **Eslatma:** Ushbu kontrakt **single source of truth**. Backend va Frontend dasturchilar shu fayldan foydalanadi. Har qanday o'zgarish PR orqali, ikki tomon roziligi bilan qilinadi.
