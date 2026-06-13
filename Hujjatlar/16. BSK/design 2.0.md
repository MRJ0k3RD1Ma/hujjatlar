# DIZAYN UCHUN TEXNIK TOPSHIRIQ (UI/UX)
## Ko'p Qavatli Binalarda FaceID Kirish Nazorati va Monitoring Tizimi

| Maydon | Qiymat |
|--------|--------|
| Hujjat raqami | TT-DESIGN-2025-001-v3.0 |
| Versiya | 3.0 (Senior Architect tomonidan qayta ko'rib chiqilgan) |
| Tuzilgan sana | 2025-yil |
| Buyurtmachi | Boshqaruv service kompaniyalari / GASN / Qurilish boshqarmasi |
| Bajaruvchi | Senior Software Architect Team |
| Holati | Production Ready |

---

## 1. UMUMIY MA'LUMOT

### 1.1. Loyiha Maqsadi
Ushbu hujjat ko'p qavatli turar-joy binolarining kirish qismlarida FaceID (yuz tanish) texnologiyasi asosida ishlaydigan avtomatlashtirilgan kirish nazorati va monitoring tizimi uchun **Web**, **Mobil** va **Terminal** ilovalarining UI/UX dizayni bo'yicha texnik talablarni belgilaydi.

**Muhim prinsiplar:**
- 🔒 **Privacy-First:** Pasport ma'lumotlari saqlanmaydi. Identifikatsiya uchun faqat telefon raqam ishlatiladi.
- 🛡️ **Security-by-Design:** Nozik ma'lumotlar (telefon raqamlar) barcha interfeyslarda maskalanishi shart.
- ♿ **Accessibility:** WCAG 2.1 AA standartiga to'liq moslik.
- 📱 **Mobile-First:** Barcha dizayn yechimlari avval mobil qurilmalar uchun optimallashtiriladi.

### 1.2. Dizayn Qamrovi

| Platforma | Texnologiya | Maqsadli Foydalanuvchilar | Prioritet |
|-----------|-------------|---------------------------|-----------|
| Web Panel | React.js 18+ | Adminlar, Operatorlar, Nazorat organlari | P0 (Critical) |
| Mobil Ilova | React Native | Rezidentlar, Bino Operatorlari | P0 (Critical) |
| Terminal UI | Embedded Linux/Android | Kirish nuqtalaridagi foydalanuvchilar | P0 (Critical) |
| Admin Panel | React.js 18+ | Super Admin, Tizim administratorlari | P1 (High) |

### 1.3. Dizayn Tamoyillari

| Tamoyil | Tavsif | Amaliy qo'llanilishi |
|---------|--------|---------------------|
| **Minimalizm** | Keraksiz elementlarsiz, toza va aniq interfeys | Har bir ekranda maksimal 1 ta asosiy harakat (CTA) |
| **Accessibility** | WCAG 2.1 AA standartiga to'liq moslik | Kontrast ≥ 4.5:1, keyboard navigation, screen reader support |
| **Responsive** | Barcha qurilmalarda to'g'ri ko'rinish | Mobile-first yondashuv, 6 breakpoint |
| **Dark Mode** | Qorong'u rejimni to'liq qo'llab-quvvatlash | Barcha komponentlar uchun light/dark variantlar |
| **O'zbek tili** | Barcha matnlar o'zbek tilida (lotin/kirill almashuv) | i18n support, lotin/kirill toggle |
| **Xavfsizlik UX** | Nozik ma'lumotlar maskalanishi | Telefon raqamlar: `+998 90 *** ** 34` formatida |
| **Performance** | Tezkor yuklanish va responsivlik | FCP < 1.5s, LCP < 2.5s, CLS < 0.1 |
| **Consistency** | Barcha platformalarda bir xil tajriba | Design System tokenlari barcha joyda qo'llaniladi |

---

## 2. DIZAYN TIZIMI (DESIGN SYSTEM)

### 2.1. Ranglar Palitasi

#### Asosiy Ranglar (Primary Colors)

| Rang nomi | Hex | CSS Variable | Dark Mode | Ishlatilishi |
|-----------|-----|--------------|-----------|--------------|
| Primary Blue | `#1E40AF` | `--color-primary` | `#3B82F6` | Asosiy tugmalar, havolalar, aktiv holatlar |
| Primary Dark | `#1E3A8A` | `--color-primary-dark` | `#2563EB` | Hover holati, focus ring |
| Primary Light | `#3B82F6` | `--color-primary-light` | `#60A5FA` | Ikkinchi darajali elementlar, background |
| Primary Surface | `#EFF6FF` | `--color-primary-surface` | `#1E3A8A` | Card background, selected state |

#### Holat Ranglari (Status Colors)

| Holat | Hex | CSS Variable | Dark Mode | Ishlatilishi |
|-------|-----|--------------|-----------|--------------|
| Success Green | `#10B981` | `--color-success` | `#34D399` | Muvaffaqiyatli operatsiyalar, kirish ruxsati |
| Warning Yellow | `#F59E0B` | `--color-warning` | `#FBBF24` | Ogohlantirishlar, oflayn holat, maintenance |
| Error Red | `#EF4444` | `--color-error` | `#F87171` | Xatolar, kirish rad etildi, critical alerts |
| Info Blue | `#3B82F6` | `--color-info` | `#60A5FA` | Ma'lumot xabarlari, notification |

#### Neytral Ranglar (Neutral Colors)

| Rang nomi | Hex | CSS Variable | Dark Mode | Ishlatilishi |
|-----------|-----|--------------|-----------|--------------|
| White | `#FFFFFF` | `--color-white` | `#0F172A` | Fon, kartochkalar (Light) |
| Gray 50 | `#F9FAFB` | `--color-gray-50` | `#1E293B` | Sekundar fon |
| Gray 100 | `#F3F4F6` | `--color-gray-100` | `#334155` | Border, separator |
| Gray 200 | `#E5E7EB` | `--color-gray-200` | `#475569` | Disabled fon, input border |
| Gray 500 | `#6B7280` | `--color-gray-500` | `#94A3B8` | Ikkinchi darajali matn |
| Gray 700 | `#374151` | `--color-gray-700` | `#CBD5E1` | Kuchli ikkinchi matn |
| Gray 900 | `#111827` | `--color-gray-900` | `#F1F5F9` | Asosiy matn |

#### Terminal Holati Indikatorlari

| Holat | Rang | Hex | Animatsiya | Qo'llanilishi |
|-------|------|-----|------------|---------------|
| Online | Yashil | `#10B981` | Yo'q | Terminal ishlayapti |
| Offline | Qizil | `#EF4444` | Yo'q | Aloqa yo'q |
| Maintenance | To'q sariq | `#F59E0B` | Yo'q | Texnik xizmat |
| Error | Qizil | `#EF4444` | Pulse (1s) | Kritik xatolik |
| Sync pending | Ko'k | `#3B82F6` | Spin (2s) | Sinxronizatsiya jarayoni |

### 2.2. Tipografiya

**Font oilasi:** `Inter` (asosiy) → `system-ui` → `sans-serif`

**Font yuklash strategiyasi:**
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}
```

| Element | Desktop | Mobile | Weight | Line Height | Letter Spacing | Ishlatilishi |
|---------|---------|--------|--------|-------------|----------------|--------------|
| H1 — Sahifa sarlavhasi | 32px | 24px | 700 | 1.2 | -0.02em | Sahifa nomi |
| H2 — Bo'lim sarlavhasi | 24px | 20px | 600 | 1.2 | -0.01em | Bo'lim nomi |
| H3 — Kichik sarlavha | 20px | 18px | 600 | 1.3 | 0 | Subseksiya |
| H4 — Widget sarlavha | 16px | 15px | 600 | 1.3 | 0 | Karta sarlavhasi |
| Body — Asosiy matn | 16px | 14px | 400 | 1.5 | 0 | Paragraf |
| Small — Kichik matn | 14px | 12px | 400 | 1.4 | 0 | Yordamchi ma'lumot |
| Caption — Izoh | 12px | 11px | 400 | 1.4 | 0.01em | Vaqt, meta |
| Button | 16px | 14px | 500 | 1.0 | 0.02em | Tugma matni |
| Label | 14px | 13px | 500 | 1.2 | 0 | Form yorliqlari |
| Code / Monospace | 14px | 13px | 400 | 1.5 | 0 | ID, token, API |

**Accessibility talablari:**
- Minimal font o'lchami: 14px (mobile), 16px (desktop)
- Font size scaling: `clamp(14px, 1vw + 12px, 16px)`
- User zoom: 200% gacha qo'llab-quvvatlash

### 2.3. Grid va Layout

#### Breakpointlar

| Breakpoint | Kenglik | Kolonnalar | Sidebar | Container Padding |
|------------|---------|------------|---------|-------------------|
| Mobile Small | `< 375px` | 1 | Yo'q (drawer) | 12px |
| Mobile | `375px – 767px` | 1 | Yo'q (drawer) | 16px |
| Tablet | `768px – 1023px` | 2 | Yig'iladigan | 20px |
| Desktop Small | `1024px – 1279px` | 3 | 240px | 24px |
| Desktop | `1280px – 1439px` | 4 | 260px | 24px |
| Desktop Large | `≥ 1440px` | 4 + sidebar | 280px | 32px |

#### Spacing tizimi (8px grid)

```css
:root {
  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-5: 20px;
  --spacing-6: 24px;
  --spacing-8: 32px;
  --spacing-10: 40px;
  --spacing-12: 48px;
  --spacing-16: 64px;
  --spacing-20: 80px;
  --spacing-24: 96px;
}
```

#### Container kengliklari

```css
.container {
  max-width: 1440px;
  margin: 0 auto;
  padding-left: var(--spacing-6);
  padding-right: var(--spacing-6);
}

