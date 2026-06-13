# DIZAYN UCHUN TEXNIK TOPSHIRIQ (UI/UX)
## Ko'p Qavatli Binalarda FaceID Kirish Nazorati va Monitoring Tizimi

| Maydon | Qiymat |
|---|---|
| **Hujjat raqami** | TT-DESIGN-2025-001-v2.0 |
| **Versiya** | 2.0 (Qayta ko'rib chiqilgan) |
| **Tuzilgan sana** | 2025-yil |
| **Buyurtmachi** | Boshqaruv service kompaniyalari / GASN / Qurilish boshqarmasi |
| **Bajaruvchi** | Senior Software Architect Team |
| **Holati** | Tasdiqlash uchun tayyor |

---

## 1. UMUMIY MA'LUMOT

### 1.1. Loyiha Maqsadi

Ushbu hujjat ko'p qavatli turar-joy binolarining kirish qismlarida **FaceID (yuz tanish)** texnologiyasi asosida ishlaydigan avtomatlashtirilgan kirish nazorati va monitoring tizimi uchun Web va Mobil ilovalarning UI/UX dizayni bo'yicha texnik talablarni belgilaydi.

**Muhim:** Shaxsiy ma'lumotlar xavfsizligini ta'minlash maqsadida **pasport ma'lumotlari saqlanmaydi**. Identifikatsiya uchun faqat **telefon raqam** ishlatiladi.

### 1.2. Dizayn Qamrovi

| Platforma | Texnologiya | Maqsadli Foydalanuvchilar |
|---|---|---|
| **Web Panel** | React.js 18+ | Adminlar, Operatorlar, Nazorat organlari |
| **Mobil Ilova** | React Native | Rezidentlar, Bino Operatorlari |
| **Terminal UI** | Embedded Linux/Android | Kirish nuqtalaridagi foydalanuvchilar |

### 1.3. Dizayn Tamoyillari

- **Minimalizm** — Keraksiz elementlarsiz, toza va aniq interfeys
- **Accessibility** — WCAG 2.1 AA standartiga to'liq moslik
- **Responsive** — Barcha qurilmalarda to'g'ri ko'rinish (mobile-first yondashuv)
- **Dark Mode** — Qorong'u rejimni to'liq qo'llab-quvvatlash
- **O'zbek tili** — Barcha matnlar o'zbek tilida (lotin/kirill almashuv)
- **Xavfsizlik UX** — Nozik ma'lumotlar (telefon raqamlar) maskalanishi

---

## 2. DIZAYN TIZIMI (DESIGN SYSTEM)

### 2.1. Ranglar Palitasi

#### Asosiy Ranglar

| Rang nomi | Hex | CSS Variable | Ishlatilishi |
|---|---|---|---|
| Primary Blue | `#1E40AF` | `--color-primary` | Asosiy tugmalar, havolalar |
| Primary Dark | `#1E3A8A` | `--color-primary-dark` | Hover holati |
| Primary Light | `#3B82F6` | `--color-primary-light` | Ikkinchi darajali elementlar |
| Success Green | `#10B981` | `--color-success` | Muvaffaqiyatli operatsiyalar, kirish ruxsati |
| Warning Yellow | `#F59E0B` | `--color-warning` | Ogohlantirishlar, oflayn holat |
| Error Red | `#EF4444` | `--color-error` | Xatolar, kirish rad etildi |
| Info Blue | `#3B82F6` | `--color-info` | Ma'lumot xabarlari |

#### Neytral Ranglar

| Rang nomi | Hex | CSS Variable | Ishlatilishi |
|---|---|---|---|
| White | `#FFFFFF` | `--color-white` | Fon, kartochkalar |
| Gray 50 | `#F9FAFB` | `--color-gray-50` | Sekundar fon |
| Gray 100 | `#F3F4F6` | `--color-gray-100` | Border, separator |
| Gray 200 | `#E5E7EB` | `--color-gray-200` | Disabled fon |
| Gray 500 | `#6B7280` | `--color-gray-500` | Ikkinchi darajali matn |
| Gray 700 | `#374151` | `--color-gray-700` | Kuchli ikkinchi matn |
| Gray 900 | `#111827` | `--color-gray-900` | Asosiy matn |

#### Dark Mode Ranglar

| Rang nomi | Hex | CSS Variable | Ishlatilishi |
|---|---|---|---|
| Dark BG | `#0F172A` | `--dark-bg` | Asosiy fon |
| Dark Card | `#1E293B` | `--dark-card` | Kartochka foni |
| Dark Border | `#334155` | `--dark-border` | Borderlar |
| Dark Surface | `#293548` | `--dark-surface` | Hover, aktiv holatlar |
| Dark Text | `#F1F5F9` | `--dark-text` | Asosiy matn |
| Dark Muted | `#94A3B8` | `--dark-muted` | Ikkinchi darajali matn |

#### Holat Ranglari (Terminal statuslari uchun)

| Holat | Rang | Hex |
|---|---|---|
| Online | Yashil | `#10B981` |
| Offline | Qizil | `#EF4444` |
| Maintenance | To'q sariq | `#F59E0B` |
| Error | Qizil miltillovchi | `#EF4444` + animation |
| Sync pending | Ko'k | `#3B82F6` |

### 2.2. Tipografiya

**Font oilasi:** `Inter` (asosiy) → `system-ui` → `sans-serif`

| Element | Desktop | Mobile | Weight | Line Height | Ishlatilishi |
|---|---|---|---|---|---|
| H1 — Sahifa sarlavhasi | 32px | 24px | 700 | 1.2 | Sahifa nomi |
| H2 — Bo'lim sarlavhasi | 24px | 20px | 600 | 1.2 | Bo'lim nomi |
| H3 — Kichik sarlavha | 20px | 18px | 600 | 1.3 | Subseksiya |
| H4 — Widget sarlavha | 16px | 15px | 600 | 1.3 | Karta sarlavhasi |
| Body — Asosiy matn | 16px | 14px | 400 | 1.5 | Paragraf |
| Small — Kichik matn | 14px | 12px | 400 | 1.4 | Yordamchi ma'lumot |
| Caption — Izoh | 12px | 11px | 400 | 1.4 | Vaqt, meta |
| Button | 16px | 14px | 500 | 1.0 | Tugma matni |
| Label | 14px | 13px | 500 | 1.2 | Form yorliqlari |
| Code / Monospace | 14px | 13px | 400 | 1.5 | ID, token, API |

### 2.3. Grid va Layout

#### Breakpointlar

| Breakpoint | Kenglik | Kolonnalar | Sidebar |
|---|---|---|---|
| Mobile Small | < 375px | 1 | Yo'q |
| Mobile | 375px – 767px | 1 | Yo'q |
| Tablet | 768px – 1023px | 2 | Yig'iladigan |
| Desktop Small | 1024px – 1279px | 3 | 240px |
| Desktop | 1280px – 1439px | 4 | 260px |
| Desktop Large | ≥ 1440px | 4 + sidebar | 280px |

#### Spacing tizimi (8px grid)

```
--spacing-1:  4px
--spacing-2:  8px
--spacing-3:  12px
--spacing-4:  16px
--spacing-5:  20px
--spacing-6:  24px
--spacing-8:  32px
--spacing-10: 40px
--spacing-12: 48px
--spacing-16: 64px
```

#### Container kengliklari

```
max-width: 1440px (Desktop Large)
padding-x: 24px (Desktop), 16px (Tablet), 16px (Mobile)
gap (grid): 24px (Desktop), 16px (Tablet), 12px (Mobile)
```

### 2.4. Komponentlar Kutubxonasi

#### Tugmalar (Buttons)

| Turi | Balandlik | Padding | Border Radius | Font |
|---|---|---|---|---|
| Primary Large | 56px | 24px 32px | 8px | 18px/500 |
| Primary Medium | 44px | 16px 24px | 6px | 16px/500 |
| Primary Small | 36px | 12px 16px | 4px | 14px/500 |
| Secondary Medium | 44px | 16px 24px | 6px | 16px/500 |
| Ghost Medium | 44px | 16px 24px | 6px | 16px/500 |
| Danger Medium | 44px | 16px 24px | 6px | 16px/500 |
| Icon Button | 44×44px | 0 | 50% (aylana) | — |

**Button holatlari:**

| Holat | Effekt |
|---|---|
| Default | Asosiy rang |
| Hover | Fon 10% to'qroq, `cursor: pointer` |
| Active / Pressed | `scale(0.98)` |
| Focus | `ring 2px Primary Color`, `outline-offset: 2px` |
| Disabled | `opacity: 50%`, `cursor: not-allowed` |
| Loading | Spinner + disabled |

#### Input Maydonlari

| Element | Balandlik | Border Radius | Border | Focus border |
|---|---|---|---|---|
| Text Input | 44px | 6px | 1px Gray 200 | 2px Primary Blue |
| Password Input | 44px | 6px | 1px Gray 200 | 2px Primary Blue |
| Phone Input (mask) | 44px | 6px | 1px Gray 200 | 2px Primary Blue |
| Select Dropdown | 44px | 6px | 1px Gray 200 | 2px Primary Blue |
| Multi-Select | 44px min | 6px | 1px Gray 200 | 2px Primary Blue |
| Search Input | 44px | 22px (pill) | 1px Gray 200 | 2px Primary Blue |
| Textarea | Auto (min 88px) | 6px | 1px Gray 200 | 2px Primary Blue |
| Date Picker | 44px | 6px | 1px Gray 200 | 2px Primary Blue |

**Form validation holatlari:**

| Holat | Visual |
|---|---|
| Valid | Yashil border + ✓ icon |
| Invalid | Qizil border + ✗ icon + xato matni (12px) |
| Required | `*` belgisi + label |
| Optional | "(ixtiyoriy)" + label |
| Loading | Input disabled + spinner |

#### Kartochkalar (Cards)

```
Background: #FFFFFF (Light) / #1E293B (Dark)
Border: 1px solid #E5E7EB (Light) / #334155 (Dark)
Border Radius: 12px
Box Shadow: 0 1px 3px rgba(0,0,0,0.1)
Padding: 24px (Desktop) / 16px (Mobile)

Hover (interactive cards):
  Box Shadow: 0 4px 12px rgba(0,0,0,0.15)
  Transform: translateY(-2px)
  Transition: 200ms ease
```

#### Jadvallar (Tables)

```
Header:
  Background: #F9FAFB
  Font: 12px/600, uppercase, Gray 500
  Padding: 12px 16px
  Border-bottom: 2px solid #E5E7EB

Row:
  Padding: 16px
  Border-bottom: 1px solid #F3F4F6
  Height: 56px min

Row Hover:
  Background: #F9FAFB
  Transition: 100ms

Selected Row:
  Background: #EFF6FF (Blue 50)
```

#### Modallar (Dialogs)

```
Overlay: rgba(0,0,0,0.5), backdrop-blur: 4px
Container:
  Max-width: 480px (small), 640px (medium), 800px (large)
  Border-radius: 16px
  Padding: 32px
  Max-height: 90vh, overflow-y: auto
Animation: scale(0.95)→scale(1), opacity 0→1, 200ms ease
```

### 2.5. Iconografiya

- **Kutubxona:** Heroicons v2.0 (birlamchi) yoki Lucide Icons
- **Stil:** Outline (asosiy ko'rinish), Filled (aktiv/tanlangan holat)
- **O'lchamlar:** 16px (inline), 20px (button/list), 24px (navigation), 32px (empty state)
- **Rang:** `currentColor` (matn rangiga avtomatik mos)
- **Terminal holati ikonlari:**
  - Online: `signal` yoki `wifi` — yashil
  - Offline: `signal-slash` — qizil
  - Maintenance: `wrench` — to'q sariq
  - Error: `exclamation-triangle` — qizil, miltillovchi

### 2.6. Animatsiyalar va Mikro-interaksiyalar

#### Page transitions

```css
.page-enter {
  opacity: 0;
  transform: translateY(8px);
}
.page-enter-active {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 200ms ease, transform 200ms ease;
}
```

#### Notification (Toast)

| Turi | Ko'rinish muddati | Joylashuvi | Rang |
|---|---|---|---|
| Success | 3s (avtomatik) | Yuqori o'ng | Yashil |
| Error | 5s + qo'lda yopish | Yuqori o'ng | Qizil |
| Warning | 5s + qo'lda yopish | Yuqori o'ng | To'q sariq |
| Info | 3s (avtomatik) | Yuqori o'ng | Ko'k |

#### Loading holatlari

- **Skeleton screen** — kontent yuklanayotganda (shimmer effekt)
- **Spinner** — amal bajarilayotganda (tugma ichida)
- **Progress bar** — fayl yuklashda (page top-da)
- **Pull-to-refresh** — mobil ro'yxatlarda

---

## 3. WEB PANEL DIZAYNI

### 3.1. Global Layout

```
┌──────────────────────────────────────────────────────────┐
│  HEADER (64px)                                           │
│  [Logo] [Breadcrumb]        [Search] [Notif] [Profile]  │
├────────────────┬─────────────────────────────────────────┤
│                │                                         │
│  SIDEBAR       │  MAIN CONTENT                           │
│  (260px)       │  (fluid width)                          │
│                │                                         │
│  - Dashboard   │  ┌──────────────────────────────┐      │
│  - Rezidentlar │  │  Page Header (Title + Actions)│      │
│  - Binolar     │  └──────────────────────────────┘      │
│  - Terminallar │                                         │
│  - Loglar      │  [Page Content Area]                    │
│  - Hisobotlar  │                                         │
│  - Sozlamalar  │                                         │
│                │                                         │
└────────────────┴─────────────────────────────────────────┘
```

**Header spesifikatsiyasi:**
- Balandligi: 64px
- Background: White / Dark Card
- Border-bottom: 1px Gray 100
- Position: sticky top-0, z-index: 100

**Sidebar spesifikatsiyasi:**
- Kenglik: 260px (desktop), 240px (small desktop)
- Mobil: overlay (drawer) ko'rinishda
- Aktiv element: Primary Blue fon, oq matn, 6px border-left indikator
- Yig'ilish: tablet va pastda hamburger menu

### 3.2. Sidebar Navigatsiya

| Bo'lim | Icon | Ruxsat darajasi | Submenyu |
|---|---|---|---|
| Dashboard | `chart-bar` | Barcha rollar | Yo'q |
| Rezidentlar | `users` | BSK Admin, Operator | Qo'shish, Ro'yxat |
| Binolar | `building-office` | BSK Admin, GASN, Operator | Ro'yxat |
| Terminallar | `device-phone-mobile` | BSK Admin, Operator | Ro'yxat, Monitoring |
| Kirish Loglari | `clipboard-document-list` | Barcha rollar | — |
| Hisobotlar | `chart-pie` | BSK Admin, GASN, Prokuratura, IIV | — |
| Foydalanuvchilar | `user-group` | Faqat Super Admin | — |
| Sozlamalar | `cog` | Super Admin, BSK Admin | Tizim, Xavfsizlik |

### 3.3. Asosiy Sahifalar

#### 3.3.1. Dashboard (Asosiy Ko'rinish)

**Maqsad:** Real-time statistika va tizim holatini tezkor ko'rish

**Statistika kartalari (1-qator — 4 karta):**

| Karta | Ma'lumot | Icon | Rang |
|---|---|---|---|
| Bugungi kirishlar | Muvaffaqiyatli kirish soni | `door-open` | Ko'k |
| Rad etilganlar | Tanilmagan urinishlar | `x-circle` | Qizil |
| Aktiv terminallar | Online / Jami | `signal` | Yashil |
| Aktiv rezidentlar | Faol shaxslar soni | `users` | Ko'k |

**Karta tuzilishi:**
```
┌─────────────────────────┐
│  [Icon]    [Trend ↑↓]   │
│                         │
│  1,234                  │  ← Asosiy raqam (32px/700)
│  Bugungi kirishlar      │  ← Sarlavha (14px/500)
│  ▲ 12% o'tgan haftadan  │  ← Trend (12px, yashil/qizil)
└─────────────────────────┘
```

**2-qator — Grafik va Xarita:**

```
┌──────────────────────────────┬───────────────────────────┐
│  Kirish Trendi (7 kun)       │  Terminal Xaritasi        │
│  [Line Chart]                │  [Leaflet/Mapbox Map]      │
│  - Muvaffaqiyatli kirishlar  │  • Online terminalar       │
│  - Rad etilgan               │  • Offline terminalar      │
│  X: sana, Y: soni            │  Zoom, cluster support     │
└──────────────────────────────┴───────────────────────────┘
```

**3-qator — Lentalar:**

```
┌──────────────────────────────┬───────────────────────────┐
│  So'nggi Voqealar (real-time)│  Shubhali Voqealar        │
│  [WebSocket yangilanadi]     │  [Alohida widget]          │
│  • 14:32 — Abdullayev kirdi  │  ⚠ Terminal-3: 5 urinish  │
│  • 14:31 — Tanilmagan [foto] │  ⚠ Terminal-7: oflayn     │
│  • 14:30 — Terminal online   │  Barcha → [Ko'rish]        │
└──────────────────────────────┴───────────────────────────┘
```

**Responsive talablar:**
- Desktop: 4 statistika kartasi bir qatorda
- Tablet: 2×2 grid
- Mobile: 1×4 (vertikal stack)

#### 3.3.2. Rezidentlar Ro'yxati

**Maqsad:** Rezidentlarni boshqarish (CRUD amallar)

**Filtrlar paneli (top bar):**

```
[🔍 Qidirish: ism / telefon / xonadon]  [Bino ▼]  [Holat ▼]  [Sana ▼]  [Tozalash]
```

**Jadval kolonnalari:**

| Kolonna | Kenglik | Saralash | Filtrlash | Eslatma |
|---|---|---|---|---|
| ☐ (checkbox) | 40px | — | — | Bulk select |
| Avatar + Ism-sharif | 25% | ✅ | ✅ | Foto thumbnail + to'liq ism |
| Telefon | 15% | ✅ | ✅ | Maskalangan: `+998 90 *** 12 34` |
| Bino / Xonadon | 20% | ✅ | ✅ | `Chilonzor-14 / 35-xonadon` |
| Qavat | 8% | ✅ | — | |
| Holat | 10% | ✅ | ✅ | Badge: aktiv/bloklangan/arxiv |
| Qo'shilgan sana | 12% | ✅ | ✅ | `21.03.2025` |
| Amallar | 80px | — | — | [✏️] [🔒] [⋮] |

**Holat badge'lari:**

| Holat | Rang | DB qiymati |
|---|---|---|
| Aktiv | Yashil | `active` |
| Bloklangan | Qizil | `blocked` |
| Arxivlangan | Kulrang | `archived` |
| O'chirilgan | Qizil/italic | `deleted` |

**Bulk amallar paneli (tanlanganda paydo bo'ladi):**

```
[3 ta tanlandi]  [Ko'chirish ▼]  [Bloklash]  [O'chirish]  [Bekor qilish]
```

**Rezident Kartochkasi Modal (ko'rish/tahrirlash):**

```
┌─────────────────────────────────────────────────────────┐
│  [←] Rezident Ma'lumotlari                    [✏️] [✕]  │
├──────────────────┬──────────────────────────────────────┤
│                  │  To'liq ism:  Abdullayev Jasur       │
│  [Foto/Avatar]   │  Telefon:     +998 90 *** 12 34      │
│  120×120px       │  Bino:        Chilonzor-14           │
│                  │  Xonadon:     35 (4-qavat)           │
│  [Yangilash]     │  Holat:       🟢 Aktiv               │
│                  │  Qo'shilgan:  21.03.2025             │
├──────────────────┴──────────────────────────────────────┤
│  KIRISH HUQUQLARI                                        │
│  Terminal-1 (Kirish): ✅ Aktiv  |  07:00 – 23:00        │
│  Terminal-2 (Orqa):   ✅ Aktiv  |  Cheksiz              │
├──────────────────────────────────────────────────────────┤
│  SO'NGGI KIRISHLAR (Oxirgi 5 ta)                         │
│  [Vaqt]        [Terminal]    [Holat]      [Foto]         │
│  21.03 14:32   Terminal-1    ✅ Kirdi     [👁️]           │
│  20.03 09:15   Terminal-1    ✅ Kirdi     [👁️]           │
├──────────────────────────────────────────────────────────┤
│        [Bloklash]    [Ko'chirish]    [O'chirish]          │
└──────────────────────────────────────────────────────────┘
```

**Rezident Qo'shish/Tahrirlash Formasi:**

```
Qadamlar (Stepper):
  [1. Shaxsiy ma'lumotlar] → [2. Joylashuv] → [3. Yuz foto] → [4. Kirish huquqlari]

Qadам 1: Shaxsiy ma'lumotlar
  - To'liq ism-sharif * (text input)
  - Telefon raqami * (masked: +998 __ ___ __ __)
  [Pasport ustuni mavjud emas]

Qadам 2: Joylashuv
  - Bino tanlash * (select, qidiruv bilan)
  - Xonadon raqami * (number input)
  - Qavat * (auto-hisoblanadi yoki manual)

Qadам 3: Yuz foto
  - Kamera orqali olish YOKI fayl yuklash
  - Kamida 2 ta foto talab qilinadi
  - Turli burchak ko'rsatmasi + preview
  - Sifat baholash (quality score indicator)

Qadам 4: Kirish huquqlari
  - Terminal tanlash (checkbox ro'yxat)
  - Vaqt oralig'i (ixtiyoriy): 07:00 – 23:00
  - Kirish muddati (ixtiyoriy): tugash sanasi
```

#### 3.3.3. Terminallar Boshqaruvi

**Maqsad:** FaceID qurilmalarini monitoring va boshqarish

**Terminal Kartasi (Grid view — asosiy ko'rinish):**

```
┌─────────────────────────────────────┐
│  🟢 ONLINE        Terminal-1        │
│  ─────────────────────────────────  │
│  📍 Chilonzor-14, Asosiy kirish     │
│  🔢 SN: FID-2025-001                │
│  📡 IP: 192.168.1.101               │
│  🔄 Sinxron: 2 daqiqa oldin         │
│  👥 Rezidentlar: 145 / 200          │
│  ───────────────────────────────    │
│  [⚙️ Sozlash]  [🔄 Sinxron]  [⋮]   │
└─────────────────────────────────────┘
```

**Holat Indikatorlari:**

| Holat | Rang | Icon | Animatsiya |
|---|---|---|---|
| Online | `#10B981` (Yashil) | `●` | Yo'q |
| Offline | `#EF4444` (Qizil) | `●` | Yo'q |
| Maintenance | `#F59E0B` (To'q sariq) | `⚙️` | Yo'q |
| Error | `#EF4444` (Qizil) | `⚠️` | Pulse miltillash |
| Syncing | `#3B82F6` (Ko'k) | `↻` | Aylana |

**Terminal Detail Modal:**

```
Tablar: [Umumiy] [Rezidentlar] [Loglar] [Sozlamalar]

[Umumiy]:
  - Model, serial raqam, firmware versiyasi
  - IP manzil, MAC manzil
  - Oxirgi heartbeat vaqti
  - Uptime statistikasi (grafik)
  - Sinxronizatsiya holati: server vs lokal farq

[Rezidentlar]:
  - Bu terminaldagi rezidentlar ro'yxati
  - Qo'shish / O'chirish imkoniyati

[Loglar]:
  - Faqat shu terminal voqealari
  - Filtrlash imkoniyati

[Sozlamalar]:
  - Yuz tanish sezgirligi (slider)
  - Liveness detection: on/off
  - Kirish vaqt oralig'i
  - Volume, ekran yorqinligi
  - [Remote Restart]  [Remote Lock]
```

#### 3.3.4. Kirish Loglari

**Maqsad:** Barcha kirish voqealarini ko'rish va filtrlash

**Filtrlar paneli:**

```
[📅 Sana oralig'i]  [🏢 Bino ▼]  [📱 Terminal ▼]  [🎯 Voqea turi ▼]  [🔍 Shaxs/telefon]
[Qo'llash]  [Tozalash]  [📥 Export: PDF | Excel | CSV]
```

**Log Jadvali:**

| Kolonna | Kontent | Format |
|---|---|---|
| Vaqt | Sana va soat | `21.03.2025 14:32:15` |
| Terminal | Bino + terminal ID | `Chilonzor-14 / T-1` |
| Shaxs | Ism + Telefon | `Abdullayev J.` + `+998 90 *** 12 34` |
| Voqea Turi | Event badge | `✅ KIRDI` / `❌ RAD ETILDI` / `⚠️ SHUBHALI` |
| Qaror sababi | Qisqa izoh | `Tanishdi` / `Tanilmadi` / `Liveness fail` |
| Foto | Thumbnail | `[👁️ Ko'rish]` |

**Voqea turi badge'lari:**

| Voqea | Badge rangi | Matn |
|---|---|---|
| `DOOR_OPEN_SUCCESS` | Yashil | ✅ Kirdi |
| `DOOR_OPEN_DENIED` | Qizil | ❌ Rad etildi |
| `DOOR_OPEN_MANUAL` | Ko'k | 🔑 Qo'lda ochildi |
| `LIVENESS_FAIL` | To'q sariq | ⚠️ Liveness xatosi |
| `SUSPICIOUS_ATTEMPT` | Qizil + bold | 🚨 Shubhali |
| `DOOR_FORCED` | Qizil + bold | 🚨 Majburiy ochildi |
| `DEVICE_ONLINE` | Yashil/kulrang | 📡 Terminal online |
| `DEVICE_OFFLINE` | Kulrang | 📡 Terminal offline |
| `SYNC_COMPLETE` | Ko'k | 🔄 Sinxron tugadi |

**Foto Ko'rish Modal:**

```
┌─────────────────────────────────────────────────────────┐
│  Kirish Fotosi                                    [✕]   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│           [Yuz fotosi — tam o'lchamda]                   │
│                                                          │
├─────────────────────────────────────────────────────────┤
│  Vaqt:     21.03.2025  14:32:15                         │
│  Terminal: Chilonzor-14, Asosiy kirish                  │
│  Shaxs:    Abdullayev Jasur (Tanildi)                   │
│  Aniqliq:  98.7%                                        │
│  Holat:    ✅ Kirish ruxsat etildi                       │
│                                                          │
│  [📥 Yuklab olish]                    [← Oldingi] [→ Keyingi] │
└─────────────────────────────────────────────────────────┘
```

> **Xavfsizlik:** Foto ko'rish faqat vakolatli foydalanuvchilar uchun. Prokuratura va IIV uchun — har bir ko'rish `security_access_logs` jadvaliga yoziladi.

#### 3.3.5. Hisobotlar va Analitika

**Hisobot Turlari:**

| Hisobot | Davriyligi | Ma'lumot | Export |
|---|---|---|---|
| Kunlik kirish | Kun | Saatlik grafik, jami soni | PDF, Excel |
| Haftalik trend | 7 kun | Kunlik taqqoslama | PDF, Excel |
| Oylik statistika | Oy | To'liq tahlil | PDF, Excel, CSV |
| Terminal faollik | Tanlanadi | Uptime %, xatolar | PDF |
| Shubhali voqealar | Tanlanadi | Xavfsizlik hisoboti | PDF |

**Hisobot Sahifasi Layout:**

```
┌────────────────────────────────────────────────────────────┐
│  Hisobotlar                        [📅 Davr tanlash]       │
├────────────────────────────────────────────────────────────┤
│  [Kunlik] [Haftalik] [Oylik] [Terminal] [Xavfsizlik]       │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Jami kirishlar: 12,450  |  Muvaffaqiyatli: 12,210 (98%)  │
│  Rad etildi: 240  |  Shubhali: 12  |  Oflayn vaqt: 0.3%   │
│                                                            │
├──────────────────────────────┬─────────────────────────────┤
│  Kunlik trend (Line Chart)   │  Terminallar holati (Bar)   │
├──────────────────────────────┴─────────────────────────────┤
│  Top 10 faol bino (jadval)                                 │
│  Soatlar kesimida taqsimot (Heatmap)                       │
├────────────────────────────────────────────────────────────┤
│        [📄 PDF]  [📊 Excel]  [📋 CSV]  [📧 Email]          │
└────────────────────────────────────────────────────────────┘
```

#### 3.3.6. Autentifikatsiya Sahifalari

**Login Sahifasi:**

```
┌─────────────────────────────────────┐
│                                     │
│         [BSK Logo]                  │
│    FaceID Kirish Nazorati Tizimi    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  +998  [__ ___ __ __]       │   │  ← Telefon raqam
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  ••••••••          [👁️]    │   │  ← Parol
│  └─────────────────────────────┘   │
│                                     │
│  [Parolni unutdingizmi?]            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │       Kirish                │   │  ← Primary Large button
│  └─────────────────────────────┘   │
│                                     │
│  5 marta xato: 15 daqiqa blok      │
└─────────────────────────────────────┘
```

**OTP Tasdiqlash (Parol tiklash):**

```
┌─────────────────────────────────────┐
│  [←]  SMS Tasdiqlash                │
│                                     │
│  +998 90 *** 12 34 ga               │
│  6 raqamli kod yuborildi            │
│                                     │
│  ┌────┐  ┌────┐  ┌────┐            │
│  │  _ │  │  _ │  │  _ │  ...       │  ← 6 alohida input
│  └────┘  └────┘  └────┘            │
│                                     │
│  Kod kelmadimi?  [Qayta yuborish]   │
│  (Qayta yuborish: 00:45 keyin)      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Tasdiqlash             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 3.4. Foydalanuvchi Rollari Bo'yicha Ko'rinish

| Sahifa | Super Admin | BSK Admin | Operator | GASN | Prokuratura | IIV |
|---|---|---|---|---|---|---|
| Dashboard | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha (faqat ko'rish) | ✅ Cheklangan | ✅ Cheklangan |
| Rezidentlar | ✅ CRUD | ✅ CRUD | ✅ CRUD | ❌ | ❌ | ❌ |
| Binolar | ✅ CRUD | ✅ CRUD | 👁️ Ko'rish | 👁️ Ko'rish | 👁️ Ko'rish | 👁️ Ko'rish |
| Terminallar | ✅ CRUD | ✅ CRUD | 👁️ Ko'rish | 👁️ Ko'rish | ❌ | ❌ |
| Kirish Loglari | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha | ✅ So'rov asosida* | ✅ So'rov asosida* |
| Hisobotlar | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha | ✅ Cheklangan | ✅ Cheklangan |
| Foydalanuvchilar | ✅ CRUD | ❌ | ❌ | ❌ | ❌ | ❌ |
| Sozlamalar | ✅ To'liq | ✅ Cheklangan | ❌ | ❌ | ❌ | ❌ |

> *Prokuratura va IIV uchun ma'lumotlarga har bir kirish `security_access_logs` jadvalida qayd etiladi. Har bir so'rov uchun hujjat raqami kiritilishi talab etiladi.

---

## 4. MEHMON KIRISH MODULI (Web Panel)

**Maqsad:** Vaqtinchalik kirish kodi yaratish

**Mehmon Kirish Formasi:**

```
┌─────────────────────────────────────────────────────────┐
│  Vaqtinchalik Kirish Yaratish                           │
├─────────────────────────────────────────────────────────┤
│  Mehmon ismi:       [_________________________]         │
│  Terminal:          [Chilonzor-14, T-1       ▼]        │
│  Kirish turi:       ○ QR-kod  ● PIN (6 xona)           │
│  Amal qilish:       [📅 Boshlanish] – [📅 Tugash]       │
│  Foydalanish soni:  ○ 1 marta  ○ 5 marta  ● Cheksiz    │
├─────────────────────────────────────────────────────────┤
│              [Bekor qilish]   [Yaratish]                │
└─────────────────────────────────────────────────────────┘
```

**Natija ko'rinishi:**

```
┌─────────────────────────────────────────────────────────┐
│  ✅ Mehmon kirish yaratildi                              │
│                                                          │
│  [QR Code]     PIN: 849 372                             │
│  (200×200px)                                             │
│                                                          │
│  Amal qilish:  21.03.2025 15:00 – 21.03.2025 20:00     │
│  Terminal:     Chilonzor-14, Asosiy kirish              │
│                                                          │
│  [📥 QR Yuklab olish]  [📤 Ulashish]  [❌ Bekor qilish] │
└─────────────────────────────────────────────────────────┘
```

---

## 5. MOBIL ILOVA DIZAYNI (React Native)

### 5.1. Navigatsiya Tuzilishi

**Bottom Tab Bar (5 tab):**

```
┌─────────────────────────────────────────────────────────┐
│  [🏠 Asosiy]  [👥 Rezidentlar]  [📱 Terminallar]  [📊 Hisobotlar]  [⚙️ Sozlamalar] │
└─────────────────────────────────────────────────────────┘
```

- Aktiv tab: Primary Blue rang + to'ldirilgan icon
- Badge: bildirishnomalar soni (qizil dot)
- Safe area inset (iOS) hisobga olinishi

### 5.2. Asosiy Ekranlar

#### 5.2.1. Home (Asosiy)

```
┌─────────────────────────────────────┐  Status bar
│  BSK FaceID           [🔔 3]  [👤]  │  ← Header (safe area)
├─────────────────────────────────────┤
│  Bugun, 21 mart 2025                │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │  1,234      │  │  5          │  │  ← Stat cards
│  │  Kirishlar  │  │  Shubhali   │  │
│  └─────────────┘  └─────────────┘  │
│  ┌─────────────┐  ✅ 12 / 15 online │
│  │  Terminallar│                    │
│  └─────────────┘                   │
│                                     │
│  ── So'nggi Voqealar ──            │
│  ┌─────────────────────────────┐   │
│  │ ✅ 14:32 — Abdullayev kirdi  │   │
│  │ ❌ 14:31 — Tanilmagan [foto] │   │
│  │ ✅ 14:29 — Yusupov kirdi    │   │
│  └─────────────────────────────┘   │
│  [Barchasini ko'rish]               │
└─────────────────────────────────────┘  Home indicator
```

#### 5.2.2. Rezidentlar (Mobile)

```
┌─────────────────────────────────────┐
│  Rezidentlar           [+] [🔍]     │
├─────────────────────────────────────┤
│  ┌ Qidirish...                    ┐ │
│  └────────────────────────────────┘ │
│  [Barchasi ▾]  [Aktiv ▾]  [Bino ▾] │  ← Filter chips
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Foto] Abdullayev Jasur    →│   │
│  │        +998 90 *** 12 34    │   │
│  │        Chilonzor-14 / 35-x  │   │
│  │        🟢 Aktiv              │   │
│  └─────────────────────────────┘   │
│  ← swipe: [🗑️ O'chirish]           │
│  → swipe: [✏️ Tahrirlash]          │
│                                     │
└─────────────────────────────────────┘
                                        [+ FAB]  ← Floating action button
```

#### 5.2.3. Rezident Qo'shish (Mobile)

```
Qadamlar (top progress bar):
●──●──○──○  (1 / 4 qadam)

┌─────────────────────────────────────┐
│  [←]  Rezident Qo'shish  (1/4)     │
│  ━━━━━━━━━━━━━━━━━━───────────────  │  ← Progress 25%
│                                     │
│  To'liq ism-sharif *               │
│  ┌─────────────────────────────┐   │
│  │  Abdullayev Jasur           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Telefon raqami *                   │
│  ┌─────────────────────────────┐   │
│  │  +998 │ (90) 123-45-67     │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Pasport ma'lumotlari talab qilinmaydi] │
│                                     │
│              [Keyingi →]            │
└─────────────────────────────────────┘
```

#### 5.2.4. Terminal Holati (Mobile)

```
┌─────────────────────────────────────┐
│  Terminallar                [🔄]    │
├─────────────────────────────────────┤
│  12 Online  |  2 Offline  |  1 Xato │  ← Summary bar
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🟢 Terminal-1              │   │
│  │  Chilonzor-14, Asosiy kirish│   │
│  │  Oxirgi: 2 daqiqa oldin     │   │
│  │  Rezidentlar: 145           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🔴 Terminal-3              │   │
│  │  Yunusobod-8, Kirish        │   │
│  │  Oxirgi: 3 soat oldin       │   │
│  │  [⚠️ Sinxronlash kerak]     │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 5.3. Mobile UX Talablari

**Gesture'lar:**

| Gesture | Harakat |
|---|---|
| Swipe Left (ro'yxat elementi) | O'chirish / Bloklash (confirm dialog kerak) |
| Swipe Right (ro'yxat elementi) | Tahrirlash |
| Pull to Refresh | Ma'lumotlarni yangilash |
| Long Press | Bulk tanlash rejimi |
| Tap | Detail ko'rinishi |
| Pinch to zoom | Foto ko'rishda |

**Touch Target standartlari:**
- Minimal o'lcham: **44×44 px** (Apple HIG)
- Optimal o'lcham: **48×48 px** (Material Design)
- Elementlar orasidagi minimal masofa: **8px**

**Loading holatlari:**
- Skeleton screens — kontent yuklanayotganda
- Pull-to-refresh indikator
- Infinite scroll — uzun ro'yxatlar uchun
- Progress bar — fayl va foto yuklashda

**Xato holatlari:**
- Network error: "Internet aloqasi yo'q" + [Qayta urinish]
- Empty state: Mos icon + qisqa matn + harakat tugmasi
- 403 Forbidden: "Ruxsat yo'q" xabari
- 500 Server error: "Xatolik yuz berdi" + murojaat kodi

---

## 6. TERMINAL UI DIZAYNI (Embedded Linux/Android)

### 6.1. Asosiy Ekran — Kutish holati (Idle State)

```
┌────────────────────────────────┐  7" IPS Display (1024×600)
│                                │
│                                │
│         [BSK Logo]             │
│                                │
│   [Kamera ko'rinishi — circle] │  ← Real-time kamera preview
│         (300×300px)            │
│                                │
│  ┌──────────────────────────┐ │
│  │  Yuzingizni ko'rsating   │ │  ← 20px, oq matn
│  └──────────────────────────┘ │
│                                │
│  ────────────────────────────  │
│  Chilonzor-14, Asosiy kirish  │  ← Bino nomi
│  14:32  │  21 Mart 2025       │  ← Vaqt/sana (real-time)
└────────────────────────────────┘
```

### 6.2. Kirish Ruxsat Etildi (Success)

```
┌────────────────────────────────┐
│                                │
│  ┌──────────────────────────┐ │
│  │                          │ │
│  │       ✅                 │ │  ← Katta yashil check icon
│  │   Xush kelibsiz!         │ │  ← 24px, oq
│  │                          │ │
│  │   Abdullayev Jasur       │ │  ← Ism (20px/600)
│  │   35-xonadon, 4-qavat    │ │  ← Xonadon
│  │                          │ │
│  └──────────────────────────┘ │
│                                │
│  🚪 Eshik ochildi             │  ← Animatsiya bilan
│                                │
│  [3 soniyada yopiladi...]     │  ← Countdown progress bar
└────────────────────────────────┘
Fon rangi: #10B981 (Yashil)
Davomiyligi: 3 soniya, so'ng idle ga qaytadi
```

### 6.3. Kirish Rad Etildi (Denied)

```
┌────────────────────────────────┐
│                                │
│  ┌──────────────────────────┐ │
│  │                          │ │
│  │       ❌                 │ │  ← Katta qizil X icon
│  │  Kirish ruxsat etilmadi  │ │  ← 24px, oq
│  │                          │ │
│  │  [Sabab kodi / matn]     │ │  ← Tanilmadi / Vaqt tugadi
│  │                          │ │
│  └──────────────────────────┘ │
│                                │
│  [2 soniyada yopiladi...]     │
└────────────────────────────────┘
Fon rangi: #EF4444 (Qizil)
Davomiyligi: 2 soniya
Ovozli signal: qisqa ogohlantiruv beep
```

### 6.4. Liveness Detection Xatosi

```
Fon rangi: #F59E0B (To'q sariq / Ogohlantirish)
Icon: ⚠️
Matn: "Faqat jonli shaxs uchun"
Davomiyligi: 2 soniya
```

### 6.5. Terminal Sozlamalari (Admin kirish)

```
Admin kirish: PIN (6 raqam) yoki NFC karta
┌────────────────────────────────┐
│  ⚙️ Terminal Sozlamalari       │
├────────────────────────────────┤
│  Tarmoq:     192.168.1.101     │
│  Server:     ✅ Ulangan        │
│  Rezidentlar: 145              │
│  Sinxron:    2 daqiqa oldin    │
├────────────────────────────────┤
│  Sezgirlik:  ●●●●○  (4/5)     │
│  Liveness:   ✅ Yoqilgan       │
│  Volume:     ●●●○○  (3/5)     │
├────────────────────────────────┤
│  [🔄 Sinxronlash]              │
│  [🔄 Qayta ishga tushirish]    │
│  [❌ Chiqish]                  │
└────────────────────────────────┘
```

---

## 7. ACCESSIBILITY (A11Y) TALABLAR

### 7.1. Vizual Accessibility (WCAG 2.1 AA)

| Talab | Minimal daraja | Maqsadli daraja |
|---|---|---|
| Kontrast (kichik matn) | 4.5 : 1 | 7 : 1 |
| Kontrast (katta matn ≥18px) | 3 : 1 | 4.5 : 1 |
| Minimal font o'lchami | 14px | 16px |
| Focus indikatori | 2px ring | 3px ring + offset |
| Touch target (mobile) | 44×44px | 48×48px |

- **Rang ko'rish nuqsoni:** Rangdan tashqari icon yoki matn ham ishlatish
- **User scalable:** `font-size` va `zoom` o'zgartirish imkoniyati (max-scale cheklovchi meta tegs yo'q)

### 7.2. Screen Reader qo'llab-quvvatlash

```html
<!-- Ikonlarda -->
<button aria-label="Rezident qo'shish">
  <PlusIcon />
</button>

<!-- Dinamik kontentda -->
<div aria-live="polite" aria-atomic="true">
  {notification}
</div>

<!-- Skip link -->
<a href="#main-content" class="sr-only focus:not-sr-only">
  Asosiy kontentga o'tish
</a>

<!-- Jadvalda -->
<th scope="col">Ism-sharif</th>
<th scope="row">1-qator</th>
```

### 7.3. Keyboard Navigation

| Tugma | Harakat |
|---|---|
| `Tab` / `Shift+Tab` | Elementlar orasida o'tish |
| `Enter` / `Space` | Tugma va havolalarni faollashtirish |
| `Escape` | Modal yopish, dropdown yopish |
| `Arrow keys` | Dropdown, select, table navigation |
| `Home` / `End` | Ro'yxat boshi / oxiri |

- Barcha funksiyalar klaviatura orqali bajarilishi
- Modal ochilanda: **focus trap** (Tab ichida qolishi)
- Modal yopilganda: trigger elementga focus qaytishi
- Tab tartib: mantiqiy (chapdan-o'ngga, yuqoridan-pastga)

### 7.4. Motion va Animatsiya

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

- Minimal animatsiya muddati: 200ms
- Maksimal animatsiya muddati: 500ms
- Avtomatik boshlanuvchi animatsiyalar: ta'qiqlangan
- Parallax effektlari: `prefers-reduced-motion: reduce` da o'chiriladi

---

## 8. RESPONSIVE BREAKPOINTLAR

| Breakpoint | Kenglik | Layout | Sidebar |
|---|---|---|---|
| Mobile Small | < 375px | 1 ustun | Yo'q (drawer) |
| Mobile | 375px – 767px | 1 ustun | Yo'q (drawer) |
| Tablet | 768px – 1023px | 2 ustun | Yig'iladigan |
| Desktop Small | 1024px – 1279px | 3 ustun | 240px (doimiy) |
| Desktop | 1280px – 1439px | 4 ustun | 260px (doimiy) |
| Desktop Large | ≥ 1440px | 4 ustun + keng sidebar | 280px (doimiy) |

**Mobile-first CSS yondashuvi:**

```css
/* Mobile default */
.grid { grid-template-columns: 1fr; }

/* Tablet+ */
@media (min-width: 768px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}

/* Desktop+ */
@media (min-width: 1280px) {
  .grid { grid-template-columns: repeat(4, 1fr); }
}
```

---

## 9. PERFORMANCE TALABLARI

### 9.1. Web Vitals Maqsadlari

| Metrika | Maqsad | O'lchash vositasi |
|---|---|---|
| First Contentful Paint (FCP) | < 1.5s | Lighthouse |
| Time to Interactive (TTI) | < 3.5s | Lighthouse |
| Largest Contentful Paint (LCP) | < 2.5s | Lighthouse |
| Cumulative Layout Shift (CLS) | < 0.1 | Lighthouse |
| First Input Delay (FID) | < 100ms | Field data |
| Lighthouse score | ≥ 90 | Lighthouse |

### 9.2. Rasm Optimizatsiyasi

| Talab | Qiymat |
|---|---|
| Format | WebP (birlamchi), PNG (fallback) |
| Maksimal hajm | 200 KB / rasm |
| Yuz fotolari (thumbnail) | 80×80px, ≤ 15 KB |
| Yuz fotolari (modal) | 400×400px, ≤ 80 KB |
| Lazy loading | Barcha ro'yxat rasmlari |
| srcset | Responsive images (`1x, 2x`) |

### 9.3. Kesh Strategiyasi

| Resurs | Kesh muddati | Strategiya |
|---|---|---|
| Static assets (JS, CSS) | 1 yil | Content hash + immutable |
| Fontlar | 1 yil | Cache-first |
| API javoblari | 5 daqiqa | Network-first |
| Foydalanuvchi sessiyasi | LocalStorage | JWT + refresh token |
| Rasmlar | 7 kun | Service Worker cache |

---

## 10. DELIVERABLES (Topshiriladigan Fayllar)

### 10.1. Design Fayllari

| Fayl | Format | Tavsif |
|---|---|---|
| Figma Master File | `.fig` | Barcha sahifalar, variantlar, autolayout |
| Design System Library | `.fig` | Komponentlar kutubxonasi, tokenlar |
| Icon Set | `.svg` (128 ta) | Heroicons + maxsus ikonlar |
| Logo Assets | `.svg`, `.png` | Barcha o'lchamlar, ranglar |
| Illustrations | `.svg` | Empty state, onboarding rasmlari |
| Dark Mode variants | `.fig` | Barcha sahifalar dark mode'da |

### 10.2. Hujjatlar

| Hujjat | Format | Tavsif |
|---|---|---|
| Style Guide | PDF | Rang, tipografiya, spacing qoidalari |
| Component Docs | HTML/PDF | Har bir komponent spesifikatsiyasi |
| Interaction Specs | Figma prototype | Animatsiya va o'tishlar |
| Asset Export Guide | PDF | Dev uchun eksport qo'llanmasi |
| Handoff Notes | Zeplin / Figma Dev Mode | Developer uchun tayyorlangan |

### 10.3. Prototiplar

| Prototip | Maqsad |
|---|---|
| Web Panel (interactive) | To'liq oqim sinovlari |
| Mobile App (interactive) | Gesture va navigatsiya sinovlari |
| Terminal UI (clickable) | Kirish stsenariyalari |
| User Flow Diagramlar | Barcha foydalanuvchi yo'llari |
| Wireframes (low-fidelity) | Dastlabki tuzilma tasdiqlash |

### 10.4. Export Formatlari

| Asset | Format | Rezolutsiya |
|---|---|---|
| Ikonlar | SVG + PNG | 1x, 2x, 3x |
| Rasmlar | WebP + PNG | Responsive srcset |
| Fontlar | WOFF2 + WOFF | — |
| Logo | SVG + PNG | Multiple sizes (16, 32, 64, 128, 256px) |
| Splash screens | PNG | iOS + Android standart o'lchamlar |

---

## 11. KOMPONENTLAR KUTUBXONASI (Ilova A)

### A.1. Form Komponentlari

| Komponent | Variantlar | Eslatmalar |
|---|---|---|
| Text Input | Default, Focus, Error, Disabled | Label + helper text |
| Password Input | Ko'rish/yashirish toggle | Kuch indikatori |
| Phone Input | +998 prefiksli masked input | Avtomatik format |
| Select Dropdown | Single, searchable | Virtual scroll (ko'p elementda) |
| Multi-Select | Chip ko'rinishida | Max 5 chip, +N ko'rish |
| Checkbox | Default, Indeterminate | Group qo'llab-quvvatlash |
| Radio Button | Default, Disabled | Group label |
| Toggle Switch | On/Off + Loading | Label o'ngda |
| Date Picker | Single, Range | Kalendarli modal |
| File Upload | Drag-drop + Click | Preview, progress, size limit |
| Search Input | Pill shaklda | Debounce 300ms |
| Textarea | Auto-resize | Character count |

### A.2. Ma'lumot Ko'rsatish

| Komponent | Tavsif |
|---|---|
| Data Table | Sort, filter, pagination, bulk select, sticky header |
| Card Grid | Responsive, hover effekt |
| List View | Avatar, icon, subtitle variantlari |
| Timeline | Voqealar tarixi (kirish log) |
| Statistics Cards | Trend ko'rsatkichi bilan |
| Charts | Line, Bar, Pie, Doughnut, Heatmap (Recharts yoki Chart.js) |
| Map View | Terminal xaritasi (Leaflet) |
| Calendar View | Hisobot davr tanlash |

### A.3. Navigatsiya

| Komponent | Tavsif |
|---|---|
| Sidebar Menu | Collapsible, submenu, aktiv indikator |
| Top Navigation | Search, notification, profile dropdown |
| Breadcrumbs | Avtomatik sahifa yo'li |
| Pagination | Sahifa raqamlari + oldingi/keyingi |
| Tabs | Horizontal, underline variant |
| Stepper | Horizontal (web), vertical (mobile) |
| Bottom Tab Bar | Mobile uchun, 5 element, badge |

### A.4. Qayta Aloqa (Feedback)

| Komponent | Tavsif |
|---|---|
| Alert/Toast | 4 variant (success/error/warning/info), auto-dismiss |
| Modal/Dialog | Small/Medium/Large, confirm dialog |
| Tooltip | Hover/Focus triggeri, max-width 200px |
| Progress Bar | Linear (fayl upload) + circular (yuk) |
| Spinner | Button ichida + sahifa yuklanishi |
| Skeleton Loader | Jadval + karta shimmer variant |
| Empty State | Icon + matn + harakat tugmasi |
| Error State | 404, 403, 500 maxsus sahifalar |

### A.5. Amallar (Actions)

| Komponent | Tavsif |
|---|---|
| Primary Button | Asosiy harakat |
| Secondary Button | Ikkinchi harakat |
| Ghost Button | Kamroq muhim harakat |
| Icon Button | Faqat ikonli (toolbar uchun) |
| Floating Action Button | Mobile — `+` qo'shish tugmasi |
| Dropdown Menu | Kontekst amallar (⋮ menyusi) |
| Context Menu | Right-click / Long press |
| Split Button | Asosiy + dropdown kombinatsiyasi |

---

## 12. QABUL QILISH MEZONLARI

### 12.1. Dizayn Review Checklist

- [ ] Barcha sahifalar Figmada dizayn qilingan
- [ ] Barcha holatlar ko'rsatilgan (default, empty, loading, error, success)
- [ ] Dark mode versiyasi to'liq mavjud
- [ ] Mobile responsive versiyasi to'liq mavjud
- [ ] Accessibility tekshiruvi o'tkazilgan (WCAG 2.1 AA)
- [ ] Design System to'liq hujjatlashtirilgan
- [ ] Barcha komponentlar Figma library'da
- [ ] Prototype oqimlari ishlaydi
- [ ] Developer handoff tayyor (Figma Dev Mode / Zeplin)
- [ ] Pasport maydonlari dizaynda YO'Q

### 12.2. Developer Handoff

- [ ] Barcha komponentlar nomlangan (BEM yoki atomic)
- [ ] Spacing qiymatlari aniq ko'rsatilgan (px/rem)
- [ ] Color tokenlar belgilangan (CSS variables)
- [ ] Font stillari hujjatlashtirilgan
- [ ] Animatsiya spesifikatsiyalari aniq
- [ ] Breakpoint qiymatlari kelishilgan
- [ ] Icon eksport yo'riqnomasi berilgan

### 12.3. Foydalanuvchi Testlari

- [ ] Kamida 5 ta foydalanuvchi bilan usability test o'tkazilgan
- [ ] Har bir rol uchun alohida test
- [ ] Terminal UI uchun real qurilmada test
- [ ] Aniqlangan muammolar bartaraf etilgan
- [ ] A/B test variantlari tayyorlangan (agar kerak)

---

## 13. LOYIHA BOSQICHLARI (DIZAYN UCHUN)

| Bosqich | Mazmun | Muddat | Natija |
|---|---|---|---|
| 1. Research | Foydalanuvchi tadqiqoti, raqobat tahlili | 1 hafta | Insights hujjati |
| 2. Wireframes | Low-fidelity prototiplar | 1 hafta | Figma wireframes |
| 3. Visual Design | High-fidelity dizayn | 2 hafta | Figma master file |
| 4. Design System | Komponentlar kutubxonasi | 1 hafta | Figma library |
| 5. Prototyping | Interaktiv prototiplar | 1 hafta | Clickable prototypes |
| 6. Testing | Foydalanuvchi sinovlari + qayta ko'rib chiqish | 1 hafta | Test hisoboti |
| 7. Handoff | Developer hujjatlashtirish | 3 kun | Handoff paketi |
| **Jami** | | **~7 hafta** | |

---

## 14. KELISHUV VA IMZOLAR

| Lavozim | Ism-sharif | Sana | Imzo |
|---|---|---|---|
| Buyurtmachi vakili | | __.__.2025 | ___________ |
| Bajaruvchi rahbar | | __.__.2025 | ___________ |
| UI/UX Lead Designer | | __.__.2025 | ___________ |
| Tech Lead | | __.__.2025 | ___________ |
| GASN vakili | | __.__.2025 | ___________ |

---

*Ushbu hujjat BSK FaceID Kirish Nazorati Tizimining UI/UX dizayni uchun asosiy texnik topshiriq hisoblanadi. O'zgartirish kiritish barcha tomonlarning yozma roziligi bilan amalga oshiriladi.*

**Maxfiy | Faqat ichki foydalanish uchun**

---

*Hujjat versiyasi: 2.0 | TT-DESIGN-2025-001-v2.0 | Texnik topshiriq BSK 2.0 asosida yangilandi*
