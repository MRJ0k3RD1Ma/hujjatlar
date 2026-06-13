# RFC-003: Binolar va Terminallar — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 003 |
| **Modul** | Binolar, terminallar, sinxronizatsiya, monitoring |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

> **Asos:** RFC-000, RFC-001.

---

## 1. Umumiy ko'rinish

Bino — ko'p qavatli turar-joy. Terminallar — binoning kirish nuqtalarida o'rnatilgan FaceID qurilmalar. Terminallar serverga MQTT yoki WebSocket orqali real-time ulanadi. Oflayn rejimda 72 soat mustaqil ishlashi mumkin, keyin sinxronizatsiya navbati orqali ma'lumotlar uzatiladi.

### 1.1 Terminal aloqa protokoli

| Kanal | Maqsad | Interval |
|-------|--------|----------|
| Heartbeat (`POST /terminals/heartbeat`) | Terminal tirik ekanini bildirish | Har 30 soniya |
| Access Event (`POST /terminals/access-event`) | Kirish voqeasini yuborish | Real-time |
| Sync Request (`POST /terminals/sync`) | Rezident ro'yxati yangilash | Soatiga 1 marta yoki o'zgarishda |

---

## 2. Binolar API

### 2.1 Binolar ro'yxati

**`GET /api/v1/buildings`**

**Headers:** `Authorization: Bearer <access_token>`

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 20 | Har sahifada |
| `search` | string | — | Nomi yoki manzili bo'yicha |
| `organization_id` | number | — | Tashkilot bo'yicha (faqat super_admin) |
| `region_id` | number | — | Viloyat/tuman bo'yicha |
| `sort` | string | `name` | `name`, `-created_at` |

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "buildings": [
      {
        "id": 1,
        "name": "Chilonzor-14",
        "address": "Toshkent sh., Chilonzor tumani, 14-mavze",
        "organization": {
          "id": 5,
          "name": "Chilonzor BSK"
        },
        "region": {
          "id": 1100,
          "name_uz": "Chilonzor tumani"
        },
        "total_floors": 9,
        "total_entrances": 4,
        "terminals_count": 4,
        "terminals_online": 3,
        "residents_count": 145,
        "coordinates": {
          "latitude": 41.2994,
          "longitude": 69.2401
        },
        "created_at": "2025-01-10T08:00:00Z"
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

---

### 2.2 Bino batafsil

**`GET /api/v1/buildings/:id`**

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Chilonzor-14",
    "address": "Toshkent sh., Chilonzor tumani, 14-mavze",
    "cadastre_code": "10:01:04:01:00014",
    "organization": {
      "id": 5,
      "name": "Chilonzor BSK",
      "type": "management_company"
    },
    "region": {
      "id": 1100,
      "name_uz": "Chilonzor tumani",
      "name_ru": "Чиланзарский район"
    },
    "total_floors": 9,
    "total_entrances": 4,
    "coordinates": {
      "latitude": 41.2994,
      "longitude": 69.2401
    },
    "terminals": [
      {
        "id": 1,
        "name": "Terminal-1",
        "entrance_number": 1,
        "status": "online",
        "last_heartbeat_at": "2026-03-17T14:31:45Z"
      },
      {
        "id": 2,
        "name": "Terminal-2",
        "entrance_number": 2,
        "status": "offline",
        "last_heartbeat_at": "2026-03-17T11:00:00Z"
      }
    ],
    "stats": {
      "residents_count": 145,
      "active_residents": 140,
      "blocked_residents": 5,
      "today_access_count": 89,
      "today_denied_count": 3
    },
    "created_at": "2025-01-10T08:00:00Z",
    "updated_at": "2026-01-15T09:00:00Z"
  }
}
```

---

### 2.3 Bino yaratish

**`POST /api/v1/buildings`** _(faqat super_admin, bsk_admin)_

**Request:**

```json
{
  "name": "Yunusobod-8",
  "address": "Toshkent sh., Yunusobod tumani, 8-uy",
  "cadastre_code": "10:05:02:03:00008",
  "organization_id": 5,
  "region_id": 1200,
  "total_floors": 12,
  "total_entrances": 3,
  "latitude": 41.3456,
  "longitude": 69.3012
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Bino qo'shildi",
  "data": {
    "id": 3,
    "name": "Yunusobod-8",
    "address": "Toshkent sh., Yunusobod tumani, 8-uy",
    "created_at": "2026-03-17T10:00:00Z"
  }
}
```

---

### 2.4 Bino tahrirlash

**`PATCH /api/v1/buildings/:id`**

**Request (partial update):**

```json
{
  "name": "Yunusobod-8 (A-blok)",
  "total_floors": 14
}
```

---

### 2.5 Bino o'chirish

**`DELETE /api/v1/buildings/:id`**

**Biznes qoidalar:**
- Rezidentlari yoki terminallari bo'lsa o'chirib bo'lmaydi
- Soft delete — `is_active: false` qilinadi

---

## 3. Terminallar API

### 3.1 Terminallar ro'yxati

**`GET /api/v1/terminals`**

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `building_id` | number | Bino bo'yicha filter |
| `status` | string | `online`, `offline`, `maintenance`, `error`, `all` |
| `page`, `per_page` | number | Pagination |

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "terminals": [
      {
        "id": 1,
        "name": "Terminal-1",
        "serial_number": "FID-2025-001",
        "building": {
          "id": 1,
          "name": "Chilonzor-14"
        },
        "entrance_number": 1,
        "status": "online",
        "ip_address": "192.168.1.101",
        "firmware_version": "v2.3.1",
        "residents_count": 145,
        "last_sync_at": "2026-03-17T14:00:00Z",
        "last_heartbeat_at": "2026-03-17T14:31:45Z",
        "uptime_percent": 99.2
      }
    ],
    "pagination": { "..." : "..." },
    "summary": {
      "total": 15,
      "online": 13,
      "offline": 1,
      "maintenance": 1,
      "error": 0
    }
  }
}
```