@media (max-width: 1023px) {
  .container {
    padding-left: var(--spacing-4);
    padding-right: var(--spacing-4);
  }
}
```

### 2.4. Komponentlar Kutubxonasi

#### Tugmalar (Buttons)

| Turi | Balandlik | Padding | Border Radius | Font | Min Touch Target |
|------|-----------|---------|---------------|------|------------------|
| Primary Large | 56px | 24px 32px | 8px | 18px/500 | 48×48px |
| Primary Medium | 44px | 16px 24px | 6px | 16px/500 | 44×44px |
| Primary Small | 36px | 12px 16px | 4px | 14px/500 | 40×40px |
| Secondary Medium | 44px | 16px 24px | 6px | 16px/500 | 44×44px |
| Ghost Medium | 44px | 16px 24px | 6px | 16px/500 | 44×44px |
| Danger Medium | 44px | 16px 24px | 6px | 16px/500 | 44×44px |
| Icon Button | 44×44px | 0 | 50% (aylana) | — | 44×44px |

**Button holatlari:**

| Holat | CSS | Effekt |
|-------|-----|--------|
| Default | `background: var(--color-primary)` | Asosiy rang |
| Hover | `background: var(--color-primary-dark)` | Fon 10% to'qroq |
| Active / Pressed | `transform: scale(0.98)` | Bosilgan effekt |
| Focus | `box-shadow: 0 0 0 2px var(--color-primary)` | Ring 2px |
| Disabled | `opacity: 0.5; cursor: not-allowed` | O'chirilgan |
| Loading | `pointer-events: none` | Spinner + disabled |

**Accessibility:**
- Barcha tugmalar `aria-label` bilan ta'minlanishi kerak
- Icon-only tugmalar uchun `aria-label` majburiy
- Keyboard focus visible bo'lishi shart

#### Input Maydonlari

| Element | Balandlik | Border Radius | Border | Focus border | Error border |
|---------|-----------|---------------|--------|--------------|--------------|
| Text Input | 44px | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Password Input | 44px | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Phone Input (mask) | 44px | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Select Dropdown | 44px | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Multi-Select | 44px min | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Search Input | 44px | 22px (pill) | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Textarea | Auto (min 88px) | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |
| Date Picker | 44px | 6px | 1px Gray 200 | 2px Primary Blue | 2px Error Red |

**Form validation holatlari:**

| Holat | Visual | Message Position |
|-------|--------|------------------|
| Valid | Yashil border + ✓ icon | Input ostida |
| Invalid | Qizil border + ✗ icon + xato matni (12px) | Input ostida |
| Required | `*` belgisi + label | Label yonida |
| Optional | `(ixtiyoriy)` + label | Label yonida |
| Loading | Input disabled + spinner | Input ichida |

**Phone Input Mask:**
```
+998 (__) ___-__-__
```

#### Kartochkalar (Cards)

```css
.card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  padding: 24px;
  transition: all 200ms ease;
}

.dark .card {
  background: #1E293B;
  border-color: #334155;
}

.card--interactive:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}
```

| Variant | Padding (Desktop) | Padding (Mobile) | Shadow |
|---------|-------------------|------------------|--------|
| Default | 24px | 16px | 0 1px 3px |
| Interactive | 24px | 16px | 0 4px 12px (hover) |
| Compact | 16px | 12px | 0 1px 2px |
| Elevated | 24px | 16px | 0 4px 6px |

#### Jadvallar (Tables)

```css
.table-header {
  background: #F9FAFB;
  font: 12px/600;
  text-transform: uppercase;
  color: #6B7280;
  padding: 12px 16px;
  border-bottom: 2px solid #E5E7EB;
}

.table-row {
  padding: 16px;
  border-bottom: 1px solid #F3F4F6;
  min-height: 56px;
  transition: background 100ms;
}

.table-row:hover {
  background: #F9FAFB;
}

.table-row--selected {
  background: #EFF6FF;
}
```

**Responsive table behavior:**
- Desktop: To'liq jadval ko'rinishi
- Tablet: Horizontal scroll yoki column collapse
- Mobile: Card view (har bir qator alohida karta)

#### Modallar (Dialogs)

```css
.modal-overlay {
  background: rgba(0,0,0,0.5);
  backdrop-filter: blur(4px);
  position: fixed;
  inset: 0;
  z-index: 1000;
}

.modal-container {
  max-width: 480px; /* small */
  max-width: 640px; /* medium */
  max-width: 800px; /* large */
  border-radius: 16px;
  padding: 32px;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalEnter 200ms ease;
}

