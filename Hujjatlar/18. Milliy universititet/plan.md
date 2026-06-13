# Plan: Davomat tizimi — Backend Texnik Topshiriq

## Context
Milliy Universiteti uchun FaceID asosidagi davomat tizimining backend qismi uchun texnik topshiriq (TZ) hujjati yaratish. Hujjat backend dasturchi uchun to'liq yo'riqnoma bo'lib xizmat qiladi.

**Amalga oshirish:** `d:\MBOS\Hujjatlar\18. Milliy universititet\backend texnik topshiriq.md` faylini yaratish.

---

# Milliy Universiteti — Davomat Tizimi
## Backend Texnik Topshiriq

**Versiya:** 2.0 (Bun + Hono + Excel Import)
**Sana:** 2026-05-13
**Buyurtmachi:** Milliy Universiteti

---

## 1. Umumiy Ma'lumot

### 1.1 Loyiha Maqsadi
FaceID qurilmalari orqali talabalar, o'qituvchilar va xodimlarning darsga/ishga qatnashishini avtomatik kuzatish tizimi. Tizim HEMIS bilan integratsiyalashadi, real vaqtda monitoring va statistikani ta'minlaydi.

### 1.2 Tizimdan Tashqari Qoladigan Narsalar
- Yuzni ro'yxatga olish (FaceID backend tomonidan bajariladi)
- HEMIS tizimiga ma'lumot yozish (faqat o'qish)
- Ommaviy kirish — faqat login/parol berilgan administratorlar foydalanadi

---

## 2. Tizim Arxitekturasi

```
┌─────────────────────────────────────────────────────────────────┐
│                  Excel Fayllar (admin yuklaydi)                 │
│   Talabalar.xlsx · O'qituvchilar.xlsx · Xodimlar.xlsx · ...     │
└───────────────────────────┬─────────────────────────────────────┘
                            │ multipart/form-data upload
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                                                                  │
│              ASOSIY BACKEND (Bun + Hono)                        │
│              Ubuntu 22.04 + Docker                              │
│              PostgreSQL + Redis                                  │
│                                                                  │
│   ┌────────────┐  ┌──────────────┐  ┌──────────────┐           │
│   │  REST API  │  │ Cron / Queue │  │ Excel Parser │           │
│   │  (Hono)    │  │ (BullMQ)     │  │ (exceljs)    │           │
│   └────────────┘  └──────────────┘  └──────────────┘           │
└──────┬─────────────────────────┬────────────────────────────────┘
       │                         │
       │ REST API                │ REST API
       │                         │
┌──────▼──────────┐    ┌─────────▼──────────────────────────────┐
│  ISUP Server    │    │   React.js Admin Panel (brauzer)        │
│  (Alohida servis│    │   Faqat login/parol berilgan adminlar  │
│  qora quti)     │    └────────────────────────────────────────┘
└──────┬──────────┘
       │ ISUP Protocol
       │
┌──────▼──────────────────────────────────────────────────────────┐
│              FaceID Qurilmalar (Binolarda)                       │
│         Qurilma 1  │  Qurilma 2  │  Qurilma 3  │ ...           │
│         └──────────┴─────────────┴─────────────┘               │
│         HTTP POST /api/faceid/callback → Hono (to'g'ridan)      │
└─────────────────────────────────────────────────────────────────┘
```

### 2.1 Servislar Taqsimoti

| Servis | Texnologiya | Vazifa |
|---|---|---|
| **Asosiy Backend** | Bun + Hono + PostgreSQL | Biznes logika, REST API, Cron |
| **ISUP Server** | Alohida servis (qora quti) | FaceID qurilmalar bilan ISUP protokol |
| **Cache** | Redis | Session, real-time data, queue |
| **Queue** | BullMQ (Redis) | Hisobot generatsiya, Excel import |
| **Excel Parser** | exceljs | Talaba/o'qituvchi/xodim ma'lumotlarini import |
| **File Storage** | Local filesystem | Rasm va hujjatlar |

### 2.2 ISUP Server Interfeysi

ISUP server Hono uchun qora quti — Hono faqat HTTP orqali gaplashadi.

**Autentifikatsiya:** har bir FaceID qurilma uchun alohida token — `X-Face-ID: {device_token}` header. Token `faceid_devices.isup_token` da saqlanadi.

**Async/Sync pattern:**
- So'rovda `callback_url` bo'lsa → ISUP server so'rovni navbatga qo'yadi, darhol `queue_id` qaytaradi. Bajarib bo'lgach `callback_url` ga natija yuboradi.
- `callback_url` bo'lmasa → sinxron, to'liq bajarib response qaytaradi.

---

**A) Hono → ISUP Server (odam boshqaruvi — 4 ta amal + eshik ochish):**

```
# 1. Odam qo'shish
POST http://isup-server:8080/api/persons
Headers: X-Face-ID: {device_token}
Body: {
  "person_id": "hemis_12345",
  "name": "Aliyev Alisher",
  "face_image_url": "http://nestjs-server/files/faces/hemis_12345.jpg",
  "callback_url": "http://nestjs-server/api/isup/callback"
}
# Async response:
→ 202 Accepted: { "queue_id": "q-uuid", "status": "queued" }
# Bajarilgach callback_url ga:
→ POST { "queue_id": "q-uuid", "person_id": "hemis_12345",
          "status": "success" | "error", "error": "..." }

# 2. Odam o'chirish
DELETE http://isup-server:8080/api/persons/{person_id}
Headers: X-Face-ID: {device_token}
Body: { "callback_url": "http://nestjs-server/api/isup/callback" }
# Async response: 202 + queue_id

# 3. Odam ma'lumotini yangilash
PUT http://isup-server:8080/api/persons/{person_id}
Headers: X-Face-ID: {device_token}
Body: { "name": "Aliyev Alisher Normatovich",
        "callback_url": "http://nestjs-server/api/isup/callback" }

# 4. Yuz rasmini yangilash
PUT http://isup-server:8080/api/persons/{person_id}/face
Headers: X-Face-ID: {device_token}
Body: { "face_image_url": "http://nestjs-server/files/faces/hemis_12345_v2.jpg",
        "callback_url": "http://nestjs-server/api/isup/callback" }

# 5. Eshikni bir martalik ochish (qoravul tomonidan)
POST http://isup-server:8080/api/devices/{device_serial}/door/open
Headers: X-Face-ID: {device_token}
Body: { "open_duration_seconds": 5 }
# Sinxron response:
→ 200 OK: { "success": true }
→ 200 OK: { "success": false, "error": "Device offline" }

# 6. Qurilma ro'yxatga qo'shish (Hono da yangi device yaratilganda)
POST http://isup-server:8080/api/devices
Headers: X-Face-ID: {isup_token}
Body: {
  "device_id":   "DS-K1T671MF-001",
  "serial":      "DS001234",
  "mac":         "AA:BB:CC:DD:EE:FF",
  "name":        "Kirish-1",
  "ip_address":  "192.168.1.10",
  "firmware":    "V1.3.4",
  "cms_port":    7660,
  "sms_port":    8003,
  "secret_key":  "abc123",
  "isup_token":  "Hono tomonidan generatsiya qilingan token"
}
# ISUP server:
#   1. Barcha ma'lumotlarni o'z bazasiga yozadi
#   2. Aynan shu qurilmaga ulanishga ruxsat beradi
#
# Sinxron response:
→ 200 OK: { "success": true, "integrate_id": 42 }
# Hono integrate_id ni faceid_devices.integrate_id ga yozadi

# 7. Qurilmani o'chirish (Hono da device o'chirilganda)
DELETE http://isup-server:8080/api/devices/{device_serial}
Headers: X-Face-ID: {isup_token}
→ 200 OK: { "success": true }
```

