# RFC-001: Autentifikatsiya Tizimi — BSK FaceID

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 001 |
| **Modul** | Autentifikatsiya, sessiyalar, rollar |
| **Holat** | Draft |
| **Sana** | 2026-03-17 |
| **Muallif** | Frontend team |
| **Backend** | PHP / Yii2 team |

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

---

## 1. Umumiy ko'rinish

Tizim **Telefon raqami + Parol** asosida autentifikatsiya qiladi. Parolni tiklash va 2FA uchun **SMS OTP** ishlatiladi. Barcha foydalanuvchilar 7 ta roldan biriga ega bo'ladi. Terminal qurilmalar alohida **API key** autentifikatsiyasidan foydalanadi.

### 1.1 Autentifikatsiya strategiyasi

| Tizim | Metod | Token |
|-------|-------|-------|
| Web Panel (admin/operator) | Phone + Password | JWT access + refresh token |
| Prokuratura / IIV | Phone + Password + 2FA OTP | JWT access + refresh token |
| Terminal qurilmasi | API Key + Serial Number | Statik API key (rotatsiya bilan) |

### 1.2 SMS Provider

**Eskiz.uz** yoki **Play Mobile** — O'zbekiston SMS provayderlari.

- OTP kodi: 6 xonali, 2 daqiqa amal qiladi
- Bir raqamga soatiga max 5 ta SMS

---

## 2. API Endpointlar

### 2.1 Login (Kirish)

**`POST /api/v1/auth/login`**

Telefon raqami + parol bilan tizimga kirish.

**Request:**

```json
{
  "phone": "+998901234567",
  "password": "SecurePass123!"
}
```

**Response (200 OK) — oddiy rollar:**

```json
{
  "success": true,
  "message": "Muvaffaqiyatli kirdingiz",
  "data": {
    "user": {
      "id": 1,
      "phone_masked": "+998 90 *** 12 34",
      "full_name": "Karimov Sardor",
      "role": "bsk_admin",
      "organization": {
        "id": 5,
        "name": "Chilonzor BSK",
        "type": "management_company"
      },
      "last_login_at": "2026-03-15T09:30:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
      "access_expires_in": 900,
      "refresh_expires_in": 86400
    },
    "requires_2fa": false
  }
}
```

**Response (200 OK) — Prokuratura / IIV (2FA talab qilinadi):**

```json
{
  "success": true,
  "data": {
    "requires_2fa": true,
    "phone_masked": "+998 90 *** 12 34",
    "otp_session": "otp_sess_abc123xyz",
    "expires_in": 120
  }
}
```

**Biznes qoidalar:**
- Telefon raqami `+998` bilan boshlanishi kerak, 12 raqam
- 5 marta noto'g'ri parol → 15 daqiqa bloklanish (`failed_login_attempts`, `locked_until` DB da)
- `prosecutor` va `iiv` rollari uchun har doim 2FA majburiy
- `user_status: blocked` bo'lsa → `403 USER_BLOCKED`
- Muvaffaqiyatli kirishda `last_login_at` yangilanadi

---

### 2.2 OTP yuborish (Parol tiklash yoki 2FA)

**`POST /api/v1/auth/send-otp`**

**Request:**

```json
{
  "phone": "+998901234567",
  "purpose": "PASSWORD_RESET"
}
```

**`purpose` qiymatlari (DB `otp_purpose` ENUM dan):**
- `PASSWORD_RESET` — parolni tiklash
- `LOGIN_VERIFY` — 2FA kirish tasdiqlash
- `PHONE_CONFIRM` — telefon tasdiqlash (yangi foydalanuvchi)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Tasdiqlash kodi yuborildi",
  "data": {
    "phone_masked": "+998 90 *** 12 34",
    "expires_in": 120,
    "retry_after": 60
  }
}
```

---

### 2.3 OTP tasdiqlash

**`POST /api/v1/auth/verify-otp`**

**Request (2FA uchun):**

```json
{
  "otp_session": "otp_sess_abc123xyz",
  "code": "482916",
  "purpose": "LOGIN_VERIFY"
}
```

**Request (parol tiklash uchun):**

```json
{
  "phone": "+998901234567",
  "code": "482916",
  "purpose": "PASSWORD_RESET"
}
```

**Response (200 OK) — 2FA muvaffaqiyatli:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "phone_masked": "+998 90 *** 12 34",
      "full_name": "Toshmatov Akbar",
      "role": "prosecutor",
      "organization": {
        "id": 12,
        "name": "Yunusobod tumani prokuraturasi",
        "type": "prokuratura"
      }
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "refresh_token": "bmV3IHJlZnJlc2ggdG9r...",
      "access_expires_in": 900,
      "refresh_expires_in": 86400
    }
  }
}
```

