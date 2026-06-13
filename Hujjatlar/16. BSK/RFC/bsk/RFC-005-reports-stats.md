# RFC-005: Hisobotlar va Statistika — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 005 |
| **Modul** | Hisobotlar va Statistika |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

---

## 1. Umumiy ko'rinish

Bu RFC BSK FaceID tizimidagi statistika va hisobotlar modulini belgilaydi: dashboard ko'rsatkichlari, grafik ma'lumotlar, terminal ishlash hisobotlari, shubhali hodisalar va PDF/Excel eksport.

### 1.1 Foydalanuvchi rollari bo'yicha ruxsatlar

| Rol | Dashboard | Hisobotlar | Eksport | Barcha binolar |
|-----|-----------|-----------|---------|----------------|
| `super_admin` | Ha | Ha | Ha | Ha |
| `bsk_admin` | Ha | Ha | Ha | Ha |
| `operator` | Ha | Cheklangan | Ha | Yo'q (faqat o'z binolari) |
| `gasn` | Ha | Cheklangan | Ha | Yo'q |
| `construction` | Ha | Yo'q | Yo'q | Yo'q |
| `prosecutor` | Yo'q | Yo'q | Yo'q | Yo'q |
| `iiv` | Yo'q | Yo'q | Yo'q | Yo'q |

---

## 2. Endpointlar ro'yxati

| Method | Endpoint | Tavsif | Rol |
|--------|----------|--------|-----|
| GET | `/api/v1/stats/dashboard` | Asosiy dashboard ko'rsatkichlari | Barcha (prosecutor/iiv bundan mustasno) |
| GET | `/api/v1/stats/access-trend` | Kirish grafigi (kunlik/haftalik/oylik) | Barcha |
| GET | `/api/v1/stats/terminal-uptime` | Terminal ishlash statistikasi | super_admin, bsk_admin, operator |
| GET | `/api/v1/stats/residents-summary` | Rezidentlar statistikasi | super_admin, bsk_admin, operator |
| GET | `/api/v1/stats/suspicious-events` | Shubhali hodisalar hisoboti | super_admin, bsk_admin, operator |
| GET | `/api/v1/stats/buildings-comparison` | Binolar taqqoslash | super_admin, bsk_admin |
| POST | `/api/v1/reports/generate` | Hisobot yaratish (PDF/Excel) | super_admin, bsk_admin, operator, gasn |
| GET | `/api/v1/reports/{report_id}` | Hisobot holatini ko'rish | Barcha |

---

## 3. Endpointlar batafsil

### 3.1 GET /api/v1/stats/dashboard

Asosiy dashboard uchun yig'ilgan ko'rsatkichlar. Frontend login bo'lgandan so'ng birinchi yuklash uchun.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy: muayyan bino |
| `period` | string | `today`, `week`, `month`, `year` (default: `today`) |

**Request:**

```http
GET /api/v1/stats/dashboard?period=today
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "period": "today",
    "period_label": "2026-yil 17-mart",
    "generated_at": "2026-03-17T14:30:00Z",

    "access_summary": {
      "total_events": 1842,
      "successful": 1753,
      "denied": 89,
      "success_rate": 0.952,
      "change_vs_prev": +0.023
    },

    "residents": {
      "total_active": 4218,
      "new_today": 12,
      "blocked": 34,
      "change_vs_prev": +5
    },

    "buildings": {
      "total": 8,
      "active_terminals": 42,
      "offline_terminals": 2,
      "terminals_with_issues": 1
    },

    "alerts": [
      {
        "type": "TERMINAL_OFFLINE",
        "severity": "warning",
        "message": "Navruz-3 binosi, 'Orqa kirish' terminali 45 daqiqadan beri oflayn",
        "terminal_id": 9,
        "building_id": 3,
        "since": "2026-03-17T13:45:00Z"
      },
      {
        "type": "SUSPICIOUS_EVENTS",
        "severity": "critical",
        "message": "Bugun 5 ta majburiy ochish hodisasi qayd etildi",
        "count": 5,
        "building_id": null
      }
    ],

    "recent_events": [
      {
        "id": 10312,
        "event_type": "DOOR_FORCED",
        "building_name": "Navruz-2 MJK",
        "terminal_name": "Bosh kirish",
        "created_at": "2026-03-17T14:22:10Z"
      },
      {
        "id": 10311,
        "event_type": "DOOR_OPEN_SUCCESS",
        "building_name": "Navruz-1 MJK",
        "terminal_name": "Bosh kirish",
        "created_at": "2026-03-17T14:21:55Z"
      }
    ]
  }
}
```

