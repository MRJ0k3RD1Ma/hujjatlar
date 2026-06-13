# RFC-006: Mehmon Kirish — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 006 |
| **Modul** | Mehmon Kirish (Guest Access) |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

---

## 1. Umumiy ko'rinish

Bu RFC BSK FaceID tizimida ro'yxatdan o'tmagan mehmonga vaqtinchalik kirish ruxsatnomasi berish mexanizmini belgilaydi. Mehmonga **QR kod** yoki **PIN kod** orqali muayyan bino terminallaridan kirish imkoniyati yaratiladi.

### 1.1 Modeldagi jadvallar

- `guest_passes` — mehmon ruxsatnomasi (QR/PIN, muddati, foydalanish soni)
- `access_logs` — mehmon kirish hodisalari ham shu jadvalda (resident_id = null, guest_pass_id to'ldirilgan)

### 1.2 Mehmon kirish turlari

| Tur | Mexanizm | Foydalanish |
|-----|---------|-------------|
| **QR kod** | Terminal kamerasi QR o'qiydi | Bir martalik yoki vaqt cheklangan |
| **PIN kod** | Terminal klaviaturasida 6 xonali PIN | Bir martalik yoki vaqt cheklangan |

### 1.3 Foydalanuvchi rollari bo'yicha ruxsatlar

| Rol | Yaratish | Ko'rish | Bekor qilish |
|-----|---------|---------|--------------|
| `super_admin` | Ha | Barcha | Ha |
| `bsk_admin` | Ha | Barcha | Ha |
| `operator` | Ha | O'z binolari | Ha |
| `gasn` | Yo'q | Yo'q | Yo'q |
| `construction` | Yo'q | Yo'q | Yo'q |
| `prosecutor` | Yo'q | Yo'q | Yo'q |
| `iiv` | Yo'q | Yo'q | Yo'q |

---

## 2. Endpointlar ro'yxati

| Method | Endpoint | Tavsif | Rol |
|--------|----------|--------|-----|
| GET | `/api/v1/guest-passes` | Ruxsatnomalar ro'yxati | super_admin, bsk_admin, operator |
| GET | `/api/v1/guest-passes/{id}` | Bitta ruxsatnoma batafsil | super_admin, bsk_admin, operator |
| POST | `/api/v1/guest-passes` | Yangi ruxsatnoma yaratish | super_admin, bsk_admin, operator |
| PATCH | `/api/v1/guest-passes/{id}` | Ruxsatnomani tahrirlash | super_admin, bsk_admin, operator |
| DELETE | `/api/v1/guest-passes/{id}` | Ruxsatnomani bekor qilish | super_admin, bsk_admin, operator |
| GET | `/api/v1/guest-passes/{id}/qr` | QR kod rasmini olish | super_admin, bsk_admin, operator |
| POST | `/api/v1/guest-passes/{id}/regenerate` | QR/PIN yangilash | super_admin, bsk_admin, operator |
| GET | `/api/v1/guest-passes/{id}/usage-logs` | Foydalanish loglari | super_admin, bsk_admin, operator |
| **Terminal Protocol** | | | |
| POST | `/api/v1/terminal/validate-guest` | Terminal: mehmon kodni tekshirish | Terminal (X-Terminal-Key) |

---

## 3. Endpointlar batafsil

### 3.1 GET /api/v1/guest-passes

Mehmon ruxsatnomalar ro'yxati.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page` | number | Sahifa raqami |
| `per_page` | number | Default 20 |
| `building_id` | number | Bino filtri |
| `status` | string | `active`, `used`, `expired` (vergul bilan ko'p) |
| `date_from` | string | Yaratilgan sanadan |
| `date_to` | string | Yaratilgan sanagacha |
| `search` | string | Mehmon ismi yoki izoh bo'yicha qidiruv |
| `sort` | string | `-created_at` (default), `expires_at` |

**Request:**

```http
GET /api/v1/guest-passes?status=active&building_id=1
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "guest_passes": [
      {
        "id": 245,
        "code_type": "qr",
        "status": "active",
        "guest_name": "Rahimov Sardor",
        "guest_phone_masked": "+998 90 *** 45 67",
        "note": "Plombirchi usta, 42-xonadon uchun",
        "building": {
          "id": 1,
          "name": "Navruz-1 MJK"
        },
        "terminals": [
          { "id": 5, "name": "Bosh kirish" }
        ],
        "apartment": "42",
        "created_by": {
          "id": 7,
          "full_name": "Operator Aziz"
        },
        "valid_from": "2026-03-17T08:00:00Z",
        "valid_until": "2026-03-17T18:00:00Z",
        "max_uses": 1,
        "used_count": 0,
        "created_at": "2026-03-17T07:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 48,
      "total_pages": 3,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

---

### 3.2 GET /api/v1/guest-passes/{id}

Bitta ruxsatnoma to'liq ma'lumot.

**Request:**

```http
GET /api/v1/guest-passes/245
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": 245,
    "code_type": "qr",
    "status": "active",
    "guest_name": "Rahimov Sardor",
    "guest_phone_masked": "+998 90 *** 45 67",
    "note": "Plombirchi usta, 42-xonadon uchun",
    "building": {
      "id": 1,
      "name": "Navruz-1 MJK",
      "address": "Yunusobod tumani, 14-mavze"
    },
    "terminals": [
      { "id": 5, "name": "Bosh kirish", "direction": "entry" }
    ],
    "apartment": "42",
    "floor": 8,
    "created_by": {
      "id": 7,
      "full_name": "Operator Aziz",
      "role": "operator"
    },
    "valid_from": "2026-03-17T08:00:00Z",
    "valid_until": "2026-03-17T18:00:00Z",
    "max_uses": 1,
    "used_count": 0,
    "last_used_at": null,
    "qr_url": "/api/v1/guest-passes/245/qr",
    "pin_code": null,
    "created_at": "2026-03-17T07:30:00Z",
    "updated_at": "2026-03-17T07:30:00Z"
  }
}
```

> `pin_code` — `code_type: "pin"` bo'lganda 6 xonali raqam sifatida qaytariladi. QR uchun `null`.
> `qr_url` — `code_type: "qr"` bo'lganda to'ldiriladi, PIN uchun `null`.

---

### 3.3 POST /api/v1/guest-passes

Yangi mehmon ruxsatnomasi yaratish.

**Request body:**

```json
{
  "code_type": "qr",
  "guest_name": "Rahimov Sardor",
  "guest_phone": "+998901234567",
  "note": "Plombirchi usta, 42-xonadon uchun",
  "building_id": 1,
  "terminal_ids": [5],
  "apartment": "42",
  "valid_from": "2026-03-17T08:00:00Z",
  "valid_until": "2026-03-17T18:00:00Z",
  "max_uses": 1
}
```

**Maydonlar:**

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|----------|--------|
| `code_type` | string | Ha | `qr` yoki `pin` |
| `guest_name` | string | Ha | Mehmon ismi (min 3, max 100 belgi) |
| `guest_phone` | string | Yo'q | Mehmon telefoni (+998XXXXXXXXX) |
| `note` | string | Yo'q | Izoh (max 500 belgi) |
| `building_id` | number | Ha | Bino ID |
| `terminal_ids` | number[] | Ha | Ruxsat beriladigan terminallar (min 1) |
| `apartment` | string | Yo'q | Xonadon raqami |
| `valid_from` | string | Ha | Boshlanish vaqti (ISO 8601) |
| `valid_until` | string | Ha | Tugash vaqti (ISO 8601) |
| `max_uses` | number | Yo'q | Maksimal foydalanish (default: 1, max: 10, `null` = cheksiz) |

**Response 201:**

```json
{
  "success": true,
  "message": "Mehmon ruxsatnomasi yaratildi",
  "data": {
    "id": 245,
    "code_type": "qr",
    "status": "active",
    "guest_name": "Rahimov Sardor",
    "guest_phone_masked": "+998 90 *** 45 67",
    "note": "Plombirchi usta, 42-xonadon uchun",
    "building": {
      "id": 1,
      "name": "Navruz-1 MJK"
    },
    "terminals": [
      { "id": 5, "name": "Bosh kirish", "direction": "entry" }
    ],
    "apartment": "42",
    "valid_from": "2026-03-17T08:00:00Z",
    "valid_until": "2026-03-17T18:00:00Z",
    "max_uses": 1,
    "used_count": 0,
    "qr_url": "/api/v1/guest-passes/245/qr",
    "pin_code": null,
    "created_at": "2026-03-17T07:30:00Z"
  }
}
```

**PIN yaratish uchun:**

```json
{
  "code_type": "pin",
  "guest_name": "Usmonov Kamol",
  "building_id": 1,
  "terminal_ids": [5, 6],
  "valid_from": "2026-03-17T00:00:00Z",
  "valid_until": "2026-03-20T23:59:59Z",
  "max_uses": 3
}
```

**Response (PIN):**

```json
{
  "success": true,
  "data": {
    "id": 246,
    "code_type": "pin",
    "pin_code": "847291",
    "qr_url": null,
    ...
  }
}
```

> `pin_code` faqat yaratilganda bir marta qaytariladi. Keyingi so'rovlarda `null` keladi.

---

### 3.4 PATCH /api/v1/guest-passes/{id}

Ruxsatnomani tahrirlash (faqat `active` holat uchun).

**Request body (partial update):**

```json
{
  "note": "Yangilangan izoh",
  "valid_until": "2026-03-17T20:00:00Z",
  "max_uses": 2
}
```

> O'zgartirish mumkin: `note`, `valid_until`, `max_uses`, `terminal_ids`
> O'zgartirib bo'lmaydi: `code_type`, `building_id`, `valid_from`

**Response 200:**

```json
{
  "success": true,
  "message": "Ruxsatnoma yangilandi",
  "data": { ... }
}
```

---

### 3.5 DELETE /api/v1/guest-passes/{id}

Ruxsatnomani bekor qilish (soft cancel — status `expired` ga o'tadi).

**Request:**

```http
DELETE /api/v1/guest-passes/245
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "message": "Mehmon ruxsatnomasi bekor qilindi"
}
```

---

### 3.6 GET /api/v1/guest-passes/{id}/qr

QR kod tasvirini olish (PNG yoki SVG).

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `format` | string | `png` (default) yoki `svg` |
| `size` | number | Piksel o'lchami (default: 300, max: 1000) |

**Request:**

```http
GET /api/v1/guest-passes/245/qr?format=png&size=400
Authorization: Bearer <access_token>
```

**Response 200:**

```
Content-Type: image/png
(binary data)
```

> Frontend bu URL ni `<img src="...">` tegiga to'g'ridan-to'g'ri ishlatishi mumkin.

---

### 3.7 POST /api/v1/guest-passes/{id}/regenerate

QR kod yoki PIN kodni yangilash (eski kod bekor qilinadi).

**Request:**

```http
POST /api/v1/guest-passes/246/regenerate
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "message": "PIN yangilandi",
  "data": {
    "id": 246,
    "code_type": "pin",
    "pin_code": "312847",
    "updated_at": "2026-03-17T09:00:00Z"
  }
}
```

---

### 3.8 GET /api/v1/guest-passes/{id}/usage-logs

Ruxsatnomadan foydalanish loglari.

**Request:**

```http
GET /api/v1/guest-passes/245/usage-logs
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "guest_pass": {
      "id": 245,
      "guest_name": "Rahimov Sardor",
      "max_uses": 1,
      "used_count": 1
    },
    "usage_logs": [
      {
        "access_log_id": 10400,
        "terminal": {
          "id": 5,
          "name": "Bosh kirish"
        },
        "is_success": true,
        "event_type": "DOOR_OPEN_SUCCESS",
        "created_at": "2026-03-17T09:15:33Z"
      }
    ]
  }
}
```

---

### 3.9 POST /api/v1/terminal/validate-guest

**Terminal Protocol** — terminal tomonidan mehmon kodni tekshirish va kirish log yozish.

**Auth:** `X-Terminal-Key` + `X-Terminal-Serial`

**Request body:**

```json
{
  "code_type": "qr",
  "code_value": "BSK-GUEST-245-a7f8c2d1e9b3",
  "captured_at": "2026-03-17T09:15:30Z"
}
```

> `code_type`: `qr` | `pin`
> `code_value`: QR uchun token string, PIN uchun 6 xonali raqam

**Response 200 — Ruxsat berildi:**

```json
{
  "success": true,
  "data": {
    "decision": "allow",
    "guest_pass_id": 245,
    "guest_name": "Rahimov Sardor",
    "apartment": "42",
    "valid_until": "2026-03-17T18:00:00Z",
    "remaining_uses": 0,
    "access_log_id": 10400,
    "display_message": "Kirish ruxsati berildi\nRahimov Sardor\n42-xonadon"
  }
}
```

**Response 200 — Rad etildi:**

```json
{
  "success": true,
  "data": {
    "decision": "deny",
    "reason": "EXPIRED",
    "guest_pass_id": null,
    "access_log_id": 10401,
    "display_message": "Kirish rad etildi\nMuddati tugagan"
  }
}
```

> Har ikki holatda ham HTTP 200 qaytariladi — bu terminal protokolining standart yondashuvi. `decision` maydoni `allow` | `deny` ni belgilaydi.

**Rad etish sabablari (`reason`):**

| Sabab | Tavsif |
|-------|--------|
| `NOT_FOUND` | Kod topilmadi |
| `EXPIRED` | Muddati tugagan |
| `MAX_USES_REACHED` | Maksimal foydalanish soni to'ldi |
| `INVALID_TERMINAL` | Bu terminal uchun ruxsat yo'q |
| `NOT_STARTED` | `valid_from` hali kelmagan |
| `CANCELLED` | Bekor qilingan |

---

## 4. Biznes qoidalar

### 4.1 QR kod formati

- QR kod: `BSK-GUEST-{id}-{random_token}` (random token 24 belgi, bir martalik)
- QR ko'rinishi: `https://bsk.uz/guest/{token}` URL sifatida enkodlanadi (terminal bu URLni o'qiydi)
- Terminal faqat `BSK-GUEST-` prefiksli tokenlarni mehmon kodi sifatida qabul qiladi

