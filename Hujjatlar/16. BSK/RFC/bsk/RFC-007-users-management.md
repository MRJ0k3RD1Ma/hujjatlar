# RFC-007: Foydalanuvchilar Boshqaruvi — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 007 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |
| **Modul** | Foydalanuvchilar Boshqaruvi |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |

---

## 1. Umumiy ko'rinish

Bu RFC BSK FaceID tizimidagi foydalanuvchilarni boshqarish modulini belgilaydi: admin/operator CRUD, tashkilotlar boshqaruvi, foydalanuvchi-binolar bog'liqlik, tizim audit logi va xavfsizlik logi.

### 1.1 Modeldagi jadvallar

- `users` — tizim foydalanuvchilari
- `organizations` — tashkilotlar (BSK, prokuratura, IIV va h.k.)
- `auth_item` / `auth_assignment` — Yii2 RBAC rollari
- `system_audit_logs` — barcha CUD amallar logi
- `security_access_logs` — prokuratura/IIV kirish logi

### 1.2 7 ta foydalanuvchi roli

| Rol | Tavsif |
|-----|--------|
| `super_admin` | Barcha tizimni boshqaradi |
| `bsk_admin` | BSK tashkilotini boshqaradi |
| `operator` | Tayinlangan binolarni boshqaradi |
| `gasn` | GASN nazorat organi — faqat ko'rish |
| `construction` | Qurilish nazorat organi — cheklangan ko'rish |
| `prosecutor` | Prokuratura — kirish loglari va foto (audit bilan) |
| `iiv` | IIV — kirish loglari va foto (audit bilan) |

### 1.3 Ruxsatlar matritsasi

| Amal | super_admin | bsk_admin | operator | Boshqalar |
|------|-------------|-----------|----------|-----------|
| Foydalanuvchi yaratish | Ha | Ha (o'z org) | Yo'q | Yo'q |
| Foydalanuvchi ko'rish | Ha (barcha) | Ha (o'z org) | Faqat o'zi | Faqat o'zi |
| Foydalanuvchi tahrirlash | Ha | Ha (o'z org) | Faqat o'zi (cheklangan) | Yo'q |
| Foydalanuvchi o'chirish | Ha | Ha (o'z org) | Yo'q | Yo'q |
| Tashkilot CRUD | Ha | Yo'q | Yo'q | Yo'q |
| Audit log ko'rish | Ha | Ha | Yo'q | Yo'q |
| Security log ko'rish | Ha | Ha | Yo'q | Yo'q |

---

## 2. Endpointlar ro'yxati

| Method | Endpoint | Tavsif | Rol |
|--------|----------|--------|-----|
| **Foydalanuvchilar** | | | |
| GET | `/api/v1/users` | Foydalanuvchilar ro'yxati | super_admin, bsk_admin |
| GET | `/api/v1/users/{id}` | Bitta foydalanuvchi | super_admin, bsk_admin, o'zi |
| POST | `/api/v1/users` | Yangi foydalanuvchi | super_admin, bsk_admin |
| PATCH | `/api/v1/users/{id}` | Tahrirlash | super_admin, bsk_admin |
| DELETE | `/api/v1/users/{id}` | O'chirish (soft) | super_admin, bsk_admin |
| PATCH | `/api/v1/users/{id}/status` | Holat o'zgartirish | super_admin, bsk_admin |
| PATCH | `/api/v1/users/{id}/buildings` | Bino tayinlash | super_admin, bsk_admin |
| POST | `/api/v1/users/{id}/reset-password` | Parol tiklash | super_admin, bsk_admin |
| **Tashkilotlar** | | | |
| GET | `/api/v1/organizations` | Tashkilotlar ro'yxati | super_admin |
| GET | `/api/v1/organizations/{id}` | Bitta tashkilot | super_admin, bsk_admin |
| POST | `/api/v1/organizations` | Yangi tashkilot | super_admin |
| PATCH | `/api/v1/organizations/{id}` | Tahrirlash | super_admin |
| DELETE | `/api/v1/organizations/{id}` | O'chirish | super_admin |
| **Audit** | | | |
| GET | `/api/v1/audit-logs` | Tizim audit loglari | super_admin, bsk_admin |
| GET | `/api/v1/audit-logs/stats` | Audit statistikasi | super_admin, bsk_admin |