---

### 3.2 GET /api/v1/stats/access-trend

Kirish hodisalari grafigi uchun ma'lumot.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy bino filtri |
| `terminal_id` | number | Ixtiyoriy terminal filtri |
| `granularity` | string | `hour`, `day`, `week`, `month` (default: `day`) |
| `date_from` | string | Boshi (ISO 8601) |
| `date_to` | string | Oxiri (ISO 8601) |
| `event_types` | string | Vergul bilan: `DOOR_OPEN_SUCCESS,DOOR_OPEN_DENIED` |

**Request:**

```http
GET /api/v1/stats/access-trend?granularity=day&date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "granularity": "day",
    "date_from": "2026-03-01T00:00:00Z",
    "date_to": "2026-03-17T23:59:59Z",
    "series": [
      {
        "event_type": "DOOR_OPEN_SUCCESS",
        "label": "Muvaffaqiyatli kirish",
        "color": "#22c55e",
        "data": [
          { "date": "2026-03-01", "count": 1245 },
          { "date": "2026-03-02", "count": 1189 },
          { "date": "2026-03-03", "count": 987 },
          { "date": "2026-03-17", "count": 1753 }
        ]
      },
      {
        "event_type": "DOOR_OPEN_DENIED",
        "label": "Rad etilgan",
        "color": "#ef4444",
        "data": [
          { "date": "2026-03-01", "count": 67 },
          { "date": "2026-03-02", "count": 54 },
          { "date": "2026-03-03", "count": 43 },
          { "date": "2026-03-17", "count": 89 }
        ]
      }
    ],
    "totals": {
      "DOOR_OPEN_SUCCESS": 19842,
      "DOOR_OPEN_DENIED": 1024
    }
  }
}
```

---

### 3.3 GET /api/v1/stats/terminal-uptime

Terminal ishlash muddati va holat statistikasi.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy bino filtri |
| `date_from` | string | Tahlil davri boshi |
| `date_to` | string | Tahlil davri oxiri |

**Request:**

```http
GET /api/v1/stats/terminal-uptime?date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "period": {
      "from": "2026-03-01T00:00:00Z",
      "to": "2026-03-17T23:59:59Z",
      "days": 17
    },
    "summary": {
      "total_terminals": 44,
      "avg_uptime_percent": 98.7,
      "terminals_with_issues": 3,
      "total_offline_minutes": 187
    },
    "terminals": [
      {
        "terminal_id": 5,
        "terminal_name": "Bosh kirish",
        "building_id": 1,
        "building_name": "Navruz-1 MJK",
        "current_status": "online",
        "uptime_percent": 99.8,
        "total_minutes": 24480,
        "offline_minutes": 49,
        "offline_count": 2,
        "last_offline_at": "2026-03-12T03:15:00Z",
        "avg_response_ms": 145,
        "total_events": 8921
      },
      {
        "terminal_id": 9,
        "terminal_name": "Orqa kirish",
        "building_id": 3,
        "building_name": "Navruz-3 MJK",
        "current_status": "offline",
        "uptime_percent": 96.2,
        "total_minutes": 24480,
        "offline_minutes": 924,
        "offline_count": 8,
        "last_offline_at": "2026-03-17T13:45:00Z",
        "avg_response_ms": 203,
        "total_events": 4512
      }
    ]
  }
}
```

---

### 3.4 GET /api/v1/stats/residents-summary

Rezidentlar holati bo'yicha statistika.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy |

