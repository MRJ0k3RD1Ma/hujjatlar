# 04 — KATALOG (Invertorlar, Materiallar, Hududlar, Sozlamalar)

> CRUD endpointlari. Asosan **superadmin** uchun. `GET` operatsiyalari oddiy admin uchun ham ochiq.

---

## 1. INVERTORLAR

### 1.1 Ro'yxat
**`GET /api/v1/admin/inverters`**

```http
GET /api/v1/admin/inverters?status=active&search=deye&sort=model&page=1&per_page=50
Authorization: Bearer {access_token}
```

#### Query
| Parametr | Tip | Izoh |
|----------|-----|------|
| `status` | enum | `active`, `inactive` |
| `search` | string | model yoki manufacturer bo'yicha |
| `sort` | string | `model`, `-created_at`, `points_per_unit` |

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "model": "Deye SUN-12K",
      "manufacturer": "Deye",
      "power_kw": "12.00",
      "points_per_unit": 120,
      "status": "active",
      "usage_count": 45,
      "created_at": "2026-01-10T08:00:00Z",
      "updated_at": "2026-04-15T10:30:00Z"
    }
  ],
  "meta": {"pagination": {"page": 1, "per_page": 50, "total": 12, "total_pages": 1}}
}
```

### 1.2 Yaratish
**`POST /api/v1/admin/inverters`** *(superadmin)*

#### Request
```json
{
  "model": "Huawei SUN2000-15K",
  "manufacturer": "Huawei",
  "power_kw": "15.00",
  "points_per_unit": 150,
  "status": "active"
}
```

#### Validatsiya
| Field | Rules |
|-------|-------|
| `model` | required, 2–255 belgi, unique |
| `manufacturer` | string?, max 255 |
| `power_kw` | decimal?, 0.1–10000 |
| `points_per_unit` | required, int, 1–100000 |
| `status` | enum, default `active` |

#### Response (201)
```json
{
  "success": true,
  "data": {
    "id": 13,
    "model": "Huawei SUN2000-15K",
    "manufacturer": "Huawei",
    "power_kw": "15.00",
    "points_per_unit": 150,
    "status": "active",
    "created_at": "2026-04-18T14:00:00Z"
  },
  "message": "Invertor qo'shildi"
}
```

### 1.3 Yangilash
**`PUT /api/v1/admin/inverters/{id}`** *(superadmin)*

#### Request — to'liq yoki qisman barcha maydonlar
```json
{
  "model": "Huawei SUN2000-15K Pro",
  "points_per_unit": 160,
  "status": "active"
}
```

#### Response (200)
```json
{
  "success": true,
  "data": { /* yangilangan invertor */ },
  "message": "Invertor yangilandi"
}
```

> ⚠️ `points_per_unit` o'zgartirilsa, **eski arizalar hisobi o'zgarmaydi** (snapshot mantiq). Faqat keyingi yangi arizalar uchun amal qiladi.

### 1.4 O'chirish (soft delete)
**`DELETE /api/v1/admin/inverters/{id}`** *(superadmin)*

> Real `DELETE` emas, `status='inactive'` qiladi. Bu invertor ariza tarixida ko'rinadi, lekin yangi ariza uchun tanlanmaydi.

#### Response (200)
```json
{
  "success": true,
  "message": "Invertor nofaol holatga o'tkazildi"
}
```

---

## 2. MATERIALLAR

### 2.1 Ro'yxat
**`GET /api/v1/admin/materials`**

```http
GET /api/v1/admin/materials?status=active&unit=meter&sort=name
```

#### Response (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Kabel 4mm²",
      "unit": "meter",
      "points_per_unit": 2,
      "status": "active",
      "usage_count": 234,
      "created_at": "2026-01-10T08:00:00Z"
    },
    {
      "id": 2,
      "name": "Montaj to'plami",
      "unit": "set",
      "points_per_unit": 5,
      "status": "active",
      "usage_count": 145
    }
  ]
}
```

### 2.2 Yaratish
**`POST /api/v1/admin/materials`** *(superadmin)*

#### Request
```json
{
  "name": "Akkumulyator BAT-100Ah",
  "unit": "piece",
  "points_per_unit": 50,
  "status": "active"
}
```

