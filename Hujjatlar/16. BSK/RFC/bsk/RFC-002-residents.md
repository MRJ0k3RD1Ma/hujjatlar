# RFC-002: Rezidentlar Boshqaruvi — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 002 |
| **Modul** | Rezidentlar, yuz fotolar, kirish huquqlari, ko'chirish |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

> **Asos:** RFC-000 (konvensiyalar), RFC-001 (autentifikatsiya).

---

## 1. Umumiy ko'rinish

Rezident — binoda yashovchi shaxs. Tizim rezidentni **telefon raqami** orqali identifikatsiya qiladi (pasport ma'lumotlari saqlanmaydi). Har bir rezidentning yuz shabloni (template) terminalga sinxronlashtiriladi. Rezidentni bir binodан boshqasiga ko'chirish mumkin — tarixi saqlanadi.

### 1.1 Asosiy qoidalar

- **Pasport ma'lumotlari saqlanmaydi** — faqat ism-sharif va telefon raqam
- Telefon raqam bazada **AES-256** shifrlangan + **SHA-256** hash (qidiruv uchun)
- API response'da telefon **maskalangan**: `+998 90 *** 12 34`
- Yuz foto vectorlari API orqali **qaytarilmaydi** (faqat terminal sinxronizatsiyasida)

---

## 2. API Endpointlar

### 2.1 Rezidentlar ro'yxati

**`GET /api/v1/residents`**

**Headers:** `Authorization: Bearer <access_token>`

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 20 | Har sahifada (max 100) |
| `search` | string | — | Ism-sharif, xonadon raqami bo'yicha |
| `building_id` | number | — | Bino bo'yicha filter |
| `status` | string | `active` | `active`, `blocked`, `archived`, `all` |
| `sort` | string | `-created_at` | `full_name`, `-full_name`, `-created_at`, `apartment_number` |
| `floor` | number | — | Qavat bo'yicha |

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "residents": [
      {
        "id": 42,
        "full_name": "Abdullayev Jasur",
        "phone_masked": "+998 90 *** 12 34",
        "building": {
          "id": 1,
          "name": "Chilonzor-14"
        },
        "apartment_number": "35",
        "floor_number": 4,
        "status": "active",
        "face_count": 2,
        "has_access": true,
        "created_at": "2025-06-15T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 145,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

**Biznes qoidalar:**
- `bsk_admin` faqat o'z tashkiloti binolaridagi rezidentlarni ko'radi
- `operator` faqat o'z binosidagi rezidentlarni ko'radi
- `gasn`, `construction` — bu endpoint ga kirish yo'q (`403 FORBIDDEN`)
- `face_count` — shu rezidentning yuz shablonlari soni
- `has_access` — kamida bitta aktiv terminali bormi

---

### 2.2 Rezident batafsil

**`GET /api/v1/residents/:id`**

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 42,
    "full_name": "Abdullayev Jasur",
    "phone_masked": "+998 90 *** 12 34",
    "building": {
      "id": 1,
      "name": "Chilonzor-14",
      "address": "Chilonzor tumani, 14-uy"
    },
    "apartment_number": "35",
    "floor_number": 4,
    "status": "active",
    "face_templates": [
      {
        "id": 1,
        "photo_thumb_url": "https://api.bsk.uz/uploads/residents/42/face_1_thumb.webp",
        "is_primary": true,
        "quality_score": 95,
        "created_at": "2025-06-15T10:00:00Z"
      },
      {
        "id": 2,
        "photo_thumb_url": "https://api.bsk.uz/uploads/residents/42/face_2_thumb.webp",
        "is_primary": false,
        "quality_score": 88,
        "created_at": "2025-06-15T10:05:00Z"
      }
    ],
    "terminal_access": [
      {
        "terminal_id": 1,
        "terminal_name": "Terminal-1 (Asosiy kirish)",
        "building_name": "Chilonzor-14",
        "is_active": true,
        "access_start": null,
        "access_end": null
      },
      {
        "terminal_id": 2,
        "terminal_name": "Terminal-2 (Orqa kirish)",
        "building_name": "Chilonzor-14",
        "is_active": true,
        "access_start": "2026-01-01T06:00:00Z",
        "access_end": "2026-12-31T23:59:00Z"
      }
    ],
    "recent_access": [
      {
        "event_type": "DOOR_OPEN_SUCCESS",
        "terminal_name": "Terminal-1 (Asosiy kirish)",
        "photo_thumb_url": "https://api.bsk.uz/uploads/access_logs/2026/03/log_5001_thumb.webp",
        "created_at": "2026-03-17T14:32:15Z"
      },
      {
        "event_type": "DOOR_OPEN_SUCCESS",
        "terminal_name": "Terminal-1 (Asosiy kirish)",
        "photo_thumb_url": null,
        "created_at": "2026-03-16T09:15:00Z"
      }
    ],
    "created_at": "2025-06-15T10:00:00Z",
    "updated_at": "2026-01-10T14:00:00Z"
  }
}
```

**Biznes qoidalar:**
- Yuz template vector ma'lumotlari (encrypted bytes) qaytarilmaydi — faqat thumbnail URL
- `quality_score` — yuz tanish sifati (0-100)
- `recent_access` — oxirgi 5 ta kirish voqeasi
- `access_start` / `access_end` — `null` bo'lsa cheksiz

---

### 2.3 Rezident qo'shish

**`POST /api/v1/residents`**

**Headers:** `Authorization: Bearer <access_token>`

**Request (JSON — 1-qadam: Shaxsiy ma'lumotlar):**

```json
{
  "full_name": "Abdullayev Jasur",
  "phone": "+998901234567",
  "building_id": 1,
  "apartment_number": "35",
  "floor_number": 4
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Rezident qo'shildi. Yuz foto yuklang.",
  "data": {
    "id": 42,
    "full_name": "Abdullayev Jasur",
    "phone_masked": "+998 90 *** 12 34",
    "building": {
      "id": 1,
      "name": "Chilonzor-14"
    },
    "apartment_number": "35",
    "floor_number": 4,
    "status": "active",
    "face_templates": [],
    "terminal_access": [],
    "created_at": "2026-03-17T10:00:00Z"
  }
}
```

**Biznes qoidalar:**
- Telefon raqami tizimda **unikal** bo'lishi kerak (SHA-256 hash bo'yicha tekshiriladi)
- `phone_hash` — SHA-256(telefon), bazada UNIQUE
- `building_id` — foydalanuvchining ruxsati bor bino bo'lishi kerak
- Rezident yaratilgandan keyin yuz foto va kirish huquqlari alohida so'rovlar bilan qo'shiladi
- `USER_ADDED` event `access_logs` jadvaliga yoziladi

---

### 2.4 Rezidentni tahrirlash

**`PATCH /api/v1/residents/:id`**

**Request (faqat yuborilgan maydonlar yangilanadi):**

```json
{
  "full_name": "Abdullayev Jasur Norqulovich",
  "apartment_number": "36",
  "floor_number": 4
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Rezident ma'lumotlari yangilandi",
  "data": {
    "id": 42,
    "full_name": "Abdullayev Jasur Norqulovich",
    "phone_masked": "+998 90 *** 12 34",
    "apartment_number": "36",
    "floor_number": 4,
    "updated_at": "2026-03-17T11:30:00Z"
  }
}
```

> **Eslatma:** Telefon raqamni o'zgartirish mumkin emas bu endpointdan. Buning uchun alohida `PATCH /api/v1/residents/:id/phone` endpoint ishlatiladi (OTP tasdiqlash talab qilinadi).

---

### 2.5 Rezidentni bloklash / faollashtirish

**`PATCH /api/v1/residents/:id/status`**

**Request:**

```json
{
  "status": "blocked",
  "reason": "Ijaradan ketdi"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Rezident bloklandi",
  "data": {
    "id": 42,
    "status": "blocked",
    "updated_at": "2026-03-17T12:00:00Z"
  }
}
```

**Ruxsat etilgan `status` o'tishlari:**
- `active` → `blocked` (bloklanadi, terminaldan o'chirilmaydi — soft block)
- `active` → `archived` (arxivlash — terminaldan o'chiriladi)
- `blocked` → `active` (qayta faollash)
- `archived` → `active` (arxivdan chiqarish)

---

### 2.6 Rezidentni o'chirish

**`DELETE /api/v1/residents/:id`**

**Request:**

```json
{
  "reason": "Bino egasining talabi"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Rezident o'chirildi"
}
```

**Biznes qoidalar:**
- Soft delete: `status = 'deleted'`, ma'lumotlar saqlanadi
- Barcha terminallardan sinxron o'chiriladi (sync_queues orqali)
- `USER_DELETED` event yoziladi
- O'chirilgan rezidentni tiklash faqat `super_admin` orqali

---

### 2.7 Rezidentni ko'chirish (bir binodан boshqasiga)

**`POST /api/v1/residents/:id/transfer`**

**Request:**

```json
{
  "new_building_id": 3,
  "new_apartment_number": "12",
  "new_floor_number": 2,
  "reason": "Yangi kvartiraga ko'chdi"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Rezident ko'chirildi",
  "data": {
    "id": 42,
    "full_name": "Abdullayev Jasur",
    "old_building": {
      "id": 1,
      "name": "Chilonzor-14",
      "apartment_number": "35"
    },
    "new_building": {
      "id": 3,
      "name": "Yunusobod-8",
      "apartment_number": "12"
    },
    "transferred_at": "2026-03-17T13:00:00Z"
  }
}
```

**Biznes qoidalar:**
- Eski terminallardan o'chiriladi (sync_queues orqali)
- Yangi binoning terminallariga qo'shilmaydi — kirish huquqlari alohida beriladi
- `resident_building_history` jadvaliga `moved_out_at` yoziladi (eski)
- Yangi yozuv yaratiladi `moved_in_at` bilan
- `USER_TRANSFERRED` event yoziladi

---

### 2.8 Ko'chirish tarixi

**`GET /api/v1/residents/:id/history`**

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "history": [
      {
        "id": 1,
        "building": {
          "id": 1,
          "name": "Chilonzor-14"
        },
        "apartment_number": "35",
        "floor_number": 4,
        "moved_in_at": "2025-06-15T10:00:00Z",
        "moved_out_at": "2026-03-17T13:00:00Z",
        "reason": "Yangi kvartiraga ko'chdi",
        "created_by_name": "Karimov Sardor"
      },
      {
        "id": 2,
        "building": {
          "id": 3,
          "name": "Yunusobod-8"
        },
        "apartment_number": "12",
        "floor_number": 2,
        "moved_in_at": "2026-03-17T13:00:00Z",
        "moved_out_at": null,
        "reason": null,
        "created_by_name": "Karimov Sardor"
      }
    ]
  }
}
```

---

## 3. Yuz Foto API

### 3.1 Yuz foto yuklash

**`POST /api/v1/residents/:id/face-photos`**

**Headers:** `Content-Type: multipart/form-data`

**Request:**

```
photos[]: (file) face_front.jpg
photos[]: (file) face_angle.jpg
is_primary_index: 0
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Yuz fotolari yuklandi va shablon yaratildi",
  "data": {
    "face_templates": [
      {
        "id": 1,
        "photo_thumb_url": "https://api.bsk.uz/uploads/residents/42/face_1_thumb.webp",
        "is_primary": true,
        "quality_score": 95,
        "created_at": "2026-03-17T10:05:00Z"
      },
      {
        "id": 2,
        "photo_thumb_url": "https://api.bsk.uz/uploads/residents/42/face_2_thumb.webp",
        "is_primary": false,
        "quality_score": 88,
        "created_at": "2026-03-17T10:05:00Z"
      }
    ],
    "sync_status": "queued"
  }
}
```

**Biznes qoidalar:**
- Minimal 1 ta, maksimal 5 ta foto
- Backend yuz vectorini yaratadi (FaceID SDK orqali)
- Vector AES-256 bilan shifrlangan holda saqlanadi
- `quality_score < 60` bo'lsa — xato qaytariladi
- Foto yuklangandan keyin terminalga sinxronizatsiya navbatga qo'yiladi (`sync_queues`)
- Foto `face_templates` jadvalida, vector `template_data` (BYTEA) maydonida

---

### 3.2 Yuz fotoni o'chirish

**`DELETE /api/v1/residents/:id/face-photos/:template_id`**

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Yuz foto o'chirildi",
  "data": {
    "remaining_face_count": 1
  }
}
```

**Biznes qoidalar:**
- Kamida 1 ta yuz foto qolishi kerak (agar `remaining_face_count` 0 bo'lsa — xato)
- O'chirilganda terminaldan ham o'chiriladi (sync_queues orqali)
- Primary foto o'chirilganda — qolganlardan birinchisi primary bo'ladi

---

### 3.3 Asosiy yuz fotoini o'zgartirish

**`PATCH /api/v1/residents/:id/face-photos/:template_id/set-primary`**

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Asosiy foto o'zgartirildi"
}
```

