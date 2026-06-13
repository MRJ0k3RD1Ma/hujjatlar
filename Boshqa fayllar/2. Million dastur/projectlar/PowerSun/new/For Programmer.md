# 🛠️ POWER SUN v2.1 — DASTURCHILAR UCHUN TEXNIK TOPSHIRIQ

> **Maqsad:** Mijoz uchun yozilgan funksional talablarni texnik arxitektura, API dizayni, DB mapping, xavfsizlik qoidalari va implementatsiya qadamlariga o‘girish.  
> **Auditoriya:** Backend (Yii2), Frontend (React), DevOps, QA muhandislari  
> **Versiya:** 2.1 (Developer Release)

---

## 1. ARXITEKTURA VA TEXNOLOGIK STEK

| Qatlam | Texnologiya | Versiya | Izoh |
|--------|-------------|---------|------|
| **Backend** | PHP 8.1+ / Yii2 Advanced Template | `yiisoft/yii2 ~2.0.50` | REST API + Bot Webhook + Queue Worker |
| **Frontend** | React 18 / Vite / Ant Design 5 | `vite@5`, `antd@5` | SPA, JWT auth, React Router v6 |
| **Database** | MySQL 8.0+ | `InnoDB`, `utf8mb4`, `ROW_FORMAT=DYNAMIC` | Transactional, FK strict, JSON validatsiya |
| **Cache/State** | Redis 7+ | `yii2-redis` | Bot dialog state, rate limiting, queue driver |
| **File Storage** | Cloudinary | `cloudinary_php ~2.0` | Rasmlar/video optimizatsiya, auto-format |
| **Auth** | JWT | `firebase/php-jwt` | Access: 15m, Refresh: 7d, HTTP-only cookie yoki localStorage |
| **Server** | Nginx + PHP-FPM + Systemd | Ubuntu 22.04+ | Reverse proxy, gzip/brotli, logrotate |
| **Queue** | `yii2-queue` (Redis/DB) | ~2.3 | Telegram notification retry, cron fallback |

---

## 2. LOYIHA STRUKTURASI

```
powersun/
├── common/          # Umumiy modellar, validators, helpers, enums, traits
├── api/             # Telegram bot webhook + public API endpoints
├── backend/         # Admin/React API + JWT auth + RBAC
├── console/         # Yii2 commands, queue workers, backup scripts, cron jobs
├── frontend/        # React.js SPA (Vite build)
├── environments/    # dev / prod configs
└── vendor/          # Composer dependencies
```

> 💡 **Split recommendation:** `api` moduli bot va ochiq so‘rovlar uchun, `backend` moduli admin panel API uchun. `common` da ActiveRecord modellari va biznes mantiq yagona bo‘ladi.

---

## 3. DB → YII2 ACTIVE RECORD MAPPING

| Jadval | Model | Asosiy Relations | Muhim Eslatma |
|--------|-------|------------------|---------------|
| `users` | `User` | `hasMany(Installation)`, `hasMany(WithdrawalRequest)` | `card_number` yo‘q. `pin_hash` (bcrypt). Holat Redis da boshqariladi. |
| `inverters` | `Inverter` | `hasMany(Installation)` | `points_per_unit` → snapshot yoziladi |
| `materials` | `Material` | `hasMany(InstallationMaterial)` | `unit` ENUM → UI da tarjima qilinadi |
| `installations` | `Installation` | `belongsTo(User)`, `belongsTo(Inverter)`, `hasMany(InstallationMaterial)`, `hasMany(Payment)` | `paid_amount` meros. Asosiy balans `withdrawal_requests` orqali |
| `installation_materials` | `InstallationMaterial` | `belongsTo(Installation)`, `belongsTo(Material)` | `points_earned` yaratilishda hisoblanadi, keyin o‘zgarmaydi |
| `withdrawal_requests` | `WithdrawalRequest` | `belongsTo(User)`, `belongsTo(Admin)` | `status` FSM: `pending → approved → paid` |
| `installation_status_history` | `StatusHistory` | `belongsTo(Installation)`, `belongsTo(Admin)` | Notification retry queue bilan bog‘liq |
| `settings` | `Setting` | Key-Value pattern (`Yii::$app->cache`) | `point_value`, `min_withdrawal_som` dinamik o‘qiladi |

### 🔹 Balans Hisoblash (Backend Helper)
```php
public static function getAvailableBalance(int $userId): float
{
    $earned = (new Query())
        ->select('COALESCE(SUM(total_amount), 0)')
        ->from('installations')
        ->where(['user_id' => $userId, 'status' => ['approved', 'paid']])
        ->scalar();

    $withdrawn = (new Query())
        ->select('COALESCE(SUM(amount_som), 0)')
        ->from('withdrawal_requests')
        ->where(['user_id' => $userId, 'status' => ['approved', 'paid']])
        ->scalar();

    return max(0, $earned - $withdrawn);
}
```

