# 06 — DASHBOARD

> Bosh sahifadagi widgetlar, statistikalar va grafiklar uchun endpointlar.

---

## 1. UMUMIY STATISTIKA WIDGETS

### `GET /api/v1/admin/dashboard/stats`

#### Request
```http
GET /api/v1/admin/dashboard/stats?period=month
Authorization: Bearer {access_token}
```

| Parametr | Tip | Default | Variantlar |
|----------|-----|---------|-----------|
| `period` | enum | `month` | `today`, `week`, `month`, `year`, `all` |
| `compare` | bool | `true` | Oldingi davr bilan solishtirish |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "period": "2026-04",
    "compared_to": "2026-03",
    "widgets": {
      "installations_total": {
        "value": 245,
        "previous": 198,
        "change_percent": 23.7,
        "trend": "up"
      },
      "inverters_installed": {
        "value": 312,
        "previous": 245,
        "change_percent": 27.3,
        "trend": "up"
      },
      "materials_used": {
        "value": 1450,
        "previous": 1100,
        "change_percent": 31.8,
        "trend": "up"
      },
      "total_points_earned": {
        "value": 73500,
        "previous": 58200,
        "change_percent": 26.3,
        "trend": "up"
      },
      "total_amount_paid": {
        "value": "367500000.00",
        "previous": "291000000.00",
        "change_percent": 26.3,
        "trend": "up",
        "currency": "UZS"
      },
      "pending_withdrawals": {
        "value": "12500000.00",
        "count": 8,
        "currency": "UZS"
      },
      "active_users": {
        "value": 145,
        "previous": 130,
        "change_percent": 11.5,
        "trend": "up"
      },
      "new_users": {
        "value": 23,
        "previous": 18,
        "change_percent": 27.8,
        "trend": "up"
      }
    }
  }
}
```

---

## 2. ARIZALAR DINAMIKASI

### `GET /api/v1/admin/dashboard/installations-chart`

#### Request
```http
GET /api/v1/admin/dashboard/installations-chart?period=month&granularity=day
```

| Parametr | Variantlar |
|----------|-----------|
| `period` | `week`, `month`, `quarter`, `year` |
| `granularity` | `hour`, `day`, `week`, `month` |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "labels": ["2026-04-01", "2026-04-02", "2026-04-03", "..."],
    "datasets": [
      {
        "label": "Tasdiqlangan",
        "data": [12, 15, 8, 20, 25, 18, 22],
        "color": "#52c41a"
      },
      {
        "label": "Rad etilgan",
        "data": [1, 2, 0, 3, 2, 1, 0],
        "color": "#ff4d4f"
      },
      {
        "label": "Ko'rib chiqilmoqda",
        "data": [3, 4, 2, 5, 6, 4, 3],
        "color": "#faad14"
      }
    ],
    "total": {
      "approved": 120,
      "rejected": 9,
      "pending": 27
    }
  }
}
```

---

## 3. CHIQIM DINAMIKASI

### `GET /api/v1/admin/dashboard/withdrawals-chart`

```http
GET /api/v1/admin/dashboard/withdrawals-chart?period=month&granularity=day
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "labels": ["2026-04-01", "2026-04-02", "..."],
    "datasets": [
      {
        "label": "Yangi so'rovlar (so'm)",
        "data": [1500000, 2300000, 1200000, "..."],
        "color": "#1890ff",
        "type": "bar"
      },
      {
        "label": "To'langan (so'm)",
        "data": [1200000, 2000000, 1500000, "..."],
        "color": "#52c41a",
        "type": "bar"
      }
    ],
    "total": {
      "requested": "85000000.00",
      "paid": "72000000.00",
      "rejected": "3000000.00"
    }
  }
}
```

---

## 4. INVERTORLAR BO'YICHA STATISTIKA

### `GET /api/v1/admin/dashboard/top-inverters`

```http
GET /api/v1/admin/dashboard/top-inverters?period=month&limit=10
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "inverter_id": 5,
      "model": "Deye SUN-12K",
      "manufacturer": "Deye",
      "installations_count": 45,
      "total_units": 87,
      "total_points": 10440,
      "total_amount": "52200000.00"
    },
    {
      "inverter_id": 8,
      "model": "Huawei SUN2000-10K",
      "manufacturer": "Huawei",
      "installations_count": 32,
      "total_units": 45,
      "total_points": 5400,
      "total_amount": "27000000.00"
    }
  ]
}
```

---

## 5. MATERIALLAR BO'YICHA STATISTIKA

### `GET /api/v1/admin/dashboard/top-materials`

```http
GET /api/v1/admin/dashboard/top-materials?period=month&limit=10
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "material_id": 1,
      "name": "Kabel 4mm²",
      "unit": "meter",
      "usage_count": 234,
      "total_quantity": "3450.00",
      "total_points": 6900,
      "total_amount": "34500000.00"
    }
  ]
}
```

