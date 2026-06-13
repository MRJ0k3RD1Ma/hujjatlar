# RFC-005: To'lov tizimi (Click + Payme)

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 005 |
| **Modul** | To'lov integratsiyasi |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Platforma ikkita to'lov tizimini qo'llab-quvvatlaydi: **Click** va **Payme**. Ikkala tizim ham redirect model asosida ishlaydi — foydalanuvchi to'lov provayderining sahifasida karta ma'lumotlarini kiritadi. Natija webhook orqali backend ga qaytariladi.

### 1.1 To'lov jarayoni (umumiy)

```
Frontend                Backend              To'lov provider
   |                       |                       |
   |-- POST /api/orders -->|                       |
   |                       |-- Buyurtma yaratish   |
   |                       |-- Payment yaratish    |
   |<-- payment_url -------|                       |
   |                       |                       |
   |-- redirect ---------> | -------redirect-----> |
   |                       |                       |
   |                       |<-- webhook (prepare)--|
   |                       |-- OK ----------------->|
   |                       |                       |
   |                       |<-- webhook (complete)-|
   |                       |-- OK ----------------->|
   |                       |-- Buyurtma: paid      |
   |                       |                       |
   |<-- return_url --------|<----------------------|
   |                       |                       |
   |-- GET /orders/:id --->|                       |
   |<-- buyurtma holati ---|                       |
```

### 1.2 To'lov URL formatlari

**Click redirect URL:**
```
https://my.click.uz/services/pay?service_id={SERVICE_ID}&merchant_id={MERCHANT_ID}&amount={AMOUNT}&transaction_param={ORDER_NUMBER}&return_url={RETURN_URL}
```

**Payme redirect URL:**
```
https://checkout.paycom.uz/{BASE64_ENCODED_PARAMS}
```

Base64 params:
```json
{
  "m": "{MERCHANT_ID}",
  "ac": { "order_id": "{ORDER_NUMBER}" },
  "a": {AMOUNT_IN_TIYIN},
  "c": "{RETURN_URL}"
}
```

---

## 2. Frontend API Endpointlar

### 2.1 To'lov yaratish

Buyurtma yaratish (`POST /api/orders`) javobida `payment_url` qaytariladi (RFC-004 da tavsiflangan). Alohida to'lov yaratish endpointi ham mavjud — bu `pending` holatdagi buyurtma uchun qayta to'lov urinishi kerak bo'lganda ishlatiladi.