---

## 4. Kirish Huquqlari API

### 4.1 Terminallarga kirish huquqi berish

**`POST /api/v1/residents/:id/access`**

**Request:**

```json
{
  "terminal_ids": [1, 2],
  "access_start": null,
  "access_end": null
}
```

**Vaqt cheklovi bilan:**

```json
{
  "terminal_ids": [3],
  "access_start": "2026-04-01T06:00:00Z",
  "access_end": "2026-12-31T23:59:00Z"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Kirish huquqlari yangilandi",
  "data": {
    "terminal_access": [
      {
        "terminal_id": 1,
        "terminal_name": "Terminal-1 (Asosiy kirish)",
        "is_active": true,
        "access_start": null,
        "access_end": null,
        "sync_status": "queued"
      },
      {
        "terminal_id": 2,
        "terminal_name": "Terminal-2 (Orqa kirish)",
        "is_active": true,
        "access_start": null,
        "access_end": null,
        "sync_status": "queued"
      }
    ]
  }
}
```

---

### 4.2 Kirish huquqini o'chirish

**`DELETE /api/v1/residents/:id/access/:terminal_id`**

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Kirish huquqi o'chirildi",
  "data": {
    "sync_status": "queued"
  }
}
```

---

## 5. Bulk amallar

### 5.1 Ko'p rezidentni bloklash

**`POST /api/v1/residents/bulk-block`**

**Request:**

```json
{
  "resident_ids": [42, 43, 44],
  "reason": "Ijaradan ketdilar"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "3 ta rezident bloklandi",
  "data": {
    "blocked_count": 3,
    "failed": []
  }
}
```

---

### 5.2 Ko'p rezidentni ko'chirish

**`POST /api/v1/residents/bulk-transfer`**

**Request:**

```json
{
  "resident_ids": [42, 43],
  "new_building_id": 3,
  "reason": "Bino rekonstruksiyasi"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "transferred_count": 2,
    "failed": []
  }
}
```

---

## 6. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_PHONE` | Telefon raqami formati noto'g'ri | Validatsiya |
| 400 | `INVALID_STATUS_TRANSITION` | Holat o'tishi ruxsat etilmagan | Status o'zgartirish |
| 400 | `MIN_FACE_REQUIRED` | Kamida 1 ta yuz foto kerak | Oxirgi foto o'chirishda |
| 400 | `MAX_FACE_EXCEEDED` | Maksimal foto soni oshdi (5 ta) | Foto qo'shish |
| 400 | `LOW_FACE_QUALITY` | Yuz foto sifati past (min 60) | Foto yuklash |
| 400 | `NO_FACE_DETECTED` | Fotoda yuz topilmadi | Foto yuklash |
| 400 | `TRANSFER_SAME_BUILDING` | Bir xil binoga ko'chirish | Ko'chirish |
| 404 | `RESIDENT_NOT_FOUND` | Rezident topilmadi | Noto'g'ri ID |
| 404 | `BUILDING_NOT_FOUND` | Bino topilmadi | Noto'g'ri building_id |
| 404 | `TERMINAL_NOT_FOUND` | Terminal topilmadi | Noto'g'ri terminal_id |
| 404 | `FACE_TEMPLATE_NOT_FOUND` | Yuz foto topilmadi | Noto'g'ri template_id |
| 409 | `PHONE_ALREADY_EXISTS` | Bu telefon raqam allaqachon mavjud | Yaratish/yangilash |
| 409 | `ACCESS_ALREADY_EXISTS` | Bu terminal uchun huquq allaqachon bor | Huquq berish |
| 413 | `PHOTO_TOO_LARGE` | Foto hajmi katta (max 5MB) | Yuklash |
| 415 | `INVALID_PHOTO_TYPE` | Foto formati noto'g'ri | jpg/jpeg/png/webp |