---

## 6. VILOYAT BO'YICHA STATISTIKA

### `GET /api/v1/admin/dashboard/regions-stats`

```http
GET /api/v1/admin/dashboard/regions-stats?period=month
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "region_id": 1,
      "region_title": "Toshkent shahri",
      "users_count": 85,
      "installations_count": 145,
      "total_amount": "72500000.00",
      "withdrawals_paid": "55000000.00"
    },
    {
      "region_id": 2,
      "region_title": "Toshkent viloyati",
      "users_count": 65,
      "installations_count": 98,
      "total_amount": "49000000.00",
      "withdrawals_paid": "32000000.00"
    }
  ]
}
```

---

## 7. TOP USTALAR

### `GET /api/v1/admin/dashboard/top-users`

```http
GET /api/v1/admin/dashboard/top-users?period=month&limit=10&sort=total_amount
```

| Parametr | Variantlar |
|----------|-----------|
| `sort` | `total_amount`, `installations_count`, `total_points` |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "user_id": 15,
      "name": "Ismoilov Abdulloh",
      "phone": "+998901234567",
      "region": "Toshkent shahri",
      "installations_count": 12,
      "total_points": 2850,
      "total_amount": "14250000.00"
    }
  ]
}
```

---

## 8. SO'NGI HARAKATLAR (Activity feed)

### `GET /api/v1/admin/dashboard/activity-feed`

```http
GET /api/v1/admin/dashboard/activity-feed?limit=20
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": "feed_001",
      "type": "installation_created",
      "title": "Yangi ariza #1234",
      "description": "Ismoilov Abdulloh yangi ariza yubordi (2 invertor, 285 ball)",
      "user": {"id": 15, "name": "Ismoilov Abdulloh"},
      "ref": {"type": "installation", "id": 1234, "url": "/installations/1234"},
      "created_at": "2026-04-18T13:25:00Z"
    },
    {
      "id": "feed_002",
      "type": "withdrawal_created",
      "title": "Yangi chiqim so'rovi #567",
      "description": "Karimov Sherzod 1 200 000 so'm yechmoqchi",
      "user": {"id": 23, "name": "Karimov Sherzod"},
      "ref": {"type": "withdrawal", "id": 567, "url": "/withdrawals/567"},
      "created_at": "2026-04-18T13:20:00Z"
    },
    {
      "id": "feed_003",
      "type": "installation_approved",
      "title": "Ariza tasdiqlandi #1230",
      "description": "Aliyev Vali tomonidan tasdiqlandi (1 425 000 so'm)",
      "admin": {"id": 1, "name": "Aliyev Vali"},
      "ref": {"type": "installation", "id": 1230, "url": "/installations/1230"},
      "created_at": "2026-04-18T13:15:00Z"
    }
  ]
}
```

---

## 9. NOTIFICATIONS / ALERTS

### `GET /api/v1/admin/dashboard/alerts`

> Backend tomonidan aniqlangan muhim xabarlar (failed notifications, suspicious activity, etc.)

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": "alert_001",
      "level": "warning",
      "type": "notification_failed",
      "message": "5 ta foydalanuvchiga Telegram xabar yetkazilmadi",
      "details": {"failed_count": 5, "since": "2026-04-18T08:00:00Z"},
      "action_url": "/logs?notification_status=failed",
      "created_at": "2026-04-18T13:00:00Z"
    },
    {
      "id": "alert_002",
      "level": "info",
      "type": "pending_withdrawals",
      "message": "8 ta chiqim so'rovi 24 soatdan ko'p kutmoqda",
      "details": {"oldest_request_id": 560, "oldest_age_hours": 36},
      "action_url": "/withdrawals?status=pending",
      "created_at": "2026-04-18T13:05:00Z"
    },
    {
      "id": "alert_003",
      "level": "danger",
      "type": "pin_lockouts",
      "message": "1 soat ichida 12 ta PIN lockout (g'ayri-oddiy faollik)",
      "details": {"count": 12, "since": "2026-04-18T12:00:00Z"},
      "action_url": "/users?pin_locked=true",
      "created_at": "2026-04-18T13:10:00Z"
    }
  ],
  "meta": {"total": 3, "by_level": {"info": 1, "warning": 1, "danger": 1}}
}
```

---

## 10. POLLING TAVSIYASI

| Endpoint | Polling interval |
|----------|------------------|
| `/dashboard/stats` | 60s |
| `/dashboard/activity-feed` | 30s |
| `/dashboard/alerts` | 30s |
| `/withdrawals` (pending) | 15s |
| Boshqalar | 60s+ |

> 💡 v3.0 da WebSocket push joriy etiladi → polling olib tashlanadi.
