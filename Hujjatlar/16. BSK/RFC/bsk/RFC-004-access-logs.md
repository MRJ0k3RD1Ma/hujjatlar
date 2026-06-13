# RFC-004: Kirish Loglari — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 004 |
| **Modul** | Kirish Loglari (Access Logs) |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

---

## 1. Umumiy ko'rinish

Bu RFC BSK FaceID tizimidagi barcha kirish hodisalari (access events) loglarini ko'rish, filtrlash, eksport qilish va maxsus huquqli foydalanuvchilar (prokuratura, IIV) tomonidan ko'rish uchun audit mexanizmini belgilaydi.

### 1.1 Modeldagi jadvallar

- `access_logs` — asosiy log jadvali (oy bo'yicha partitioned)
- `security_access_logs` — prokuratura/IIV kirishi audit jadvali
- `log_chains` — log zanjiri yaxlitligi (blockchain-like)

### 1.2 Foydalanuvchi rollari bo'yicha ruxsatlar

| Rol | Ko'rish | Eksport | Foto ko'rish | Audit log |
|-----|---------|---------|--------------|-----------|
| `super_admin` | Barcha binolar | Ha | Ha | Ha |
| `bsk_admin` | Barcha binolar | Ha | Ha | Ha |
| `operator` | Tayinlangan binolar | Ha | Ha | Yo'q |
| `gasn` | Tayinlangan binolar | Ha | Yo'q | Yo'q |
| `construction` | Tayinlangan binolar | Yo'q | Yo'q | Yo'q |
| `prosecutor` | Tayinlangan binolar | Ha | Ha | Har so'rov audit yoziladi |
| `iiv` | Tayinlangan binolar | Ha | Ha | Har so'rov audit yoziladi |

---

## 2. Endpointlar ro'yxati

| Method | Endpoint | Tavsif | Rol |
|--------|----------|--------|-----|
| GET | `/api/v1/access-logs` | Log ro'yxati (filter bilan) | Barcha autentifikatsiya qilinganlar |
| GET | `/api/v1/access-logs/{id}` | Bitta log batafsil | Barcha |
| GET | `/api/v1/access-logs/{id}/photo` | Log fotosini ko'rish | super_admin, bsk_admin, operator, prosecutor, iiv |
| GET | `/api/v1/access-logs/stats` | Qisqa statistika | Barcha |
| POST | `/api/v1/access-logs/export` | Excel/PDF/CSV eksport | Barcha (construction bundan mustasno) |
| GET | `/api/v1/security-logs` | Maxsus audit loglari | super_admin, bsk_admin |

---

## 3. Endpointlar batafsil

### 3.1 GET /api/v1/access-logs

Kirish loglarini filtrlash va sahifalash bilan ko'rish.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page` | number | Sahifa raqami (default: 1) |
| `per_page` | number | Elementlar soni (default: 50, max: 200) |
| `building_id` | number | Bino bo'yicha filtr |
| `terminal_id` | number | Terminal bo'yicha filtr |
| `event_type` | string | Hodisa turi (vergul bilan ko'p: `DOOR_OPEN_SUCCESS,DOOR_OPEN_DENIED`) |
| `date_from` | string | Sana boshi (ISO 8601: `2026-03-01T00:00:00Z`) |
| `date_to` | string | Sana oxiri (ISO 8601: `2026-03-17T23:59:59Z`) |
| `search` | string | Rezident qidirish (ism bo'yicha) |
| `is_success` | boolean | Muvaffaqiyatli kirish (`true`) yoki rad etilgan (`false`) |
| `confidence_min` | number | Minimal ishonch darajasi (0.0–1.0) |
| `sort` | string | Saralash: `-created_at` (default), `created_at`, `confidence_score` |

**Request:**

```http
GET /api/v1/access-logs?building_id=1&date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z&event_type=DOOR_OPEN_DENIED&page=1&per_page=50
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": 10245,
        "event_type": "DOOR_OPEN_DENIED",
        "is_success": false,
        "created_at": "2026-03-17T08:23:14Z",
        "building": {
          "id": 1,
          "name": "Navruz-1 MJK",
          "address": "Yunusobod tumani, 14-mavze"
        },
        "terminal": {
          "id": 5,
          "name": "Bosh kirish",
          "direction": "entry"
        },
        "resident": {
          "id": 142,
          "full_name": "Karimov Bobur",
          "apartment": "47",
          "photo_thumb": "/uploads/residents/142/face_1_thumb.webp"
        },
        "confidence_score": 0.61,
        "liveness_score": 0.92,
        "failure_reason": "LOW_CONFIDENCE",
        "has_photo": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total_items": 234,
      "total_pages": 5,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

> **Eslatma:** `resident` maydoni `null` bo'lishi mumkin — noma'lum shaxs urinishi. `failure_reason` faqat `is_success: false` bo'lganda keladi.

---

### 3.2 GET /api/v1/access-logs/{id}

Bitta hodisa haqida to'liq ma'lumot.

**Request:**

```http
GET /api/v1/access-logs/10245
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": 10245,
    "event_type": "DOOR_OPEN_DENIED",
    "is_success": false,
    "created_at": "2026-03-17T08:23:14Z",
    "building": {
      "id": 1,
      "name": "Navruz-1 MJK",
      "address": "Yunusobod tumani, 14-mavze",
      "soato_code": "1726182"
    },
    "terminal": {
      "id": 5,
      "name": "Bosh kirish",
      "serial_number": "BSK-TRM-2025-0042",
      "direction": "entry",
      "location_description": "1-qavat bosh eshik"
    },
    "resident": {
      "id": 142,
      "full_name": "Karimov Bobur",
      "apartment": "47",
      "floor": 8,
      "status": "active",
      "photo_thumb": "/uploads/residents/142/face_1_thumb.webp"
    },
    "confidence_score": 0.61,
    "liveness_score": 0.92,
    "failure_reason": "LOW_CONFIDENCE",
    "has_photo": true,
    "photo_url": null,
    "device_info": {
      "firmware_version": "2.1.4",
      "algorithm_version": "face-v3"
    },
    "log_hash": "sha256:a3f8c2d1e9b7...",
    "prev_hash": "sha256:f1e2d3c4b5a6..."
  }
}
```

> **Eslatma:** `photo_url` — foto ko'rish alohida endpoint orqali amalga oshiriladi. Prokuratura/IIV uchun so'rov avtomatik `security_access_logs` ga yoziladi.

---

### 3.3 GET /api/v1/access-logs/{id}/photo

Kirish hodisasi paytida olingan rasmni ko'rish (prokuratura/IIV uchun audit).

**Ruxsat:** super_admin, bsk_admin, operator, prosecutor, iiv

**Request:**

```http
GET /api/v1/access-logs/10245/photo
Authorization: Bearer <access_token>
```

**Prokuratura/IIV uchun qo'shimcha:**

```http
GET /api/v1/access-logs/10245/photo
Authorization: Bearer <access_token>
X-Request-Document: "2026-yil 17-mart sanali №12-A buyruq asosida"
```

> `X-Request-Document` sarlavhasi prosecutor va iiv rollari uchun **majburiy**. Yo'q bo'lsa 400 qaytaradi.

**Response 200:**

```json
{
  "success": true,
  "data": {
    "photo_url": "/uploads/access_logs/2026/03/10245.webp",
    "captured_at": "2026-03-17T08:23:14Z",
    "expires_at": "2026-03-17T09:23:14Z"
  }
}
```

> `photo_url` — 1 soatlik vaqtinchalik URL. Backend pre-signed URL yoki JWT-protected endpoint ishlatishi mumkin.

**Error 400 — Prokuratura/IIV uchun hujjat yo'q:**

```json
{
  "success": false,
  "error": {
    "code": "REQUEST_DOCUMENT_REQUIRED",
    "message": "Prokuratura va IIV so'rovlari uchun X-Request-Document sarlavhasi majburiy",
    "details": {}
  }
}
```

**Error 404 — Foto yo'q:**

```json
{
  "success": false,
  "error": {
    "code": "PHOTO_NOT_FOUND",
    "message": "Bu hodisa uchun foto saqlanmagan",
    "details": {}
  }
}
```

---

### 3.4 GET /api/v1/access-logs/stats

Joriy kun/hafta/oy uchun qisqa statistika. Dashboard va widget uchun.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy: muayyan bino |
| `period` | string | `today`, `week`, `month` (default: `today`) |

**Request:**

```http
GET /api/v1/access-logs/stats?building_id=1&period=today
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "period": "today",
    "period_label": "Bugun (2026-03-17)",
    "total_events": 312,
    "successful_entries": 285,
    "denied_entries": 27,
    "success_rate": 0.913,
    "by_event_type": {
      "DOOR_OPEN_SUCCESS": 285,
      "DOOR_OPEN_DENIED": 22,
      "DOOR_OPEN_MANUAL": 5,
      "LIVENESS_FAIL": 3,
      "DOOR_FORCED": 2,
      "SUSPICIOUS_ATTEMPT": 0
    },
    "hourly_trend": [
      { "hour": 0, "count": 2 },
      { "hour": 6, "count": 18 },
      { "hour": 7, "count": 45 },
      { "hour": 8, "count": 67 },
      { "hour": 9, "count": 38 }
    ],
    "terminals_stats": [
      {
        "terminal_id": 5,
        "terminal_name": "Bosh kirish",
        "total": 189,
        "success": 178,
        "denied": 11
      },
      {
        "terminal_id": 6,
        "terminal_name": "Orqa kirish",
        "total": 123,
        "success": 107,
        "denied": 16
      }
    ]
  }
}
```

---

### 3.5 POST /api/v1/access-logs/export

Filtrlangan loglarni eksport qilish (Excel, PDF, CSV).

**Ruxsat:** super_admin, bsk_admin, operator, gasn, prosecutor, iiv (construction **yo'q**)

**Request body:**

```json
{
  "format": "excel",
  "filters": {
    "building_id": 1,
    "date_from": "2026-03-01T00:00:00Z",
    "date_to": "2026-03-17T23:59:59Z",
    "event_type": ["DOOR_OPEN_SUCCESS", "DOOR_OPEN_DENIED"],
    "terminal_id": null,
    "is_success": null
  },
  "columns": [
    "id",
    "created_at",
    "building",
    "terminal",
    "resident_name",
    "event_type",
    "confidence_score",
    "failure_reason"
  ],
  "request_document": "2026-yil 17-mart sanali №12-A buyruq"
}
```

> `format`: `excel` | `pdf` | `csv`
> `request_document` — prosecutor va iiv rollari uchun **majburiy**
> `columns` — ko'rsatilmasa barcha ustunlar eksport qilinadi

**Response 200:**

```json
{
  "success": true,
  "data": {
    "export_id": "exp_2026031712345",
    "status": "processing",
    "estimated_rows": 5420,
    "download_url": null,
    "expires_at": null,
    "created_at": "2026-03-17T12:00:00Z"
  }
}
```

**Eksport tayyor bo'lgach (polling yoki WebSocket):**

```json
{
  "success": true,
  "data": {
    "export_id": "exp_2026031712345",
    "status": "ready",
    "estimated_rows": 5420,
    "actual_rows": 5389,
    "download_url": "/exports/exp_2026031712345.xlsx",
    "expires_at": "2026-03-17T13:00:00Z",
    "created_at": "2026-03-17T12:00:00Z",
    "completed_at": "2026-03-17T12:00:08Z"
  }
}
```

**GET /api/v1/access-logs/export/{export_id}** — eksport holatini tekshirish.

---

### 3.6 GET /api/v1/security-logs

Prokuratura/IIV foydalanuvchilarining audit loglari.

**Ruxsat:** super_admin, bsk_admin faqat

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page` | number | Sahifa |
| `per_page` | number | Default 50 |
| `user_id` | number | Foydalanuvchi bo'yicha filtr |
| `date_from` | string | Sana boshi |
| `date_to` | string | Sana oxiri |
| `action` | string | `view_log`, `view_photo`, `export` |

