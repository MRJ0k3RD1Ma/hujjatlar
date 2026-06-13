# 07 — AUDIT LOG

> `action_logs` jadvali asosida admin harakatlari va status o'zgarishlarini ko'rsatish.

---

## 1. UMUMIY LOG RO'YXATI

### `GET /api/v1/admin/logs`

#### Request
```http
GET /api/v1/admin/logs?action=approve&entity_type=installation&admin_id=1&date_from=2026-04-01&page=1&per_page=50
Authorization: Bearer {access_token}
```

#### Query parametrlari
| Parametr | Tip | Izoh |
|----------|-----|------|
| `admin_id` | int | Aniq admin |
| `action` | string | `approve`, `reject`, `pay`, `pin_reset`, `block`, etc. |
| `action[in]` | string | Vergul bilan |
| `entity_type` | string | `installation`, `withdrawal`, `user`, `inverter`, `material`, `setting`, `admin` |
| `entity_id` | int | Aniq obyekt |
| `created_at[gte]` | datetime | |
| `created_at[lte]` | datetime | |
| `search` | string | details JSON ichidan |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 5001,
      "admin": {
        "id": 1,
        "name": "Aliyev Vali",
        "role": "superadmin"
      },
      "action": "approve",
      "entity_type": "installation",
      "entity_id": 1234,
      "entity_label": "Ariza #1234 — Ismoilov Abdulloh",
      "details": {
        "from_status": "pending",
        "to_status": "approved",
        "comment": "Hammasi joyida",
        "balance_added": "1425000.00",
        "ip_address": "192.168.1.45",
        "user_agent": "Mozilla/5.0..."
      },
      "created_at": "2026-04-18T13:30:00Z"
    },
    {
      "id": 5002,
      "admin": {"id": 1, "name": "Aliyev Vali", "role": "superadmin"},
      "action": "pin_reset",
      "entity_type": "user",
      "entity_id": 15,
      "entity_label": "Usta — Ismoilov Abdulloh",
      "details": {
        "reason": "Usta telefon orqali shaxsini tasdiqladi",
        "verification_method": "phone_call",
        "ip_address": "192.168.1.45"
      },
      "created_at": "2026-04-18T13:35:00Z"
    }
  ],
  "meta": {
    "pagination": {"page": 1, "per_page": 50, "total": 1450, "total_pages": 29},
    "summary": {
      "by_action": {
        "approve": 845,
        "reject": 120,
        "pay": 245,
        "pin_reset": 35,
        "block": 12,
        "setting_update": 28
      }
    }
  }
}
```

---

## 2. ACTION TURLARI

| Action | Entity types | Izoh |
|--------|--------------|------|
| `login` | admin | Admin tizimga kirdi |
| `logout` | admin | Admin chiqdi |
| `password_change` | admin | Parol o'zgartirildi |
| `approve` | installation, withdrawal | Tasdiqlandi |
| `reject` | installation, withdrawal | Rad etildi |
| `reopen` | installation | Qayta ko'rib chiqishga ochildi |
| `pay` | withdrawal | "To'lov yakunlandi" bosildi |
| `card_reveal` | withdrawal | To'liq karta raqami ko'rildi |
| `block` | user | Foydalanuvchi bloklandi |
| `unblock` | user | Blokdan chiqarildi |
| `pin_reset` | user | PIN reset qilindi |
| `pin_unlock` | user | PIN lockout bekor qilindi |
| `create` | inverter, material, region, district, admin | Yangi yozuv |
| `update` | inverter, material, region, district, admin, setting | Yangilandi |
| `delete` | inverter, material, region, district, admin | Nofaol qilindi |
| `setting_update` | setting | Sozlama o'zgartirildi |
| `export` | installation, withdrawal | Eksport olindi |

---

## 3. ENTITY UCHUN TARIX

### `GET /api/v1/admin/logs/{entity_type}/{entity_id}`

> Aniq obyekt tarixini ko'rsatish (timeline ko'rinishida).

#### Request
```http
GET /api/v1/admin/logs/installation/1234
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 5000,
      "action": "create",
      "actor": {"type": "user", "id": 15, "name": "Ismoilov Abdulloh"},
      "details": {"source": "telegram_bot"},
      "created_at": "2026-04-18T10:25:00Z"
    },
    {
      "id": 5001,
      "action": "approve",
      "actor": {"type": "admin", "id": 1, "name": "Aliyev Vali"},
      "details": {
        "from_status": "pending",
        "to_status": "approved",
        "balance_added": "1425000.00"
      },
      "created_at": "2026-04-18T13:30:00Z"
    }
  ]
}
```

---

## 4. NOTIFICATION HISTORY

### `GET /api/v1/admin/logs/notifications`

> `installation_status_history.notification_status` asosida.

#### Request
```http
GET /api/v1/admin/logs/notifications?status=failed&page=1&per_page=50
```

| Query | Variantlar |
|-------|-----------|
| `status` | `pending`, `sent`, `failed` |
| `installation_id` | int |
| `user_id` | int |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 9015,
      "installation_id": 1234,
      "user": {"id": 15, "name": "Ismoilov Abdulloh"},
      "from_status": "pending",
      "to_status": "approved",
      "notification_status": "failed",
      "notification_error": "Telegram API: 403 Forbidden — bot was blocked by the user",
      "retry_count": 3,
      "next_retry_at": null,
      "changed_at": "2026-04-18T13:30:00Z"
    }
  ],
  "meta": {
    "summary": {
      "pending": 5,
      "sent": 14530,
      "failed": 23
    }
  }
}
```

---

## 5. NOTIFICATION QAYTA YUBORISH

### `POST /api/v1/admin/logs/notifications/{history_id}/retry`

> `failed` holatdagi notification'ni queue'ga qaytadan qo'shadi.

#### Response (200)
```json
{
  "success": true,
  "data": {
    "history_id": 9015,
    "queued": true,
    "queue_job_id": "tg_5x8z9w"
  },
  "message": "Notification qayta yuborish navbatiga qo'yildi"
}
```

---

## 6. EKSPORT

### `GET /api/v1/admin/logs/export`

```http
GET /api/v1/admin/logs/export?format=xlsx&date_from=2026-04-01&date_to=2026-04-30
```

Response strukturasi `02-installations.md §6` bilan bir xil.

Excel ustunlari:
- ID, Sana, Admin, Action, Entity, Entity ID, Details (JSON), IP, User-Agent
