# 08 — TELEGRAM BOT WEBHOOK

> Telegram serveri bizning Backend'ga qanday so'rov yuboradi va biz qanday javob qaytaramiz.

---

## 1. WEBHOOK O'RNATISH

> ⚠️ Bot tokeni `.env` da: `TELEGRAM_BOT_TOKEN`. Webhook secret: `TELEGRAM_WEBHOOK_SECRET` (random 64 char).

### Bir martalik o'rnatish (deploy paytida)
```bash
curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://api.powersun.uz/api/v1/bot/webhook",
    "secret_token": "abc123_random_64_char_secret",
    "allowed_updates": ["message", "callback_query", "edited_message"],
    "drop_pending_updates": false
  }'
```

### Yii2 console buyrug'i (tavsiya)
```bash
php yii bot/set-webhook
php yii bot/delete-webhook   # disable
php yii bot/webhook-info     # status
```

---

## 2. WEBHOOK ENDPOINT

### `POST /api/v1/bot/webhook`

Telegram serveri har bir Update'ni shu URL'ga POST qiladi.

#### Request headerlar
```http
POST /api/v1/bot/webhook HTTP/1.1
Host: api.powersun.uz
Content-Type: application/json
X-Telegram-Bot-Api-Secret-Token: abc123_random_64_char_secret
```

> 🔒 Backend birinchi navbatda `X-Telegram-Bot-Api-Secret-Token` headerini tekshiradi. Mos kelmasa → `403 Forbidden`.

#### Request body — `Update` obyekti
Telegram Update Schema: <https://core.telegram.org/bots/api#update>

#### Response (200) — har doim
```json
{"ok": true}
```

> ⚠️ Telegram **5 sekund** ichida 200 OK kutadi. Aks holda webhook qayta yuboriladi (4–5 marta retry).
> Shuning uchun Backend faqat `Update`'ni Redis Queue'ga push qiladi va darhol javob qaytaradi. Asosiy ishlov **`ProcessTelegramUpdate`** Job'ida bajariladi.

---

## 3. UPDATE TURLARI VA NAMUNALAR

### 3.1 Matnli xabar
```json
{
  "update_id": 100001,
  "message": {
    "message_id": 50,
    "from": {
      "id": 123456789,
      "is_bot": false,
      "first_name": "Abdulloh",
      "last_name": "Ismoilov",
      "username": "abdulloh_ism",
      "language_code": "uz"
    },
    "chat": {
      "id": 123456789,
      "first_name": "Abdulloh",
      "last_name": "Ismoilov",
      "type": "private"
    },
    "date": 1735689600,
    "text": "/start"
  }
}
```

### 3.2 Telefon raqam (contact share)
```json
{
  "update_id": 100002,
  "message": {
    "message_id": 51,
    "from": {"id": 123456789, "first_name": "Abdulloh"},
    "chat": {"id": 123456789, "type": "private"},
    "date": 1735689700,
    "contact": {
      "phone_number": "+998901234567",
      "first_name": "Abdulloh",
      "user_id": 123456789
    }
  }
}
```

### 3.3 Geolokatsiya
```json
{
  "update_id": 100003,
  "message": {
    "message_id": 52,
    "from": {"id": 123456789, "first_name": "Abdulloh"},
    "chat": {"id": 123456789, "type": "private"},
    "date": 1735689800,
    "location": {
      "latitude": 41.32,
      "longitude": 69.25
    }
  }
}
```

### 3.4 Rasm (photo)
```json
{
  "update_id": 100004,
  "message": {
    "message_id": 53,
    "from": {"id": 123456789, "first_name": "Abdulloh"},
    "chat": {"id": 123456789, "type": "private"},
    "date": 1735689900,
    "photo": [
      {"file_id": "AgACAgIA...small", "file_unique_id": "uniq1", "width": 90, "height": 67, "file_size": 1500},
      {"file_id": "AgACAgIA...med", "file_unique_id": "uniq2", "width": 320, "height": 240, "file_size": 12000},
      {"file_id": "AgACAgIA...large", "file_unique_id": "uniq3", "width": 1280, "height": 960, "file_size": 250000}
    ],
    "caption": "Yaqindan ko'rinish"
  }
}
```