@keyframes modalEnter {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
```

| O'lcham | Max-width | Qo'llanilishi |
|---------|-----------|---------------|
| Small | 480px | Confirm dialogs, form inputs |
| Medium | 640px | Detail views, edit forms |
| Large | 800px | Complex forms, data tables |
| Full-screen | 100% | Mobile modal, photo viewer |

### 2.5. Iconografiya

**Kutubxona:** Heroicons v2.0 (birlamchi) yoki Lucide Icons

**Stil:**
- Outline (asosiy ko'rinish)
- Filled (aktiv/tanlangan holat)

**O'lchamlar:**

| O'lcham | Qo'llanilishi | CSS Class |
|---------|---------------|-----------|
| 16px | Inline text, badges | `icon-xs` |
| 20px | Button, list items | `icon-sm` |
| 24px | Navigation, sidebar | `icon-md` |
| 32px | Empty state, hero | `icon-lg` |
| 48px | Terminal status, alerts | `icon-xl` |

**Rang:** `currentColor` (matn rangiga avtomatik mos)

**Terminal holati ikonlari:**

| Holat | Icon Name | Rang | Animatsiya |
|-------|-----------|------|------------|
| Online | `signal` / `wifi` | Yashil | Yo'q |
| Offline | `signal-slash` | Qizil | Yo'q |
| Maintenance | `wrench` | To'q sariq | Yo'q |
| Error | `exclamation-triangle` | Qizil | Pulse |
| Syncing | `arrow-path` | Ko'k | Spin |

### 2.6. Animatsiyalar va Mikro-interaksiyalar

#### Page Transitions

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

.page-exit {
  opacity: 1;
}

.page-exit-active {
  opacity: 0;
  transition: opacity 150ms ease;
}
```

#### Notification (Toast)

| Turi | Ko'rinish muddati | Joylashuvi | Rang | Auto-dismiss |
|------|-------------------|------------|------|--------------|
| Success | 3s | Yuqori o'ng | Yashil | ✅ |
| Error | 5s + qo'lda yopish | Yuqori o'ng | Qizil | ❌ |
| Warning | 5s + qo'lda yopish | Yuqori o'ng | To'q sariq | ❌ |
| Info | 3s | Yuqori o'ng | Ko'k | ✅ |

**Toast Container:**
```css
.toast-container {
  position: fixed;
  top: 24px;
  right: 24px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 400px;
}
```

#### Loading Holatlari

| Komponent | Variant | Qo'llanilishi |
|-----------|---------|---------------|
| Skeleton Screen | Shimmer effekt | Kontent yuklanayotganda |
| Spinner | Circular, 24px | Tugma ichida, modal |
| Progress Bar | Linear, top of page | Fayl yuklashda |
| Pull-to-refresh | Circular indicator | Mobil ro'yxatlarda |

**Skeleton Pattern:**
```css
.skeleton {
  background: linear-gradient(
    90deg,
    #F3F4F6 25%,
    #E5E7EB 50%,
    #F3F4F6 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

#### Motion Preferences

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

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

#### Header Spetsifikatsiyasi

| Parametr | Qiymat |
|----------|--------|
| Balandligi | 64px |
| Background | White / Dark Card |
| Border-bottom | 1px Gray 100 |
| Position | `sticky top-0`, `z-index: 100` |
| Shadow | 0 1px 2px rgba(0,0,0,0.05) |

**Header Elementlari:**

| Element | O'lcham | Joylashuv | Interaction |
|---------|---------|-----------|-------------|
| Logo | 40×40px | Left | Click → Dashboard |
| Breadcrumb | Auto | Left-Center | Clickable segments |
| Search | 320px | Center | Debounce 300ms |
| Notification | 24×24px | Right | Badge counter, dropdown |
| Profile | 36×36px | Right | Avatar + dropdown |

#### Sidebar Spetsifikatsiyasi

| Parametr | Desktop | Tablet | Mobile |
|----------|---------|--------|--------|
| Kenglik | 260px | 240px | Overlay (drawer) |
| Position | Fixed left | Collapsible | Hidden |
| Background | White / Dark Card | White / Dark Card | White / Dark Card |
| Border-right | 1px Gray 100 | 1px Gray 100 | None |
| Z-index | 90 | 90 | 1000 |

**Aktiv element stil:**
```css
.sidebar-item--active {
  background: var(--color-primary);
  color: #FFFFFF;
  border-left: 4px solid var(--color-primary-dark);
}
```

### 3.2. Sidebar Navigatsiya

| Bo'lim | Icon | Ruxsat darajasi | Submenyu | Badge |
|--------|------|-----------------|----------|-------|
| Dashboard | `chart-bar` | Barcha rollar | Yo'q | Yo'q |
| Rezidentlar | `users` | BSK Admin, Operator | Qo'shish, Ro'yxat | Yo'q |
| Binolar | `building-office` | BSK Admin, GASN, Operator | Ro'yxat | Yo'q |
| Terminallar | `device-phone-mobile` | BSK Admin, Operator | Ro'yxat, Monitoring | Status dot |
| Kirish Loglari | `clipboard-document-list` | Barcha rollar | — | Yo'q |
| Hisobotlar | `chart-pie` | BSK Admin, GASN, Prokuratura, IIV | — | Yo'q |
| Mehmonlar | `ticket` | BSK Admin, Operator | QR yaratish, Ro'yxat | Yo'q |
| Foydalanuvchilar | `user-group` | Faqat Super Admin | — | Yo'q |
| Sozlamalar | `cog` | Super Admin, BSK Admin | Tizim, Xavfsizlik | Yo'q |

**Navigation State:**
- Hover: Background Gray 50, text Gray 900
- Active: Background Primary Blue, text White
- Disabled: Opacity 50%, cursor not-allowed
- Focus: Ring 2px Primary Blue, offset 2px

### 3.3. Asosiy Sahifalar

#### 3.3.1. Dashboard (Asosiy Ko'rinish)

**Maqsad:** Real-time statistika va tizim holatini tezkor ko'rish

**Statistika kartalari (1-qator — 4 karta):**

| Karta | Ma'lumot | Icon | Rang | Trend |
|-------|----------|------|------|-------|
| Bugungi kirishlar | Muvaffaqiyatli kirish soni | `door-open` | Ko'k | ▲/▼ % |
| Rad etilganlar | Tanilmagan urinishlar | `x-circle` | Qizil | ▲/▼ % |
| Aktiv terminallar | Online / Jami | `signal` | Yashil | — |
| Aktiv rezidentlar | Faol shaxslar soni | `users` | Ko'k | ▲/▼ % |

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

| Breakpoint | Layout |
|------------|--------|
| Desktop | 4 statistika kartasi bir qatorda |
| Tablet | 2×2 grid |
| Mobile | 1×4 (vertikal stack) |

#### 3.3.2. Rezidentlar Ro'yxati

**Maqsad:** Rezidentlarni boshqarish (CRUD amallar)

**Filtrlar paneli (top bar):**
```
[🔍 Qidirish: ism / telefon / xonadon]  [Bino ▼]  [Holat ▼]  [Sana ▼]  [Tozalash]
```

**Jadval kolonnalari:**

| Kolonna | Kenglik | Saralash | Filtrlash | Eslatma |
|---------|---------|----------|-----------|---------|
| ☐ (checkbox) | 40px | — | — | Bulk select |
| Avatar + Ism-sharif | 25% | ✅ | ✅ | Foto thumbnail + to'liq ism |
| Telefon | 15% | ✅ | ✅ | Maskalangan: `+998 90 *** ** 34` |
| Bino / Xonadon | 20% | ✅ | ✅ | Chilonzor-14 / 35-xonadon |
| Qavat | 8% | ✅ | — | Auto-hisoblanadi |
| Holat | 10% | ✅ | ✅ | Badge: aktiv/bloklangan/arxiv |
| Qo'shilgan sana | 12% | ✅ | ✅ | 21.03.2025 |
| Amallar | 80px | — | — | [✏️] [🔒] [⋮] |

**Holat badge'lari:**

| Holat | Rang | DB qiymati | Text Color |
|-------|------|------------|------------|
| Aktiv | Yashil bg, Green text | `active` | `#065F46` |
| Bloklangan | Qizil bg, Red text | `blocked` | `#991B1B` |
| Arxivlangan | Kulrang bg, Gray text | `archived` | `#374151` |
| O'chirilgan | Qizil/italic | `deleted` | `#991B1B` |

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
│  [Foto/Avatar]   │  Telefon:     +998 90 *** ** 34      │
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

**Qadamlar (Stepper):**
```
[1. Shaxsiy ma'lumotlar] → [2. Joylashuv] → [3. Yuz foto] → [4. Kirish huquqlari]
```

**Qadam 1: Shaxsiy ma'lumotlar**
- To'liq ism-sharif * (text input)
- Telefon raqami * (masked: `+998 __ ___ __ __`)
- ⚠️ **Pasport ustuni mavjud emas**

**Qadam 2: Joylashuv**
- Bino tanlash * (select, qidiruv bilan)
- Xonadon raqami * (number input)
- Qavat * (auto-hisoblanadi yoki manual)

**Qadam 3: Yuz foto**
- Kamera orqali olish YOKI fayl yuklash
- Kamida 2 ta foto talab qilinadi
- Turli burchak ko'rsatmasi + preview
- Sifat baholash (quality score indicator)
- Min resolution: 640×480px
- Max file size: 2MB

**Qadam 4: Kirish huquqlari**
- Terminal tanlash (checkbox ro'yxat)
- Vaqt oralig'i (ixtiyoriy): `07:00 – 23:00`
- Kirish muddati (ixtiyoriy): tugash sanasi

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

| Holat | Rang | Icon | Animatsiya | Tooltip |
|-------|------|------|------------|---------|
| Online | `#10B981` (Yashil) | ● | Yo'q | "Online — Oxirgi aloqa: 2 daqiqa oldin" |
| Offline | `#EF4444` (Qizil) | ● | Yo'q | "Offline — Oxirgi aloqa: 3 soat oldin" |
| Maintenance | `#F59E0B` (To'q sariq) | ⚙️ | Yo'q | "Texnik xizmat" |
| Error | `#EF4444` (Qizil) | ⚠️ | Pulse miltillash | "Xatolik — Administratorga xabar bering" |
| Syncing | `#3B82F6` (Ko'k) | ↻ | Aylana | "Sinxronizatsiya jarayoni..." |

**Terminal Detail Modal:**

**Tablar:** `[Umumiy] [Rezidentlar] [Loglar] [Sozlamalar]`

**[Umumiy]:**
- Model, serial raqam, firmware versiyasi
- IP manzil, MAC manzil
- Oxirgi heartbeat vaqti
- Uptime statistikasi (grafik)
- Sinxronizatsiya holati: server vs lokal farq

**[Rezidentlar]:**
- Bu terminaldagi rezidentlar ro'yxati
- Qo'shish / O'chirish imkoniyati
- Sync status indicator

**[Loglar]:**
- Faqat shu terminal voqealari
- Filtrlash imkoniyati
- Export options

**[Sozlamalar]:**
- Yuz tanish sezgirligi (slider 1-5)
- Liveness detection: on/off toggle
- Kirish vaqt oralig'i
- Volume, ekran yorqinligi
- `[Remote Restart]` `[Remote Lock]`

#### 3.3.4. Kirish Loglari

**Maqsad:** Barcha kirish voqealarini ko'rish va filtrlash

**Filtrlar paneli:**
```
[📅 Sana oralig'i]  [🏢 Bino ▼]  [📱 Terminal ▼]  [🎯 Voqea turi ▼]  [🔍 Shaxs/telefon]
[Qo'llash]  [Tozalash]  [📥 Export: PDF | Excel | CSV]
```

**Log Jadvali:**

| Kolonna | Kontent | Format | Width |
|---------|---------|--------|-------|
| Vaqt | Sana va soat | `21.03.2025 14:32:15` | 160px |
| Terminal | Bino + terminal ID | `Chilonzor-14 / T-1` | 200px |
| Shaxs | Ism + Telefon | `Abdullayev J. | +998 90 *** ** 34` | 25% |
| Voqea Turi | Event badge | `✅ KIRDI` / `❌ RAD ETILDI` | 140px |
| Qaror sababi | Qisqa izoh | `Tanishdi` / `Tanilmadi` / `Liveness fail` | 20% |
| Foto | Thumbnail | `[👁️ Ko'rish]` | 80px |

**Voqea turi badge'lari:**

| Voqea | Badge rangi | Matn | Icon |
|-------|-------------|------|------|
| DOOR_OPEN_SUCCESS | Yashil | ✅ Kirdi | `check-circle` |
| DOOR_OPEN_DENIED | Qizil | ❌ Rad etildi | `x-circle` |
| DOOR_OPEN_MANUAL | Ko'k | 🔑 Qo'lda ochildi | `key` |
| LIVENESS_FAIL | To'q sariq | ⚠️ Liveness xatosi | `exclamation` |
| SUSPICIOUS_ATTEMPT | Qizil + bold | 🚨 Shubhali | `exclamation-triangle` |
| DOOR_FORCED | Qizil + bold | 🚨 Majburiy ochildi | `lock-open` |
| DEVICE_ONLINE | Yashil/kulrang | 📡 Terminal online | `wifi` |
| DEVICE_OFFLINE | Kulrang | 📡 Terminal offline | `wifi-off` |
| SYNC_COMPLETE | Ko'k | 🔄 Sinxron tugadi | `arrow-path` |

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

**Xavfsizlik:**
- Foto ko'rish faqat vakolatli foydalanuvchilar uchun
- Prokuratura va IIV uchun — har bir ko'rish `security_access_logs` jadvaliga yoziladi
- Download faqat Super Admin va BSK Admin uchun

#### 3.3.5. Hisobotlar va Analitika

**Hisobot Turlari:**

| Hisobot | Davriyligi | Ma'lumot | Export |
|---------|------------|----------|--------|
| Kunlik kirish | Kun | Saatlik grafik, jami soni | PDF, Excel |
| Haftalik trend | 7 kun | Kunlik taqqoslama | PDF, Excel |
| Oylik statistika | Oy | To'liq tahlil | PDF, Excel, CSV |
| Terminal faollik | Tanlanadi | Uptime %, xatolar | PDF |
| Shubhali voqealar | Tanlanadi | Xavfsizlik hisoboti | PDF |
| Rezident faollik | Oy | Kirish statistikasi | Excel |

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

**Login Form Validation:**

| Holat | Message | Action |
|-------|---------|--------|
| Empty phone | "Telefon raqamni kiriting" | Focus input |
| Invalid phone | "Noto'g'ri telefon raqam formati" | Highlight input |
| Empty password | "Parolni kiriting" | Focus input |
| Wrong credentials | "Telefon raqam yoki parol noto'g'ri" | Clear password |
| 5 failed attempts | "Account 15 daqiqaga bloklandi" | Disable form |

**OTP Tasdiqlash (Parol tiklash):**

```
┌─────────────────────────────────────┐
│  [←]  SMS Tasdiqlash                │
│                                     │
│  +998 90 *** ** 34 ga               │
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

**OTP Input Behavior:**
- Auto-focus next input on digit entry
- Backspace moves to previous input
- Paste support for 6-digit code
- Auto-submit on last digit
- Resend cooldown: 60 seconds

### 3.4. Foydalanuvchi Rollari Bo'yicha Ko'rinish

| Sahifa | Super Admin | BSK Admin | Operator | GASN | Prokuratura | IIV |
|--------|-------------|-----------|----------|------|-------------|-----|
| Dashboard | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha (faqat ko'rish) | ✅ Cheklangan | ✅ Cheklangan |
| Rezidentlar | ✅ CRUD | ✅ CRUD | ✅ CRUD | ❌ | ❌ | ❌ |
| Binolar | ✅ CRUD | ✅ CRUD | 👁️ Ko'rish | 👁️ Ko'rish | 👁️ Ko'rish | 👁️ Ko'rish |
| Terminallar | ✅ CRUD | ✅ CRUD | 👁️ Ko'rish | 👁️ Ko'rish | ❌ | ❌ |
| Kirish Loglari | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha | ✅ So'rov asosida* | ✅ So'rov asosida* |
| Hisobotlar | ✅ To'liq | ✅ O'z binolari | ✅ O'z binolari | ✅ Barcha | ✅ Cheklangan | ✅ Cheklangan |
| Mehmonlar | ✅ CRUD | ✅ CRUD | ✅ CRUD | ❌ | ❌ | ❌ |
| Foydalanuvchilar | ✅ CRUD | ❌ | ❌ | ❌ | ❌ | ❌ |
| Sozlamalar | ✅ To'liq | ✅ Cheklangan | ❌ | ❌ | ❌ | ❌ |

*\*Prokuratura va IIV uchun ma'lumotlarga har bir kirish `security_access_logs` jadvalida qayd etiladi. Har bir so'rov uchun hujjat raqami kiritilishi talab etiladi.*

**Access Control Matrix:**

| Action | Super Admin | BSK Admin | Operator | GASN | Prokuratura | IIV |
|--------|-------------|-----------|----------|------|-------------|-----|
| View Dashboard | All | Own org | Own building | All | Limited | Limited |
| Create Resident | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Edit Resident | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Delete Resident | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| View Logs | All | Own org | Own building | All | With request | With request |
| Export Logs | ✅ | ✅ | ❌ | ✅ | With request | With request |
| Manage Users | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| System Settings | ✅ | Partial | ❌ | ❌ | ❌ | ❌ |

---

## 4. MEHMON KIRISH MODULI (Web Panel)

### 4.1. Maqsad
Vaqtinchalik kirish kodi yaratish va boshqarish

### 4.2. Mehmon Kirish Formasi

```
┌─────────────────────────────────────────────────────────┐
│  Vaqtinchalik Kirish Yaratish                           │
├─────────────────────────────────────────────────────────┤
│  Mehmon ismi:       [_________________________]         │
│  Mehmon telefon:    [+998 __ ___ __ __] (ixtiyoriy)     │
│  Host rezident:     [Abdullayev Jasur ▼] (auto-fill)    │
│  Terminal:          [Chilonzor-14, T-1       ▼]        │
│  Kirish turi:       ○ QR-kod  ● PIN (6 xona)           │
│  Amal qilish:       [📅 Boshlanish] – [📅 Tugash]       │
│  Foydalanish soni:  ○ 1 marta  ○ 5 marta  ● Cheksiz    │
├─────────────────────────────────────────────────────────┤
│              [Bekor qilish]   [Yaratish]                │
└─────────────────────────────────────────────────────────┘
```

**Form Validation:**

| Field | Required | Validation | Error Message |
|-------|----------|------------|---------------|
| Mehmon ismi | ✅ | Min 2 chars | "Ism kamida 2 belgi bo'lishi kerak" |
| Mehmon telefon | ❌ | Valid phone format | "Noto'g'ri telefon raqam" |
| Host rezident | ✅ | Active resident | "Rezident topilmadi" |
| Terminal | ✅ | Active terminal | "Terminal tanlanmagan" |
| Kirish turi | ✅ | QR yoki PIN | "Kirish turi tanlanmagan" |
| Amal qilish | ✅ | Start < End | "Boshlanish tugashdan oldin bo'lishi kerak" |
| Foydalanish soni | ✅ | 1-999 yoki ∞ | "Noto'g'ri qiymat" |

### 4.3. Natija Ko'rinishi

```
┌─────────────────────────────────────────────────────────┐
│  ✅ Mehmon kirish yaratildi                              │
│                                                          │
│  [QR Code]     PIN: 849 372                             │
│  (200×200px)                                             │
│                                                          │
│  Mehmon:        Karimov Ali                              │
│  Amal qilish:   21.03.2025 15:00 – 21.03.2025 20:00     │
│  Terminal:      Chilonzor-14, Asosiy kirish              │
│  Foydalanish:   0 / Cheksiz                              │
│                                                          │
│  [📥 QR Yuklab olish]  [📤 Ulashish]  [❌ Bekor qilish] │
└─────────────────────────────────────────────────────────┘
```

**QR Code Specifications:**
- Size: 200×200px (min), 400×400px (download)
- Format: PNG, SVG
- Error correction: Level M (15%)
- Content: Encrypted token with expiry

**Share Options:**
- SMS (auto-fill message)
- Telegram
- WhatsApp
- Email
- Copy link

### 4.4. Mehmonlar Ro'yxati

**Table Columns:**

| Kolonna | Content | Filter | Sort |
|---------|---------|--------|------|
| Mehmon ismi | Full name | ✅ | ✅ |
| Host | Rezident ismi | ✅ | ✅ |
| Terminal | Bino + Terminal | ✅ | ✅ |
| Turi | QR / PIN | ✅ | ❌ |
| Holat | Aktiv / Ishlatilgan / Muddati tugagan | ✅ | ✅ |
| Yaratilgan | Sana va vaqt | ✅ | ✅ |
| Tugash | Sana va vaqt | ✅ | ✅ |
| Foydalanish | X / Limit | ❌ | ✅ |
| Amallar | [Ko'rish] [Bekor qilish] | — | — |

---

## 5. MOBIL ILOVA DIZAYNI (React Native)

### 5.1. Navigatsiya Tuzilishi

**Bottom Tab Bar (5 tab):**

```
┌─────────────────────────────────────────────────────────┐
│  [🏠 Asosiy]  [👥 Rezidentlar]  [📱 Terminallar]  [📊 Hisobotlar]  [⚙️ Sozlamalar] │
└─────────────────────────────────────────────────────────┘
```

| Tab | Icon (Active) | Icon (Inactive) | Badge |
|-----|---------------|-----------------|-------|
| Asosiy | `home` (filled) | `home` (outline) | Yo'q |
| Rezidentlar | `users` (filled) | `users` (outline) | Yo'q |
| Terminallar | `device-mobile` (filled) | `device-mobile` (outline) | Status dot |
| Hisobotlar | `chart-bar` (filled) | `chart-bar` (outline) | Yo'q |
| Sozlamalar | `cog` (filled) | `cog` (outline) | Notification dot |

**Tab Bar Specifications:**
- Height: 60px (iOS), 56px (Android)
- Background: White / Dark Card
- Border-top: 1px Gray 100
- Active tab: Primary Blue + filled icon
- Inactive tab: Gray 500 + outline icon
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

**Header Specifications:**
- Height: 56px + safe area
- Background: White / Dark Card
- Title: 18px/600
- Right actions: Notification (24px), Profile (36px)

**Stat Cards (Mobile):**
- Width: 48% - 8px gap
- Height: 100px
- Padding: 16px
- Border radius: 12px

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
│  │        +998 90 *** ** 34    │   │
│  │        Chilonzor-14 / 35-x  │   │
│  │        🟢 Aktiv              │   │
│  └─────────────────────────────┘   │
│  ← swipe: [🗑️ O'chirish]           │
│  → swipe: [✏️ Tahrirlash]          │
│                                     │
└─────────────────────────────────────┘
                                        [+ FAB]  ← Floating action button
```

**List Item Specifications:**
- Height: 80px min
- Avatar: 48×48px
- Padding: 12px horizontal
- Border-bottom: 1px Gray 100

**Filter Chips:**
- Height: 32px
- Padding: 8px 16px
- Border radius: 16px (pill)
- Background: Gray 100
- Active: Primary Blue background, White text

**FAB (Floating Action Button):**
- Size: 56×56px
- Position: Bottom right, 16px from edges
- Icon: Plus (24px)
- Shadow: 0 4px 12px rgba(0,0,0,0.15)

#### 5.2.3. Rezident Qo'shish (Mobile)

**Qadamlar (top progress bar):**
```
●──●──○──○  (1 / 4 qadam)
```

```
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

**Progress Bar:**
- Height: 4px
- Active color: Primary Blue
- Inactive color: Gray 200
- Border radius: 2px

**Form Fields (Mobile):**
- Input height: 48px (touch target)
- Label: 14px/500, Gray 700
- Helper text: 12px/400, Gray 500
- Error text: 12px/400, Error Red

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

**Summary Bar:**
- Height: 48px
- Background: Gray 50
- Items: Equal width, centered
- Text: 14px/500

### 5.3. Mobile UX Talablari

#### Gesture'lar

| Gesture | Harakat | Confirmation |
|---------|---------|--------------|
| Swipe Left (ro'yxat elementi) | O'chirish / Bloklash | Confirm dialog kerak |
| Swipe Right (ro'yxat elementi) | Tahrirlash | Direct navigation |
| Pull to Refresh | Ma'lumotlarni yangilash | Auto-trigger |
| Long Press | Bulk tanlash rejimi | Haptic feedback |
| Tap | Detail ko'rinishi | Direct navigation |
| Pinch to zoom | Foto ko'rishda | Auto-fit on release |

#### Touch Target Standartlari

| Element | Minimal | Optimal | Platform |
|---------|---------|---------|----------|
| Button | 44×44px | 48×48px | iOS HIG |
| Icon Button | 44×44px | 48×48px | Material Design |
| List Item | 44px height | 56px height | Both |
| Input Field | 44px height | 48px height | Both |
| Tab Bar Item | 48×48px | 56×56px | Both |

**Elementlar orasidagi minimal masofa:** 8px

#### Loading Holatlari

| Komponent | Variant | Qo'llanilishi |
|-----------|---------|---------------|
| Skeleton Screen | Card, List, Table | Kontent yuklanayotganda |
| Pull-to-refresh | Circular indicator | Ro'yxat yangilash |
| Infinite Scroll | Loading spinner | Uzun ro'yxatlar |
| Progress Bar | Linear | Fayl va foto yuklash |
| Full-screen Loader | Modal overlay | Critical operations |

#### Xato Holatlari

| Xato | Message | Action |
|------|---------|--------|
| Network error | "Internet aloqasi yo'q" | [Qayta urinish] button |
| Empty state | Icon + "Ma'lumot topilmadi" + [Qo'shish] button | CTA button |
| 403 Forbidden | "Ruxsat yo'q" | [Chiqish] button |
| 500 Server error | "Xatolik yuz berdi" + kod | [Qayta urinish] + Support contact |
| Session expired | "Sessiya muddati tugadi" | [Qayta kirish] button |

---

## 6. TERMINAL UI DIZAYNI (Embedded Linux/Android)

### 6.1. Asosiy Ekran — Kutish Holati (Idle State)

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

**Idle State Specifications:**

| Element | Size | Position | Color |
|---------|------|----------|-------|
| Logo | 80×80px | Top center | White |
| Camera Preview | 300×300px | Center | Live feed |
| Instruction | 20px/500 | Below camera | White |
| Building Name | 16px/400 | Bottom | Gray 200 |
| Time/Date | 16px/500 | Bottom | White |

**Background:** Dark gradient (#1E3A8A → #111827)

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
│  [████████░░] 3 soniya        │  ← Countdown progress bar
└────────────────────────────────┘
```

**Success State Specifications:**

| Element | Value |
|---------|-------|
| Fon rangi | `#10B981` (Yashil) |
| Davomiyligi | 3 soniya |
| Icon size | 96×96px |
| Title font | 24px/600 |
| Name font | 20px/600 |
| Apartment font | 16px/400 |
| Progress bar | 4px height, White |
| Transition | Fade to Idle |

### 6.3. Kirish Rad Etildi (Denied)

```
┌────────────────────────────────┐
│                                │
│  ┌──────────────────────────┐ │
│  │                          │ │
│  │       ❌                 │ │  ← Katta qizil X icon
│  │  Kirish ruxsat etilmadi  │ │  ← 24px, oq
│  │                          │ │
│  │  Tanilmadi               │ │  ← Sabab (16px)
│  │                          │ │
│  └──────────────────────────┘ │
│                                │
│  [██████░░░░] 2 soniya        │
└────────────────────────────────┘
```

**Denied State Specifications:**

| Element | Value |
|---------|-------|
| Fon rangi | `#EF4444` (Qizil) |
| Davomiyligi | 2 soniya |
| Icon size | 96×96px |
| Title font | 24px/600 |
| Reason font | 16px/400 |
| Ovozli signal | Qisqa ogohlantiruv beep (500ms) |
| Transition | Fade to Idle |

### 6.4. Liveness Detection Xatosi

```
┌────────────────────────────────┐
│                                │
│  ┌──────────────────────────┐ │
│  │                          │ │
│  │       ⚠️                 │ │
│  │  Faqat jonli shaxs uchun │ │
│  │                          │ │
│  │  Iltimos, qayta urinib   │ │
│  │  ko'ring                 │ │
│  │                          │ │
│  └──────────────────────────┘ │
│                                │
│  [████████░░] 2 soniya        │
└────────────────────────────────┘
```

**Liveness Fail Specifications:**

| Element | Value |
|---------|-------|
| Fon rangi | `#F59E0B` (To'q sariq) |
| Davomiyligi | 2 soniya |
| Icon size | 96×96px |
| Ovozli signal | Warning tone |

### 6.5. Terminal Sozlamalari (Admin Kirish)

**Admin kirish:** PIN (6 raqam) yoki NFC karta

```
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

**Admin PIN Input:**
- 6 digit numeric keypad
- Masked input (••••••)
- 3 failed attempts → 5 minute lockout
- NFC card alternative

---

## 7. ACCESSIBILITY (A11Y) TALABLARI

### 7.1. Vizual Accessibility (WCAG 2.1 AA)

| Talab | Minimal daraja | Maqsadli daraja | Tekshirish usuli |
|-------|----------------|-----------------|------------------|
| Kontrast (kichik matn) | 4.5 : 1 | 7 : 1 | WebAIM Contrast Checker |
| Kontrast (katta matn ≥18px) | 3 : 1 | 4.5 : 1 | WebAIM Contrast Checker |
| Minimal font o'lchami | 14px | 16px | Browser zoom test |
| Focus indikatori | 2px ring | 3px ring + offset | Keyboard navigation |
| Touch target (mobile) | 44×44px | 48×48px | Touch test |

**Rang ko'rish nuqsoni:**
- Rangdan tashqari icon yoki matn ham ishlatish
- Color-blind friendly palette test
- Grayscale mode test

**User scalable:**
- `font-size` va `zoom` o'zgartirish imkoniyati
- `max-scale` cheklovchi meta tegs yo'q
- Support 200% zoom without breaking layout

### 7.2. Screen Reader Qo'llab-Quvvatlash

**HTML Semantics:**

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

<!-- Formlarda -->
<label for="phone">Telefon raqami</label>
<input id="phone" type="tel" aria-required="true" aria-describedby="phone-help" />
<span id="phone-help" class="helper-text">+998 formatida kiriting</span>
```

**ARIA Requirements:**

| Element | ARIA Attribute | Value |
|---------|----------------|-------|
| Modal | `role`, `aria-modal`, `aria-labelledby` | `dialog`, `true`, title ID |
| Tab | `role`, `aria-selected`, `aria-controls` | `tab`, `true/false`, panel ID |
| Alert | `role`, `aria-live` | `alert`, `assertive` |
| Loading | `aria-busy`, `aria-live` | `true`, `polite` |
| Navigation | `role`, `aria-label` | `navigation`, descriptive label |

### 7.3. Keyboard Navigation

| Tugma | Harakat | Qo'llanilishi |
|-------|---------|---------------|
| `Tab` / `Shift+Tab` | Elementlar orasida o'tish | Barcha interaktiv elementlar |
| `Enter` / `Space` | Tugma va havolalarni faollashtirish | Buttons, links |
| `Escape` | Modal yopish, dropdown yopish | Modals, dropdowns |
| `Arrow keys` | Dropdown, select, table navigation | Selects, menus, tables |
| `Home` / `End` | Ro'yxat boshi / oxiri | Lists, tables |

**Focus Management:**
- Barcha funksiyalar klaviatura orqali bajarilishi
- Modal ochilanda: focus trap (Tab ichida qolishi)
- Modal yopilganda: trigger elementga focus qaytishi
- Tab tartib: mantiqiy (chapdan-o'ngga, yuqoridan-pastga)
- Focus visible: 2px ring, offset 2px

**Skip Links:**
```html
<a href="#main-content" class="skip-link">
  Asosiy kontentga o'tish
</a>
```

### 7.4. Motion va Animatsiya

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

**Animation Guidelines:**

| Parametr | Qiymat | Eslatma |
|----------|--------|---------|
| Minimal animatsiya muddati | 200ms | Qisqa bo'lmasligi kerak |
| Maksimal animatsiya muddati | 500ms | Uzun bo'lmasligi kerak |
| Autoplay animatsiyalar | Ta'qiqlangan | User interaction kerak |
| Parallax effektlari | `prefers-reduced-motion` da o'chiriladi | Accessibility |
| Loading spinners | 1s rotation | Continuous |
| Toast enter/exit | 200ms | Smooth |

---

## 8. RESPONSIVE BREAKPOINTLAR

### 8.1. Breakpoint Tizimi

| Breakpoint | Kenglik | Layout | Sidebar | Container |
|------------|---------|--------|---------|-----------|
| Mobile Small | `< 375px` | 1 ustun | Yo'q (drawer) | 100% - 24px |
| Mobile | `375px – 767px` | 1 ustun | Yo'q (drawer) | 100% - 32px |
| Tablet | `768px – 1023px` | 2 ustun | Yig'iladigan | 100% - 40px |
| Desktop Small | `1024px – 1279px` | 3 ustun | 240px (doimiy) | 100% - 48px |
| Desktop | `1280px – 1439px` | 4 ustun | 260px (doimiy) | 1440px |
| Desktop Large | `≥ 1440px` | 4 ustun + sidebar | 280px (doimiy) | 1440px |

### 8.2. Mobile-First CSS Yondashuvi

```css
/* Mobile default */
.grid {
  grid-template-columns: 1fr;
  gap: var(--spacing-4);
}

.card {
  padding: var(--spacing-4);
}

/* Tablet+ */
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--spacing-6);
  }
  
  .card {
    padding: var(--spacing-6);
  }
}

/* Desktop+ */
@media (min-width: 1280px) {
  .grid {
    grid-template-columns: repeat(4, 1fr);
    gap: var(--spacing-8);
  }
  
  .card {
    padding: var(--spacing-8);
  }
}
```

### 8.3. Component Responsive Behavior

| Komponent | Mobile | Tablet | Desktop |
|-----------|--------|--------|---------|
| Navigation | Hamburger menu | Collapsible sidebar | Fixed sidebar |
| Tables | Card view | Horizontal scroll | Full table |
| Modals | Full-screen | 90% width | Fixed max-width |
| Forms | Single column | 2 columns | 2-3 columns |
| Dashboard | Vertical stack | 2×2 grid | 4×1 row |
| Charts | Stacked | Side by side | Full width |

---

## 9. PERFORMANCE TALABLARI

### 9.1. Web Vitals Maqsadlari

| Metrika | Maqsad | O'lchash vositasi | Priority |
|---------|--------|-------------------|----------|
| First Contentful Paint (FCP) | < 1.5s | Lighthouse | P0 |
| Time to Interactive (TTI) | < 3.5s | Lighthouse | P0 |
| Largest Contentful Paint (LCP) | < 2.5s | Lighthouse | P0 |
| Cumulative Layout Shift (CLS) | < 0.1 | Lighthouse | P0 |
| First Input Delay (FID) | < 100ms | Field data | P1 |
| Total Blocking Time (TBT) | < 300ms | Lighthouse | P1 |
| Lighthouse score | ≥ 90 | Lighthouse | P0 |

### 9.2. Rasm Optimizatsiyasi

| Talab | Qiymat | Qo'llanilishi |
|-------|--------|---------------|
| Format | WebP (birlamchi), PNG (fallback) | Barcha rasmlar |
| Maksimal hajm | 200 KB / rasm | Upload limit |
| Yuz fotolari (thumbnail) | 80×80px, ≤ 15 KB | List views |
| Yuz fotolari (modal) | 400×400px, ≤ 80 KB | Detail views |
| Lazy loading | Barcha ro'yxat rasmlari | Below fold |
| srcset | Responsive images (1x, 2x, 3x) | All images |
| SVG icons | Inline yoki sprite | Icons |

**Image Loading Strategy:**
```html
<img 
  src="image-400.webp" 
  srcset="image-400.webp 400w, image-800.webp 800w"
  sizes="(max-width: 768px) 100vw, 50vw"
  loading="lazy"
  decoding="async"
  alt="Descriptive text"
/>
```

### 9.3. Kesh Strategiyasi

| Resurs | Kesh muddati | Strategiya | Cache-Control |
|--------|--------------|------------|---------------|
| Static assets (JS, CSS) | 1 yil | Content hash + immutable | `public, max-age=31536000, immutable` |
| Fontlar | 1 yil | Cache-first | `public, max-age=31536000` |
| API javoblari | 5 daqiqa | Network-first | `private, max-age=300` |
| Foydalanuvchi sessiyasi | LocalStorage | JWT + refresh token | N/A |
| Rasmlar | 7 kun | Service Worker cache | `public, max-age=604800` |
| HTML pages | 0 | Network-first | `no-cache` |

**Service Worker Strategy:**
```javascript
// Cache-first for static assets
// Network-first for API calls
// Stale-while-revalidate for images
```

### 9.4. Code Splitting

| Route | Chunk Size Target | Loading |
|-------|-------------------|---------|
| Dashboard | < 100 KB | Lazy |
| Residents | < 150 KB | Lazy |
| Terminals | < 100 KB | Lazy |
| Logs | < 200 KB | Lazy + pagination |
| Reports | < 150 KB | Lazy |
| Settings | < 50 KB | Lazy |

**Bundle Analysis:**
- Total initial bundle: < 300 KB (gzipped)
- Vendor chunks: Separated
- Common chunks: Shared components

---

## 10. KOMPONENTLAR KUTUBXONASI (Ilova A)

### A.1. Form Komponentlari

| Komponent | Variantlar | Props | Eslatmalar |
|-----------|------------|-------|------------|
| Text Input | Default, Focus, Error, Disabled | `label`, `placeholder`, `error`, `helperText` | Label + helper text |
| Password Input | Ko'rish/yashirish toggle | `showPasswordToggle`, `strengthIndicator` | Kuch indikatori |
| Phone Input | +998 prefiksli masked | `countryCode`, `mask` | Avtomatik format |
| Select Dropdown | Single, searchable | `options`, `searchable`, `placeholder` | Virtual scroll (ko'p elementda) |
| Multi-Select | Chip ko'rinishida | `maxChips`, `placeholder` | Max 5 chip, +N ko'rish |
| Checkbox | Default, Indeterminate | `checked`, `indeterminate`, `label` | Group qo'llab-quvvatlash |
| Radio Button | Default, Disabled | `checked`, `label`, `name` | Group label |
| Toggle Switch | On/Off + Loading | `checked`, `loading`, `label` | Label o'ngda |
| Date Picker | Single, Range | `mode`, `minDate`, `maxDate` | Kalendarli modal |
| File Upload | Drag-drop + Click | `accept`, `maxSize`, `multiple` | Preview, progress, size limit |
| Search Input | Pill shaklda | `debounce`, `placeholder` | Debounce 300ms |
| Textarea | Auto-resize | `rows`, `maxLength`, `showCount` | Character count |

### A.2. Ma'lumot Ko'rsatish

| Komponent | Props | Qo'llanilishi |
|-----------|-------|---------------|
| Data Table | `columns`, `data`, `sortable`, `filterable`, `pagination` | Ro'yxatlar, logs |
| Card Grid | `columns`, `gap`, `responsive` | Dashboard, terminals |
| List View | `items`, `avatar`, `subtitle`, `action` | Residents, notifications |
| Timeline | `events`, `orientation` | Kirish log tarixi |
| Statistics Cards | `value`, `label`, `trend`, `icon` | Dashboard widgets |
| Charts | `type`, `data`, `options` | Analytics (Recharts) |
| Map View | `markers`, `zoom`, `center` | Terminal xaritasi (Leaflet) |
| Calendar View | `events`, `view`, `range` | Hisobot davr tanlash |

### A.3. Navigatsiya

| Komponent | Props | Qo'llanilishi |
|-----------|-------|---------------|
| Sidebar Menu | `items`, `collapsed`, `activeKey` | Main navigation |
| Top Navigation | `search`, `notifications`, `profile` | Header |
| Breadcrumbs | `items`, `maxItems` | Page path |
| Pagination | `total`, `current`, `pageSize`, `onChange` | Table pagination |
| Tabs | `items`, `activeKey`, `onChange` | Content sections |
| Stepper | `steps`, `current`, `orientation` | Multi-step forms |
| Bottom Tab Bar | `tabs`, `activeKey`, `badge` | Mobile navigation |

### A.4. Qayta Aloqa (Feedback)

| Komponent | Variantlar | Auto-dismiss | Qo'llanilishi |
|-----------|------------|--------------|---------------|
| Alert/Toast | Success, Error, Warning, Info | 3-5s | Notifications |
| Modal/Dialog | Small, Medium, Large, Confirm | No | Forms, details |
| Tooltip | Top, Bottom, Left, Right | On hover | Help text |
| Progress Bar | Linear, Circular | No | Upload, loading |
| Spinner | Small, Medium, Large | No | Loading states |
| Skeleton Loader | Card, List, Table | No | Content loading |
| Empty State | Icon, title, description, CTA | No | No data |
| Error State | 404, 403, 500 | No | Error pages |

### A.5. Amallar (Actions)

| Komponent | Variantlar | Qo'llanilishi |
|-----------|------------|---------------|
| Primary Button | Large, Medium, Small | Main CTA |
| Secondary Button | Medium, Small | Secondary actions |
| Ghost Button | Medium, Small | Low priority |
| Icon Button | With label, Icon only | Toolbars |
| Floating Action Button | Single, Extended | Mobile add actions |
| Dropdown Menu | Top, Bottom, Left, Right | Context actions |
| Context Menu | Right-click, Long press | Advanced actions |
| Split Button | Primary + Dropdown | Combined actions |

---

## 11. QABUL QILISH MEZONLARI

### 11.1. Dizayn Review Checklist

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
- [ ] Telefon raqamlar maskalangan
- [ ] Barcha ikonlar consistent (Heroicons/Lucide)
- [ ] Animatsiyalar documented
- [ ] Breakpoints tested on real devices

### 11.2. Developer Handoff

- [ ] Barcha komponentlar nomlangan (BEM yoki atomic)
- [ ] Spacing qiymatlari aniq ko'rsatilgan (px/rem)
- [ ] Color tokenlar belgilangan (CSS variables)
- [ ] Font stillari hujjatlashtirilgan
- [ ] Animatsiya spesifikatsiyalari aniq (duration, easing)
- [ ] Breakpoint qiymatlari kelishilgan
- [ ] Icon eksport yo'riqnomasi berilgan (SVG, PNG)
- [ ] Asset naming convention documented
- [ ] Component props documented
- [ ] Interaction states documented

### 11.3. Foydalanuvchi Testlari

- [ ] Kamida 5 ta foydalanuvchi bilan usability test o'tkazilgan
- [ ] Har bir rol uchun alohida test (Admin, Operator, GASN, etc.)
- [ ] Terminal UI uchun real qurilmada test
- [ ] Accessibility test with screen readers
- [ ] Keyboard-only navigation test
- [ ] Aniqlangan muammolar bartaraf etilgan
- [ ] A/B test variantlari tayyorlangan (agar kerak)
- [ ] Performance test on low-end devices
- [ ] Network throttling test (3G, 4G)

### 11.4. Security Review

- [ ] No sensitive data in URLs
- [ ] Phone numbers masked in all views
- [ ] Session timeout implemented
- [ ] Logout on inactivity
- [ ] Secure file upload validation
- [ ] XSS prevention in all inputs
- [ ] CSRF protection documented
- [ ] Audit log for sensitive actions

---

## 12. LOYIHA BOSQICHLARI (DIZAYN UCHUN)

| Bosqich | Mazmun | Muddat | Natija | Owner |
|---------|--------|--------|--------|-------|
| 1. Research | Foydalanuvchi tadqiqoti, raqobat tahlili, persona yaratish | 1 hafta | Insights hujjati, Persona docs | UX Researcher |
| 2. Wireframes | Low-fidelity prototiplar, user flow | 1 hafta | Figma wireframes, Flow diagrams | UX Designer |
| 3. Visual Design | High-fidelity dizayn, all screens | 2 hafta | Figma master file | UI Designer |
| 4. Design System | Komponentlar kutubxonasi, tokens | 1 hafta | Figma library, Style guide | Design System Lead |
| 5. Prototyping | Interaktiv prototiplar, micro-interactions | 1 hafta | Clickable prototypes | UX Designer |
| 6. Testing | Foydalanuvchi sinovlari + qayta ko'rib chiqish | 1 hafta | Test hisoboti, Iterations | UX Researcher |
| 7. Handoff | Developer hujjatlashtirish, spec export | 3 kun | Handoff paketi, Documentation | Design Lead |
| 8. QA Support | Implementation review, design QA | Continuous | Pixel-perfect implementation | UI Designer |
| **Jami** | | **~8 hafta** | | |

---

## 13. KELISHUV VA IMZOLAR

| Lavozim | Ism-sharif | Sana | Imzo |
|---------|------------|------|------|
| Buyurtmachi vakili | | __.__.2025 | ___________ |
| Bajaruvchi rahbar | | __.__.2025 | ___________ |
| UI/UX Lead Designer | | __.__.2025 | ___________ |
| Tech Lead / Architect | | __.__.2025 | ___________ |
| GASN vakili | | __.__.2025 | ___________ |
| Security Officer | | __.__.2025 | ___________ |

---

## 14. O'ZGARTIRISHLAR TARIXI

| Versiya | Sana | O'zgarish | Muallif |
|---------|------|-----------|---------|
| 1.0 | 2025-01-01 | Dastlabki versiya | Design Team |
| 2.0 | 2025-02-01 | Privacy updates (pasport olib tashlandi) | Security Team |
| 3.0 | 2025-03-01 | Senior Architect review, accessibility improvements | Architect Team |

---

**Maxfiy | Faqat ichki foydalanish uchun**

**Hujjat versiyasi:** 3.0 | TT-DESIGN-2025-001-v3.0

**Ushbu hujjat BSK FaceID Kirish Nazorati Tizimining UI/UX dizayni uchun asosiy texnik topshiriq hisoblanadi. O'zgartirish kiritish barcha tomonlarning yozma roziligi bilan amalga oshiriladi.**