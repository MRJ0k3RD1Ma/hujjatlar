# 03 — CHIQIM SO'ROVLARI (Withdrawals)

> Withdrawal so'rovlari ro'yxati, tafsilot, tasdiqlash, rad etish, "to'lov yakunlandi" belgilash.

---

## 1. CHIQIM SO'ROVLARI RO'YXATI

### `GET /api/v1/admin/withdrawals`

#### Request
```http
GET /api/v1/admin/withdrawals?status=pending&user_id=15&amount_som[gte]=100000&sort=-created_at&page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Query parametrlari
| Parametr | Tip | Izoh |
|----------|-----|------|
| `status` | enum | `pending`, `approved`, `paid`, `rejected` |
| `status[in]` | string | `pending,approved` |
| `user_id` | int | Aniq usta |
| `admin_id` | int | Tasdiqlagan admin |
| `amount_som[gte]` | decimal | Min summa |
| `amount_som[lte]` | decimal | Max summa |
| `created_at[gte]` | datetime | |
| `created_at[lte]` | datetime | |
| `search` | string | ID, usta ismi, telefon, karta last4 |
| `sort` | string | `-created_at`, `-amount_som` |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 567,
      "user": {
        "id": 15,
        "name": "Ismoilov Abdulloh",
        "phone": "+998901234567"
      },
      "points_amount": 240,
      "amount_som": "1200000.00",
      "card_masked": "8600 **** **** 4567",
      "card_holder_name": "Abdulloh Ismoilov",
      "card_type": "uzcard",
      "status": "pending",
      "admin": null,
      "created_at": "2026-04-18T11:00:00Z",
      "updated_at": "2026-04-18T11:00:00Z"
    }
  ],
  "meta": {
    "pagination": { "page": 1, "per_page": 20, "total": 45, "total_pages": 3 },
    "summary": {
      "total_pending_amount": "8500000.00",
      "total_approved_amount": "12000000.00",
      "total_paid_amount": "45000000.00",
      "by_status": {
        "pending": 12,
        "approved": 5,
        "paid": 25,
        "rejected": 3
      }
    }
  }
}
```

> ⚠️ Karta raqami **hech qachon to'liq qaytarilmaydi**, faqat `card_masked` (`8600 **** **** 4567`) format.

---

## 2. CHIQIM SO'ROVI TAFSILOTI

