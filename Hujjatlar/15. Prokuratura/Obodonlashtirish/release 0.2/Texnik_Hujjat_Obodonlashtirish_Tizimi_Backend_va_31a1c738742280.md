# Texnik Hujjat: Obodonlashtirish Tizimi - Backend va Database Arxitekturasi

| Maydon | Qiymat |
| --- | --- |
| **Versiya** | 3.0 (Qisqartirilgan) |
| **Yaratilgan Sana** | 2025 |
| **Texnik Stack** | Bun.js + Drizzle ORM + PostgreSQL 15+ |
| **Hujjat Maqsadi** | Backend dasturchilar uchun qisqa texnik qo'llanma |
| **Status** | ✅ Production Ready |
| **Eslatma** | Database schemalar `schema.ts` va `relations.ts` fayllarida mavjud |

---

## 📑 MUNDARIJA

1. [Tizim Umumiy Ko'rinishi](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
2. [Texnik Stack](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
3. [Arxitektura Diagrammasi](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
4. [Face Recognition Arxitekturasi](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
5. [GPS Tracking Arxitekturasi](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
6. [Mobile Client Location Verification](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
7. [Security va Access Control](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
8. [Performance Optimizatsiyasi](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
9. [API Endpoint Recommendations](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
10. [Migration Strategy](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
11. [Monitoring va Logging](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
12. [Backup va Recovery](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)
13. [Keyingi Qadamlar](https://www.notion.so/Texnik-Hujjat-Obodonlashtirish-Tizimi-Backend-va-Database-Arxitekturasi-31a1c738742280a2b151e99c617b4181?pvs=21)

---

## 1. TIZIM UMUMIY KO'RINISHI

### 1.1. Maqsad

Prokuratura – Obodonlashtirish xodimlarining davomatlari va texnikalarning qayerda ekanligini xaritada ko'rsatuvchi tizim.

### 1.2. Asosiy Funksiyalar

| # | Funksiya | Tavsif |
| --- | --- | --- |
| 1 | Tashkilotlar Iyerarxiyasi | Tashkilotlarning ma'lumotlarini iyerarxiya qilib shakllantirish |
| 2 | Cross Access | Tashkilotlararo ruxsatnomalar boshqaruvi |
| 3 | Brigada Tuzilmasi | Brigaderlarni biriktirish va guruh rahbari qilib belgilash |
| 4 | Xodimlar Boshqaruvi | Guruhga xodimlarni biriktirib chiqish |
| 5 | Face Recognition Davomat | Planshetlarda yuz orqali davomat qayd etish |
| 6 | Hudud Boshqaruvi | KMZ fayllarni import qilib, xodimlarga hudud biriktirish |
| 7 | Texnika Ro'yxati | Maxsus texnikalar ro'yxatini shakllantirish |
| 8 | Texnika Biriktirish | Texnikalarni xodimlarga biriktirish |
| 9 | GPS Tracking | Teltonika MF920 GPS qurilmasidan ma'lumot olish (Socket + Binary) |
| 10 | Dashboard | Barcha ma'lumotlarni dashboard ko'rinishida taqdim etish |

---

## 2. TEXNIK STACK

| Komponent | Texnologiya | Versiya | Izoh |
| --- | --- | --- | --- |
| **Runtime** | Bun.js | Latest | Yuqori performans, kam xotira |
| **Framework** | HonoJS | Latest | Lightweight HTTP framework |
| **ORM** | Drizzle ORM | Latest | Type-safe, schema-first |
| **Database** | PostgreSQL | 15+ | JSONB, BRIN index, CTE |
| **Cache** | Redis | 7+ | Session, queue, rate limiting |
| **Queue** | BullMQ | Latest | Async job processing |
| **Face Recognition** | Python Service | Custom | Async queue orqali |
| **GPS Tracking** | Teltonika MF920 | Socket Protocol | 30 soniya interval |
| **File Storage** | S3/MinIO | - | Rasm va snapshotlar |
| **Password Hash** | Bcrypt | cost=10 | Xavfsiz parol saqlash |
| **JWT** | HS256 | - | Authentication token |

---

## 3. ARXITEKTURA DIAGRAMMASI

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │   Web    │  │  Mobile  │  │ Tablet   │  │  Admin   │        │
│  │ Dashboard│  │   App    │  │  (Brig)  │  │  Panel   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│         │             │              │              │            │
│         └─────────────┴──────────────┴──────────────┘            │
│                           │                                       │
│         📍 Location Verification (Mobile Side - 100% Trust)      │
└───────────────────────────┼───────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (Bun.js + Hono)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Auth API   │  │  Business    │  │  Device      │          │
│  │              │  │    API       │  │    API       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER (PostgreSQL)                   │
│  📌 Schema: schema.ts, relations.ts (alohida fayllarda)         │
│  📌 Primary Keys: UUID (defaultRandom)                          │
│  📌 Timestamps: ISO String (mode: 'string')                     │
│  📌 GPS Tracking: BRIN Index + Auto-Cleanup (60 kun)            │
│  📌 Soft Delete: Barcha jadvallarda (isDeleted + deletedAt)     │
└───────────────────────────┼─────────────────────────────────────┘
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  Face Recognition│ │   GPS Tracking   │ │   File Storage   │
│  (Python SVC)    │ │   (TCP Socket)   │ │   (S3/MinIO)     │
└──────────────────┘ └──────────────────┘ └──────────────────┘
              │             │
              ▼             ▼
    ┌──────────────────────────────┐
    │       Redis Queue            │
    │      (BullMQ)                │
    └──────────────────────────────┘
```

---

## 4. FACE RECOGNITION ARXITEKTURASI

### 4.1. Jarayon Oqimi

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Device    │────▶│  Bun.js     │────▶│   Python    │
│  (Camera)   │     │   Server    │     │   Service   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │          ┌─────────────────┐          │
       │          │attendanceEvent  │          │
       │          │     CREATE      │          │
       │          └─────────────────┘          │
       │                   │                   │
       │                   ▼                   │
       │          ┌─────────────────┐          │
       │          │faceRecognitionJob│          │
       │          │  status=PENDING │          │
       │          └─────────────────┘          │
       │                   │                   │
       │                   ▼                   │
       │          ┌─────────────────┐          │
       │          │  Redis Queue    │──────────┤
       │          │   (BullMQ)      │          │
       │          └─────────────────┘          │
       │                                       │
       │                   ◀───────────────────┤
       │                   │                   │
       │          ┌─────────────────┐          │
       │          │faceRecognitionJob│          │
       │          │ status=COMPLETED│          │
       │          │ matchedStaffId  │          │
       │          └─────────────────┘          │
       │                   │                   │
       │                   ▼                   │
       │          ┌─────────────────┐          │
       │          │attendanceEvent  │          │
       │          │     UPDATE      │          │
       │          └─────────────────┘          │
       │                   │                   │
       │                   ▼                   │
       │          ┌─────────────────┐          │
       │          │dailyAttendance  │          │
       │          │ CREATE/UPDATE   │          │
       │          └─────────────────┘          │
```

### 4.2. Face Recognition Job Statuslari

| Status | Tavsif | Keyingi Harakat |
| --- | --- | --- |
| `PENDING` | Queue da kutayapti | Worker oladi |
| `PROCESSING` | Python service da ishlanmoqda | Javob kutilmoqda |
| `COMPLETED` | Muvaffaqiyatli yakunlandi | `dailyAttendance` yangilanadi |
| `FAILED` | Xatolik yuz berdi | Retry yoki manual review |

### 4.3. Retry Mechanism

```tsx
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 5000;

async function processFaceJob(job: Job) {
  try {
    const result = await callPythonService(job.data);
    await updateJobStatus(job.id, 'COMPLETED', result);
  } catch (error) {
    const retryCount = job.attemptsMade;
    if (retryCount < MAX_RETRIES) {
      await updateJobStatus(job.id, 'PENDING', { error });
      throw error; // BullMQ avtomatik retry qiladi
    } else {
      await updateJobStatus(job.id, 'FAILED', { error });
    }
  }
}
```

---

## 5. GPS TRACKING ARXITEKTURASI

### 5.1. Teltonika MF920 Protocol

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  GPS Device │────▶│  TCP Socket │────▶│  Bun.js     │
│  (MF920)    │     │   Server    │     │   Parser    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                     │
       │         Binary Data                 │
       │         (AVL Protocol)              │
       │                                     ▼
       │                           ┌─────────────────┐
       │                           │  gpsTracking    │
       │                           │  INSERT BATCH   │
       │                           └─────────────────┘
```

### 5.2. GPS Ma'lumotlar Strategiyasi (NO PARTITIONING)

**Qaror:** 2 oylik (60 kun) retention uchun partitioning **ISHLATILMAYDI**

| Omil | Qiymat | Xulosa |
| --- | --- | --- |
| Ma'lumot hajmi (100 device) | ~17 million record | PostgreSQL uchun o'rtacha |
| Jami hajm (index bilan) | ~15-20 GB | Bitta table'da boshqarish mumkin |
| Query tezligi | BRIN + B-Tree | Partitioning siz ham tez |
| Maintenance | DELETE + VACUUM | Oddiyroq |

### 5.3. Optimizatsiya Yechimlari

| Yechim | Tavsif | Foyda |
| --- | --- | --- |
| **BRIN Index** | Time-series ma'lumotlar uchun | 100x kompakt index |
| **Batch Insert** | Har 1000 ta ma'lumotni batch qilib yozish | Performance |
| **Auto-Cleanup** | Har kuni 60 kundan eski ma'lumotlarni o'chirish | Storage |
| **Autovacuum** | Maxsus sozlamalar | Table bloat prevention |

### 5.4. GPS Cleanup Service

```tsx
// services/gps-cleanup.service.ts
export class GPSCleanupService {
  private readonly retentionDays = 60;
  private readonly batchSize = 10000;

  async cleanupOldData(): Promise<{ deleted: number }> {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - this.retentionDays);

    let deleted = 0;
    let batch = this.batchSize;

    while (batch === this.batchSize) {
      const result = await db.execute(sql`
        DELETE FROM gps_tracking
        WHERE id IN (
          SELECT id FROM gps_tracking
          WHERE received_at < ${cutoff}
          LIMIT ${this.batchSize}
        )
      `);
      batch = result.rowCount ?? 0;
      deleted += batch;
    }

    await db.execute(sql`VACUUM (ANALYZE) gps_tracking`);
    return { deleted };
  }
}
```

### 5.5. GPS Socket Server

```tsx
// servers/gps-socket.server.ts
export async function startGPSSocketServer(port: number = 8888) {
  const server = Bun.listen({
    socket: {
      data(socket, buffer) {
        const imei = parseImei(buffer);
        const gpsData = parseAVL(buffer);
        trackingService.queueForBatch(imei, gpsData);
        socket.write(buildAck(imei));
      },
    },
    port,
    hostname: '0.0.0.0',
  });

  console.log(`📡 GPS Socket Server running on port ${port}`);
  return server;
}
```

---

## 6. MOBILE CLIENT LOCATION VERIFICATION

### 6.1. Arxitektura Qarori

| Qaror | Holat | Izoh |
| --- | --- | --- |
| **Point-in-Polygon Logic** | ✅ Mobile Side | Barcha geometriya hisob-kitoblari mobil qurilmada |
| **Server-Side Verification** | ❌ Yo'q | Backend sanity check, audit yo'q |
| **PostGIS Extension** | ❌ Kerak Emas | Database da PostGIS o'rnatish shart emas |
| **Client Trust** | ✅ 100% | Mobile yuborgan `locationVerified: true` qabul qilinadi |

### 6.2. Data Flow

```
┌─────────────────┐
│  Mobile Client  │
│  (Point-in-Poly │
│  gon Logic)     │
└────────┬────────┘
         │ 1. Territory Coordinates yuklab oladi
         │ 2. GPS + Polygon tekshiradi
         │ 3. locationVerified: true deb yuboradi
         ▼
┌─────────────────┐
│   Backend API   │
│   (HonoJS + Bun)│
└────────┬────────┘
         │ 1. Mobile flag'ga ishonadi
         │ 2. Ma'lumotni DB ga yozadi
         │ 3. Face Recognition queue ga qo'yadi
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   (Drizzle ORM) │
└─────────────────┘
```

### 6.3. Territory Sync API

```tsx
// GET /api/territories/my
// Response:
{
  "territories": [
    {
      "id": "uuid",
      "name": "Yashnobod Tumani",
      "coordinates": [[...]], // GeoJSON Polygon
      "updatedAt": "2025-01-15T10:00:00Z"
    }
  ]
}
```

### 6.4. Attendance Submit API

```tsx
// POST /api/attendance/submit
// Request:
{
  "deviceId": "uuid",
  "eventTime": "2025-01-15T09:00:00Z",
  "snapshot": "base64...",
  "latitude": 41.3115,
  "longitude": 69.2401,
  "locationVerified": true,  // Mobile tomonidan hisoblangan
  "territoryId": "uuid"
}
```

### 6.5. Risklar va Mitigatsiya

| Risk | Ehtimollik | Ta'sir | Mitigatsiya |
| --- | --- | --- | --- |
| GPS Spoofing | Yuqori | Xodim hududda bo'lmasa ham davomatga chiqishi | Tashkilot siyosati, jarima |
| Device Sharing | O'rta | Bir device dan bir nechta xodim kirishi | Device-Staff binding |
| Territory Sync | O'rta | Territory o'zgarganda mobile da eskisi qolishi | `updatedAt` bilan cache invalidation |

---

## 7. SECURITY VA ACCESS CONTROL

### 7.1. Password Hashing

```tsx
// utils/password.ts
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 10;

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### 7.2. JWT Configuration

```tsx
// config/auth.config.ts
export const AUTH_CONFIG = {
  jwt: {
    algorithm: 'HS256',
    secret: process.env.JWT_SECRET!,
    expiresIn: '15m',        // Access token
    refreshExpiresIn: '7d',  // Refresh token
  },
} as const;
```

### 7.3. Tashkilotlararo Ruxsat (Cross Access)

`organizationCrossAccess` jadvali orqali tashkilotlararo READ/WRITE ruxsatnomalar boshqariladi.

### 7.4. User va Staff Ajratish

| User | Staff |
| --- | --- |
| Tizimga kirish (login) | Tashkilot xodimi (davomat) |
| phoneNumber + password | organization + brigade |
| Photo | Photo + face encoding |

### 7.5. Soft Delete Pattern

Barcha jadvallarda quyidagi audit maydonlar mavjud:

```tsx
isDeleted: boolean('is_deleted').default(false).notNull(),
deletedAt: timestamp('deleted_at', { mode: 'string' }),
```

**Drizzle Query da foydalanish:**

```tsx
// Faqat o'chirilmagan yozuvlar
const result = await db.query.staff.findMany({
  where: eq(staff.isDeleted, false)
});

// Soft delete qilish
await db.update(staff)
  .set({ isDeleted: true, deletedAt: new Date().toISOString() })
  .where(eq(staff.id, 'some-id'));
```

---

## 8. PERFORMANCE OPTIMIZATSIYASI

### 8.1. Indeks Strategiyasi

| Jadval | Indeks | Tip | Maqsad |
| --- | --- | --- | --- |
| gpsTracking | idx_gps_device_time | B-Tree | Device bo'yicha vaqt qidiruvi |
| gpsTracking | idx_gps_received_at_brin | BRIN | Time-series optimizatsiyasi |
| attendanceEvent | idx_att_event_device_time | B-Tree | Qurilma bo'yicha vaqt |
| attendanceEvent | idx_att_event_org_time | B-Tree | Tashkilot bo'yicha hisobot |
| dailyAttendance | idx_att_daily_date_status | B-Tree | Kunlik statistika |
| dailyAttendance | uq_staff_daily | UNIQUE | Bir xodim - bir kun |
| staff | uq_staff_org_phone | UNIQUE | Xodim qidiruvi |
| device | uq_equipment_org_serial | UNIQUE | Qurilma identifikatsiyasi |

### 8.2. BRIN Index Custom Migration

```sql
-- drizzle/0001_add_brin_index_gps.sql

-- BRIN Index (time-series uchun optimal)
CREATE INDEX IF NOT EXISTS idx_gps_received_at_brin
  ON gps_tracking USING BRIN (received_at);

-- B-Tree Index (device queries uchun)
CREATE INDEX IF NOT EXISTS idx_gps_device_time
  ON gps_tracking (gps_device_id, received_at DESC);

-- Autovacuum sozlamalari
ALTER TABLE gps_tracking SET (
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 1000,
  autovacuum_naptime = '30s'
);
```

### 8.3. Query Optimizatsiyasi

```tsx
// ✅ TO'G'RI - Index ishlatadi
const events = await db.query.attendanceEvent.findMany({
  where: and(
    eq(attendanceEvent.deviceId, deviceId),
    gte(attendanceEvent.eventTime, startDate)
  ),
  orderBy: desc(attendanceEvent.eventTime),
  limit: 100
});

// ❌ NOTO'G'RI - Full table scan
const events = await db.query.attendanceEvent.findMany({
  where: sql`DATE(${attendanceEvent.eventTime}) = ${date}`
});
```

---

## 9. API ENDPOINT RECOMMENDATIONS

### 9.1. Authentication & User

| Method | Endpoint | Description |
| --- | --- | --- |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/logout` | User logout |
| POST | `/api/auth/refresh` | Refresh token |
| GET | `/api/users/me` | Current user info |
| PUT | `/api/users/me` | Update profile |

### 9.2. Organization

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/organizations` | Get organization tree |
| GET | `/api/organizations/:id` | Get organization details |
| POST | `/api/organizations` | Create organization |
| PUT | `/api/organizations/:id` | Update organization |

### 9.3. Staff & Attendance

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/staff` | Get staff list |
| POST | `/api/staff` | Create staff |
| GET | `/api/attendance/daily` | Get daily attendance |
| GET | `/api/attendance/reports` | Get attendance reports |
| POST | `/api/attendance/submit` | Mobile attendance submit |

### 9.4. Territory

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/territories` | Get territory list |
| POST | `/api/territories` | Create territory (KMZ import) |
| GET | `/api/territories/my` | Mobile: Get assigned territories |
| PUT | `/api/territories/:id` | Update territory |

### 9.5. Equipment & GPS

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/equipment` | Get equipment list |
| GET | `/api/equipment/:id/gps` | Get GPS history |
| GET | `/api/equipment/live` | Get live GPS positions |
| POST | `/api/equipment` | Create equipment |

### 9.6. Task Management

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/tasks` | Get task list |
| POST | `/api/tasks` | Create task |
| PUT | `/api/tasks/:id` | Update task |
| POST | `/api/tasks/:id/assign` | Assign task to staff |

---

## 10. MIGRATION STRATEGY

### 10.1. Drizzle Migration Commands

```bash
# Schema o'zgarishlarini aniqlash
bunx drizzle-kit generate

# Migrationlarni bajarish
bunx drizzle-kit migrate

# Studio orqali ko'rish
bunx drizzle-kit studio

# Custom SQL migration (BRIN index uchun)
bunx drizzle-kit generate --custom --name=add-brin-index-gps
```

### 10.2. Seed Data

Initial data yaratish kerak:

- `organizationType` (Davlat, Xususiy, etc.)
- `organizationTypePosition` (Lavozimlar)
- `equipmentType` (Traktor, Yuk mashina, etc.)
- `taskType` (Tozalash, Ekish, Ta'mirlash, etc.)
- `soato` (Hudud klassifikatori)
- `faceRecognitionService` (Python service config)

### 10.3. drizzle.config.ts

```tsx
// drizzle.config.ts
import type { Config } from "drizzle-kit";

export default {
  schema: "./src/db/schema/index.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
} satisfies Config;
```

---

## 11. MONITORING VA LOGGING

### 11.1. Database Monitoring

```sql
-- Slow query monitoring
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Connection monitoring
SELECT count(*) as connections
FROM pg_stat_activity;

-- Table size monitoring
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  n_dead_tup as dead_rows,
  n_live_tup as live_rows
FROM pg_tables
JOIN pg_stat_user_tables USING (schemaname, tablename)
WHERE tablename = 'gps_tracking';
```

### 11.2. Application Logging

```tsx
// utils/logger.ts
export const logger = {
  info: (message: string, data?: object) => {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: 'info',
      message,
      ...data
    }));
  },
  error: (message: string, error?: Error) => {
    console.error(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: 'error',
      message,
      error: error?.message
    }));
  }
};
```

### 11.3. Custom Metrics

```tsx
// services/metrics.service.ts
export const metrics = {
  gps_inserted: new Counter('gps_tracking_inserted_total'),
  gps_deleted: new Counter('gps_tracking_deleted_total'),
  face_recognition_latency: new Histogram('face_recognition_duration_ms'),
  db_query_duration: new Histogram('database_query_duration_ms'),
  attendance_processed: new Counter('attendance_events_total'),
};
```

---

## 12. BACKUP VA RECOVERY

### 12.1. Backup Strategy

```bash
# Daily full backup
pg_dump -h localhost -U postgres obodonlashtirish > backup_$(date +%Y%m%d).sql

# Hourly WAL archiving
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
```

### 12.2. Recovery Points

| Data Type | RPO | RTO | Izoh |
| --- | --- | --- | --- |
| Attendance | 1 hour | 4 hours | Critical |
| GPS Tracking | 24 hours | 8 hours | 60 kun retention |
| Staff Data | 1 hour | 2 hours | Critical |
| Task Data | 1 hour | 2 hours | Critical |

### 12.3. GPS Data Retention Policy

```tsx
// config/gps.config.ts
export const GPS_CONFIG = {
  retention: {
    days: 60,
    cleanupCron: '0 3 * * *', // Har kuni 03:00
    batchSize: 10000,
  },
  indexing: {
    useBRIN: true,
    usePartialIndex: true,
  },
  monitoring: {
    checkBloatWeekly: true,
    alertIfDeadRatioAbove: 20,
  }
} as const;
```

---

## 13. KEYINGI QADAMLAR

### 13.1. Checklist

```
- [ ] ✅ Database schema final versiyasi (schema.ts, relations.ts)
- [ ] ⏳ Drizzle migrations yaratish
- [ ] ⏳ Seed data tayyorlash
- [ ] ⏳ API endpointlar implementatsiyasi
- [ ] ⏳ Face Recognition Python service integratsiyasi
- [ ] ⏳ GPS Socket server implementatsiyasi
- [ ] ⏳ GPS Cleanup cron job sozlash
- [ ] ⏳ BRIN index custom migration
- [ ] ⏳ Testing va performance tuning
- [ ] ⏳ Docker Compose fayli (PostgreSQL + Redis + Bun + Python)
```

### 13.2. Performance Checklist

```
📊 GPS Tracking:
  - [ ] BRIN index yaratildi
  - [ ] Cleanup cron job ishga tushdi
  - [ ] Autovacuum sozlamalari qo'llandi
  - [ ] Batch insert (1000 record) implement qilindi

📊 Attendance:
  - [ ] Device-time index yaratildi
  - [ ] Duplicate prevention logic qo'shildi
  - [ ] Daily aggregation cron job ishga tushdi

📊 Face Recognition:
  - [ ] Redis queue sozlandi
  - [ ] Retry mechanism implement qilindi
  - [ ] Python service health check qo'shildi

📊 Security:
  - [ ] Bcrypt password hashing
  - [ ] JWT HS256 authentication
  - [ ] Rate limiting sozlandi
```

---

## 📎 QO'SHIMCHA MA'LUMOTLAR

### A. Docker Compose (Development)

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: obodonlashtirish
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pg/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  bun-app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/obodonlashtirish
      REDIS_URL: redis://redis:6379

  python-face-service:
    build: ./services/face-recognition
    ports:
      - "8000:8000"

volumes:
  pg
```

### B. Environment Variables

```bash
# .env.example

# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/obodonlashtirish

# Redis
REDIS_URL=redis://localhost:6379

# Auth
JWT_SECRET=your-secret-key-change-in-prod
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# Face Recognition
FACE_SERVICE_URL=http://localhost:8000
FACE_SERVICE_API_KEY=key-123

# Storage (S3/MinIO)
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=obodonlashtirish

# GPS
GPS_SOCKET_PORT=8888
GPS_RETENTION_DAYS=60
```

### C. Package.json Scripts

```json
{
  "scripts": {
    "dev": "bun run --watch src/index.ts",
    "build": "bun build src/index.ts --outdir dist",
    "start": "bun run dist/index.js",
    "db:generate": "bunx drizzle-kit generate",
    "db:migrate": "bunx drizzle-kit migrate",
    "db:studio": "bunx drizzle-kit studio",
    "db:cleanup:gps": "bun run src/jobs/gps-cleanup.ts",
    "db:vacuum": "bun run src/scripts/vacuum-gps.ts",
    "db:stats": "bun run src/scripts/gps-stats.ts"
  }
}
```

---

## 💡 XULOSA

Ushbu arxitektura **2 oylik GPS ma'lumot retention** uchun optimallashtirilgan. Partitioning murakkabligisiz, **BRIN index** va muntazam cleanup orqali yuqori performans ta'minlanadi.

**Mobile Client 100% Trust** qarori server yuklamasini sezilarli darajada kamaytiradi va offline ishlash imkoniyatini beradi.

**UUID + ISO Timestamp** standarti barcha jamoa a'zolari uchun yagona kod style ta'minlaydi.

Database schemalar `schema.ts` va `relations.ts` fayllarida mavjud - ushbu hujjatda keltirilmagan.

---

| Hujjat Versiyasi | 3.0 (Qisqartirilgan) |
| --- | --- |
| Yaratilgan Sana | 2025 |
| Texnik Stack | Bun.js + Drizzle ORM + PostgreSQL 15+ |
| Hujjat Maqsadi | Backend dasturchilar uchun qisqa texnik qo'llanma |
| Status | ✅ Production Ready |