**`POST /api/payment/create`**

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "order_id": 1001,
  "payment_method": "click"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "payment_url": "https://my.click.uz/services/pay?service_id=XXX&merchant_id=XXX&amount=11435000&transaction_param=ORD-20260206-1001&return_url=https://site.uz/payment/result",
    "expires_in": 1800,
    "order_number": "ORD-20260206-1001",
    "amount": 11435000,
    "payment_method": "click"
  }
}
```

**Biznes qoidalar:**
- Faqat `pending` holatdagi buyurtma uchun ishlaydi
- To'lov muddati o'tmagan bo'lishi kerak
- Foydalanuvchi faqat o'z buyurtmasi uchun to'lov yarata oladi
- Oldingi to'lov urinishi muvaffaqiyatsiz bo'lgan bo'lsa, yangi to'lov yaratiladi

---

### 2.2 To'lov natijasi sahifasi

To'lov provayderidan qaytgandan keyin foydalanuvchi `/payment/result` sahifasiga tushadi.

**URL format:**
```
https://site.uz/payment/result?order_number=ORD-20260206-1001
```

Frontend bu sahifada buyurtma holatini polling bilan tekshiradi:

**`GET /api/orders/:id`** — RFC-004 dagi endpoint

**Polling logikasi:**
1. Sahifa ochilganda buyurtma holatini so'rash
2. Agar `pending` bo'lsa — har 3 soniyada qayta so'rash
3. Agar `paid` bo'lsa — muvaffaqiyat ko'rsatish
4. Agar `cancelled` bo'lsa — muvaffaqiyatsiz ko'rsatish
5. Maksimal 60 soniya polling, keyin "To'lov tekshirilmoqda" xabari

---

## 3. Webhook Endpointlar (Backend uchun)

Bu endpointlar to'lov provayderlar tomonidan chaqiriladi. Frontend bu endpointlarni chaqirmaydi, lekin to'lov oqimini tushunish uchun hujjatlashtirilgan.

### 3.1 Click webhooks

**`POST /api/payment/click/prepare`**

Click to'lov boshlanganini xabar beradi.

**Click yuboradi:**
```json
{
  "click_trans_id": 12345678,
  "service_id": 1234,
  "click_paydoc_id": 87654321,
  "merchant_trans_id": "ORD-20260206-1001",
  "amount": 11435000,
  "action": 0,
  "error": 0,
  "error_note": "",
  "sign_time": "2026-02-06 14:31:00",
  "sign_string": "md5_hash_here"
}
```

**Backend javobi:**
```json
{
  "click_trans_id": 12345678,
  "merchant_trans_id": "ORD-20260206-1001",
  "merchant_prepare_id": 1,
  "error": 0,
  "error_note": "Success"
}
```

**`POST /api/payment/click/complete`**

Click to'lov yakunlanganini xabar beradi.

**Click yuboradi:**
```json
{
  "click_trans_id": 12345678,
  "service_id": 1234,
  "click_paydoc_id": 87654321,
  "merchant_trans_id": "ORD-20260206-1001",
  "merchant_prepare_id": 1,
  "amount": 11435000,
  "action": 1,
  "error": 0,
  "error_note": "",
  "sign_time": "2026-02-06 14:32:00",
  "sign_string": "md5_hash_here"
}
```

**Backend validatsiya:**
- `sign_string` — MD5 hash tekshirish (Click secret key bilan)
- `amount` — buyurtma `total` bilan taqqoslash
- `merchant_trans_id` — buyurtma mavjudligini tekshirish

---

### 3.2 Payme webhooks

**`POST /api/payment/payme`**

Payme JSON-RPC 2.0 formatda ishlaydi. Bitta endpoint, methodlar:

**CheckPerformTransaction** — buyurtma to'lash mumkinligini tekshirish:
```json
{
  "method": "CheckPerformTransaction",
  "params": {
    "amount": 1143500000,
    "account": {
      "order_id": "ORD-20260206-1001"
    }
  }
}
```

**CreateTransaction** — tranzaksiya yaratish:
```json
{
  "method": "CreateTransaction",
  "params": {
    "id": "payme_transaction_id",
    "time": 1707220260000,
    "amount": 1143500000,
    "account": {
      "order_id": "ORD-20260206-1001"
    }
  }
}
```

**PerformTransaction** — to'lovni tasdiqlash:
```json
{
  "method": "PerformTransaction",
  "params": {
    "id": "payme_transaction_id"
  }
}
```

**CancelTransaction** — bekor qilish:
```json
{
  "method": "CancelTransaction",
  "params": {
    "id": "payme_transaction_id",
    "reason": 3
  }
}
```

**CheckTransaction** — holat tekshirish:
```json
{
  "method": "CheckTransaction",
  "params": {
    "id": "payme_transaction_id"
  }
}
```

**Payme autentifikatsiya:** HTTP Basic Auth — `Authorization: Basic base64(merchant_id:secret_key)`

> **Eslatma:** Payme `amount` **tiyinda** (so'm × 100). 11,435,000 so'm = 1,143,500,000 tiyin.

---

## 4. Backend to'lov qoidalari

Backend dasturchi uchun muhim qoidalar:

1. **Idempotency:** Bir xil webhook ikki marta kelsa — qayta ishlanmasligi kerak
2. **Summa tekshirish:** Webhook dagi `amount` buyurtma `total` bilan mos kelishi kerak
3. **Logging:** Barcha `raw_request` va `raw_response` `payments` jadvalida JSONB da saqlanadi
4. **Holat yangilash:** Muvaffaqiyatli to'lovda `orders.status → paid`, `orders.paid_at` belgilanadi
5. **Stock kamayish:** `paid` bo'lganda `stock_quantity` kamayadi
6. **Timeout:** `pending` buyurtma 30 daqiqadan keyin avtomatik `cancelled` (cron job)

---

## 5. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_PAYMENT_METHOD` | Noto'g'ri to'lov usuli | click/payme dan boshqa |
| 404 | `ORDER_NOT_FOUND` | Buyurtma topilmadi | Noto'g'ri order_id |
| 409 | `ORDER_NOT_PENDING` | Buyurtma pending holatda emas | To'langan yoki bekor qilingan |
| 409 | `PAYMENT_EXPIRED` | To'lov muddati o'tgan | 30 daqiqadan keyin |
| 409 | `PAYMENT_ALREADY_PROCESSING` | To'lov allaqachon jarayonda | Parallel urinish |
| 409 | `AMOUNT_MISMATCH` | Summa mos kelmaydi | Webhook dagi summa farqli |

---

## 6. TypeScript interfeyslar

```typescript
// ============================================
// Payment types
// ============================================

type PaymentMethod = "click" | "payme";

type PaymentStatus =
  | "pending"
  | "processing"
  | "completed"
  | "failed"
  | "cancelled"
  | "refunded";

interface CreatePaymentRequest {
  order_id: number;
  payment_method: PaymentMethod;
}

interface CreatePaymentData {
  payment_url: string;
  expires_in: number;       // soniyalarda
  order_number: string;
  amount: number;           // so'mda
  payment_method: PaymentMethod;
}

// Admin uchun to'lov ma'lumotlari
interface PaymentRecord {
  id: number;
  order_id: number;
  provider: PaymentMethod;
  provider_transaction_id: string | null;
  amount: number;
  status: PaymentStatus;
  paid_at: string | null;
  error_message: string | null;
  created_at: string;
  updated_at: string;
}

// To'lov natija sahifasi uchun
interface PaymentResultPage {
  order_number: string;
  status: "success" | "pending" | "failed";
  amount: number;
  payment_method: PaymentMethod;
  message: string;
}
```

---

## 7. Frontend uchun eslatmalar

1. **Redirect flow:** Buyurtma yaratilgandan keyin `payment_url` ga to'liq sahifa redirect qilinadi (iframe emas). Mobile da ham ishlaydi.

2. **Return URL:** To'lov provayderidan qaytganda `/payment/result?order_number=XXX` sahifasiga tushiladi. Bu sahifada buyurtma holati ko'rsatiladi.

3. **Polling UX:** "To'lov tekshirilmoqda..." loading holati. Muvaffaqiyatda confetti/checkmark animatsiya. Muvaffaqiyatsizda xato xabari va "Qayta urinish" tugmasi.

4. **Qayta to'lov:** Agar to'lov muvaffaqiyatsiz bo'lsa va buyurtma hali `pending` da bo'lsa — `POST /api/payment/create` orqali qayta to'lov yaratiladi.

5. **Timeout UX:** Buyurtma yaratilgandan keyin 30 daqiqalik timer ko'rsatiladi. Muddat tugashiga yaqin ogohlantirish chiqadi.

6. **Admin to'lovlar:** Admin panelda to'lovlar tarixi — `payments` jadvali orqali. Har bir to'lovning holati, muddati, xato xabari ko'rsatiladi.