### `GET /api/v1/admin/withdrawals/{id}`

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 567,
    "user": {
      "id": 15,
      "name": "Ismoilov Abdulloh",
      "phone": "+998901234567",
      "telegram_id": 123456789,
      "customer_type": "individual",
      "region": {"id": 1, "title": "Toshkent shahri"},
      "district": {"id": 5, "title": "Yunusobod"},
      "current_balance": "2650000.00",
      "total_earned": "8950000.00",
      "total_withdrawn": "6300000.00"
    },
    "points_amount": 240,
    "amount_som": "1200000.00",
    "point_value_at_request": "5000.00",
    "card_masked": "8600 **** **** 4567",
    "card_holder_name": "Abdulloh Ismoilov",
    "card_type": "uzcard",
    "card_full": null,
    "status": "pending",
    "admin": null,
    "rejection_reason": null,
    "paid_confirmed_at": null,
    "balance_at_request": "2650000.00",
    "history": [
      {
        "from_status": null,
        "to_status": "pending",
        "admin": null,
        "reason": null,
        "changed_at": "2026-04-18T11:00:00Z"
      }
    ],
    "created_at": "2026-04-18T11:00:00Z",
    "updated_at": "2026-04-18T11:00:00Z"
  }
}
```

> 🔒 `card_full` faqat **superadmin** uchun va alohida endpoint orqali ochiladi (audit bilan).

---

## 3. KARTA TO'LIQ RAQAMINI KO'RISH (Superadmin)

### `POST /api/v1/admin/withdrawals/{id}/reveal-card`

> 🔴 Har murojaat audit log'ga yoziladi. SMS notification superadmin'ga yuboriladi.

#### Request
```http
POST /api/v1/admin/withdrawals/567/reveal-card
Authorization: Bearer {access_token}
```

```json
{
  "reason": "Bankka xabar yozish uchun to'liq raqam kerak"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "card_full": "8600123456784567",
    "expires_at": "2026-04-18T13:35:00Z"
  },
  "message": "Karta ma'lumoti 5 daqiqa ko'rinadi. Audit log'ga yozildi"
}
```

#### Xatoliklar
**403 — admin huquqi yetarli emas:**
```json
{
  "success": false,
  "error": {
    "code": 403,
    "type": "FORBIDDEN",
    "message": "Faqat superadmin to'liq karta raqamini ko'ra oladi"
  }
}
```

---

## 4. CHIQIM SO'ROVINI TASDIQLASH

### `PUT /api/v1/admin/withdrawals/{id}/approve`

> Status: `pending` → `approved`. Pul hali o'tkazilmadi, faqat admin "tekshirdim, to'lov uchun tayyor" deb belgilaydi.

#### Request
```json
{
  "comment": "Karta egasi mos. To'lovga tayyor"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 567,
    "status": "approved",
    "approved_by": {"id": 1, "name": "Aliyev Vali"},
    "approved_at": "2026-04-18T13:30:00Z"
  },
  "message": "So'rov tasdiqlandi. Endi pulni o'tkazib, 'To'lov yakunlandi' tugmasini bosing"
}
```

---

## 5. "TO'LOV YAKUNLANDI" — MARK PAID

### `PUT /api/v1/admin/withdrawals/{id}/mark-paid`

> Status: `approved` → `paid`. Foydalanuvchi balansidan summa yechiladi, ustaga "Pul kartangizga o'tkazildi" xabari ketadi.

#### Request
```json
{
  "transaction_reference": "TX-20260418-001234",
  "comment": "Uzcard orqali"
}
```

| Field | Rules |
|-------|-------|
| `transaction_reference` | string?, bank tranzaksiya raqami (audit uchun) |
| `comment` | string?, ixtiyoriy izoh |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 567,
    "status": "paid",
    "paid_confirmed_at": "2026-04-18T14:00:00Z",
    "user_new_balance": "1450000.00",
    "transaction_reference": "TX-20260418-001234"
  },
  "message": "To'lov yakunlandi. Foydalanuvchi balansidan 1 200 000 so'm yechildi va xabar yuborildi"
}
```

#### Xatoliklar

**409 — noto'g'ri status:**
```json
{
  "success": false,
  "error": {
    "code": 409,
    "type": "INVALID_STATE",
    "message": "Faqat 'approved' holatdagi so'rovni 'paid' qilish mumkin",
    "details": {"current_status": "pending"}
  }
}
```

---

## 6. CHIQIM SO'ROVINI RAD ETISH

### `PUT /api/v1/admin/withdrawals/{id}/reject`

> Status: `pending` yoki `approved` → `rejected`. Ustaga summa qaytariladi (balansdan yechilmagan, hech narsa qilinmaydi). Sabab ustaga yuboriladi.

#### Request
```json
{
  "reason": "Karta egasi ismi noto'g'ri kiritilgan. Iltimos, qaytadan so'rov yuboring"
}
```