---

### 3.2 Terminal batafsil

**`GET /api/v1/terminals/:id`**

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Terminal-1",
    "serial_number": "FID-2025-001",
    "building": {
      "id": 1,
      "name": "Chilonzor-14",
      "address": "Chilonzor tumani, 14-mavze"
    },
    "entrance_number": 1,
    "status": "online",
    "ip_address": "192.168.1.101",
    "mac_address": "AA:BB:CC:DD:EE:01",
    "firmware_version": "v2.3.1",
    "config": {
      "sensitivity": 4,
      "liveness_detection": true,
      "volume": 3,
      "screen_brightness": 4,
      "door_open_duration": 5
    },
    "residents_count": 145,
    "server_residents_count": 147,
    "sync_diff": 2,
    "sync_status": "pending",
    "last_sync_at": "2026-03-17T14:00:00Z",
    "last_heartbeat_at": "2026-03-17T14:31:45Z",
    "stats": {
      "today_success": 89,
      "today_denied": 3,
      "today_liveness_fail": 1,
      "uptime_7d": 99.5
    },
    "created_at": "2025-01-10T08:00:00Z"
  }
}
```

---

### 3.3 Terminal yaratish

**`POST /api/v1/terminals`** _(faqat super_admin, bsk_admin)_

**Request:**

```json
{
  "building_id": 1,
  "name": "Terminal-5",
  "serial_number": "FID-2025-005",
  "entrance_number": 3,
  "ip_address": "192.168.1.105",
  "mac_address": "AA:BB:CC:DD:EE:05",
  "firmware_version": "v2.3.1"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Terminal qo'shildi",
  "data": {
    "id": 5,
    "name": "Terminal-5",
    "serial_number": "FID-2025-005",
    "api_key": "tk_live_abc123xyz789...",
    "status": "offline",
    "created_at": "2026-03-17T10:00:00Z"
  }
}
```

> **Muhim:** `api_key` faqat bir marta ko'rsatiladi. Saqlash shart!

---

### 3.4 Terminal konfiguratsiyasini yangilash

**`PATCH /api/v1/terminals/:id/config`**

**Request:**

```json
{
  "sensitivity": 5,
  "liveness_detection": true,
  "volume": 4,
  "screen_brightness": 3,
  "door_open_duration": 3
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Konfiguratsiya yangilandi. Terminal keyingi heartbeat'da qabul qiladi.",
  "data": {
    "config_updated_at": "2026-03-17T11:00:00Z",
    "sync_status": "pending"
  }
}
```

---

### 3.5 Terminal holatini o'zgartirish (Maintenance)

**`PATCH /api/v1/terminals/:id/status`**

**Request:**

```json
{
  "status": "maintenance",
  "note": "Kamera almashtirilmoqda"
}
```

---

### 3.6 Remote restart

**`POST /api/v1/terminals/:id/restart`**

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Qayta ishga tushirish buyrug'i yuborildi",
  "data": {
    "command_id": "cmd_restart_xyz",
    "status": "queued"
  }
}
```