---

## 4. API SPECIFIKATSIYASI

### 📦 Standart Javob Format
```json
// Muvaffaqiyatli
{"success": true, "data": {...}, "message": "Operation successful"}

// Xatolik
{"success": false, "error": {"code": 422, "message": "Validation failed", "details": {"card_number": ["Format noto'g'ri"]}}}
```

### 🔑 Autentifikatsiya
- `POST /api/v1/auth/login` → `{access_token, refresh_token, expires_in}`
- `POST /api/v1/auth/refresh` → yangi juftlik qaytaradi, eski refresh token revoke qilinadi
- `Authorization: Bearer <access_token>` barcha admin so‘rovlarida majburiy

### 📡 Asosiy Endpointlar

| Method | URL | Vazifa | Auth |
|--------|-----|--------|------|
| `POST` | `/api/v1/bot/webhook` | Telegram payload qabul qilish | ❌ (Secret Token header) |
| `GET` | `/api/v1/bot/balance` | Usta balansini qaytarish | ✅ (User JWT/Session) |
| `POST` | `/api/v1/bot/withdraw` | Yangi chiqim so‘rovi yaratish (PIN majburiy) | ✅ |
| `POST` | `/api/v1/bot/pin/set` | PIN o‘rnatish/yangilash (eski PIN bo‘lsa tasdiqlash) | ✅ |
| `POST` | `/api/v1/bot/pin/verify` | PIN tekshirish (lockout bilan) | ✅ |
| `POST` | `/api/v1/bot/pin/reset-request` | PIN reset so‘rovi yaratish | ✅ |
| `PUT` | `/api/v1/admin/users/{id}/pin-reset` | Admin tomonidan PIN reset | ✅ Admin |
| `GET` | `/api/v1/admin/installations` | Arizalar ro‘yxati (filter, pagination) | ✅ Admin |
| `PUT` | `/api/v1/admin/installations/{id}/approve` | Tasdiqlash + balansga qo‘shish | ✅ Admin |
| `PUT` | `/api/v1/admin/installations/{id}/reject` | Rad etish (`reject_reason` majburiy) | ✅ Admin |
| `GET` | `/api/v1/admin/withdrawals` | Chiqim so‘rovlari ro‘yxati | ✅ Admin |
| `PUT` | `/api/v1/admin/withdrawals/{id}/approve` | So‘rovni tasdiqlash | ✅ Admin |
| `PUT` | `/api/v1/admin/withdrawals/{id}/mark-paid` | To‘lov yakunlandi → `paid` | ✅ Admin |
| `POST` | `/api/v1/admin/inverters` | Invertor CRUD | ✅ Superadmin |
| `POST` | `/api/v1/admin/materials` | Material CRUD | ✅ Superadmin |
| `GET` | `/api/v1/health` | DB/Redis/Disk status | ❌ |

---

## 5. ASOSIY BIZNES MANTIQ IMPLEMENTATSIYASI

### 🔹 1. Ariza Yaratish & Snapshot
```php
public function beforeValidate()
{
    if (parent::beforeValidate()) {
        $inverter = Inverter::findOne($this->inverter_id);
        $pointValue = Setting::getValue('point_value');

        $this->points_per_unit_snapshot = $inverter->points_per_unit;
        $this->base_points = $inverter->points_per_unit * $this->inverter_count;
        // material_bonus_points InstallationMaterial::save() da hisoblanadi
        $this->total_points = $this->base_points + $this->material_bonus_points;
        $this->point_value_snapshot = $pointValue;
        $this->total_amount = $this->total_points * $pointValue;
        return true;
    }
    return false;
}
```
> ⚠️ `material_bonus_points` alohida `InstallationMaterial` yozuvlari saqlanganda `SUM(points_earned)` sifatida hisoblanadi va `beforeSave()` da `installations` jadvalida yangilanadi.

