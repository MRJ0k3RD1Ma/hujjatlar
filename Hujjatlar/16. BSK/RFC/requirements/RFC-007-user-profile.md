# RFC-007: Foydalanuvchi profili

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 007 |
| **Modul** | Profil, manzillar, sevimlilar, sharhlar, bildirishnomalar |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Foydalanuvchi profili orqali shaxsiy ma'lumotlarni boshqarish, manzillar qo'shish, sevimli mahsulotlarni saqlash, sharhlar yozish va mahsulot mavjudligi haqida bildirishnoma olish mumkin.

---

## 2. API Endpointlar

### 2.1 Profil olish

**`GET /api/user/profile`**

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "phone": "+998901234567",
    "first_name": "Sardor",
    "last_name": "Karimov",
    "avatar_url": "https://api.site.uz/uploads/avatars/1.webp",
    "is_verified": true,
    "created_at": "2026-01-15T10:30:00Z",
    "stats": {
      "orders_count": 5,
      "wishlist_count": 12,
      "reviews_count": 3
    }
  }
}
```

---

### 2.2 Profil yangilash

**`PATCH /api/user/profile`**

**Request:**
```json
{
  "first_name": "Sardor",
  "last_name": "Karimov"
}
```

**Avatar yuklash (alohida):**

**`POST /api/user/profile/avatar`** (multipart/form-data)
```
avatar: (file) photo.jpg
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profil yangilandi",
  "data": {
    "id": 1,
    "phone": "+998901234567",
    "first_name": "Sardor",
    "last_name": "Karimov",
    "avatar_url": "https://api.site.uz/uploads/avatars/1.webp"
  }
}
```

---

### 2.3 Manzillar

**`GET /api/user/addresses`**

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "title": "Uy",
      "region": "Toshkent shahri",
      "city": "Toshkent",
      "district": "Yunusobod",
      "street": "Amir Temur ko'chasi",
      "house": "15",
      "apartment": "42",
      "landmark": "Metro yonida",
      "is_default": true,
      "created_at": "2026-01-20T08:00:00Z"
    },
    {
      "id": 6,
      "title": "Ofis",
      "region": "Toshkent shahri",
      "city": "Toshkent",
      "district": "Mirzo Ulug'bek",
      "street": "Buyuk Ipak Yo'li",
      "house": "100",
      "apartment": null,
      "landmark": "IT Park yonida",
      "is_default": false,
      "created_at": "2026-02-01T12:00:00Z"
    }
  ]
}
```

**`POST /api/user/addresses`** — Yangi manzil qo'shish

**Request:**
```json
{
  "title": "Uy",
  "region": "Toshkent shahri",
  "city": "Toshkent",
  "district": "Yunusobod",
  "street": "Amir Temur ko'chasi",
  "house": "15",
  "apartment": "42",
  "landmark": "Metro yonida",
  "is_default": true
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Manzil qo'shildi",
  "data": {
    "id": 7,
    "title": "Uy",
    "region": "Toshkent shahri",
    "city": "Toshkent",
    "district": "Yunusobod",
    "street": "Amir Temur ko'chasi",
    "house": "15",
    "apartment": "42",
    "landmark": "Metro yonida",
    "is_default": true,
    "created_at": "2026-02-06T14:00:00Z"
  }
}
```

**`PATCH /api/user/addresses/:id`** — Tahrirlash (partial update)

**`DELETE /api/user/addresses/:id`** — O'chirish

**Biznes qoidalar:**
- Maksimal 5 ta manzil
- `is_default: true` qo'yilganda boshqa manzillarning `is_default` avtomatik `false` bo'ladi
- `region` va `city` majburiy, qolganlar ixtiyoriy emas (`street`, `house` majburiy)

---

### 2.4 Sevimlilar (Wishlist)

**`GET /api/user/wishlist`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 20 | Har sahifada |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 101,
        "name": "AMD Ryzen 7 7800X3D",
        "slug": "amd-ryzen-7-7800x3d",
        "price": 5200000,
        "discount_price": 4800000,
        "image": "https://api.site.uz/uploads/products/101/main.webp",
        "brand": { "slug": "amd", "name": "AMD" },
        "rating": 4.8,
        "in_stock": true,
        "added_at": "2026-02-01T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 12,
      "total_pages": 1,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

**`POST /api/user/wishlist/:productId`** — Sevimliga qo'shish

