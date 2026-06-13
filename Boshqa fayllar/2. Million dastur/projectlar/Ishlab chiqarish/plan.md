# NazoratPos — Ko'p Tashkilot SaaS Tizim Rebuild Rejasi

## Context (Nima uchun bu ish qilinadi)

Ikki alohida loyiha mavjud:

- `D:\php\dilmurod\autoservice` — Yii2 monolit, bir filial uchun biznes tizimi (sklad, sotuv, Paid da fiskal fieldlari bor lekin integratsiya yo'q)
- `D:\php\dilmurod\auto_remote` — Yii2 REST API v1 + React frontend, markaziy monitoring (admin, branch, payment, region, district, snapshot — region/district SOATO seed bilan)
- `D:\php\dilmurod\autoservice\electron-soliq\` — Electron 35 + Unikassa API tayyor (sendSale/openZReport/POS printer)

**Maqsad:** ikkalasini yagona SaaS tizimga birlashtirish:

- Superadmin `admin` jadvalida (auto_remote dan)
- Tashkilotlar o'zi `/register` orqali ro'yxatdan o'tadi (region/district tanlab) → superadmin tasdiqlaydi
- Yagona DB, row-level tenancy (har business jadvalda `branch_id`)
- Har tashkilot NazoratPos ga kirib 4 ta asosiy modul bilan ishlaydi: **Sklad, Sotuv, Ishlab chiqarish, Buyurtmalar**
- Sotuv Unikassa fiskal cheki bilan yakunlanadi
- Mijoz tomonidagi ishlar faqat **Electron.js** dasturi ichida ishlaydi
- Superadmin barcha tashkilotlarning umumlashgan ma'lumotini bitta joyda ko'radi
- **Bosh egasi (owner) portali:** bitta shaxs 3-4 biznesga ega bo'lsa, bitta telefon+parol bilan kirib hamma biznesini ko'radi (faqat ko'rish). Biznesda ish qilish uchun esa aynan shu filialga berilgan username+password bilan Electron dasturiga kiradi

**Scope'dan CHIQARILADI:** HR (Employee, Attendance, Device, FaceSync), Ta'mirlash (Visit, avtoservis vizitlari), Forniture, Email/SMTP — bularni eski `autoservice` da qoldirib yuboriladi yoki umuman qo'shilmaydi.

## Texnik shartlar (yakuniy)

1. **Backend:** Yii2 advanced (allaqachon `D:\php\dilmurod\NazoratPos\backend\` ga o'rnatilgan)
2. **Frontend:** React.js (shablonlar foydalanuvchi tomonidan beriladi)
3. **Electron.js:** faqat Unikassa bilan ishlash va chek chop etish funksiyalari uchun (fiskal IPC + POS printer). Biznes logikasi hammasi frontend+backend tomonida, Electron faqat native bridge
4. **Backend modullari:** `backend/modules/v1/superadmin/`, `backend/modules/v1/admin/`, `backend/modules/v1/owner/`, `backend/modules/v1/public/` — har birida alohida Swagger
5. **UI shablonlar:** foydalanuvchi tomonidan taqdim etiladi

## Foydalanuvchi tanlovlari (tasdiqlangan)

1. **Stack:** Yii2 backend + React (Vite) frontend
2. **Sklad:** Klassik multi-warehouse (har branch ichida)
3. **Fiskal:** Unikassa API, backend faqat **yozib olish** qiladi, chek yuborish Electron ichida amalga oshadi
4. **Registratsiya:** Ochiq /register + admin approve; **email va SMS tasdiqlash YO'Q**; tashkilot egasi +998 telefon raqami bilan kiritiladi (format tekshiriladi, qolgan qism validatsiya qilinmaydi)
5. **DB:** Yagona DB, row-level tenancy (`branch_id` har business jadvalda)
6. **User model:** `admin` (platforma) + `user` (tashkilot xodimlari) — ikkita jadval
7. **Domain:** Domen foydalanuvchi tomonidan olinadi (tasdiqlashda belgilanadi)
8. **Scope:** Faqat Sklad, Sotuv, Ishlab chiqarish, Buyurtmalar, Unikassa, Admin panel
9. **Email/SMTP:** Kerak emas. Admin tasdiqlaganda login credentials egasiga qo'lda yetkaziladi
10. **Plan struktura:** `auto_remote` dagi `plan` jadvalidan o'zgarmay ishlatiladi (name, price, duration_days, max_users, max_products, features JSON, is_active, sort_order)
11. **To'lovlar:** Payme API integratsiya + qo'lda kiritish (naqd, bank o'tkazmasi, CLICK)
12. **Pilot tashkilot:** Superadmin panel orqali o'zi qo'lda qo'shadi
13. **Electron:** Faqat Windows, auto-update bor

## Asosiy qaror: yangi monorepo

Barcha kodlar `D:\php\dilmurod\NazoratPos\` ichiga yoziladi. Auto_remote backendini asos qilib, autoservice dan faqat biznes logika ko'chirib olinadi, HR/Ta'mirlash olib tashlanadi. Electron dastur alohida build target. Ushbu reja fayli (plan.md) va keyingi barcha hujjatlar `D:\php\dilmurod\NazoratPos\docs\` papkasiga joylanadi — loyiha start bo'lgach, birinchi qadamda bu fayl nusxalab qo'yiladi va o'sha yerda davom qiladi.

```text
D:\php\dilmurod\NazoratPos\
├── backend\          # Yii2 advanced (auto_remote dan kengaygan)
├── admin-panel\      # React, browser (admin.nazoratpos.uz) — superadmin
├── owner-portal\     # React, browser (me.nazoratpos.uz) — biznes egasi bir telefon+parol bilan
                      #   hamma biznesini ko'radi (READ-ONLY dashboard)
├── app-electron\     # React + Electron packaging — tashkilot xodimi uchun (faqat Electron, Windows)
├── public-web\       # React (statik) — landing + /register (browser)
├── shared-ui\        # @nazoratpos/ui paket (Radix+Tailwind kitini panel lar o'rtasida ulashadi)
└── docs\             # plan.md (bu fayl ko'chiriladi), api-reference.md,
                      # fiscal-spec.md, payme-integration.md, migration-notes.md,
                      # deployment-guide.md
```

---

## 1. Arxitektura

### 1.1 Tenant scoping (row-level)

Har business jadvalda `branch_id INT NOT NULL` FK. Backend `TenantContext` service — JWT claim'dan `branch_id` o'qib oladi, `TenantScopeBehavior` ActiveQuery ga avtomatik `WHERE branch_id = :bid` qo'shadi. Admin JWT da `branch_id=null` — scope ishlamaydi, lekin admin controllers explicit `?branch_id=X` filter bilan ishlaydi.

**Himoya qatlamlari:**

- `TenantScopeBehavior` — har modelda
- `BaseController` — `beforeAction` da tenantContext set qiladi
- Write endpointlarda DTO ichida `branch_id` bo'lsa, JWT.branch_id bilan kross-tekshirish; mos kelmasa 403
- Cross-tenant id injection (user Sale id 99 ko'rsa, u boshqa branch niki bo'lsa) → auto 404

### 1.2 Client architecture

**Admin panel (`admin.nazoratpos.uz`, browser):**

- Superadmin (admin jadval) kiradi
- Barcha branchlar ro'yxati, registratsiyalar, to'lovlar, tariflar, umumlashgan hisobot
- Region/district CRUD, audit

**Owner portal (`me.nazoratpos.uz`, browser, YANGI):**

- **Bosh egasi** (owner jadvali) telefon+parol bilan kiradi
- Agar o'zi bitta nechta biznesga egalik qilsa (owner_branch orqali), login dan keyin "Mening biznesim" ro'yxatini ko'radi
- Har biri bo'yicha kirib umumiy dashboard (bugungi sotuv, qoldiq qiymati, orderlar, top mahsulot, fiskal summary) — **faqat ko'rish**
- Write, edit, sale, sklad harakati yo'q
- Ichkarida ishlash uchun "Filialda ishlash" tugmasi → NazoratPos ilovasini ochish va u yerda alohida filial username+password bilan kirish

**App (Electron, tashkilot xodimlari uchun):**

- React ilova Electron ichida bundle qilingan
- **Username + password per-branch** bilan kiradi (aynan shu filialga berilgan credentials)
- Owner telefon+paroli bu yerda ishlamaydi — alohida login
- Serverga `GET/POST /api/v1/app/*` chaqiradi
- POS + Fiskal + Printer `electronSoliq` IPC orqali
- **Browser dan ochilmaydi** — `window.electronSoliq` bo'lmasa app ishlamaydi, login ekranida "Faqat NazoratPos ilovasida ishlaydi" xabari

**Public web (`nazoratpos.uz`, browser):**

- Landing, /register (tashkilot ro'yxatdan o'tish), /login yo'naltirish: owner portaliga yoki Electron ilovasini yuklash

**Eslatma:** default printer qidirish va saqlash:

- Electron: `app.getPath('userData')/config.json` faylga yozib qo'yiladi (masalan `{"default_printer":"POS-80"}`)
- Browser (admin yoki public da qayerdir kerak bo'lsa): `localStorage` (uzoq muddatli saqlash — sessionStorage emas)

### 1.3 Ro'yxatdan o'tish oqimi

Email tasdiqlash yo'q — SMTP server kerak emas. Tashkilot telefon raqami bilan ro'yxatdan o'tadi, SMS tasdiqlash ham yo'q (telefon faqat format tekshirilad). Superadmin approve da 2 xil login credentials belgilanadi:

- **Owner login:** phone + parol (me.nazoratpos.uz uchun) — bu odam bir nechta biznesga ega bo'lsa shu bitta login bilan hammasini ko'radi
- **Branch user login:** username + parol (app-electron uchun) — shu filialda ishlash uchun

```text
1. Tashkilot egasi nazoratpos.uz/register ga kiradi (browser)
2. Form: org_name, inn, owner_name, owner_phone (+998XXXXXXXXX - faqat format, 13 ta belgi),
   owner_email (ixtiyoriy), region_id, district_id, address, plan_id, proposed_username
   Validatsiya: phone regex ^\+998\d{9}$, qolgan ma'lumotlar required
3. POST /api/v1/public/register → registration_request(status=PENDING) yaratiladi
4. Ekranda: "Arizangiz qabul qilindi. Admin tasdiqlagach sizga aloqaga chiqishadi."
   (rate-limit: IP va phone bo'yicha 3/soat)
5. Superadmin admin-panelda /registrations sahifasida ko'radi
6. Superadmin "Tasdiqlash" bosadi, dialogda:
   - Agar shu phone bo'yicha `owner` jadvalida odam bor bo'lsa → mavjud ownerga link qilinadi (yangi biznes qo'shiladi)
   - Yo'q bo'lsa → yangi owner yaratiladi (phone + vaqtinchalik parol)
   - Branch user uchun username + vaqtinchalik parol (yoki auto-generate) belgilaydi
   - Trial kun soni yoki to'liq plan tanlaydi
   Tasdiqlab yuborganda:
   - branch yaratiladi (region_id, district_id, owner_* bilan)
   - owner (yangi bo'lsa) yaratiladi, owner_branch(role=MAIN) link qilinadi
   - Default role seeded (OWNER, CASHIER, WAREHOUSE_KEEPER, TECHNICIAN, ACCOUNTANT)
   - Branch user (OWNER role) yaratiladi — bu user app-electron ga kiradi
   - Default warehouse (MAIN) yaratiladi
   - Default branch_setting satri yaratiladi (bo'sh, keyin tashkilot to'ldiradi)
   - Trial yoki plan bo'yicha subscription boshlanadi
7. Admin tasdiqlash paytida 2 xil credentials ni egasiga qo'lda yetkazadi:
   - Owner: phone (tanish) + password (me.nazoratpos.uz)
   - Branch: username + password (app-electron)
   (WhatsApp/Telegram orqali — admin mas'uliyati)
8. Egasi: me.nazoratpos.uz ga kirib biznesini ko'radi; NazoratPos ilovasini yuklab olib branch credentials bilan kirib ishlaydi
```

**Ikkinchi biznes qo'shish:**

Bosh egasi yangi biznes ochmoqchi bo'lsa:

- Variant A: yana /register orqali o'tadi, shu telefonni kiritadi. Admin approve paytida `owner` jadvalida mavjudligi aniqlanadi → avvalgi owner ga ulanadi
- Variant B: admin to'g'ridan-to'g'ri admin-panel'dan "Branch qo'sh" bilan yangi filial yaratadi va `owner_branch` da mavjud owner ga link qiladi

### 1.4 Mahsulot katalogi (GLOBAL + BRANCH)

Muhim arxitektura tanlov: ikki bosqichli mahsulot tizimi.

**`product_master`** (global, shared):

- Har mahsulot `barcode` bo'yicha unikal (`UNIQUE KEY barcode`)
- Field: `id, barcode, name, mxik_code NULL, mxik_name NULL, package_code NULL, unit_id, photo NULL, verified TINYINT(1), created_by_branch_id, created_at`
- Tashkilot barcode skanner qilib qidiradi → topilsa, shu mahsulotni o'ziga oladi
- Topilmasa, tashkilot yangi barcode bilan kiritadi → `product_master` ga qo'shiladi, `created_by_branch_id=X`
- Superadmin `verified=1` qila oladi (ishonchli manba)
- MXIK kod **majburiy emas** (NULL mumkin). Tashkilot keyinroq to'ldiradi yoki `branch_setting.default_mxik_code` ishlatiladi

**`goods`** (branch-scoped, tashkilot mahsulot ro'yxati):

- Field: `id, branch_id, product_master_id FK, group_id, sale_price, come_price, price_type, vat_percent, is_service, status, created, updated, register_id`
- Tashkilot shu mahsulotga o'z narxini qo'yadi, gruppaga ajratadi
- Aktual qoldiq `goods_warehouse_stock(goods_id, warehouse_id, qty)` da
- Sotuvda/kelishida faqat goods ishlatiladi (product_master faqat ma'lumot manbasi)

**Oqim: Come (kelish) — barcode search:**

```text
1. POS: barcode skanner
2. GET /api/v1/app/product/search?barcode=...
   - product_master dan topadi
   - goods dan (branch_id=X, product_master_id=that) tekshiradi
3. Agar goods bor → existing mahsulotga miqdor qo'shish
4. Agar product_master bor, lekin goods yo'q → "Bu mahsulotni o'z ro'yxatingizga qo'shasizmi?" modal → narx kiriting → goods yaratiladi
5. Agar product_master yo'q → "Yangi mahsulot kiriting" modal → barcode, name, (ixtiyoriy: mxik, package_code, foto) → product_master + goods yaratiladi
6. Qabul qilingan miqdor → ComeProduct + stock_movement(TYPE=COME)
```

### 1.5 Branch sozlamalari (`branch_setting`)

Har branch uchun `branch_setting` jadvalida key/value yoki bitta katta row:

**Tavsiya etilgan strukturasi — bitta row per branch:**

| Field | Maqsad |
|---|---|
| `branch_id` (PK) | Bog'lanish |
| `default_mxik_code` VARCHAR(32) NULL | MXIK yo'q mahsulot sotilganda fiskal chekda ishlatiladi |
| `default_mxik_name` VARCHAR(255) NULL | Default MXIK nomi |
| `default_package_code` VARCHAR(32) NULL | Default paket kodi |
| `default_lat` DECIMAL(10,7) NULL | Fiskal chek `Location.Latitude` uchun |
| `default_lng` DECIMAL(10,7) NULL | Fiskal chek `Location.Longitude` uchun |
| `default_owner_type` VARCHAR(32) NULL | Soliq uchun owner turi (yakka tartibda, OOO, …) |
| `default_name` VARCHAR(255) NULL | `default_owner_type` nomi (masalan "YATT Botirov A.") |
| `default_vat_percent` DECIMAL(5,2) NULL | Default QQS |
| `inn` VARCHAR(20) | Tashkilot INN (branch bilan duplicate bo'lishi mumkin, lekin saxtah uchun) |
| `legal_address` VARCHAR(500) NULL | Huquqiy manzil |
| `phone`, `email`, `website` | Aloqa |
| `logo_path` VARCHAR(500) NULL | Chek bosish uchun |
| `receipt_header`, `receipt_footer` TEXT NULL | Chek shapkasi/futer |
| `default_printer_name` VARCHAR(128) NULL | Server-side persisted printer nomi (Electron local config ham bor, serverda backup) |
| `timezone` VARCHAR(64) DEFAULT 'Asia/Tashkent` | |
| `currency` VARCHAR(3) DEFAULT 'UZS' | |
| `created, updated` | |

**Printer persistence strategiyasi:**

- **Electron** (primary): `app.getPath('userData')/nazoratpos-client.config.json` faylga `{"default_printer":"POS-80","fiscal_terminal_id":1,...}` yozib qo'yadi. Dastur ochilganda local faylni o'qib settings ga qo'yadi. Server-side `branch_setting.default_printer_name` ham sinxronlash (1 kassadan boshqa kassaga o'tganda davom)
- **Browser** (admin panel da printer test uchun): `localStorage.setItem('nazoratpos_printer_default', ...)` (sessionStorage emas — uzoq muddatli)

### 1.6 Fiskal oqimi (API faqat yozib olish, oqim Electron da)

**Muhim:** Backend Unikassa API ga BEVOSITA chaqiruv yubormaydi. Chek yuborish butunlay Electron dasturi ichida:

```text
[Kassachi POS da "Finalize" bosadi]
        │
        ▼
App (Electron) → POST /api/v1/app/sale/{id}/finalize
        │
        ▼
Backend (faqat DB ishi):
  TX start:
    sale DRAFT → FINALIZED
    FiscalService::ensureOpenShift(terminalId)
    StockService::decrease(...)  # stock_movement
    Paid yaratiladi (fiscal_sign=NULL)
    Event SaleFinalized (audit, admin snapshot push)
  TX commit
        │
        ▼
Response: {sale, paid, fiscal_payload — DTO for Unikassa}
        │
        ▼ (Electron renderer)
window.electronSoliq.fiskal.sendSale(fiscal_payload)
        │
        ▼ (Electron main, electron-soliq SoliqService)
Unikassa API https://api.unikassa.uz/api/v1/integrate → response
        │
        ▼
Electron → renderer → PATCH /api/v1/app/paid/{id}/fiscal
body: {fiscal_sign, receipt_seq, terminal_id, qr_code_url, fiscal_datetime,
       request_payload, response_payload}
        │
        ▼
Backend FiscalService::recordReceipt():
  • Paid.fiscal_* update (endpoint faqat yozib oladi)
  • fiscal_receipt audit row (JSON payloadlar bilan)
  • fiscal_shift.total_sales += price
        │
        ▼
Electron → window.electronSoliq.printer.print(receiptBuilder(...))
```

**Fiscal payload qurish** (backend):

- Agar `sale_product.goods.product_master.mxik_code` bor → shu ishlatiladi
- Agar NULL → `branch_setting.default_mxik_code` fallback
- Agar u ham NULL → `FISCAL_ERROR` qaytaradi ("MXIK kod sozlanmagan. Sozlamalarda default_mxik_code ni to'ldiring")
- `Location: {Latitude, Longitude}` → `branch_setting.default_lat/lng`
- `ExtraInfo.TIN` → `branch_setting.inn`

**Offline queue:**

- Electron: IndexedDB `offline_fiscal_queue`, 1 min retry
- Backend: `fiscal_receipt.status='OFFLINE_QUEUED'` bilan mavjud, cron `RetryFiscalJob` har 1 min
- Agar internet yo'q bo'lsa ham Sale finalize backend da davom etadi (stock deducted, paid created). Faqat fiscal_sign NULL qoladi — keyin sync bo'ladi

**Error code handling:** 9021 (duplicate idempotent), 9023 (log + admin notify), 9030 (SHIFT_CLOSED → UI auto-open), 9040 (offline queue), 9090 (manual review).

### 1.7 Multi-warehouse (branch ichida)

Har branch ichida bir nechta sklad, boshqa branchlar bilan aloqasi yo'q:

- `warehouse.branch_id = 5`
- `goods_warehouse_stock(goods_id, warehouse_id)` — ikki jadval ham shu branch
- `stock_movement(branch_id, goods_id, warehouse_id, type, qty_delta, qty_after, ref_type, ref_id, cost, user_id, created_at)`
- Transfer, inventarizatsiya — branch ichida
- Filiallar o'zaro mahsulot almashmaydi (kelajak uchun qo'yilmaydi)

**Race condition himoyasi:** `SELECT … FOR UPDATE` `goods_warehouse_stock(goods_id, warehouse_id)` rowi, Service transaction ichida.

### 1.8 Admin monitoring (umumlashgan)

Admin `admin.mbos.uz` dan barcha tashkilotlar ma'lumotlarini bitta joyda ko'radi:

- **Umumiy KPI dashboard:** bugungi umumiy sotuv (barcha branchlar), eng ko'p savdogar branch, region bo'yicha revenue heatmap, top-10 mahsulot (global product_master bo'yicha), online/offline branchlar soni
- **Branch ro'yxati** filter: region, district, plan, status, online, subscription days left
- **BranchDetail:** shu branch kunlik snapshot, revenue graph, sklad qiymati, fiskal summary, orderlar statistikasi, users ro'yxati
- **Global Product Master:** barcha barcode/nomlar, `verified` flagini qo'yish, `mxik_code` tarqatish (bir tashkilot to'ldirganda boshqalari ham ko'radi)
- **Registrations:** pending, approve/reject
- **Payments:** barcha branchlar to'lovlari
- **Plans, Admins, Notifications, Action Logs, Regions, Districts**

---

## 2. Database — yagona DB

### 2.1 Mavjud (auto_remote dan olinadi, o'zgarmay qoladi)

`admin`, `plan`, `region`, `district`, `payment`, `branch_snapshot`, `branch_order_snapshot`, `branch_revenue_monthly`, `branch_revenue_daily`, `action_log`, `notification`, `setting` (global).

**`payment` jadvaliga qo'shiladi** (plan to'lovi uchun):

- `payment_method ENUM('CASH','CARD','BANK_TRANSFER','CLICK','PAYME','OTHER')` (mavjud, lekin PAYME value to'liq qo'llanadi)
- `payme_transaction_id VARCHAR(64) NULL` — Payme unikal transaction id
- `payme_state INT NULL` — Payme Merchant API holat kodi (1=create, 2=perform, -1=cancel)
- `payme_create_time BIGINT NULL`, `payme_perform_time BIGINT NULL`, `payme_cancel_time BIGINT NULL`
- `payme_reason INT NULL` — cancellation reason code
- `source ENUM('MANUAL','PAYME')` — kim kiritdi
- `entered_by_admin_id` — agar MANUAL bo'lsa, kim admin kiritgan

### 2.2 Mavjudga qo'shiladi

**`branch`** ga:

- `owner_user_id INT FK user(id) NULL`
- `trial_ends_at DATE NULL`
- `status ENUM('PENDING','ACTIVE','SUSPENDED','ARCHIVED')` (mavjud `status TINYINT` o'rniga)
- `registration_ip VARCHAR(45) NULL`

`action_log` ga qo'shimcha action enum turlari.

### 2.3 Yangi jadvallar (business domain)

**User va auth:**

- `user` — `id, branch_id (NOT NULL), username, password_hash, auth_key, name, phone, email, avatar, role_id FK, status, last_login_at, last_login_ip, created, updated` + `UNIQUE(branch_id, username)`, `UNIQUE(branch_id, email)`
- `role` — `id, branch_id NULL (NULL=global template), code, name, is_system, created`
- `permission` — `id, code, group, name` (global)
- `role_permission` — `role_id, permission_id`

**Owner (bosh egasi, me.nazoratpos.uz uchun):**

- `owner` — `id, phone VARCHAR(14) (UNIQUE, +998XXXXXXXXX), password_hash, auth_key, name, email NULL, last_login_at, last_login_ip, status ENUM('ACTIVE','SUSPENDED'), created, updated`
- `owner_branch` — `id, owner_id FK, branch_id FK, role ENUM('MAIN','CO','VIEWER'), added_by_admin_id FK admin, created` + `UNIQUE(owner_id, branch_id)` (bitta owner bitta branch ga bir marta link)

Owner login oqimi:

- `POST /api/v1/owner/auth/login` — phone+password → JWT aud=owner
- `GET /api/v1/owner/branches` — owner_branch orqali shu owner ning branchlari ro'yxati
- `GET /api/v1/owner/branch/{id}/dashboard` — shu branch ning read-only KPI (server-side `branch_id` guard — owner_branch da yoki yo'qligini tekshiradi)
- Write operatsiyalar YO'Q
- `registration_request` — `id, org_name, inn, owner_name, phone VARCHAR(14) (+998 bilan boshlanadi, regex ^\+998\d{9}$), email VARCHAR(255) NULL (ixtiyoriy), region_id, district_id, address, plan_id, proposed_username, status ENUM(PENDING/APPROVED/REJECTED), rejected_reason, approved_by FK admin, approved_at, branch_id NULL, created, ip, user_agent`

**Branch sozlamalari:**

- `branch_setting` — 1.5 dagi field ro'yxati, PK=branch_id

**Sklad:**

- `warehouse` — `id, branch_id, code, name, type ENUM, address, responsible_user_id, is_default, is_active, ...` + `UNIQUE(branch_id, code)`
- `goods_warehouse_stock` — `id, goods_id, warehouse_id, qty DECIMAL(18,3), reserved_qty, avg_cost, last_movement_at` + `UNIQUE(goods_id, warehouse_id)`
- `stock_movement` — `id, branch_id, goods_id, warehouse_id, movement_type ENUM(COME,SALE,RETURN,TRANSFER_OUT,TRANSFER_IN,ADJUSTMENT,PRODUCTION_IN,PRODUCTION_OUT,RESERVE,UNRESERVE), qty_delta, qty_after, ref_type, ref_id, cost, user_id, note, created_at` + `INDEX(branch_id, goods_id, warehouse_id, created_at)`, `INDEX(ref_type, ref_id)`
- `stock_transfer`, `stock_transfer_item` — DRAFT/IN_TRANSIT/COMPLETED/CANCELLED
- `stock_inventory`, `stock_inventory_item` — snapshot + actual + delta + commit

**Mahsulot:**

- `product_master` — `id, barcode (UNIQUE), name, mxik_code NULL, mxik_name NULL, package_code NULL, unit_id, photo, verified TINYINT, created_by_branch_id, created_at, updated_at`
- `goods` — `id, branch_id, product_master_id FK, group_id FK, sale_price, come_price, price_type ENUM(SUM/RATE), vat_percent, is_service TINYINT, status, created, updated, register_id` + `UNIQUE(branch_id, product_master_id)` (agar service bo'lmasa)
- `goods_group` — `id, branch_id, name, parent_id NULL, image, status`
- `goods_unit` — `id, name, code, is_system TINYINT` (global, masalan dona/kg/litr)

**Yetkazuvchi va kelish:**

- `supplier` — `id, branch_id, name, phone, inn, balans, ...`
- `supplier_paid` — `id, branch_id, supplier_id, amount, date, payment_method_id, ...`
- `come` — `id, branch_id, supplier_id, date, total_price, nakladnoy, status, register_id`
- `come_product` — `id, come_id, goods_id, warehouse_id, qty, price, total`
- `supplier_return`, `supplier_return_product` — qaytarish

**Mijoz:**

- `client` — `id, branch_id, name, phone, type_id, balans, debt, credit`
- `client_type` — `id, branch_id, name, status`

**Sotuv:**

- `sale` — `id, branch_id, code, user_id, date, total_price, discount, status ENUM(DRAFT/FINALIZED/CANCELLED/REFUNDED), shift_id FK fiscal_shift NULL, client_id NULL, finalized_at`
- `sale_product` — `id, sale_id, goods_id, warehouse_id, qty, price, total, vat_percent, mxik_used VARCHAR(32) NULL` (fiskal chekda ishlatilgan MXIK)
- `sale_client` — `client_id, sale_id` (many-to-many, odatda 1ta)
- `sale_credit` — qarz boshqaruvi

**To'lov:**

- `paid` — `id, branch_id, sale_id NULL, client_id NULL, supplier_id NULL, amount, payment_method_id, date, shift_id FK fiscal_shift NULL, fiscal_sign VARCHAR(255) NULL, fiscal_receipt_seq INT NULL, fiscal_terminal_id VARCHAR(64) NULL, fiscal_qrcode_url VARCHAR(500) NULL, fiscal_datetime DATETIME NULL, register_id, modify_id, created, updated`
- `payment_method` (was `payment` — rename, `payment` jadval auto_remote'da plan payment) — `id, code, name, is_system`

**Fiskal:**

- `fiscal_terminal` — `id, branch_id, code, name, unikassa_terminal_id, unikassa_login, unikassa_password_encrypted, environment ENUM(PROD/TEST), warehouse_id NULL, is_active`
- `fiscal_shift` — `id, branch_id, terminal_id, opened_by, closed_by, opened_at, closed_at, z_number, total_sales, total_refunds, total_cash, total_card, status ENUM(OPEN/CLOSED/ERRORED)`
- `fiscal_receipt` — `id, branch_id, paid_id, shift_id, terminal_id, receipt_type ENUM(SALE/REFUND/ADVANCE/CREDIT), receipt_seq, fiscal_sign, qr_code_url, fiscal_datetime, request_payload JSON, response_payload JSON, status ENUM(PENDING/SENT/FAILED/OFFLINE_QUEUED), error_code, error_message, retry_count, created_at, sent_at`

**Buyurtmalar:**

- `order` — `id, branch_id, code, client_id, responsible_id, total_price, deposit, date, deadline_date, state ENUM(NEW/CONFIRMED/IN_PRODUCTION/READY/DELIVERED/CANCELLED), priority, note, created, finalized_at`
- `order_document` — `id, order_id, document_type ENUM(DRAWING/PHOTO/TECH_SPEC/CONTRACT/OTHER), file_path, uploaded_by, is_primary, version, created_at`
- `order_item` — `id, order_id, goods_id NULL (agar mahsulot), free_text NULL, qty, price, total` (yangi — oldin yo'q edi)

**Ishlab chiqarish:**

- `made` — `id, branch_id, order_id NULL, brigadir_id, goods_id, count, date, start_date, end_date, state ENUM(PENDING/IN_PROGRESS/COMPLETED/REJECTED)`
- `made_cost` — `id, made_id, raw_material_id FK goods, qty_plan, qty_fact, cost_plan, cost_fact` (granola → raw_material_id rename)

**Audit:**

- `audit_log` — `id, branch_id NULL, actor_type ENUM(admin/user/system), actor_id, action, entity_type, entity_id, before_snapshot JSON, after_snapshot JSON, ip, user_agent, created_at`

### 2.4 Global (branch_id YO'Q)

`admin`, `plan`, `region`, `district`, `permission`, `payment_method` (methods: NAQD/KARTA/KLIK/PAYME/HAVO), `product_master`, `goods_unit`, `setting` (global), `system_notification`.

### 2.5 O'chiriladi (eski autoservice dan)

`license`, `remote_access_log`, `custom`, `custom_type`, `code_product`, `visit`, `client_car`, `employee`, `position`, `part`, `attendance`, `attendance_event`, `device`, `face_device_sync`, `forniture*`, `referal*` (reklama manbasi — hozircha chiqariladi, kelajakda qaytarish mumkin).

### 2.6 Migration tartibi

Yii console migratsiya (`backend/console/migrations/`):

1. `branch` ustunlarini alter (owner_user_id, trial_ends_at, status enum, registration_ip)
2. `registration_request`
3. `permission`, `role`, `role_permission`, `user`
4. `branch_setting`
5. `warehouse` + default seed (trigger branch approve da)
6. `product_master`, `goods_unit` (global)
7. `goods_group`, `goods`, `goods_warehouse_stock`, `stock_movement`, `stock_transfer*`, `stock_inventory*`
8. `supplier`, `supplier_paid`, `come`, `come_product`, `supplier_return*`
9. `client`, `client_type`
10. `payment_method` (global), `fiscal_terminal`, `fiscal_shift`, `fiscal_receipt`
11. `sale`, `sale_product`, `sale_client`, `sale_credit`
12. `paid`
13. `order`, `order_item`, `order_document`, `made`, `made_cost`
14. `audit_log`
15. Seed: superadmin, default plan (Starter/Pro/Enterprise), system permissions (sklad.*, sotuv.*, made.*, order.*), system roles template

---

## 3. Backend — asosiy controllerlar

### 3.1 Public API (`/api/v1/public/*`, auth siz, `modules/v1/public/`)

- `GET /plan` — ochiq tarif ro'yxati
- `GET /region`, `GET /district?region_id=X` — dropdown
- `POST /register` — registration_request yaratish (phone format regex `^\+998\d{9}$` tekshiriladi, email va SMS tasdiq YO'Q)
- `GET /registration/{token}` — status (arizaga berilgan tracking kod bo'yicha)
- `POST /payme/callback` — Payme Merchant API JSON-RPC endpoint (CheckPerformTransaction, CreateTransaction, PerformTransaction, CancelTransaction, CheckTransaction, GetStatement)

### 3.2 Superadmin API (`/api/v1/superadmin/*`, JWT aud=superadmin, `modules/v1/superadmin/`)

- `AuthController` — login/refresh/me/logout/change-password
- `AdminUserController` — CRUD + reset-password
- `PlanController` — CRUD (auto_remote plan patterni bilan)
- `BranchController` — CRUD + `/{id}/block`, `/{id}/unblock`, `/{id}/snapshots`, `/{id}/orders`, `/{id}/revenue`, **`POST /`** (pilot tashkilot qo'shish — admin o'zi yaratadi); filter `?region_id=&district_id=&status=&is_online=&plan_id=`
- `RegistrationController` — `GET /`, `GET /{id}`, **`POST /{id}/approve`** (username + parol admin tomonidan belgilanadi, dialogda), `POST /{id}/reject`
- `PaymentController` — CRUD + `POST /manual` (naqd/bank/CLICK qo'lda kiritish, `source=MANUAL`), Payme to'lovlari avtomatik callback orqali keladi (source=PAYME), filter source, payment_method, date range
- `RegionController`, `DistrictController` — CRUD
- `ProductMasterController` — global katalog (superadmin moderatsiya qiladi, `verified=1` qo'yadi, duplicate barcode merge)
- `DashboardController` — **barcha tashkilotlar ma'lumotini bitta joyda**: total revenue bugun, online branches, pending registrations, top branches, region heatmap, top product_master
- `ReportController` — global reportlar (barcha branchlar, region bo'yicha, plan bo'yicha)
- `NotificationController`, `LogController` (action_log), `SettingController`

### 3.3 Admin API (`/api/v1/admin/*`, JWT aud=admin + branch_id, `modules/v1/admin/`)

Bu tashkilot ichidagi xodimlar ishlaydigan endpointlar (user jadvalidagi yozuvlar). "admin" bu yerda — branch-scoped user sifatida (OWNER, MANAGER, CASHIER, WAREHOUSE_KEEPER, TECHNICIAN, ACCOUNTANT rollari).

`BaseController` `beforeAction` da `tenantContext->setBranchId(JWT.branch_id)`. Har model ActiveQuery avtomatik filter.

- `AuthController` — login/refresh/me/logout/change-password
- `ProfileController` — profile update
- `UserController` — xodim CRUD (branch ichida)
- `RoleController` — branch role CRUD (faqat branch ichidagi)
- `BranchSettingController` — `GET /setting`, `PUT /setting` (default_mxik, default_lat/lng, default_printer_name, receipt_header…)

**Sklad:**

- `WarehouseController` — CRUD + `/{id}/stock`, `/{id}/movements`
- `StockMovementController` — list + `/balance?goods_id=&warehouse_id=`, `/low-stock`
- `StockTransferController` — CRUD + `/send`, `/receive`, `/cancel`
- `StockInventoryController` — CRUD + `/item` (actual_qty), `/commit`, `/cancel`

**Mahsulot:**

- `ProductController` — `GET /product/search?barcode=` (product_master + goods join), `POST /product/add-to-branch` (product_master_id dan goods yaratadi), `POST /product/create` (product_master + goods bir paytda — barcode yangi bo'lsa)
- `GoodsController` — CRUD + `/{id}/stock`, `/{id}/movements`, `/import` (Excel)
- `GoodsGroupController` — CRUD

**Supplier + Come:**

- `SupplierController` — CRUD + `/{id}/payments`, `/{id}/balance`, `/{id}/comes`
- `SupplierPaidController` — CRUD
- `ComeController` — CRUD + `/confirm` (stock_movement trigger), `/return`
- `SupplierReturnController` — qaytarish

**Mijoz:**

- `ClientController` — CRUD + `/{id}/sales`, `/{id}/balance`
- `ClientTypeController` — CRUD

**Sotuv (POS core):**

- `SaleController` — CRUD + `/{id}/item` (add/edit/remove), **`POST /{id}/finalize`** (tx: stock + paid + shift update), `/cancel`, `/refund`
- `PaidController` — CRUD + **`PATCH /{id}/fiscal`** (Electron dan fiscal response yozish), `/{id}/retry-fiscal`
- `PaymentMethodController` — read-only list

**Fiskal:**

- `FiscalController`:
  - `/fiscal/terminal` CRUD (branch o'z terminalini sozlaydi)
  - `/fiscal/shift` list + `/current`, `POST /shift/open`, `POST /shift/close`
  - `/fiscal/receipt` list + `/{id}`, `POST /receipt/record` (paid.fiscal_* yozib olish backend ga fallback), `/{id}/reprint`
  - `/fiscal/z-report/{shiftId}`
  - `/fiscal/offline-queue`, `POST /offline-queue/process`

**Buyurtmalar:**

- `OrderController` — CRUD + **`PATCH /{id}/state`** (state transition with allowed matrix), `/cancel`
- `OrderItemController` — CRUD (order DRAFT bo'lsa)
- `OrderDocumentController` — upload/delete

**Ishlab chiqarish:**

- `MadeController` — CRUD + `/{id}/cost` (raw_material qaytarish, PRODUCTION_OUT movement), `/{id}/finish` (PRODUCTION_IN movement, goods qoldiqni oshirish)

**Dashboard + Report:**

- `DashboardController` — KPI (bugungi sotuv, qoldiq value, open orderlar, low stock, fiskal summary)
- `ReportController` — daily/monthly/stock-value/fiscal-summary/supplier-debt/client-debt/export Excel
- `BillingController` — tarif, to'lov tarix, obuna holati, upgrade

### 3.4 Service layer — muhim namunalar

**`SaleService::finalize()`** (tenant-aware):

```php
public function finalize(int $saleId, FinalizeSaleDto $dto): array {
  $tx = Yii::$app->db->beginTransaction();
  try {
    $sale = $this->saleRepo->findOrFailForUpdate($saleId);
    if ($sale->status !== Sale::STATUS_DRAFT) throw new DomainException('Not DRAFT');

    $shift = $this->fiscalService->ensureOpenShift($dto->terminalId);

    foreach ($sale->products as $item) {
      $this->stockService->decrease(
        $item->goods_id, $item->warehouse_id, $item->qty,
        StockMovement::TYPE_SALE, 'sale', $sale->id,
        $item->goods->come_price
      );
      // sale_product.mxik_used ni aniqlash
      $mxik = $item->goods->productMaster->mxik_code
        ?? $this->branchSetting->getDefault('default_mxik_code')
        ?? null;
      if ($mxik === null) throw new FiscalException('MXIK code missing, set default_mxik_code');
      $item->mxik_used = $mxik;
      $item->save(false);
    }

    $sale->status = Sale::STATUS_FINALIZED;
    $sale->finalized_at = date('Y-m-d H:i:s');
    $sale->shift_id = $shift->id;
    $sale->save(false);

    $paid = $this->paidService->createForSale($sale, $dto->paymentMethodId, $shift);

    // Fiscal payload construction (Electron ga qaytariladi, u Unikassaga yuboradi)
    $fiscalPayload = $this->fiscalService->buildSalePayload($sale, $paid, $shift);

    $this->eventDispatcher->dispatch(new SaleFinalized($sale, $paid));
    $tx->commit();

    return ['sale' => $sale, 'paid' => $paid, 'fiscal_payload' => $fiscalPayload];
  } catch (\Throwable $e) { $tx->rollBack(); throw $e; }
}
```

**`FiscalService::buildSalePayload()`**:

- `branch_setting` dan default_lat/lng, inn, default_owner_type, default_name olinadi
- Items: SaleProduct → `{Name, SPIC: mxik_used, PackageCode: default_package_code, Price(tiyin), Amount, VAT(tiyin), VATPercent}`
- Location: default_lat/lng
- Payment: naqd/karta bo'lib taqsimlanadi
- ExtraInfo.TIN: default_inn

**`FiscalService::recordReceipt()`** — Electron javobini yozib oladi:

- Paid.fiscal_* update
- fiscal_receipt audit row (request + response JSON)
- fiscal_shift.total_sales ++
- Event FiscalReceiptRecorded

**`RegistrationService::approve()`** — 1.3 dagi oqim:

- branch yaratiladi
- `owner` jadvalida phone bor → mavjud ownerga link; yo'q → yangi owner yaratadi (admin bergan password bilan)
- `owner_branch(owner_id, branch_id, role='MAIN')` insert
- Default role seeded + branch user (OWNER role) + default warehouse + default branch_setting + trial subscription
- Admin dialog da 4 ta kiritadi: (1) owner phone-i bor-yo'q avtomatik ko'rsatadi, (2) owner password (yangi bo'lsa), (3) branch user username, (4) branch user password

**`OwnerAuthService::login()`** — phone + password → JWT aud=owner. `OwnerBranchRepository::forOwner($ownerId)` orqali branch list.

**`OwnerBranchPolicy::canView($ownerId, $branchId)`** — `owner_branch` jadvalida link borligini tekshirish, yo'q bo'lsa 404.

**`PaymeService`** — `common/services/Payme/`:

- `CheckPerformTransaction(account)` — branch_id tasdiqlash, amount va plan narxi moslashini tekshirish
- `CreateTransaction(...)` — payment row create (PENDING), payme_transaction_id saqlash
- `PerformTransaction(...)` — payment confirm, branch.subscription_end renew
- `CancelTransaction(...)` — payment cancel, state=-1/-2
- `CheckTransaction(...)` — state qaytarish
- Error codes: -31001 (invalid amount), -31008 (impossible), -31050 (wrong account), -31099 (cancelled), etc — Payme Merchant API spec bo'yicha

**`StockService::decrease()`** — pessimistic lock `goods_warehouse_stock`, InsufficientStockException, stock_movement row, StockChanged event.

**`ProductService::findOrCreate($barcode, $dto, $branchId)`** — barcode bo'yicha product_master qidiradi, topilmasa yaratadi (current branch_id sifatida `created_by_branch_id`).

### 3.5 TenantScopeBehavior

```php
// common/behaviors/TenantScopeBehavior.php
class TenantScopeBehavior extends Behavior {
  public function events() {
    return [ActiveRecord::EVENT_BEFORE_INSERT => 'setBranchId'];
  }
  public function setBranchId() {
    if ($this->owner->branch_id === null) {
      $this->owner->branch_id = Yii::$app->tenantContext->branchId;
    }
  }
}

// Har modelda:
public function behaviors() {
  return [TimestampBehavior::class, TenantScopeBehavior::class];
}

// Model query scope
public static function find() {
  $q = parent::find();
  $bid = Yii::$app->tenantContext->branchId;
  if ($bid !== null) $q->andWhere([static::tableName().'.branch_id' => $bid]);
  return $q;
}
```

### 3.6 Events + Jobs

**Events:** SaleFinalized, StockChanged, StockLow, OrderCreated, OrderStateChanged, ComeRegistered, FiscalReceiptRecorded, BranchApproved, BranchBlocked, PaymentReceived, SubscriptionExpiring.

**Jobs (queue):**

- `RetryFiscalJob` — har 1 min (OFFLINE_QUEUED receipts)
- `AutoCloseShiftJob` — kuniga 23:30 ochiq shiftlar
- `DailyBranchSnapshotJob` — kuniga 01:00 (branch_snapshot + branch_revenue_daily)
- `SubscriptionReminderJob` — kuniga 09:00 (notification orqali admin panelda ko'rinadi)
- `AutoSuspendBlockJob` — subscription_end + 3 kun o'tgan branch lar SUSPENDED
- `PaymeCheckJob` — kutilayotgan Payme to'lov statusini tekshiradi (callback retry)

### 3.7 Policies + permissions

Permissions (global):

- `warehouse.*` (read/create/edit/delete/transfer/inventory)
- `stock.*` (movement.read/adjust)
- `goods.*`, `goods.import`
- `product.search`, `product.create` (new product_master)
- `supplier.*`, `come.*`, `return.*`
- `client.*`
- `sale.*`, `sale.finalize`, `sale.refund`, `sale.cancel`
- `paid.*`
- `fiscal.terminal.manage`, `fiscal.shift.open`, `fiscal.shift.close`, `fiscal.receipt.record`
- `order.*`, `order.state.change`
- `made.*`
- `report.*`, `report.export`
- `branch.setting.edit`
- `user.manage`, `role.manage`

**Default rollar (branch-scoped):**

- **OWNER** — barcha permissions
- **MANAGER** — barcha except user.manage, role.manage, branch.setting.edit, fiscal.terminal.manage
- **CASHIER** — sale.*, paid.*, fiscal.shift.open/close, fiscal.receipt.record, client.read, goods.read
- **WAREHOUSE_KEEPER** — warehouse.*, stock.*, goods.*, come.*, return.*, inventory.*, transfer.*, supplier.*
- **TECHNICIAN** — order.read, order.state.change, made.*, goods.read
- **ACCOUNTANT** — report.*, paid.read, supplier_paid.*, client.read

---

## 4. Frontend

### 4.0 owner-portal (browser, `me.nazoratpos.uz`, YANGI)

Yangi kichik React ilova (shared-ui ishlatgan holda). Sahifalar:

- **Login** — phone (+998 prefix pre-filled) + password
- **MyBusinesses** — owner ning barcha branchlari kartochkalar ro'yxati (nom, status, bugungi sotuv, online/offline indikator)
- **BranchOverview** — tanlangan branch read-only dashboard: bugungi KPI (sotuv summasi, chek soni, yangi orderlar, low stock), 7-kunlik sotuv grafigi, top-10 mahsulot, fiskal summary (smena statusi, bugungi chek soni)
- **BranchReports** — read-only kunlik/oylik, Excel export
- **Profile** — o'z ma'lumoti, password o'zgartirish
- **Sidebar**da "Filialda ishlash" tugmasi — NazoratPos ilovasini ishga tushirish uchun custom URL protocol (`nazoratpos://open?branch_id=X`), yo'q bo'lsa yuklab olish linki

### 4.1 admin-panel (browser, `admin.nazoratpos.uz`)

`auto_remote/frontend/` dan kengaytiriladi (Radix+Tailwind+TanStack Query+react-router 7):

Mavjud: Dashboard, Branches, BranchDetail, Payments, Plans, Admins, Notifications, Logs, Settings.

Qo'shiladi:

- **Registrations** — pending list, approve/reject
- **Regions**, **Districts** — superadmin SOATO CRUD
- **ProductMaster** — global katalog, barcode qidirish, verify flag, duplicate merge, MXIK to'ldirish
- **GlobalReport** — barcha tashkilotlar umumlashgan hisoboti (sotuv, qoldiq value, region heatmap)
- BranchDetail ga qo'shimcha: sklad value, fiskal summary, top products, users list

### 4.2 app-electron (Electron, tashkilot uchun)

Yangi React ilova Electron ichida. `window.electronSoliq` bo'lmasa login sahifada "Faqat NazoratPos ilovasida ishlaydi" banner.

Folder:

```text
app-electron/src/
├── app/{App,routes,providers}/
├── pages/
│   ├── Login, Dashboard
│   ├── Warehouses/ (WarehouseList, WarehouseDetail, TransferList/New/View, InventoryList/Session)
│   ├── Goods/ (GoodsList, GoodsDetail, GoodsForm, GoodsStockByWarehouse, GoodsImport,
│   │          BarcodeLookup — product_master dan izlash)
│   ├── Suppliers/, Come/ (ComeList, ComeNew [barcode scan flow], ComeView)
│   ├── Clients/ (ClientList, ClientDetail, ClientForm)
│   ├── POS/ (POSScreen, BarcodeInput, Cart, PaymentModal, ReceiptPreview) — kritik
│   ├── Fiscal/ (ShiftControl, ZReport, ReceiptHistory, OfflineQueue, TerminalSettings)
│   ├── Orders/ (OrderKanban — drag-n-drop state, OrderDetail, OrderForm, OrderDocuments)
│   ├── Made/ (MadeList, MadeDetail, MadeCost — production flow)
│   ├── Reports/ (Daily, Monthly, StockValue, FiscalSummary, SupplierDebt, ClientDebt)
│   ├── Billing/ (Subscription, PaymentHistory, UpgradePlan)
│   └── Settings/ (General, BranchSettings — default_mxik/lat/lng/printer, UsersRoles, Audit)
├── features/{pos, fiscal, warehouse, orders, made, auth}/
├── entities/
├── shared/{api, components, ui, hooks, lib}/
└── electron/bridge.ts
```

**Electron main process:** `electron-soliq` dan ko'chirilgan + config manager:

- `app.getPath('userData')/nazoratpos-client.config.json` — default_printer, fiscal_terminal_id, token cache
- Soliq service (Unikassa API)
- POS printer service (@madrimov/electron-pos-printer)
- **Auto-updater (electron-updater):** Windows only, .exe/NSIS installer, har 2 soatda yangilanish tekshiradi. Yangi versiya topilsa fon'da yuklaydi, foydalanuvchi ruxsat bersa restart + install. Update server: backend static `/downloads/latest.yml` + `.exe`/`.blockmap` yoki GitHub Releases

**IPC:**

- `soliq:*` (configure, healthCheck, sendSale, sendRefund, openShift, closeShift)
- `printer:*` (getPrinters, print, getStatus)
- `app:*` (getVersion, isElectron, getConfig, setConfig)

### 4.3 Critical UX: Come (barcode flow)

```text
ComeNew.tsx:
  1. Supplier select
  2. BarcodeInput (kirish focus)
  3. On scan: GET /app/product/search?barcode=...
     - result.product_master + result.goods (branch niki bor/yo'q)
  4a. goods bor: qty + price → ComeProduct ro'yxatga qo'shish
  4b. product_master bor, goods yo'q: modal "O'z ro'yxatingizga qo'shasizmi?" → sale_price/come_price → POST /app/product/add-to-branch → goods yaratiladi, qatorga qo'shiladi
  4c. product_master yo'q: modal "Yangi mahsulot kiriting" → barcode, name, unit, (mxik, package_code, photo ixtiyoriy), sale_price, come_price → POST /app/product/create → product_master + goods yaratiladi, qatorga qo'shiladi
  5. Qatorlar tayyor → "Kelishni tasdiqlash" → POST /app/come → tx: come + come_product + stock_movement lar (increase)
```

### 4.4 Critical UX: POS

```text
POSScreen.tsx:
  1. BarcodeInput focus
  2. Scan → GET /app/product/search?barcode=...
     - goods bor bo'lmasa error: "Bu mahsulot siz uchun ro'yxatda yo'q. Avval Kelishdan qabul qiling"
     - goods bor → cart.addLine
  3. Cart inline edit qty/price
  4. ClientPanel (optional — biriktirish yoki qarz uchun)
  5. Finalize button:
     a. Modal: payment method (naqd/karta/aralash)
     b. POST /app/sale/{id}/finalize → {sale, paid, fiscal_payload}
     c. if window.electronSoliq: electronSoliq.fiskal.sendSale(fiscal_payload) → {FiscalSign, ReceiptSeq, QRCodeURL, ...}
     d. PATCH /app/paid/{id}/fiscal → backend yozib oladi
     e. electronSoliq.printer.print(receiptBuilder({sale, paid, fiscal, branchSetting}))
     f. toast "Chek chop etildi", yangi sale DRAFT yaratiladi, cart toza
  6. Error handling:
     - 9030 (shift closed) → auto-open prompt
     - 9040 (network) → offline queue toast, keyin retry
     - MXIK yo'q error → Settings ga yo'naltirish
```

### 4.5 BranchSettings.tsx (muhim)

Tashkilot o'zining default MXIK, lat/lng, printer va boshqalarini sozlaydi. Form sections:

- **Umumiy:** nom, INN, manzil, telefon, email, logo upload, chek shapkasi/futer
- **Fiskal defaults:** `default_mxik_code`, `default_mxik_name`, `default_package_code`, `default_owner_type`, `default_name`, `default_vat_percent`
- **Geolokatsiya:** `default_lat`, `default_lng` (map picker)
- **Printer:** list `window.electronSoliq.printer.getPrinters()` → dropdown → serverga PUT hamda local Electron config ga yozish
- **Timezone, Valyuta**

### 4.6 State + API

- Server state: TanStack Query
- Client state: React Context (Auth, Shift, Cart, BranchSetting cache)
- Form: react-hook-form + zod
- axios interceptor: 401 → refresh → retry; 403 branch blocked → logout + banner

---

## 5. Bosqichlar (Phase plan)

| Phase | Scope | Vaqt |
|---|---|---|
| **0** | `D:\php\dilmurod\NazoratPos\` monorepo yaratish. Backend tayyor (Yii2 advanced). Keyingi subdirectorylar: admin-panel, owner-portal, app-electron, public-web, shared-ui, **docs/**. docs/ ichida mana shu plan.md nusxasi + api-reference.md + fiscal-spec.md + payme-integration.md + migration-notes.md + deployment-guide.md. Backend ichida 4 ta modul: v1/public, v1/superadmin, v1/owner, v1/admin — har birida SwaggerController. Migrations init, docker, CI, electron-soliq ko'chirish | 7 kun |
| **1** | Public: /register (phone bilan, email/SMS tasdiq yo'q) + /plan + /region + /district. Admin: Registrations sahifasi + approve/reject (username+parol belgilash dialogi + owner yaratish/linking) | 7 kun |
| **1.5** | **Owner + owner_branch jadvallari**. Owner auth (phone+password). Owner API (/auth, /branches, /branch/{id}/dashboard, /reports). Registration approve'da owner yaratish/link qilish logikasi. **owner-portal** skeleton (Login + MyBusinesses + BranchOverview read-only) | 7 kun |
| **2** | user + role + permission + role_permission jadvallari, App auth (JWT + branch_id claim), TenantScopeBehavior, BaseController guard. Electron app skeleton — login ekrani, window.electronSoliq check | 7 kun |
| **3** | branch_setting jadvali + CRUD API + Settings sahifasi (umumiy, fiskal defaults, geolokatsiya, printer picker). Electron config file r/w | 5 kun |
| **4** | Warehouse + StockMovement + StockService (pessimistic lock) + StockTransfer + StockInventory — App API va UI | 10-12 kun |
| **5** | product_master global katalog + admin moderatsiya + goods (branch-scoped) + goods_group + goods_unit + ProductService.findOrCreate. Admin-panelda ProductMaster sahifasi. App-panelda BarcodeLookup UI | 10 kun |
| **6** | Supplier + Come (barcode flow + stock_movement increase) + SupplierPaid + SupplierReturn. App-panelda Come barcode workflow | 8-10 kun |
| **7** | Client + ClientType | 3 kun |
| **8** | **Sale POS + Paid + Fiscal end-to-end** — SaleService.finalize, FiscalTerminal, FiscalShift, FiscalReceipt, FiscalService (shift open/close + buildSalePayload + recordReceipt + retry), App-panelda POSScreen + ShiftControl, Electron soliq.service va printer integratsiyasi, offline queue, error code handling | 18-22 kun |
| **9** | Order + OrderItem + OrderDocument, OrderKanban drag-n-drop, state transitions matrix | 8 kun |
| **10** | Made + MadeCost (raw_material_id), production flow: order → made → raw materials PRODUCTION_OUT, finish → goods PRODUCTION_IN | 7 kun |
| **11** | Reports + Billing (app: subscription, plan upgrade, **Payme checkout** + qo'lda to'lov tarixi ko'rish) + Global Dashboard (admin) — barcha tashkilot umumlashgan KPI, region heatmap, top products | 10 kun |
| **11.5** | Payme Merchant API integratsiyasi: public /payme/callback endpoint, PaymeService, transaction state machine, PaymeCheckJob. Admin panelda manual payment kiritish UI (naqd/bank/CLICK) | 5 kun |
| **12** | Cron/queue (RetryFiscal, AutoCloseShift, DailyBranchSnapshot, SubscriptionReminder, AutoSuspend, PaymeCheck). Remote heartbeat (Electron → backend ping) | 5 kun |
| **13** | Electron Windows packaging (.exe/NSIS installer), **auto-update (electron-updater)** Windows only, (macOS/Linux build chiqarilmaydi), code signing (Authenticode) ixtiyoriy | 5 kun |
| **14** | Legacy data migration (bir test branch uchun), parallel run 2 hafta, UAT, cutover | 10-14 kun |

**Umumiy:** ~4-5 oy solo, ~3 oy jamoa.

---

## 6. Legacy migration (eski autoservice → mbos, bitta branch uchun)

Console command:

```bash
php yii legacy/init-branch --name="Pilot" --region=1726 --district=1726294 --owner="Ism"
  # Natija: $branchId

php yii legacy/users --branch=$branchId
php yii legacy/product-catalog --branch=$branchId
  # goods.barcode → product_master (verified=0, created_by_branch_id=$branchId)
  # ko'rinib, keyin goods(branch-scoped) yaratiladi
php yii legacy/backfill-stock --branch=$branchId
  # goods.remainder → goods_warehouse_stock(MAIN) + opening balance stock_movement
php yii legacy/suppliers --branch=$branchId
php yii legacy/come --branch=$branchId --from=2023-01-01
php yii legacy/clients --branch=$branchId
php yii legacy/sales --branch=$branchId --from=2023-01-01
  # + sale_product, sale_client, sale_credit, stock_movement backfill
php yii legacy/paid --branch=$branchId
  # agar paid.fiscal_sign bor bo'lsa → fiscal_receipt audit satri yoziladi
php yii legacy/orders --branch=$branchId
  # order + order_document + made + made_cost (granola → raw_material_id)
php yii legacy/verify --branch=$branchId
```

Olib tashlanadi: visit, client_car, employee, attendance, device, face_device_sync, forniture.

---

## 7. Kritik fayllar (implementation uchun)

**Eng muhim (Phase 8 dan):**

- `NazoratPos/backend/common/services/SaleService.php`
- `NazoratPos/backend/common/services/StockService.php`
- `NazoratPos/backend/common/services/FiscalService.php` (buildSalePayload, recordReceipt)
- `NazoratPos/backend/common/services/ProductService.php` (findOrCreate)
- `NazoratPos/backend/common/services/RegistrationService.php`
- `NazoratPos/backend/common/services/TenantService.php`
- `NazoratPos/backend/common/behaviors/TenantScopeBehavior.php`
- `NazoratPos/backend/common/behaviors/BlockCheckBehavior.php`
- `NazoratPos/backend/app-api/modules/v1/controllers/SaleController.php`
- `NazoratPos/backend/app-api/modules/v1/controllers/FiscalController.php`
- `NazoratPos/backend/app-api/modules/v1/controllers/ComeController.php`
- `NazoratPos/backend/app-api/modules/v1/controllers/ProductController.php`
- `NazoratPos/backend/app-api/modules/v1/controllers/BranchSettingController.php`
- `NazoratPos/backend/admin-api/modules/v1/controllers/RegistrationController.php`
- `NazoratPos/backend/admin-api/modules/v1/controllers/ProductMasterController.php`
- `NazoratPos/backend/public-api/controllers/RegisterController.php`
- `NazoratPos/backend/console/migrations/` (70+ migration)
- `NazoratPos/backend/console/controllers/LegacyMigrationController.php`
- `NazoratPos/backend/console/controllers/QueueController.php`
- `NazoratPos/app-electron/src/pages/POS/POSScreen.tsx`
- `NazoratPos/app-electron/src/pages/Come/ComeNew.tsx` (barcode flow)
- `NazoratPos/app-electron/src/pages/Fiscal/ShiftControl.tsx`
- `NazoratPos/app-electron/src/pages/Settings/BranchSettings.tsx`
- `NazoratPos/app-electron/src/electron/bridge.ts`
- `NazoratPos/app-electron/electron/main/services/soliq.service.ts` (electron-soliq dan ko'chirish)
- `NazoratPos/app-electron/electron/main/services/config.service.ts` (userData/nazoratpos-client.config.json)
- `NazoratPos/admin-panel/src/pages/Registrations.tsx`
- `NazoratPos/admin-panel/src/pages/ProductMaster.tsx`

**Qayta ishlatiladigan (mavjud kod):**

- [auto_remote BaseController](D:/php/dilmurod/auto_remote/backend/backend/modules/v1/controllers/BaseController.php)
- [auto_remote AuthController](D:/php/dilmurod/auto_remote/backend/backend/modules/v1/controllers/AuthController.php)
- [auto_remote api.ts](D:/php/dilmurod/auto_remote/frontend/src/services/api.ts)
- [auto_remote Branch/Admin/Plan/Region/District models](D:/php/dilmurod/auto_remote/backend/common/models/)
- [auto_remote DB schema](D:/php/dilmurod/auto_remote/docs/remote_server_database.sql)
- [electron-soliq SoliqService](D:/php/dilmurod/autoservice/electron-soliq/src/main/services/soliq.service.ts)
- [electron-soliq FiskalAPI](D:/php/dilmurod/autoservice/electron-soliq/src/main/lib/fiskal-unikassa/)

---

## 8. Risk va mitigation

| Risk | Mitigation |
|---|---|
| Tenant data leak | TenantScopeBehavior har modelda, BaseController guard, integration test matrix, write-endpoint body.branch_id cross-check |
| Owner cross-branch access | Har owner endpoint'da OwnerBranchPolicy — owner_branch junction tekshiruvi. Integration test: owner A sees only A's branches |
| Concurrent stock race | SELECT … FOR UPDATE, composite lock goods+warehouse, load test |
| Unikassa offline | Backend Sale finalize fiskaldan mustaqil. Paid.fiscal_* NULL qabul. Electron offline_queue + server retry |
| MXIK yo'q mahsulot sotilishi | branch_setting.default_mxik_code fallback. To'ldirilmagan bo'lsa, sale finalize da aniq error message → Settings ga yo'naltirish |
| product_master duplicate barcode | DB UNIQUE constraint; race condition uchun findOrCreate da INSERT IGNORE + reread yoki advisory lock |
| Electron dasturi bo'lmasa tashkilot kirmaydi | Login sahifada aniq ko'rsatma "NazoratPos ilovasini yuklab oling: [link]". Admin panelda admin lar kirishlari mumkin |
| Ro'yxatdan o'tish spam | Email verify majburiy, IP rate-limit (3/soat), admin approve gate |
| Subscription tugadi | 7/3 kun notification, grace period 3 kun, SUSPENDED da read-only billing + qolganlar blok |
| Shift ochiq qolish | Cron AutoCloseShift 23:30, UI warning badge |
| Electron config fayl zararli o'zgartirish | Schema validation yuklashda. Keyin serverdan qayta sync mumkin |
| Default printer topilmadi | Fallback: user-selected silent=false bilan dialog ochiladi. Electron printer.getPrinters() ni avtomatik tekshirish |
| Legacy product katalog aralashib ketish | Migration da duplicate barcode nigation logi, admin moderatsiya (verified flag) |

---

## 9. Test va verification

### 9.1 Unit (Codeception + PHPUnit)

- StockServiceTest (inc/dec/race/insufficient, branch-scoped)
- SaleServiceTest (finalize, cross-branch reject, shift closed, MXIK missing)
- FiscalServiceTest (buildSalePayload with defaults, recordReceipt idempotent)
- ProductServiceTest (findOrCreate, duplicate barcode race)
- RegistrationServiceTest (approve full flow)
- TenantScopeBehaviorTest (auto filter, admin bypass)

### 9.2 API (Codeception Cest)

- `RegistrationCest` — public register → verify → admin approve → user login
- `TenantIsolationCest` — user A cross-branch access → 404/403
- `ComeCest` — barcode scan flow (existing goods, new product_master, new goods)
- `SaleCest` — finalize stock+paid, MXIK resolution (master vs default)
- `FiscalCest` — shift open/close, receipt record with payload JSON
- `StockTransferCest`, `InventoryCest`
- `AdminApproveCest`

### 9.3 E2E (Playwright)

- `register-flow.spec.ts`
- `come-barcode.spec.ts` (barcode scanner mock, 3 variants)
- `pos.spec.ts` (electronSoliq mock)
- `fiscal-shift.spec.ts`
- `admin-approve.spec.ts`

### 9.4 Fiskal sandbox (Unikassa TEST)

Senariylar: happy, shift closed (9030), duplicate (9021), timeout (9040), refund, MXIK fallback.

### 9.5 Load test (k6)

- 50 concurrent sale finalize (race + tenant isolation)
- 100 GET /goods (multi-branch, N+1)
- 30 concurrent barcode search
- Target: p95 < 500ms finalize, < 200ms list, < 100ms barcode search

### 9.6 End-to-end verification (manual)

1. Public /register (+998 phone) → admin approve (owner+branch user credentials) → NazoratPos ilovasini yuklash → branch user bilan login → Dashboard; alohida me.nazoratpos.uz → owner phone+password → MyBusinesses ko'rinadi
2. Settings/BranchSettings — default_mxik, lat/lng, printer to'ldirish
3. Supplier yaratish → Come barcode skanner: (a) mavjud goods (b) mavjud master, yangi goods (c) butunlay yangi
4. Sale DRAFT → barcode → cart → finalize → electronSoliq sendSale → fiscal_receipt yozildi → printer chop etdi
5. Internet uzdirish → sale finalize → offline queue → internet qaytganda auto-retry
6. MXIK siz mahsulot sotuvi (default_mxik fallback)
7. Cross-tenant: branch A user brauzerda B sale ID → 404
8. Block qilingan branch user login → rad etildi + banner
9. Admin Dashboard: barcha branchlar KPI bitta joyda
10. Legacy migration dry-run + verify

---

## 10. Hal qilinmagan savollar

Reja tasdiqlansa:

- **Domen:** foydalanuvchi tomonidan olinadi
- **Payme Merchant API credentials:** merchant_id, cashbox_id (test va prod)
- **Electron Authenticode sertifikat:** ixtiyoriy (bo'lmasa ham ishlaydi, lekin SmartScreen warning chiqadi)
- **Update server:** auto-updater yangilanishlarini qayerdan oladi — o'z backend static fayllari yoki GitHub Releases?

Phase 0+1+1.5+2+3 birinchi 4-5 hafta ichida demo:

- Public /register (phone bilan) → admin panel /registrations → approve (owner phone+password va branch username+password admin belgilaydi)
- Owner portal me.nazoratpos.uz/login (phone+password) → MyBusinesses → BranchOverview read-only
- App-Electron login (username+password) → Dashboard skeleton → BranchSettings to'ldirish
- Superadmin pilot tashkilotni qo'lda qo'shishi mumkin (Branches sahifasida "Yangi" tugmasi), mavjud owner ga yangi filial biriktirish