### 🔹 2. Chiqim So‘rovi (Race Condition Himoya)
```php
public static function createRequest(int $userId, float $amount, string $card, string $holder): WithdrawalRequest
{
    $db = Yii::$app->db;
    $transaction = $db->beginTransaction();
    try {
        // 1. Balansni lock qilish
        $balance = (new Query())->select('available_balance')->from('v_user_balance')->where(['user_id' => $userId])->scalar();
        if ($amount > $balance) throw new BadRequestHttpException('Balans yetarli emas');

        // 2. So‘rov yaratish
        $req = new self();
        $req->attributes = [
            'user_id' => $userId,
            'points_amount' => (int)($amount / Setting::getValue('point_value')),
            'amount_som' => $amount,
            'card_number' => $card,
            'card_holder_name' => $holder,
            'status' => 'pending'
        ];
        if (!$req->save()) throw new Exception('Save failed: ' . implode(', ', $req->getFirstErrors()));

        $transaction->commit();
        return $req;
    } catch (\Exception $e) {
        $transaction->rollBack();
        throw $e;
    }
}
```

### 🔹 3. PIN Service (Set / Verify / Lockout)

```php
namespace common\services;

use Yii;
use yii\base\UserException;
use common\models\User;

class PinService
{
    private const WEAK_PINS = ['0000','1111','2222','3333','4444','5555',
        '6666','7777','8888','9999','1234','4321','1212','0123'];

    public static function setPin(User $user, string $newPin, ?string $oldPin = null): void
    {
        self::validateFormat($newPin);
        if ($user->pin_hash !== null) {
            if ($oldPin === null || !password_verify($oldPin, $user->pin_hash)) {
                throw new UserException('Eski PIN noto‘g‘ri');
            }
        }
        $user->pin_hash = password_hash($newPin, PASSWORD_BCRYPT);
        $user->pin_attempts = 0;
        $user->pin_locked_until = null;
        $user->pin_set_at = date('Y-m-d H:i:s');
        if (!$user->save(false)) {
            throw new \RuntimeException('PIN saqlashda xatolik');
        }
    }

    public static function verify(User $user, string $pin): bool
    {
        if ($user->pin_hash === null) {
            throw new UserException('PIN o‘rnatilmagan. /set_pin orqali o‘rnating');
        }
        if ($user->pin_locked_until !== null && strtotime($user->pin_locked_until) > time()) {
            $left = ceil((strtotime($user->pin_locked_until) - time()) / 60);
            throw new UserException("PIN bloklangan. {$left} daqiqadan keyin urinib ko‘ring");
        }

        if (password_verify($pin, $user->pin_hash)) {
            $user->updateAttributes(['pin_attempts' => 0, 'pin_locked_until' => null]);
            return true;
        }

        $maxAttempts = (int)Setting::getValue('pin_max_attempts', 3);
        $lockoutMin  = (int)Setting::getValue('pin_lockout_minutes', 30);
        $attempts    = $user->pin_attempts + 1;

        $updates = ['pin_attempts' => $attempts];
        if ($attempts >= $maxAttempts) {
            $updates['pin_locked_until'] = date('Y-m-d H:i:s', time() + $lockoutMin * 60);
            $updates['pin_attempts'] = 0;
            $user->updateAttributes($updates);
            throw new UserException("PIN {$maxAttempts} marta noto‘g‘ri kiritildi. {$lockoutMin} daqiqa bloklandi");
        }
        $user->updateAttributes($updates);
        return false;
    }

    private static function validateFormat(string $pin): void
    {
        $len = (int)Setting::getValue('pin_length', 4);
        if (!preg_match("/^\d{{$len}}$/", $pin)) {
            throw new UserException("PIN aniq {$len} ta raqamdan iborat bo‘lishi kerak");
        }
        if (in_array($pin, self::WEAK_PINS, true)) {
            throw new UserException('PIN juda oson. Boshqa kombinatsiya tanlang');
        }
        if (preg_match('/^(\d)\1+$/', $pin)) {
            throw new UserException('PIN bir xil raqamlardan iborat bo‘lmasligi kerak');
        }
    }
}
```

> ⚠️ **Bot xavfsizligi:** PIN matnli xabarni qabul qilgandan so‘ng `Telegram::deleteMessage($chatId, $messageId)` orqali **darhol o‘chirilishi shart**. Aks holda PIN Telegram chat tarixida qoladi.

### 🔹 4. Withdraw Flow PIN Integratsiyasi

```php
public function actionConfirmWithdraw($pin)
{
    $user = $this->getCurrentUser();
    if (!PinService::verify($user, $pin)) {
        $left = (int)Setting::getValue('pin_max_attempts', 3) - $user->pin_attempts;
        return ['ok' => false, 'message' => "❌ Noto‘g‘ri PIN. Qolgan urinishlar: {$left}"];
    }

    $state = Yii::$app->redis->get("bot:state:{$user->telegram_id}");
    $data  = json_decode($state, true)['data'] ?? null;
    if (!$data) throw new BadRequestHttpException('Sessiya muddati o‘tgan');

    $req = WithdrawalRequest::createRequest(
        $user->id, $data['amount'], $data['card'], $data['holder']
    );
    Yii::$app->redis->del("bot:state:{$user->telegram_id}");
    return ['ok' => true, 'request_id' => $req->id];
}
```