**Request:**

```http
GET /api/v1/security-logs?date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "security_logs": [
      {
        "id": 892,
        "user": {
          "id": 23,
          "full_name": "Toshmatov Saidakbar",
          "role": "prosecutor",
          "organization": "Yunusobod tuman prokuraturasi"
        },
        "action": "view_photo",
        "access_log_id": 10245,
        "request_document": "2026-yil 17-mart sanali №12-A buyruq asosida",
        "ip_address": "192.168.1.45",
        "user_agent": "Mozilla/5.0 ...",
        "created_at": "2026-03-17T10:15:22Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total_items": 47,
      "total_pages": 1,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

---

## 4. Biznes qoidalar

### 4.1 Loglash

- Har bir terminal kirish urinishi `access_logs` jadvaliga yoziladi
- Loglar o'chirilmaydi — faqat o'qish imkoni mavjud (immutable)
- Har log uchun `log_hash` (SHA-256) va `prev_hash` hisoblanadi — zanjir yaxlitligi
- `log_chains` jadvalida kunlik zanjir saqlanadi
- Fotolar 90 kun saqlanadi, keyin avtomatik o'chiriladi; biroq log yozuvi qoladi

### 4.2 Prokuratura/IIV kirishi

- Har bir ko'rish/eksport so'rovi `security_access_logs` ga yoziladi
- `request_document` maydoni majburiy — yuridik asos ko'rsatilishi shart
- Frontend bu maydon bo'sh bo'lganda so'rov yuborilishini bloklashi kerak
- Super_admin va bsk_admin bu loglarni ko'rishi mumkin

### 4.3 Eksport cheklovlari

- Bir eksportda maksimal 50,000 qator
- Eksport fayl 1 soat muddatga saqlanadi, keyin o'chiriladi
- Katta eksportlar async qayta ishlanadi (background job)
- Eksport so'rovi ham `system_audit_logs` ga yoziladi

### 4.4 Filtr cheklovlari

- `date_from` va `date_to` orasidagi farq max 90 kun
- Operator faqat o'ziga tayinlangan binolarni ko'ra oladi
- `gasn` va `construction` rollari faqat o'z binosini ko'radi

### 4.5 Event type guruhlash

**Muvaffaqiyatli:** `DOOR_OPEN_SUCCESS`, `DOOR_OPEN_MANUAL`

**Rad etilgan:** `DOOR_OPEN_DENIED`, `LIVENESS_FAIL`

**Xavfli:** `DOOR_FORCED`, `SUSPICIOUS_ATTEMPT`

**Tizim:** `DEVICE_ONLINE`, `DEVICE_OFFLINE`, `SYNC_COMPLETE`, `USER_ADDED`, `USER_DELETED`, `USER_TRANSFERRED`

---

## 5. Error kodlar

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `VALIDATION_ERROR` | Noto'g'ri filtr parametrlari |
| 400 | `DATE_RANGE_TOO_LARGE` | Sana oralig'i 90 kundan ko'p |
| 400 | `REQUEST_DOCUMENT_REQUIRED` | Prokuratura/IIV uchun hujjat yo'q |
| 400 | `EXPORT_TOO_LARGE` | Eksport 50,000 qatordan ko'p |
| 400 | `INVALID_FORMAT` | Noto'g'ri eksport formati |
| 403 | `FORBIDDEN` | Ruxsat yo'q (boshqa binoning logi) |
| 404 | `LOG_NOT_FOUND` | Log topilmadi |
| 404 | `PHOTO_NOT_FOUND` | Foto saqlanmagan yoki muddati o'tgan |
| 404 | `EXPORT_NOT_FOUND` | Eksport topilmadi |
| 410 | `EXPORT_EXPIRED` | Eksport muddati o'tgan (1 soatdan ko'p) |

---

## 6. TypeScript interfeyslari

```typescript
// ============================================
// Event Types
// ============================================

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