**Response (200 OK) — parol tiklash tasdiq:**

```json
{
  "success": true,
  "data": {
    "reset_token": "rst_tok_xyz789abc",
    "expires_in": 600
  }
}
```

**Biznes qoidalar:**
- Maksimal 3 ta noto'g'ri urinish → kod bloklangan
- Kod 2 daqiqa amal qiladi
- Faqat 1 marta ishlatilishi mumkin
- `phone_hash` bo'yicha `otp_codes` jadvalidan tekshiriladi

---

### 2.4 Yangi parol o'rnatish

**`POST /api/v1/auth/reset-password`**

**Request:**

```json
{
  "reset_token": "rst_tok_xyz789abc",
  "new_password": "NewSecurePass456!",
  "new_password_confirm": "NewSecurePass456!"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Parol muvaffaqiyatli yangilandi"
}
```

**Parol talablari (backend validatsiyasi):**
- Kamida 8 belgi
- Kamida 1 ta katta harf
- Kamida 1 ta raqam
- Kamida 1 ta maxsus belgi (`!@#$%^&*`)

---

### 2.5 Token yangilash

**`POST /api/v1/auth/refresh`**

**Request:**

```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl..."
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "bmV3IHJlZnJlc2ggdG9r...",
    "access_expires_in": 900,
    "refresh_expires_in": 86400
  }
}
```

**Biznes qoidalar:**
- Refresh token bir martalik (token rotation)
- Eski refresh token qayta ishlatilsa → barcha sessiyalar bekor (`SESSION_REVOKED`)
- Refresh token 24 soat amal qiladi (xavfsizlik sababi — qisqartilgan)

---

### 2.6 Chiqish (Logout)

**`POST /api/v1/auth/logout`**

**Headers:** `Authorization: Bearer <access_token>`

**Request:**

```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl..."
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Muvaffaqiyatli chiqdingiz"
}
```

---

### 2.7 Joriy foydalanuvchi

**`GET /api/v1/auth/me`**