#### Validatsiya
| Field | Rules |
|-------|-------|
| `name` | required, 2–255 belgi |
| `unit` | required, enum: `meter`, `piece`, `set`, `kg` |
| `points_per_unit` | required, int, 1–100000 |
| `status` | enum, default `active` |

### 2.3 Yangilash / O'chirish
Invertorlar bilan bir xil pattern (`PUT`, `DELETE`).

---

## 3. HUDUDLAR (Region & District)

### 3.1 Viloyatlar ro'yxati
**`GET /api/v1/admin/regions`**

#### Response (200)
```json
{
  "success": true,
  "data": [
    {"id": 1, "title": "Toshkent shahri", "status": "active", "districts_count": 11},
    {"id": 2, "title": "Toshkent viloyati", "status": "active", "districts_count": 14},
    {"id": 3, "title": "Andijon viloyati", "status": "active", "districts_count": 14}
  ]
}
```

### 3.2 Tumanlar ro'yxati
**`GET /api/v1/admin/districts?region_id=1`**

#### Response (200)
```json
{
  "success": true,
  "data": [
    {"id": 5, "title": "Yunusobod", "region_id": 1, "status": "active"},
    {"id": 6, "title": "Mirzo Ulug'bek", "region_id": 1, "status": "active"}
  ]
}
```

### 3.3 Public endpoint (Bot uchun)
**`GET /api/v1/regions`** — auth talab qilmaydi
**`GET /api/v1/regions/{id}/districts`** — auth talab qilmaydi

> Bot ro'yxatdan o'tish paytida ushbu endpointlardan foydalanadi.

### 3.4 CRUD (superadmin)
**`POST /api/v1/admin/regions`**, **`PUT /api/v1/admin/regions/{id}`**, **`DELETE /api/v1/admin/regions/{id}`** — invertorlar pattern bilan bir xil.

```json
{"title": "Samarqand viloyati"}
```

---

## 4. SOZLAMALAR (Settings)

### 4.1 Hammasini olish
**`GET /api/v1/admin/settings`**

#### Response (200)
```json
{
  "success": true,
  "data": {
    "point_value": "5000",
    "min_kw": "1",
    "max_kw": "1000",
    "max_daily_apps": "3",
    "min_withdrawal_som": "50000",
    "pin_length": "4",
    "pin_max_attempts": "3",
    "pin_lockout_minutes": "30"
  }
}
```

### 4.2 Bitta yangilash
**`PUT /api/v1/admin/settings/{key}`** *(superadmin)*

#### Request
```http
PUT /api/v1/admin/settings/point_value
```

```json
{"value": "5500"}
```

#### Response (200)
```json
{
  "success": true,
  "data": {"key": "point_value", "value": "5500", "updated_at": "2026-04-18T14:00:00Z"},
  "message": "Sozlama yangilandi. O'zgarish faqat yangi arizalar uchun amal qiladi"
}
```

### 4.3 Ko'p sozlamani bir vaqtda yangilash
**`PUT /api/v1/admin/settings`** *(superadmin)*

```json
{
  "point_value": "5500",
  "min_withdrawal_som": "100000",
  "pin_max_attempts": "5"
}
```

### 4.4 Sozlamalar ro'yxati va izohlar

| Key | Tip | Default | Izoh |
|-----|-----|---------|------|
| `point_value` | int | 5000 | 1 ball uchun so'm |
| `min_kw` | int | 1 | Min quvvat (validatsiya) |
| `max_kw` | int | 1000 | Max quvvat (validatsiya) |
| `max_daily_apps` | int | 3 | Bir kunda max ariza |
| `min_withdrawal_som` | int | 50000 | Min chiqim summasi |
| `pin_length` | int | 4 | PIN uzunligi |
| `pin_max_attempts` | int | 3 | Maks. noto'g'ri urinish |
| `pin_lockout_minutes` | int | 30 | Lockout vaqti (daqiqa) |

> 📌 Sozlama o'zgarishi `action_logs` ga yoziladi.

---

## 5. RBAC RUXSATLAR

| Endpoint | Admin | Superadmin |
|----------|-------|------------|
| GET (barchasi) | ✅ | ✅ |
| POST/PUT/DELETE Invertorlar | ❌ | ✅ |
| POST/PUT/DELETE Materiallar | ❌ | ✅ |
| POST/PUT/DELETE Regions/Districts | ❌ | ✅ |
| PUT Settings | ❌ | ✅ |
