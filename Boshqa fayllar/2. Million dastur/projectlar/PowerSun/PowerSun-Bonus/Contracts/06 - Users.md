# 05 — USTALAR (Users) va PIN BOSHQARUVI

> Ustalar ro'yxati, tafsilot, blok/unblok, PIN reset, balans tarixi.

---

## 1. USTALAR RO'YXATI

### `GET /api/v1/admin/users`

#### Request
```http
GET /api/v1/admin/users?status=active&region_id=1&search=ismoil&sort=-created_at&page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Query parametrlari
| Parametr | Tip | Izoh |
|----------|-----|------|
| `status` | enum | `active`, `blocked` |
| `customer_type` | enum | `individual`, `legal`, `sole_proprietor` |
| `region_id` | int | |
| `district_id` | int | |
| `search` | string | ism, telefon, telegram_id |
| `pin_set` | bool | `true` = PIN o'rnatgan, `false` = o'rnatmagan |
| `pin_locked` | bool | `true` = hozir bloklangan |
| `sort` | string | `name`, `-created_at`, `-installations_count`, `-total_balance` |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "telegram_id": 123456789,
      "name": "Ismoilov Abdulloh",
      "phone": "+998901234567",
      "customer_type": "individual",
      "legal_name": null,
      "region": {"id": 1, "title": "Toshkent shahri"},
      "district": {"id": 5, "title": "Yunusobod"},
      "status": "active",
      "pin_set": true,
      "pin_locked": false,
      "stats": {
        "installations_count": 45,
        "approved_count": 40,
        "rejected_count": 3,
        "total_earned": "8950000.00",
        "total_withdrawn": "6300000.00",
        "available_balance": "2650000.00"
      },
      "created_at": "2026-01-10T08:00:00Z",
      "last_active_at": "2026-04-18T13:45:00Z"
    }
  ],
  "meta": {
    "pagination": {"page": 1, "per_page": 20, "total": 234, "total_pages": 12},
    "summary": {
      "total_users": 234,
      "active": 215,
      "blocked": 19,
      "with_pin": 198,
      "currently_locked": 3
    }
  }
}
```

---

## 2. USTA TAFSILOTI

### `GET /api/v1/admin/users/{id}`

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 15,
    "telegram_id": 123456789,
    "name": "Ismoilov Abdulloh",
    "phone": "+998901234567",
    "customer_type": "individual",
    "legal_name": null,
    "region": {"id": 1, "title": "Toshkent shahri"},
    "district": {"id": 5, "title": "Yunusobod"},
    "status": "active",
    "state": null,
    "pin": {
      "is_set": true,
      "set_at": "2026-02-15T10:00:00Z",
      "attempts": 0,
      "locked_until": null,
      "is_locked": false
    },
    "balance": {
      "available": "2650000.00",
      "available_points": 530,
      "total_earned": "8950000.00",
      "total_withdrawn": "6300000.00",
      "pending_withdrawal": "0.00"
    },
    "stats": {
      "installations_total": 45,
      "installations_pending": 2,
      "installations_approved": 40,
      "installations_rejected": 3,
      "withdrawals_total": 12,
      "withdrawals_paid": 11,
      "withdrawals_pending": 1
    },
    "created_at": "2026-01-10T08:00:00Z",
    "updated_at": "2026-04-18T13:45:00Z"
  }
}
```

---

## 3. USTANI BLOK QILISH

### `PUT /api/v1/admin/users/{id}/block`

#### Request
```json
{
  "reason": "Soxta ariza yuborgan, fraud aniqlangan"
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
    "id": 15,
    "status": "blocked",
    "blocked_by": {"id": 1, "name": "Aliyev Vali"},
    "blocked_at": "2026-04-18T14:00:00Z"
  },
  "message": "Foydalanuvchi bloklandi. Bot bilan ishlay olmaydi"
}
```

---

## 4. USTANI BLOKDAN CHIQARISH

### `PUT /api/v1/admin/users/{id}/unblock`

#### Request
```json
{
  "reason": "Tushunmovchilik hal qilindi"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 15,
    "status": "active",
    "unblocked_by": {"id": 1, "name": "Aliyev Vali"},
    "unblocked_at": "2026-04-18T14:30:00Z"
  },
  "message": "Foydalanuvchi blokdan chiqarildi"
}
```

---

## 5. PIN RESET (Admin orqali)

### `PUT /api/v1/admin/users/{id}/pin-reset`

> Usta PIN'ni unutsa, telefon orqali admin bilan bog'lanadi. Admin shaxsini tasdiqlagach, PIN'ni reset qiladi (`pin_hash = NULL`). Usta keyingi `/withdraw` paytida yangi PIN o'rnatadi.

#### Request
```json
{
  "reason": "Usta telefon orqali shaxsini tasdiqladi (passport so'raldi)",
  "verification_method": "phone_call"
}
```

| Field | Rules |
|-------|-------|
| `reason` | required, 10–500 belgi |
| `verification_method` | enum: `phone_call`, `in_person`, `video_call` |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "user_id": 15,
    "pin_reset_by": {"id": 1, "name": "Aliyev Vali"},
    "pin_reset_at": "2026-04-18T14:00:00Z"
  },
  "message": "PIN reset qilindi. Foydalanuvchi keyingi chiqim so'rovi paytida yangi PIN o'rnatadi"
}
```

