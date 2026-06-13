# Milliy Universiteti — Davomat Tizimi
## Dizayn Texnik Topshirig'i — Dark Theme (UI/UX Spec)

**Versiya:** 1.0
**Sana:** 2026-05-04
**Buyurtmachi:** Milliy Universiteti
**Maqsadli foydalanuvchi:** UI/UX dizayner va Frontend developer

---

## 1. Umumiy

**Platforma:** Web admin panel (desktop-first, responsive)
**Tema:** Dark (qorong'i) — asosiy tema
**Minimal kenglik:** 1280px
**Frontend:** React.js + Tailwind CSS
**Ikonlar:** Lucide Icons
**Grafiklar:** Recharts

---

## 2. Rang Palitasi (Dark Theme)

### 2.1 Fon qatlamlari

| Token | Hex | Ishlatish |
|---|---|---|
| `bg-base` | `#0A0A15` | Sahifa asosiy foni |
| `bg-sidebar` | `#0F0F1E` | Sidebar foni |
| `bg-card` | `#14142A` | Karta, panel foni |
| `bg-card-hover` | `#1A1A32` | Karta hover holati |
| `bg-input` | `#1C1C30` | Input, select foni |
| `bg-elevated` | `#1E1E35` | Dropdown, tooltip foni |
| `border` | `#2A2A42` | Chegara chiziqlari |
| `border-light` | `#353550` | Yengil chegara |

### 2.2 Matn ranglari

| Token | Hex | Ishlatish |
|---|---|---|
| `text-primary` | `#E2E8F0` | Asosiy matn, sarlavhalar |
| `text-secondary` | `#94A3B8` | Ikkinchi darajali, label |
| `text-muted` | `#475569` | Placeholder, vaqtinchalik matn |
| `text-inverse` | `#0A0A15` | Quyuq fon ustidagi matn |

### 2.3 Semantik ranglar

| Token | Hex | Dark bg | Ishlatish |
|---|---|---|---|
| `success` | `#10B981` | `#0D2E22` | Kirdi, online, normal |
| `success-text` | `#34D399` | — | Yashil matn |
| `warning` | `#F59E0B` | `#2D2206` | Kechikkan, ogohlantirish |
| `warning-text` | `#FBBF24` | — | Sariq matn |
| `danger` | `#EF4444` | `#2D0E0E` | Kelmadi, offline, xato |
| `danger-text` | `#F87171` | — | Qizil matn |
| `info` | `#3B82F6` | `#0E1E3D` | Chiqdi, ma'lumot |
| `info-text` | `#60A5FA` | — | Ko'k matn |
| `purple` | `#8B5CF6` | `#1A0E35` | Talaba badge, accent |
| `purple-text` | `#A78BFA` | — | Binafsha matn |

### 2.4 Asosiy brendlash

| Token | Hex | Ishlatish |
|---|---|---|
| `primary` | `#00C98D` | Asosiy aksent (yashil-teal) |
| `primary-dark` | `#00A876` | Hover |
| `primary-glow` | `rgba(0,201,141,0.15)` | Focus ring, highlight |
| `sidebar-active` | `rgba(0,201,141,0.12)` | Aktiv menyu foni |
| `sidebar-active-border` | `#00C98D` | Aktiv menyu chap chegara |

---

## 3. Tipografiya

**Font:** `Inter` (Google Fonts)

| Daraja | Size | Weight | Ishlatish |
|---|---|---|---|
| H1 | 24px | 700 | Sahifa sarlavhasi |
| H2 | 20px | 600 | Bo'lim sarlavhasi |
| H3 | 16px | 600 | Karta sarlavhasi, widget |
| Body | 14px | 400 | Jadval matn, forma |
| Body SM | 13px | 400 | Ikkinchi darajali |
| Caption | 12px | 400 | Timestamp, yorliq |
| Label | 12px | 500 | Form label |
| Badge | 11px | 600 | Status badge |
| Number LG | 32px | 700 | Dashboard widget raqami |
| Number MD | 20px | 700 | Karta statistika raqami |

---

## 4. Layout Tuzilmasi

```
┌──────────────────────────────────────────────────────────┐
│  TOPBAR (60px, sticky, bg-card border-b border)          │
├──────────────┬───────────────────────────────────────────┤
│              │                                           │
│  SIDEBAR     │   CONTENT AREA                           │
│  (220px)     │   bg-base, padding: 24px                 │
│  bg-sidebar  │                                          │
│  fixed       │                                          │
│              │                                          │
└──────────────┴───────────────────────────────────────────┘
```

### 4.1 Sidebar

**Tuzilma:**
```
┌────────────────────────┐
│  Logo zona (72px)      │
│  [O] AccessControl     │
│  v2.4 · Hikvision      │
├────────────────────────┤
│  ASOSIY               │
│  [▣] Dashboard         │
│  [≡] Kirdi-Chiqdi   8 │  ← badge
│  [👤] Xodimlar/Talab.  │
│  [▤] Hisobotlar        │
│                        │
│  TIZIM                 │
│  [⚙] Sozlamalar        │
├────────────────────────┤
│  ● Qurilma ulangan    │  ← pastki holat
│  192.168.1.64          │
└────────────────────────┘
```

**Sidebar item holatlari:**
- Default: matn `#475569`, icon `#475569`
- Hover: background `#1A1A32`, matn `#94A3B8`
- **Aktiv:** background `rgba(0,201,141,0.12)`, matn `#00C98D`, chap chegara `3px solid #00C98D`
- Section label: 11px 600 `#475569` uppercase, padding-top: 16px

**Notification badge:** `#EF4444` background, `#FFFFFF` matn, 18px diameter

**Pastki holat:**
- Yashil `●` pulsing dot + `Qurilma ulangan` — `#34D399` matn
- IP manzil: 12px `#475569`

### 4.2 Topbar

```
┌─────────────────────────────────────────────────────────┐
│  [Sahifa nomi]    [Bugun: 2026.04.28 (Seshanba)]   soat │
│                                      [+ Hodisa] [↓ CSV] │
└─────────────────────────────────────────────────────────┘
```

- Background: `#0F0F1E`, border-bottom: `1px solid #2A2A42`
- Sahifa nomi: 18px 600 `#E2E8F0`
- Sana: 13px `#475569`
- Soat: 14px 600 `#00C98D` (live clock, monospace font)
- `[+ Hodisa]` — primary tugma (outline yashil)
- `[↓ CSV]` — secondary tugma

---

## 5. Sahifalar — Batafsil Spesifikatsiya

---

### 5.1 Dashboard

**URL:** `/dashboard`

#### Layout:
```
┌─────────────────────────────────────────────────────────┐
│  [Widget 1]  [Widget 2]  [Widget 3]  [Widget 4]         │
│  (4 ta, teng kenglik)                                   │
├──────────────────────────────┬──────────────────────────┤
│  Soatlik faollik (Bar chart) │  Live Feed               │
│  70%                         │  30%                     │
├──────────────────────────────┴──────────────────────────┤
│  Haftalik davomiylik (Line)  │  Taqsimot (Donut)        │
│  65%                         │  35%                     │
└─────────────────────────────────────────────────────────┘
```

#### Widget kartalar (4 ta):

**Karta dizayni:**
- Background: `#14142A`, radius: 12px, border: `1px solid #2A2A42`
- Padding: 20px 24px
- Sarlavha: 12px 500 `#94A3B8` uppercase
- Raqam: 36px 700
- Pastki tavsif: 12px `#475569`

| № | Sarlavha | Raqam rangi | Tavsif |
|---|---|---|---|
| 1 | BUGUN KIRGANLAR | `#E2E8F0` (oq) | "xodim va talabalar" |
| 2 | HOZIR ICHKARIDA | `#FBBF24` (sariq) | "kishi binoda" |
| 3 | KECHIKKANLAR | `#FBBF24` (sariq) | "09:00 dan keyin" |
| 4 | KELMADI | `#F87171` (qizil) | "ro'yxatda yo'q" |

#### Soatlik faollik (Bar chart):
- Background: `#14142A`, border: `1px solid #2A2A42`, radius: 12px
- Sarlavha: `SOATLIK FAOLLIK (BUGUN)` — 11px 600 `#94A3B8` uppercase
- X o'qi: soatlar (8:00 – 19:00), matn `#475569`
- Y o'qi: raqamlar `#475569`
- **Bar 1 (Kirdi):** `#10B981` (yashil)
- **Bar 2 (Chiqdi):** `#3B82F6` (ko'k)
- Bar radius: 4px (yuqori)
- Tooltip: `#1E1E35` bg, `#E2E8F0` matn

#### Live Feed (o'ng panel):
- Sarlavha: `LIVE FEED` + `barchasi →` link
- Har bir yozuv: avatar + ism + bo'lim + holat badge
- Avatar: 32px, initials, rang gradient
- Border-bottom: `1px solid #2A2A42`
- Vaqt: 12px `#475569` monospace
- **Yangi yozuv animatsiyasi:** slide-down 300ms

#### Haftalik davomiylik (Line chart):
- Chiziq rangi: `#10B981` (yashil), strokeWidth: 2
- Area fill: `rgba(16,185,129,0.08)`
- X o'qi: Du Se Ch Pa Ju Sh Ya
- Y o'qi: 0–100%

#### Taqsimot (Donut chart):
- Sarlavha: `TAQSIMOT`
- Segmentlar: Xodimlar `#10B981`, Talabalar `#8B5CF6`, Hozir ichkarida `#3B82F6`, Kechikkan `#F59E0B`
- Legend: ism + rang nuqta + raqam

---

### 5.2 Kirdi-Chiqdi Jurnali

**URL:** `/journal`

```
┌──────────────────────────────────────────────────────────┐
│  Kirdi-Chiqdi Jurnali                                    │
│  Barcha hodisalar real vaqtda yangilanadi                │
├──────────────────────────────────────────────────────────┤
│  [🔍 Ism yoki ID...] [Barchasi ▾] [Barcha turlar ▾] [📅] │
│                                           61 ta hodisa   │
├──────────────────────────────────────────────────────────┤
│  VAQT | ISM FAMILIYA | ID | BO'LIM/GURUH | TUR | HOLAT | QURILMA │
│  ─────────────────────────────────────────────────────── │
│  ...                                                     │
└──────────────────────────────────────────────────────────┘
```

#### Filter qatori:
- Background: `#14142A`, padding: 12px 16px, border-bottom: `1px solid #2A2A42`
- `[🔍 Ism yoki ID...]` — 280px, bg `#1C1C30`, border `1px solid #2A2A42`
- `[Barchasi ▾]` — rol filter (Barchasi / Xodim / Talaba)
- `[Barcha turlar ▾]` — holat filter (Kirdi / Chiqdi / Kechikdi)
- `[📅 04/28/2026]` — sana tanlash
- O'ng tomonda: `N ta hodisa` — 12px `#475569`

#### Jadval ustunlari:

| Ustun | Kenglik | Tavsif |
|---|---|---|
| VAQT | 180px | `YYYY.MM.DD HH:MM:SS`, 13px monospace `#94A3B8` |
| ISM FAMILIYA | flex | Avatar (32px) + Ism 14px `#E2E8F0` |
| ID | 90px | `ID-XXXX`, 13px `#475569` |
| BO'LIM / GURUH | 160px | 13px `#94A3B8` |
| TUR | 90px | Badge: Xodim / Talaba |
| HOLAT | 100px | Badge: Kirdi / Chiqdi / Kechikdi |
| QURILMA | 140px | Qurilma seriya, 12px `#475569` |

#### Jadval uslubi:
- Header: background `#0F0F1E`, 11px 600 `#475569` uppercase, letter-spacing: 0.08em
- Qator height: 52px, hover: `#1A1A32`
- Border: faqat gorizontal `1px solid #2A2A42`

#### Holat badge'lari:
| Badge | Background | Matn | Border |
|---|---|---|---|
| Kirdi | `#0D2E22` | `#34D399` | `1px solid #10B981` |
| Chiqdi | `#0E1E3D` | `#60A5FA` | `1px solid #3B82F6` |
| Kechikdi | `#2D2206` | `#FBBF24` | `1px solid #F59E0B` |

#### Tur badge'lari:
| Badge | Background | Matn |
|---|---|---|
| Xodim | `#1A0E35` | `#A78BFA` |
| Talaba | `#1A0E35` | `#C4B5FD` |

**Real-time yangilash:** HTTP polling 3s, yangi qator tepadan tushadi (slide-down animatsiya)

---

### 5.3 Xodimlar va Talabalar

**URL:** `/persons`

```
┌──────────────────────────────────────────────────────────┐
│  Xodimlar va Talabalar    [Barchasi ▾]  [+ Yangi qo'shish]│
├──────────────────────────────────────────────────────────┤
│  [Karta] [Karta] [Karta] [Karta]   ← 4 ustunli grid      │
│  [Karta] [Karta] [Karta] [Karta]                         │
└──────────────────────────────────────────────────────────┘
```

#### Shaxs kartasi:

```
┌──────────────────────────────────────┐
│  [Avatar]  Alisher Toshmatov    ●   │  ← online dot
│  (48px)    ID-1000                  │
│            [Xodim]                  │
│            IT bo'limi               │
│  ─────────────────────────────────  │
│  18       0          TASH           │
│  KUN    KECHIKDI    HOLAT           │
└──────────────────────────────────────┘
```

**Karta parametrlari:**
- Background: `#14142A`, border: `1px solid #2A2A42`, radius: 12px
- Padding: 16px
- Hover: border `1px solid #353550`, background `#1A1A32`

**Avatar (48px):**
- Border-radius: full
- Fon: gradient (har ism uchun unikal rang: sariq, ko'k, yashil, binafsha, qizil, teal)
- Initials: 16px 700 `#FFFFFF`
- **Online dot:** 10px, `#10B981`, border: `2px solid #14142A`, yuqori o'ng burchak

**Ism bloki:**
- Ism: 14px 600 `#E2E8F0`
- ID: 12px `#475569`
- Role badge (Xodim/Talaba): 11px 600, fon `#1A0E35`, matn `#A78BFA`
- Bo'lim/Guruh: 12px `#64748B`

**Statistika qatori (pastki):**
- 3 ta ustun, divider bilan ajratilgan
- Raqam: 20px 700
  - KUN: `#E2E8F0`
  - KECHIKDI: `#F59E0B` (0 bo'lsa `#475569`)
  - HOLAT: `#34D399` (ICH=ichkarida) yoki `#475569` (TASH=tashqarida)
- Label: 10px 500 `#475569` uppercase

**Filter (top right):**
- `[Barchasi ▾]` — Barchasi / Xodimlar / Talabalar
- `[+ Yangi qo'shish]` — primary tugma

---

### 5.4 Hisobotlar

**URL:** `/reports`

```
┌──────────────────────────────────────────────────────────┐
│  Hisobotlar va Statistika                                │
│  Oy va haftalik tahlil                                   │
├──────────────────────────────────────────────────────────┤
│  [Kunlik] [Bo'limlar bo'yicha] [Kechikish tahlili]       │
├──────────────────────────────────────────────────────────┤
│  OXIRGI 7 KUN DAVOMIYLIK (Stacked bar chart)             │
├──────────────────────────────────────────────────────────┤
│  KUNLIK BATAFSIL (jadval)                                │
└──────────────────────────────────────────────────────────┘
```

#### Tab bar:
- Background: transparent, border-bottom: `1px solid #2A2A42`
- Aktiv tab: matn `#00C98D`, border-bottom: `2px solid #00C98D`
- Passiv tab: matn `#475569`, hover: `#94A3B8`
- Tab font: 14px 500

#### Stacked Bar chart (Oxirgi 7 kun):
- Sarlavha: `OXIRGI 7 KUN DAVOMIYLIK` — 11px 600 `#94A3B8` uppercase
- X o'qi: kun nomlari (Du, Se, Ch...)
- **Segment 1 — Keldi:** `#10B981` (yashil)
- **Segment 2 — Kechikdi:** `#F59E0B` (sariq)
- **Segment 3 — Kelmadi:** `#7F1D1D` (to'q qizil)
- Bar radius: 4px (faqat yuqori)
- Grid chiziq: `#2A2A42`, dashed

#### Kunlik batafsil jadval:
- Sarlavha: `KUNLIK BATAFSIL` — 11px 600 `#94A3B8` uppercase
- Pastki o'ng: `[↓ Excel]` `[↓ CSV]` tugmalar

**Jadval ustunlari:**

| Ustun | Tavsif |
|---|---|
| SANA | `YYYY.MM.DD (Hafta kuni)` — sana bold, kun kuni `#475569` italic |
| JAMI KIRDI | `#E2E8F0` |
| XODIMLAR | `#60A5FA` (ko'k) |
| TALABALAR | `#A78BFA` (binafsha) |
| KECHIKKANLAR | `#FBBF24` (sariq) |
| KELMADI | `#F87171` (qizil) |
| DAVOMIYLIK % | Progress bar + foiz matn |

**Davomiylik % ustuni:**
- Progress bar: height 6px, bg `#2A2A42`, fill `#10B981`
- Foiz matn: 13px `#34D399` — o'ng tomonda

---

## 6. Komponent Kutubxonasi

### 6.1 Tugmalar

**Primary (yashil outline):**
```
background: transparent
border: 1px solid #00C98D
color: #00C98D
hover: background rgba(0,201,141,0.12)
height: 36px, padding: 0 16px, radius: 8px, font: 13px 500
```

**Secondary:**
```
background: #1C1C30
border: 1px solid #2A2A42
color: #94A3B8
hover: border #353550, color #E2E8F0
height: 36px, padding: 0 16px, radius: 8px
```

**Danger:**
```
background: #2D0E0E
border: 1px solid #EF4444
color: #F87171
hover: background #3D1212
```

### 6.2 Input / Select

```
background: #1C1C30
border: 1px solid #2A2A42
color: #E2E8F0
placeholder: #475569
radius: 8px
height: 36px, padding: 0 12px
focus: border #00C98D, box-shadow: 0 0 0 3px rgba(0,201,141,0.12)
font: 13px
```

### 6.3 Avatar

| O'lcham | Diametr | Font |
|---|---|---|
| XS | 24px | 10px |
| SM | 32px | 13px |
| MD | 40px | 15px |
| LG | 48px | 17px |
| XL | 80px | 28px |

**Gradient ranglar (ism bo'yicha):**
```
A–E: #7C3AED → #5B21B6 (binafsha)
F–J: #0EA5E9 → #0369A1 (ko'k)
K–O: #10B981 → #047857 (yashil)
P–T: #F59E0B → #B45309 (sariq)
U–Z: #EF4444 → #B91C1C (qizil)
```

### 6.4 Badge

```
padding: 3px 10px
radius: 9999px
font: 11px 600
border: 1px solid (har tur uchun)
```

### 6.5 Jadval (Table)

```
Header:
  background: #0F0F1E
  color: #475569, 11px 600, uppercase, letter-spacing: 0.08em
  padding: 12px 16px

Qator:
  height: 52px
  hover: background #1A1A32
  border-bottom: 1px solid #2A2A42

Cell:
  padding: 0 16px
  font: 13–14px #94A3B8
```

### 6.6 Karta (Card)

```
background: #14142A
border: 1px solid #2A2A42
border-radius: 12px
padding: 20px 24px

hover (interaktiv karta):
  border-color: #353550
  background: #1A1A32
```

### 6.7 Confirmation Dialog

```
background: #14142A
border: 1px solid #2A2A42
border-radius: 12px
max-width: 440px
overlay: rgba(0,0,0,0.7)

Sarlavha: 16px 600 #E2E8F0
Matn: 14px #94A3B8
```

### 6.8 Drawer (O'ngdan chiqadi)

```
background: #0F0F1E
border-left: 1px solid #2A2A42
width: 480px (kichik), 600px (katta)
overlay: rgba(0,0,0,0.6)

Sarlavha zona:
  background: #0F0F1E
  border-bottom: 1px solid #2A2A42
  padding: 20px 24px
  font: 16px 600 #E2E8F0

Footer:
  position: sticky, bottom: 0
  background: #0F0F1E
  border-top: 1px solid #2A2A42
  padding: 16px 24px

Animatsiya:
  kirish: translateX(100%→0) 250ms ease-out
  chiqish: translateX(0→100%) 200ms ease-in
```

### 6.9 Toast

```
background: #1E1E35
border: 1px solid #2A2A42
border-left: 4px solid (tur rangi)
radius: 8px
padding: 14px 16px
width: 340px
o'ng yuqori burchak
auto-dismiss: 4s

Success: border-left #10B981
Error:   border-left #EF4444
Warning: border-left #F59E0B
```

### 6.10 Loading (Skeleton)

```
background: #1C1C30
shimmer: linear-gradient(90deg, #1C1C30 25%, #252540 50%, #1C1C30 75%)
animation: 1.5s loop, left to right
border-radius: 6px
```

### 6.11 Dropdown / Select Menu

```
background: #1E1E35
border: 1px solid #353550
border-radius: 8px
box-shadow: 0 8px 24px rgba(0,0,0,0.4)

Item:
  height: 36px, padding: 0 12px
  font: 13px #94A3B8
  hover: background #252540, color #E2E8F0
  aktiv: background rgba(0,201,141,0.1), color #00C98D
```

---

## 7. Animatsiyalar

| Hodisa | Animatsiya | Davomiylik |
|---|---|---|
| Drawer kirish | translateX(100%→0) | 250ms ease-out |
| Drawer chiqish | translateX(0→100%) | 200ms ease-in |
| Dialog kirish | fade + scale(0.95→1) | 200ms |
| Live feed yangi qator | slide-down + fade-in | 300ms |
| Toast kirish | slide-in-right | 250ms |
| Toast chiqish | fade + slide-right | 200ms |
| Dropdown | fade + translateY(-4px→0) | 150ms |
| Skeleton shimmer | gradient sweep | 1500ms loop |
| Online puls dot | scale pulse | 2000ms loop |
| Soat yangilanishi | none (instant) | — |

**Easing:** `cubic-bezier(0.4, 0, 0.2, 1)`

---

## 8. Maxsus Elementlar

### 8.1 Live Clock (Topbar)

```
font-family: 'JetBrains Mono', monospace
font: 16px 600
color: #00C98D
letter-spacing: 0.05em
```

### 8.2 Qurilma holat indikatori (Sidebar pastida)

```
● yashil dot (8px, animated pulse)
"Qurilma ulangan" — 12px #34D399
IP manzil — 11px #475569
```

### 8.3 Notification Badge (Sidebar)

```
background: #EF4444
color: #FFFFFF
font: 10px 700
min-width: 18px, height: 18px
border-radius: full
padding: 0 4px
```

### 8.4 Progress Bar (Davomiylik %)

```
height: 6px
background: #2A2A42
border-radius: full

fill:
  > 90%: #10B981 (yashil)
  70–90%: #F59E0B (sariq)
  < 70%: #EF4444 (qizil)
```

---

## 9. Responsive

### 9.1 Breakpointlar

| Nom | Kenglik |
|---|---|
| Mobile | 360–767px |
| Tablet | 768–1279px |
| Desktop | 1280px+ |

### 9.2 Desktop (1280px+)
- Sidebar: 220px, fixed
- Grid: 4 ustun (shaxslar)
- Barcha ustunlar to'liq

### 9.3 Tablet (768–1279px)
- Sidebar: collapsed (64px, faqat ikonlar)
- Grid: 2–3 ustun
- Jadval: ikkinchi darajali ustunlar yashiriladi

### 9.4 Telefon (360–767px)
- Sidebar: yo'q → bottom navigation
- Grid: 1 ustun (to'liq kenglik karta)
- Drawer: bottom sheet (100% kenglik, 90% balandlik)

---

## 10. Deliverables (Figma)

| № | Sahifa |
|---|---|
| 1 | Login |
| 2 | Dashboard |
| 3 | Kirdi-Chiqdi Jurnali |
| 4 | Xodimlar va Talabalar (grid) |
| 5 | Shaxs profili |
| 6 | Hisobotlar |
| 7 | FaceID Qurilmalar |
| 8 | Binolar |
| 9 | Davomat jadvali |
| 10 | Sozlamalar |

**Figma talab:**
- Design System page: barcha tokenlar (ranglar, tipografiya, spacing)
- Components page: barcha reusable komponentlar (dark tema)
- Screens page: har bir sahifa
- Dark mode default, light mode ixtiyoriy

---

*Yaratilgan: 2026-05-04 | Versiya: 1.0 | Dark Theme*