**Response (201):**
```json
{
  "success": true,
  "message": "Sevimlilarga qo'shildi"
}
```

**`DELETE /api/user/wishlist/:productId`** — Sevimidan o'chirish

**Response (200):**
```json
{
  "success": true,
  "message": "Sevimlilardan o'chirildi"
}
```

**Biznes qoidalar:**
- Bir mahsulot bir marta qo'shiladi, duplikat — 409
- Nofaol mahsulotlar wishlist da qoladi, lekin `in_stock: false` ko'rsatiladi

---

### 2.5 Sharh yozish

**`POST /api/user/reviews`**

**Request:**
```json
{
  "product_id": 101,
  "rating": 5,
  "comment": "Juda yaxshi protsessor, o'yinlarda zo'r ishlaydi!"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Sharh yuborildi. Moderator tekshirgandan keyin chiqadi.",
  "data": {
    "id": 15,
    "product_id": 101,
    "rating": 5,
    "comment": "Juda yaxshi protsessor, o'yinlarda zo'r ishlaydi!",
    "is_approved": false,
    "created_at": "2026-02-06T15:00:00Z"
  }
}
```

**Biznes qoidalar:**
- `rating` — 1 dan 5 gacha (majburiy)
- `comment` — ixtiyoriy, maksimal 1000 belgi
- Sharh `is_approved: false` holatda yaratiladi — moderator tasdiqlashi kerak
- Bir foydalanuvchi bir mahsulotga faqat 1 ta sharh yoza oladi
- Foydalanuvchi shu mahsulotni sotib olgan bo'lishi shart emas (lekin frontend da "Verified Purchase" badge ko'rsatilishi mumkin)

---

### 2.6 Stock bildirishnoma

**`POST /api/user/stock-notify/:productId`**

Mahsulot omborda paydo bo'lganda xabar olish uchun ro'yxatga yozilish.

**Response (201):**
```json
{
  "success": true,
  "message": "Mahsulot mavjud bo'lganda xabar beramiz"
}
```

**Biznes qoidalar:**
- Faqat `stock_quantity = 0` bo'lgan mahsulotlar uchun ishlaydi
- Mahsulot stockga tushganda SMS yuboriladi
- SMS yuborilgandan keyin `is_notified: true` bo'ladi
- Bir foydalanuvchi bir mahsulotga 1 marta yoziladi

---

## 3. Admin API — Foydalanuvchilar boshqaruvi

### 3.1 Foydalanuvchilar ro'yxati

**`GET /api/admin/users`**

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page`, `per_page` | number | Pagination |
| `search` | string | Telefon yoki ism bo'yicha |
| `role` | string | `customer`, `moderator`, `admin` |
| `is_active` | boolean | Faollik |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "phone": "+998901234567",
        "first_name": "Sardor",
        "last_name": "Karimov",
        "role": "customer",
        "is_active": true,
        "orders_count": 5,
        "total_spent": 25000000,
        "created_at": "2026-01-15T10:30:00Z"
      }
    ],
    "pagination": { "...": "..." }
  }
}
```

---

### 3.2 Foydalanuvchi tahrirlash

**`PATCH /api/admin/users/:id`**

**Request:**
```json
{
  "role": "moderator",
  "is_active": true
}
```