> **Eslatma:** `face_image_url` — Hono serverning o'zida saqlangan rasmga URL (local filesystem, HTTP orqali ochiq).

---

**B) FaceID Qurilma → Hono (to'g'ridan HTTP callback):**

FaceID qurilmalar hodisalarni to'g'ridan to'g'ri Hono serveriga HTTP POST yuboradi.
Hono da `POST /api/faceid/callback` endpoint bu xabarlarni qabul qiladi.

**Callback xabar formati (`FaceIDCallbackDto`):**

```typescript
enum FaceIDEventType {
  HEART_BEAT = 'heartBeat',
  ACCESS_CONTROLLER_EVENT = 'AccessControllerEvent'
}

enum FaceIDSubEventType {
  FACE_RECOGNIZED   = 75,   // Yuz tanildi
  FACE_UNRECOGNIZED = 104,  // Yuz tanilmadi
  UNKNOWN           = 21,
  UNKNOWN1          = 22
}

class FaceIDCallbackDto {
  ipAddress: string        // Qurilma IP manzili
  portNo: number
  protocol: 'HTTP'
  macAddress: string
  channelID: number
  dateTime: string         // Hodisa vaqti (UTC+5, ISO 8601)
  activePostCount: number
  eventType: FaceIDEventType
  eventState: 'active'
  eventDescription: string
  deviceID?: string
  shortSerialNumber?: string   // Qurilma seriya raqami → faceid_devices.external_id
  AccessControllerEvent?: {
    deviceName: string
    majorEventType: number
    subEventType: FaceIDSubEventType
    name?: string            // Foydalanuvchi ismi (qurilmada saqlangan)
    doorNo?: number          // Eshik raqami
    cardReaderNo?: number    // Считыватель raqami (1=kirish, 2=chiqish, odatda)
    employeeNoString?: string  // Foydalanuvchi ID → users.hemis_id
    serialNo: number
    userType?: 'normal'
    currentVerifyMode?: string
    mask?: string            // 'no' | 'yes'
    picturesNumber?: number
    purePwdVerifyEnable: boolean
    FaceRect?: { height: number; width: number; x: number; y: number }
  }
}
```

**Hono `POST /api/faceid/callback` ishlov logikasi:**

```
1. eventType = 'heartBeat':
   → shortSerialNumber orqali faceid_devices ni topish
   → status = 'online', last_ping_at = now() yangilash

2. eventType = 'AccessControllerEvent':
   a. subEventType = 75 (FACE_RECOGNIZED):
      → shortSerialNumber → faceid_devices → building_id olish
      → employeeNoString → users.hemis_id → user_id olish
      → door_direction + cardReaderNo → event_type ('entry'|'exit') aniqlash:
           door_direction='entry'  → 'entry'
           door_direction='exit'   → 'exit'
           door_direction='both'   → cardReaderNo=1 → 'entry', cardReaderNo=2 → 'exit'
      → attendance_logs ga yozish
   
   b. subEventType = 104 (FACE_UNRECOGNIZED):
      → Noma'lum yuz hodisasi — audit log ga yozish (xavfsizlik uchun)
```

**Qurilma offline aniqlash:**
Qurilmadan 60 soniya ichida `heartBeat` kelmasa → `status = 'offline'` (Hono cron, har daqiqada tekshiradi)

---

**C) ISUP Server → Hono (callback endpoint):**

`callback_url` qo'yilgan barcha so'rovlarda ISUP server darhol `queue_id` qaytaradi (202):
```
→ 202 Accepted: { "queue_id": "q-uuid", "status": "queued" }
```

Amal bajarilgach ISUP server `callback_url` ga natijani yuboradi:
```
POST /api/isup/callback
Body: {
  "queue_id": "q-uuid",
  "person_id": "hemis_12345",
  "action": "add" | "delete" | "update" | "update_face",
  "status": "success" | "error",
  "error": "Device timeout" | null
}
```

Hono bu endpointda:
1. `queue_id` orqali `isup_queue` yozuvini topadi
2. `isup_queue.status` ni `success` yoki `error` qilib yangilaydi