### 🔹 5. Karta Validatsiyasi (Luhn + BIN)

```php
public function rules()
{
    return [
        [['card_number'], 'match', 'pattern' => '/^\d{16}$/'],
        [['card_number'], 'validateLuhn'],
        [['card_number'], 'function' => function ($attr) {
            $prefix = substr($this->$attr, 0, 4);
            if (!in_array($prefix, ['8600', '9860', '4', '5'])) {
                $this->addError($attr, 'Faqat Uzcard, HUMO, Visa yoki Mastercard qabul qilinadi.');
            }
        }],
    ];
}
```

---

## 6. TELEGRAM BOT ARXITEKTURASI

### 🔹 Webhook Handler (`api/controllers/BotController`)
```php
public function actionWebhook()
{
    $secret = Yii::$app->request->getHeaders()->get('X-Telegram-Bot-Api-Secret-Token');
    if ($secret !== Yii::$app->params['telegram']['webhook_secret']) {
        throw new ForbiddenHttpException('Invalid webhook secret');
    }

    $update = json_decode(Yii::$app->request->getRawBody(), true);
    Yii::$app->queue->push(new ProcessTelegramUpdate(['update' => $update]));
    return ['ok' => true]; // 200 OK darhol qaytarish majburiy
}
```

### 🔹 Redis State Machine
- Key: `bot:state:{telegram_id}`
- TTL: 24 soat
- Payload: `{"step": "app_materials_select", "data": {"inverter_id": 5, "count": 2}, "expires_at": 1735689600}`
- Har bir qadamda `step` validatsiyasi qilinadi. Timeout yoki `/cancel` da `DEL` qilinadi.

### 🔹 Notification Queue
```php
// Queue Job: SendTelegramNotification
public function execute($queue)
{
    try {
        Telegram::sendMessage(['chat_id' => $this->chatId, 'text' => $this->text]);
        $this->history->updateStatus('sent');
    } catch (\Throwable $e) {
        $this->history->updateStatus('failed', $e->getMessage());
        // Retry 3 marta, keyin o'chiriladi yoki DLQ ga tushadi
    }
}
```

---

## 7. XAVFSIZLIK QOIDALARI

| Qoida | Implementatsiya |
|-------|-----------------|
| **JWT Refresh Rotation** | Har `refresh` da yangi juftlik, eski token `blacklist` Redis da saqlanadi |
| **Rate Limiting** | `yii\filters\RateLimiter` (IP bazida 60 req/min, auth endpoint 10 req/min) |
| **CORS** | Faqat `VITE_API_URL` da ko‘rsatilgan domen ruxsat etiladi |
| **Karta Ma’lumotlari** | UI da `substr_replace($card, '****', 4, 8)`, loglarda ham xuddi shu format, raw DB da saqlansa `AES_ENCRYPT` tavsiya |
| **Optimistic Lock** | `installations.version` har `update` da `version = version + 1`, xatolikda `StaleObjectException` |
| **Input Sanitization** | `yii\helpers\Html::encode()`, `yii\validators\*` majburiy, raw SQL faqat `yii\db\Query` orqali |
| **PIN Storage** | `users.pin_hash` bcrypt (cost=12), raw PIN hech qayerda log/cache da saqlanmaydi |
| **PIN Lockout** | 3 noto‘g‘ri urinish → 30 daqiqa block. Sozlamalardan boshqariladi (`pin_max_attempts`, `pin_lockout_minutes`) |
| **Bot PIN Hygiene** | PIN matnli xabarni Telegram'dan `deleteMessage` orqali darhol o‘chirish majburiy |
| **Weak PIN** | `0000`, `1234`, `1111` kabi oson PIN-lar `PinService::validateFormat()` da rad etiladi |

---

## 8. TESTLASH STRATEGIYASI

| Turi | Vosita | Qamrov |
|------|--------|--------|
| **Unit** | PHPUnit, Codeception | Modellar, validators, hisoblash formulalari, Luhn |
| **Integration** | Codeception, REST module | API endpoints, DB transactions, auth flow |
| **E2E (Bot)** | Mock Telegram API, `webhook-tester` | `/new`, `/withdraw`, state machine, notification retry |
| **E2E (Admin)** | Cypress / Playwright | Login, dashboard, approve/reject, withdrawal approval |
| **Coverage** | `pcov` / `xdebug` | Minimal 80%, critical logic 100% |