---

## 3. Endpointlar batafsil

### 3.1 GET /api/v1/users

Foydalanuvchilar ro'yxati.

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page` | number | Sahifa (default: 1) |
| `per_page` | number | Default 20 |
| `search` | string | Ism yoki login bo'yicha qidiruv |
| `role` | string | Rol filtri (vergul bilan ko'p) |
| `status` | string | `active`, `blocked`, `deleted` |
| `organization_id` | number | Tashkilot filtri |
| `sort` | string | `-created_at` (default), `full_name` |

**Request:**

```http
GET /api/v1/users?role=operator,gasn&status=active&page=1
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 15,
        "login": "aziz.operator",
        "full_name": "Toshmatov Aziz",
        "role": "operator",
        "status": "active",
        "organization": {
          "id": 2,
          "name": "Navruz MJK Boshqaruvi",
          "type": "bsk"
        },
        "buildings": [
          { "id": 1, "name": "Navruz-1 MJK" },
          { "id": 2, "name": "Navruz-2 MJK" }
        ],
        "last_login_at": "2026-03-17T08:45:00Z",
        "created_at": "2026-01-15T10:00:00Z",
        "is_2fa_enabled": false
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 28,
      "total_pages": 2,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

---

### 3.2 GET /api/v1/users/{id}

Bitta foydalanuvchi to'liq ma'lumot.

**Request:**

```http
GET /api/v1/users/15
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": 15,
    "login": "aziz.operator",
    "full_name": "Toshmatov Aziz",
    "role": "operator",
    "status": "active",
    "phone_masked": "+998 90 *** 12 34",
    "organization": {
      "id": 2,
      "name": "Navruz MJK Boshqaruvi",
      "type": "bsk",
      "logo_url": "/uploads/organizations/2/logo.webp"
    },
    "buildings": [
      {
        "id": 1,
        "name": "Navruz-1 MJK",
        "address": "Yunusobod tumani, 14-mavze",
        "terminals_count": 3
      },
      {
        "id": 2,
        "name": "Navruz-2 MJK",
        "address": "Yunusobod tumani, 15-mavze",
        "terminals_count": 2
      }
    ],
    "is_2fa_enabled": false,
    "login_attempts": 0,
    "last_login_at": "2026-03-17T08:45:00Z",
    "last_login_ip": "192.168.1.45",
    "created_at": "2026-01-15T10:00:00Z",
    "updated_at": "2026-03-10T14:20:00Z",
    "created_by": {
      "id": 1,
      "full_name": "Super Admin"
    }
  }
}
```

---

### 3.3 POST /api/v1/users

Yangi foydalanuvchi yaratish.

**Request body:**

```json
{
  "login": "sardor.gasn",
  "full_name": "Raximov Sardor",
  "phone": "+998901234567",
  "role": "gasn",
  "organization_id": 3,
  "building_ids": [1, 2, 3],
  "password": "SecurePass123!",
  "is_2fa_enabled": false
}
```

**Maydonlar:**

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|----------|--------|
| `login` | string | Ha | Unikal login (3–50 belgi, `a-z0-9._-`) |
| `full_name` | string | Ha | To'liq ism (3–100 belgi) |
| `phone` | string | Ha | Telefon (+998XXXXXXXXX) |
| `role` | string | Ha | Rol (7 ta roldan biri) |
| `organization_id` | number | Ha | Tashkilot ID |
| `building_ids` | number[] | Ha | Tayinlangan binolar (gasn/construction uchun ham) |
| `password` | string | Ha | Dastlabki parol (min 8 belgi) |
| `is_2fa_enabled` | boolean | Yo'q | Mandatory: prosecutor/iiv uchun avtomatik `true` |

**Response 201:**