> 📌 `photo` massivining oxirgi (eng katta) elementi olinadi → `getFile` orqali yuklab olinadi → Cloudinary'ga upload qilinadi.

### 3.5 Video
```json
{
  "update_id": 100005,
  "message": {
    "message_id": 54,
    "from": {"id": 123456789, "first_name": "Abdulloh"},
    "chat": {"id": 123456789, "type": "private"},
    "date": 1735690000,
    "video": {
      "duration": 45,
      "width": 720,
      "height": 1280,
      "mime_type": "video/mp4",
      "file_id": "BAACAgIA...",
      "file_unique_id": "uniqvid",
      "file_size": 4500000
    }
  }
}
```

> ⚠️ Validatsiya: `duration ≤ 60`, `file_size ≤ 50 MB`. Aks holda bot xabar beradi: "Video 1 daqiqadan ko'p emas".

### 3.6 Inline tugma bosish (callback query)
```json
{
  "update_id": 100006,
  "callback_query": {
    "id": "cb_xyz123",
    "from": {"id": 123456789, "first_name": "Abdulloh"},
    "message": {
      "message_id": 55,
      "chat": {"id": 123456789, "type": "private"},
      "date": 1735690100,
      "text": "Invertor modelini tanlang:"
    },
    "data": "inverter:5"
  }
}
```

> 📌 `data` payload formati: `{action}:{value}` — masalan `inverter:5`, `confirm:yes`, `cancel`.

---

## 4. BACKEND → TELEGRAM API

Backend `https://api.telegram.org/bot{TOKEN}/{method}` ga so'rov yuboradi.

### 4.1 Matnli xabar yuborish
```http
POST https://api.telegram.org/bot{TOKEN}/sendMessage
Content-Type: application/json
```

```json
{
  "chat_id": 123456789,
  "text": "✅ Arizangiz qabul qilindi! ID: #1234",
  "parse_mode": "HTML",
  "reply_markup": {
    "inline_keyboard": [
      [{"text": "📋 Ko'rish", "callback_data": "view:1234"}]
    ]
  }
}
```

#### Response (Telegram)
```json
{
  "ok": true,
  "result": {
    "message_id": 56,
    "chat": {"id": 123456789, "type": "private"},
    "date": 1735690200,
    "text": "✅ Arizangiz qabul qilindi! ID: #1234"
  }
}
```

### 4.2 Xabarni o'chirish (PIN xavfsizligi uchun)
```http
POST https://api.telegram.org/bot{TOKEN}/deleteMessage
```

```json
{
  "chat_id": 123456789,
  "message_id": 56
}
```

> 🔐 PIN matnli xabarni qabul qilgach, **darhol** ushbu metod chaqirilishi shart.

### 4.3 Inline klaviatura
```json
{
  "chat_id": 123456789,
  "text": "Invertor modelini tanlang:",
  "reply_markup": {
    "inline_keyboard": [
      [{"text": "Deye SUN-12K", "callback_data": "inverter:5"}],
      [{"text": "Huawei SUN2000-15K", "callback_data": "inverter:8"}],
      [{"text": "❌ Bekor qilish", "callback_data": "cancel"}]
    ]
  }
}
```

### 4.4 Reply klaviatura (telefon share)
```json
{
  "chat_id": 123456789,
  "text": "📞 Telefon raqamingizni yuboring:",
  "reply_markup": {
    "keyboard": [
      [{"text": "📱 Telefonni ulashish", "request_contact": true}]
    ],
    "resize_keyboard": true,
    "one_time_keyboard": true
  }
}
```

### 4.5 Klaviatura olib tashlash
```json
{
  "chat_id": 123456789,
  "text": "Davom etamiz...",
  "reply_markup": {"remove_keyboard": true}
}
```

### 4.6 Faylni yuklab olish (rasm/video)
```http
GET https://api.telegram.org/bot{TOKEN}/getFile?file_id=AgACAgIA...
```

#### Response
```json
{
  "ok": true,
  "result": {
    "file_id": "AgACAgIA...",
    "file_unique_id": "uniq3",
    "file_size": 250000,
    "file_path": "photos/file_42.jpg"
  }
}
```