**Headers:** `Authorization: Bearer <access_token>`

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "phone_masked": "+998 90 *** 12 34",
    "full_name": "Karimov Sardor",
    "role": "bsk_admin",
    "organization": {
      "id": 5,
      "name": "Chilonzor BSK",
      "type": "management_company"
    },
    "buildings": [
      { "id": 1, "name": "Chilonzor-14", "address": "Chilonzor, 14-uy" },
      { "id": 2, "name": "Chilonzor-18", "address": "Chilonzor, 18-uy" }
    ],
    "permissions": {
      "can_manage_residents": true,
      "can_manage_terminals": true,
      "can_view_reports": true,
      "can_manage_users": false,
      "can_view_all_buildings": false
    },
    "last_login_at": "2026-03-17T08:45:00Z",
    "created_at": "2025-01-15T10:00:00Z"
  }
}
```

> **Eslatma:** `buildings` — faqat `operator` uchun bitta bino, `bsk_admin` uchun o'z tashkilotining binolari. `gasn`, `prosecutor`, `iiv` uchun — bo'sh `[]` (ular barcha binolarni ko'radi, lekin `user_buildings` orqali emas).

---

### 2.8 Parolni o'zgartirish (kirgan holda)

**`PATCH /api/v1/auth/change-password`**

**Headers:** `Authorization: Bearer <access_token>`

**Request:**

```json
{
  "current_password": "OldPass123!",
  "new_password": "NewPass456!",
  "new_password_confirm": "NewPass456!"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Parol yangilandi. Qayta kiring."
}
```

> Parol o'zgartirilganda barcha joriy sessiyalar bekor qilinadi.

---

## 3. Token strategiyasi

| Parametr | Access Token | Refresh Token |
|----------|-------------|---------------|
| **Muddat** | 15 daqiqa (900s) | 24 soat (86400s) |
| **Format** | JWT (HS256) | Opaque (UUID v4) |
| **Saqlash (frontend)** | Xotirada (React state) | localStorage yoki httpOnly cookie |
| **Saqlash (backend)** | Tekshirilmaydi (stateless) | `users.auth_key` yoki alohida sessions jadval |
| **Yangilash** | Refresh endpoint orqali | Har yangilashda rotate |

### 3.1 JWT Access Token payload

```json
{
  "sub": 1,
  "role": "bsk_admin",
  "org_id": 5,
  "buildings": [1, 2],
  "iat": 1742220000,
  "exp": 1742220900
}
```

> **Eslatma:** Telefon raqami payload ga **kiritilmaydi** (xavfsizlik).

---

## 4. Rollar va huquqlar

### 4.1 Rollar jadvali

| Rol | DB qiymati | Tavsif | 2FA |
|-----|-----------|--------|-----|
| Super Admin | `super_admin` | To'liq tizim boshqaruvi | Ixtiyoriy |
| BSK Admin | `bsk_admin` | O'z tashkiloti binolari | Yo'q |
| Operator | `operator` | Bitta bino boshqaruvi | Yo'q |
| GASN Nazoratchi | `gasn` | Faqat ko'rish (barcha binolar) | Yo'q |
| Qurilish Boshqarma | `construction` | Ko'rish (binolar) | Yo'q |
| Prokuratura | `prosecutor` | So'rov asosida loglar | **Majburiy** |
| IIV | `iiv` | So'rov asosida xavfsizlik logi | **Majburiy** |

### 4.2 Route himoyasi

**Public endpointlar (auth talab qilinmaydi):**

```
POST /api/v1/auth/login
POST /api/v1/auth/send-otp
POST /api/v1/auth/verify-otp
POST /api/v1/auth/reset-password
POST /api/v1/auth/refresh
POST /api/v1/terminals/heartbeat     (Terminal API key bilan)
POST /api/v1/terminals/access-event  (Terminal API key bilan)
POST /api/v1/terminals/sync          (Terminal API key bilan)
```

**Barcha autentifikatsiya qilingan foydalanuvchilar:**

```
GET  /api/v1/auth/me
POST /api/v1/auth/logout
PATCH /api/v1/auth/change-password
GET  /api/v1/access-logs           (filtrlangan — o'z binolari yoki barcha)
GET  /api/v1/reports/dashboard
```

**BSK Admin + Operator:**

```
GET/POST/PATCH/DELETE /api/v1/residents/*
GET/POST/PATCH/DELETE /api/v1/guest-passes/*
GET /api/v1/buildings/*
GET /api/v1/terminals/*
```

**BSK Admin (Operator emas):**

```
POST/PATCH/DELETE /api/v1/buildings/*
POST/PATCH/DELETE /api/v1/terminals/*
GET /api/v1/reports/*
```

**GASN + Construction:**

```
GET /api/v1/buildings
GET /api/v1/buildings/:id
GET /api/v1/terminals
GET /api/v1/access-logs
GET /api/v1/reports/*
```

**Prosecutor + IIV (2FA talab qilinadi):**

```
GET /api/v1/security/logs         (request_document majburiy)
GET /api/v1/access-logs           (filtrlangan, request_document majburiy)
```

**Super Admin:**

```
Barcha yuqoridagi + quyidagilar:
GET/POST/PATCH/DELETE /api/v1/admin/users/*
GET/POST/PATCH/DELETE /api/v1/admin/organizations/*
GET /api/v1/admin/audit-logs
GET /api/v1/admin/security-logs
PATCH /api/v1/admin/settings/*
```

---

## 5. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_PHONE` | Telefon raqami formati noto'g'ri | Validatsiya |
| 400 | `INVALID_PASSWORD_FORMAT` | Parol talablarga javob bermaydi | Parol o'rnatish |
| 400 | `PASSWORDS_DO_NOT_MATCH` | Parollar mos kelmaydi | Tasdiqlash |
| 400 | `INVALID_OTP_PURPOSE` | Noto'g'ri OTP maqsad | Enum to'g'ri emas |
| 400 | `INVALID_CODE` | OTP kod noto'g'ri | Noto'g'ri kod |
| 400 | `CODE_EXPIRED` | OTP kod muddati tugagan | 2 daqiqadan keyin |
| 400 | `CODE_ALREADY_USED` | Kod allaqachon ishlatilgan | Qayta ishlatish |
| 400 | `INVALID_RESET_TOKEN` | Tiklash tokeni noto'g'ri | Noto'g'ri token |
| 401 | `WRONG_PASSWORD` | Parol noto'g'ri | Login |
| 401 | `USER_NOT_FOUND` | Foydalanuvchi topilmadi | Login |
| 401 | `TOKEN_EXPIRED` | Access token muddati tugagan | JWT exp |
| 401 | `TOKEN_INVALID` | Token noto'g'ri | JWT sign xato |
| 401 | `REFRESH_TOKEN_INVALID` | Refresh token topilmadi | Noto'g'ri token |
| 401 | `SESSION_REVOKED` | Sessiya bekor (theft detection) | Dublikat refresh |
| 401 | `TWO_FA_REQUIRED` | 2FA talab qilinadi | Prosecutor/IIV |
| 403 | `USER_BLOCKED` | Foydalanuvchi bloklangan | Admin bloklagan |
| 403 | `ACCOUNT_LOCKED` | Akkaunt vaqtincha bloklangan | 5 marta xato |
| 429 | `TOO_MANY_ATTEMPTS` | OTP urinishlari tugadi (3/3) | 3 ta xato |
| 429 | `SMS_RATE_LIMIT` | SMS limiti oshdi | 5 dan ko'p/soat |
| 429 | `RETRY_TOO_SOON` | Qayta yuborish uchun kutish | 60 soniya |
| 429 | `LOGIN_RATE_LIMIT` | Login urinishlari oshdi | 5 marta/15 daqiqa |

---

## 6. TypeScript interfeyslar

```typescript
// ============================================
// Request types
// ============================================

interface LoginRequest {
  phone: string;       // "+998XXXXXXXXX"
  password: string;
}

interface SendOtpRequest {
  phone: string;
  purpose: "PASSWORD_RESET" | "LOGIN_VERIFY" | "PHONE_CONFIRM";
}

interface VerifyOtpRequest {
  otp_session?: string;    // 2FA uchun
  phone?: string;          // Parol tiklash uchun
  code: string;            // 6 xonali
  purpose: "PASSWORD_RESET" | "LOGIN_VERIFY";
}

interface ResetPasswordRequest {
  reset_token: string;
  new_password: string;
  new_password_confirm: string;
}

interface RefreshTokenRequest {
  refresh_token: string;
}

interface LogoutRequest {
  refresh_token: string;
}

interface ChangePasswordRequest {
  current_password: string;
  new_password: string;
  new_password_confirm: string;
}

// ============================================
// Response types
// ============================================

interface AuthUser {
  id: number;
  phone_masked: string;           // "+998 90 *** 12 34"
  full_name: string;
  role: UserRole;
  organization: {
    id: number;
    name: string;
    type: string;
  } | null;
  buildings: {
    id: number;
    name: string;
    address: string;
  }[];
  permissions: UserPermissions;
  last_login_at: string | null;
  created_at: string;
}

interface UserPermissions {
  can_manage_residents: boolean;
  can_manage_terminals: boolean;
  can_view_reports: boolean;
  can_manage_users: boolean;
  can_view_all_buildings: boolean;
}

interface AuthTokens {
  access_token: string;
  refresh_token: string;
  access_expires_in: number;   // 900 (soniyalarda)
  refresh_expires_in: number;  // 86400 (soniyalarda)
}

interface LoginData {
  user: AuthUser;
  tokens: AuthTokens;
  requires_2fa: false;
}

interface Login2FARequired {
  requires_2fa: true;
  phone_masked: string;
  otp_session: string;
  expires_in: number;
}

interface VerifyOtpLoginData {
  user: AuthUser;
  tokens: AuthTokens;
}

interface VerifyOtpResetData {
  reset_token: string;
  expires_in: number;   // 600 soniya
}

interface SendOtpData {
  phone_masked: string;
  expires_in: number;   // 120 soniya
  retry_after: number;  // 60 soniya
}

// ============================================
// JWT Payload
// ============================================

interface JwtPayload {
  sub: number;           // user.id
  role: UserRole;
  org_id: number | null;
  buildings: number[];   // kirish huquqi bor binolar ID si
  iat: number;
  exp: number;
}
```

---

## 7. Ketma-ketlik diagrammasi

### 7.1 Oddiy login oqimi

```
Foydalanuvchi       Frontend          Backend          SMS
     |                  |                |               |
     |-- Login forma -->|                |               |
     |                  |-- POST /login->|               |
     |                  |               |-- Parol tekshir|
     |                  |               |-- JWT yaratish |
     |                  |<-- 200 + JWT--|               |
     |                  |-- JWT xotirada|               |
     |<-- Dashboard -----|               |               |
```

### 7.2 Prokuratura/IIV 2FA oqimi

```
Foydalanuvchi       Frontend          Backend          SMS
     |                  |                |               |
     |-- Login forma -->|                |               |
     |                  |-- POST /login->|               |
     |                  |               |-- requires_2fa |
     |                  |<-- 200 + sess-|               |
     |                  |-- OTP kodi -->|               |
     |                  |               |-- SMS yuborish>|
     |                  |               |<-- OK ---------|
     |<-- SMS keldi -----|               |               |
     |-- 6 raqam --->   |               |               |
     |                  |-POST /verify->|               |
     |                  |               |-- Kod tekshir  |
     |                  |               |-- Audit log    |
     |                  |<-- 200 + JWT--|               |
     |<-- Dashboard -----|               |               |
```

### 7.3 Token yangilash oqimi

```
Frontend                        Backend
   |                               |
   |-- API so'rov (expired) ------>|
   |<-- 401 TOKEN_EXPIRED ---------|
   |                               |
   |-- POST /auth/refresh -------->|
   |                               |-- Refresh tekshir
   |                               |-- Eski o'chir
   |                               |-- Yangi juftlik
   |<-- 200 + yangi tokenlar ------|
   |                               |
   |-- Dastlabki so'rov qayta ---->|
   |<-- 200 OK --------------------|
```

---

## 8. Frontend uchun eslatmalar

1. **Telefon input:** `+998 (XX) XXX-XX-XX` formatda mask. Serverga `+998XXXXXXXXX` yuboriladi.

2. **Parol kuchi indikatori:** Zaif/O'rtacha/Kuchli. Kuchli bo'lmasa yuborish bloklanadi.

3. **Login blok:** 5 ta xato → frontend tomonda ham countdown timer ko'rsatish (`locked_until` dan hisoblanadi).

4. **2FA OTP input:** 6 ta alohida input box. Oxirgi raqam kiritilganda avtomatik verify.

5. **Token saqlash:**
   - Access token → React state / Zustand store (localStorage emas!)
   - Refresh token → `httpOnly` cookie (backend bilan kelishiladi) yoki localStorage

6. **Axios interceptor:** `401 TOKEN_EXPIRED` → refresh endpoint → qayta so'rov. Refresh ham muvaffaqiyatsiz → `/login` ga redirect.

7. **Prosecutor/IIV paneli:** Kirish uchun hujjat raqami kiritish shakli ko'rsatiladi (har bir so'rov uchun `request_document` talab qilinadi).