```json
{
  "success": true,
  "message": "Foydalanuvchi yaratildi",
  "data": {
    "id": 29,
    "login": "sardor.gasn",
    "full_name": "Raximov Sardor",
    "phone_masked": "+998 90 *** 45 67",
    "role": "gasn",
    "status": "active",
    "organization": {
      "id": 3,
      "name": "Yunusobod GASN"
    },
    "buildings": [
      { "id": 1, "name": "Navruz-1 MJK" },
      { "id": 2, "name": "Navruz-2 MJK" },
      { "id": 3, "name": "Navruz-3 MJK" }
    ],
    "is_2fa_enabled": false,
    "created_at": "2026-03-17T10:00:00Z"
  }
}
```

---

### 3.4 PATCH /api/v1/users/{id}

Foydalanuvchi ma'lumotlarini tahrirlash.

**Request body (partial update):**

```json
{
  "full_name": "Raximov Sardor Ibrohimovich",
  "phone": "+998901112233",
  "organization_id": 4
}
```

> `login` va `role` o'zgartirib bo'lmaydi — alohida endpoint kerak.
> `bsk_admin` o'z tashkilotidagi foydalanuvchini tahrirlaydi, boshqasini emas.

**Response 200:**

```json
{
  "success": true,
  "message": "Foydalanuvchi yangilandi",
  "data": { ... }
}
```

---

### 3.5 DELETE /api/v1/users/{id}

Foydalanuvchini o'chirish (soft delete — status `deleted` ga o'tadi).

**Request:**

```http
DELETE /api/v1/users/29
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "message": "Foydalanuvchi o'chirildi"
}
```

> O'chirilgan foydalanuvchi tizimga kira olmaydi, biroq loglarda ismi ko'rinadi.

---

### 3.6 PATCH /api/v1/users/{id}/status

Foydalanuvchi holatini o'zgartirish.

**Request body:**

```json
{
  "status": "blocked",
  "reason": "Noto'g'ri harakatlar tufayli bloklandi"
}
```

> `status`: `active` | `blocked`
> `reason` — ixtiyoriy izoh, audit logga yoziladi

**Response 200:**

```json
{
  "success": true,
  "message": "Foydalanuvchi bloklandi",
  "data": {
    "id": 29,
    "status": "blocked",
    "updated_at": "2026-03-17T11:00:00Z"
  }
}
```

---

### 3.7 PATCH /api/v1/users/{id}/buildings

Foydalanuvchiga tayinlangan binolarni yangilash.

**Request body:**

```json
{
  "building_ids": [1, 3, 5]
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Binolar yangilandi",
  "data": {
    "user_id": 29,
    "buildings": [
      { "id": 1, "name": "Navruz-1 MJK" },
      { "id": 3, "name": "Navruz-3 MJK" },
      { "id": 5, "name": "Navruz-5 MJK" }
    ]
  }
}
```

---

### 3.8 POST /api/v1/users/{id}/reset-password

Foydalanuvchi parolini tiklash (admin tomonidan).

**Request body:**

```json
{
  "new_password": "NewSecurePass456!",
  "force_change_on_login": true
}
```

> `force_change_on_login: true` — foydalanuvchi keyingi kirishda parolni o'zgartirishi shart

**Response 200:**

```json
{
  "success": true,
  "message": "Parol yangilandi. Foydalanuvchi keyingi kirishda parolini o'zgartirishi kerak."
}
```

---

### 3.9 GET /api/v1/organizations

Tashkilotlar ro'yxati (faqat super_admin).

**Request:**