type FailureReason =
  | "LOW_CONFIDENCE"
  | "LIVENESS_FAILED"
  | "NOT_REGISTERED"
  | "ACCESS_REVOKED"
  | "BUILDING_MISMATCH"
  | "DEVICE_ERROR";

type ExportFormat = "excel" | "pdf" | "csv";
type ExportStatus = "processing" | "ready" | "failed";

// ============================================
// Access Log
// ============================================

interface AccessLogSummary {
  id: number;
  event_type: EventType;
  is_success: boolean;
  created_at: string; // ISO 8601 UTC
  building: {
    id: number;
    name: string;
    address: string;
  };
  terminal: {
    id: number;
    name: string;
    direction: "entry" | "exit";
  };
  resident: AccessLogResident | null;
  confidence_score: number; // 0.0 – 1.0
  liveness_score: number;
  failure_reason: FailureReason | null;
  has_photo: boolean;
}

interface AccessLogResident {
  id: number;
  full_name: string;
  apartment: string;
  photo_thumb: string;
}

interface AccessLogDetail extends AccessLogSummary {
  building: {
    id: number;
    name: string;
    address: string;
    soato_code: string;
  };
  terminal: {
    id: number;
    name: string;
    serial_number: string;
    direction: "entry" | "exit";
    location_description: string;
  };
  resident: (AccessLogResident & {
    floor: number;
    status: string;
  }) | null;
  photo_url: string | null;
  device_info: {
    firmware_version: string;
    algorithm_version: string;
  };
  log_hash: string;
  prev_hash: string;
}

