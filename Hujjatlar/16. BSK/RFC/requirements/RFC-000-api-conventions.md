# RFC-000: API umumiy konvensiyalar

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 000 |
| **Modul** | Umumiy API konvensiyalar |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

## 1. Umumiy ko'rinish

Bu hujjat barcha API endpointlar uchun yagona konvensiyalarni belgilaydi. Barcha RFC lar (001-008) shu hujjatga asoslanadi. Backend va frontend jamoalar shu qoidalarga rioya qilishi kerak.

### 1.1 API Base URL

```
Production:  https://api.site.uz
Development: http://localhost:4000
```

Barcha endpointlar `/api` prefiksi bilan boshlanadi:
```
https://api.site.uz/api/products
https://api.site.uz/api/auth/send-code
https://api.site.uz/api/admin/orders
```

### 1.2 Content Type

Barcha so'rov va javoblar `application/json` formatda (fayl yuklash bundan mustasno).

```
Content-Type: application/json
Accept: application/json
```

Fayl yuklash endpointlarida:
```
Content-Type: multipart/form-data
```

---

## 2. Request konvensiyalar

### 2.1 Autentifikatsiya header

Himoyalangan endpointlar uchun JWT access token yuboriladi:

```
Authorization: Bearer <access_token>
```

### 2.2 Til header

Ko'p tillilik uchun `Accept-Language` header ishlatiladi:

```
Accept-Language: uz
Accept-Language: ru
```

**Qoidalar:**
- Default: `uz` (header yuborilmasa)
- Qo'llab-quvvatlanadigan tillar: `uz`, `ru`
- Backend shu header asosida `name_uz`/`name_ru`, `title_uz`/`title_ru`, `description_uz`/`description_ru`, `content_uz`/`content_ru` va `label_uz`/`label_ru` kabi juft maydonlardan tegishli tilni tanlab, javobda yagona `name`, `title`, `description`, `content`, `label` sifatida qaytaradi
- Admin API larda ikkala til ham qaytariladi (admin ikki tilda tahrir qiladi)

**Misol:**

Database da: `name_uz: "Protsessorlar"`, `name_ru: "Процессоры"`

`Accept-Language: uz` → javobda: `"name": "Protsessorlar"`
`Accept-Language: ru` → javobda: `"name": "Процессоры"`
Admin API → javobda: `"name_uz": "Protsessorlar", "name_ru": "Процессоры"`

### 2.3 Query parametrlar konvensiyasi

| Nomi | Turi | Tavsif |
|------|------|--------|
| `page` | number | Sahifa raqami (1 dan boshlanadi) |
| `per_page` | number | Har sahifadagi elementlar soni |
| `sort` | string | Saralash tartibi |
| `search` | string | Qidiruv so'zi |

- Boolean qiymatlar: `?in_stock=true` yoki `?in_stock=false`
- Bir nechta qiymat: vergul bilan ajratiladi — `?brand=amd,intel`
- Dinamik filtrlar: nuqta bilan — `?spec.socket=AM5,LGA1700`

---

## 3. Response formatlari

### 3.1 Muvaffaqiyatli javob (Success)

Barcha muvaffaqiyatli javoblar quyidagi formatda:

```json
{
  "success": true,
  "message": "Ixtiyoriy xabar (yaratish, yangilash, o'chirish uchun)",
  "data": {
    // javob ma'lumotlari
  }
}
```

**Qoidalar:**
- `success` — har doim `true`
- `message` — ixtiyoriy. CUD (Create/Update/Delete) operatsiyalarda foydalanuvchiga ko'rsatish uchun xabar. GET so'rovlarda odatda yo'q
- `data` — asosiy javob ma'lumotlari. Har doim mavjud