> 📌 Bot avtomatik xabar yuboradi:
> ```
> 🔐 Sizning PIN-kodingiz admin tomonidan reset qilindi.
> Keyingi /withdraw paytida yangi PIN o'rnatasiz.
> ```

---

## 6. PIN LOCKOUT'NI BEKOR QILISH (Admin orqali)

### `PUT /api/v1/admin/users/{id}/pin-unlock`

> Usta 3 marta noto'g'ri PIN kiritsa, 30 daqiqaga bloklanadi. Admin tezkor blokdan chiqarishi mumkin.

#### Request
```json
{
  "reason": "Usta tezkor murojaat qildi, vaziyat aniqlandi"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "user_id": 15,
    "pin_attempts_reset": true,
    "lock_removed": true,
    "by": {"id": 1, "name": "Aliyev Vali"},
    "at": "2026-04-18T14:00:00Z"
  },
  "message": "PIN lockout bekor qilindi"
}
```

---

## 7. USTA BALANS TARIXI

### `GET /api/v1/admin/users/{id}/balance-history`

#### Request
```http
GET /api/v1/admin/users/15/balance-history?date_from=2026-01-01&date_to=2026-04-30
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "type": "earn",
      "ref_type": "installation",
      "ref_id": 1234,
      "amount": "1425000.00",
      "balance_after": "1425000.00",
      "description": "Ariza #1234 tasdiqlandi",
      "created_at": "2026-04-18T13:30:00Z"
    },
    {
      "type": "withdraw",
      "ref_type": "withdrawal_request",
      "ref_id": 567,
      "amount": "-1200000.00",
      "balance_after": "225000.00",
      "description": "Chiqim #567 to'landi",
      "created_at": "2026-04-18T14:00:00Z"
    }
  ],
  "meta": {
    "pagination": {"page": 1, "per_page": 20, "total": 145, "total_pages": 8},
    "summary": {
      "total_earned": "8950000.00",
      "total_withdrawn": "6300000.00",
      "current_balance": "2650000.00"
    }
  }
}
```

---

## 8. USTA ARIZALARI

### `GET /api/v1/admin/users/{id}/installations`

Parametrlar va response `02-installations.md §1` bilan bir xil, faqat avtomatik `user_id` filtri bilan.

---

## 9. USTA CHIQIM SO'ROVLARI

### `GET /api/v1/admin/users/{id}/withdrawals`

Parametrlar va response `03-withdrawals.md §1` bilan bir xil, faqat avtomatik `user_id` filtri bilan.

---

## 10. ADMINLAR (Superadmin uchun)

### 10.1 Adminlar ro'yxati
**`GET /api/v1/admin/admins`** *(superadmin)*

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Aliyev Vali",
      "login": "admin@powersun.uz",
      "role": "superadmin",
      "status": "active",
      "last_login_at": "2026-04-18T13:25:00Z",
      "created_at": "2026-01-10T08:00:00Z"
    }
  ]
}
```

### 10.2 Yangi admin yaratish
**`POST /api/v1/admin/admins`** *(superadmin)*

```json
{
  "name": "Karimov Sherzod",
  "login": "sherzod@powersun.uz",
  "password": "TempPass123!",
  "role": "admin",
  "force_password_change": true
}
```

#### Response (201)
```json
{
  "success": true,
  "data": { /* yangi admin */ },
  "message": "Admin yaratildi. Boshlang'ich parol email ga yuborildi"
}
```

### 10.3 Admin yangilash / nofaol qilish
**`PUT /api/v1/admin/admins/{id}`** *(superadmin)*

```json
{"name": "Karimov Sherzod Aktivovich", "status": "inactive"}
```

> ⚠️ Superadmin o'zini nofaol qila olmaydi. Boshqa superadmin tomonidan amalga oshiriladi.