// ============================================
// Stats
// ============================================

interface AccessLogStats {
  period: "today" | "week" | "month";
  period_label: string;
  total_events: number;
  successful_entries: number;
  denied_entries: number;
  success_rate: number;
  by_event_type: Record<EventType, number>;
  hourly_trend: Array<{
    hour: number;
    count: number;
  }>;
  terminals_stats: Array<{
    terminal_id: number;
    terminal_name: string;
    total: number;
    success: number;
    denied: number;
  }>;
}

// ============================================
// Export
// ============================================

interface ExportFilters {
  building_id?: number;
  date_from?: string;
  date_to?: string;
  event_type?: EventType[];
  terminal_id?: number;
  is_success?: boolean;
}

interface CreateExportRequest {
  format: ExportFormat;
  filters: ExportFilters;
  columns?: string[];
  request_document?: string; // prosecutor/iiv uchun majburiy
}

interface ExportJob {
  export_id: string;
  status: ExportStatus;
  estimated_rows: number;
  actual_rows?: number;
  download_url: string | null;
  expires_at: string | null;
  created_at: string;
  completed_at?: string;
}

// ============================================
// List Response types
// ============================================

interface AccessLogsListResponse {
  logs: AccessLogSummary[];
  pagination: Pagination;
}

// ============================================
// Security Logs (super_admin / bsk_admin)
// ============================================