**Request:**

```http
GET /api/v1/stats/residents-summary
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "total": {
      "active": 4218,
      "blocked": 34,
      "archived": 156,
      "deleted": 23
    },
    "by_building": [
      {
        "building_id": 1,
        "building_name": "Navruz-1 MJK",
        "total_apartments": 120,
        "residents_active": 342,
        "residents_blocked": 5,
        "coverage_percent": 87.5
      },
      {
        "building_id": 2,
        "building_name": "Navruz-2 MJK",
        "total_apartments": 96,
        "residents_active": 278,
        "residents_blocked": 8,
        "coverage_percent": 81.3
      }
    ],
    "registration_trend": [
      { "month": "2026-01", "new_residents": 48 },
      { "month": "2026-02", "new_residents": 63 },
      { "month": "2026-03", "new_residents": 29 }
    ],
    "face_photos": {
      "residents_with_1_photo": 3421,
      "residents_with_2_photos": 612,
      "residents_with_3_photos": 185,
      "residents_without_photo": 0
    }
  }
}
```

---

### 3.5 GET /api/v1/stats/suspicious-events

Shubhali va xavfli hodisalar hisoboti.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Ixtiyoriy |
| `date_from` | string | Tahlil davri boshi |
| `date_to` | string | Tahlil davri oxiri |

**Request:**

```http
GET /api/v1/stats/suspicious-events?date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "period": {
      "from": "2026-03-01T00:00:00Z",
      "to": "2026-03-17T23:59:59Z"
    },
    "summary": {
      "door_forced": 12,
      "suspicious_attempt": 34,
      "liveness_fail": 89,
      "total_suspicious": 135
    },
    "trend": [
      { "date": "2026-03-01", "door_forced": 0, "suspicious_attempt": 2, "liveness_fail": 5 },
      { "date": "2026-03-15", "door_forced": 3, "suspicious_attempt": 4, "liveness_fail": 8 }
    ],
    "hotspots": [
      {
        "building_id": 2,
        "building_name": "Navruz-2 MJK",
        "terminal_id": 7,
        "terminal_name": "Yer osti parkovka",
        "suspicious_count": 28,
        "risk_level": "high"
      },
      {
        "building_id": 1,
        "building_name": "Navruz-1 MJK",
        "terminal_id": 5,
        "terminal_name": "Bosh kirish",
        "suspicious_count": 7,
        "risk_level": "medium"
      }
    ],
    "recent_critical": [
      {
        "id": 10312,
        "event_type": "DOOR_FORCED",
        "building_name": "Navruz-2 MJK",
        "terminal_name": "Yer osti parkovka",
        "created_at": "2026-03-17T14:22:10Z",
        "has_photo": true
      }
    ]
  }
}
```

---

### 3.6 GET /api/v1/stats/buildings-comparison

Binolar o'rtasida taqqoslash (faqat super_admin, bsk_admin).

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `date_from` | string | Tahlil davri boshi |
| `date_to` | string | Tahlil davri oxiri |
| `metric` | string | `access_count`, `success_rate`, `suspicious_count`, `uptime` |

**Request:**

```http
GET /api/v1/stats/buildings-comparison?metric=success_rate&date_from=2026-03-01T00:00:00Z&date_to=2026-03-17T23:59:59Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "metric": "success_rate",
    "period": {
      "from": "2026-03-01T00:00:00Z",
      "to": "2026-03-17T23:59:59Z"
    },
    "buildings": [
      {
        "building_id": 1,
        "building_name": "Navruz-1 MJK",
        "value": 0.978,
        "rank": 1,
        "change_vs_prev_period": +0.005
      },
      {
        "building_id": 3,
        "building_name": "Navruz-3 MJK",
        "value": 0.921,
        "rank": 2,
        "change_vs_prev_period": -0.012
      },
      {
        "building_id": 2,
        "building_name": "Navruz-2 MJK",
        "value": 0.889,
        "rank": 3,
        "change_vs_prev_period": -0.031
      }
    ]
  }
}
```

---