### 4.2 PIN kod formati

- 6 ta raqam, tasodifiy generatsiya
- `000000`, `123456` kabi oddiy kombinatsiyalar rad etiladi
- PIN faqat yaratilganda bir marta API javobida ko'rsatiladi — keyinchalik bazadan regenerate qilish kerak

### 4.3 Muddat va foydalanish

- `valid_from` hozirgi vaqtdan kechiktirish mumkin (kelajakka rejalashtirish)
- `valid_until` maksimal: `valid_from` dan 30 kun ichida
- `max_uses: null` = cheksiz, lekin muddat doirasida
- Foydalanish soni dolzarb: `used_count >= max_uses` bo'lsa `MAX_USES_REACHED`
- Muddat o'tganda `status` avtomatik `expired` ga o'tadi (cron job)

### 4.4 Terminal cheklovlari

- Ruxsatnoma faqat `terminal_ids` da ko'rsatilgan terminallarda ishlaydi
- Terminal `validate-guest` so'rovida avtomatik kirish logi yaratadi
- Offline terminallarda mehmon kirishi mumkin emas — real-time tekshirish kerak (internet bo'lishi shart)

### 4.5 Xavfsizlik

- `guest_phone` bazada AES-256 shifrlangan, response'da maskalangan
- QR token bir martalik — foydalanilgandan so'ng `max_uses: 1` bo'lsa eski tokenni qayta kiritib bo'lmaydi
- `regenerate` qilinganda eski token bekor qilinadi va access_log ga yoziladi
- Bekor qilingan ruxsatnomalar bazadan o'chirilmaydi — audit uchun saqlanadi

---

## 5. Error kodlar

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `VALIDATION_ERROR` | Noto'g'ri ma'lumotlar |
| 400 | `INVALID_DATE_RANGE` | `valid_from` > `valid_until` |
| 400 | `DATE_TOO_FAR` | `valid_until` 30 kundan ko'p |
| 400 | `INVALID_TERMINAL` | Ko'rsatilgan terminal shu binoga tegishli emas |
| 400 | `GUEST_PASS_NOT_ACTIVE` | Faqat active ruxsatnomani tahrirlash mumkin |
| 403 | `FORBIDDEN` | Boshqa operatorning ruxsatnomasini o'zgartira olmaysiz |
| 404 | `GUEST_PASS_NOT_FOUND` | Ruxsatnoma topilmadi |
| 409 | `PIN_COLLISION` | PIN generatsiyada takrorlanish (qayta urinish) |

**Terminal protokoli xatolari:**

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `INVALID_CODE_FORMAT` | Noto'g'ri kod formati |
| 401 | `TERMINAL_UNAUTHORIZED` | Terminal kaliti noto'g'ri |

---

## 6. TypeScript interfeyslari

```typescript
// ============================================
// Guest Pass
// ============================================

type GuestPassCodeType = "qr" | "pin";
type GuestPassStatus = "active" | "used" | "expired";

interface GuestPassTerminal {
  id: number;
  name: string;
  direction?: "entry" | "exit";
}

interface GuestPassSummary {
  id: number;
  code_type: GuestPassCodeType;
  status: GuestPassStatus;
  guest_name: string;
  guest_phone_masked: string | null;
  note: string | null;
  building: {
    id: number;
    name: string;
  };
  terminals: GuestPassTerminal[];
  apartment: string | null;
  created_by: {
    id: number;
    full_name: string;
  };
  valid_from: string;
  valid_until: string;
  max_uses: number | null;
  used_count: number;
  created_at: string;
}

interface GuestPassDetail extends GuestPassSummary {
  building: {
    id: number;
    name: string;
    address: string;
  };
  floor: number | null;
  created_by: {
    id: number;
    full_name: string;
    role: string;
  };
  last_used_at: string | null;
  qr_url: string | null;
  pin_code: string | null; // faqat yaratilganda
  updated_at: string;
}

// ============================================
// Requests
// ============================================

interface CreateGuestPassRequest {
  code_type: GuestPassCodeType;
  guest_name: string;
  guest_phone?: string;
  note?: string;
  building_id: number;
  terminal_ids: number[];
  apartment?: string;
  valid_from: string;
  valid_until: string;
  max_uses?: number | null;
}

interface UpdateGuestPassRequest {
  note?: string;
  valid_until?: string;
  max_uses?: number | null;
  terminal_ids?: number[];
}

// ============================================
// Usage Logs
// ============================================

interface GuestPassUsageLog {
  access_log_id: number;
  terminal: {
    id: number;
    name: string;
  };
  is_success: boolean;
  event_type: EventType;
  created_at: string;
}

// ============================================
// Terminal Protocol
// ============================================

type GuestValidateDecision = "allow" | "deny";
type GuestDenyReason =
  | "NOT_FOUND"
  | "EXPIRED"
  | "MAX_USES_REACHED"
  | "INVALID_TERMINAL"
  | "NOT_STARTED"
  | "CANCELLED";

interface ValidateGuestRequest {
  code_type: GuestPassCodeType;
  code_value: string;
  captured_at: string;
}

interface ValidateGuestResponse {
  decision: GuestValidateDecision;
  guest_pass_id: number | null;
  guest_name?: string;
  apartment?: string;
  valid_until?: string;
  remaining_uses?: number;
  reason?: GuestDenyReason;
  access_log_id: number;
  display_message: string;
}

// ============================================
// Query Params
// ============================================

interface GuestPassesQueryParams extends PaginationParams {
  building_id?: number;
  status?: string; // "active,used,expired"
  date_from?: string;
  date_to?: string;
  search?: string;
  sort?: string;
}
```

---

## 7. Frontend eslatmalari

### 7.1 Ruxsatnoma yaratish forma

```
┌─────────────────────────────────────────┐
│  Yangi mehmon ruxsatnomasi              │
├─────────────────────────────────────────┤
│  Tur:  [● QR kod]  [○ PIN kod]          │
│                                         │
│  Mehmon ismi: [________________]        │
│  Telefon:     [________________] (ixt.) │
│  Izoh:        [________________] (ixt.) │
│                                         │
│  Bino:     [Navruz-1 MJK      ▼]        │
│  Terminal: [✓] Bosh kirish              │
│            [ ] Orqa kirish              │
│  Xonadon:  [________________] (ixt.)   │
│                                         │
│  Boshlanish: [2026-03-17 08:00]         │
│  Tugash:     [2026-03-17 18:00]         │
│  Foydalanish: [1▼] (1, 2, 3, ... cheksiz) │
│                                         │
│         [Bekor qilish] [Yaratish]       │
└─────────────────────────────────────────┘
```

### 7.2 QR kod modal

- Ruxsatnoma yaratilgandan so'ng avtomatik QR kod modal oynada ko'rsatiladi
- Modal: QR rasm + mehmon ismi + muddat + "Nusxa olish" + "Yuklab olish" (PNG)
- PIN uchun: katta shrift bilan 6 xonali raqam + "Nusxa olish" tugmasi
- "Qayta yuborish" — SMS orqali mehmon telefoniga yuborish (agar telefon ko'rsatilgan bo'lsa)

### 7.3 Holat ko'rsatish

| Holat | Rang | Belgi |
|-------|------|-------|
| `active` (muddati kelmagan) | Ko'k | `Kutilmoqda` |
| `active` (muddat ichida) | Yashil | `Faol` |
| `used` (to'liq foydalanilgan) | Kulrang | `Ishlatildi` |
| `expired` | Sariq | `Muddati o'tdi` |
| Bekor qilingan | Qizil | `Bekor qilindi` |

### 7.4 Real-time holat yangilanishi

- Ruxsatnoma terminal tomonidan ishlatilib, `used_count` o'zgarganda — ro'yxat avtomatik yangilanishi kerak
- WebSocket orqali `guest_pass.used` hodisasi kuzatilishi mumkin

### 7.5 QR kod yuklab olish

```html
<a href="/api/v1/guest-passes/245/qr?format=png&size=400" download="guest-pass-245.png">
  Yuklab olish
</a>
```

Frontend Authorization headerini cookie yoki download tokeniga ko'chirishi kerak, chunki `<a download>` Authorization headerni qo'sha olmaydi. Yechim: `GET /api/v1/guest-passes/{id}/qr?token={short_token}` — 1 daqiqa muddatli yuklab olish tokeni.