---

### 3.7 Sinxronizatsiyani boshlash

**`POST /api/v1/terminals/:id/sync`**

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Sinxronizatsiya navbatga qo'yildi",
  "data": {
    "queued_operations": 5,
    "estimated_duration": 30
  }
}
```

---

## 4. Terminal Protokol API (Terminal qurilmadan)

Bu endpointlar terminal qurilma tomonidan chaqiriladi (`X-Terminal-Key` va `X-Terminal-Serial` header bilan).

### 4.1 Heartbeat

**`POST /api/v1/terminals/heartbeat`**

**Headers:**

```
X-Terminal-Key: tk_live_abc123xyz789...
X-Terminal-Serial: FID-2025-001
Content-Type: application/json
```

**Request:**

```json
{
  "status": "online",
  "ip_address": "192.168.1.101",
  "firmware_version": "v2.3.1",
  "residents_count": 145,
  "free_storage_mb": 4521,
  "uptime_seconds": 86400
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "server_time": "2026-03-17T14:32:00Z",
    "config_updated": false,
    "sync_required": true,
    "commands": []
  }
}
```

**Agar konfiguratsiya yangilangan bo'lsa:**

```json
{
  "success": true,
  "data": {
    "server_time": "2026-03-17T14:32:00Z",
    "config_updated": true,
    "new_config": {
      "sensitivity": 5,
      "liveness_detection": true,
      "volume": 4,
      "screen_brightness": 3,
      "door_open_duration": 3
    },
    "sync_required": false,
    "commands": [
      { "type": "restart", "command_id": "cmd_restart_xyz" }
    ]
  }
}
```

---

### 4.2 Kirish voqeasini yuborish

**`POST /api/v1/terminals/access-event`**

**Headers:** `X-Terminal-Key` + `X-Terminal-Serial`

**Request:**

```json
{
  "event_type": "DOOR_OPEN_SUCCESS",
  "terminal_local_id": "evt_12345",
  "resident_phone_hash": "a3f2c1d4e5b6...",
  "confidence_score": 98.7,
  "is_masked": false,
  "metadata": {
    "temperature": 36.6,
    "liveness_score": 99.1
  },
  "occurred_at": "2026-03-17T14:32:10Z"
}
```

**Tanilmagan shaxs uchun:**

```json
{
  "event_type": "DOOR_OPEN_DENIED",
  "terminal_local_id": "evt_12346",
  "resident_phone_hash": null,
  "confidence_score": 0,
  "is_masked": false,
  "metadata": {},
  "occurred_at": "2026-03-17T14:33:00Z"
}
```

**Foto alohida yuklanadi** (`POST /api/v1/terminals/upload-photo`):

```
Content-Type: multipart/form-data
X-Terminal-Key: ...
X-Terminal-Serial: ...

