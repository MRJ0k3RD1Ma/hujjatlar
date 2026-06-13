# HAR BIR SAHIFA UCHUN BATAFSIL TEXNIK SPETSIKATSIYA
## BSK FaceID Kirish Nazorati Tizimi

| Hujjat raqami | TT-PAGES-2025-001 |
|--------------|-------------------|
| Versiya | 1.0 |
| Sana | 2025-yil |
| Asos | design.md, db.sql, Texnik topshiriq - BSK 2.0.md |

---

## 1. WEB PANEL — ASOSIY SAHIFALAR

### 1.1. Login Sahifasi (`/login`)

| Element | Turi | Majburiy | Validation | Eslatma |
|---------|------|----------|------------|---------|
| Telefon raqam | Input (masked) | ✅ | `+998 __ ___ __ __` format | Auto-format |
| Parol | Password | ✅ | Min 8 belgi | Ko'rish/yashirish toggle |
| Kirish tugmasi | Button | ✅ | — | Primary Large |
| Parolni unutdingizmi | Link | ❌ | — | `/password-reset` ga o'tadi |
| Til tanlash | Select | ❌ | O'zbek/Rus | Header'da |

**Xavfsizlik:**
- 5 marta noto'g'ri kiritish → 15 daqiqa blok
- Blok holati: `locked_until` timestamp ko'rsatiladi
- CAPTCHA: 3-marta xatodan keyin faollashadi

---

### 1.2. Dashboard (`/dashboard`)

**Maqsad:** Real-time statistika va tizim holati

#### 1.2.1. Statistika Kartalari (1-qator)

| Karta | Ma'lumot Manbai | Yangilanish | Format |
|-------|-----------------|-------------|--------|
| Bugungi kirishlar | `access_logs` (bugun, `DOOR_OPEN_SUCCESS`) | Real-time (WebSocket) | 1,234 |
| Rad etilganlar | `access_logs` (bugun, `DOOR_OPEN_DENIED`) | Real-time | 45 |
| Aktiv terminallar | `terminals` (status='online') | Har 30 soniya | 12 / 15 |
| Aktiv rezidentlar | `residents` (status='active') | Har 5 daqiqa | 2,450 |

#### 1.2.2. Grafiklar (2-qator)

| Grafik | Turi | Ma'lumot Manbai | Davr |
|--------|------|-----------------|------|
| Kirish Trendi | Line Chart | `access_logs` | 7 kun |
| Terminal Xaritasi | Map (Leaflet) | `terminals` + `buildings` | Real-time |

#### 1.2.3. Lenta Widgetlari (3-qator)

| Widget | Ma'lumot | Limit | Yangilanish |
|--------|----------|-------|-------------|
| So'nggi Voqealar | `access_logs` (oxirgi 10 ta) | 10 ta | Real-time |
| Shubhali Voqealar | `access_logs` (event_type IN ('SUSPICIOUS_ATTEMPT', 'LIVENESS_FAIL')) | 5 ta | Real-time |