---

## 7. TypeScript interfeyslar

```typescript
// ============================================
// Resident types
// ============================================

interface ResidentListItem {
  id: number;
  full_name: string;
  phone_masked: string;
  building: {
    id: number;
    name: string;
  };
  apartment_number: string;
  floor_number: number | null;
  status: ResidentStatus;
  face_count: number;
  has_access: boolean;
  created_at: string;
}

interface FaceTemplate {
  id: number;
  photo_thumb_url: string;
  is_primary: boolean;
  quality_score: number;
  created_at: string;
}

interface TerminalAccess {
  terminal_id: number;
  terminal_name: string;
  building_name: string;
  is_active: boolean;
  access_start: string | null;
  access_end: string | null;
}

interface ResidentDetail {
  id: number;
  full_name: string;
  phone_masked: string;
  building: {
    id: number;
    name: string;
    address: string;
  };
  apartment_number: string;
  floor_number: number | null;
  status: ResidentStatus;
  face_templates: FaceTemplate[];
  terminal_access: TerminalAccess[];
  recent_access: {
    event_type: EventType;
    terminal_name: string;
    photo_thumb_url: string | null;
    created_at: string;
  }[];
  created_at: string;
  updated_at: string;
}

interface BuildingHistory {
  id: number;
  building: {
    id: number;
    name: string;
  };
  apartment_number: string;
  floor_number: number | null;
  moved_in_at: string;
  moved_out_at: string | null;
  reason: string | null;
  created_by_name: string;
}

// ============================================
// Request types
// ============================================

interface CreateResidentRequest {
  full_name: string;
  phone: string;         // "+998XXXXXXXXX"
  building_id: number;
  apartment_number: string;
  floor_number?: number;
}

interface UpdateResidentRequest {
  full_name?: string;
  apartment_number?: string;
  floor_number?: number;
}

interface UpdateResidentStatusRequest {
  status: "active" | "blocked" | "archived";
  reason?: string;
}

interface TransferResidentRequest {
  new_building_id: number;
  new_apartment_number: string;
  new_floor_number?: number;
  reason?: string;
}

interface UpdateAccessRequest {
  terminal_ids: number[];
  access_start?: string | null;
  access_end?: string | null;
}

interface BulkBlockRequest {
  resident_ids: number[];
  reason?: string;
}

interface BulkTransferRequest {
  resident_ids: number[];
  new_building_id: number;
  reason?: string;
}

// ============================================
// Response types
// ============================================

interface UploadFaceResponse {
  face_templates: FaceTemplate[];
  sync_status: "queued" | "processing" | "completed";
}

interface BulkActionResult {
  success_count: number;
  failed: {
    resident_id: number;
    error: string;
  }[];
}
```