```http
GET /api/v1/organizations
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "organizations": [
      {
        "id": 1,
        "name": "BSK Bosh Tashkiloti",
        "type": "bsk",
        "soato_code": "1726182",
        "logo_url": "/uploads/organizations/1/logo.webp",
        "users_count": 5,
        "buildings_count": 8,
        "is_active": true,
        "created_at": "2025-01-01T00:00:00Z"
      },
      {
        "id": 3,
        "name": "Yunusobod GASN",
        "type": "gasn",
        "soato_code": "1726182",
        "logo_url": null,
        "users_count": 2,
        "buildings_count": 0,
        "is_active": true,
        "created_at": "2025-06-15T00:00:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

---

### 3.10 POST /api/v1/organizations

Yangi tashkilot yaratish.

**Request body:**

```json
{
  "name": "Chilonzor tuman prokuraturasi",
  "type": "prosecutor",
  "soato_code": "1726182",
  "logo": null
}
```

> `type`: `bsk` | `gasn` | `construction` | `prosecutor` | `iiv` | `other`

**Multipart (logo bilan):**

```
Content-Type: multipart/form-data
name: Chilonzor tuman prokuraturasi
type: prosecutor
soato_code: 1726182
logo: <file>
```

**Response 201:**

```json
{
  "success": true,
  "message": "Tashkilot yaratildi",
  "data": {
    "id": 7,
    "name": "Chilonzor tuman prokuraturasi",
    "type": "prosecutor",
    "soato_code": "1726182",
    "logo_url": null,
    "is_active": true,
    "created_at": "2026-03-17T12:00:00Z"
  }
}
```

---

### 3.11 GET /api/v1/audit-logs

Tizim audit loglari (barcha CUD amallar).

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page` | number | Sahifa |
| `per_page` | number | Default 50 |
| `user_id` | number | Foydalanuvchi bo'yicha filtr |
| `entity_type` | string | `user`, `resident`, `building`, `terminal`, `guest_pass` |
| `action` | string | `create`, `update`, `delete`, `block`, `transfer` |
| `date_from` | string | Sana boshi |
| `date_to` | string | Sana oxiri |

**Request:**

```http
GET /api/v1/audit-logs?entity_type=resident&action=delete&date_from=2026-03-01T00:00:00Z
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "audit_logs": [
      {
        "id": 5421,
        "user": {
          "id": 7,
          "full_name": "Toshmatov Aziz",
          "role": "operator"
        },
        "entity_type": "resident",
        "entity_id": 142,
        "entity_name": "Karimov Bobur (xonadon: 47)",
        "action": "delete",
        "changes": null,
        "ip_address": "192.168.1.45",
        "user_agent": "Mozilla/5.0 ...",
        "created_at": "2026-03-15T14:22:10Z"
      },
      {
        "id": 5418,
        "user": {
          "id": 7,
          "full_name": "Toshmatov Aziz",
          "role": "operator"
        },
        "entity_type": "resident",
        "entity_id": 98,
        "entity_name": "Yusupov Jahongir (xonadon: 12)",
        "action": "update",
        "changes": {
          "full_name": {
            "old": "Yusupov Jahongir",
            "new": "Yusupov Jahongir Aliyevich"
          }
        },
        "ip_address": "192.168.1.45",
        "user_agent": "Mozilla/5.0 ...",
        "created_at": "2026-03-15T11:10:05Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total_items": 312,
      "total_pages": 7,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

---

### 3.12 GET /api/v1/audit-logs/stats

Audit statistikasi.

**Request:**

```http
GET /api/v1/audit-logs/stats?period=week
Authorization: Bearer <access_token>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "period": "week",
    "total_actions": 847,
    "by_action": {
      "create": 124,
      "update": 589,
      "delete": 32,
      "block": 12,
      "transfer": 90
    },
    "by_entity": {
      "resident": 654,
      "terminal": 42,
      "building": 8,
      "user": 15,
      "guest_pass": 128
    },
    "most_active_users": [
      { "user_id": 7, "full_name": "Toshmatov Aziz", "action_count": 234 },
      { "user_id": 12, "full_name": "Operator Sherzod", "action_count": 178 }
    ]
  }
}
```

---

## 4. Biznes qoidalar

### 4.1 Parol talablari

- Minimal 8 belgi
- Kamida 1 ta katta harf, 1 ta kichik harf, 1 ta raqam
- Oxirgi 5 ta parol takrorlanishi mumkin emas
- `prosecutor` va `iiv` rollari uchun minimal 12 belgi, majburiy 2FA

### 4.2 Login noyobligi

- `login` tizim bo'yicha unikal
- Faqat `a-z`, `0-9`, `.`, `_`, `-` belgilar
- Minimal 3, maksimal 50 belgi

### 4.3 2FA majburiyati

- `prosecutor` va `iiv` rollari uchun `is_2fa_enabled` avtomatik `true` qilinadi va o'zgartirib bo'lmaydi
- Boshqa rollar uchun ixtiyoriy

### 4.4 Audit logi

- Barcha CREATE, UPDATE, DELETE amallar `system_audit_logs` ga yoziladi
- `changes` maydoni — eski va yangi qiymatlar farqi (diff)
- Telefon raqamlar `changes` da maskalanadi
- Audit loglar o'chirilmaydi (immutable)

### 4.5 O'chirish cheklovlari

- Foydalanuvchi o'chirishdan oldin uning barcha aktiv mehmon ruxsatnomalari bekor qilinadi
- `super_admin` rolini faqat boshqa `super_admin` o'chira oladi
- O'zini o'chira olmaydi

### 4.6 Tashkilot boshqaruvi

- `bsk` tipidagi tashkilotga bino tayinlanishi mumkin
- `prosecutor` va `iiv` tipidagi tashkilotlar uchun SOATO kodi majburiy
- Tashkilot o'chirishdan oldin unga tegishli barcha foydalanuvchilar boshqa tashkilotga ko'chirilishi shart

---

## 5. Error kodlar

| HTTP Status | Error Code | Tavsif |
|-------------|------------|--------|
| 400 | `VALIDATION_ERROR` | Noto'g'ri ma'lumotlar |
| 400 | `WEAK_PASSWORD` | Parol talablarga mos kelmaydi |
| 400 | `PASSWORD_RECENTLY_USED` | Bu parol yaqinda ishlatilgan |
| 400 | `CANNOT_CHANGE_OWN_ROLE` | O'z rolini o'zgartira olmaysiz |
| 400 | `CANNOT_DELETE_SELF` | O'zini o'chira olmaysiz |
| 400 | `ORG_HAS_USERS` | Tashkilotda foydalanuvchilar bor |
| 409 | `LOGIN_TAKEN` | Bu login band |
| 409 | `PHONE_TAKEN` | Bu telefon raqam band |
| 403 | `FORBIDDEN` | Ruxsat yo'q |
| 403 | `CANNOT_MANAGE_HIGHER_ROLE` | Yuqoriroq roldagi foydalanuvchini boshqara olmaysiz |
| 404 | `USER_NOT_FOUND` | Foydalanuvchi topilmadi |
| 404 | `ORGANIZATION_NOT_FOUND` | Tashkilot topilmadi |
| 404 | `BUILDING_NOT_FOUND` | Ko'rsatilgan bino topilmadi |

---

## 6. TypeScript interfeyslari

```typescript
// ============================================
// User
// ============================================

