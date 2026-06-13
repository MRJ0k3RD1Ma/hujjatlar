# RFC-006: Yetkazib berish tizimi (BTS Express)

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 006 |
| **Modul** | Yetkazib berish (Delivery) |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Yetkazib berish ikkita usulda amalga oshiriladi: **BTS Express** (pochta xizmati) va **Pickup** (do'kondan olib ketish). BTS Express REST API orqali integratsiya qilinadi — narx avtomatik hisoblanadi, buyurtma yaratiladi va tracking kuzatiladi.

### 1.1 Yetkazib berish usullari

| Usul | Tavsif | Narx | Qamrov |
|------|--------|------|--------|
| `bts_express` | BTS Express pochta | BTS API dan hisoblanadi | Butun O'zbekiston |
| `pickup` | Do'kondan olib ketish | Bepul | Do'kon manzili |

### 1.2 BTS Express API

- **Base URL:** `http://api.bts.uz:8080`
- **Auth:** `Authorization: Bearer {BTS_TOKEN}`
- Backend BTS API ni proxy qiladi — frontend to'g'ridan-to'g'ri BTS ga murojaat qilmaydi

---

## 2. API Endpointlar

### 2.1 Shaharlar ro'yxati

**`GET /api/delivery/cities`**

BTS Express xizmat ko'rsatadigan shaharlar. Backend BTS dan olib cache qiladi.

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "bts_city_id": 100,
      "name": "Toshkent",
      "region": "Toshkent shahri"
    },
    {
      "id": 2,
      "bts_city_id": 101,
      "name": "Samarqand",
      "region": "Samarqand viloyati"
    },
    {
      "id": 3,
      "bts_city_id": 102,
      "name": "Buxoro",
      "region": "Buxoro viloyati"
    }
  ]
}
```

**Biznes qoidalar:**
- Auth talab qilinmaydi
- Ma'lumotlar `delivery_cities` jadvalida cache qilinadi
- Backend muntazam (kuniga 1 marta) BTS dan yangilaydi
- `name` — `Accept-Language` ga qarab `name_uz` yoki `name_ru`

---

### 2.2 Yetkazib berish narxini hisoblash

**`POST /api/delivery/calculate`**

Checkout paytida foydalanuvchiga yetkazib berish narxini ko'rsatish.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "city_id": 2,
  "weight": 1.5
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "delivery_fee": 35000,
    "estimated_days": "2-3",
    "provider": "BTS Express"
  }
}
```

**Biznes qoidalar:**
- `city_id` — `delivery_cities` jadvalidagi ID
- `weight` — og'irlik kg da
- Backend BTS `/v1/order/calculate` API ga so'rov yuboradi
- Jo'natuvchi shahar — do'konning manzili (sozlamalardan)
- Agar BTS API javob bermasa — xato qaytariladi

---

### 2.3 Buyurtma tracking

**`GET /api/delivery/track/:orderId`**

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK) — BTS Express:**
```json
{
  "success": true,
  "data": {
    "order_id": 1001,
    "delivery_method": "bts_express",
    "tracking_code": "BTS-1234567",
    "status": "in_transit",
    "estimated_date": "2026-02-09",
    "delivered_at": null,
    "history": [
      {
        "status": "created",
        "description": "Jo'natma qabul qilindi",
        "location": "Toshkent",
        "timestamp": "2026-02-06T16:00:00Z"
      },
      {
        "status": "in_transit",
        "description": "Yo'lda",
        "location": "Toshkent → Samarqand",
        "timestamp": "2026-02-07T08:00:00Z"
      }
    ]
  }
}
```

**Response — Pickup:**
```json
{
  "success": true,
  "data": {
    "order_id": 1002,
    "delivery_method": "pickup",
    "tracking_code": null,
    "status": "preparing",
    "estimated_date": null,
    "delivered_at": null,
    "pickup_address": {
      "address": "Toshkent, Yunusobod tumani, Amir Temur ko'chasi 15",
      "phone": "+998901234567",
      "working_hours": "09:00 - 18:00"
    },
    "history": []
  }
}
```

---

## 3. Checkout da yetkazib berish oqimi

