# 02 — ARIZALAR (Installations)

> Arizalar ro'yxati, tafsilot, tasdiqlash/rad etish, eksport.

---

## 1. ARIZALAR RO'YXATI

### `GET /api/v1/admin/installations`

#### Request
```http
GET /api/v1/admin/installations?status=pending&user_id=15&inverter_id=5&region_id=1&created_at[gte]=2026-04-01&sort=-created_at&page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Query parametrlari
| Parametr | Tip | Izoh |
|----------|-----|------|
| `status` | enum | `pending`, `approved`, `rejected`, `paid` |
| `status[in]` | string | Vergul bilan: `pending,approved` |
| `user_id` | int | Aniq usta |
| `inverter_id` | int | Aniq invertor |
| `material_id` | int | Tarkibida material bor |
| `region_id` | int | Ustaning viloyati |
| `district_id` | int | Ustaning tumani |
| `object_type` | enum | `house`, `factory`, `office`, `other` |
| `created_at[gte]` | datetime | Sana boshlanish |
| `created_at[lte]` | datetime | Sana tugash |
| `total_amount[gte]` | decimal | Min summa |
| `total_amount[lte]` | decimal | Max summa |
| `search` | string | ID, usta ismi, telefon bo'yicha |
| `sort` | string | `created_at`, `-created_at`, `total_amount`, `-total_amount` |
| `page`, `per_page` | int | Pagination |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 1234,
      "user": {
        "id": 15,
        "name": "Ismoilov Abdulloh",
        "phone": "+998901234567",
        "telegram_id": 123456789
      },
      "inverter": {
        "id": 5,
        "model": "Deye SUN-12K",
        "manufacturer": "Deye"
      },
      "object_type": "house",
      "address": "Toshkent sh., Yunusobod tumani, Bog'ishamol 12-uy",
      "kw": "12.00",
      "inverter_count": 2,
      "total_points": 285,
      "total_amount": "1425000.00",
      "status": "pending",
      "materials_count": 2,
      "photos_count": 4,
      "has_video": true,
      "created_at": "2026-04-18T10:25:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 145,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    },
    "summary": {
      "total_amount": "245000000.00",
      "total_points": 49000,
      "by_status": {
        "pending": 23,
        "approved": 95,
        "rejected": 12,
        "paid": 15
      }
    }
  }
}
```

---

## 2. ARIZA TAFSILOTI

### `GET /api/v1/admin/installations/{id}`

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "user": {
      "id": 15,
      "name": "Ismoilov Abdulloh",
      "phone": "+998901234567",
      "telegram_id": 123456789,
      "customer_type": "individual",
      "legal_name": null,
      "region": {"id": 1, "title": "Toshkent shahri"},
      "district": {"id": 5, "title": "Yunusobod"}
    },
    "inverter": {
      "id": 5,
      "model": "Deye SUN-12K",
      "manufacturer": "Deye",
      "power_kw": "12.00"
    },
    "location": "Toshkent shahri",
    "location_lat": 41.32,
    "location_lng": 69.25,
    "address": "Toshkent sh., Yunusobod tumani, Bog'ishamol 12-uy",
    "object_type": "house",
    "kw": "12.00",
    "inverter_count": 2,
    "points_per_unit_snapshot": 120,
    "base_points": 240,
    "material_bonus_points": 45,
    "total_points": 285,
    "point_value_snapshot": "5000.00",
    "total_amount": "1425000.00",
    "paid_amount": "0.00",
    "extra_materials_note": null,
    "notes": "Mijoz mamnun",
    "status": "pending",
    "reject_reason": null,
    "version": 1,
    "materials": [
      {
        "id": 101,
        "material": {"id": 1, "name": "Kabel", "unit": "meter"},
        "quantity": "15.00",
        "points_per_unit_snapshot": 2,
        "points_earned": 30
      },
      {
        "id": 102,
        "material": {"id": 2, "name": "Montaj to'plami", "unit": "set"},
        "quantity": "3.00",
        "points_per_unit_snapshot": 5,
        "points_earned": 15
      }
    ],
    "photos": [
      {
        "id": 501,
        "photo_url": "https://res.cloudinary.com/.../inv_close_1234.jpg",
        "photo_type": "inverter_close",
        "created_at": "2026-04-18T10:24:30Z"
      }
    ],
    "video_url": "https://res.cloudinary.com/.../video_1234.mp4",
    "status_history": [
      {
        "id": 9001,
        "from_status": null,
        "to_status": "pending",
        "admin": null,
        "reason": null,
        "context": null,
        "notification_status": "sent",
        "changed_at": "2026-04-18T10:25:00Z"
      }
    ],
    "calculation_breakdown": {
      "formula": "(120 × 2) + (2×15 + 5×3) = 240 + 45 = 285 ball",
      "amount_formula": "285 × 5000 = 1 425 000 so'm"
    },
    "created_at": "2026-04-18T10:25:00Z",
    "updated_at": "2026-04-18T10:25:00Z"
  }
}
```

---

## 3. ARIZANI TASDIQLASH

### `PUT /api/v1/admin/installations/{id}/approve`

#### Request
```http
PUT /api/v1/admin/installations/1234/approve
Authorization: Bearer {access_token}
Content-Type: application/json
```

```json
{
  "version": 1,
  "comment": "Hammasi joyida"
}
```

| Field | Tip | Izoh |
|-------|-----|------|
| `version` | int | Optimistic lock — mavjud `version` qiymati |
| `comment` | string? | Ixtiyoriy izoh (audit log uchun) |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "status": "approved",
    "version": 2,
    "approved_by": {"id": 1, "name": "Aliyev Vali"},
    "approved_at": "2026-04-18T13:30:00Z",
    "balance_added": "1425000.00",
    "user_new_balance": "3850000.00"
  },
  "message": "Ariza tasdiqlandi. Foydalanuvchi balansiga 1 425 000 so'm qo'shildi"
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
    "message": "Faqat 'pending' holatdagi arizani tasdiqlash mumkin",
    "details": {"current_status": "approved"}
  }
}
```