type UserRole =
  | "super_admin"
  | "bsk_admin"
  | "operator"
  | "gasn"
  | "construction"
  | "prosecutor"
  | "iiv";

type UserStatus = "active" | "blocked" | "deleted";

interface UserBuilding {
  id: number;
  name: string;
  address?: string;
  terminals_count?: number;
}

interface UserOrganization {
  id: number;
  name: string;
  type: OrganizationType;
  logo_url?: string | null;
}

interface UserSummary {
  id: number;
  login: string;
  full_name: string;
  role: UserRole;
  status: UserStatus;
  organization: UserOrganization;
  buildings: UserBuilding[];
  last_login_at: string | null;
  created_at: string;
  is_2fa_enabled: boolean;
}

interface UserDetail extends UserSummary {
  phone_masked: string;
  login_attempts: number;
  last_login_ip: string | null;
  updated_at: string;
  created_by: {
    id: number;
    full_name: string;
  };
}

// ============================================
// Requests
// ============================================

interface CreateUserRequest {
  login: string;
  full_name: string;
  phone: string;
  role: UserRole;
  organization_id: number;
  building_ids: number[];
  password: string;
  is_2fa_enabled?: boolean;
}

interface UpdateUserRequest {
  full_name?: string;
  phone?: string;
  organization_id?: number;
}

interface UpdateUserStatusRequest {
  status: "active" | "blocked";
  reason?: string;
}

interface UpdateUserBuildingsRequest {
  building_ids: number[];
}

interface ResetPasswordRequest {
  new_password: string;
  force_change_on_login?: boolean;
}

// ============================================
// Organization
// ============================================