#### Bitta resurs qaytarilganda (GET, POST, PATCH):

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "AMD Ryzen 7 7800X3D",
    "price": 5200000
  }
}
```

#### Ro'yxat qaytarilganda (GET list):

```json
{
  "success": true,
  "data": {
    "items_key": [
      { "id": 1, "name": "..." },
      { "id": 2, "name": "..." }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 150,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

> **`items_key`** — kontekstga qarab o'zgaradi: `products`, `orders`, `users`, `reviews`, `posts`, `promotions`, `logs` va h.k. Bu har bir endpointda aniq belgilanadi.

#### O'chirish (DELETE):

```json
{
  "success": true,
  "message": "Mahsulot o'chirildi"
}
```

> `data` maydoni yo'q bo'lishi mumkin (yoki `null`).

---

### 3.2 Xato javob (Error)

Barcha xato javoblar quyidagi yagona formatda:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Foydalanuvchiga ko'rsatish uchun xabar",
    "details": {}
  }
}
```

**Maydonlar:**

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|----------|--------|
| `success` | `false` | ✅ | Har doim `false` |
| `error.code` | `string` | ✅ | Mashina o'qiydigan xato kodi (SCREAMING_SNAKE_CASE) |
| `error.message` | `string` | ✅ | Foydalanuvchiga ko'rsatish uchun xabar (Accept-Language ga qarab tillanadi) |
| `error.details` | `object` | ❌ | Qo'shimcha ma'lumot (validatsiya xatolari uchun) |

#### Oddiy xato:

```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Mahsulot topilmadi"
  }
}
```

#### Validatsiya xatosi (maydon bo'yicha):

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Kiritilgan ma'lumotlarda xatolik bor",
    "details": {
      "phone": "Telefon raqami +998 bilan boshlanishi kerak",
      "first_name": "Ism kamida 2 belgidan iborat bo'lishi kerak"
    }
  }
}
```

> `details` — kalit: maydon nomi, qiymat: xato xabari. Frontend har bir input yonida tegishli xatoni ko'rsatadi.

---

### 3.3 Pagination formati

Ro'yxat qaytaradigan barcha endpointlar yagona pagination formatini ishlatadi:

```json
{
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_items": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

| Maydon | Turi | Tavsif |
|--------|------|--------|
| `current_page` | number | Joriy sahifa raqami (1 dan boshlanadi) |
| `per_page` | number | Har sahifadagi elementlar soni |
| `total_items` | number | Jami elementlar soni (barcha sahifalarda) |
| `total_pages` | number | Jami sahifalar soni |
| `has_next` | boolean | Keyingi sahifa bormi |
| `has_prev` | boolean | Oldingi sahifa bormi |

**Standart qiymatlar:**
- `page` default: `1`
- `per_page` default: `20`, max: `50`
- `per_page` 50 dan katta bo'lsa — 50 ga tenglanadi

---

## 4. HTTP status kodlar

### 4.1 Muvaffaqiyat kodlari

| Status | Qachon ishlatiladi |
|--------|--------------------|
| `200 OK` | GET, PATCH, DELETE muvaffaqiyatli |
| `201 Created` | POST bilan yangi resurs yaratildi |
| `204 No Content` | Ishlatilmaydi — har doim JSON javob qaytariladi |

### 4.2 Klient xato kodlari

| Status | Qachon ishlatiladi | Misol |
|--------|--------------------|----|
| `400 Bad Request` | So'rov validatsiyadan o'tmadi | Noto'g'ri format, yetishmagan maydon |
| `401 Unauthorized` | Autentifikatsiya talab qilinadi yoki token noto'g'ri | Token muddati o'tgan, token yo'q |
| `403 Forbidden` | Ruxsat yo'q | Customer admin API ga kirmoqchi |
| `404 Not Found` | Resurs topilmadi | Noto'g'ri ID, slug |
| `409 Conflict` | Biznes logika ziddiyati | Dublikat, stock yetarli emas, holat o'tishi noto'g'ri |
| `413 Payload Too Large` | Fayl hajmi oshdi | Rasm > 5MB |
| `415 Unsupported Media Type` | Fayl formati noto'g'ri | PDF rasm sifatida yuklash |
| `422 Unprocessable Entity` | Ma'lumot qayta ishlab bo'lmadi | Tashqi API (BTS, SMS) xatosi |
| `429 Too Many Requests` | Rate limit oshdi | SMS, login urinishlari |

### 4.3 Server xato kodlari

| Status | Qachon ishlatiladi |
|--------|--------------------|
| `500 Internal Server Error` | Kutilmagan server xatosi |
| `502 Bad Gateway` | Tashqi API javob bermadi |
| `503 Service Unavailable` | Xizmat vaqtincha ishlamayapti |

---

## 5. Umumiy error kodlari

Barcha endpointlarda uchraydigan umumiy xato kodlari:

| HTTP Status | Error Code | Tavsif |
|-------------|-----------|--------|
| 400 | `VALIDATION_ERROR` | So'rov validatsiyadan o'tmadi (details da maydon xatolari) |
| 401 | `UNAUTHORIZED` | Autentifikatsiya talab qilinadi (token yuborilmagan) |
| 401 | `TOKEN_EXPIRED` | Access token muddati tugagan |
| 401 | `TOKEN_INVALID` | Token noto'g'ri yoki buzilgan |
| 403 | `FORBIDDEN` | Huquq yetarli emas (role mos kelmaydi) |
| 403 | `USER_BLOCKED` | Foydalanuvchi bloklangan |
| 404 | `NOT_FOUND` | Resurs topilmadi (umumiy) |
| 429 | `RATE_LIMITED` | So'rovlar chastotasi oshdi |
| 500 | `INTERNAL_ERROR` | Kutilmagan server xatosi |

> Modul-spetsifik error kodlari tegishli RFC larda alohida keltirilgan. Ular shu umumiy kodlarga **qo'shimcha** sifatida ishlaydi.

---

## 6. Fayl yuklash konvensiyasi

### 6.1 Request format

```
Content-Type: multipart/form-data
Authorization: Bearer <access_token>
```

### 6.2 Cheklovlar

| Parametr | Qiymat |
|----------|--------|
| Rasm formatlari | `jpg`, `jpeg`, `png`, `webp` |
| Max rasm hajmi | 5 MB |
| Max avatar hajmi | 2 MB |
| Backend konvertatsiya | Barcha rasmlar `WebP` formatga konvertatsiya qilinadi |
| Rasm o'lchamlari | `thumbnail` (300px), `medium` (600px), `large` (1200px) |

### 6.3 Response format

Yuklangan rasmlar to'liq URL sifatida qaytariladi:

```json
{
  "url": "https://api.site.uz/uploads/products/101/main.webp"
}
```

### 6.4 Rasm URL pattern

```
/uploads/products/{product_id}/{filename}.webp
/uploads/categories/{filename}.webp
/uploads/brands/{filename}.webp
/uploads/avatars/{user_id}.webp
/uploads/blog/{post_id}/{filename}.webp
/uploads/banners/{filename}.webp
/uploads/promotions/{filename}.webp
/uploads/settings/{filename}
```

---

## 7. Sana va vaqt formati

Barcha sana va vaqt qiymatlari **ISO 8601** formatda, **UTC** timezone da:

```
2026-02-06T14:30:00Z
```

| Format | Misol | Ishlatilish |
|--------|-------|-------------|
| DateTime (UTC) | `2026-02-06T14:30:00Z` | `created_at`, `updated_at`, `paid_at`, `starts_at`, `ends_at` |
| Date only | `2026-02-06` | `estimated_date` (yetkazib berish) |

Frontend o'z vaqt zonasiga (`Asia/Tashkent`, UTC+5) konvert qiladi.

---

## 8. Pul formati

Barcha pul qiymatlari **so'mda**, **butun son** sifatida qaytariladi:

```json
{
  "price": 5200000,
  "delivery_fee": 35000,
  "total": 11435000
}
```

| Qoida | Misol |
|-------|-------|
| Valyuta | O'zbek so'mi (UZS) |
| Format | Butun son (tiyin ishlatilmaydi) |
| Frontend formatlash | `5 200 000 so'm` (bo'shliq bilan) |