**Natijani tekshirish (callback kelmagan yoki xato bo'lgan holatda):**

Hono ISUP serverga `queue_id` orqali so'rov yuborib holatni tekshiradi:
```
GET http://isup-server:8080/api/queue/{queue_id}
Headers: X-Face-ID: {device_token}
Response: {
  "queue_id": "q-uuid",
  "status": "queued" | "success" | "error",
  "error": "..." | null
}
```

Bu tekshiruv ikki yo'l bilan ishga tushadi:
- **Cron job** — har kuni kechqurun (22:00) `isup_queue` da `status='queued'` yoki `status='error'` bo'lgan yozuvlar uchun avtomatik tekshiruv
- **Qo'lda** — admin paneldagi "Sync" tugmasi bosilganda tegishli foydalanuvchi yozuvlari uchun tekshiruv

---

## 3. Texnologiyalar

| Komponent | Texnologiya | Versiya |
|---|---|---|
| Runtime | **Bun** | 1.1+ |
| Framework | **Hono** | 4.x |
| Til | TypeScript | 5.x |
| ORM | Drizzle ORM | 0.30+ |
| Ma'lumotlar bazasi | PostgreSQL | 16 |
| Cache / Queue | Redis | 7 |
| Queue manager | BullMQ | 5.x |
| Real-time | HTTP Polling (frontend) | — |
| Auth | `hono/jwt` middleware | — |
| File storage | Local filesystem | — |
| Validatsiya | Zod + `@hono/zod-validator` | — |
| Excel parser | exceljs | 4.x |
| API hujjat | `@hono/swagger-ui` + Zod OpenAPI | — |
| Test | `bun test` (built-in) | — |
| Konteyner | Docker + docker-compose | — |

---

## 4. Ma'lumotlar Bazasi Modellari

### 4.1 `users` (umumiy jadval — student/teacher/employee)

> Barcha foydalanuvchilar uchun bitta umumiy jadval. `user_type` orqali farqlanadi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | Ichki identifikator |
| `hemis_id` | VARCHAR(50) UNIQUE | HEMIS tizimidagi ID |
| `user_type` | ENUM('student','teacher','employee') | Tur |
| `full_name` | VARCHAR(255) | F.I.SH |
| `phone` | VARCHAR(20) | Telefon |
| `email` | VARCHAR(255) | Email |
| `department_id` | UUID FK | Bo'lim/Fakultet |
| `group_id` | UUID FK NULL | Guruh (faqat talabalar uchun) |
| `position` | VARCHAR(100) NULL | Lavozim (xodimlar uchun) |
| `employee_subtype` | ENUM('regular','guard') NULL | Xodim turi (`guard` = qoravul, 4 kunlik 24 soatlik smena) |
| `teacher_work_type` | ENUM('class_only','fixed_hours') NULL | O'qituvchi ish turi (faqat `user_type='teacher'` uchun) |
| `status` | ENUM('active','inactive') | Holat |
| `last_imported_at` | TIMESTAMPTZ NULL | Oxirgi Excel import vaqti |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

### 4.2 `departments`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `hemis_id` | VARCHAR(50) | |
| `name` | VARCHAR(255) | Fakultet/bo'lim nomi |
| `type` | ENUM('faculty','department') | |

### 4.3 `groups`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `hemis_id` | VARCHAR(50) | |
| `name` | VARCHAR(100) | Guruh nomi |
| `course` | SMALLINT | Kurs |
| `department_id` | UUID FK | |

### 4.4 `buildings`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `name` | VARCHAR(255) | Bino nomi |
| `address` | TEXT | Manzil |
| `floor_count` | SMALLINT | Qavatlar soni |

### 4.5 `faceid_devices`

> ISUP server qurilmani ro'yxatdan o'tkazganda ma'lumotlarni Hono ga yuboradi. `isup_token` Hono tomonidan generatsiya qilinadi.

| Ustun | Tur | Default | Tavsif |
|---|---|---|---|
| `id` | UUID (PK) | — | |
| `integrate_id` | INTEGER | — | ISUP serverdagi integratsiya ID |
| `device_id` | VARCHAR(64) | — | ISUP serverdagi qurilma ID |
| `serial` | VARCHAR(255) | — | Qurilma seriya raqami (`FaceIDCallbackDto.shortSerialNumber` bilan mos) |
| `mac` | VARCHAR(255) | — | MAC manzil |
| `name` | VARCHAR(128) | — | Qurilma nomi |
| `ip_address` | VARCHAR(45) | — | IP manzil |
| `firmware` | VARCHAR(64) NULL | — | Firmware versiyasi |
| `cms_port` | SMALLINT | 7660 | ISUP CMS port |
| `sms_port` | SMALLINT | 8003 | SMS port |
| `sdk_user_id` | BIGINT NULL | — | SDK foydalanuvchi ID |
| `session_key` | VARCHAR(64) NULL | — | Joriy sessiya kaliti |
| `secret_key` | VARCHAR(64) | — | Qurilma maxfiy kaliti |
| `isup_token` | VARCHAR(255) NULL | — | Hono tomonidan generatsiya qilingan token (`X-Face-ID` header) |
| `building_id` | UUID FK NULL | — | Joylashgan bino (admin tomonidan belgilanadi) |
| `location_note` | VARCHAR(255) NULL | — | Joylashuv izohi |
| `turnstile_number` | SMALLINT NULL | — | Turniket tartib raqami |
| `door_direction` | ENUM('entry','exit','both') NULL | — | Kirish/chiqish yo'nalishi |
| `status` | ENUM('online','offline','unknown') | `unknown` | Holat |
| `last_seen` | TIMESTAMPTZ NULL | — | Oxirgi heartbeat vaqti |
| `last_sync_at` | TIMESTAMPTZ NULL | — | Oxirgi sync vaqti |

> `FaceIDCallbackDto` da kelgan `shortSerialNumber` → `faceid_devices.serial` orqali qurilma aniqlanadi.

### 4.6 `class_schedules`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `hemis_id` | VARCHAR(50) | |
| `subject_name` | VARCHAR(255) | Fan nomi |
| `teacher_id` | UUID FK | O'qituvchi |
| `group_id` | UUID FK | Guruh |
| `building_id` | UUID FK | Bino |
| `room` | VARCHAR(50) | Xona |
| `day_of_week` | SMALLINT | 1=Dushanba, 7=Yakshanba |
| `start_time` | TIME | Boshlanish vaqti |
| `end_time` | TIME | Tugash vaqti |
| `semester` | VARCHAR(20) | Semestr (2025-2, etc.) |
| `valid_from` | DATE | Jadval boshlanadi |
| `valid_until` | DATE | Jadval tugaydi |

### 4.7 `default_work_schedules`

> `fixed_hours` uchun shablon (template) jadvallar. Admin bir marta yaratadi, keyin xodimlarga biriktiradi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `name` | VARCHAR(100) | Shablon nomi (masalan: "Standart 5 kunlik") |
| `description` | TEXT NULL | Ixtiyoriy tavsif |
| `created_at` | TIMESTAMPTZ | |

### 4.8 `default_work_schedule_days`

> Shablon kunlari — har bir kun uchun ish vaqti.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `default_schedule_id` | UUID FK → default_work_schedules | |
| `day_of_week` | SMALLINT | 1=Dushanba, 7=Yakshanba |
| `start_time` | TIME | Kelish vaqti |
| `end_time` | TIME | Ketish vaqti |

### 4.9 `work_schedules`

> Har bir foydalanuvchi uchun bitta yozuv. `schedule_type` qanday hisoblanishini belgilaydi.

| `schedule_type` | Kimlar uchun | Tavsif |
|---|---|---|
| `class_only` | Jadval asosida o'qituvchi | Faqat dars vaqtida binoda bo'lishi kerak |
| `fixed_hours` | Soatbay/kun davomida o'qituvchi, oddiy xodim | `work_schedule_days` ga ko'ra hisoblanadi |
| `guard_rotation` | Qoravul | 4 kunlik tsikl, 24 soatlik smena |

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `user_id` | UUID FK | |
| `schedule_type` | ENUM('class_only','fixed_hours','guard_rotation') | |
| `default_schedule_id` | UUID FK NULL → default_work_schedules | Asoslangan shablon |
| `rotation_cycle_days` | SMALLINT NULL | `guard_rotation` uchun tsikl uzunligi (4) |
| `rotation_start_date` | DATE NULL | Qoravul tsikl boshlangan sana |
| `is_24h_shift` | BOOLEAN | 24 soatlik navbat (`guard_rotation`) |
| `day_boundary_hour` | SMALLINT | Smena kun chegarasi, default: 4 (soat 04:00) |

### 4.10 `work_schedule_days`

> Foydalanuvchi uchun yakuniy ish vaqtlari — shablondan ko'chiriladi va kerak bo'lsa sozlanadi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `work_schedule_id` | UUID FK → work_schedules | |
| `day_of_week` | SMALLINT | 1=Dushanba, 7=Yakshanba |
| `start_time` | TIME | Kelish vaqti |
| `end_time` | TIME | Ketish vaqti |

**Qo'llash oqimi:**

```
1. Admin "Standart 5 kunlik" shablon yaratadi (default_work_schedules)
2. Har kun uchun soat belgilaydi (default_work_schedule_days)
3. Xodimga fixed_hours biriktirish:
   → work_schedules yozuvi yaratiladi (default_schedule_id = shablon ID)
   → default_work_schedule_days dan nusxa olinadi → work_schedule_days ga yoziladi
4. Kerak bo'lsa xodim uchun alohida kun sozlanadi (work_schedule_days tahrirlash)
```

`work_schedule_days` yozuvi yo'q kun — dam olish kuni hisoblanadi.

### 4.11 `attendance_logs` (xom hodisalar)

> **Partitioning:** `PARTITION BY RANGE (occurred_at)` — oylik bo'linma. `pg_partman` extension avtomatik yaratadi. 3 oydan eski partitionlar server lokal fayliga `.parquet` sifatida arxivlanadi va bazadan o'chiriladi (har oyning 1-sanasida cron).

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `user_id` | UUID FK | |
| `device_id` | UUID FK NULL | Qo'lda kiritilganda NULL |
| `building_id` | UUID FK | |
| `event_type` | ENUM('entry','exit') | |
| `occurred_at` | TIMESTAMPTZ | Hodisa vaqti (partition key) |
| `confidence` | DECIMAL(4,3) NULL | Yuz tanish ishonchliligi (qo'lda kiritilganda NULL) |
| `is_manual` | BOOLEAN | Qo'lda kiritilganmi |
| `manual_entry_id` | UUID FK NULL → manual_attendance_entries | `is_manual=true` bo'lganda bog'lanadi |
| `image_snapshot` | VARCHAR(500) NULL | Qurilmadan kelgan yuz surati fayl yo'li (30 kundan keyin NULL qilinadi) |
| `event_raw` | JSONB NULL | FaceID qurilmadan kelgan xom `FaceIDCallbackDto` |

### 4.12 `attendance_records` (kunlik xulosa)

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `user_id` | UUID FK | |
| `date` | DATE | Kun |
| `first_entry_at` | TIMESTAMPTZ NULL | Birinchi kirish vaqti |
| `first_entry_log_id` | UUID FK NULL → attendance_logs | Kirish vaqti aniqlangan event |
| `last_exit_at` | TIMESTAMPTZ NULL | Oxirgi chiqish vaqti |
| `last_exit_log_id` | UUID FK NULL → attendance_logs | Chiqish vaqti aniqlangan event |
| `expected_start` | TIME NULL | Rejadagi kelish vaqti |
| `expected_end` | TIME NULL | Rejadagi ketish vaqti |
| `total_minutes` | INTEGER | Ishlagan daqiqalar |
| `late_minutes` | INTEGER | Kechikish daqiqalari |
| `early_exit_minutes` | INTEGER | Erta ketish daqiqalari |
| `status` | ENUM('present','late','early_exit','absent','holiday','excused') | |
| `is_holiday` | BOOLEAN | Bayram kuni |

### 4.10 `manual_attendance_entries`

> Bir qo'lda kiritish seansi — kirish va chiqish vaqti, izoh, fayl. Har bir seans 2 ta `attendance_logs` yozuvini (`entry` + `exit`) yaratadi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `user_id` | UUID FK | |
| `date` | DATE | |
| `entry_time` | TIME | Kirish vaqti |
| `exit_time` | TIME NULL | Chiqish vaqti (ixtiyoriy) |
| `notes` | TEXT | Izoh (majburiy) |
| `attachment_path` | VARCHAR(500) NULL | Fayl yo'li (server lokal) — ixtiyoriy |
| `created_by` | UUID FK | Admin ID |
| `created_at` | TIMESTAMPTZ | |

### 4.12 `holidays`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `name` | VARCHAR(255) | Bayram nomi |
| `start_date` | DATE | Boshlanish sanasi |
| `end_date` | DATE | Tugash sanasi (`start_date` ga teng bo'lsa — 1 kun) |

### 4.13 `admin_users`

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `username` | VARCHAR(100) UNIQUE | |
| `password_hash` | VARCHAR(255) | bcrypt |
| `full_name` | VARCHAR(255) | |
| `email` | VARCHAR(255) UNIQUE | |
| `role` | ENUM('super_admin','hr_manager','operator','security') | |
| `is_active` | BOOLEAN | |
| `last_login_at` | TIMESTAMP | |

### 4.14 `isup_queue`

> ISUP serverga yuborilgan async so'rovlarni kuzatish — callback kelguncha holat saqlanadi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `queue_id` | VARCHAR(100) UNIQUE | ISUP server qaytargan navbat ID |
| `device_id` | UUID FK → faceid_devices | |
| `person_id` | VARCHAR(50) | HEMIS ID |
| `action` | ENUM('add','delete','update','update_face') | |
| `status` | ENUM('queued','success','error') | |
| `retry_count` | SMALLINT | Default: 0, max: 3 |
| `error_message` | TEXT NULL | |
| `created_at` | TIMESTAMPTZ | |
| `resolved_at` | TIMESTAMPTZ NULL | |

### 4.15 `audit_logs`

> Kim qaysi profilni ko'rgani, eksport qilgani — O'zbekiston shaxsiy ma'lumotlar qonuni talabi.

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `admin_user_id` | UUID FK | |
| `action` | VARCHAR(50) | `view_profile`, `export_report`, `delete_user`, `door_open` |
| `target_type` | VARCHAR(20) | `student`, `teacher`, `employee` |
| `target_id` | UUID NULL | |
| `ip_address` | VARCHAR(45) | |
| `created_at` | TIMESTAMP | |

---

## 5. Excel Import (HEMIS ma'lumotlari)

> **Yondashuv:** HEMIS API bilan to'g'ridan integratsiya qilinmaydi. Admin HEMIS dan eksport qilingan Excel fayllarni qo'lda yuklaydi.

### 5.1 Import qilinadigan ma'lumotlar

| Ma'lumot | Excel fayl shabloni | Endpoint |
|---|---|---|
| Talabalar | `students.xlsx` | `POST /api/import/students` |
| O'qituvchilar | `teachers.xlsx` | `POST /api/import/teachers` |
| Xodimlar | `employees.xlsx` | `POST /api/import/employees` |
| Guruhlar | `groups.xlsx` | `POST /api/import/groups` |
| Fakultetlar/Bo'limlar | `departments.xlsx` | `POST /api/import/departments` |
| Dars jadvali | `schedules.xlsx` | `POST /api/import/schedules` |

### 5.2 Excel fayl formatlari (shablonlar)

**Talabalar (`students.xlsx`):**

| HEMIS ID | F.I.SH | Guruh | Fakultet | Telefon | Email | Status |
|---|---|---|---|---|---|---|
| 12345 | Aliyev Alisher | 3-B | Informatika | +998... | a@... | active |

**O'qituvchilar (`teachers.xlsx`):**

| HEMIS ID | F.I.SH | Kafedra | Lavozim | Ish turi | Telefon | Email |
|---|---|---|---|---|---|---|
| 67890 | Karimov Bobur | Dasturlash | Dotsent | class_only | +998... | b@... |

> `Ish turi`: `class_only` (jadval asosida) yoki `fixed_hours` (belgilangan soat)

**Xodimlar (`employees.xlsx`):**

| HEMIS ID | F.I.SH | Bo'lim | Lavozim | Xodim turi | Telefon | Email |
|---|---|---|---|---|---|---|
| 11111 | Rahimov Rustam | Texnik bo'lim | Texnik | regular | +998... | r@... |

> `Xodim turi`: `regular` (oddiy) yoki `guard` (qoravul)

**Dars jadvali (`schedules.xlsx`):**

| HEMIS ID | Fan | O'qituvchi HEMIS ID | Guruh HEMIS ID | Bino | Xona | Hafta kuni | Boshlanish | Tugash | Semestr | Boshlanish sanasi | Tugash sanasi |
|---|---|---|---|---|---|---|---|---|---|---|---|
| s001 | Algoritmlar | 67890 | g001 | 1-bino | 201 | 1 | 08:30 | 10:00 | 2025-2 | 2026-02-01 | 2026-06-30 |

### 5.3 Import Algoritmi

```
1. Excel fayl yuklanadi (multipart/form-data, max 50MB)
2. exceljs orqali parse qilinadi
3. Birinchi qator — sarlavhalar (validatsiya: kutilgan ustunlar bormi?)
4. Har qator uchun:
   a. Zod schema bilan validatsiya
   b. hemis_id orqali bazada mavjudligini tekshirish:
      - Mavjud: o'zgargan maydonlarni UPDATE
      - Yo'q: yangi yozuv INSERT
   c. last_imported_at = NOW()
5. Excel ro'yxatida YO'Q foydalanuvchilarni topish (delta):
   → users.status = 'inactive' qilish
   → Har bir aktiv faceid_devices uchun:
       DELETE http://isup-server:8080/api/persons/{hemis_id}
       Headers: X-Face-ID: {device.isup_token}
       Body: { "callback_url": "..." }
     → isup_queue ga yozuv (action='delete')
6. Import natijasi:
   { added: N, updated: M, deactivated: K, errors: [...] }
7. import_history jadvaliga log yoziladi
```

### 5.4 Import API endpointlari

```
# Excel shablonini yuklab olish (bo'sh fayl sarlavhalar bilan)
GET  /api/import/template/{type}
     ?type=students|teachers|employees|groups|departments|schedules
     Response: Excel binary (Content-Type: application/vnd.openxmlformats...)

# Excel yuklash (multipart/form-data)
POST /api/import/{type}
     ?delta_sync=true|false   (default: true — yo'q foydalanuvchilarni inactive qilish)
     Body: file=@students.xlsx
     Response (async — katta fayl bo'lsa):
       { "job_id": "uuid", "status": "queued" }
     Response (sync — kichik fayl):
       { "added": 12, "updated": 234, "deactivated": 3, "errors": [...] }

# Import jarayoni holati
GET  /api/import/jobs/{job_id}
     Response: { "status": "processing|done|error", "progress": 0.75, "result": {...} }

# Import tarixi
GET  /api/import/history?limit=50
     Response: [
       { "id": "...", "type": "students", "file_name": "...",
         "imported_by": "admin1", "result": {...}, "created_at": "..." }
     ]

# Bitta xato yozuvni yuklab olish (validatsiyadan o'tmaganlar)
GET  /api/import/jobs/{job_id}/errors.xlsx
     Response: Excel binary — xato qatorlar + xato sababi
```

### 5.5 `import_history` jadvali

| Ustun | Tur | Tavsif |
|---|---|---|
| `id` | UUID (PK) | |
| `type` | ENUM('students','teachers','employees','groups','departments','schedules') | |
| `file_name` | VARCHAR(255) | Asl fayl nomi |
| `file_path` | VARCHAR(500) | Saqlangan fayl yo'li (`/app/uploads/imports/`) |
| `imported_by` | UUID FK → admin_users | Kim yukladi |
| `total_rows` | INTEGER | Jami qatorlar |
| `added_count` | INTEGER | Yangi qo'shilganlar |
| `updated_count` | INTEGER | Yangilanganlar |
| `deactivated_count` | INTEGER | Inactive qilinganlar |
| `error_count` | INTEGER | Xato qatorlar |
| `errors_json` | JSONB | Xato qatorlar tafsiloti |
| `status` | ENUM('processing','done','error') | |
| `created_at` | TIMESTAMPTZ | |
| `completed_at` | TIMESTAMPTZ NULL | |

### 5.6 Validatsiya qoidalari

- **HEMIS ID** — bo'sh bo'lmasligi shart, unique
- **F.I.SH** — kamida 2 ta so'z, min 4 belgi
- **Telefon** — `+998` bilan boshlanishi (ixtiyoriy)
- **Email** — RFC format (ixtiyoriy)
- **Status** — `active` yoki `inactive` (default: `active`)
- **Foreign keys** — `Guruh HEMIS ID` bazada bo'lishi shart (yo'q bo'lsa xato)
- **Sana** — `YYYY-MM-DD` format
- **Vaqt** — `HH:MM` format

Xato bo'lgan qatorlar import qilinmaydi, lekin boshqa qatorlar ishlanadi. Xato hisoboti `errors.xlsx` orqali yuklab olinadi.

---

## 6. API Endpointlar

### 6.1 Autentifikatsiya

```
POST   /api/auth/login            — Kirish (username + password)
POST   /api/auth/refresh          — Token yangilash
POST   /api/auth/logout           — Chiqish
GET    /api/auth/me               — Joriy admin ma'lumotlari
```

### 6.2 Dashboard

```
GET    /api/dashboard/summary     — Bugungi statistika widgetlari
GET    /api/dashboard/charts      — Grafiklar uchun ma'lumot
GET    /api/dashboard/live        — Hozir binolarda nechi kishi
```

### 6.3 Talabalar

```
GET    /api/students              — Ro'yxat (pagination, search, filter)
GET    /api/students/:id          — Batafsil
GET    /api/students/:id/profile  — Profil + statistika
GET    /api/students/:id/attendance  — Davomat tarixi (filter: building, period)
GET    /api/students/:id/tabel    — Oy bo'yicha jadval (tabel)
```

### 6.4 O'qituvchilar

```
GET    /api/teachers              — Ro'yxat
GET    /api/teachers/:id
GET    /api/teachers/:id/profile
GET    /api/teachers/:id/attendance
GET    /api/teachers/:id/schedule — Dars jadvali
GET    /api/teachers/:id/tabel
```

### 6.5 Xodimlar

```
GET    /api/employees             — Ro'yxat
GET    /api/employees/:id
GET    /api/employees/:id/profile
GET    /api/employees/:id/attendance
GET    /api/employees/:id/schedule
GET    /api/employees/:id/tabel
PUT    /api/employees/:id/schedule — Ish grafigini tahrirlash (Admin)
PUT    /api/guards/:id/rotation   — Qoravul tsikl sozlash (Admin)
```

### 6.6 Davomat

```
GET    /api/attendance            — Davomat jadvali (filter: date, role, building, user)
GET    /api/attendance/logs       — Xom kirish/chiqish hodisalari
POST   /api/attendance/manual     — Qo'lda davomat qo'shish
PUT    /api/attendance/manual/:id — Tahrirlash
DELETE /api/attendance/manual/:id — O'chirish
```

**`POST /api/attendance/manual` request body:**
```json
{
  "userId": "uuid",
  "date": "2026-05-04",
  "entryTime": "08:45",
  "exitTime": "17:30",
  "notes": "Tashqi tadbir",
  "attachmentUrl": "https://..."
}
```

### 6.7 Dars Jadvali

```
GET    /api/schedules             — Barcha jadval (filter: teacher, group, building)
GET    /api/schedules/week        — Haftalik view (?date=2026-05-04)
GET    /api/schedules/teacher/:id — Bitta o'qituvchi jadvali
GET    /api/schedules/group/:id   — Bitta guruh jadvali
```

### 6.8 Binolar

```
GET    /api/buildings             — Ro'yxat
GET    /api/buildings/:id
POST   /api/buildings             — Yaratish (Admin)
PUT    /api/buildings/:id         — Tahrirlash (Admin)
DELETE /api/buildings/:id         — O'chirish (Admin)
GET    /api/buildings/:id/occupancy — Hozirgi odamlar soni
```

### 6.9 FaceID Qurilmalar

```
GET    /api/devices               — Ro'yxat (status, turnstile_number, door_direction bilan)
GET    /api/devices/:id
POST   /api/devices               — Ro'yxatga qo'shish (Admin) → ISUP serverga §2.2 #6 yuboradi
PUT    /api/devices/:id           — Tahrirlash (Admin)
DELETE /api/devices/:id           — O'chirish (Admin) → ISUP serverga §2.2 #7 yuboradi
GET    /api/devices/:id/status    — Holat va oxirgi ping
POST   /api/devices/:id/sync      — Qo'lda sync boshlash
POST   /api/devices/:id/door/open — Eshikni bir martalik ochish (Security/Admin)
```

**`POST /api/devices/:id/door/open` request body:**
```json
{ "open_duration_seconds": 5 }
```
Response:
```json
{ "success": true }
{ "success": false, "error": "Device offline" }
```

Hono bu endpointda:
1. `faceid_devices.isup_token` orqali tokenni oladi
2. ISUP serverga `POST .../door/open` yuboradi (sinxron)
3. Natijani `audit_logs` ga yozadi (`action: "door_open"`, kim, qaysi qurilma, qachon)

### 6.10 Bayram Kunlari

```
GET    /api/holidays              — Ro'yxat (?year=2026)
POST   /api/holidays              — Qo'shish (Admin)
PUT    /api/holidays/:id          — Tahrirlash
DELETE /api/holidays/:id          — O'chirish
GET    /api/holidays/check/:date  — Bu sana bayram periodiga kiradimi?
```

### 6.11 Hisobotlar

```
GET    /api/reports/attendance    — Davomat hisoboti
GET    /api/reports/delays        — Kechikishlar hisoboti
GET    /api/reports/hours         — Ishlangan soatlar hisoboti
GET    /api/reports/building-entries — Bino bo'yicha kirishlar

POST   /api/reports/export        — Export (Excel/PDF) — async (queue)
GET    /api/reports/export/:jobId — Export holati va yuklab olish
```

**Hisobot filter parametrlari:**
```
?startDate=2026-05-01
&endDate=2026-05-31
&userType=student|teacher|employee
&buildingId=uuid
&userId=uuid (ixtiyoriy, bitta foydalanuvchi uchun)
&format=json|excel|pdf
```

### 6.12 Global Qidiruv

```
GET    /api/search?q=Aliyev&limit=20  — Foydalanuvchilarni F.I.SH bo'yicha qidirish
```

### 6.13 FaceID Callback va Qurilma Holati

```
# FaceID qurilmalardan to'g'ridan keladigan hodisalar:
POST   /api/faceid/callback    — Heartbeat + kirish/chiqish hodisalari (FaceIDCallbackDto)

# Qurilma offline tekshiruvi (Hono Cron, har 1 daqiqada):
→ last_ping_at > 60s bo'lgan qurilmalar → status = 'offline'
```

### 6.14 Admin Foydalanuvchilar

```
GET    /api/admin-users           — Ro'yxat (Super Admin)
POST   /api/admin-users           — Yaratish
PUT    /api/admin-users/:id       — Tahrirlash
DELETE /api/admin-users/:id       — O'chirish
PUT    /api/admin-users/:id/password — Parol o'zgartirish
```

---

## 7. Frontend Polling (Real-time ma'lumotlar)

Frontend ma'lumotlarni HTTP polling orqali oladi.

| Sahifa | Endpoint | Interval |
|---|---|---|
| Dashboard widgetlar | `GET /api/dashboard/summary` | 30 soniya |
| Monitoring feed | `GET /api/monitoring/events?after={lastId}` | 3 soniya |
| Qurilmalar holati | `GET /api/devices/status` | 60 soniya |
| Bino occupancy | `GET /api/dashboard/live` | 15 soniya |

**Monitoring endpoint:**
```
GET /api/monitoring/events?after={lastEventId}&limit=50
Response: {
  "events": [...],
  "lastId": "uuid"
}
```
Frontend `lastId` ni saqlab, har so'rovda yuboradi — faqat yangi hodisalar keladi.

---

## 8. Biznes Qoidalar

### 8.1 Davomat Statusi Hisoblash (`attendance_records`)

Har kecha cron (23:59) yoki kunning oxirida ishlaydigan job:

```
1. Sana biror holidays yozuvining start_date–end_date oralig'iga kiradimi?
   → Ha: status = 'holiday', keyingi qadamlarga o'tilmaydi
   → SQL: WHERE :date BETWEEN start_date AND end_date
2. Foydalanuvchi uchun ish kuni/vaqti belgilangan?
   - Yo'q → attendance_record yaratilmaydi
3. attendance_logs dan min(entry) va max(exit) olish
4. Kirish yo'q → status = 'absent'
5. Kirishning vaqti expected_start dan kech? → late_minutes hisobi
6. Chiqish expected_end dan erta? → early_exit_minutes hisobi
7. Status:
   - late_minutes = 0 va early_exit_minutes = 0 → 'present'
   - late_minutes > 0 → 'late'
   - early_exit_minutes > 0 → 'early_exit'
8. Manuel entry mavjud bo'lsa → status = 'excused'
```

### 8.2 O'qituvchi Ish Grafigi

**`teacher_work_type = 'class_only'` (jadval asosida):**
- `work_schedules.schedule_type = 'class_only'` yozuvi yaratiladi
- Davomat faqat dars vaqtida tekshiriladi: `class_schedules.start_time – end_time` oralig'ida binoda bo'lishi kerak
- Darsdan tashqari vaqtda kelsa/ketsa — `attendance_record` da hisoblanmaydi
- `expected_start` / `expected_end` = dars boshlanish/tugash vaqti

**`teacher_work_type = 'fixed_hours'` (soatbay / kun davomida):**
- `work_schedules.schedule_type = 'fixed_hours'`, `start_time`, `end_time`, `work_days` belgilanadi
- Belgilangan kunlarda belgilangan vaqtda kelishi va ketishi kerak
- Davomat oddiy xodim kabi hisoblanadi: `start_time` dan `end_time` gacha
- Dars jadvali bo'lsa ham, asosiy hisob `work_schedules.start_time` / `end_time` ga ko'ra

**Ish grafigini yangilash:**
- Excel dars jadvali import qilinganda `class_only` uchun `work_schedule` avtomatik yangilanadi
- `fixed_hours` uchun admin qo'lda belgilaydi

### 8.3 Qoravul Tsikl Hisoblash

> Qoravullar `users.employee_subtype = 'guard'`, `work_schedules.schedule_type = 'guard_rotation'`

```
rotation_start_date + (har 4 kunda ish kuni)
is_24h_shift = true bo'lsa: 1 kun ish, 3 kun dam
is_24h_shift = false bo'lsa: kunlik ish grafigi sifatida
```

**24-soatlik smena kun chegarasi:**
- Smena `day_boundary_hour` (default: 04:00) da boshlanib, ertangi `day_boundary_hour` da tugaydi
- Misol: kirish 22:00, chiqish ertangi 08:00 → bitta smena, bitta `attendance_record`
- Cron 04:00 da ishlaydi — tungi smenalar to'g'ri hisoblanadi

### 8.4 Manuel Davomat Qoidalari

- Faqat `admin` va `hr_manager` roli qo'sha oladi
- `notes` maydoni majburiy (bo'sh bo'lmasligi kerak)
- Manuel davomat mavjud bo'lsa, FaceID logidan ustun turadi
- Xuddi shu kun uchun faqat bitta manuel entry bo'lishi mumkin

### 8.5 Ishlagan Soat Hisoblash

```
total_minutes = last_exit_at - first_entry_at (daqiqalarda)
Ish kuni jami soat = total_minutes / 60
```

---

## 9. Xavfsizlik (RBAC)

### 9.1 Rollar va Ruxsatlar

| Ruxsat | super_admin | hr_manager | operator | security |
|---|:---:|:---:|:---:|:---:|
| Barcha ma'lumotlarni ko'rish | ✅ | ✅ | ✅ | ✅ |
| Manuel davomat qo'shish | ✅ | ✅ | ✅ | ❌ |
| Foydalanuvchi ma'lumotlarini tahrirlash | ✅ | ✅ | ❌ | ❌ |
| Hisobot eksport | ✅ | ✅ | ✅ | ❌ |
| Binolar/Qurilmalar boshqarish | ✅ | ❌ | ❌ | ❌ |
| Eshikni ochish (door open) | ✅ | ✅ | ✅ | ✅ |
| Bayram kunlari boshqarish | ✅ | ✅ | ❌ | ❌ |
| Admin foydalanuvchilar | ✅ | ❌ | ❌ | ❌ |
| Excel import qilish | ✅ | ✅ | ❌ | ❌ |

### 9.2 JWT Konfiguratsiya

- Access token TTL: 15 daqiqa
- Refresh token TTL: 7 kun (Redis da saqlash)
- Refresh token rotation (har refreshda yangi token)
- **JWT Revocation:** Redis da `blacklisted_jti` Set (TTL = 15 daqiqa)
  - Trigger: logout, parol o'zgarishi, foydalanuvchi deaktivatsiyasi
  - JWT middleware har so'rovda blacklist tekshiradi

### 9.3 ISUP Server Xavfsizlik

- `X-API-Key` header (shared secret, .env da) — barcha ISUP server so'rovlarida
- ISUP server faqat ichki tarmoqda, tashqi internetga ochiq emas
- Rate limiting: Hono → ISUP server, 500 req/min

### 9.4 Umumiy Xavfsizlik
- Helmet.js (HTTP security headers)
- Rate limiting (global: 100 req/min per IP)
- Input validatsiya (Zod + `@hono/zod-validator`)
- SQL injection: Drizzle ORM parameterized queries
- Logging: barcha muhim amallar audit log ga yoziladi

---

## 10. Docker Infratuzilmasi

```yaml
# docker-compose.yml strukturasi

services:
  api:
    image: oven/bun:1.1-alpine
    # Hono app (bun run src/index.ts)
    ports: ["3000:3000"]
    depends_on: [postgres, redis]
    volumes:
      - uploads:/app/uploads

  postgres:
    image: postgres:16-alpine
    volumes: [pgdata:/var/lib/postgresql/data]
    environment:
      POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD

  redis:
    image: redis:7-alpine
    volumes: [redisdata:/data]

  nginx:
    image: nginx:alpine
    # Reverse proxy, SSL termination
    ports: ["80:80", "443:443"]

volumes:
  pgdata:
  redisdata:
  uploads:  # Local file storage (yuz rasmlari, import Excel fayllari)
```

### 10.1 Environment Variables (.env)

```env
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=davomat
DB_USER=davomat_user
DB_PASSWORD=...

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# JWT
JWT_SECRET=...
JWT_REFRESH_SECRET=...

# ISUP Server
ISUP_SERVER_URL=http://isup-server:8080
ISUP_API_KEY=...

# File Storage (local)
FILE_STORAGE_PATH=/app/uploads
FILE_BASE_URL=http://api-server:3000/files
IMPORT_MAX_FILE_SIZE_MB=50

# Timezone
TZ=Asia/Tashkent
```

---

## 11. Timezone Boshqaruvi

**Asosiy qoida:** bazada hamma timestamp **UTC** da saqlanadi, ekranda **UTC+5 (Asia/Tashkent)** da ko'rsatiladi.

### 11.1 Qatlamlar bo'yicha timezone

| Qatlam | Sozlama | Izoh |
|---|---|---|
| **FaceID qurilma** | UTC+5 ga sozlangan | ISUP server qurilmadan kelgan vaqtni UTC ga o'giradi |
| **ISUP Server** | UTC formatda yuboradi | `occurred_at` har doim UTC ISO 8601 |
| **Hono** | `TZ=Asia/Tashkent` (.env) | Cron ifodalar mahalliy vaqtda yoziladi |
| **PostgreSQL** | `TIMESTAMPTZ` (UTC) | Barcha `TIMESTAMP` ustunlar `WITH TIME ZONE` |
| **TIME maydonlar** | Local time (UTC+5) | `start_time`, `end_time`, `day_boundary_hour` — mahalliy vaqt |
| **Frontend** | `Intl.DateTimeFormat` `Asia/Tashkent` | Server UTC, ekran UTC+5 |

### 11.2 PostgreSQL konfiguratsiyasi

```sql
-- Barcha TIMESTAMP ustunlar TIMESTAMPTZ bo'lishi shart
ALTER TABLE attendance_logs
  ALTER COLUMN occurred_at TYPE TIMESTAMPTZ;

-- PostgreSQL sessiya timezone
SET timezone = 'Asia/Tashkent';

-- Server default
-- postgresql.conf: timezone = 'UTC'  (saqlash UTC, query UTC+5 da ko'rinadi)
```

### 11.3 Bun + Hono sozlamasi

```typescript
// src/index.ts
process.env.TZ = 'Asia/Tashkent';

// PostgreSQL connection (Drizzle + node-postgres yoki bun:sqlite emas — postgres())
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // PostgreSQL TIMESTAMPTZ — UTC da saqlanadi, ISO string sifatida qaytadi
});

export const db = drizzle(pool);
```

### 11.4 Cron Joblar (Tashkent vaqtida)

| Cron | Ifoda (TZ=Asia/Tashkent) | Vazifa |
|---|---|---|
| Davomat hisoblash | `0 4 * * *` | Har kuni 04:00 — tungi smenalar tugagandan keyin |
| Snapshot tozalash | `0 3 1 * *` | Har oyning 1-kuni 03:00 — 30 kundan eski `image_snapshot` yo'llari NULL qilinadi, fayl o'chiriladi |
| Arxivlash (logs) | `0 1 1 * *` | Har oyning 1-kuni 01:00 |

> **Muhim:** Davomat hisoblash croni `0 4 * * *` (04:00) da ishlaydi — qoravulning tungi smenasi shu vaqtda tugaydi.

### 11.5 Vaqt Hisoblash Qoidalari

**Ishlagan vaqt:**
```sql
-- total_minutes: TIMESTAMPTZ farqi avtomatik to'g'ri hisoblanadi
total_minutes = EXTRACT(EPOCH FROM (last_exit_at - first_entry_at)) / 60
```

**Kechikish hisoblash:**
```sql
-- expected_start (TIME, UTC+5) ni bugungi TIMESTAMPTZ ga aylantirish
expected_start_ts = (date + expected_start) AT TIME ZONE 'Asia/Tashkent'
late_minutes = GREATEST(0,
  EXTRACT(EPOCH FROM (first_entry_at - expected_start_ts)) / 60
)
```

**Tungi smena (day_boundary_hour = 4):**
```sql
-- Smena sanasi: kirish vaqti 04:00 dan oldin bo'lsa, oldingi kun sifatida hisoblanadi
shift_date = CASE
  WHEN EXTRACT(HOUR FROM (first_entry_at AT TIME ZONE 'Asia/Tashkent')) < day_boundary_hour
    THEN (first_entry_at AT TIME ZONE 'Asia/Tashkent')::DATE - 1
  ELSE (first_entry_at AT TIME ZONE 'Asia/Tashkent')::DATE
END
```

### 11.6 Frontend Ko'rsatish

```typescript
// Barcha vaqtlarni Tashkent vaqtida ko'rsatish
const fmt = new Intl.DateTimeFormat('uz-UZ', {
  timeZone: 'Asia/Tashkent',
  dateStyle: 'short',
  timeStyle: 'short'
});

// API javobida UTC ISO string keladi
// "2026-05-04T03:32:15.000Z" → "04.05.2026, 08:32" (UTC+5)
```

---

## 12. Ishlash Ko'rsatkichlari (Performance)

| Ko'rsatkich | Maqsad |
|---|---|
| API javob vaqti (oddiy) | < 200ms |
| API javob vaqti (hisobot) | < 3s (kichik); async (katta) |
| Excel import (10,000 talaba) | < 2 daqiqa |
| Concurrent foydalanuvchilar | 200+ |
| FaceID hodisalar | 50 hodisa/soniya |

### 11.1 Optimizatsiya Choralari

- PostgreSQL indekslar: `user_id + date`, `building_id + occurred_at`, `hemis_id`
- Redis cache: dashboard statistika (30 soniyada bir yangilash)
- Pagination: barcha ro'yxatlarda `limit/offset` yoki `cursor`
- Katta hisobotlar va Excel import: BullMQ orqali background ishlov
- Database connection pooling: Drizzle pool `max: 20`

---

## 12. API Hujjatlashtirish

- `@hono/swagger-ui` + `@hono/zod-openapi` — Zod sxemalardan avtomatik OpenAPI
- Swagger UI: `/api/docs` (faqat development va staging)
- OpenAPI 3.0 spec eksport: `/api/docs-json`
- Har bir endpoint uchun: request/response Zod schema, error kodlar, autentifikatsiya talabi

---

## 13. Loyihaning Bun + Hono Modul Tuzilmasi

```
src/
├── index.ts              — Hono app entry, server boot
├── modules/
│   ├── auth/             — JWT middleware, login/logout/refresh
│   ├── users/            — Student, Teacher, Employee routes
│   │   ├── students.ts
│   │   ├── teachers.ts
│   │   └── employees.ts
│   ├── attendance/       — Logs, Records, Manual
│   ├── schedules/        — Class schedules, Work schedules
│   ├── buildings/
│   ├── devices/          — FaceID devices
│   ├── holidays/
│   ├── import/           — Excel import (students, teachers, ...)
│   │   ├── parser.ts     — exceljs parser
│   │   ├── validators.ts — Zod schemas
│   │   └── routes.ts
│   ├── isup/             — ISUP HTTP client, person mgmt, callback
│   ├── faceid/           — Qurilmadan to'g'ridan callback handler
│   ├── dashboard/
│   ├── reports/          — Export + stats
│   └── admin-users/
├── middleware/
│   ├── auth.ts           — JWT verify, role guard
│   ├── logger.ts
│   └── error.ts          — Global error handler
├── db/
│   ├── schema.ts         — Drizzle schema (barcha jadvallar)
│   ├── client.ts         — DB connection
│   └── migrations/       — Drizzle Kit migrations
├── queue/
│   ├── workers/          — BullMQ workers (reports, import)
│   └── queues.ts
├── lib/
│   ├── zod-schemas.ts    — umumiy Zod sxemalar
│   └── utils.ts
└── config/
    └── env.ts            — process.env validatsiya (Zod)
```

---

## 14. Test Strategiyasi

| Test turi | Tool | Maqsad |
|---|---|---|
| Unit | `bun test` (built-in) | >70% coverage |
| Integration | Testcontainers + `bun test` | Real PostgreSQL/Redis bilan |
| E2E | Playwright | Login → davomat → hisobot oqimi |
| Load | k6 | 50 event/sec, 200+ concurrent user |
| Security | OWASP ZAP | SQL injection, XSS, auth bypass |

---

## 15. Biometrik Ma'lumotlar Siyosati

> O'zbekiston "Shaxsiy ma'lumotlar to'g'risida" qonuni talabi.

**Saqlash:**

- Yuz rasmlari (ro'yxatga olish uchun): server lokal filesystemda (`/app/uploads/faces/`)
- `attendance_logs.image_snapshot`: qurilmadan kelgan hodisa rasmi fayl yo'li

**Muddati:**

- `image_snapshot` — **30 kun** saqlanadi. Har oyning 1-sanasida cron (`0 3 1 * *`) 30 kundan eski yozuvlarning:
  1. Fayl diskdan o'chiriladi
  2. `image_snapshot` ustun `NULL` qilinadi

**Kirish nazorati:**

- `audit_logs` jadvali (§4.15): kim qaysi profilni ko'rdi, kim eksport qildi, kim eshik ochdi
- Eksport fayllarida yuz rasmlari bo'lmaydi

---

## 16. Kuzatuv Tizimi (Observability)

**Stack:** Prometheus + Grafana + Loki (docker-compose ga qo'shiladi)

**Metrikalar (Prometheus):**
- API latency (p50, p95, p99)
- FaceID callback rate (hodisa/soniya)
- BullMQ queue backlog hajmi
- DB connection pool holati

**Alert qoidalar:**
- FaceID callback > 10 daqiqa 0 hodisa → alert (qurilma muammosi)
- Excel import xato → alert
- BullMQ queue backlog > 1,000 → alert
- DB slow query > 2s → alert

**docker-compose qo'shimcha servislar:**
```yaml
prometheus:
  image: prom/prometheus:latest
  ports: ["9090:9090"]

grafana:
  image: grafana/grafana:latest
  ports: ["3001:3000"]

loki:
  image: grafana/loki:latest
```

---

## 17. Tekshirish (Verification)

- [ ] `docker-compose up` bilan barcha servislar ishga tushadi
- [ ] `POST /api/auth/login` ishlaydi va JWT qaytaradi
- [ ] Logout qilgach, eski token `401` qaytaradi (JWT blacklist ishlaydi)
- [ ] `GET /api/import/template/students` bo'sh Excel shablonini qaytaradi
- [ ] `POST /api/import/students` (multipart/form-data) Excel ni parse qilib bazaga yozadi
- [ ] Excel da yo'q foydalanuvchi `inactive` bo'ladi va ISUP serverdan yuzi o'chiriladi
- [ ] Excel da xato qatorlar bo'lsa `errors.xlsx` orqali yuklab olish mumkin
- [ ] FaceID qurilmasi `POST /api/faceid/callback` ga hodisa yuborganida `attendance_logs` ga yoziladi
- [ ] 24-soatlik smenada kirish 22:00 + chiqish 08:00 → bitta `attendance_record`
- [ ] Soat 04:00 da cron `attendance_records` ni to'g'ri hisoblaydi
- [ ] 30 kundan eski `image_snapshot` maydonlari `NULL` qilinadi
- [ ] `GET /api/monitoring/events?after={id}` faqat yangi hodisalarni qaytaradi
- [ ] `GET /api/reports/attendance` to'g'ri filtered natija qaytaradi
- [ ] Swagger UI `/api/docs` da ochiladi
- [ ] Grafana dashboardda metrikalar ko'rinadi

---

*Yaratilgan: 2026-05-04 | Yangilangan: 2026-05-13 | Versiya: 2.0 (Bun + Hono + Excel Import)*
