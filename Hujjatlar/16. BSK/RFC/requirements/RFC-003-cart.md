# RFC-003: Savat tizimi

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 003 |
| **Modul** | Savat (Cart) |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Savat tizimi ikki rejimda ishlaydi: ro'yxatdan o'tmagan foydalanuvchilar uchun **localStorage** da, ro'yxatdan o'tganlar uchun **server** (database) da. Foydalanuvchi login qilganda localStorage savati server savatiga **merge** qilinadi.

### 1.1 Savat holatlari

| Holat | Saqlash joyi | Izoh |
|-------|-------------|------|
| Guest (tizimga kirmagan) | `localStorage` | Frontend boshqaradi |
| Autentifikatsiya qilingan | Database (`carts` + `cart_items`) | Backend boshqaradi |
| Login paytida | Merge | localStorage → DB ga qo'shiladi |

---

## 2. Guest savat (Frontend — localStorage)

Guest rejimda savat to'liq frontend tomonida boshqariladi. Backend ga so'rov yuborilmaydi.

### 2.1 localStorage format

```json
{
  "cart_items": [
    {
      "product_id": 101,
      "quantity": 2,
      "added_at": "2026-02-06T10:00:00Z"
    },
    {
      "product_id": 205,
      "quantity": 1,
      "added_at": "2026-02-06T10:05:00Z"
    }
  ]
}
```

### 2.2 Frontend qoidalar (guest)

- Mahsulot qo'shilganda `product_id` va `quantity` saqlanadi
- Bir xil mahsulot qayta qo'shilsa — `quantity` oshadi
- Narx localStorage da saqlanmaydi — har safar backend dan olinadi (narx o'zgarishi uchun)
- Savat sahifasida mahsulot ma'lumotlari `GET /api/products` ga ID lar yuborib olinadi
- Maksimal 50 ta mahsulot savatda

---

## 3. Auth savat — API Endpointlar

### 3.1 Savatni olish

**`GET /api/cart`**

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
    "items": [
      {
        "id": 10,
        "product": {
          "id": 101,
          "name": "AMD Ryzen 7 7800X3D",
          "slug": "amd-ryzen-7-7800x3d",
          "price": 5200000,
          "discount_price": 4800000,
          "image": "https://api.site.uz/uploads/products/101/main.webp",
          "in_stock": true,
          "stock_quantity": 15
        },
        "quantity": 2,
        "subtotal": 9600000,
        "added_at": "2026-02-06T10:00:00Z"
      },
      {
        "id": 11,
        "product": {
          "id": 205,
          "name": "Corsair Vengeance 32GB DDR5",
          "slug": "corsair-vengeance-32gb-ddr5",
          "price": 1800000,
          "discount_price": null,
          "image": "https://api.site.uz/uploads/products/205/main.webp",
          "in_stock": true,
          "stock_quantity": 8
        },
        "quantity": 1,
        "subtotal": 1800000,
        "added_at": "2026-02-06T10:05:00Z"
      }
    ],
    "summary": {
      "items_count": 3,
      "subtotal": 11400000,
      "discount_total": 800000,
      "total": 11400000
    }
  }
}
```

**Biznes qoidalar:**
- `subtotal` = (`discount_price` yoki `price`) × `quantity`
- `discount_total` = umumiy chegirma summasi (original narx - haqiqiy narx)
- `summary.total` = barcha itemlarning subtotal yig'indisi
- Agar mahsulot `is_active: false` yoki o'chirilgan bo'lsa — savatdan chiqariladi va javobda qaytmaydi
- `in_stock` va `stock_quantity` — real vaqt ma'lumot

---

### 3.2 Mahsulot qo'shish

**`POST /api/cart/items`**

**Request:**
```json
{
  "product_id": 101,
  "quantity": 1
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Mahsulot savatga qo'shildi",
  "data": {
    "id": 10,
    "product": {
      "id": 101,
      "name": "AMD Ryzen 7 7800X3D",
      "slug": "amd-ryzen-7-7800x3d",
      "price": 5200000,
      "discount_price": 4800000,
      "image": "https://api.site.uz/uploads/products/101/main.webp",
      "in_stock": true,
      "stock_quantity": 15
    },
    "quantity": 1,
    "subtotal": 4800000
  }
}
```

**Biznes qoidalar:**
- Agar mahsulot allaqachon savatda bo'lsa — `quantity` oshadi (409 emas, merge qiladi)
- `quantity` ≤ `stock_quantity` bo'lishi kerak
- Mahsulot `is_active: true` va `stock_quantity > 0` bo'lishi kerak

---

### 3.3 Miqdor o'zgartirish

**`PATCH /api/cart/items/:id`**

`:id` — cart item ID (mahsulot ID emas).

**Request:**
```json
{
  "quantity": 3
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 10,
    "quantity": 3,
    "subtotal": 14400000
  }
}
```

**Biznes qoidalar:**
- `quantity` ≥ 1 va ≤ `stock_quantity`
- `quantity: 0` yuborilsa — mahsulot o'chiriladi

---

### 3.4 Mahsulot o'chirish

**`DELETE /api/cart/items/:id`**

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Mahsulot savatdan o'chirildi"
}
```

---

### 3.5 Guest savatni merge qilish

**`POST /api/cart/merge`**

Login bo'lgandan keyin chaqiriladi. Guest savatidagi mahsulotlar server savatiga qo'shiladi.