### 3.7 POST /api/v1/reports/generate

To'liq hisobot yaratish (PDF yoki Excel, fon jarayonida).

**Ruxsat:** super_admin, bsk_admin, operator, gasn

**Request body:**

```json
{
  "report_type": "access_summary",
  "format": "pdf",
  "filters": {
    "building_id": 1,
    "date_from": "2026-03-01T00:00:00Z",
    "date_to": "2026-03-17T23:59:59Z"
  },
  "sections": [
    "summary",
    "access_trend",
    "terminal_uptime",
    "suspicious_events",
    "residents_summary"
  ],
  "title": "Mart 2026 — Navruz-1 MJK Hisoboti",
  "language": "uz"
}
```

> `report_type`: `access_summary` | `terminal_report` | `residents_report` | `security_audit`
> `format`: `pdf` | `excel`
> `language`: `uz` | `ru` (hisobot tili)
> `sections`: hisobotga kiritiladigan bo'limlar ro'yxati

**Response 201:**

```json
{
  "success": true,
  "data": {
    "report_id": "rpt_20260317abc123",
    "status": "processing",
    "report_type": "access_summary",
    "format": "pdf",
    "title": "Mart 2026 — Navruz-1 MJK Hisoboti",
    "download_url": null,
    "expires_at": null,
    "created_at": "2026-03-17T14:30:00Z"
  }
}
```

**Hisobot tayyor bo'lgach:**

```json
{
  "success": true,
  "data": {
    "report_id": "rpt_20260317abc123",
    "status": "ready",
    "report_type": "access_summary",
    "format": "pdf",
    "title": "Mart 2026 — Navruz-1 MJK Hisoboti",
    "file_size_kb": 842,
    "pages": 12,
    "download_url": "/reports/rpt_20260317abc123.pdf",
    "expires_at": "2026-03-18T14:30:00Z",
    "created_at": "2026-03-17T14:30:00Z",
    "completed_at": "2026-03-17T14:30:15Z"
  }
}
```

---

### 3.8 GET /api/v1/reports/{report_id}

Hisobot holatini tekshirish.

**Request:**

```http
GET /api/v1/reports/rpt_20260317abc123
Authorization: Bearer <access_token>
```

**Response:** 3.7 bilan bir xil format.

---

## 4. Biznes qoidalar

### 4.1 Cache strategiyasi

- Dashboard statistikasi **5 daqiqa** cache ga olinadi
- Trend ma'lumotlari `granularity=day` uchun **1 soat**, `hour` uchun **5 daqiqa** cache
- Operator o'z binosi uchun so'rasa cache alohida saqlanadi
- Hisobot yaratish hech qachon cache'dan foydalanmaydi — har doim yangi hisoblash

### 4.2 Ma'lumot cheklovlari

- Trend grafigi maksimal 365 kunni qamrab oladi
- Bitta grafik so'rovida maksimal 1,000 data point qaytariladi (granularity avtomatik belgilanishi mumkin)
- Hisobot yaratish uchun `date_from` va `date_to` oralig'i maksimal **90 kun**
- Hisobot fayllari **24 soat** saqlanadi, keyin o'chiriladi

### 4.3 Hisobot tarkibi

- **PDF hisobot**: BSK logotipi, tayyorlangan sana, filtrlash parametrlari, jadvallar va grafiklar, imzo maydoni
- **Excel hisobot**: Har bir bo'lim alohida varaqda (`Sheet`), formulalar bilan
- Hisobotlar `uz` yoki `ru` tilida tayyorlanishi mumkin

### 4.4 Risk darajalari

- `high`: 10+ shubhali hodisa oyda yoki terminal uptime < 95%
- `medium`: 3–9 shubhali hodisa yoki uptime 95–98%
- `low`: 0–2 shubhali hodisa va uptime > 98%

---

