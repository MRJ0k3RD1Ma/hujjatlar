# ISUP Server — Texnik Topshiriq (Backend)

**Versiya:** 2.0
**Sana:** 2026-05-04
**Buyurtmachi:** Milliy Universiteti
**Asos loyiha:** `D:\desktopapp\ISUP_Service\full\`

---

## 1. Texnologiya Steki

| Komponent | Qiymat |
|---|---|
| Framework | ASP.NET 8.0 |
| Til | C# 12+ |
| Ma'lumotlar bazasi | MySQL (`MySqlConnector 2.3.7`) |
| SDK | Hikvision ISUP 5.0 (`HCISUPCMS.dll`, `HCISUPStream.dll`, `HCISUPAlarm.dll`) |
| HTTP API port | `5001` |
| Qurilma ulanish port (CMS) | `7660` (TCP) |
| FaceID hodisa port (SMS) | `8003` (TCP) |
| Auth | HTTP Basic Auth (barcha `/api/*` endpointlarda) |

---

## 2. Asosiy Arxitektura

```
FaceID Qurilma
    │ TCP 7660 (ISUP CMS — qurilma ro'yxatdan o'tishi)
    │ TCP 8003 (ISUP SMS — yuz tanish hodisalari)
    ▼
┌──────────────────────────────────────────────────┐
│              ISUP Server (ASP.NET 8.0)           │
│                                                  │
│  IsupService (background service)               │
│  ├── HikCms: qurilma ulanishi, auth, online/off  │
│  ├── HikStream: yuz tanish hodisalari (8003)     │
│  └── DbService: barcha ma'lumotlar MySQL dan     │
│                                                  │
│  REST API (port 5001)                            │
│  ├── DeviceApiController — device CRUD           │
│  ├── CameraController   — face ops, ISAPI        │
│  └── EventController    — NestJS callback [NEW]  │
│                                                  │
│  Background Workers                              │
│  ├── HeartbeatWorker   — qurilma holati → NestJS │
│  └── EventForwardWorker— tanilgan yuzlar [NEW]   │
└───────────────────┬──────────────────────────────┘
                    │ HTTP callback
                    ▼
              NestJS Backend
```

---

## 3. Mavjud Funksionallik (ISUP_Service loyihasidan)

Quyidagilar **allaqachon mavjud** va qayta ishlatiladi:

### 3.1 Qurilma ulanishi va autentifikatsiya
- **File:** `Hikvision/IsupService.cs`
- Qurilma TCP 7660 ga ulanadi → `OnRegister` callback
- `secret_key` orqali autentifikatsiya — **`DbService` orqali to'g'ridan MySQL dan olinadi**
- Online/offline holat → DB ga yoziladi (`Data/DbService.cs`)

> **O'zgarish:** `IsupState` memory cache va `DataRefreshWorker` olib tashlanadi. Barcha kalitlar va sessiyalar har safar **bazadan** o'qiladi — xotiradagi nusxa saqlanmaydi.

### 3.2 Qurilma CRUD API
- **File:** `Controllers/DeviceApiController.cs`
- `GET /api/devices`, `POST /api/devices`, `PUT /api/devices/{id}`, `DELETE /api/devices/{id}`
- Device model: `device_id`, `serial`, `mac`, `name`, `ip_address`, `firmware`, `cms_port`, `sms_port`, `secret_key`, `sdk_user_id`, `session_key`, `integrate_id`

### 3.3 Yuz rasmi yuklash va ro'yxatga olish
- **File:** `Controllers/CameraController.cs`
- `POST /api/camera/face/upload` — rasm yuklash + `faces/` papkasiga saqlash
- `POST /api/camera/face/enroll` — qurilmaga ISAPI orqali ro'yxatdan o'tkazish
- `POST /api/camera/face/remove` — qurilmadan o'chirish

### 3.4 HeartbeatWorker (qurilma holati)
- **File:** `Services/HeartbeatWorker.cs`
- Har 300 soniyada `Integration.state_endpoint` ga POST yuboradi
- Payload: `{ device_id, state, serial, mac }`

---

## 4. Qo'shiladigan / O'zgartiriladigan Funksionallik

### 4.1 `isup_token` — NestJS autentifikatsiyasi uchun

**Muammo:** Hozir faqat HTTP Basic Auth bor. NestJS so'rovlarini `isup_token` bilan autentifikatsiya qilish kerak.

**O'zgartirish — `DeviceApiController.cs`:**
- `devices` jadvaliga `isup_token VARCHAR(255)` ustuni qo'shish
- `POST /api/devices` da `isup_token` qabul qilish va saqlash
- Barcha NestJS dan keladigan so'rovlarda `X-Face-ID: {isup_token}` tekshirish:
  - `ActionFilterAttribute` yoki middleware orqali
  - Token DB dagi `devices.isup_token` bilan solishtiriladi
  - Mos kelmasa — `401 Unauthorized`

---

### 4.2 Person API — NestJS uchun yangi endpointlar

NestJS plan.md dagi interfeys bilan ishlaydi. Yangi `PersonController.cs` yaratiladi:

```csharp
// POST /api/persons
// NestJS yangi odam qo'shganda barcha online qurilmalarga yuboradi
{
  "person_id": "hemis_12345",       // HEMIS ID → employeeNoString
  "name": "Aliyev Alisher",
  "face_image_url": "http://nestjs-server/files/faces/hemis_12345.jpg"
}
// callback_url berilsa → navbatga qo'yiladi (queue_id qaytaradi)
// berilmasa → sinxron bajariladi

// DELETE /api/persons/{person_id}
// Barcha online qurilmalardan o'chiradi

// PUT /api/persons/{person_id}
// Ism yangilash

// PUT /api/persons/{person_id}/face
// Yuz rasmini yangilash
{
  "face_image_url": "http://nestjs-server/files/faces/hemis_12345_v2.jpg"
}
```

**Ichki ishlash logikasi (`PersonController.cs`):**
```
1. face_image_url dan rasmni yuklab olish (HttpClient)
2. Rasmni `faces/` ga saqlash
3. Har bir online qurilma uchun:
   - ISAPI: POST /ISAPI/ContentMgmt/faceLibrary/person
   - Body: person_id (employeeNo), ism, yuz rasmi
4. callback_url bo'lsa:
   - DB ga queue yozuv saqlash (status='queued', queue_id generatsiya)
   - Har bir qurilma bajarilgach callback_url ga yuborish
5. callback_url bo'lmasa: sinxron javob
```

---

### 4.3 Queue tizimi — async amallar uchun

`PersonQueue` jadvali (MySQL):

```sql
CREATE TABLE person_queue (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  queue_id    VARCHAR(100) UNIQUE NOT NULL,
  person_id   VARCHAR(50) NOT NULL,
  action      ENUM('add','delete','update','update_face') NOT NULL,
  status      ENUM('queued','success','error') DEFAULT 'queued',
  callback_url VARCHAR(500) NULL,
  error_msg   TEXT NULL,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME NULL
);
```

**Queue check endpoint:**
```
GET /api/queue/{queue_id}
Headers: X-Face-ID: {isup_token}
Response: { "queue_id": "...", "status": "queued|success|error", "error": null }
```

---

### 4.4 Yuz tanish hodisalarini NestJS ga yuborish [ASOSIY O'ZGARTIRISH]

**Muammo:** Hozir qurilma yuz taniganda `POST /api/camera/face/upload` ga yuboradi — lekin NestJS ga forward qilinmaydi.

**O'zgartirish — `CameraController.cs` `face/upload` endpointiga:**

```csharp
[HttpPost("face/upload")]
public async Task<IActionResult> FaceUpload(...)
{
    // 1. Rasmni saqlash (mavjud logika)
    // 2. [YANGI] Integration.state_endpoint orqali NestJS ga yuborish:
    await ForwardFaceEventToNestJs(new {
        device_id     = dto.DeviceId,
        person_id     = dto.EmployeeNo,   // HEMIS ID
        event_type    = "entry",           // yoki "exit" — door_direction dan aniqlanadi
        occurred_at   = DateTime.UtcNow,
        similarity    = dto.Similarity,
        building_id   = device.BuildingId  // devices jadvalidagi building_id
    });
}
```

**NestJS callback URL:** `Integration` modelidagi `state_endpoint` → `http://nestjs:3000/api/faceid/callback`

> **Eslatma:** `event_type` (entry/exit) — qurilmaning `door_direction` maydoni asosida aniqlanadi. `door_direction='entry'` → `'entry'`, `door_direction='exit'` → `'exit'`, `door_direction='both'` → `cardReaderNo` dan aniqlanadi.

---

### 4.5 Heartbeat → NestJS

**Mavjud:** `HeartbeatWorker` har 300s da `state_endpoint` ga qurilma holatini yuboradi.

**O'zgartirish:** Payload NestJS kutgan formatga moslanadi:
```json
{
  "device_id":    "DS-K1T671MF-001",
  "status":       "online",
  "ip_address":   "192.168.1.10",
  "last_seen":    "2026-05-04T08:32:00Z"
}
```

HeartbeatWorker intervali: 300s → **60s** (NestJS 60s da offline aniqlash uchun)

---

### 4.6 Eshik ochish API

```csharp
// POST /api/devices/{device_serial}/door/open
// Headers: X-Face-ID: {isup_token}
// Body: { "open_duration_seconds": 5 }

// ISAPI orqali qurilmaga yuboriladi:
// PUT /ISAPI/AccessControl/RemoteControl/door/0
// Body: <RemoteControlDoor><cmd>open</cmd></RemoteControlDoor>
```

---

### 4.7 Qurilma holati endpoint (NestJS polling uchun)

```csharp
// GET /api/devices/status
// Headers: X-Face-ID: {isup_token}
// Response:
[
  {
    "device_id":   "DS-K1T671MF-001",
    "serial":      "DS001234",
    "building_id": "uuid-from-our-system",
    "status":      "online",
    "last_seen":   "2026-05-04T08:32:00Z"
  }
]
```

`building_id` — `devices` jadvaliga qo'shiladigan yangi ustun, NestJS tomonidan belgilanadi.

---

## 5. Ma'lumotlar Bazasi O'zgarishlari

Mavjud `devices` jadvaliga qo'shiladigan ustunlar:

```sql
ALTER TABLE devices
  ADD COLUMN isup_token   VARCHAR(255) NULL,
  ADD COLUMN building_id  VARCHAR(36)  NULL,   -- NestJS UUID
  ADD COLUMN door_direction ENUM('entry','exit','both') NULL,
  ADD COLUMN turnstile_number SMALLINT NULL,
  ADD COLUMN location_note VARCHAR(255) NULL;
```

Yangi `person_queue` jadvali — §4.3 da ko'rsatilgan.

---

## 6. `appsettings.json` O'zgarishlari

```json
{
  "Urls": "http://0.0.0.0:5001",
  "Isup": {
    "ListenIP":       "0.0.0.0",
    "ServerAddress":  "192.168.x.x",
    "CmsPort":        7660,
    "SmsPort":        8003
  },
  "NestJs": {
    "CallbackUrl":    "http://nestjs-server:3000/api/faceid/callback",
    "HeartbeatUrl":   "http://nestjs-server:3000/api/faceid/callback"
  }
}
```

---

## 7. API Xulosa Jadvali

| Method | Endpoint | Vazifa | Holat |
|---|---|---|---|
| GET | `/api/devices` | Qurilmalar ro'yxati | Mavjud |
| POST | `/api/devices` | Qurilma qo'shish | Mavjud + `isup_token`, `building_id` qo'shiladi |
| PUT | `/api/devices/{id}` | Tahrirlash | Mavjud |
| DELETE | `/api/devices/{id}` | O'chirish | Mavjud |
| GET | `/api/devices/status` | NestJS polling uchun holat | **Yangi** |
| POST | `/api/persons` | Odam qo'shish (barcha qurilmalarga) | **Yangi** |
| DELETE | `/api/persons/{person_id}` | Odam o'chirish | **Yangi** |
| PUT | `/api/persons/{person_id}` | Ma'lumot yangilash | **Yangi** |
| PUT | `/api/persons/{person_id}/face` | Yuz rasmi yangilash | **Yangi** |
| GET | `/api/queue/{queue_id}` | Queue holati | **Yangi** |
| POST | `/api/devices/{serial}/door/open` | Eshik ochish | **Yangi** |
| POST | `/api/camera/face/upload` | Yuz tanish hodisasi | Mavjud + NestJS forward **qo'shiladi** |

---

## 8. Tekshirish

- [ ] `IsupState` memory cache yo'q — `secret_key` va `session_key` har safar MySQL dan olinadi
- [ ] `DataRefreshWorker` mavjud emas — belgilangan joyda ishga tushirilmagan
- [ ] Qurilma TCP 7660 ga ulanadi va autentifikatsiya o'tadi (DB dan `secret_key` olinib tekshiriladi)
- [ ] `POST /api/devices` da `isup_token` saqlanadi va keyingi so'rovlarda tekshiriladi
- [ ] `POST /api/persons` yuz rasmini URL dan yuklab, qurilmaga ISAPI orqali qo'shadi
- [ ] Yuz tanilganda `POST /api/camera/face/upload` → NestJS callback URL ga yuboradi
- [ ] Heartbeat 60s da NestJS ga yuboriladi
- [ ] `POST /api/devices/{serial}/door/open` qurilma eshigini ochadi
- [ ] `GET /api/queue/{queue_id}` navbat holatini qaytaradi

---

*Yaratilgan: 2026-05-04 | Versiya: 2.0*