| Field | Rules |
|-------|-------|
| `reason` | required, 10–500 belgi |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 567,
    "status": "rejected",
    "rejection_reason": "Karta egasi ismi noto'g'ri kiritilgan. Iltimos, qaytadan so'rov yuboring",
    "rejected_by": {"id": 1, "name": "Aliyev Vali"},
    "rejected_at": "2026-04-18T13:35:00Z"
  },
  "message": "So'rov rad etildi. Foydalanuvchiga xabar yuborildi"
}
```

---

## 7. CHIQIM SO'ROVI YARATISH (Bot ichidan)

### `POST /api/v1/bot/withdraw`

> ⚠️ Bu endpoint **faqat bot** ishlatadi (admin emas). PIN tasdiqlangach chaqiriladi.

#### Request
```http
POST /api/v1/bot/withdraw
Content-Type: application/json
X-Bot-Secret: {webhook_secret}
```

```json
{
  "telegram_id": 123456789,
  "amount_som": "1200000.00",
  "card_number": "8600123456784567",
  "card_holder_name": "Abdulloh Ismoilov",
  "pin": "4729"
}
```

| Field | Rules |
|-------|-------|
| `telegram_id` | required, bigint |
| `amount_som` | required, decimal, min ≥ `min_withdrawal_som`, ≤ available_balance |
| `card_number` | required, 16 raqam, Luhn valid, BIN [8600/9860/4/5] |
| `card_holder_name` | required, 3–255 belgi |
| `pin` | required, 4 raqam |

#### Response (201)
```json
{
  "success": true,
  "data": {
    "id": 567,
    "status": "pending",
    "amount_som": "1200000.00",
    "points_amount": 240,
    "card_masked": "8600 **** **** 4567",
    "created_at": "2026-04-18T11:00:00Z",
    "user_balance_after": "1450000.00"
  },
  "message": "So'rov qabul qilindi. Adminlar ko'rib chiqishini kuting"
}
```

#### Xatoliklar

**423 — PIN bloklangan:**
```json
{
  "success": false,
  "error": {
    "code": 423,
    "type": "PIN_LOCKED",
    "message": "PIN 30 daqiqaga bloklangan",
    "details": {"unlock_at": "2026-04-18T11:30:00Z"}
  }
}
```

**422 — PIN noto'g'ri:**
```json
{
  "success": false,
  "error": {
    "code": 422,
    "type": "VALIDATION_ERROR",
    "message": "PIN noto'g'ri",
    "details": {
      "pin": ["Noto'g'ri PIN. Qolgan urinishlar: 2"]
    }
  }
}
```

**409 — balans yetmaydi:**
```json
{
  "success": false,
  "error": {
    "code": 409,
    "type": "INSUFFICIENT_BALANCE",
    "message": "Balans yetarli emas",
    "details": {"available": "850000.00", "requested": "1200000.00"}
  }
}
```

**422 — karta validatsiyasi yiqildi:**
```json
{
  "success": false,
  "error": {
    "code": 422,
    "type": "VALIDATION_ERROR",
    "message": "Karta ma'lumotlari noto'g'ri",
    "details": {
      "card_number": ["Karta raqami Luhn algoritmidan o'tmadi"],
      "card_holder_name": ["Ism kamida 3 belgi bo'lishi kerak"]
    }
  }
}
```

---

## 8. CHIQIM SO'ROVI EKSPORTI

### `GET /api/v1/admin/withdrawals/export`

Parametrlar va response strukturasi `02-installations.md §6` bilan bir xil.

Excel ustunlari:
- ID, Usta, Telefon, Ball, Summa (so'm), Karta (mask), Karta egasi, Holat, Tasdiqlovchi admin, Sana, To'lov sanasi, Bank tranzaksiya №

---

## 9. STATISTIKA (Bo'lim ichidagi)

### `GET /api/v1/admin/withdrawals/stats`

#### Request
```http
GET /api/v1/admin/withdrawals/stats?period=month&date=2026-04
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "period": "2026-04",
    "total_requests": 145,
    "total_amount_paid": "85000000.00",
    "total_amount_pending": "12000000.00",
    "total_amount_rejected": "3000000.00",
    "average_processing_hours": 18.5,
    "top_users": [
      {"user_id": 15, "name": "Ismoilov Abdulloh", "total": "12000000.00"},
      {"user_id": 23, "name": "Karimov Sherzod", "total": "8500000.00"}
    ]
  }
}
```