> **Eslatma:** Payme API `amount` ni **tiyinda** (so'm × 100) kutadi. Bu konvertatsiya backend tomonida amalga oshiriladi. Frontend har doim so'mda ishlaydi.

---

## 9. Null va ixtiyoriy maydonlar

### 9.1 Null qiymatlari

Mavjud bo'lmagan qiymatlar `null` sifatida qaytariladi, maydon tushirib qoldirilmaydi:

```json
{
  "first_name": "Sardor",
  "last_name": null,
  "avatar_url": null,
  "discount_price": null
}
```

### 9.2 PATCH so'rovlari

Partial update — faqat yuborilgan maydonlar yangilanadi:

```json
// Faqat first_name yangilanadi, qolganlar o'zgarmaydi
{
  "first_name": "Sardor"
}
```

Maydonni `null` ga o'zgartirish uchun aniq `null` yuboriladi:

```json
{
  "discount_price": null
}
```

---

## 10. Rate limiting

| Endpoint | Limit | Oyna |
|----------|-------|------|
| `POST /api/auth/send-code` | 5 ta SMS | 1 soat (telefon raqamiga) |
| `POST /api/auth/verify-code` | 3 ta urinish | 1 kod uchun |
| Umumiy API | 100 so'rov | 1 daqiqa (IP bo'yicha) |
| Admin API | 200 so'rov | 1 daqiqa |

Rate limit oshganda:

```
HTTP 429 Too Many Requests

Headers:
  Retry-After: 45   (soniyalarda, qayta urinish uchun kutish)
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 0
  X-RateLimit-Reset: 1707221760   (unix timestamp)
```

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "So'rovlar chastotasi oshdi. 45 soniyadan keyin urinib ko'ring.",
    "details": {
      "retry_after": 45
    }
  }
}
```

---

## 11. Versiyalash

Hozircha API versiyalanmaydi (v1 prefiksi ishlatilmaydi). Kelajakda zarur bo'lsa:

```
/api/v1/products
/api/v2/products
```

Hozirgi barcha endpointlar:
```
/api/products
/api/auth/send-code
/api/admin/orders
```

---

## 12. CORS sozlamalari

```
Access-Control-Allow-Origin: https://site.uz, https://admin.site.uz
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, Accept-Language
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

---

## 13. TypeScript base tiplari

Barcha RFC larda ishlatiladigan umumiy tiplar:

```typescript
// ============================================
// API Response wrapper
// ============================================

/**
 * Muvaffaqiyatli javob
 */
interface ApiResponse<T> {
  success: true;
  message?: string;
  data: T;
}

/**
 * Xato javob
 */
interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, string>;
  };
}

/**
 * Umumiy API natija (success yoki error)
 * Frontend fetch wrapper shu tipni qaytaradi
 */
type ApiResult<T> = ApiResponse<T> | ApiError;

// ============================================
// Pagination
// ============================================

interface Pagination {
  current_page: number;
  per_page: number;
  total_items: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

/**
 * Paginatsiyali ro'yxat javob
 * T — items massivining element tipi
 * K — items kaliti nomi (default "items")
 */
interface PaginatedResponse<T> {
  [key: string]: T[] | Pagination;
  pagination: Pagination;
}

// ============================================
// Umumiy query parametrlar
// ============================================

interface PaginationParams {
  page?: number;
  per_page?: number;
}

interface SortableParams extends PaginationParams {
  sort?: string;
}

interface SearchableParams extends SortableParams {
  search?: string;
}

// ============================================
// Umumiy tiplar
// ============================================

/** Foydalanuvchi rollari */
type UserRole = "customer" | "moderator" | "admin";

/** To'lov usullari */
type PaymentMethod = "click" | "payme";

/** Yetkazib berish usullari */
type DeliveryMethod = "bts_express" | "pickup";

/** Buyurtma holatlari */
type OrderStatus =
  | "pending"
  | "paid"
  | "processing"
  | "shipped"
  | "delivered"
  | "cancelled"
  | "refunded";

/** To'lov holatlari */
type PaymentStatus =
  | "pending"
  | "processing"
  | "completed"
  | "failed"
  | "cancelled"
  | "refunded";

/** Yetkazib berish holatlari */
type DeliveryStatus = "preparing" | "created" | "in_transit" | "delivered";

/** Blog holatlari */
type BlogStatus = "draft" | "published";

/** Aksiya turi */
type PromotionType = "percentage" | "fixed";

/** Aksiya qo'llanishi */
type PromotionApplyTo = "product" | "category" | "all";

/** Admin harakat turi */
type ActionType = "create" | "update" | "delete";

/** Spec template maydon turi */
type SpecFieldType = "select" | "number" | "text" | "boolean";

/** Qo'llanma turi */
type GuideType = "video" | "article";

// ============================================
// Tez-tez ishlatiladigan sub-tiplar
// ============================================

/** Qisqa brend ma'lumoti (mahsulot ichida) */
interface BrandRef {
  slug: string;
  name: string;
}

/** Qisqa kategoriya ma'lumoti (mahsulot ichida) */
interface CategoryRef {
  id: number;
  name: string;
  slug: string;
}

/** Breadcrumb element */
interface Breadcrumb {
  name: string;
  slug: string | null; // null = joriy sahifa (oxirgi element)
}
```