#### Faylni yuklab olish
```http
GET https://api.telegram.org/file/bot{TOKEN}/photos/file_42.jpg
```

→ Backend faylni yuklab olib Cloudinary'ga upload qiladi.

### 4.7 Callback query'ga javob (loading spinneri yo'qolishi uchun)
```http
POST https://api.telegram.org/bot{TOKEN}/answerCallbackQuery
```

```json
{
  "callback_query_id": "cb_xyz123",
  "text": "✅ Tanlandi",
  "show_alert": false
}
```

> ⚠️ Har bir callback_query'ga **albatta** javob qaytarilishi kerak (Telegram talabi).

---

## 5. RATE LIMIT (Telegram tomonidan)

| Limit | Qiymat |
|-------|--------|
| 1 chat'ga | 1 msg/sec |
| Bot umumiy | 30 msg/sec |
| Group chat | 20 msg/min |

> 📌 Backend `yii2-queue` orqali ketma-ketlik saqlaydi. 429 javob kelsa → exponential backoff retry.

---

## 6. WEBHOOK XATOLIKLAR

### Telegram qaytaradigan xatoliklar:

| Code | Description | Action |
|------|-------------|--------|
| 400 | Bad Request: chat not found | User log'dan o'chirilgan, `users.status = blocked` qilish |
| 403 | Forbidden: bot was blocked by the user | Bot bloklangan, notification to'xtatish |
| 403 | Forbidden: user is deactivated | User Telegram'dan o'chirgan |
| 429 | Too Many Requests | Retry-After ga qarab kutib turish |
| 500 | Internal Server Error | 30s kutish va retry |

### Backend response (Telegram'ga):
```json
{"ok": true}
```

> ⚠️ Hatto ichki xatolik bo'lsa ham, Telegram'ga **har doim** `200 OK + {"ok":true}` qaytariladi. Aks holda webhook 4-5 marta qayta yuboriladi va dublikat ariza kelishi mumkin.

---

## 7. IDEMPOTENT ISHLOV

`update_id` har Update uchun unikal. Backend Redis'da saqlaydi:
```
SETNX bot:processed:{update_id} 1 EX 86400
```

Agar `SETNX` muvaffaqiyatsiz → bu Update allaqachon ishlov berilgan → skip.

---

## 8. SECRET TOKEN VALIDATSIYASI (PHP namunasi)

```php
namespace api\controllers;

use Yii;
use yii\rest\Controller;
use yii\web\ForbiddenHttpException;

class BotController extends Controller
{
    public function actionWebhook()
    {
        $secret = Yii::$app->request->getHeaders()->get('X-Telegram-Bot-Api-Secret-Token');
        $expected = Yii::$app->params['telegram']['webhook_secret'];

        if (!hash_equals($expected, (string)$secret)) {
            Yii::warning('Invalid webhook secret', 'bot');
            throw new ForbiddenHttpException();
        }

        $update = json_decode(Yii::$app->request->getRawBody(), true);
        if (!$update || !isset($update['update_id'])) {
            return ['ok' => true]; // noto'g'ri payload — sukut
        }

        // Idempotency
        $key = "bot:processed:{$update['update_id']}";
        if (!Yii::$app->redis->set($key, 1, 'EX', 86400, 'NX')) {
            return ['ok' => true]; // allaqachon ishlov berilgan
        }

        // Queue ga push (5s timeout sababli)
        Yii::$app->queue->push(new \api\jobs\ProcessTelegramUpdate(['update' => $update]));

        return ['ok' => true];
    }
}
```

---

## 9. DEV MUHITDA POLLING (webhook o'rniga)

Production webhook talab qiladi (HTTPS). Dev'da `ngrok` yoki polling:

```bash
php yii bot/poll
```

Bu buyruq `getUpdates` orqali Telegram'dan Update'larni oladi va ichki webhook handlerni chaqiradi (xuddi production kabi).

```php
// console/controllers/BotController::actionPoll()
public function actionPoll()
{
    $offset = 0;
    while (true) {
        $updates = Telegram::getUpdates(['offset' => $offset, 'timeout' => 30]);
        foreach ($updates as $update) {
            (new \api\controllers\BotController())->processUpdate($update);
            $offset = $update['update_id'] + 1;
        }
    }
}
```
