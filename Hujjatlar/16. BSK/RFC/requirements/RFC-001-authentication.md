# RFC-001: Autentifikatsiya tizimi

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 001 |
| **Modul** | Autentifikatsiya |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan. Shu hujjat faqat autentifikatsiyaga xos qoidalarni tavsiflaydi.

---

## 1. Umumiy ko'rinish

Tizim telefon raqami + SMS OTP (bir martalik kod) asosida autentifikatsiya qiladi. Parol ishlatilmaydi. Foydalanuvchi telefon raqamini kiritadi, SMS orqali 6 xonali kod oladi va kodni kiritib tizimga kiradi. Agar raqam yangi bo'lsa — avtomatik ro'yxatdan o'tadi, mavjud bo'lsa — kiradi.

### 1.1 SMS Provider

**Eskiz.uz** — O'zbekistondagi SMS provider. API orqali SMS yuboriladi.

- Base URL: `https://notify.eskiz.uz/api`
- Auth: Bearer token (Eskiz dashboard dan olinadi)
- Narx: ~50 so'm / SMS

---

## 2. API Endpointlar

### 2.1 SMS kod yuborish

**`POST /api/auth/send-code`**

Telefon raqamiga 6 xonali tasdiqlash kodini yuboradi.

**Headers:**
```
Content-Type: application/json
Accept-Language: uz | ru
```

**Request body:**
```json
{
  "phone": "+998901234567"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Tasdiqlash kodi yuborildi",
  "data": {
    "phone": "+998901234567",
    "expires_in": 120,
    "retry_after": 60
  }
}
```

**Biznes qoidalar:**
- Telefon raqami `+998` bilan boshlanishi va 12 ta raqamdan iborat bo'lishi kerak
- Kod 6 xonali tasodifiy raqam (masalan: `482916`)
- Kod **2 daqiqa** (120 soniya) amal qiladi
- Bir raqamga qayta kod yuborish uchun kamida **60 soniya** kutish kerak
- Bir raqamga soatiga maksimal **5 ta** SMS yuboriladi (rate limit)
- Avvalgi ishlatilmagan kodlar yangi kod yuborilganda bekor bo'ladi

---

### 2.2 Kodni tekshirish (Login / Register)

**`POST /api/auth/verify-code`**

Yuborilgan kodni tekshiradi. Kod to'g'ri bo'lsa, foydalanuvchini kirgazadi yoki ro'yxatdan o'tkazadi.

**Request body:**
```json
{
  "phone": "+998901234567",
  "code": "482916"
}
```

**Response — mavjud foydalanuvchi (200 OK):**
```json
{
  "success": true,
  "message": "Muvaffaqiyatli kirdingiz",
  "data": {
    "user": {
      "id": 1,
      "phone": "+998901234567",
      "first_name": "Sardor",
      "last_name": "Karimov",
      "role": "customer",
      "avatar_url": null,
      "is_verified": true,
      "created_at": "2026-01-15T10:30:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
      "access_expires_in": 900,
      "refresh_expires_in": 2592000
    },
    "is_new_user": false
  }
}
```

**Response — yangi foydalanuvchi (201 Created):**
```json
{
  "success": true,
  "message": "Ro'yxatdan o'tdingiz",
  "data": {
    "user": {
      "id": 42,
      "phone": "+998901234567",
      "first_name": null,
      "last_name": null,
      "role": "customer",
      "avatar_url": null,
      "is_verified": true,
      "created_at": "2026-02-06T14:20:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
      "access_expires_in": 900,
      "refresh_expires_in": 2592000
    },
    "is_new_user": true
  }
}
```

**Biznes qoidalar:**
- Maksimal **3 ta noto'g'ri urinish**. 3 dan keyin kod bloklandi, yangi kod so'rash kerak
- Kod faqat **1 marta** ishlatilishi mumkin
- Agar telefon raqami bazada yo'q bo'lsa — yangi `customer` yaratiladi
- Yangi foydalanuvchi `is_verified: true` bo'ladi (telefon tasdiqlangan)
- Har bir muvaffaqiyatli kirishda yangi session (refresh token) yaratiladi
- `is_new_user` flagi frontend uchun — yangi userga profil to'ldirish taklif qilinadi

