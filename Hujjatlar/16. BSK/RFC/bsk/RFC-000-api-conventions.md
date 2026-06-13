# RFC-000: API Umumiy Konvensiyalar — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 000 |
| **Modul** | Umumiy API konvensiyalar |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

---

## 1. Umumiy ko'rinish

Bu hujjat BSK FaceID Kirish Nazorati Tizimining barcha API endpointlari uchun yagona konvensiyalarni belgilaydi. Barcha RFC lar (001–007) shu hujjatga asoslanadi.

### 1.1 API Base URL

```
Production:  https://api.bsk.uz
Development: http://localhost:8080
```

Barcha endpointlar `/api/v1` prefiksi bilan boshlanadi:

```
https://api.bsk.uz/api/v1/residents
https://api.bsk.uz/api/v1/auth/login
https://api.bsk.uz/api/v1/admin/users
https://api.bsk.uz/api/v1/terminals/heartbeat
```

### 1.2 Content-Type

Barcha so'rov va javoblar `application/json` formatda (fayl yuklash bundan mustasno):

```
Content-Type: application/json
Accept: application/json
```

Yuz foto yuklash endpointlarida:

```
Content-Type: multipart/form-data
```

---

## 2. Request konvensiyalar

### 2.1 Autentifikatsiya header

Himoyalangan endpointlar uchun JWT access token:

```
Authorization: Bearer <access_token>
```

Terminal endpointlari uchun API key:

```
X-Terminal-Key: <api_key>
X-Terminal-Serial: <serial_number>
```

### 2.2 Query parametrlar

| Nomi | Turi | Tavsif |
|------|------|--------|
| `page` | number | Sahifa raqami (1 dan boshlanadi) |
| `per_page` | number | Har sahifadagi elementlar soni (default: 20, max: 100) |
| `sort` | string | Saralash maydoni (`-` belgisi teskari tartib: `-created_at`) |
| `search` | string | Qidiruv so'zi (trigram search) |
| `date_from` | string | Sana oralig'i boshi (ISO 8601) |
| `date_to` | string | Sana oralig'i oxiri (ISO 8601) |

- Boolean qiymatlar: `?is_active=true` yoki `?is_active=false`
- Bir nechta qiymat: `?status=active,blocked`

---

## 3. Response formatlari

### 3.1 Muvaffaqiyatli javob

```json
{
  "success": true,
  "message": "Ixtiyoriy xabar (CUD operatsiyalarda)",
  "data": {}
}
```

#### Bitta resurs (GET, POST, PATCH):

```json
{
  "success": true,
  "data": {
    "id": 1,
    "full_name": "Abdullayev Jasur",
    "phone_masked": "+998 90 *** 12 34"
  }
}
```

#### Ro'yxat (GET list):

```json
{
  "success": true,
  "data": {
    "items_key": [],
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

> `items_key` — kontekstga qarab: `residents`, `terminals`, `buildings`, `logs`, `users`, `guest_passes` va h.k.

#### O'chirish (DELETE):

```json
{
  "success": true,
  "message": "Rezident o'chirildi"
}
```

### 3.2 Xato javob

```json
{
  "success": false,
  "error": {
    "code": "RESIDENT_NOT_FOUND",
    "message": "Rezident topilmadi",
    "details": {}
  }
}
```

#### Validatsiya xatosi:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Kiritilgan ma'lumotlarda xatolik bor",
    "details": {
      "phone": "Telefon raqami +998 bilan boshlanishi kerak",
      "full_name": "Ism-sharif kamida 3 belgidan iborat bo'lishi kerak"
    }
  }
}
```

### 3.3 Pagination formati

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
| `current_page` | number | Joriy sahifa (1 dan boshlanadi) |
| `per_page` | number | Har sahifadagi elementlar |
| `total_items` | number | Jami elementlar soni |
| `total_pages` | number | Jami sahifalar soni |
| `has_next` | boolean | Keyingi sahifa bormi |
| `has_prev` | boolean | Oldingi sahifa bormi |