type OrganizationType =
  | "bsk"
  | "gasn"
  | "construction"
  | "prosecutor"
  | "iiv"
  | "other";

interface Organization {
  id: number;
  name: string;
  type: OrganizationType;
  soato_code: string | null;
  logo_url: string | null;
  users_count: number;
  buildings_count: number;
  is_active: boolean;
  created_at: string;
}

interface CreateOrganizationRequest {
  name: string;
  type: OrganizationType;
  soato_code?: string;
  logo?: File; // multipart
}

// ============================================
// Audit Log
// ============================================

type AuditEntityType =
  | "user"
  | "resident"
  | "building"
  | "terminal"
  | "guest_pass"
  | "organization";

type AuditAction =
  | "create"
  | "update"
  | "delete"
  | "block"
  | "transfer"
  | "restore";

interface AuditLogChanges {
  [field: string]: {
    old: unknown;
    new: unknown;
  };
}

interface AuditLog {
  id: number;
  user: {
    id: number;
    full_name: string;
    role: UserRole;
  };
  entity_type: AuditEntityType;
  entity_id: number;
  entity_name: string;
  action: AuditAction;
  changes: AuditLogChanges | null;
  ip_address: string;
  user_agent: string;
  created_at: string;
}

interface AuditLogStats {
  period: string;
  total_actions: number;
  by_action: Record<AuditAction, number>;
  by_entity: Record<AuditEntityType, number>;
  most_active_users: Array<{
    user_id: number;
    full_name: string;
    action_count: number;
  }>;
}

// ============================================
// Query Params
// ============================================

interface UsersQueryParams extends PaginationParams {
  search?: string;
  role?: string;
  status?: string;
  organization_id?: number;
  sort?: string;
}

interface AuditLogsQueryParams extends PaginationParams {
  user_id?: number;
  entity_type?: AuditEntityType;
  action?: AuditAction;
  date_from?: string;
  date_to?: string;
}
```

---

## 7. Frontend eslatmalari

### 7.1 Foydalanuvchi yaratish forma

- Rol tanlanganda shu rolga mos maydonlar ko'rsatiladi:
  - `prosecutor` / `iiv` tanlansa: "2FA majburiy" xabari va `is_2fa_enabled` avtomatik belgilanadi
  - `gasn` / `construction` tanlansa: parol talablari oddiy bo'ladi
- Tashkilot ro'yxati rolga qarab filtrlanadi (prosecutor rol tanlansa faqat prosecutor tashkilotlar)
- Binolar multi-select (bino tanlanganda terminal soni ham ko'rsatiladi)

### 7.2 Rol ikonkalari va ranglar

| Rol | Rang | Tavsif |
|-----|------|--------|
| `super_admin` | Qoramtir binafsha | Toj ikonkasi |
| `bsk_admin` | Ko'k | Qalqon ikonkasi |
| `operator` | Yashil | Tishli g'ildirak ikonkasi |
| `gasn` | To'q sariq | Ko'z ikonkasi |
| `construction` | Apelsin | Quruvchi ikonkasi |
| `prosecutor` | Qizil | Hujjat ikonkasi |
| `iiv` | To'q ko'k | Nishon ikonkasi |

### 7.3 Audit log ko'rinishi

- `changes` maydoni bo'lsa "diff" formatda ko'rsatish: ~~eski qiymat~~ → yangi qiymat
- Juda ko'p o'zgarishlar bo'lsa accordion bilan yig'ish
- `delete` amali qizil belgilangan, `create` yashil

### 7.4 Tashkilot boshqaruvi

- Faqat `super_admin` uchun ko'rinadigan menyu bo'limi
- Tashkilot logosi: drag-and-drop yoki oddiy fayl tanlash
- Logo: `jpg`, `png`, `webp` formatlari, max 2MB

### 7.5 Ruxsatlar nazorati (frontend)

- Frontend ham ruxsatlarni tekshirishi kerak (faqat vizual uchun — asosiy himoya backendda)
- Ruxsat yo'q tugmalar `disabled` yoki yashiriladi
- Boshqa operatorning bino/foydalanuvchisini ko'rish urinishida 403 kelsa — "Ruxsat yo'q" sahifasiga yo'naltirish