**409 — version conflict:**
```json
{
  "success": false,
  "error": {
    "code": 409,
    "type": "STALE_OBJECT",
    "message": "Ariza boshqa admin tomonidan o'zgartirildi. Sahifani yangilang",
    "details": {"current_version": 2, "your_version": 1}
  }
}
```

---

## 4. ARIZANI RAD ETISH

### `PUT /api/v1/admin/installations/{id}/reject`

#### Request
```json
{
  "version": 1,
  "reason": "Rasmlar sifatsiz. Iltimos, qaytadan yuboring"
}
```

| Field | Rules |
|-------|-------|
| `version` | required, int |
| `reason` | required, string, 10–1000 belgi |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "status": "rejected",
    "version": 2,
    "reject_reason": "Rasmlar sifatsiz. Iltimos, qaytadan yuboring",
    "rejected_by": {"id": 1, "name": "Aliyev Vali"},
    "rejected_at": "2026-04-18T13:30:00Z"
  },
  "message": "Ariza rad etildi. Foydalanuvchiga xabar yuborildi"
}
```

#### Xatoliklar

**422 — sabab juda qisqa:**
```json
{
  "success": false,
  "error": {
    "code": 422,
    "type": "VALIDATION_ERROR",
    "message": "Validatsiya xatoligi",
    "details": {
      "reason": ["Sabab kamida 10 belgi bo'lishi kerak"]
    }
  }
}
```

---

## 5. RAD ETILGAN ARIZANI QAYTA OCHISH

### `PUT /api/v1/admin/installations/{id}/reopen`

> Faqat `rejected` arizani `pending` holatga qaytaradi.

#### Request
```json
{
  "version": 2,
  "comment": "Mijoz rasmlarni qayta yubordi"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "status": "pending",
    "version": 3
  },
  "message": "Ariza qayta ko'rib chiqish uchun ochildi"
}
```

---

## 6. EKSPORT (Excel/CSV)

### `GET /api/v1/admin/installations/export`

#### Request
```http
GET /api/v1/admin/installations/export?format=xlsx&status[in]=approved,paid&created_at[gte]=2026-01-01
Authorization: Bearer {access_token}
```

| Parametr | Tip | Izoh |
|----------|-----|------|
| `format` | enum | `xlsx`, `csv`, `pdf` |
| (filtrlar) | — | Yuqoridagi list filtrlari bilan bir xil |

#### Response (200) — fayl
```http
HTTP/1.1 200 OK
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="installations_2026-04-18.xlsx"
Content-Length: 24576

<binary data>
```

> 💡 Katta eksport (>10 000 yozuv) → background job. Response 202:
> ```json
> {
>   "success": true,
>   "data": {
>     "job_id": "exp_1234abcd",
>     "status": "queued",
>     "estimated_seconds": 60,
>     "check_url": "/api/v1/admin/exports/exp_1234abcd"
>   },
>   "message": "Eksport tayyorlanmoqda. Tayyor bo'lganda bildirishnoma keladi"
> }
> ```

---

## 7. ARIZA STATUS TARIXI

### `GET /api/v1/admin/installations/{id}/history`

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 9001,
      "from_status": null,
      "to_status": "pending",
      "admin": null,
      "reason": null,
      "context": {"created_via": "telegram_bot"},
      "notification_status": "sent",
      "notification_error": null,
      "notification_sent_at": "2026-04-18T10:25:05Z",
      "changed_at": "2026-04-18T10:25:00Z"
    },
    {
      "id": 9002,
      "from_status": "pending",
      "to_status": "approved",
      "admin": {"id": 1, "name": "Aliyev Vali"},
      "reason": "Hammasi joyida",
      "context": {"balance_added": "1425000.00"},
      "notification_status": "sent",
      "notification_sent_at": "2026-04-18T13:30:02Z",
      "changed_at": "2026-04-18T13:30:00Z"
    }
  ]
}
```
