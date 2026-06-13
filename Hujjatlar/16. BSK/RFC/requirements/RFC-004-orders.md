# RFC-004: Buyurtma tizimi

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 004 |
| **Modul** | Buyurtma (Order), Checkout |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Checkout — savatdan buyurtmaga o'tish jarayoni. Foydalanuvchi manzilni tanlaydi, yetkazib berish usulini belgilaydi, to'lov usulini tanlaydi va buyurtmani tasdiqlaydi. Buyurtma yaratilgandan keyin to'lov sahifasiga yo'naltiriladi.

### 1.1 Checkout bosqichlari

1. **Savat ko'rish** — mahsulotlar, miqdor, narxlar
2. **Autentifikatsiya** — agar login qilmagan bo'lsa
3. **Manzil tanlash** — mavjud manzildan yoki yangi kiritish
4. **Yetkazib berish usuli** — BTS Express yoki Pickup
5. **To'lov usuli** — Click yoki Payme
6. **Tasdiqlash** — buyurtma xulosasi
7. **To'lov** — to'lov provayderiga yo'naltirish
8. **Natija** — muvaffaqiyatli/muvaffaqiyatsiz

### 1.2 Buyurtma holatlari

| Holat | Tavsif | Kim o'zgartiradi |
|-------|--------|-----------------|
| `pending` | Buyurtma yaratildi, to'lov kutilmoqda | Tizim (checkout) |
| `paid` | To'lov muvaffaqiyatli | Tizim (webhook) |
| `processing` | Admin tayyorlamoqda | Admin |
| `shipped` | BTS Express ga berildi | Admin (BTS ga yuborish) |
| `delivered` | Yetkazib berildi | BTS tracking / Admin |
| `cancelled` | Bekor qilindi | Foydalanuvchi yoki Admin |
| `refunded` | Pul qaytarildi | Admin |

### 1.3 Holat o'tishlari

```
pending → paid → processing → shipped → delivered
pending → cancelled
paid → cancelled → refunded
paid → processing → cancelled → refunded
```

---

## 2. API Endpointlar

### 2.1 Buyurtma yaratish (Checkout)

**`POST /api/orders`**