---

## 8. Frontend uchun eslatmalar

1. **Rezident qo'shish — 4 qadam (stepper):**
   - 1-qadam: Shaxsiy ma'lumotlar (ism, telefon, xonadon)
   - 2-qadam: Yuz foto yuklash (kamida 2 ta, kamera yoki fayl)
   - 3-qadam: Kirish huquqlarini belgilash (terminal tanlash, vaqt oralig'i)
   - 4-qadam: Tasdiqlash (preview + yaratish)

2. **Yuz foto sifati:** Backend qaytargan `quality_score` ni progress bar bilan ko'rsatish. 60 dan past → qayta yuklash talab qilinadi.

3. **Telefon qidiruv:** Search inputda telefon raqami kiritilganda, backend `phone_hash` bo'yicha qidiradi. Frontend to'liq raqam yuboradi, backend hash qilib solishtiradi.

4. **Bulk select:** Jadvalda checkbox bilan tanlash. Tanlanganda "X ta tanlandi | Ko'chirish | Bloklash | Bekor qilish" paneli paydo bo'ladi.

5. **Sinxronizatsiya holati:** Rezident kartasida `sync_status` badge ko'rsatish (queued/processing/completed). WebSocket yoki polling bilan yangilash.

6. **Foto ko'rish:** Thumbnail kichik, click → modal da katta foto. Admin foto ni yuklab olishi mumkin emas (watermark yoki kirish hisobi).