interface SecurityLog {
  id: number;
  user: {
    id: number;
    full_name: string;
    role: "prosecutor" | "iiv";
    organization: string;
  };
  action: "view_log" | "view_photo" | "export";
  access_log_id: number;
  request_document: string;
  ip_address: string;
  user_agent: string;
  created_at: string;
}

// ============================================
// Query Params
// ============================================

interface AccessLogsQueryParams extends PaginationParams {
  building_id?: number;
  terminal_id?: number;
  event_type?: string; // vergul bilan: "DOOR_OPEN_SUCCESS,DOOR_OPEN_DENIED"
  date_from?: string;
  date_to?: string;
  search?: string;
  is_success?: boolean;
  confidence_min?: number;
  sort?: string;
}
```

---

## 7. Frontend eslatmalari

### 7.1 Log jadvali

- Default tartib: `created_at` bo'yicha teskari (eng yangi birinchi)
- `DOOR_FORCED` va `SUSPICIOUS_ATTEMPT` qatorlari qizil fon bilan ajralib turishi kerak
- Muvaffaqiyatli kirish — yashil, rad etilgan — qizil/sariq ikonka
- Rezident ismi kliklanishi — resident detail sahifasiga o'tadi
- Fotosi bor loglar — kamera ikonkasi bilan belgilanadi

### 7.2 Filtr panel

- Sana oralig'i: `date_from` va `date_to` (UI da `DateRangePicker`)
- Event type: multi-select dropdown
- Bino va terminal: bog'liq select (bino tanlansa terminal ro'yxati filtrlanadi)
- Filtr holati URL query params ga yozilishi kerak (sahifa yangilanganda saqlansin)

### 7.3 Foto ko'rish (Prokuratura/IIV)

- Foto so'rashdan oldin modal oyna chiqishi kerak: "Hujjat asosini kiriting"
- `request_document` maydoni `textarea` (max 500 belgi), majburiy
- Foto 1 soat muddatga ko'rsatiladi — muddati o'tsa "Foto muddati o'tdi" xabari

### 7.4 Eksport

- 5,000+ qatorli eksportlar async — "Tayyorlanmoqda..." holati ko'rsatiladi
- Tayyor bo'lganda toast xabar + "Yuklab olish" tugmasi
- Frontend eksport holatini 3 soniyada bir polling qilishi mumkin yoki WebSocket ishlatadi

### 7.5 Real-time yangilanish

- Log jadvali WebSocket orqali yangi hodisalar kelganda avtomatik yangilanadi
- Yangi xavfli hodisalar (`DOOR_FORCED`, `SUSPICIOUS_ATTEMPT`) push notification sifatida ham ko'rsatiladi
- Operator "Yangi hodisalar bor" banner ko'radi, "Yangilash" tugmasi bilan

### 7.6 Log zanjiri tekshirish

- Detail sahifada `log_hash` va `prev_hash` ko'rsatiladi (texnik foydalanuvchilar uchun)
- Admin panel log yaxlitligi hisobotini ko'rish imkoniyati (chains section)