photo: (file) event_12345.jpg
event_local_id: evt_12345
```

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "log_id": 5001,
    "stored": true
  }
}
```

**Biznes qoidalar:**
- Terminal oflayn bo'lganida voqealar lokal saqlanadi
- Internet qayta kelganda `sync_queues` orqali yuboriladi
- `integrity_hash` — backend tomonida hisoblanadi va `log_chains` da saqlanadi
- `resident_phone_hash` — terminal lokal DB da sha256 hashni saqlaydi, ID emas

---

### 4.3 Sinxronizatsiya so'rovi

**`POST /api/v1/terminals/sync`**

Terminal o'zining joriy rezidentlar ro'yxatini yuborib, serverdan farqlarni oladi.

**Request:**

```json
{
  "current_version": 142,
  "resident_hashes": [
    "a3f2c1d4...",
    "b5e6f7a8...",
    "c9d0e1f2..."
  ]
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "new_version": 147,
    "to_add": [
      {
        "phone_hash": "d1e2f3a4...",
        "template_data": "BASE64_ENCODED_ENCRYPTED_VECTOR...",
        "template_hash": "abc123...",
        "access_start": null,
        "access_end": null
      }
    ],
    "to_update": [
      {
        "phone_hash": "a3f2c1d4...",
        "template_data": "BASE64_ENCODED_ENCRYPTED_VECTOR...",
        "template_hash": "def456..."
      }
    ],
    "to_remove": [
      "b5e6f7a8..."
    ]
  }
}
```

**Biznes qoidalar:**
- `template_data` — AES-256 shifrlangan yuz vector (terminal decryption key bor)
- Terminal faqat o'ziga tegishli `resident_terminal_access` yozuvlaridagi rezidentlarni oladi
- `sync_queues` da `completed` qilinadi

---

## 5. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_SERIAL` | Terminal serial raqami noto'g'ri | Heartbeat/sync |
| 400 | `BUILDING_HAS_RESIDENTS` | Binoda rezidentlar bor | O'chirish |
| 400 | `BUILDING_HAS_TERMINALS` | Binoda terminallar bor | O'chirish |
| 400 | `INVALID_STATUS_TRANSITION` | Holat o'tishi noto'g'ri | Status o'zgartirish |
| 401 | `INVALID_TERMINAL_KEY` | Terminal API key noto'g'ri | Terminal auth |
| 401 | `TERMINAL_KEY_EXPIRED` | Terminal API key muddati o'tgan | Rotatsiya |
| 404 | `BUILDING_NOT_FOUND` | Bino topilmadi | Noto'g'ri ID |
| 404 | `TERMINAL_NOT_FOUND` | Terminal topilmadi | Noto'g'ri ID |
| 409 | `SERIAL_EXISTS` | Bu serial raqam allaqachon mavjud | Yaratish |
| 409 | `IP_CONFLICT` | Bu IP manzil boshqa terminalda | Yaratish |

---

## 6. TypeScript interfeyslar

