# 00 — UMUMIY KONVENTSIYALAR

> Barcha endpointlar uchun amal qiladigan umumiy qoidalar.

---

## 1. JAVOB FORMATI

### ✅ Muvaffaqiyatli javob
```json
{
  "success": true,
  "data": { /* asosiy ma'lumot */ },
  "message": "Operation successful",
  "meta": { /* ixtiyoriy: pagination, total, etc */ }
}
```

### ❌ Xatolik javobi
```json
{
  "success": false,
  "error": {
    "code": 422,
    "type": "VALIDATION_ERROR",
    "message": "Validatsiya xatoligi",
    "details": {
      "card_number": ["Format noto'g'ri", "Luhn algoritmi yiqildi"],
      "amount_som": ["Balans yetarli emas"]
    }
  }
}
```

---

## 2. XATO TYPE'LARI

| HTTP | type | Qachon |
|------|------|--------|
| 400 | `BAD_REQUEST` | Noto'g'ri parametr formati |
| 401 | `UNAUTHORIZED` | Token yo'q yoki muddati o'tgan |
| 401 | `INVALID_CREDENTIALS` | Login/parol noto'g'ri |
| 403 | `FORBIDDEN` | Ruxsat yo'q (RBAC) |
| 403 | `USER_BLOCKED` | Foydalanuvchi bloklangan |
| 404 | `NOT_FOUND` | Resurs topilmadi |
| 409 | `INVALID_STATE` | FSM qoidasi buzilgan (masalan: `paid` arizani `reject` qilib bo'lmaydi) |
| 409 | `STALE_OBJECT` | Optimistic lock conflict (`version` o'zgargan) |
| 409 | `INSUFFICIENT_BALANCE` | Balans yetarli emas |
| 409 | `DUPLICATE` | Takroriy yozuv (UNIQUE constraint) |
| 422 | `VALIDATION_ERROR` | Maydon validatsiyasi yiqildi |
| 423 | `PIN_LOCKED` | PIN bloklangan |
| 423 | `RATE_LIMITED` | Endpoint vaqtinchalik bloklangan |
| 429 | `TOO_MANY_REQUESTS` | Rate limit oshirildi |
| 500 | `INTERNAL_ERROR` | Backend xatolik (log'da batafsil) |

---

## 3. PAGINATSIYA

### Request (query params)
```
?page=1&per_page=20&sort=-created_at
```

| Parametr | Default | Max | Izoh |
|----------|---------|-----|------|
| `page` | 1 | — | Sahifa raqami (1 dan boshlanadi) |
| `per_page` | 20 | 100 | Bir sahifadagi yozuvlar soni |
| `sort` | `-created_at` | — | `field` (asc) yoki `-field` (desc). Vergul bilan ko'p: `-created_at,id` |

### Response meta
```json
{
  "success": true,
  "data": [ /* yozuvlar massivi */ ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 145,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

### Response headerlar
```http
X-Pagination-Total-Count: 145
X-Pagination-Page-Count: 8
X-Pagination-Current-Page: 1
X-Pagination-Per-Page: 20
```

---

## 4. FILTRLASH

Query parametrlar orqali. Operator suffix bilan:

| Suffix | Ma'nosi | Misol |
|--------|---------|-------|
| (yo'q) | Aynan teng | `status=pending` |
| `[in]` | Massivda | `status[in]=pending,approved` |
| `[gte]` | ≥ | `created_at[gte]=2026-01-01` |
| `[lte]` | ≤ | `amount_som[lte]=1000000` |
| `[like]` | LIKE %X% | `name[like]=ismoil` |
| `[ne]` | ≠ | `status[ne]=rejected` |
| `[null]` | IS NULL | `admin_id[null]=true` |

### Misol
```http
GET /api/v1/admin/installations?status[in]=pending,approved&created_at[gte]=2026-04-01&user_id=15&sort=-total_amount&page=1&per_page=50
```

---

## 5. SANA / VAQT FORMATI

- **ISO 8601 (UTC):** `2026-04-18T13:25:00Z`
- **Sana (faqat sana):** `2026-04-18`
- **Vaqt zonasi:** Backend UTC saqlaydi, Frontend `Asia/Tashkent` (`+05:00`) ga konvertatsiya qiladi
- **Filterlarda:** `?created_at[gte]=2026-04-01T00:00:00+05:00`

---

## 6. PUL / SUMMA FORMATI

- **Server tomonida:** `DECIMAL(15,2)` → JSON da `string` ko'rinishida (`"1234567.89"`) yoki `number` (kichik qiymatlar uchun)
- **Frontend formatlash:** `1 234 567.89 so'm` (probel — minglik ajratuvchi, vergul — kasr)
- **Ball:** `INT` → JSON da `number` (`240`)

> ⚠️ Floating-point xatosidan qochish uchun pul `string` sifatida tavsiya etiladi:
> ```json
> {"amount_som": "1234567.89", "points": 240}
> ```

---

## 7. RATE LIMITING

| Endpoint guruhi | Limit | Window |
|-----------------|-------|--------|
| `/api/v1/auth/*` | 10 req | 1 daqiqa / IP |
| `/api/v1/bot/webhook` | 1000 req | 1 daqiqa / IP |
| `/api/v1/bot/pin/verify` | 5 req | 1 daqiqa / user |
| Boshqalar | 60 req | 1 daqiqa / IP yoki user |

### Response (429)
```json
{
  "success": false,
  "error": {
    "code": 429,
    "type": "TOO_MANY_REQUESTS",
    "message": "So'rov chegarasi oshirildi",
    "details": {"retry_after": 30}
  }
}
```

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1735689600
Retry-After: 30
```

---

## 8. CORS

```http
Access-Control-Allow-Origin: https://admin.powersun.uz
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Request-ID
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

Faqat ro'yxatga olingan domenlar ruxsat etiladi. Dev'da `http://localhost:5173` (Vite default).

---

## 9. ENUMS

### Installation status
```typescript
type InstallationStatus = 'pending' | 'approved' | 'rejected' | 'paid';
```

### Withdrawal status
```typescript
type WithdrawalStatus = 'pending' | 'approved' | 'paid' | 'rejected';
```

### User customer type
```typescript
type CustomerType = 'individual' | 'legal' | 'sole_proprietor';
```

### User status
```typescript
type UserStatus = 'active' | 'blocked';
```

### Admin role
```typescript
type AdminRole = 'superadmin' | 'admin';
```

### Object type (installation)
```typescript
type ObjectType = 'house' | 'factory' | 'office' | 'other';
```

### Material unit
```typescript
type MaterialUnit = 'meter' | 'piece' | 'set' | 'kg';
```

### Photo type
```typescript
type PhotoType = 'inverter_close' | 'installed_view' | 'cable_connection' | 'other';
```

### Notification status
```typescript
type NotificationStatus = 'pending' | 'sent' | 'failed';
```

---

## 10. UMUMIY MA'LUMOT TURLARI

### `User` (qisqartirilgan)
```typescript
interface UserBrief {
  id: number;
  name: string;
  phone: string;
  telegram_id: number;
}
```

### `Admin` (qisqartirilgan)
```typescript
interface AdminBrief {
  id: number;
  name: string;
  role: AdminRole;
}
```

### `Region`
```typescript
interface Region {
  id: number;
  title: string;
}
```

### `District`
```typescript
interface District {
  id: number;
  title: string;
  region_id: number;
}
```

---

## 11. WEBSOCKET / REAL-TIME (Kelajak uchun)

v2.1 da WebSocket yo'q. Frontend polling ishlatadi (Dashboard 30s, Withdrawals 15s).

v3.0 da Pusher / Socket.IO orqali real-time push rejada.

---

## 12. IDEMPOTENT SO'ROVLAR

`PUT /approve`, `/reject`, `/mark-paid` kabi FSM action'lar **idempotent**:
- Birinchi murojaat → action bajariladi
- Takroriy murojaat → 409 `INVALID_STATE` (chunki status allaqachon o'zgargan)

Idempotency key (ixtiyoriy) header orqali:
```http
Idempotency-Key: uuid-v4
```

24 soat davomida bir xil key bilan kelgan so'rov birinchi javobni qaytaradi.