**Biznes qoidalar:**
- Faqat `admin` role o'zgartira oladi
- `admin` → `customer` ga tushirish mumkin emas (o'zini ham)
- `is_active: false` — foydalanuvchi bloklangan, login qila olmaydi

---

### 3.3 Sharhlar moderatsiyasi

**`GET /api/admin/reviews`**

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page`, `per_page` | number | Pagination |
| `is_approved` | boolean | Tasdiqlangan/kutilmoqda |
| `product_id` | number | Mahsulot bo'yicha |
| `min_rating`, `max_rating` | number | Reyting filter |

**`PATCH /api/admin/reviews/:id`** — Tasdiqlash yoki rad etish

**Request:**
```json
{
  "is_approved": true
}
```

**`DELETE /api/admin/reviews/:id`** — O'chirish

---

## 4. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_RATING` | Reyting 1-5 orasida bo'lishi kerak | Sharh yozishda |
| 400 | `COMMENT_TOO_LONG` | Sharh 1000 belgidan oshdi | Sharh yozishda |
| 404 | `ADDRESS_NOT_FOUND` | Manzil topilmadi | Noto'g'ri ID |
| 409 | `ADDRESS_LIMIT_REACHED` | Manzillar limiti (5 ta) | Yangi manzil qo'shishda |
| 409 | `ALREADY_IN_WISHLIST` | Allaqachon sevimlilarda | Qayta qo'shish |
| 409 | `ALREADY_REVIEWED` | Allaqachon sharh yozilgan | Qayta sharh |
| 409 | `PRODUCT_IN_STOCK` | Mahsulot omborda mavjud | Stock notify registratsiya |
| 409 | `ALREADY_SUBSCRIBED` | Allaqachon yozilgan | Qayta subscribe |
| 413 | `AVATAR_TOO_LARGE` | Avatar hajmi katta (max 2MB) | Avatar yuklash |

---

## 5. TypeScript interfeyslar

```typescript
// ============================================
// Profile types
// ============================================

interface UserProfile {
  id: number;
  phone: string;
  first_name: string | null;
  last_name: string | null;
  avatar_url: string | null;
  is_verified: boolean;
  created_at: string;
  stats: {
    orders_count: number;
    wishlist_count: number;
    reviews_count: number;
  };
}

interface UpdateProfileRequest {
  first_name?: string;
  last_name?: string;
}

// ============================================
// Address types
// ============================================

interface UserAddress {
  id: number;
  title: string;
  region: string;
  city: string;
  district: string | null;
  street: string;
  house: string;
  apartment: string | null;
  landmark: string | null;
  is_default: boolean;
  created_at: string;
}

interface CreateAddressRequest {
  title: string;
  region: string;
  city: string;
  district?: string;
  street: string;
  house: string;
  apartment?: string;
  landmark?: string;
  is_default?: boolean;
}

interface UpdateAddressRequest extends Partial<CreateAddressRequest> {}

// ============================================
// Wishlist types
// ============================================

interface WishlistItem {
  id: number;      // product_id
  name: string;
  slug: string;
  price: number;
  discount_price: number | null;
  image: string | null;
  brand: {
    slug: string;
    name: string;
  } | null;
  rating: number;
  in_stock: boolean;
  added_at: string;
}

// ============================================
// Review types
// ============================================

interface CreateReviewRequest {
  product_id: number;
  rating: number;    // 1-5
  comment?: string;  // max 1000
}

interface UserReview {
  id: number;
  product_id: number;
  rating: number;
  comment: string | null;
  is_approved: boolean;
  created_at: string;
}

// ============================================
// Admin user types
// ============================================

interface AdminUserListItem {
  id: number;
  phone: string;
  first_name: string | null;
  last_name: string | null;
  role: "customer" | "moderator" | "admin";
  is_active: boolean;
  orders_count: number;
  total_spent: number;
  created_at: string;
}

interface UpdateUserRoleRequest {
  role?: "customer" | "moderator" | "admin";
  is_active?: boolean;
}

// Admin review
interface AdminReview {
  id: number;
  user: {
    id: number;
    phone: string;
    first_name: string | null;
  };
  product: {
    id: number;
    name: string;
    slug: string;
  };
  rating: number;
  comment: string | null;
  is_approved: boolean;
  created_at: string;
}
```

---

## 6. Frontend uchun eslatmalar

1. **Profil sahifasi:** Sidebar navigatsiya — Profil, Buyurtmalarim, Manzillar, Sevimlilar. Profil tahrirlash inline yoki modal.

2. **Manzil formasi:** Viloyat → Shahar → Tuman cascade select. Yetkazib berish shaharlar ro'yxati (`/api/delivery/cities`) bilan sinxron.

3. **Wishlist toggle:** Mahsulot kartochkasida yurak ikonka. Bosilganda optimistic update — darhol rang o'zgaradi, keyin API chaqiriladi.

4. **Sharh yozish:** Mahsulot sahifasida "Sharh qoldirish" tugmasi (faqat login qilganlarga). 5 yulduzli reyting + matn input. Yuborilgandan keyin "Moderator tekshirgandan keyin chiqadi" xabari.

5. **Stock notification:** Mahsulot sahifasida `in_stock: false` bo'lsa "Mavjud bo'lganda xabar bering" tugmasi. Login qilgan foydalanuvchi uchun.

6. **Admin sharhlar:** Yangi sharhlar badge bilan ko'rsatiladi. Bulk tasdiqlash/rad etish imkoniyati.