```
Frontend                         Backend                    BTS API
   |                                |                          |
   |-- Manzil tanlash (city_id) --->|                          |
   |-- POST /delivery/calculate --->|                          |
   |                                |-- /v1/order/calculate -->|
   |                                |<-- narx + muddat --------|
   |<-- delivery_fee + days --------|                          |
   |                                |                          |
   |-- Foydalanuvchi tasdiqlaydi    |                          |
   |-- POST /api/orders ----------->|                          |
   |                                |-- Buyurtma yaratish      |
   |<-- payment_url ----------------|                          |
   |                                |                          |
   |   ... to'lov jarayoni ...      |                          |
   |                                |                          |
   |                                |-- (to'lov tasdiqlandi)   |
   |                                |                          |
   |   Admin "BTS ga yuborish" --->|                          |
   |                                |-- /v1/order/add -------->|
   |                                |<-- tracking_code --------|
   |                                |                          |
   |-- GET /delivery/track/1001 --->|                          |
   |                                |-- /v1/order/track ------>|
   |                                |<-- holat ----------------|
   |<-- tracking ma'lumotlari ------|                          |
```

---

## 4. BTS Express API reference (Backend uchun)

| BTS Endpoint | Method | Tavsif |
|-------------|--------|--------|
| `/v1/order/calculate` | POST | Narx hisoblash |
| `/v1/order/add` | POST | Buyurtma yaratish |
| `/v1/order/track` | GET | Tracking holat |
| `/v1/order/cancel` | GET | Bekor qilish |
| `/v1/order/detail` | GET | Batafsil ma'lumot |
| `/v1/order/history` | GET | Buyurtma tarixi |

---

## 5. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_CITY` | Shahar topilmadi | Noto'g'ri city_id |
| 400 | `INVALID_WEIGHT` | Og'irlik noto'g'ri | 0 yoki manfiy |
| 404 | `ORDER_NOT_FOUND` | Buyurtma topilmadi | Tracking uchun |
| 404 | `DELIVERY_NOT_FOUND` | Yetkazib berish ma'lumoti yo'q | Pickup yoki hali yuborilmagan |
| 422 | `BTS_API_ERROR` | BTS API xatosi | BTS javob bermayapti |
| 422 | `BTS_CITY_NOT_SERVED` | BTS bu shaharga xizmat qilmaydi | Nofaol shahar |
| 503 | `BTS_UNAVAILABLE` | BTS xizmati vaqtincha ishlamayapti | Timeout yoki 5xx |

---

## 6. TypeScript interfeyslar

```typescript
// ============================================
// Delivery types
// ============================================

type DeliveryMethod = "bts_express" | "pickup";
type DeliveryStatus = "preparing" | "created" | "in_transit" | "delivered";

interface DeliveryCity {
  id: number;
  bts_city_id: number;
  name: string;
  region: string;
}

interface DeliveryCalculateRequest {
  city_id: number;
  weight: number; // kg
}

interface DeliveryCalculateData {
  delivery_fee: number;     // so'mda
  estimated_days: string;   // "2-3"
  provider: string;         // "BTS Express"
}

interface DeliveryTrackingHistory {
  status: string;
  description: string;
  location: string;
  timestamp: string;
}

interface DeliveryTracking {
  order_id: number;
  delivery_method: DeliveryMethod;
  tracking_code: string | null;
  status: DeliveryStatus;
  estimated_date: string | null;
  delivered_at: string | null;
  history: DeliveryTrackingHistory[];
  pickup_address?: {
    address: string;
    phone: string;
    working_hours: string;
  };
}
```

---

## 7. Frontend uchun eslatmalar

1. **Checkout manzil qadami:** Foydalanuvchi mavjud manzillardan tanlaydi yoki yangi manzil kiritadi. Shahar tanlanganda avtomatik `POST /delivery/calculate` chaqiriladi va yetkazib berish narxi ko'rsatiladi.

2. **Og'irlik hisoblash:** Hozircha backend savatdagi mahsulotlarning umumiy og'irligini hisoblaydi. Agar mahsulotlarda og'irlik kiritilmagan bo'lsa — standart 0.5 kg ishlatiladi.

3. **Pickup UX:** Pickup tanlanganda do'kon manzili, telefoni va ish vaqti ko'rsatiladi. Manzil kiritish qadami o'tkazib yuboriladi.

4. **Tracking sahifasi:** Buyurtma batafsil sahifasida timeline ko'rinishida tracking holati. Har safar sahifa ochilganda yangi ma'lumot olinadi (real-time polling kerak emas).

5. **BTS xatosi:** Agar BTS API ishlamayapti bo'lsa — "Yetkazib berish narxini hisoblash vaqtincha mumkin emas, iltimos keyinroq urinib ko'ring" xabari.