## 5. Error kodlar

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `VALIDATION_ERROR` | Noto'g'ri parametrlar |
| 400 | `DATE_RANGE_TOO_LARGE` | Tahlil davri 365 kundan ko'p |
| 400 | `INVALID_GRANULARITY` | Noto'g'ri granularity qiymati |
| 400 | `INVALID_REPORT_TYPE` | Noto'g'ri hisobot turi |
| 403 | `FORBIDDEN` | Ruxsat yo'q |
| 404 | `BUILDING_NOT_FOUND` | Bino topilmadi |
| 404 | `REPORT_NOT_FOUND` | Hisobot topilmadi |
| 410 | `REPORT_EXPIRED` | Hisobot muddati o'tgan |

---

## 6. TypeScript interfeyslari

```typescript
// ============================================
// Dashboard
// ============================================

type AlertSeverity = "info" | "warning" | "critical";
type AlertType =
  | "TERMINAL_OFFLINE"
  | "SUSPICIOUS_EVENTS"
  | "SYNC_FAILED"
  | "LOW_UPTIME";

interface DashboardAlert {
  type: AlertType;
  severity: AlertSeverity;
  message: string;
  terminal_id?: number;
  building_id?: number;
  count?: number;
  since?: string;
}

interface DashboardData {
  period: "today" | "week" | "month" | "year";
  period_label: string;
  generated_at: string;
  access_summary: {
    total_events: number;
    successful: number;
    denied: number;
    success_rate: number;
    change_vs_prev: number;
  };
  residents: {
    total_active: number;
    new_today: number;
    blocked: number;
    change_vs_prev: number;
  };
  buildings: {
    total: number;
    active_terminals: number;
    offline_terminals: number;
    terminals_with_issues: number;
  };
  alerts: DashboardAlert[];
  recent_events: Array<{
    id: number;
    event_type: EventType;
    building_name: string;
    terminal_name: string;
    created_at: string;
  }>;
}

// ============================================
// Trend
// ============================================

type TrendGranularity = "hour" | "day" | "week" | "month";

interface TrendSeries {
  event_type: EventType;
  label: string;
  color: string;
  data: Array<{
    date: string;
    count: number;
  }>;
}

interface AccessTrendData {
  granularity: TrendGranularity;
  date_from: string;
  date_to: string;
  series: TrendSeries[];
  totals: Partial<Record<EventType, number>>;
}

// ============================================
// Terminal Uptime
// ============================================

interface TerminalUptimeSummary {
  terminal_id: number;
  terminal_name: string;
  building_id: number;
  building_name: string;
  current_status: "online" | "offline" | "maintenance" | "error";
  uptime_percent: number;
  total_minutes: number;
  offline_minutes: number;
  offline_count: number;
  last_offline_at: string | null;
  avg_response_ms: number;
  total_events: number;
}

interface TerminalUptimeData {
  period: { from: string; to: string; days: number };
  summary: {
    total_terminals: number;
    avg_uptime_percent: number;
    terminals_with_issues: number;
    total_offline_minutes: number;
  };
  terminals: TerminalUptimeSummary[];
}

// ============================================
// Suspicious Events
// ============================================

type RiskLevel = "low" | "medium" | "high";

interface SuspiciousEventsData {
  period: { from: string; to: string };
  summary: {
    door_forced: number;
    suspicious_attempt: number;
    liveness_fail: number;
    total_suspicious: number;
  };
  trend: Array<{
    date: string;
    door_forced: number;
    suspicious_attempt: number;
    liveness_fail: number;
  }>;
  hotspots: Array<{
    building_id: number;
    building_name: string;
    terminal_id: number;
    terminal_name: string;
    suspicious_count: number;
    risk_level: RiskLevel;
  }>;
  recent_critical: Array<{
    id: number;
    event_type: EventType;
    building_name: string;
    terminal_name: string;
    created_at: string;
    has_photo: boolean;
  }>;
}

// ============================================
// Buildings Comparison
// ============================================

type ComparisonMetric =
  | "access_count"
  | "success_rate"
  | "suspicious_count"
  | "uptime";

interface BuildingsComparisonData {
  metric: ComparisonMetric;
  period: { from: string; to: string };
  buildings: Array<{
    building_id: number;
    building_name: string;
    value: number;
    rank: number;
    change_vs_prev_period: number;
  }>;
}

// ============================================
// Reports
// ============================================

type ReportType =
  | "access_summary"
  | "terminal_report"
  | "residents_report"
  | "security_audit";

type ReportFormat = "pdf" | "excel";
type ReportStatus = "processing" | "ready" | "failed";
type ReportLanguage = "uz" | "ru";

interface CreateReportRequest {
  report_type: ReportType;
  format: ReportFormat;
  filters: {
    building_id?: number;
    date_from: string;
    date_to: string;
  };
  sections?: string[];
  title?: string;
  language?: ReportLanguage;
}

interface ReportJob {
  report_id: string;
  status: ReportStatus;
  report_type: ReportType;
  format: ReportFormat;
  title: string;
  file_size_kb?: number;
  pages?: number;
  download_url: string | null;
  expires_at: string | null;
  created_at: string;
  completed_at?: string;
}

// ============================================
// Query Params
// ============================================

interface DashboardQueryParams {
  building_id?: number;
  period?: "today" | "week" | "month" | "year";
}

interface TrendQueryParams {
  building_id?: number;
  terminal_id?: number;
  granularity?: TrendGranularity;
  date_from?: string;
  date_to?: string;
  event_types?: string;
}
```