**Search/Filter:** Dashboard'da search yo'q (faqat ko'rish)

**Role-based ko'rinish:**

| Rol | Ko'rinadigan ma'lumot |
|-----|----------------------|
| Super Admin | Barcha binolar |
| BSK Admin | Faqat o'z tashkiloti binolari |
| Operator | Faqat biriktirilgan bino |
| GASN | Barcha (faqat ko'rish) |
| Prokuratura/IIV | Cheklangan (so'rov asosida) |

---

### 1.3. Rezidentlar Ro'yxati (`/residents`)

#### 1.3.1. Filtrlar Paneli

| Filter | Turi | Values | Default |
|--------|------|--------|---------|
| Qidiruv | Text Input | Ism, telefon, xonadon | Bo'sh |
| Bino | Select + Search | `buildings` jadvalidan | Barchasi |
| Holat | Multi-select | active, blocked, archived, deleted | active |
| Qavat | Number | 1-30 | Barchasi |
| Qo'shilgan sana | Date Range | — | Oxirgi 30 kun |
| Terminal huquqi | Select | Terminal nomi | Barchasi |

#### 1.3.2. Jadval Kolonnalari

| Kolonna | Maydon | Width | Sort | Filter | Format |
|---------|--------|-------|------|--------|--------|
| ☐ Checkbox | — | 40px | ❌ | ❌ | Bulk select |
| Avatar + Ism | `residents.full_name` + `face_templates.photo_thumb_url` | 25% | ✅ | ✅ | Thumbnail 40×40px + text |
| Telefon | `residents.phone_encrypted` (decrypt) | 15% | ✅ | ✅ | Maskalangan: `+998 90 *** ** 34` |
| Bino / Xonadon | `buildings.name` + `residents.apartment_number` | 20% | ✅ | ✅ | "Chilonzor-14 / 35-x" |
| Qavat | `residents.floor_number` | 8% | ✅ | ❌ | Auto-hisoblanadi |
| Holat | `residents.status` | 10% | ✅ | ✅ | Badge (rangli) |
| Qo'shilgan sana | `residents.created_at` | 12% | ✅ | ✅ | `DD.MM.YYYY` |
| Amallar | — | 80px | ❌ | ❌ | [✏️] [🔒] [⋮] |

#### 1.3.3. Pagination

| Parametr | Qiymat |
|----------|--------|
| Default page size | 25 ta |
| Variantlar | 10, 25, 50, 100 |
| Max page size | 100 ta |
| Infinite scroll | Yo'q (classic pagination) |
| URL param | `?page=1&per_page=25` |

#### 1.3.4. Bulk Amallar (Tanlanganda)

| Amal | Shart | Confirmation |
|------|-------|--------------|
| Ko'chirish | Kamida 1 ta tanlangan | ✅ Modal |
| Bloklash | Kamida 1 ta tanlangan | ✅ Modal |
| O'chirish | Kamida 1 ta tanlangan | ✅ Modal (2-step) |
| Export | Kamida 1 ta tanlangan | ❌ |

#### 1.3.5. Qator Amallar (Har bir resident uchun)

| Tugma | Action | Route | Ruxsat |
|-------|--------|-------|--------|
| ✏️ Tahrirlash | Modal ochish | `/residents/:id/edit` | CRUD ruxsati borlar |
| 🔒 Bloklash/Aktivlash | Status o'zgartirish | API PATCH | CRUD ruxsati borlar |
| ⋮ Menyusi | Dropdown: Ko'rish, Ko'chirish, O'chirish, Kirish tarixi | — | Role-based |

---

### 1.4. Rezident Qo'shish (`/residents/create`)

#### 1.4.1. Stepper Qadamlari

| Qadam | Sarlavha | Maydonlar | Validation |
|-------|----------|-----------|------------|
| 1 | Shaxsiy ma'lumotlar | To'liq ism*, Telefon* | Ism min 3 belgi, Telefon unikal |
| 2 | Joylashuv | Bino*, Xonadon*, Qavat | Bino tanlangan bo'lishi kerak |
| 3 | Yuz foto | Foto yuklash (min 2 ta)* | Har biri max 2MB, min 640×480 |
| 4 | Kirish huquqlari | Terminallar (checkbox), Vaqt oralig'i | Kamida 1 terminal |

#### 1.4.2. 1-Qadam: Shaxsiy Ma'lumotlar

| Maydon | Turi | Required | Validation | Helper Text |
|--------|------|----------|------------|-------------|
| To'liq ism-sharif | Text Input | ✅ | Min 3, Max 255 | "Ism va familiya kiriting" |
| Telefon raqam | Masked Input | ✅ | Unikal (`phone_hash`) | "+998 formatida" |
| Email | Email Input | ❌ | Valid email format | "Bildirishnomalar uchun" |

**⚠️ Pasport ma'lumotlari YO'Q**

#### 1.4.3. 2-Qadam: Joylashuv

| Maydon | Turi | Required | Data Source |
|--------|------|----------|-------------|
| Bino tanlash | Select + Search | ✅ | `buildings` (active) |
| Xonadon raqami | Number Input | ✅ | 1-9999 |
| Qavat | Auto-fill / Manual | ✅ | `floor_number = ceil(apartment / apartments_per_floor)` |

#### 1.4.4. 3-Qadam: Yuz Foto

| Maydon | Turi | Required | Validation |
|--------|------|----------|------------|
| Foto 1 | File Upload + Camera | ✅ | Max 2MB, WebP/JPG/PNG |
| Foto 2 | File Upload + Camera | ✅ | Max 2MB, WebP/JPG/PNG |
| Foto 3 | File Upload + Camera | ❌ | Max 2MB, WebP/JPG/PNG |
| Sifat bahosi | Progress Bar | Auto | Quality score ≥ 0.7 |

**Preview:** Har bir foto uchun thumbnail + o'chirish tugmasi

#### 1.4.5. 4-Qadam: Kirish Huquqlari

| Maydon | Turi | Required | Default |
|--------|------|----------|---------|
| Terminallar | Checkbox Group | ✅ | Tanlangan bino terminallari |
| Vaqt oralig'i | Time Range | ❌ | 00:00 – 23:59 (cheksiz) |
| Muddat | Date Range | ❌ | Cheksiz |

**Submit:** `[Yaratish]` tugmasi → Success toast → `/residents` ga redirect

---

### 1.5. Rezident Ko'rish/Tahrirlash (`/residents/:id`)

#### 1.5.1. Modal Tuzilishi

| Bo'lim | Elementlar | Data Source |
|--------|------------|-------------|
| Header | [←] Back, [✏️] Edit, [✕] Close | — |
| Shaxsiy ma'lumotlar | Avatar (120×120), Ism, Telefon (maskalangan), Email | `residents`, `face_templates` |
| Joylashuv | Bino, Xonadon, Qavat | `buildings`, `residents` |
| Holat | Badge + Toggle | `residents.status` |
| Kirish huquqlari | Terminal ro'yxati (aktiv/noaktiv), Vaqt oralig'i | `resident_terminal_access`, `terminals` |
| So'nggi kirishlar | Jadval (oxirgi 5 ta) | `access_logs` (LIMIT 5) |
| Amallar | [Bloklash] [Ko'chirish] [O'chirish] | — |

#### 1.5.2. So'nggi Kirishlar Jadvali

| Kolonna | Format | Data Source |
|---------|--------|-------------|
| Vaqt | `DD.MM.YYYY HH:mm` | `access_logs.created_at` |
| Terminal | Bino nomi + Terminal ID | `terminals`, `buildings` |
| Holat | Badge (✅/❌) | `access_logs.event_type` |
| Foto | [👁️] Thumbnail | `access_logs.photo_url` |

---

### 1.6. Binolar Ro'yxati (`/buildings`)

#### 1.6.1. Filtrlar

| Filter | Turi | Values |
|--------|------|--------|
| Qidiruv | Text | Bino nomi, manzil, kadastr |
| Tashkilot | Select | `organizations` (BSK) |
| Hudud (SOATO) | Select + Cascade | Region → District → City |
| Holat | Select | active, deleted |

#### 1.6.2. Jadval Kolonnalari

| Kolonna | Maydon | Width | Sort |
|---------|--------|-------|------|
| Bino nomi | `buildings.name` | 25% | ✅ |
| Manzil | `buildings.address` | 20% | ✅ |
| Tashkilot | `organizations.name` | 15% | ✅ |
| Hudud | `soato_regions.name_uz` | 15% | ✅ |
| Terminallar soni | COUNT(`terminals.id`) | 10% | ✅ |
| Rezidentlar soni | COUNT(`residents.id`) | 10% | ✅ |
| Holat | `buildings.is_active` | 5% | ✅ |
| Amallar | — | 80px | ❌ |

#### 1.6.3. Pagination

| Parametr | Qiymat |
|----------|--------|
| Default | 25 ta |
| Variantlar | 10, 25, 50, 100 |

---

### 1.7. Terminallar Ro'yxati (`/terminals`)

#### 1.7.1. Filtrlar

| Filter | Turi | Values |
|--------|------|--------|
| Qidiruv | Text | Terminal nomi, serial, IP |
| Bino | Select + Search | `buildings` |
| Holat | Multi-select | online, offline, maintenance, error |
| Sinxronizatsiya | Select | sync_needed, synced |

#### 1.7.2. Grid/Karta Ko'rinishi (Asosiy)

| Element | Ma'lumot | Format |
|---------|----------|--------|
| Holat indikatori | `terminals.status` | 🟢/🔴/🟠 + rang |
| Terminal nomi | `terminals.name` | "Terminal-1" |
| Bino | `buildings.name` + entrance | "Chilonzor-14, 1-podjezd" |
| Serial raqam | `terminals.serial_number` | "FID-2025-001" |
| IP manzil | `terminals.ip_address` | "192.168.1.101" |
| Oxirgi aloqa | `terminals.last_heartbeat_at` | "2 daqiqa oldin" |
| Rezidentlar | COUNT(`resident_terminal_access`) | "145 / 200" |
| Amallar | [⚙️] [🔄] [⋮] | Tugmalar |

#### 1.7.3. Jadval Ko'rinishi (Alternativ)

| Kolonna | Width | Sort |
|---------|-------|------|
| Holat | 60px | ✅ |
| Terminal nomi | 20% | ✅ |
| Bino | 20% | ✅ |
| Serial | 15% | ✅ |
| IP | 12% | ✅ |
| Oxirgi aloqa | 12% | ✅ |
| Amallar | 80px | ❌ |

#### 1.7.4. Pagination

| Parametr | Qiymat |
|----------|--------|
| Default | 20 ta (grid), 50 ta (table) |
| View toggle | Grid ↔ Table |

---

### 1.8. Terminal Detail Modal (`/terminals/:id`)

#### 1.8.1. Tablar

| Tab | Elementlar | Data Source |
|-----|------------|-------------|
| Umumiy | Model, Serial, Firmware, IP, MAC, Heartbeat, Uptime grafik | `terminals` |
| Rezidentlar | Jadval (terminaldagi residentlar) | `resident_terminal_access` + `residents` |
| Loglar | Filtrli jadval (faqat shu terminal) | `access_logs` (terminal_id) |
| Sozlamalar | Sezgirlik slider, Liveness toggle, Volume, Remote actions | `terminals.config_json` |

#### 1.8.2. Sozlamalar Tab

| Sozlama | Turi | Range/Values | Save |
|---------|------|--------------|------|
| Sezgirlik | Slider | 1-5 | Auto-save |
| Liveness detection | Toggle | On/Off | Auto-save |
| Kirish vaqti | Time Range | 00:00-23:59 | Auto-save |
| Volume | Slider | 0-100 | Auto-save |
| Ekran yorqinligi | Slider | 0-100 | Auto-save |
| Remote Restart | Button | — | Confirmation modal |
| Remote Lock | Button | — | Confirmation modal |

---

### 1.9. Kirish Loglari (`/logs`)

#### 1.9.1. Filtrlar Paneli

| Filter | Turi | Values | Default |
|--------|------|--------|---------|
| Sana oralig'i | Date Range | — | Oxirgi 7 kun |
| Bino | Select + Search | `buildings` | Barchasi |
| Terminal | Select + Search | `terminals` | Barchasi |
| Voqea turi | Multi-select | event_type ENUM | Barchasi |
| Shaxs | Text Input | Ism yoki telefon | Bo'sh |
| Holat | Select | success, denied, suspicious | Barchasi |

#### 1.9.2. Jadval Kolonnalari

| Kolonna | Maydon | Width | Sort | Export |
|---------|--------|-------|------|--------|
| Vaqt | `access_logs.created_at` | 160px | ✅ | ✅ |
| Terminal | `terminals.name` + `buildings.name` | 200px | ✅ | ✅ |
| Shaxs | `residents.full_name` + telefon (masked) | 25% | ✅ | ✅ (masked) |
| Voqea turi | `access_logs.event_type` | 140px | ✅ | ✅ |
| Qaror sababi | `access_logs.decision_reason` | 20% | ❌ | ✅ |
| Foto | `access_logs.photo_url` | 80px | ❌ | ❌ |

#### 1.9.3. Voqea Turi Badge'lari

| event_type | Badge rangi | Matn | Icon |
|------------|-------------|------|------|
| DOOR_OPEN_SUCCESS | Yashil | ✅ Kirdi | check-circle |
| DOOR_OPEN_DENIED | Qizil | ❌ Rad etildi | x-circle |
| DOOR_OPEN_MANUAL | Ko'k | 🔑 Qo'lda | key |
| LIVENESS_FAIL | To'q sariq | ⚠️ Liveness | exclamation |
| SUSPICIOUS_ATTEMPT | Qizil + bold | 🚨 Shubhali | exclamation-triangle |
| DOOR_FORCED | Qizil + bold | 🚨 Majburiy | lock-open |
| DEVICE_ONLINE | Yashil/kulrang | 📡 Online | wifi |
| DEVICE_OFFLINE | Kulrang | 📡 Offline | wifi-off |
| SYNC_COMPLETE | Ko'k | 🔄 Sinxron | arrow-path |

#### 1.9.4. Pagination

| Parametr | Qiymat |
|----------|--------|
| Default | 50 ta |
| Variantlar | 25, 50, 100, 200 |
| Export limit | 10,000 ta (bir vaqtda) |

#### 1.9.5. Export Options

| Format | Max rows | File size limit |
|--------|----------|-----------------|
| PDF | 100 ta | 10 MB |
| Excel (XLSX) | 10,000 ta | 50 MB |
| CSV | 100,000 ta | 100 MB |

---

### 1.10. Hisobotlar (`/reports`)

#### 1.10.1. Hisobot Turlari (Tabs)

| Tab | Davr | Ma'lumot | Export |
|-----|------|----------|--------|
| Kunlik kirish | Kun (tanlash) | Soatlik grafik, jami soni | PDF, Excel |
| Haftalik trend | 7 kun (fixed) | Kunlik taqqoslama | PDF, Excel |
| Oylik statistika | Oy (tanlash) | To'liq tahlil | PDF, Excel, CSV |
| Terminal faollik | Tanlanadi | Uptime %, xatolar | PDF |
| Shubhali voqealar | Tanlanadi | Xavfsizlik hisoboti | PDF |
| Rezident faollik | Oy (tanlash) | Kirish statistikasi | Excel |

#### 1.10.2. Hisobot Sahifasi Elementlari

| Element | Turi | Data Source |
|---------|------|-------------|
| Davr tanlash | Date Picker / Presets | — |
| Bino filtri | Multi-select | `buildings` |
| Summary kartalari | 4-6 cards | Aggregated queries |
| Grafik 1 | Line Chart | `access_logs` (group by date) |
| Grafik 2 | Bar Chart | `terminals` (activity) |
| Jadval | Data Table | Varied |
| Export tugmalari | Button group | — |

#### 1.10.3. Summary Kartalari (Dynamic)

| Karta | Hisoblash | Format |
|-------|-----------|--------|
| Jami kirishlar | COUNT(event_type='DOOR_OPEN_SUCCESS') | 12,450 |
| Muvaffaqiyat % | (success / total) × 100 | 98% |
| Rad etildi | COUNT(event_type='DOOR_OPEN_DENIED') | 240 |
| Shubhali | COUNT(event_type IN ('SUSPICIOUS', 'LIVENESS_FAIL')) | 12 |
| Oflayn vaqt | SUM(offline_duration) / total_time | 0.3% |

---

### 1.11. Mehmonlar (`/guests`)

#### 1.11.1. Mehmon Yaratish Formasi

| Maydon | Turi | Required | Validation |
|--------|------|----------|------------|
| Mehmon ismi | Text Input | ✅ | Min 2 belgi |
| Mehmon telefon | Masked Input | ❌ | Valid format |
| Host resident | Select + Search | ✅ | Active resident |
| Terminal | Select + Search | ✅ | Active terminal |
| Kirish turi | Radio | ✅ | QR yoki PIN |
| Boshlanish | DateTime Picker | ✅ | ≥ Hozirgi vaqt |
| Tugash | DateTime Picker | ✅ | > Boshlanish |
| Foydalanish soni | Radio + Number | ✅ | 1, 5, yoki cheksiz |

#### 1.11.2. Natija Modal

| Element | Format |
|---------|--------|
| QR Code | 200×200px (PNG/SVG) |
| PIN kod | 6 raqam (katta font) |
| Mehmon ismi | Text |
| Amal qilish muddati | `DD.MM.YYYY HH:mm – DD.MM.YYYY HH:mm` |
| Terminal | Bino + Terminal nomi |
| Foydalanish | `0 / Cheksiz` yoki `0 / 5` |
| Amallar | [📥 Yuklab olish] [📤 Ulashish] [❌ Bekor qilish] |

#### 1.11.3. Mehmonlar Ro'yxati Jadvali

| Kolonna | Width | Sort | Filter |
|---------|-------|------|--------|
| Mehmon ismi | 20% | ✅ | ✅ |
| Host | 20% | ✅ | ✅ |
| Terminal | 15% | ✅ | ✅ |
| Turi (QR/PIN) | 10% | ❌ | ✅ |
| Holat | 10% | ✅ | ✅ |
| Yaratilgan | 12% | ✅ | ✅ |
| Tugash | 12% | ✅ | ✅ |
| Foydalanish | 8% | ✅ | ❌ |
| Amallar | 80px | ❌ | ❌ |

**Holat variantlari:** Aktiv, Ishlatilgan, Muddati tugagan, Bekor qilingan

#### 1.11.4. Pagination

| Parametr | Qiymat |
|----------|--------|
| Default | 25 ta |
| Variantlar | 10, 25, 50, 100 |

---

### 1.12. Foydalanuvchilar (`/users`) — Faqat Super Admin

#### 1.12.1. Filtrlar

| Filter | Turi | Values |
|--------|------|--------|
| Qidiruv | Text | Ism, telefon, email |
| Tashkilot | Select | `organizations` |
| Rol | Multi-select | RBAC roles |
| Holat | Select | active, blocked, pending, deleted |

#### 1.12.2. Jadval Kolonnalari

| Kolonna | Width | Sort |
|---------|-------|------|
| Ism + Avatar | 25% | ✅ |
| Telefon (masked) | 15% | ✅ |
| Tashkilot | 20% | ✅ |
| Rol | 15% | ✅ |
| Oxirgi kirish | 12% | ✅ |
| Holat | 8% | ✅ |
| Amallar | 80px | ❌ |

---

### 1.13. Sozlamalar (`/settings`)

#### 1.13.1. Tablar

| Tab | Elementlar |
|-----|------------|
| Tizim | Platform nomi, Logo, Support contact, Timezone |
| Xavfsizlik | Session timeout, Password policy, 2FA settings |
| Bildirishnomalar | SMS provider, Telegram bot, Email SMTP |
| Backup | Backup schedule, Storage location, Retention policy |
| Audit | Log retention, Access log settings |

#### 1.13.2. Xavfsizlik Sozlamalari

| Sozlama | Turi | Default |
|---------|------|---------|
| Session muddati | Number (daqiqalar) | 60 |
| Max failed login | Number | 5 |
| Lockout duration | Number (daqiqalar) | 15 |
| Min password length | Number | 8 |
| Password expiry | Number (kunlar) | 90 |
| 2FA majburiy | Toggle | Off |

---

## 2. MOBIL ILOVA — SAHIFALAR

### 2.1. Login (`/login`)

| Element | Turi | Eslatma |
|---------|------|---------|
| Logo | Image | Centered |
| Telefon input | Masked Input | +998 format |
| Parol input | Password | Toggle visibility |
| Kirish tugmasi | Button | Full width |
| Parolni unutdim | Link | `/password-reset` |
| Biometrik kirish | Toggle | FaceID/TouchID (keyingi kirishlar uchun) |

---

### 2.2. Home (`/home`)

#### 2.2.1. Header

| Element | Position |
|---------|----------|
| Bino nomi | Left |
| Sana | Below title |
| Notification icon | Right (badge bilan) |
| Profile icon | Right |

#### 2.2.2. Stat Kartalari (Grid 2×2)

| Karta | Data |
|-------|------|
| Kirishlar (bugun) | COUNT today's success |
| Shubhali | COUNT suspicious events |
| Terminallar | Online / Total |
| Rezidentlar | Active count |

#### 2.2.3. So'nggi Voqealar (List)

| Element | Format | Limit |
|---------|--------|-------|
| List item | Icon + Text + Time | 10 ta |
| Load more | Button | Next 10 |

---

### 2.3. Rezidentlar (`/residents`)

#### 2.3.1. Header Actions

| Tugma | Action |
|-------|--------|
| [+] FAB | `/residents/create` |
| [🔍] | Search toggle |
| [Filter] | Filter modal |

#### 2.3.2. Search Bar

| Maydon | Turi |
|--------|------|
| Qidiruv | Text (ism, telefon, xonadon) |
| Bino | Select |
| Holat | Multi-select chips |

#### 2.3.3. List Item

| Element | Format |
|---------|--------|
| Avatar | 48×48px circle |
| Ism | 16px/600 |
| Telefon | 14px/400 (masked) |
| Xonadon | 14px/400 |
| Holat badge | Right side |
| Arrow | Right chevron |

#### 2.3.4. Gestures

| Gesture | Action |
|---------|--------|
| Swipe left | O'chirish (confirm) |
| Swipe right | Tahrirlash |
| Long press | Bulk select mode |
| Tap | Detail view |

#### 2.3.5. Pagination

| Turi | Qiymat |
|------|--------|
| Infinite scroll | ✅ |
| Page size | 20 ta |
| Loading | Skeleton + Spinner |

---

### 2.4. Rezident Qo'shish (Mobile)

#### 2.4.1. Progress Bar

| Qadam | % |
|-------|---|
| 1. Shaxsiy | 25% |
| 2. Joylashuv | 50% |
| 3. Foto | 75% |
| 4. Huquqlar | 100% |

#### 2.4.2. Har Bir Qadam

| Qadam | Maydonlar |
|-------|-----------|
| 1 | Ism, Telefon |
| 2 | Bino (select), Xonadon (number) |
| 3 | Kamera (live preview) + Upload |
| 4 | Terminal (checkbox), Vaqt (optional) |

---

### 2.5. Terminallar (`/terminals`)

#### 2.5.1. Summary Bar

| Element | Format |
|---------|--------|
| Online | 🟢 12 |
| Offline | 🔴 2 |
| Xato | ⚠️ 1 |

#### 2.5.2. Terminal Card

| Element | Format |
|---------|--------|
| Status dot | Color-coded |
| Terminal nomi | 16px/600 |
| Bino | 14px/400 |
| Oxirgi aloqa | 12px/400 (relative time) |
| Rezidentlar | 14px/400 |
| Actions | [⚙️] [🔄] |

---

### 2.6. Hisobotlar (Mobile) (`/reports`)

| Element | Mobile-specific |
|---------|-----------------|
| Davr tanlash | Preset buttons (Bugun, Hafta, Oy) |
| Grafiklar | Vertical scroll, touch zoom |
| Export | Share sheet (iOS/Android native) |
| Table | Horizontal scroll yoki card view |

---

### 2.7. Sozlamalar (Mobile) (`/settings`)

| Bo'lim | Elementlar |
|--------|------------|
| Profil | Ism, Telefon, Email, Avatar |
| Xavfsizlik | Parol o'zgartirish, Biometriya, Session |
| Bildirishnomalar | Push, SMS, Email toggles |
| Ilova | Til, Tema (Light/Dark), Versiya |
| Chiqish | [Logout] button (danger) |

---

## 3. TERMINAL UI — EKRANLAR

### 3.1. Idle State (Kutish)

| Element | Position | Size |
|---------|----------|------|
| Logo | Top center | 80×80px |
| Camera preview | Center | 300×300px circle |
| Instruction text | Below camera | 20px |
| Building name | Bottom | 16px |
| Time/Date | Bottom right | 16px |

---

### 3.2. Success State

| Element | Duration | Animation |
|---------|----------|-----------|
| Green background | 3 soniya | Fade in |
| Check icon | 3 soniya | Scale in |
| Welcome text | 3 soniya | Fade in |
| Name + Apartment | 3 soniya | Slide up |
| Progress bar | 3 soniya | Countdown |

---

### 3.3. Denied State

| Element | Duration | Sound |
|---------|----------|-------|
| Red background | 2 soniya | Beep (500ms) |
| X icon | 2 soniya | — |
| Error text | 2 soniya | — |
| Reason | 2 soniya | — |

---

### 3.4. Admin Settings (PIN/NFC)

| Element | Input Method |
|---------|--------------|
| PIN input | 6-digit numeric keypad |
| NFC | Card tap |
| Settings menu | Touch navigation |
| Remote actions | Button + Confirm |

---

## 4. SEARCH VA FILTRLAR — UMUMIY QOIDALAR

### 4.1. Search Input Specifications

| Parametr | Qiymat |
|----------|--------|
| Debounce | 300ms |
| Min characters | 3 ta |
| Max results (dropdown) | 10 ta |
| Placeholder | "Qidirish..." |
| Clear button | ✅ (X icon) |

### 4.2. Filter Modal Specifications

| Element | Behavior |
|---------|----------|
| Open | Slide from bottom (mobile), Modal (desktop) |
| Apply | [Qo'llash] button → Close + Reload |
| Reset | [Tozalash] button → Defaults + Reload |
| Cancel | [Bekor qilish] → No changes |

### 4.3. Pagination Specifications

| Element | Desktop | Mobile |
|---------|---------|--------|
| Type | Classic (1 2 3 ... 10) | Load More yoki Infinite |
| Page size selector | ✅ | ❌ (fixed 20) |
| Jump to page | ✅ | ❌ |
| Total count | ✅ | ✅ |

---

## 5. ROLE-BASED ACCESS MATRIX (SAHIFALAR BO'YICHA)

| Sahifa | Super Admin | BSK Admin | Operator | GASN | Prokuratura | IIV |
|--------|-------------|-----------|----------|------|-------------|-----|
| Dashboard | ✅ Full | ✅ Own | ✅ Own | ✅ Read | ✅ Limited | ✅ Limited |
| Residents | ✅ CRUD | ✅ CRUD | ✅ CRUD | ❌ | ❌ | ❌ |
| Buildings | ✅ CRUD | ✅ CRUD | 👁️ Read | 👁️ Read | 👁️ Read | 👁️ Read |
| Terminals | ✅ CRUD | ✅ CRUD | 👁️ Read | 👁️ Read | ❌ | ❌ |
| Logs | ✅ Full | ✅ Own | ✅ Own | ✅ All | ✅ Request* | ✅ Request* |
| Reports | ✅ Full | ✅ Own | ✅ Own | ✅ All | ✅ Limited | ✅ Limited |
| Guests | ✅ CRUD | ✅ CRUD | ✅ CRUD | ❌ | ❌ | ❌ |
| Users | ✅ CRUD | ❌ | ❌ | ❌ | ❌ | ❌ |
| Settings | ✅ Full | ✅ Partial | ❌ | ❌ | ❌ | ❌ |

*\*Prokuratura/IIV har bir kirish `security_access_logs` ga yoziladi*

---

## 6. API ENDPOINTS (SAHIFALAR UCHUN)

| Sahifa | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| Login | POST | `/api/auth/login` | Telefon + Parol |
| Dashboard | GET | `/api/dashboard/stats` | Statistika |
| Residents List | GET | `/api/residents` | Pagination + Filters |
| Resident Create | POST | `/api/residents` | Yangi resident |
| Resident Update | PATCH | `/api/residents/:id` | Tahrirlash |
| Resident Delete | DELETE | `/api/residents/:id` | O'chirish |
| Buildings List | GET | `/api/buildings` | Pagination |
| Terminals List | GET | `/api/terminals` | Grid/Table |
| Terminal Detail | GET | `/api/terminals/:id` | 4 tab data |
| Logs List | GET | `/api/logs` | Pagination + Filters |
| Logs Export | POST | `/api/logs/export` | PDF/Excel/CSV |
| Reports | GET | `/api/reports/:type` | Hisobot turi bo'yicha |
| Guests Create | POST | `/api/guests` | QR/PIN yaratish |
| Guests List | GET | `/api/guests` | Pagination |

---

**Hujjat versiyasi:** 1.0 | TT-PAGES-2025-001

**Ushbu hujjat barcha sahifalar uchun to'liq texnik spesifikatsiya bo'lib, developerlar va dizaynerlar uchun asosiy qo'llanma hisoblanadi.**