---

## 9. CI/CD & DEPLOYMENT

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql: { image: mysql:8.0, env: { MYSQL_ROOT_PASSWORD: test }, ports: ["3306:3306"] }
      redis: { image: redis:7, ports: ["6379:6379"] }
    steps:
      - uses: actions/checkout@v4
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with: { php-version: '8.1', extensions: mbstring, intl, pdo_mysql }
      - run: composer install --no-interaction --prefer-dist
      - run: php vendor/bin/codecept run unit,integration
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@v1
        with: { host: ${{ secrets.VPS_IP }, username: deploy, key: ${{ secrets.SSH_KEY }, script: |
            cd /var/www/powersun
            git pull origin main
            composer install --no-dev --optimize-autoloader
            php yii migrate --interactive=0
            php yii queue/run --verbose=1
            systemctl restart php-fpm nginx
        }}
```

---

## 10. KRITIKAL ESLATMALAR (BUG PREVENTION)

| Muammo | Yechim |
|--------|--------|
| **Balans race condition** | `SELECT ... FOR UPDATE` yoki DB `v_user_balance` view + queue serialization |
| **Snapshot buzilishi** | `installations.total_points/amount` faqat `create` da hisoblanadi, `update` da `readonly` qilinadi |
| **Bot timeout** | Webhook handler 200 OK darhol qaytaradi, og‘ir jarayonlar `yii2-queue` da |
| **Karta shifrlash** | Production da `card_number` ni `yii\security\EncryptByKey` yoki AWS KMS/Hashicorp Vault bilan saqlash |
| **Redis state sync** | Har bir qadamda `SETEX`, tugallanganda `DEL`. Crash bo‘lsa TTL avtomatik tozalaydi |
| **Notification failed** | `installation_status_history.notification_status = failed` → cron `yii queue/retry` har 5 daqiqada |

---

## 11. RIVOJLANTIRISH QOIDALARI (CODE STYLE)

- **PHP:** PSR-12, `declare(strict_types=1)`, type-hinting, `@throws` annotation
- **Yii2:** `behaviors()` da `TimestampBehavior`, `BlameableBehavior`, `SoftDeleteBehavior` (kerak bo‘lsa)
- **React:** Functional components, `React.memo`, custom hooks, `axios` interceptor for JWT refresh, ESLint + Prettier
- **Git:** Conventional Commits (`feat:`, `fix:`, `chore:`), PR required, squash merge
- **Env:** Barcha secretlar `.env`, `config/params.php` da `env()` orqali o‘qiladi

---

## ✅ DASTURCHI QABUL QILISH MEZONLARI (CHECKLIST)

- [ ] Barcha jadval `database.sql` ga mos, FK va indexlar mavjud
- [ ] `installations.total_points/amount` yaratilganda snapshotlanadi, keyin o‘zgarmaydi
- [ ] `WithdrawalRequest::create()` transaction + balance check + Luhn validation + PIN verify
- [ ] PIN bcrypt hash, weak PIN rad etiladi, lockout (3 urinish → 30 daq) ishlaydi
- [ ] Bot PIN xabari `deleteMessage` orqali darhol o‘chiriladi
- [ ] Bot webhook 200 OK < 5s, queue bilan async processing
- [ ] Redis state TTL 24h, idempotent step handling
- [ ] JWT access 15m, refresh 7d, rotation + blacklist
- [ ] Karta raqami UI/log da `****1234`, raw DB da saqlansa encrypt
- [ ] Notification retry queue + `notification_status` tracking
- [ ] Unit/Integration test coverage ≥ 80%
- [ ] CI/CD pipeline o‘tgan, staging da deploy muvaffaqiyatli

---

> 📌 **Eslatma:** Ushbu hujjat `v2.1` mijoz spec va `database.sql` asosida tuzilgan. Har qanday biznes mantiq o‘zgarishi avval schema/API impact analysis qilinib, keyin implement qilinadi.  
> 🔗 **Manbalar:** `database.sql`, `Texnik topshiriq.md (v2.1)`, Yii2 Docs, React Docs, Telegram Bot API Docs, PCI-DSS Guidelines.

Agar kerak bo‘lsa, quyidagilarni alohida generatsiya qilishim mumkin:
1. `common/models/` Active Record klasslari + relations
2. `backend/controllers/` & `api/controllers/` to‘liq endpoint kodlari
3. React `src/api/`, `src/pages/`, `src/components/` strukturasi
4. `yii2-queue` job klasslari va cron konfiguratsiyasi
5. Docker-compose + Nginx config production ready