---

## 7. Frontend eslatmalari

### 7.1 Dashboard tuzilishi

```
┌─────────────────────────────────────────────────────┐
│  Bugun  |  Hafta  |  Oy  |  Yil      [Bino filtri] │
├─────────────┬──────────────┬──────────────┬─────────┤
│ 1,753       │ 89           │ 4,218        │ 42 / 44 │
│ Kirish      │ Rad etilgan  │ Rezidentlar  │Terminal │
│ ↑ 2.3%      │ ↓ 1.1%       │ +12 bugun    │ 2 oflayn│
├─────────────┴──────────────┴──────────────┴─────────┤
│  [Xavfli hodisalar alerty — qizil banner]           │
├─────────────────────────────┬───────────────────────┤
│  Kirish trendi grafigi      │  So'ngi hodisalar     │
│  (line/bar chart)           │  (real-time feed)     │
└─────────────────────────────┴───────────────────────┘
```

### 7.2 Grafik kutubxona

- **Recharts** yoki **Chart.js** ishlatilishi tavsiya etiladi
- Trend grafigi: line chart (muvaffaqiyatli — yashil, rad etilgan — qizil)
- Terminal uptime: bar chart yoki gauge
- Binolar taqqoslash: horizontal bar chart
- Grafiklar responsive bo'lishi kerak (mobile qurilmalar uchun)

### 7.3 Real-time yangilanish

- Dashboard statistikasi **30 soniyada** bir polling yoki WebSocket
- `generated_at` vaqti ko'rsatiladi: "Yangilangan: 2 daqiqa oldin"
- Ma'lumot yangilanishi paytida skeleton loader ko'rsatiladi

### 7.4 Xavfli hodisalar

- `DOOR_FORCED` va `SUSPICIOUS_ATTEMPT` hodisalari dashboardda qizil alert banner sifatida ko'rsatiladi
- Bell (qo'ng'iroq) ikonkasida badge soni ko'rsatiladi
- Operatorlarga push/browser notification yuboriladi

### 7.5 Hisobot yaratish

- Modal yoki alohida sahifa: `report_type`, `format`, `period`, `sections` tanlash
- Hisobot tayyor bo'lishi 5–30 soniya ichida bo'lishi kutiladi
- Loading holati uchun progress indicator (yoki animated shimmer)
- Tayyor bo'lganda `download_url` ga avtomatik o'tish imkoniyati

### 7.6 Ma'lumotlarni cache

- Dashboard ma'lumotlari frontend React Query yoki SWR bilan `staleTime: 5 * 60 * 1000` (5 daqiqa) cache da saqlanishi kerak
- Foydalanuvchi bino filtrini o'zgartirsa cache tozalanadi