**Request:**
```json
{
  "items": [
    { "product_id": 101, "quantity": 2 },
    { "product_id": 205, "quantity": 1 }
  ]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Savat sinxronlashtirildi",
  "data": {
    "merged": 2,
    "skipped": 0,
    "cart": {
      "id": 1,
      "items": ["... (GET /api/cart bilan bir xil format)"],
      "summary": {
        "items_count": 3,
        "subtotal": 11400000,
        "discount_total": 800000,
        "total": 11400000
      }
    }
  }
}
```

**Biznes qoidalar:**
- Agar mahsulot allaqachon server savatida bo'lsa — `quantity` yig'iladi (qo'shiladi)
- Agar yig'indi `stock_quantity` dan oshsa — `stock_quantity` ga tenglanadi
- Mavjud bo'lmagan yoki nofaol mahsulotlar `skipped` ga tushadi
- Merge dan keyin frontend localStorage savatini tozalaydi

---

## 4. Mahsulot ma'lumotlarini olish (Guest savat uchun)

**`POST /api/products/batch`**

Guest savatdagi mahsulotlarning hozirgi narx va holat ma'lumotlarini olish.

**Request:**
```json
{
  "ids": [101, 205, 310]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 101,
      "name": "AMD Ryzen 7 7800X3D",
      "slug": "amd-ryzen-7-7800x3d",
      "price": 5200000,
      "discount_price": 4800000,
      "image": "https://api.site.uz/uploads/products/101/main.webp",
      "in_stock": true,
      "stock_quantity": 15
    },
    {
      "id": 205,
      "name": "Corsair Vengeance 32GB DDR5",
      "slug": "corsair-vengeance-32gb-ddr5",
      "price": 1800000,
      "discount_price": null,
      "image": "https://api.site.uz/uploads/products/205/main.webp",
      "in_stock": true,
      "stock_quantity": 8
    }
  ]
}
```

**Biznes qoidalar:**
- Maksimal 50 ta ID
- Topilmagan yoki nofaol mahsulotlar javobda qaytmaydi
- Auth talab qilinmaydi

---

## 5. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_QUANTITY` | Miqdor noto'g'ri (0 dan kichik yoki son emas) | Validatsiya |
| 404 | `PRODUCT_NOT_FOUND` | Mahsulot topilmadi | Nofaol yoki o'chirilgan |
| 404 | `CART_ITEM_NOT_FOUND` | Savat elementi topilmadi | Noto'g'ri cart item ID |
| 409 | `OUT_OF_STOCK` | Mahsulot omborda yo'q | stock_quantity = 0 |
| 409 | `INSUFFICIENT_STOCK` | Yetarli miqdor yo'q | quantity > stock_quantity |
| 409 | `PRODUCT_INACTIVE` | Mahsulot nofaol | is_active = false |

---

## 6. TypeScript interfeyslar

```typescript
// ============================================
// Cart types
// ============================================

interface CartItemProduct {
  id: number;
  name: string;
  slug: string;
  price: number;
  discount_price: number | null;
  image: string | null;
  in_stock: boolean;
  stock_quantity: number;
}

interface CartItem {
  id: number; // cart_item ID (server)
  product: CartItemProduct;
  quantity: number;
  subtotal: number;
  added_at: string;
}

interface CartSummary {
  items_count: number;  // jami mahsulotlar soni (quantity hisobida)
  subtotal: number;
  discount_total: number;
  total: number;
}

interface Cart {
  id: number;
  items: CartItem[];
  summary: CartSummary;
}

// ============================================
// Guest cart (localStorage)
// ============================================

interface GuestCartItem {
  product_id: number;
  quantity: number;
  added_at: string;
}

interface GuestCart {
  cart_items: GuestCartItem[];
}

// ============================================
// Request types
// ============================================

interface AddToCartRequest {
  product_id: number;
  quantity: number; // default 1
}

interface UpdateCartItemRequest {
  quantity: number;
}

interface MergeCartRequest {
  items: {
    product_id: number;
    quantity: number;
  }[];
}

interface BatchProductsRequest {
  ids: number[]; // max 50
}

// ============================================
// Response types
// ============================================

interface MergeCartData {
  merged: number;
  skipped: number;
  cart: Cart;
}
```

---

## 7. Frontend uchun eslatmalar

1. **Savat holati boshqaruvi:** Zustand yoki React Context bilan global cart state. Guest rejimda localStorage bilan sinxron, auth rejimda API bilan sinxron.

2. **Optimistic updates:** Miqdor o'zgartirish va o'chirish optimistic — UI darhol yangilanadi, agar API xato qaytarsa rollback qilinadi.

3. **Stock tekshirish:** Savat sahifasi ochilganda va checkout boshlanganda `stock_quantity` qayta tekshiriladi. Agar mavjud bo'lmasa — ogohlantirish ko'rsatiladi.

4. **Login merge flow:**
   - Foydalanuvchi login qiladi → access token olinadi
   - Agar localStorage da savat bo'lsa → `POST /api/cart/merge` chaqiriladi
   - Merge natijasi yangi cart state ga yoziladi
   - localStorage tozalanadi

5. **Savat ikonkasi:** Header dagi savat ikonkasida `items_count` badge ko'rsatiladi. Guest rejimda localStorage dan, auth rejimda API dan olinadi.

6. **Empty state:** Savat bo'sh bo'lganda "Savat bo'sh" xabari va "Xarid qilishni boshlash" tugmasi ko'rsatiladi.