---

### 2.3 Token yangilash

**`POST /api/auth/refresh`**

Muddati tugagan access token o'rniga yangisini olish.

**Request body:**
```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "bmV3IHJlZnJlc2ggdG9r...",
    "access_expires_in": 900,
    "refresh_expires_in": 2592000
  }
}
```

**Biznes qoidalar:**
- Refresh token bir martalik — yangilanganda eski token bekor bo'ladi, yangi juftlik beriladi (token rotation)
- Agar refresh token topilmasa yoki muddati o'tgan bo'lsa — `401` xato
- Agar allaqachon ishlatilgan refresh token yuborilsa — **barcha sessiyalar bekor qilinadi** (token theft detection)

---

### 2.4 Chiqish (Logout)

**`POST /api/auth/logout`**

Joriy sessiyani tugatadi.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request body:**
```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Muvaffaqiyatli chiqdingiz"
}
```

**Biznes qoidalar:**
- Refresh token bazadan o'chiriladi
- Access token server tomonida blacklist qilinmaydi — muddati o'tguncha amal qiladi (stateless)
- Frontend access tokenni xotiradan o'chirishi kerak

---

### 2.5 Joriy foydalanuvchi

**`GET /api/auth/me`**

Joriy autentifikatsiya qilingan foydalanuvchi ma'lumotlarini qaytaradi.

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
    "role": "customer",
    "avatar_url": "https://api.site.uz/uploads/avatars/1.jpg",
    "is_verified": true,
    "created_at": "2026-01-15T10:30:00Z"
  }
}
```

---

## 3. Token strategiyasi

| Parametr | Access Token | Refresh Token |
|----------|-------------|---------------|
| **Muddat** | 15 daqiqa (900s) | 30 kun (2592000s) |
| **Format** | JWT (HS256) | Opaque string (random) |
| **Saqlash (frontend)** | Xotirada (variable) | httpOnly cookie yoki xotirada |
| **Saqlash (backend)** | Tekshirilmaydi (stateless) | `user_sessions` jadvalida |
| **Yangilash** | Refresh endpoint orqali | Har yangilashda rotate |

### 3.1 JWT Access Token payload

```json
{
  "sub": 1,
  "phone": "+998901234567",
  "role": "customer",
  "iat": 1707220800,
  "exp": 1707221700
}
```

### 3.2 Frontend token boshqaruvi

- Access token **faqat xotirada** (JavaScript variable) saqlanadi, `localStorage` yoki `cookie` da emas
- Sahifa refresh bo'lganda refresh token orqali yangi access token olinadi
- Har bir API so'rov `Authorization: Bearer <access_token>` header bilan yuboriladi
- Access token muddati tugashidan **1 daqiqa oldin** avtomatik yangilanadi (proactive refresh)
- 401 javob kelganda ham refresh uriniladi, muvaffaqiyatsiz bo'lsa login sahifasiga yo'naltiriladi

---

## 4. Rollar va huquqlar

| Rol | Tavsif | Belgilash |
|-----|--------|-----------|
| `customer` | Oddiy xaridor | Avtomatik (ro'yxatdan o'tganda) |
| `moderator` | Kontentni boshqaruvchi | Admin tomonidan belgilanadi |
| `admin` | To'liq boshqaruv | Bazada qo'lda yoki seed orqali |

### 4.1 Route himoyasi

**Public endpointlar (auth talab qilinmaydi):**
- `POST /api/auth/send-code`
- `POST /api/auth/verify-code`
- `POST /api/auth/refresh`
- `GET /api/products/*`
- `GET /api/categories/*`
- `GET /api/brands`
- `GET /api/search`
- `GET /api/delivery/cities`

**Customer endpointlar (har qanday autentifikatsiya qilingan user):**
- `GET/POST/PATCH/DELETE /api/cart/*`
- `GET/POST /api/orders/*`
- `GET/PATCH /api/user/profile`
- `GET/POST/DELETE /api/user/addresses/*`
- `GET/POST/DELETE /api/user/wishlist/*`
- `POST /api/user/reviews`
- `POST /api/payment/create`
- `POST /api/delivery/calculate`

**Moderator endpointlar:**
- `GET/POST/PATCH/DELETE /api/admin/products/*`
- `GET/POST/PATCH/DELETE /api/admin/brands/*`
- `GET/PATCH /api/admin/orders/*`
- `GET/PATCH /api/admin/reviews/*`
- `GET/POST/PATCH/DELETE /api/admin/blog/*`

**Admin endpointlar (faqat admin):**
- Moderator huquqlari + quyidagilar:
- `GET/POST/PATCH/DELETE /api/admin/categories/*`
- `POST /api/admin/orders/:id/ship`
- `GET/POST/PATCH/DELETE /api/admin/promotions/*`
- `GET/PATCH /api/admin/users/*`
- `GET/PATCH /api/admin/settings/*`
- `GET /api/admin/stats/*`
- `GET /api/admin/activity-logs`

---

## 5. Error javoblar

Barcha error javoblar yagona formatda qaytariladi:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Xato tavsifi (foydalanuvchiga ko'rsatish uchun)",
    "details": {}
  }
}
```

### 5.1 Autentifikatsiya error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_PHONE` | Telefon raqami noto'g'ri formatda | Validatsiyadan o'tmagan |
| 400 | `INVALID_CODE` | Kod noto'g'ri | Noto'g'ri kod kiritilganda |
| 400 | `CODE_EXPIRED` | Kod muddati tugagan | 2 daqiqadan keyin |
| 400 | `CODE_ALREADY_USED` | Kod allaqachon ishlatilgan | Qayta ishlatish urinishi |
| 429 | `TOO_MANY_ATTEMPTS` | Kod kiritish urinishlari tugadi (3/3) | 3 ta noto'g'ri urinish |
| 429 | `SMS_RATE_LIMIT` | SMS yuborish limiti oshdi | Soatiga 5 tadan ko'p |
| 429 | `RETRY_TOO_SOON` | Qayta yuborish uchun kutish kerak | 60 soniya o'tmagan |
| 401 | `TOKEN_EXPIRED` | Access token muddati tugagan | JWT exp o'tgan |
| 401 | `TOKEN_INVALID` | Token noto'g'ri | JWT imzo xato yoki format noto'g'ri |
| 401 | `REFRESH_TOKEN_INVALID` | Refresh token topilmadi yoki muddati o'tgan | Noto'g'ri refresh token |
| 401 | `SESSION_REVOKED` | Sessiya bekor qilingan | Token theft aniqlanganda |
| 403 | `FORBIDDEN` | Ruxsat yo'q | Role huquqi yetarli emas |
| 403 | `USER_BLOCKED` | Foydalanuvchi bloklangan | Admin tomonidan bloklangan |

### 5.2 Validatsiya error misoli

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Kiritilgan ma'lumotlarda xatolik bor",
    "details": {
      "phone": "Telefon raqami +998 bilan boshlanishi kerak"
    }
  }
}
```

---

## 6. TypeScript interfeyslar

```typescript
// Base tiplar (ApiResponse, ApiError, UserRole) — RFC-000 da

// ============================================
// Request types
// ============================================

interface SendCodeRequest {
  phone: string; // "+998XXXXXXXXX" format
}

interface VerifyCodeRequest {
  phone: string;
  code: string; // 6 xonali raqam
}

interface RefreshTokenRequest {
  refresh_token: string;
}

interface LogoutRequest {
  refresh_token: string;
}

// ============================================
// Auth data types
// ============================================interface User {
  id: number;
  phone: string;
  first_name: string | null;
  last_name: string | null;
  role: UserRole;
  avatar_url: string | null;
  is_verified: boolean;
  created_at: string; // ISO 8601
}

interface AuthTokens {
  access_token: string;
  refresh_token: string;
  access_expires_in: number;  // soniyalarda (900)
  refresh_expires_in: number; // soniyalarda (2592000)
}

interface SendCodeData {
  phone: string;
  expires_in: number;   // kod amal qilish muddati (120s)
  retry_after: number;  // qayta yuborish uchun kutish (60s)
}

interface VerifyCodeData {
  user: User;
  tokens: AuthTokens;
  is_new_user: boolean;
}

// ============================================
// JWT Payload
// ============================================

interface JwtPayload {
  sub: number;       // user.id
  phone: string;
  role: UserRole;
  iat: number;       // issued at (unix timestamp)
  exp: number;       // expires at (unix timestamp)
}
```

---

## 7. Ketma-ketlik diagrammasi

### 7.1 Login / Register oqimi

```
Foydalanuvchi          Frontend              Backend              Eskiz.uz
     |                    |                     |                     |
     |-- Telefon kiritadi |                     |                     |
     |                    |-- POST /send-code -->|                     |
     |                    |                     |-- SMS yuborish ----->|
     |                    |                     |<-- OK ---------------|
     |                    |<-- 200 OK ----------|                     |
     |                    |                     |                     |
     |<-- SMS keladi -----|---------------------|---------------------|
     |                    |                     |                     |
     |-- Kodni kiritadi ->|                     |                     |
     |                    |-- POST /verify-code>|                     |
     |                    |                     |-- Kodni tekshirish  |
     |                    |                     |-- User yaratish/    |
     |                    |                     |   topish            |
     |                    |                     |-- Token yaratish    |
     |                    |<-- 200/201 + tokens-|                     |
     |                    |                     |                     |
     |                    |-- Access tokenni    |                     |
     |                    |   xotirada saqlash  |                     |
     |<-- Bosh sahifa ----|                     |                     |
```

### 7.2 Token yangilash oqimi

```
Frontend                          Backend
   |                                 |
   |-- API so'rov (expired token) -->|
   |<-- 401 TOKEN_EXPIRED -----------|
   |                                 |
   |-- POST /refresh --------------->|
   |                                 |-- refresh token tekshirish
   |                                 |-- eski tokenni o'chirish
   |                                 |-- yangi juftlik yaratish
   |<-- 200 + yangi tokenlar --------|
   |                                 |
   |-- Dastlabki so'rovni qaytadan ->|
   |<-- 200 OK ------ ---------------|
```

---

## 8. Frontend uchun eslatmalar

1. **Telefon raqami validatsiyasi:** Frontend tomonida `+998XX XXX XX XX` formatda input mask qo'yiladi. Serverga `+998XXXXXXXXX` (bo'shliksiz) yuboriladi.

2. **Countdown timer:** SMS yuborilgandan keyin 60 soniyalik timer ko'rsatiladi. Timer tugagunga qadar "Qayta yuborish" tugmasi disable bo'ladi.

3. **Kod kiritish:** 6 ta alohida input (OTP input pattern). Oxirgi raqam kiritilganda avtomatik verify so'rovi yuboriladi.

4. **Token saqlash:** Access token faqat xotira (React state / zustand store) da. Refresh token ham xotirada yoki httpOnly cookie da (backend bilan kelishiladi).

5. **Interceptor:** Axios/fetch interceptor 401 javobda avtomatik refresh qiladi. Agar refresh ham muvaffaqiyatsiz bo'lsa — login sahifasiga redirect.

6. **Admin panel:** Admin va moderator foydalanuvchilar `/admin` ga kirganda, `role` tekshiriladi. `customer` role bilan admin panelga kirish bloklangan.
