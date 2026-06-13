# 01 — AUTENTIFIKATSIYA (Admin)

> Admin panel JWT autentifikatsiyasi: login, refresh, logout, current user.

---

## 1. LOGIN

### `POST /api/v1/auth/login`

Admin login + parol bilan kirish.

#### Request
```http
POST /api/v1/auth/login
Content-Type: application/json
```

```json
{
  "login": "admin@powersun.uz",
  "password": "MySecure!Pass123",
  "remember_me": true
}
```

#### Validatsiya
| Field | Rules |
|-------|-------|
| `login` | required, string, 3–100 chars |
| `password` | required, string, 8–100 chars |
| `remember_me` | bool, default false (true → refresh TTL 30d, false → 7d) |

#### Response (200)
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "Bearer",
    "expires_in": 900,
    "admin": {
      "id": 1,
      "name": "Aliyev Vali",
      "login": "admin@powersun.uz",
      "role": "superadmin",
      "status": "active"
    }
  }
}
```

#### Xatoliklar

**401 — login/parol noto'g'ri:**
```json
{
  "success": false,
  "error": {
    "code": 401,
    "type": "INVALID_CREDENTIALS",
    "message": "Login yoki parol noto'g'ri"
  }
}
```

**403 — admin nofaol:**
```json
{
  "success": false,
  "error": {
    "code": 403,
    "type": "FORBIDDEN",
    "message": "Akkaunt nofaol holatda. Superadmin bilan bog'laning"
  }
}
```

**429 — juda ko'p urinish:**
```json
{
  "success": false,
  "error": {
    "code": 429,
    "type": "TOO_MANY_REQUESTS",
    "message": "Juda ko'p noto'g'ri urinish. 5 daqiqadan keyin urinib ko'ring",
    "details": {"retry_after": 300}
  }
}
```

---

## 2. REFRESH TOKEN

### `POST /api/v1/auth/refresh`

Access token muddati o'tganda yangi juftlik olish.

#### Request
```http
POST /api/v1/auth/refresh
Content-Type: application/json
```

```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

> ⚠️ **Token rotation:** Eski `refresh_token` darhol Redis blacklist'ga qo'shiladi. Faqat yangi juftlikni ishlating.

#### Xatoliklar

**401 — refresh token yaroqsiz/blacklisted:**
```json
{
  "success": false,
  "error": {
    "code": 401,
    "type": "UNAUTHORIZED",
    "message": "Refresh token yaroqsiz. Qaytadan login qiling"
  }
}
```

---

## 3. LOGOUT

### `POST /api/v1/auth/logout`

Joriy access + refresh tokenlarni blacklist'ga qo'shish.

#### Request
```http
POST /api/v1/auth/logout
Authorization: Bearer {access_token}
Content-Type: application/json
```

```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Response (204)
```http
HTTP/1.1 204 No Content
```

---

## 4. CURRENT USER

### `GET /api/v1/admin/me`

Joriy admin ma'lumotlari (page reload paytida ishlatiladi).

#### Request
```http
GET /api/v1/admin/me
Authorization: Bearer {access_token}
```

#### Response (200)
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Aliyev Vali",
    "login": "admin@powersun.uz",
    "role": "superadmin",
    "status": "active",
    "permissions": [
      "installations.view",
      "installations.approve",
      "installations.reject",
      "withdrawals.view",
      "withdrawals.approve",
      "withdrawals.mark_paid",
      "users.view",
      "users.block",
      "users.pin_reset",
      "catalog.manage",
      "settings.manage",
      "admins.manage",
      "logs.view"
    ],
    "created_at": "2026-01-15T08:30:00Z",
    "last_login_at": "2026-04-18T13:25:00Z"
  }
}
```

#### Xatoliklar

**401 — access token muddati o'tgan:**
```json
{
  "success": false,
  "error": {
    "code": 401,
    "type": "UNAUTHORIZED",
    "message": "Token muddati o'tgan",
    "details": {"reason": "TOKEN_EXPIRED"}
  }
}
```

→ Frontend `refresh` endpointiga so'rov yuborib, qaytadan urinib ko'radi.

---

## 5. PAROLNI O'ZGARTIRISH

### `PUT /api/v1/admin/me/password`

#### Request
```http
PUT /api/v1/admin/me/password
Authorization: Bearer {access_token}
```

```json
{
  "old_password": "OldPass123",
  "new_password": "NewSecure!Pass456",
  "new_password_confirm": "NewSecure!Pass456"
}
```

#### Validatsiya
| Field | Rules |
|-------|-------|
| `old_password` | required, mavjud parol bilan mos |
| `new_password` | required, min 8, regex: kamida 1 katta + 1 raqam + 1 maxsus belgi |
| `new_password_confirm` | required, `new_password` ga teng |

#### Response (200)
```json
{
  "success": true,
  "message": "Parol muvaffaqiyatli yangilandi. Qaytadan login qiling."
}
```

> ⚠️ Parol yangilangach, **barcha** mavjud tokenlar blacklist'ga qo'shiladi. Frontend foydalanuvchini login sahifasiga yo'naltiradi.

---

## 6. JWT TOKEN STRUKTURASI

### Access Token (15 daqiqa)
```json
{
  "iss": "powersun.uz",
  "aud": "admin",
  "sub": 1,
  "iat": 1735689600,
  "exp": 1735690500,
  "jti": "uuid-v4",
  "name": "Aliyev Vali",
  "role": "superadmin"
}
```

### Refresh Token (7 kun, remember_me bilan 30 kun)
```json
{
  "iss": "powersun.uz",
  "aud": "refresh",
  "sub": 1,
  "iat": 1735689600,
  "exp": 1736294400,
  "jti": "uuid-v4",
  "type": "refresh"
}
```

> 🔒 Algoritm: `HS256`. Secret `.env` da `JWT_SECRET` (256-bit random).

---

## 7. FRONTEND IMPLEMENTATSIYA NAMUNASI

### Axios interceptor (auto-refresh)
```typescript
import axios from 'axios';

const api = axios.create({ baseURL: 'https://api.powersun.uz' });

// Request interceptor: token qo'shish
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Response interceptor: 401 → refresh
let isRefreshing = false;
let failedQueue: any[] = [];

api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config;
    if (error.response?.status === 401 && !original._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then(() => api(original));
      }

      original._retry = true;
      isRefreshing = true;

      try {
        const { data } = await axios.post('/api/v1/auth/refresh', {
          refresh_token: localStorage.getItem('refresh_token'),
        });
        localStorage.setItem('access_token', data.data.access_token);
        localStorage.setItem('refresh_token', data.data.refresh_token);
        failedQueue.forEach((p) => p.resolve());
        failedQueue = [];
        return api(original);
      } catch (err) {
        failedQueue.forEach((p) => p.reject(err));
        failedQueue = [];
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(err);
      } finally {
        isRefreshing = false;
      }
    }
    return Promise.reject(error);
  }
);

export default api;
```