```typescript
// ============================================
// Building types
// ============================================

interface BuildingListItem {
  id: number;
  name: string;
  address: string;
  organization: {
    id: number;
    name: string;
  };
  region: {
    id: number;
    name_uz: string;
  };
  total_floors: number;
  total_entrances: number;
  terminals_count: number;
  terminals_online: number;
  residents_count: number;
  coordinates: {
    latitude: number;
    longitude: number;
  } | null;
  created_at: string;
}

interface BuildingDetail extends BuildingListItem {
  cadastre_code: string | null;
  terminals: TerminalListItem[];
  stats: {
    residents_count: number;
    active_residents: number;
    blocked_residents: number;
    today_access_count: number;
    today_denied_count: number;
  };
  updated_at: string;
}

// ============================================
// Terminal types
// ============================================

interface TerminalListItem {
  id: number;
  name: string;
  serial_number: string;
  building: {
    id: number;
    name: string;
  };
  entrance_number: number | null;
  status: TerminalStatus;
  ip_address: string | null;
  firmware_version: string | null;
  residents_count: number;
  last_sync_at: string | null;
  last_heartbeat_at: string | null;
  uptime_percent: number;
}

interface TerminalConfig {
  sensitivity: number;          // 1-5
  liveness_detection: boolean;
  volume: number;               // 1-5
  screen_brightness: number;    // 1-5
  door_open_duration: number;   // soniyalarda (1-10)
}

interface TerminalDetail {
  id: number;
  name: string;
  serial_number: string;
  building: {
    id: number;
    name: string;
    address: string;
  };
  entrance_number: number | null;
  status: TerminalStatus;
  ip_address: string | null;
  mac_address: string | null;
  firmware_version: string | null;
  config: TerminalConfig;
  residents_count: number;
  server_residents_count: number;
  sync_diff: number;
  sync_status: SyncStatus;
  last_sync_at: string | null;
  last_heartbeat_at: string | null;
  stats: {
    today_success: number;
    today_denied: number;
    today_liveness_fail: number;
    uptime_7d: number;
  };
  created_at: string;
}

// ============================================
// Request types
// ============================================

interface CreateBuildingRequest {
  name: string;
  address: string;
  cadastre_code?: string;
  organization_id: number;
  region_id: number;
  total_floors: number;
  total_entrances: number;
  latitude?: number;
  longitude?: number;
}

interface CreateTerminalRequest {
  building_id: number;
  name: string;
  serial_number: string;
  entrance_number?: number;
  ip_address?: string;
  mac_address?: string;
  firmware_version?: string;
}

interface UpdateTerminalConfigRequest {
  sensitivity?: number;
  liveness_detection?: boolean;
  volume?: number;
  screen_brightness?: number;
  door_open_duration?: number;
}

// Terminal protocol
interface HeartbeatRequest {
  status: "online" | "offline" | "error";
  ip_address: string;
  firmware_version: string;
  residents_count: number;
  free_storage_mb: number;
  uptime_seconds: number;
}

interface AccessEventRequest {
  event_type: EventType;
  terminal_local_id: string;
  resident_phone_hash: string | null;
  confidence_score: number;
  is_masked: boolean;
  metadata: Record<string, any>;
  occurred_at: string;
}

interface SyncRequest {
  current_version: number;
  resident_hashes: string[];
}

interface SyncResponseItem {
  phone_hash: string;
  template_data: string;    // Base64 encoded AES-256 encrypted vector
  template_hash: string;
  access_start: string | null;
  access_end: string | null;
}
```

---

## 7. Frontend uchun eslatmalar

1. **Terminal xaritasi (Dashboard):** Leaflet.js bilan barcha terminallarni xaritada ko'rsatish. Rang: yashil (online), qizil (offline), to'q sariq (maintenance), miltillovchi qizil (error). Cluster support (yaqin terminallarni guruhlashtirish).

2. **Real-time holat:** Terminal holati WebSocket orqali yangilanadi. `DEVICE_ONLINE` / `DEVICE_OFFLINE` eventlari kelganda UI yangilanadi.

3. **Sinxronizatsiya farq indikatori:** `sync_diff > 0` bo'lsa — sariq badge "N ta o'zgarish kutmoqda". Sync tugaganda yashilga o'tadi.

4. **Konfiguratsiya formasi:** Slider komponentlar (sensitivity, volume, brightness). Toggle (liveness_detection). Saqlanganda "Terminal keyingi heartbeat'da qabul qiladi" xabari.

5. **Remote restart:** Tasdiqlash dialog ("Terminal 30-60 soniyaga ishlamaydi"). Restart buyrug'i yuborilgandan keyin terminal `offline` holatga o'tadi, keyin `online` qaytadi.

6. **API key ko'rsatish:** Faqat yaratilganda, bir marta. Modal da katta, nusxa olish tugmasi bilan. "Saqlab qo'ying, qayta ko'rsatilmaydi" ogohlantirish.