**Standart qiymatlar:**
- `page` default: `1`
- `per_page` default: `20`, max: `100`

---

## 4. HTTP status kodlar

### 4.1 Muvaffaqiyat

| Status | Qachon |
|--------|--------|
| `200 OK` | GET, PATCH, DELETE muvaffaqiyatli |
| `201 Created` | POST bilan yangi resurs yaratildi |

### 4.2 Klient xatolari

| Status | Qachon | Misol |
|--------|--------|-------|
| `400 Bad Request` | Validatsiya xatosi | Noto'g'ri format, yetishmagan maydon |
| `401 Unauthorized` | Token yo'q yoki noto'g'ri | Himoyalangan endpoint |
| `403 Forbidden` | Rol huquqi yetarli emas | Operator admin endpoint ga |
| `404 Not Found` | Resurs topilmadi | Noto'g'ri ID |
| `409 Conflict` | Biznes logika ziddiyati | Dublikat telefon raqam |
| `413 Payload Too Large` | Fayl hajmi oshdi | Yuz foto > 5MB |
| `415 Unsupported Media Type` | Fayl formati noto'g'ri | PDF yuz foto sifatida |
| `429 Too Many Requests` | Rate limit oshdi | OTP urinishlari |

### 4.3 Server xatolari

| Status | Qachon |
|--------|--------|
| `500 Internal Server Error` | Kutilmagan xato |
| `502 Bad Gateway` | Terminal yoki tashqi servis javob bermadi |
| `503 Service Unavailable` | Texnik ishlar |

---

## 5. Umumiy error kodlari

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `VALIDATION_ERROR` | Validatsiya xatosi |
| 401 | `UNAUTHORIZED` | Token yuborilmagan |
| 401 | `TOKEN_EXPIRED` | Access token muddati tugagan |
| 401 | `TOKEN_INVALID` | Token noto'g'ri |
| 403 | `FORBIDDEN` | Ruxsat yo'q (rol mos kelmaydi) |
| 403 | `USER_BLOCKED` | Foydalanuvchi bloklangan |
| 404 | `NOT_FOUND` | Resurs topilmadi |
| 429 | `RATE_LIMITED` | So'rovlar chastotasi oshdi |
| 500 | `INTERNAL_ERROR` | Server xatosi |

---

## 6. Fayl yuklash konvensiyasi

### 6.1 Cheklovlar

| Parametr | Qiymat |
|----------|--------|
| Yuz foto formatlari | `jpg`, `jpeg`, `png`, `webp` |
| Max yuz foto hajmi | 5 MB |
| Backend konvertatsiya | Barcha rasmlar `WebP` formatga |
| Thumbnail o'lchami | 80×80px |
| Full o'lcham | 400×400px |

### 6.2 Rasm URL pattern

```
/uploads/residents/{resident_id}/face_{n}.webp
/uploads/residents/{resident_id}/face_{n}_thumb.webp
/uploads/access_logs/{year}/{month}/{log_id}.webp
/uploads/organizations/{org_id}/logo.webp
```

---

## 7. Sana va vaqt formati

Barcha sana va vaqt qiymatlari **ISO 8601** formatda, **UTC** timezone da:

```
2026-03-17T14:30:00Z
```

Frontend `Asia/Tashkent` (UTC+5) ga konvert qiladi.

---

## 8. Telefon raqam maskalash

Loglarda va ba'zi response'larda telefon raqamlar maskalanadi:

```
+998 90 *** 12 34   (o'rta 3 ta raqam yashiriladi)
```

Bazada: AES-256 shifrlangan + SHA-256 hash (qidiruv uchun).

---

## 9. Rate limiting