Savatdan buyurtma yaratadi. Buyurtma `pending` holatda yaratiladi.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "address_id": 5,
  "delivery_method": "bts_express",
  "payment_method": "click",
  "notes": "Iltimos, eshik oldiga qo'ying"
}
```

**Pickup uchun request:**
```json
{
  "delivery_method": "pickup",
  "payment_method": "payme",
  "notes": null
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Buyurtma yaratildi",
  "data": {
    "order": {
      "id": 1001,
      "order_number": "ORD-20260206-1001",
      "status": "pending",
      "items": [
        {
          "id": 1,
          "product_name": "AMD Ryzen 7 7800X3D",
          "product_image": "https://api.site.uz/uploads/products/101/main.webp",
          "price": 4800000,
          "quantity": 2,
          "subtotal": 9600000
        },
        {
          "id": 2,
          "product_name": "Corsair Vengeance 32GB DDR5",
          "product_image": "https://api.site.uz/uploads/products/205/main.webp",
          "price": 1800000,
          "quantity": 1,
          "subtotal": 1800000
        }
      ],
      "subtotal": 11400000,
      "delivery_fee": 35000,
      "discount_amount": 800000,
      "total": 11435000,
      "delivery_method": "bts_express",
      "delivery_address": {
        "region": "Toshkent shahri",
        "city": "Toshkent",
        "district": "Yunusobod",
        "street": "Amir Temur ko'chasi",
        "house": "15",
        "apartment": "42",
        "landmark": "Metro yonida"
      },
      "payment_method": "click",
      "notes": "Iltimos, eshik oldiga qo'ying",
      "created_at": "2026-02-06T14:30:00Z"
    },
    "payment": {
      "payment_url": "https://my.click.uz/services/pay?service_id=XXX&merchant_id=XXX&amount=11435000&transaction_param=ORD-20260206-1001&return_url=https://site.uz/payment/result",
      "expires_in": 1800
    }
  }
}
```

**Biznes qoidalar:**
- Savat bo'sh bo'lmasligi kerak
- Barcha mahsulotlar `in_stock` va `is_active` bo'lishi kerak
- `delivery_method: bts_express` bo'lsa `address_id` majburiy
- `delivery_method: pickup` bo'lsa `address_id` kerak emas
- Buyurtma yaratilganda mahsulot ma'lumotlari **snapshot** qilinadi (`order_items` ga narx, nom, rasm ko'chiriladi)
- `delivery_fee` — BTS API dan hisoblangan narx (pickup da 0)
- `discount_amount` — chegirma (agar mahsulotda `discount_price` bo'lsa, farq)
- `payment_url` — foydalanuvchi shu URL ga yo'naltiriladi
- Buyurtma 30 daqiqa (1800s) ichida to'lanmasa — avtomatik `cancelled` bo'ladi
- Savatdagi mahsulotlar buyurtma yaratilgandan keyin savatdan o'chiriladi
- `stock_quantity` to'lov tasdiqlanganda (`paid` bo'lganda) kamayadi, `pending` da kamamaydi

---

### 2.2 Buyurtmalarim

**`GET /api/orders`**

Foydalanuvchining barcha buyurtmalari.

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 10 | Har sahifada |
| `status` | string | — | Holat bo'yicha filter |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 1001,
        "order_number": "ORD-20260206-1001",
        "status": "paid",
        "total": 11435000,
        "items_count": 3,
        "first_item": {
          "product_name": "AMD Ryzen 7 7800X3D",
          "product_image": "https://api.site.uz/uploads/products/101/main.webp"
        },
        "delivery_method": "bts_express",
        "payment_method": "click",
        "created_at": "2026-02-06T14:30:00Z",
        "paid_at": "2026-02-06T14:32:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total_items": 5,
      "total_pages": 1,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

---

### 2.3 Buyurtma batafsil

**`GET /api/orders/:id`**

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1001,
    "order_number": "ORD-20260206-1001",
    "status": "shipped",
    "items": [
      {
        "id": 1,
        "product_id": 101,
        "product_name": "AMD Ryzen 7 7800X3D",
        "product_image": "https://api.site.uz/uploads/products/101/main.webp",
        "price": 4800000,
        "quantity": 2,
        "subtotal": 9600000
      }
    ],
    "subtotal": 11400000,
    "delivery_fee": 35000,
    "discount_amount": 800000,
    "total": 11435000,
    "delivery_method": "bts_express",
    "delivery_address": {
      "region": "Toshkent shahri",
      "city": "Toshkent",
      "district": "Yunusobod",
      "street": "Amir Temur ko'chasi",
      "house": "15",
      "apartment": "42",
      "landmark": "Metro yonida"
    },
    "payment_method": "click",
    "paid_at": "2026-02-06T14:32:00Z",
    "notes": "Iltimos, eshik oldiga qo'ying",
    "delivery": {
      "tracking_code": "BTS-1234567",
      "status": "in_transit",
      "estimated_date": "2026-02-09",
      "delivered_at": null
    },
    "status_history": [
      {
        "from_status": null,
        "to_status": "pending",
        "note": "Buyurtma yaratildi",
        "created_at": "2026-02-06T14:30:00Z"
      },
      {
        "from_status": "pending",
        "to_status": "paid",
        "note": "Click orqali to'landi",
        "created_at": "2026-02-06T14:32:00Z"
      },
      {
        "from_status": "paid",
        "to_status": "processing",
        "note": "Tayyorlanmoqda",
        "created_at": "2026-02-06T15:00:00Z"
      },
      {
        "from_status": "processing",
        "to_status": "shipped",
        "note": "BTS Express ga berildi",
        "created_at": "2026-02-06T16:00:00Z"
      }
    ],
    "created_at": "2026-02-06T14:30:00Z",
    "updated_at": "2026-02-06T16:00:00Z"
  }
}
```

---

### 2.4 Buyurtmani bekor qilish

**`POST /api/orders/:id/cancel`**

**Request:**
```json
{
  "reason": "Boshqa mahsulot tanladim"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Buyurtma bekor qilindi"
}
```