---

## 14. Frontend fetch wrapper misol

Backend dasturchi uchun emas, lekin API kontrakt qanday ishlatilishini ko'rsatish uchun:

```typescript
class ApiClient {
  private baseUrl: string;
  private accessToken: string | null = null;
  private locale: "uz" | "ru" = "uz";

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  setAccessToken(token: string | null) {
    this.accessToken = token;
  }

  setLocale(locale: "uz" | "ru") {
    this.locale = locale;
  }

  async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<ApiResult<T>> {
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Accept-Language": this.locale,
    };

    if (this.accessToken) {
      headers["Authorization"] = `Bearer ${this.accessToken}`;
    }

    const response = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    const json = await response.json();

    // 401 bo'lsa — token yangilash urinishi
    if (response.status === 401 && json.error?.code === "TOKEN_EXPIRED") {
      const refreshed = await this.refreshToken();
      if (refreshed) {
        // Qayta urinish
        return this.request<T>(method, path, body);
      }
      // Refresh ham muvaffaqiyatsiz — login sahifasiga
      window.location.href = "/login";
    }

    return json as ApiResult<T>;
  }

  // Qisqartma metodlar
  get<T>(path: string) { return this.request<T>("GET", path); }
  post<T>(path: string, body: unknown) { return this.request<T>("POST", path, body); }
  patch<T>(path: string, body: unknown) { return this.request<T>("PATCH", path, body); }
  delete<T>(path: string) { return this.request<T>("DELETE", path); }
}
```

---

## 15. Xulosa — RFC lar ro'yxati

| RFC | Modul | Tavsif |
|-----|-------|--------|
| **RFC-000** | Umumiy konvensiyalar | Shu hujjat — barcha RFC lar uchun asos |
| **RFC-001** | Autentifikatsiya | SMS OTP, JWT tokenlar, rollar, route himoyasi |
| **RFC-002** | Mahsulotlar | Kategoriyalar, filtrlash, JSONB spec, qidiruv, admin CRUD, CSV |
| **RFC-003** | Savat | Guest (localStorage) + auth (DB), merge logika |
| **RFC-004** | Buyurtmalar | Checkout, holat mashinasi, snapshot prinsipi |
| **RFC-005** | To'lov | Click + Payme redirect/webhook |
| **RFC-006** | Yetkazib berish | BTS Express API, narx hisoblash, tracking |
| **RFC-007** | Foydalanuvchi | Profil, manzillar, wishlist, sharhlar |
| **RFC-008** | Admin qo'shimcha | Statistika, blog, aksiyalar, sozlamalar, activity log |

> Barcha RFC lardagi response va error formatlar **shu hujjatdagi qoidalarga** asoslanadi. Modul-spetsifik error kodlari tegishli RFC da keltiriladi.