| Endpoint | Limit | Oyna |
|----------|-------|------|
| `POST /api/v1/auth/send-otp` | 5 ta OTP | 1 soat (telefon raqamiga) |
| `POST /api/v1/auth/verify-otp` | 3 ta urinish | 1 kod uchun |
| `POST /api/v1/auth/login` | 5 ta urinish | 15 daqiqa (IP bo'yicha) |
| Admin API | 300 so'rov | 1 daqiqa |
| Terminal heartbeat | 1 so'rov | 30 soniya (terminal bo'yicha) |
| Umumiy API | 120 so'rov | 1 daqiqa (IP bo'yicha) |

Rate limit oshganda:

```
HTTP 429 Too Many Requests

Headers:
  Retry-After: 45
  X-RateLimit-Limit: 120
  X-RateLimit-Remaining: 0
  X-RateLimit-Reset: 1742220000
```

---

## 10. CORS sozlamalari

```
Access-Control-Allow-Origin: https://bsk.uz, https://admin.bsk.uz
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Terminal-Key, X-Terminal-Serial
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

---

## 11. Xavfsizlik qoidalari

- Barcha so'rovlar **TLS 1.3** orqali
- Telefon raqamlar log'larda yoki response'larda to'liq ko'rsatilmaydi (maskalangan)
- Yuz template vectorlari hech qachon API orqali qaytarilmaydi
- Prokuratura va IIV endpointlari har bir so'rov uchun audit log yozadi
- `security_access_logs` — har bir maxsus huquqli foydalanuvchi so'rovi qayd etiladi

---

## 12. TypeScript base tiplari

```typescript
// ============================================
// API Response wrapper
// ============================================

interface ApiResponse<T> {
  success: true;
  message?: string;
  data: T;
}

interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, string>;
  };
}

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

interface PaginationParams {
  page?: number;
  per_page?: number;
}

// ============================================
// Foydalanuvchi rollari
// ============================================

type UserRole =
  | "super_admin"
  | "bsk_admin"
  | "operator"
  | "gasn"
  | "construction"
  | "prosecutor"
  | "iiv";

// ============================================
// Tizim holatlari
// ============================================

type ResidentStatus = "active" | "blocked" | "archived" | "deleted";
type TerminalStatus = "online" | "offline" | "maintenance" | "error";
type EventType =
  | "DOOR_OPEN_SUCCESS"
  | "DOOR_OPEN_DENIED"
  | "DOOR_OPEN_MANUAL"
  | "LIVENESS_FAIL"
  | "DOOR_FORCED"
  | "SUSPICIOUS_ATTEMPT"
  | "DEVICE_ONLINE"
  | "DEVICE_OFFLINE"
  | "SYNC_COMPLETE"
  | "USER_ADDED"
  | "USER_DELETED"
  | "USER_TRANSFERRED";

type GuestPassStatus = "active" | "used" | "expired";
type SyncStatus = "pending" | "processing" | "completed" | "failed";
type NotificationStatus = "pending" | "sent" | "failed" | "read";
```

---

## 13. RFC lar ro'yxati

| RFC | Modul | Tavsif |
|-----|-------|--------|
| **RFC-000** | Umumiy konvensiyalar | Shu hujjat — barcha RFC lar uchun asos |
| **RFC-001** | Autentifikatsiya | Login, OTP, JWT tokenlar, 7 rol, route himoyasi |
| **RFC-002** | Rezidentlar | CRUD, yuz foto yuklash, ko'chirish, kirish huquqlari |
| **RFC-003** | Binolar va Terminallar | Binolar CRUD, terminal monitoring, sinxronizatsiya |
| **RFC-004** | Kirish Loglari | Voqealar log, filtrlash, foto ko'rish, eksport |
| **RFC-005** | Hisobotlar va Statistika | Dashboard, grafiklar, PDF/Excel eksport |
| **RFC-006** | Mehmon Kirish | QR/PIN generatsiya, vaqtinchalik ruxsat |
| **RFC-007** | Foydalanuvchilar | Admin/operator CRUD, audit log, xavfsizlik logi |