**Biznes qoidalar:**
- Faqat `pending` holatdagi buyurtmani foydalanuvchi bekor qila oladi
- `paid` va undan keyingi holatlarda faqat Admin bekor qila oladi
- Bekor qilinganda `stock_quantity` qaytariladi (agar oldin kamaytilgan bo'lsa)

---

## 3. Admin API Endpointlar

### 3.1 Buyurtmalar ro'yxati

**`GET /api/admin/orders`**

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page`, `per_page` | number | Pagination |
| `status` | string | Holat filter |
| `search` | string | Buyurtma raqami yoki telefon |
| `date_from`, `date_to` | string | Sana oralig'i |
| `payment_method` | string | `click` yoki `payme` |
| `delivery_method` | string | `bts_express` yoki `pickup` |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 1001,
        "order_number": "ORD-20260206-1001",
        "status": "paid",
        "total": 11435000,
        "items_count": 3,
        "user": {
          "id": 5,
          "phone": "+998901234567",
          "first_name": "Sardor"
        },
        "delivery_method": "bts_express",
        "payment_method": "click",
        "created_at": "2026-02-06T14:30:00Z",
        "paid_at": "2026-02-06T14:32:00Z"
      }
    ],
    "pagination": { "..." : "..." },
    "stats": {
      "total_orders": 150,
      "pending": 5,
      "paid": 12,
      "processing": 8,
      "shipped": 20,
      "delivered": 100,
      "cancelled": 5
    }
  }
}
```

---

### 3.2 Buyurtma holatini o'zgartirish

**`PATCH /api/admin/orders/:id`**

**Request:**
```json
{
  "status": "processing",
  "note": "Tayyorlanmoqda"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Buyurtma holati yangilandi",
  "data": {
    "id": 1001,
    "status": "processing",
    "updated_at": "2026-02-06T15:00:00Z"
  }
}
```

**Ruxsat etilgan o'tishlar (Admin):**
- `paid` → `processing`
- `processing` → `shipped` (BTS ga yuborish orqali)
- `shipped` → `delivered`
- `paid` / `processing` → `cancelled`
- `cancelled` → `refunded`

---

### 3.3 BTS Express ga yuborish

**`POST /api/admin/orders/:id/ship`**

Buyurtmani BTS Express ga yuboradi. Avtomatik BTS API ga buyurtma yaratiladi.

**Request:**
```json
{
  "weight": 1.5,
  "note": "Ehtiyotkorlik bilan yetkazing"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Buyurtma BTS Express ga yuborildi",
  "data": {
    "order_id": 1001,
    "status": "shipped",
    "delivery": {
      "bts_order_id": "BTS-789456",
      "tracking_code": "BTS-1234567",
      "estimated_date": "2026-02-09",
      "delivery_fee": 35000
    }
  }
}
```

---

## 4. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `EMPTY_CART` | Savat bo'sh | Savatda mahsulot yo'q |
| 400 | `ADDRESS_REQUIRED` | Manzil kerak | BTS Express tanlangan, manzil yo'q |
| 400 | `INVALID_STATUS_TRANSITION` | Holat o'tishi noto'g'ri | Ruxsat etilmagan o'tish |
| 404 | `ORDER_NOT_FOUND` | Buyurtma topilmadi | Noto'g'ri ID |
| 404 | `ADDRESS_NOT_FOUND` | Manzil topilmadi | Noto'g'ri address_id |
| 409 | `ORDER_ALREADY_CANCELLED` | Buyurtma allaqachon bekor qilingan | Qayta bekor qilish |
| 409 | `ORDER_CANNOT_CANCEL` | Buyurtmani bekor qilib bo'lmaydi | shipped/delivered holatda |
| 409 | `OUT_OF_STOCK` | Mahsulot omborda yo'q | Checkout paytida stock tugagan |
| 409 | `INSUFFICIENT_STOCK` | Yetarli miqdor yo'q | Quantity > stock |
| 409 | `PAYMENT_EXPIRED` | To'lov muddati o'tdi | 30 daqiqadan keyin |
| 422 | `BTS_API_ERROR` | BTS API xatosi | BTS ga yuborishda |

---

## 5. TypeScript interfeyslar

```typescript
// ============================================
// Order types
// ============================================

type OrderStatus =
  | "pending"
  | "paid"
  | "processing"
  | "shipped"
  | "delivered"
  | "cancelled"
  | "refunded";

type DeliveryMethod = "bts_express" | "pickup";
type PaymentMethod = "click" | "payme";

interface OrderItem {
  id: number;
  product_id: number;
  product_name: string;
  product_image: string | null;
  price: number;
  quantity: number;
  subtotal: number;
}

interface OrderAddress {
  region: string;
  city: string;
  district: string | null;
  street: string;
  house: string;
  apartment: string | null;
  landmark: string | null;
}

interface OrderDelivery {
  tracking_code: string | null;
  status: "preparing" | "created" | "in_transit" | "delivered";
  estimated_date: string | null;
  delivered_at: string | null;
}

interface OrderStatusHistory {
  from_status: string | null;
  to_status: string;
  note: string | null;
  created_at: string;
}

// Buyurtmalar ro'yxati (qisqa)
interface OrderListItem {
  id: number;
  order_number: string;
  status: OrderStatus;
  total: number;
  items_count: number;
  first_item: {
    product_name: string;
    product_image: string | null;
  };
  delivery_method: DeliveryMethod;
  payment_method: PaymentMethod;
  created_at: string;
  paid_at: string | null;
}

// Buyurtma batafsil
interface OrderDetail {
  id: number;
  order_number: string;
  status: OrderStatus;
  items: OrderItem[];
  subtotal: number;
  delivery_fee: number;
  discount_amount: number;
  total: number;
  delivery_method: DeliveryMethod;
  delivery_address: OrderAddress | null;
  payment_method: PaymentMethod;
  paid_at: string | null;
  notes: string | null;
  delivery: OrderDelivery | null;
  status_history: OrderStatusHistory[];
  created_at: string;
  updated_at: string;
}

// ============================================
// Request types
// ============================================

interface CreateOrderRequest {
  address_id?: number;       // BTS uchun majburiy
  delivery_method: DeliveryMethod;
  payment_method: PaymentMethod;
  notes?: string | null;
}

interface CancelOrderRequest {
  reason?: string;
}

interface UpdateOrderStatusRequest {
  status: OrderStatus;
  note?: string;
}

interface ShipOrderRequest {
  weight: number;      // kg
  note?: string;
}

// ============================================
// Response types
// ============================================

interface CreateOrderData {
  order: OrderDetail;
  payment: {
    payment_url: string;    // redirect URL
    expires_in: number;     // soniyalarda (1800)
  };
}

// Admin
interface AdminOrderListItem extends OrderListItem {
  user: {
    id: number;
    phone: string;
    first_name: string | null;
  };
}

interface AdminOrdersStats {
  total_orders: number;
  pending: number;
  paid: number;
  processing: number;
  shipped: number;
  delivered: number;
  cancelled: number;
}

interface ShipOrderData {
  order_id: number;
  status: "shipped";
  delivery: {
    bts_order_id: string;
    tracking_code: string;
    estimated_date: string;
    delivery_fee: number;
  };
}
```

---

## 6. Snapshot prinsipi

Buyurtma yaratilganda quyidagi ma'lumotlar **snapshot** (nusxa) qilinadi va buyurtma bilan birga saqlanadi:

| Ma'lumot | Qaerdan | Qaerga |
|----------|---------|--------|
| Mahsulot nomi | `products.name_uz/ru` | `order_items.product_name` |
| Mahsulot rasmi | `product_images` (primary) | `order_items.product_image` |
| Narx | `products.discount_price ?? price` | `order_items.price` |
| Manzil | `user_addresses` | `orders.delivery_address` (JSONB) |

**Sababi:** Keyinchalik mahsulot narxi o'zgarsa yoki manzil o'chirilsa — buyurtma ma'lumotlari o'zgarmaydi.

---

## 7. Frontend uchun eslatmalar

1. **Checkout flow:** Multi-step forma (stepper). Har bir qadam validatsiya qilinadi. Orqaga qaytish mumkin. Faqat oxirgi qadamda buyurtma yaratiladi.

2. **To'lov redirect:** Buyurtma yaratilgandan keyin `payment_url` ga `window.location.href` bilan yo'naltiriladi. To'lovdan keyin foydalanuvchi `return_url` ga qaytadi.

3. **To'lov natija sahifasi:** `/payment/result` sahifasida `order_number` query param orqali buyurtma holati tekshiriladi. Polling (har 3 soniya) bilan to'lov tasdiqlanishini kutadi.

4. **Buyurtma kuzatish:** Buyurtma batafsil sahifasida holat tarixi (timeline) ko'rsatiladi. `shipped` holatda BTS tracking link ham ko'rsatiladi.

5. **Bekor qilish:** Foydalanuvchi faqat `pending` holatdagi buyurtmani bekor qila oladi. Tasdiqlash dialog ko'rsatiladi.

6. **Admin buyurtmalar:** Real-time yangilanish shart emas — oddiy pagination va filter yetarli. Status o'zgartirish dropdown/modal orqali.
