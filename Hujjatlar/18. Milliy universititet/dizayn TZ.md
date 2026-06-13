# Milliy Universiteti — Davomat Tizimi
## Dizayn Texnik Topshirig'i (UI/UX Spec)

**Versiya:** 1.2
**Sana:** 2026-05-04
**Buyurtmachi:** Milliy Universiteti
**Maqsadli foydalanuvchi:** UI/UX dizayner

---

## 1. Loyiha Haqida Qisqacha

FaceID qurilmalari orqali talabalar, o'qituvchilar va xodimlar davomatini kuzatuvchi **web admin panel**. Tizim real vaqtda monitoring, HR boshqaruv va analitika dashboardini birlashtiradi.

**Tizim xarakteri:** monitoring + HR + analitika
**Asosiy foydalanuvchilar:** administrator, HR menejer, operator, xavfsizlik xodimi

---

## 2. Texnik Cheklovlar

| Parametr | Qiymat |
|---|---|
| Minimal ekran kengligi | 1280px |
| Maqbul ekran | 1440px, 1920px |
| Platforma | Web (desktop-first) |
| Brauzerlar | Chrome 100+, Firefox 100+, Edge 100+ |
| Frontend texnologiya | React.js + Tailwind CSS |
| Ikonlar | Lucide Icons yoki Heroicons |
| Grafiklar | Recharts yoki Chart.js |
| Vaqt mintaqasi | Asia/Tashkent (UTC+5) — barcha vaqtlar shu mintaqada ko'rsatiladi |
| Fayl saqlash | Local server — rasm/hujjat to'g'ridan-to'g'ri NestJS serveriga yuklanadi |

---

## 3. Dizayn Tizimi (Design System)

### 3.1 Rang Palitasi

#### Asosiy ranglar

| Nom | Hex | Ishlatish |
|---|---|---|
| Primary | `#2563EB` | Tugmalar, aktiv menyu, link |
| Primary Dark | `#1D4ED8` | Hover holati |
| Primary Light | `#EFF6FF` | Background highlight |

#### Semantik ranglar

| Nom | Hex | Ishlatish |
|---|---|---|
| Success | `#16A34A` | Normal davomat, online, yashil status |
| Success Light | `#DCFCE7` | Success badge background |
| Warning | `#D97706` | Kechikkan, ogohlantirish |
| Warning Light | `#FEF3C7` | Warning badge background |
| Danger | `#DC2626` | Yo'q, offline, muammo |
| Danger Light | `#FEE2E2` | Danger badge background |
| Info | `#0891B2` | Ma'lumot, neytral |
| Info Light | `#E0F2FE` | Info badge background |

#### Neytral ranglar

| Nom | Hex | Ishlatish |
|---|---|---|
| Gray 50 | `#F9FAFB` | Sahifa background |
| Gray 100 | `#F3F4F6` | Card background, hover |
| Gray 200 | `#E5E7EB` | Chegara, divider |
| Gray 400 | `#9CA3AF` | Placeholder, ikkinchi darajali matn |
| Gray 600 | `#4B5563` | Oddiy matn |
| Gray 800 | `#1F2937` | Sarlavha, primary matn |
| White | `#FFFFFF` | Card, sidebar, topbar |

#### Sidebar rang sxemasi

| Element | Rang |
|---|---|
| Sidebar background | `#0F172A` (qorong'i ko'k) |
| Aktiv menyu item | `#1E40AF` |
| Aktiv menyu matn | `#FFFFFF` |
| Oddiy menyu matn | `#94A3B8` |
| Hover background | `#1E293B` |
| Logo zona | `#0F172A` |

---

### 3.2 Tipografiya

**Font oilasi:** `Inter` (Google Fonts)
**Fallback:** `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`

| Daraja | Font size | Font weight | Line height | Ishlatish |
|---|---|---|---|---|
| H1 | 28px | 700 | 1.3 | Sahifa sarlavhasi |
| H2 | 22px | 600 | 1.3 | Bo'lim sarlavhasi |
| H3 | 18px | 600 | 1.4 | Karta sarlavhasi |
| H4 | 16px | 600 | 1.4 | Widget sarlavhasi |
| Body Large | 16px | 400 | 1.5 | Asosiy matn |
| Body | 14px | 400 | 1.5 | Table, form matn |
| Body Small | 13px | 400 | 1.5 | Ikkinchi darajali |
| Caption | 12px | 400 | 1.4 | Yorliq, timestamp |
| Label | 12px | 500 | 1.4 | Form label |
| Badge | 11px | 600 | 1 | Status badge |

---

### 3.3 Soyalar (Shadows)

```
Shadow SM  : 0 1px 3px rgba(0,0,0,0.08)       — Card default
Shadow MD  : 0 4px 12px rgba(0,0,0,0.10)      — Dropdown, modal
Shadow LG  : 0 8px 24px rgba(0,0,0,0.12)      — Dialog, popover
Shadow XL  : 0 16px 40px rgba(0,0,0,0.15)     — Full modal
```

---

### 3.4 Bo'shliqlar (Spacing)

4px bazali sistema:

| Token | Qiymat | Ishlatish |
|---|---|---|
| space-1 | 4px | Matn ichki |
| space-2 | 8px | Matn va ikonlar orasida |
| space-3 | 12px | Badge, tag ichki padding |
| space-4 | 16px | Card padding (kichik) |
| space-5 | 20px | Form maydon orasidagi bo'shliq |
| space-6 | 24px | Card padding (standart) |
| space-8 | 32px | Bo'limlar orasida |
| space-10 | 40px | Sahifa sarlavhasi ostida |
| space-12 | 48px | Bo'lim sarlavhalari |

---

### 3.5 Radius (Border Radius)

| Token | Qiymat | Ishlatish |
|---|---|---|
| radius-sm | 4px | Badge, tag |
| radius-md | 8px | Input, button, card |
| radius-lg | 12px | Modal, katta kartalar |
| radius-xl | 16px | Drawer, panel |
| radius-full | 9999px | Avatar, pill badge |

---

### 3.6 Tugmalar (Buttons)

**Primary tugma:**
- Background: `#2563EB` → hover: `#1D4ED8`
- Matn: `#FFFFFF`, Font: 14px 600
- Padding: 10px 20px, Radius: 8px
- Height: 40px

**Secondary tugma:**
- Background: `#FFFFFF`, Border: `1px solid #E5E7EB`
- Matn: `#374151`, hover background: `#F9FAFB`

**Danger tugma:**
- Background: `#DC2626` → hover: `#B91C1C`
- Matn: `#FFFFFF`

**Ghost/text tugma:**
- Background: transparent, hover: `#F3F4F6`
- Matn: `#2563EB`

**Icon tugma:**
- 36x36px, radius: 8px, background: transparent
- Hover: `#F3F4F6`

**Tugma o'lchamlari:**

| O'lcham | Height | Padding | Font |
|---|---|---|---|
| Small | 32px | 6px 14px | 13px |
| Medium | 40px | 10px 20px | 14px |
| Large | 48px | 12px 28px | 16px |

---

### 3.7 Inputlar (Form Elements)

**Text Input:**
- Height: 40px, Padding: 10px 14px
- Border: `1px solid #E5E7EB`, Radius: 8px
- Background: `#FFFFFF`
- Focus border: `2px solid #2563EB`, shadow: `0 0 0 3px #EFF6FF`
- Error border: `1px solid #DC2626`
- Font: 14px, Placeholder color: `#9CA3AF`

**Select, Datepicker:** bir xil stil

**Textarea:** radius: 8px, min-height: 80px

**Form Label:** 12px 500, `#374151`, margin-bottom: 6px

**Error matn:** 12px, `#DC2626`, margin-top: 4px

---

### 3.8 Status Badge'lar

Har bir status badge: `border-radius: 9999px`, `padding: 2px 10px`, `font: 11px 600`

| Status | Background | Matn rangi | Ko'rsatilishi |
|---|---|---|---|
| Keldi (Normal) | `#DCFCE7` | `#16A34A` | Keldi |
| Kechikkan | `#FEF3C7` | `#D97706` | Kechikkan |
| Erta ketgan | `#FEE2E2` | `#DC2626` | Erta ketgan |
| Kelmadi | `#F3F4F6` | `#6B7280` | Kelmadi |
| Ruxsatli | `#E0F2FE` | `#0891B2` | Ruxsatli |
| Bayram | `#F3E8FF` | `#9333EA` | Bayram |
| Online | `#DCFCE7` | `#16A34A` | Online |
| Offline | `#FEE2E2` | `#DC2626` | Offline |
| Aktiv | `#DCFCE7` | `#16A34A` | Aktiv |
| Noaktiv | `#F3F4F6` | `#6B7280` | Noaktiv |

---

### 3.9 Jadval (Table)

- Header: background `#F9FAFB`, matn `#374151`, 12px 600, uppercase, letter-spacing: 0.05em
- Qator height: 56px
- Qator hover: background `#F9FAFB`
- Border: `1px solid #E5E7EB` (faqat gorizontal)
- Cell padding: 16px
- Birinchi ustun (ism): 14px 500, `#111827`
- Oddiy cell: 14px, `#374151`
- Ikkinchi darajali: 13px, `#6B7280`

---

## 4. Layout Tuzilmasi

```
┌──────────────────────────────────────────────────────────┐
│  TOPBAR (60px balandlik, sticky)                         │
├───────────┬──────────────────────────────────────────────┤
│           │                                              │
│  SIDEBAR  │         CONTENT AREA                        │
│  (240px)  │         (qolgan joy)                        │
│  fixed    │         padding: 24px                       │
│           │                                              │
└───────────┴──────────────────────────────────────────────┘
```

### 4.1 Sidebar (240px, fixed, full height)

**Tuzilma (yuqoridan pastga):**

```
┌──────────────────────────┐
│  LOGO zona (64px)        │
│  [icon] DAVOMAT          │
├──────────────────────────┤
│  Menyu — asosiy (scroll) │
│                          │
│  [icon] Dashboard        │
│  [icon] Monitoring    ●  │  ← live badge
│  [icon] Talabalar        │
│  [icon] O'qituvchilar    │
│  [icon] Xodimlar         │
│  [icon] Davomat          │
│  [icon] Dars jadvali     │
│  [icon] Binolar          │
│  [icon] FaceID           │
│  [icon] Hisobotlar       │
├──────────────────────────┤
│  Pastki qism             │
│  [icon] Sozlamalar       │
│  [icon] Yordam           │
└──────────────────────────┘
```

**Menyu item holatlari:**
- **Default:** icon `#94A3B8` + matn `#94A3B8`, background transparent
- **Hover:** background `#1E293B`, icon + matn `#E2E8F0`
- **Aktiv:** background `#1E40AF`, icon + matn `#FFFFFF`, chapida `3px solid #60A5FA` chiziq
- **Badge (Monitoring):** kichik `●` yashil animatsion nuqta — live ekanligi belgisi

**Menyu item o'lchami:** height 44px, padding 0 16px, gap 12px, radius 8px (margin: 2px 8px)

---

### 4.2 Topbar (60px, sticky top)

```
┌─────────────────────────────────────────────────────────┐
│  [☰ Collapse]  [Sahifa nomi / breadcrumb]    [Qidiruv]  [🔔]  [Admin ▾] │
└─────────────────────────────────────────────────────────┘
```

- Background: `#FFFFFF`, border-bottom: `1px solid #E5E7EB`
- **Collapse tugmasi:** sidebar yashirish/ko'rsatish
- **Breadcrumb:** 14px, `#6B7280` → aktiv: `#111827`
- **Global search:** 280px kenglik, placeholder: "F.I.SH bo'yicha qidirish...", shortcut belgisi `/`
- **Notification bell:** badge bilan (o'qilmagan soni)
- **Admin dropdown:** avatar (32px) + ism + rol + chevron; dropdown: "Profil", "Parol o'zgartirish", "Chiqish"

---

### 4.3 Content Area

- Background: `#F9FAFB`
- Padding: 24px
- **Sahifa header:** sahifa nomi (H1) + amallar (tugmalar) — space-between, margin-bottom: 24px

---

## 5. Sahifalar — Batafsil Spesifikatsiya

> **Umumiy qoida:** Barcha **qo'shish/tahrirlash** amallari **Drawer** (§6.6) orqali.
> Barcha **o'chirish** amallari **Confirmation Dialog** (§6.4) orqali tasdiqlash so'raydi.

---

### 5.1 Dashboard (Bosh sahifa)

**URL:** `/dashboard`

#### Layout:

```
┌──────────────────────────────────────────────────────────┐
│  Dashboard          [Kun ▾]  [Hafta ▾]  [Oy ▾]  [Period]│
├──────────────────────────────────────────────────────────┤
│  [Widget 1]  [Widget 2]  [Widget 3]  [Widget 4]  [Widget 5] │
│  (5 ta teng kenglikdagi karta, 1 qatorda)                │
├─────────────────────────┬────────────────────────────────┤
│  Kunlik kirishlar       │  Binolar bo'yicha              │
│  (Line chart, 60%)      │  (Bar chart, 40%)              │
├─────────────────────────┴──────────┬───────────────────  │
│  Oxirgi hodisalar (Live feed)      │  Davomat % (Pie)    │
│  (scroll, real-time yangilanadi)   │                     │
└────────────────────────────────────┴─────────────────────┘
```

#### Widgetlar (5 ta karta):

Har bir widget kartasi:
- Background: `#FFFFFF`, radius: 12px, shadow: SM
- Padding: 20px 24px
- Yuqori qism: sarlavha (14px `#6B7280`) + ikoncha (right)
- Asosiy son: 32px 700 `#111827`
- Pastki qism: o'zgarish ko'rsatkichi (+12% ↑ yashil yoki -3% ↓ qizil)

| № | Sarlavha | Ikoncha | Rang |
|---|---|---|---|
| 1 | Bugun kirganlar | `Users` | Ko'k |
| 2 | Hozir binoda | `Building2` | Yashil (live puls) |
| 3 | Kechikkanlar | `Clock` | Sariq |
| 4 | Erta ketganlar | `LogOut` | To'q sariq |
| 5 | Faol qurilmalar | `Cpu` | Ko'k-yashil |

**"Hozir binoda" widget:** raqam har 15 soniyada HTTP polling orqali yangilanadi; chap tomonda yashil puls animatsiyasi (`●` pulsing dot).

#### Grafiklar:

**Kunlik kirishlar (Line chart):**
- X o'qi: soatlar (00:00 — 23:00)
- Y o'qi: kirganlar soni
- 2 ta chiziq: Kirish (ko'k `#2563EB`) va Chiqish (kulrang `#9CA3AF`)
- Tooltip: soat + kirgan/chiqqan soni
- Height: 260px

**Binolar bo'yicha (Bar chart):**
- X o'qi: bino nomlari
- Y o'qi: odamlar soni
- Rang: `#2563EB`
- Hover: `#1D4ED8`
- Height: 260px

**Davomat % (Pie/Donut chart):**
- Talabalar davomat foizi
- Rang: Keldi `#16A34A`, Kelmadi `#DC2626`, Ruxsatli `#0891B2`
- Markazda: umumiy foiz (katta raqam)
- Legend: pastda

**Oxirgi hodisalar (Live feed):**
- Har bir hodisa: avatar + ism + rol badge + bino + qurilma + vaqt + kirish/chiqish ikoncha
- Har 3 soniyada HTTP polling yangilanadi
- Max ko'rinadigan: 20 ta (scroll)

---

### 5.2 Real-time Monitoring

**URL:** `/monitoring`

```
┌──────────────────────────────────────────────────────────┐
│  Monitoring        [● LIVE]          [Pause] [Clear]     │
├──────────┬───────────────────────────────────────────────┤
│ Filterlar│  Live hodisalar jadvali                       │
│          │                                               │
│ Bino [▾] │  F.I.SH | Rol | Bino | Qurilma | Vaqt | Status│
│ Rol  [▾] │  ────────────────────────────────────────────│
│          │  [avatar] Aliyev A.  [Talaba] 1-bino ...     │
│ [Reset]  │  [avatar] Karimov B. [O'qituvchi] 2-bino ... │
│          │  ...                                          │
│ Statistika         │                                     │
│ Hozir: 142 kishi  │                                     │
│ Bugun: 1,234       │                                     │
│ Bino-1: 67         │                                     │
│ Bino-2: 45         │                                     │
│ Bino-3: 30         │                                     │
└──────────┴───────────────────────────────────────────────┘
```

**Jadval ustunlari:**

| Ustun | Kenglik | Tavsif |
|---|---|---|
| F.I.SH | flex | Avatar (32px) + ism + HEMIS ID |
| Rol | 120px | Badge: Talaba / O'qituvchi / Xodim |
| Bino | 140px | Bino nomi |
| Qurilma | 160px | Qurilma nomi |
| Vaqt | 100px | HH:MM:SS formatda |
| Status | 100px | ↑ Kirish (yashil) / ↓ Chiqish (kulrang) |

**Live rejim (HTTP Polling):**
- `[● LIVE]` — yashil pulsing badge; `[Pause]` bosib to'xtatiladi
- Frontend har **3 soniyada** `GET /api/monitoring/events?after={lastId}` so'rov yuboradi
- **Virtualization:** `@tanstack/react-virtual` — faqat ko'rinadigan qatorlar DOM da saqlanadi
- **Batch yangilash:** polling javobi kelganda bir martalik DOM yangilanishi
- **Avtomatik Pause:** foydalanuvchi pastga scroll qilsa polling to'xtaydi
- Paused holatda sariq banner: `↑ 24 yangi hodisa — Davom ettirish` — bosish bilan polling qayta boshlanadi
- Pagination **yo'q** — o'rniga **infinite scroll** (pastga tushsa eski hodisalar yuklanadi)
- Tarixiy qidiruv faqat `/attendance` sahifasida mavjud

**Chap panel filterlari:**
- Bino dropdown (multi-select)
- Rol dropdown (Talaba / O'qituvchi / Xodim / Hammasi)
- Reset tugmasi
- **Hozirgi holat:** har bir bino uchun hozir ichidagi odamlar soni (real-time)

---

### 5.3 Talabalar, O'qituvchilar, Xodimlar (Foydalanuvchilar moduli)

**URL:** `/students` | `/teachers` | `/employees`

**Uchala sahifa bir xil UI pattern — faqat ustun nomlari farqlanadi.**

#### 5.3.1 Ro'yxat sahifasi

```
┌──────────────────────────────────────────────────────────┐
│  Talabalar (3,421 ta)    [+ Qo'shish]  [⬇ Export]       │
├──────────────────────────────────────────────────────────┤
│  [🔍 Qidirish...]  [Guruh ▾]  [Fakultet ▾]  [Status ▾] │
├──────────────────────────────────────────────────────────┤
│  Rasm | F.I.SH ↕  | ID | Guruh | Status | Oxirgi kirish  │
│  ─────────────────────────────────────────────────────── │
│  [img] Aliyev Ali    123  3-B  [Aktiv]   Bugun 08:32     │
│  [img] Karimov B.    124  2-A  [Aktiv]   Kecha 17:45     │
│  [img] Rahimov R.    125  1-C  [Noaktiv] 3 kun oldin     │
├──────────────────────────────────────────────────────────┤
│  ← 1  2  3 ... 34 →          Ko'rsatish: 20 ▾           │
└──────────────────────────────────────────────────────────┘
```

**Ustunlar:**

Talabalar uchun:
| Ustun | Kenglik | Tavsif |
|---|---|---|
| Rasm | 48px (avatar) | |
| F.I.SH | flex | |
| HEMIS ID | 100px | |
| Guruh | 80px | |
| Fakultet | 160px | |
| Status | 90px | Aktiv / Noaktiv |
| FaceID Sync | 100px | Synced / Queued / Xato (§6.7 ga qarang) |
| Oxirgi kirish | 140px | UTC+5 da |
| Amallar | 80px | Ko'rish + Tahrirlash |

O'qituvchilar uchun: Guruh → Kafedra
Xodimlar uchun: Guruh → Lavozim

**Filter qatori:**
- Qidiruv: `280px`, debounce 300ms
- Dropdown filterlar: `140px` har biri
- Aktiv filterlarda: chip ko'rinishida (× bilan yopiladi)

**Qator hover:** amallar ikonalari ko'rinadi (Ko'rish `👁`, Tahrirlash `✎`)

**Pagination:** `← Oldingi | 1 2 3 ... 34 | Keyingi →` + `Ko'rsatish: 20 ▾`

#### 5.3.2 Profil sahifasi

**URL:** `/students/:id` | `/teachers/:id` | `/employees/:id`

```
┌──────────────────────────────────────────────────────────┐
│  ← Talabalar    Aliyev Alisher — Profil   [Tahrirlash]  │
├──────────────────────────────────────────────────────────┤
│  ┌─────────────────────────┐  ┌──────────────────────┐  │
│  │  Asosiy ma'lumot        │  │  Hozirgi holat       │  │
│  │  [avatar 80px]          │  │  🟢 1-bino ichida    │  │
│  │  Aliyev Alisher         │  │  Kirdi: 08:32        │  │
│  │  HEMIS: 12345           │  ├──────────────────────┤  │
│  │  Guruh: 3-B             │  │  Bu oy statistikasi  │  │
│  │  Fakultet: Informatika  │  │  Ishlagan: 142 soat  │  │
│  │  Status: [Aktiv]        │  │  Kechikish: 3 marta  │  │
│  └─────────────────────────┘  │  Davomat: 94%        │  │
│                                └──────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  [Umumiy]  [Binolar kesimida]  [Tabel]                   │
├──────────────────────────────────────────────────────────┤
│  Sana filter: [dan __/__/____] [gacha __/__/____] [OK]   │
│                                                          │
│  Sana   | Kirish | Chiqish | Bino  | Ishlagan | Status  │
│  ─────────────────────────────────────────────────────── │
│  04 May  | 08:32  | 17:45   | 1-bino | 9s 13d  | Keldi  │
│  03 May  | 09:15  | 17:30   | 1-bino | 8s 15d  | Kechikkan│
└──────────────────────────────────────────────────────────┘
```

**Asosiy ma'lumot kartasi:**
- Avatar: 80px, border-radius: full, border: `3px solid #E5E7EB`
- Ism: H2, 22px 700
- HEMIS ID: 13px, `#6B7280`
- Status badge
- **FaceID Sync badge** — §6.7 ga qarang (Synced / Queued / Xato)

**Hozirgi holat kartasi:**
- `🟢 Binoda` — yashil matn, bino nomi + kirish vaqti (UTC+5)
- `🔴 Tashqarida` — qizil matn, oxirgi chiqish vaqti (UTC+5)

**Bu oy statistikasi:**
- 3 ta raqam: ishlagan soat, kechikish soni, davomat %
- Davomat %: progress bar (yashil, height: 6px)

**Tabs:**

| Tab | Tavsif |
|---|---|
| `Davomat` | Sanalarga sortlangan davomat jadvali (kirish, chiqish, status, ishlagan soat) |
| `Binolar kesimida` | Har bir binoga necha marta kirgan — jadval: bino nomi, kirish soni, o'rtacha vaqt |
| `Kirish joylari kesimida` | Qaysi kirish joyidan kirganligi — jadval: location_note, kirish soni |
| `Turniketlar kesimida` | Qaysi turniket orqali kirganligi — jadval: turniket №, kirish/chiqish soni |
| `Qurilmalar kesimida` | Qaysi FaceID qurilmada ko'proq qatnashgan — jadval: qurilma nomi, hodisa soni |
| `Tabel` | Joriy oy kunlik ko'rinishi (oylik jadval) |

**Tabel ko'rinish:**
Oyning har bir kuni uchun katakcha:

| Holat | Ko'rinish |
|---|---|
| Keldi | Yashil `✓` |
| Kechikkan | Sariq `⏰` |
| Kelmadi | Qizil `✗` |
| Bayram | Binafsha `★` |
| Ruxsatli | Ko'k `~` |
| Ish kuni emas | Kulrang (bo'sh) |

---

### 5.4 Davomat Sahifasi

**URL:** `/attendance`

```
┌──────────────────────────────────────────────────────────┐
│  Davomat jadvali              [+ Qo'lda qo'shish]        │
├──────────────────────────────────────────────────────────┤
│  [Sana ____/__/____]  [Rol ▾]  [Bino ▾]  [Status ▾]    │
│  [🔍 F.I.SH qidirish...]              [Reset]           │
├──────────────────────────────────────────────────────────┤
│  F.I.SH | Sana | Kirish | Chiqish | Ishlagan | Status | Amal│
│  ──────────────────────────────────────────────────────  │
│  Aliyev A. | 04.05 | 08:32 | 17:45 | 9s 13d | [Keldi] | ✎│
│  Karimov B. | 04.05 | 09:15 | 17:30 | 8s 15d | [Kechikkan]│
│  Rahimov R. | 04.05 | —     | —     | —      | [Kelmadi]  │
└──────────────────────────────────────────────────────────┘
```

#### Qo'lda davomat qo'shish (Drawer — o'ngdan chiqadi):

```
┌──────────────────────────────────┐
│  Davomat qo'shish          [✕]  │
├──────────────────────────────────┤
│  Foydalanuvchi *                 │
│  [🔍 F.I.SH yoki HEMIS ID...]   │
│                                  │
│  Sana *         Kirish vaqti *   │
│  [__/__/____]   [__:__]          │
│                                  │
│  Chiqish vaqti                   │
│  [__:__]                         │
│                                  │
│  Izoh (sababini yozing) *        │
│  [                            ]  │
│  [                            ]  │
│                                  │
│  Hujjat (ixtiyoriy)              │
│  [📎 Fayl tanlash]               │
│                                  │
│  [Bekor]         [Saqlash]       │
└──────────────────────────────────┘
```

---

### 5.5 Dars Jadvali

**URL:** `/schedules`

```
┌──────────────────────────────────────────────────────────┐
│  Dars jadvali    [Haftalik ●] [Ro'yxat]   [← Hafta →]  │
│                  Dush  Sesh  Chor  Pay  Jum  Shan  Yak  │
├──────────────────────────────────────────────────────────┤
│ 08:00 │      │      │[Maths]│      │      │     │        │
│ 09:00 │[Fiz] │      │       │[Fiz] │      │     │        │
│ 10:00 │      │[Info]│       │      │[Kim] │     │        │
│ 11:00 │      │      │       │      │      │     │        │
│ 12:00 │ TANAFFUS                                         │
│ 13:00 │      │      │       │      │      │     │        │
│ 14:00 │[Tar] │      │[Bio]  │      │      │     │        │
└──────────────────────────────────────────────────────────┘
```

**Dars bloki:**
- Background: `#EFF6FF`, border-left: `3px solid #2563EB`
- Fan nomi: 13px 600 `#1E40AF`
- O'qituvchi: 12px `#3B82F6`
- Bino/xona: 11px `#6B7280`
- Hover: shadow MD + ko'proq ma'lumot tooltip

**Filter qatori:**
- O'qituvchi bo'yicha, guruh bo'yicha, bino bo'yicha
- Hafta tanlash: `← 28 Apr — 4 May →`

---

### 5.6 Binolar Sahifasi

**URL:** `/buildings`

#### 5.6.1 Binolar ro'yxati

```
┌──────────────────────────────────────────────────────────┐
│  Binolar (5 ta)                      [+ Bino qo'shish]  │
├──────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐             │
│  │  1-bino          │  │  2-bino          │             │
│  │  🏢              │  │  🏢              │             │
│  │  Hozir: 67 kishi │  │  Hozir: 45 kishi │             │
│  │  4 qurilma       │  │  3 qurilma       │             │
│  │  [Ko'rish]  [✎] [✗]│  │  [Ko'rish]  [✎] [✗]│        │
│  └──────────────────┘  └──────────────────┘             │
└──────────────────────────────────────────────────────────┘
```

- "Hozir: N kishi" — HTTP polling (15s)
- `[✎]` → Drawer ochiladi; `[✗]` → Confirmation dialog

**Qo'shish/tahrirlash Drawer maydonlari:**
- Bino nomi (text, majburiy)
- Manzil (textarea)
- Qavatlar soni (number)

#### 5.6.2 Bino detail sahifasi

**URL:** `/buildings/:id`

```
┌──────────────────────────────────────────────────────────┐
│  ← Binolar     1-bino                  [Tahrirlash]      │
├──────────────────────────────────────────────────────────┤
│  [Umumiy] [Kirish joylari] [Turniketlar] [Qurilmalar]    │
├──────────────────────────────────────────────────────────┤
│  Sana filter: [dan ____] [gacha ____]   [Ko'rish]        │
│                                                          │
│  (Tab tanlangan sahifa ko'rsatiladi)                     │
└──────────────────────────────────────────────────────────┘
```

**Tab — Umumiy:**
- Bugun: kirganlar soni, hozir ichida, qurilmalar (online/offline)
- Kunlik kirishlar grafigi (line chart, so'nggi 7 kun)

**Tab — Kirish joylari kesimida:**
- Jadval: `Joylashuv | Kirish soni | Chiqish soni | Oxirgi faollik`
- Har bir kirish joyi = `faceid_devices.location_note` guruhi
- Filter: tanlangan period

**Tab — Turniketlar kesimida:**
- Jadval: `Turniket # | Yo'nalish | Kirish soni | Chiqish soni`
- `door_direction` badge: Kirish / Chiqish / Ikkalasi
- Filter: tanlangan period

**Tab — Qurilmalar:**
- Jadval: `Nom | Turniket | Yo'nalish | Holat | Oxirgi ping | [🔓 Och]`
- Inline eshik ochish tugmasi (§5.9 kabi)

---

### 5.7 FaceID Qurilmalar Sahifasi

**URL:** `/devices`

```
┌──────────────────────────────────────────────────────────────────┐
│  FaceID Qurilmalar                        [+ Qurilma qo'shish]  │
├──────────────────────────────────────────────────────────────────┤
│  Nom | Bino | Joylashuv | Turniket | Yo'nalish | Holat | Amal   │
│  ────────────────────────────────────────────────────────────── │
│  Kirish-1 │ 1-bino │ Asosiy kirish │ #1 │ [Kirish] │ [Online]  │ [🔓 Och] ⋮ │
│  Chiqish-1│ 1-bino │ Asosiy chiqish│ #1 │ [Chiqish]│ [Online]  │ [🔓 Och] ⋮ │
│  Turniket │ 2-bino │ 2-qavat       │ #3 │ [Ikkalasi]│[Offline] │ [—]      ⋮ │
└──────────────────────────────────────────────────────────────────┘
```

**Ustunlar:**
| Ustun | Kenglik | Tavsif |
|---|---|---|
| Nom | flex | Qurilma nomi |
| Bino | 100px | |
| Joylashuv | 160px | `location_note` |
| Turniket | 80px | `#N` raqami |
| Yo'nalish | 90px | Kirish / Chiqish / Ikkalasi — badge |
| Holat | 90px | Online / Offline — real-time polling |
| Amal | 120px | `[🔓 Och]` tugmasi + `⋮` menyu |

**`[🔓 Eshikni och]` tugmasi:**
- Qurilma `online` bo'lganda aktiv, `offline` bo'lganda `disabled` (kulrang)
- Bosilganda: kichik confirm popover — `"Kirish-1 eshigini ochasizmi?"` + `[Ha, och]` `[Bekor]`
- `[Ha, och]` bosilganda: tugma `[⏳ Ochilmoqda...]` holatiga o'tadi
- Muvaffaqiyatli: tugma `[✓ Ochildi]` (2 soniya), keyin qaytadi
- Xato (offline): `"Qurilma javob bermadi"` toast

**Online/Offline badge:** har 30 soniyada HTTP polling orqali yangilanadi
**Sync vaqti:** `⋮` menyuda ko'rsatiladi — "5 daqiqa oldin", UTC+5
**Amallar (⋮ dropdown):** Ko'rish, Tahrirlash, O'chirish

**Qo'shish/Tahrirlash Drawer (600px):**

```
  Qurilma qo'shish                            [✕]
  ─────────────────────────────────────────────
  Nom *
  [_________________________________]

  Device ID *             Serial raqam *
  [________________]      [________________]

  MAC manzil *            IP manzil *
  [________________]      [192.168.___.___]

  Firmware versiyasi
  [________________]

  CMS port                SMS port
  [7660      ]            [8003      ]

  Secret key *
  [____________________________]

  ISUP Token *
  [____________________________] [👁]
  ⓘ NestJS avtomatik generatsiya qiladi

  Bino *
  [Tanlash ▾]

  Joylashuv izohi
  [_________________________________]

  Turniket raqami         Yo'nalish *
  [___]                   [Kirish ▾]

  ─────────────────────────────────────────────
                          [Bekor]  [Saqlash]
```

- ISUP Token: avtomatik generatsiya qilinadi, `👁` toggle bilan ko'rish mumkin
- Yo'nalish: `Kirish | Chiqish | Ikkalasi`
- `[Saqlash]` bosilganda: NestJS ISUP serverga barcha ma'lumotlarni yuboradi → ISUP server qurilmani ro'yxatga oladi

**O'chirish:** `⋮ → O'chirish` → Confirmation Dialog — `"Kirish-1 qurilmasini o'chirasizmi? Qurilmadagi barcha yuz ma'lumotlari ham o'chiriladi."`

---

### 5.8 Hisobotlar Sahifasi

**URL:** `/reports`

```
┌──────────────────────────────────────────────────────────┐
│  Hisobotlar                                              │
├──────────────────────────────────────────────────────────┤
│  Kesim tanlash:                                          │
│  [Xodimlar][O'qituvchilar][Talabalar]                    │
│  [Binolar][Kirish joylari][Turniketlar][Qurilmalar]      │
├──────────────────────────────────────────────────────────┤
│  Hisobot turi:                                           │
│  [Davomat ●][Kechikishlar][Ishlagan soat][Kelib ketish]  │
├──────────────────────────────────────────────────────────┤
│  Dan: [__/__/____]  Gacha: [__/__/____]                  │
│  [Qo'shimcha filter ▾]         [Hisobot ko'rish]         │
├──────────────────────────────────────────────────────────┤
│  [Jadval / Graf ▾]           [⬇ Excel]  [⬇ PDF]         │
├──────────────────────────────────────────────────────────┤
│  Hisobot natijalari...                                   │
└──────────────────────────────────────────────────────────┘
```

**Kesimlar va qo'shimcha filterlar:**

| Kesim | Qo'shimcha filterlar | Hisobot ustunlari |
|---|---|---|
| **Xodimlar** | Lavozim, bo'lim, status | F.I.SH, ishlagan soat, kechikish, davomat % |
| **O'qituvchilar** | Kafedra, ish turi (class_only/fixed_hours) | F.I.SH, dars soati, faktik kelish, davomat % |
| **Talabalar** | Guruh, kurs, fakultet | F.I.SH, darsga kelish %, kechikish soni |
| **Binolar** | Bino tanlash | Bino nomi, kirish soni, unikal odamlar, o'rtacha vaqt |
| **Kirish joylari** | Bino, joylashuv | Joylashuv, kirish soni, eng gavjum soat |
| **Turniketlar** | Bino, turniket raqami | Turniket #, yo'nalish, kirish/chiqish soni |
| **Qurilmalar** | Bino, holat | Qurilma nomi, ishlov bergan hodisalar soni, offline vaqt |

**Export holati:**
- Tugma bosilganda: `[⏳ Tayyorlanmoqda...]` → `[✓ Yuklab olish]`
- Katta hisobotlar uchun progress bar

---

### 5.9 Bayram Kunlari

**URL:** `/settings/holidays`

```
┌──────────────────────────────────────────────────────────┐
│  Bayram kunlari  2026 ▾            [+ Bayram qo'shish]  │
├──────────────────────────────────────────────────────────┤
│  Nomi               | Boshlanish  | Tugash      | Kun | ⋮│
│  ───────────────────────────────────────────────────────│
│  Navro'z            | 21 Mar 2026 | 23 Mar 2026 |  3  | ⋮│
│  Xotira va qadrlash | 09 May 2026 | 09 May 2026 |  1  | ⋮│
│  Mustaqillik kuni   | 01 Sep 2026 | 01 Sep 2026 |  1  | ⋮│
└──────────────────────────────────────────────────────────┘
```

- **Kun** ustuni: `end_date - start_date + 1` hisoblanadi, avtomatik
- Sana ustiga hover: takvim ko'rinishida period highlight

**Qo'shish/Tahrirlash Drawer (480px) maydonlari:**
- Bayram nomi (text, majburiy)
- Boshlanish sanasi (datepicker, majburiy)
- Tugash sanasi (datepicker, default: boshlanish sanasi)
- Ko'rsatish: `X kun` (avtomatik hisoblanadi)

**O'chirish:** `⋮` menyusi → Confirmation Dialog

---

### 5.10 Sozlamalar

**URL:** `/settings`

Tabs: **Profil | Ish grafigi shablonlari | Admin foydalanuvchilar | HEMIS Sync | Tizim**

---

**Tab — Profil:**
- Ism, email maydonlari (tahrirlash Drawer)
- Parol o'zgartirish (alohida Drawer)

---

**Tab — Ish grafigi shablonlari (`default_work_schedules`):**

```
┌──────────────────────────────────────────────────────────┐
│  Ish grafigi shablonlari          [+ Shablon qo'shish]  │
├──────────────────────────────────────────────────────────┤
│  Nom                   | Ish kunlari | Amal              │
│  ─────────────────────────────────────────────────────── │
│  Standart 5 kunlik     | Du-Ju       | [✎] [✗]          │
│  Yarim kunlik Juma     | Du-Ju (Ju 13:00)| [✎] [✗]     │
└──────────────────────────────────────────────────────────┘
```

Shablon qo'shish/tahrirlash Drawer (600px):
- Shablon nomi
- Kunlar jadvali: har kun uchun `[✓]` checkbox + `start_time` – `end_time`

---

**Tab — Admin foydalanuvchilar:**

```
┌──────────────────────────────────────────────────────────┐
│  Admin foydalanuvchilar              [+ Qo'shish]        │
├──────────────────────────────────────────────────────────┤
│  Ism | Username | Rol | Status | Oxirgi kirish | Amal    │
│  ─────────────────────────────────────────────────────── │
│  Aliyev A. | admin1 | [Super Admin] | [Aktiv] | ... | ⋮  │
└──────────────────────────────────────────────────────────┘
```

Qo'shish/tahrirlash Drawer: ism, username, email, rol, parol (yangi uchun)
O'chirish: Confirmation Dialog

---

**Tab — HEMIS Sync:**

```
┌──────────────────────────────────────────────────────────┐
│  HEMIS Sync holati                                       │
│  Oxirgi sync: Bugun 02:00 ✓  [Hammasini sync qilish]    │
├──────────────────────────────────────────────────────────┤
│  Qo'lda sync:                                            │
│  [Talabalar] [O'qituvchilar] [Xodimlar] [Jadval]         │
├──────────────────────────────────────────────────────────┤
│  Sync tarixi                                             │
│  Sana       | Tur        | Holat   | Qo'shildi | O'ch.   │
│  04.05 02:00 | Hammasi    | ✓ OK   | 12        | 3       │
│  03.05 02:00 | Hammasi    | ✓ OK   | 0         | 0       │
│  02.05 03:15 | Talabalar  | ✗ Xato | —         | —       │
└──────────────────────────────────────────────────────────┘
```

- Sync tugmasi bosilganda: `[⏳ Sync bo'lmoqda...]`
- Xato bo'lsa: qizil badge + xato matni
- `[⬇ Log]` — detalni yuklab olish

---

**Tab — Tizim:**
- ISUP Server URL
- Polling intervallari (default qiymatlar)

---

## 6. Komponent Kutubxonasi

### 6.1 Global Qidiruv

- Input: 280px, debounce 300ms, shortcut `/`
- Dropdown: F.I.SH bo'yicha natijalar, talabalar/o'qituvchilar/xodimlar gruppalariga ajratilgan
- **Backend talabi:** `pg_trgm` extension + `GIN` index — `LIKE '%...%'` ishlatilmaydi
- `↑↓` navigatsiya, `Enter` tanlash, `ESC` yopish

### 6.2 Avatar

| O'lcham | Diametr | Ishlatish |
|---|---|---|
| XS | 24px | Jadval ichida, compact |
| SM | 32px | Topbar, dropdown |
| MD | 40px | Ro'yxat qatorlari |
| LG | 56px | Karta sarlavhasi |
| XL | 80px | Profil sahifasi |

- Border-radius: full (doira)
- Fallback: ism harflari (initials), background: gradient
- Initials rang: `#FFFFFF`, font: 600

### 6.2 Loading States (Skeleton UI)

**Skeleton ranglar:**
- Base: `#E5E7EB`
- Shimmer: `#F3F4F6` to `#E5E7EB`
- Animatsiya: left-to-right shimmer, 1.5s loop

**Skeleton variantlar:**
- Jadval qatori skeleton: avatar + 3 ta matn bloki
- Karta skeleton: sarlavha + raqam + progress
- Grafik skeleton: to'rtburchak blok

### 6.3 Empty State

Qachon ko'rsatiladi: qidiruv natija yo'q, jadval bo'sh

```
        [Ikoncha 48px kulrang]
    Ma'lumot topilmadi
    Qidiruvni o'zgartirib ko'ring
         [Filterni tozalash]
```

- Ikoncha: `#D1D5DB`
- Matn: 16px `#6B7280`
- Alt matn: 14px `#9CA3AF`

### 6.4 Confirmation Dialog

```
┌──────────────────────────────────┐
│  ⚠ O'chirishni tasdiqlang  [✕]  │
├──────────────────────────────────┤
│  Aliyev Alisherni o'chirsangiz,  │
│  uning barcha ma'lumotlari       │
│  o'chiriladi. Davom etasizmi?    │
│                                  │
│         [Bekor]  [O'chirish]     │
└──────────────────────────────────┘
```

- Modal: `max-width: 440px`, radius: 12px, shadow: XL
- Overlay: `rgba(0,0,0,0.5)` backdrop
- "O'chirish" tugmasi: Danger rang

### 6.5 Toast Xabarlari

O'ng yuqori burchak. Width: 360px, radius: 8px, shadow: MD

| Tur | Rang | Ikoncha |
|---|---|---|
| Success | `#DCFCE7` + `#16A34A` border-left | `✓` |
| Error | `#FEE2E2` + `#DC2626` border-left | `✗` |
| Warning | `#FEF3C7` + `#D97706` border-left | `⚠` |
| Info | `#E0F2FE` + `#0891B2` border-left | `ℹ` |

- Border-left: 4px
- Auto-dismiss: 4 soniya
- Ustma-ust kelganda: stack ko'rinish

### 6.6 Drawer (Ma'lumot qo'shish / tahrirlash)

Barcha qo'shish va tahrirlash amallari **o'ng tomondan chiqadigan Drawer** orqali amalga oshiriladi.

```
┌──────────────────────────────────────────────────────────────┐
│  Asosiy sahifa (dimlanadi)                  ┌──────────────┐ │
│                                             │  Drawer      │ │
│                                             │  (480px)     │ │
│                                             │              │ │
│                                             │  Sarlavha [✕]│ │
│                                             │  ───────────│ │
│                                             │  Form       │ │
│                                             │  maydonlari │ │
│                                             │             │ │
│                                             │  [Bekor]    │ │
│                                             │  [Saqlash]  │ │
│                                             └──────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**Xususiyatlar:**
- Kenglik: `480px` (kichik formalar), `600px` (katta formalar)
- Fon: `#FFFFFF`, shadow: `LG` (chap tomonda)
- Overlay: `rgba(0,0,0,0.4)` — faqat vizual, bosib yopilmaydi
- **Persistent:** faqat `[✕]` tugmasi yoki `[Bekor]` bilan yopiladi (tashqariga bosish yopMASLIK kerak)
- Animatsiya: `translateX(100%→0)` `250ms ease-out` (kirish), `translateX(0→100%)` `200ms` (chiqish)
- Sarlavha: 18px 600, border-bottom `1px solid #E5E7EB`
- Forma maydoni padding: 24px
- Footer (tugmalar): `position: sticky; bottom: 0`, background `#FFFFFF`, border-top, padding: 16px 24px
- `[Bekor]` — Secondary tugma, `[Saqlash]` — Primary tugma

### 6.7 Dropdown / Select

- Trigger: input ko'rinishida, chevron ikoncha
- Menu: background `#FFFFFF`, shadow MD, radius 8px, `z-index: 1000`
- Item: 36px height, padding 0 12px, hover: `#F3F4F6`
- Aktiv item: `#EFF6FF`, matn: `#2563EB`, checkmark `✓`
- Multi-select: checkbox bilan

### 6.7 FaceID Sync Status Badge

Foydalanuvchi profili va ro'yxat jadvalidagi yuz sinxronizatsiya holati.

| Holat | Badge ko'rinishi | Rang | Tavsif |
|---|---|---|---|
| `synced` | `✓ Sinxron` | Success (`#DCFCE7` / `#16A34A`) | Yuz barcha qurilmalarga yuklangan |
| `queued` | `⏳ Navbatda` | Info (`#E0F2FE` / `#0891B2`) | Yuklash jarayonida (async) |
| `error` | `✗ Xato` | Danger (`#FEE2E2` / `#DC2626`) | Yuklashda xato — hover da xato matni |
| `not_enrolled` | `— Yuklanmagan` | Gray (`#F3F4F6` / `#6B7280`) | Yuz rasmi yo'q |

- `error` holat: tooltip bilan xato sababi ko'rsatiladi (`Device timeout`, `Invalid image`, ...)
- `queued` holat: badge aylanuvchi animatsiya bilan (spinner, 1s loop)
- Profil sahifasida: asosiy ma'lumot kartasida — `[Aktiv]` badge yonida
- Ro'yxat jadvalida: alohida ustun (§5.3.1)

### 6.8 Vaqt Ko'rsatish Qoidalari

**Barcha vaqtlar UTC+5 (Asia/Tashkent) da ko'rsatiladi.**

| Kontekst | Format | Misol |
|---|---|---|
| Jadval sanasi | `DD.MM.YYYY` | `04.05.2026` |
| Kirish/chiqish vaqti | `HH:mm` | `08:32` |
| To'liq datetime | `DD.MM.YYYY HH:mm` | `04.05.2026 08:32` |
| Relative time | `N daqiqa/soat/kun oldin` | `5 daqiqa oldin` |
| Timestamp (log) | `HH:mm:ss` | `08:32:15` |

- Frontend: `Intl.DateTimeFormat('uz-UZ', { timeZone: 'Asia/Tashkent' })`
- API dan kelgan barcha vaqtlar UTC ISO 8601 (`...Z`) — frontend o'giradi
- Tooltip: relative time ustiga hover qilsa to'liq sana ko'rsatiladi

---

## 7. UX Oqimlar (User Flows)

### 7.1 Global Qidiruv

1. Topbardagi qidiruv input ga `F.I.SH` yoziladi (debounce 300ms)
2. Dropdown ochiladi: talabalar, o'qituvchilar, xodimlar gruppalariga ajratilgan
3. Natijaga bosish: tegishli profil sahifasiga o'tish
4. `ESC` — yopish, `↑↓` — navigatsiya, `Enter` — tanlash

### 7.2 Davomat Qo'lda Qo'shish

1. `[+ Qo'lda qo'shish]` bosiladi → Drawer o'ngdan chiqadi
2. Foydalanuvchi tanlanganda: uning o'sha kungi mavjud davomati ko'rsatiladi
3. Sana, kirish vaqti, izoh (majburiy), fayl (ixtiyoriy) to'ldiriladi
4. `[Saqlash]` → validatsiya → success toast → jadval yangilanadi
5. Drawer faqat `[✕]` yoki `[Bekor]` bilan yopiladi

### 7.3 Hisobot Yuklab Olish

1. Hisobot turi tanlash
2. Filter (sana, rol, bino) o'rnatish
3. `[Hisobot ko'rish]` — preview ko'rsatiladi
4. `[⬇ Excel]` yoki `[⬇ PDF]` bosiladi
5. Tugma: `[⏳ Tayyorlanmoqda...]` holati
6. Tayyor bo'lgach: `[✓ Yuklab olish]` — avtomatik download

### 7.4 Yuz Rasmi Yuklash

1. Profil sahifasida avatar ustiga hover — `[Rasm yuklash]` tugmasi paydo bo'ladi
2. Fayl tanlagichni ochadi (accept: `image/jpeg, image/png`, max: 2MB)
3. Tanlangan rasm preview ko'rsatiladi (crop/zoom ixtiyoriy)
4. `[Saqlash]` bosish → fayl to'g'ridan-to'g'ri NestJS serveriga `multipart/form-data` yuboriladi (S3/MinIO emas)
5. Yuklash jarayonida: progress bar + `[⏳ Yuklanmoqda...]`
6. Muvaffaqiyatli: avatar yangilanadi + **FaceID Sync badge `⏳ Navbatda`** holatiga o'tadi
7. ISUP server asinxron qayta ishlaydi → callback kelgach badge `✓ Sinxron` bo'ladi
8. Xato bo'lsa: badge `✗ Xato` + toast: `"Qurilmaga yuklashda xato. Qayta urinish?"`

### 7.5 FaceID Qurilma Qo'shish

1. `[+ Qurilma qo'shish]` bosiladi → Drawer o'ngdan chiqadi
2. ISUP Token, nom, bino, turniket va yo'nalish kiritiladi
3. `[Saqlash]` → success toast: `"Qurilma qo'shildi. Ulanish tekshirilmoqda..."`
4. 30 soniya ichida jadvalda status `online` yoki `offline` ko'rsatiladi

### 7.6 Ma'lumot O'chirish (Umumiy oqim)

1. `[✗]` yoki `⋮ → O'chirish` bosiladi
2. Confirmation Dialog — ob'ekt nomi + ogohlantirish matni
3. `[Ha, o'chirish]` → delete, success toast
4. `[Bekor]` → dialog yopiladi, hech narsa o'zgarmaydi

---

## 8. Animatsiyalar va O'tishlar

| Holat | Animatsiya | Davomiyligi |
|---|---|---|
| Drawer ochilish | translateX(100%→0) | 250ms ease-out |
| Drawer yopilish | translateX(0→100%) | 200ms ease-in |
| Dialog ochilish | fade-in + scale(0.95→1) | 200ms |
| Dialog yopilish | fade-out + scale(1→0.95) | 150ms |
| Sidebar collapse | width transition | 250ms |
| Page transition | fade | 150ms |
| Live feed yangi qator | slide-down + fade-in | 300ms |
| Toast appear | slide-in-right | 250ms |
| Toast dismiss | fade-out + slide-right | 200ms |
| Dropdown open | fade-in + translateY(-8px→0) | 150ms |
| Skeleton shimmer | left→right gradient sweep | 1500ms loop |
| Widget raqam update | flip/count-up | 500ms |

**Easing:** `cubic-bezier(0.4, 0, 0.2, 1)` (Material Design standard)

---

## 9. Xavfsizlik (UI darajasida)

### 9.1 Rol asosida UI o'zgarishi

| UI Element | super_admin | hr_manager | operator | security |
|---|:---:|:---:|:---:|:---:|
| "Qo'shish/Tahrirlash/O'chirish" tugmalar | ✅ | ✅ | ❌ | ❌ |
| "Qo'lda davomat" tugmasi | ✅ | ✅ | ✅ | ❌ |
| "Export" tugmalari | ✅ | ✅ | ✅ | ❌ |
| Sozlamalar menyu elementi | ✅ | qisman | ❌ | ❌ |
| Admin foydalanuvchilar bo'limi | ✅ | ❌ | ❌ | ❌ |

Ruxsat yo'q elementlar: `disabled` + `cursor: not-allowed` yoki butunlay yashiriladi

### 9.2 Autentifikatsiya

**Login sahifasi (`/login`):**
- Markazlashgan karta (440px), logo yuqorida
- Username va password input
- "Parolni ko'rsat/yashir" toggle
- `[Kirish]` tugmasi
- Noto'g'ri ma'lumot: `"Login yoki parol noto'g'ri"` — input ostida qizil matn
- Muvaffaqiyatli: `/dashboard` ga redirect

**Session tugagan holat:**
- Avtomatik `/login` ga redirect
- Toast: `"Sessiya tugadi, qayta kiring"`

---

## 10. Notifications (Bildirishnomalar)

**Topbar bell ikonasi:**
- Badge: o'qilmagan xabarlar soni (qizil, max: 99+)
- Bosish: dropdown panel ochiladi (360px kenglik)

**Notification panel:**
```
┌────────────────────────────────────────┐
│  Bildirishnomalar     [Hammasini o'qi] │
├────────────────────────────────────────┤
│  🔴 Qurilma "Kirish-2" offline bo'ldi │
│     2 daqiqa oldin                     │
├────────────────────────────────────────┤
│  🟡 HEMIS sync xatolik: timeout        │
│     15 daqiqa oldin                    │
├────────────────────────────────────────┤
│  🟢 HEMIS sync muvaffaqiyatli          │
│     1 soat oldin                       │
└────────────────────────────────────────┘
```

**Bildirishnoma turlari:**
- Qurilma offline/online
- HEMIS sync xatoligi
- Hisobot tayyor
- FaceID sync xato (yuz qurilmaga yuklanmadi)

---

## 11. Responsive Xatti-Harakat

Tizim telefon, planshet va kompyuter ekranlarida ishlaydi.

### 11.1 Breakpointlar

| Nom | Kenglik | Qurilma |
|---|---|---|
| **Mobile** | 360px – 767px | Telefon |
| **Tablet** | 768px – 1279px | Planshet, kichik noutbuk |
| **Desktop** | 1280px+ | Kompyuter, katta noutbuk |

---

### 11.2 Kompyuter (1280px+)

- Sidebar: 240px, fixed, doimiy ko'rinadi
- Barcha ustunlar to'liq ko'rinadi
- Jadvallar paginated
- Grafiklar to'liq o'lchamda

---

### 11.3 Planshet (768px – 1279px)

**Layout:**
- Sidebar: **collapsed** (64px) — faqat ikonlar ko'rinadi
- Hover: tooltip bilan menyu nomi paydo bo'ladi
- Hamburger `☰` bosib sidebar overlay sifatida ochiladi (240px, backdrop bilan)

**Jadvallar:**
- Ikkinchi darajali ustunlar yashiriladi (Fakultet, HEMIS ID va hokazo)
- Asosiy ustunlar: Rasm, Ism, Status, Amallar
- Qo'shimcha ma'lumot `⌄` expand qilish orqali qator ostida ko'rsatiladi

**Grafiklar:**
- Kenglik: `100%` (container ga moslashadi)
- Dashboard: 2 qatorda (3+2 yoki 2+2+1)

**Drawer:** kenglik 100% (to'liq ekran kengligida)

---

### 11.4 Telefon (360px – 767px)

**Layout:**
```
┌──────────────────────────┐
│ [☰]  DAVOMAT        [🔔] │  ← Topbar (56px)
├──────────────────────────┤
│                          │
│   CONTENT AREA           │
│   padding: 16px          │
│                          │
├──────────────────────────┤
│ [🏠][👁][📋][⚙]          │  ← Bottom Navigation
└──────────────────────────┘
```

- Sidebar **yo'q** — o'rniga **Bottom Navigation** (4-5 asosiy menyu elementi)
- `[☰]` (hamburger) bosilganda full-screen menyu ochiladi
- Bottom Navigation elementlari: Dashboard, Monitoring, Davomat, Hisobotlar, Ko'proq

**Jadvallar:**
- Card ko'rinishiga o'tadi (har bir qator — alohida karta)
- Har bir kartada: avatar + ism + status + asosiy ma'lumot

**Misol — Talabalar kartasi (telefon):**
```
┌──────────────────────────────┐
│ [avatar]  Aliyev Alisher     │
│           Guruh: 3-B         │
│           [Aktiv] [✓ Sinxron]│
│           Oxirgi kirish: 08:32│
│                    [Ko'rish] │
└──────────────────────────────┘
```

**Hisobotlar:** filter va natijalar accordion ko'rinishida

**Grafiklar:** faqat asosiy 1 ta grafik ko'rsatiladi, qolganlar "Ko'proq" tugmasi orqali

**Drawer:** kenglik 100%, balandlik 90% (bottom sheet ko'rinishida)

**Forma maydonlari:** har bir maydon to'liq kenglikda

---

### 11.5 Responsive Jadval (Komponentlar)

| Komponent | Desktop | Planshet | Telefon |
|---|---|---|---|
| Sidebar | 240px fixed | 64px collapsed | Yo'q (bottom nav) |
| Topbar | 60px | 60px | 56px |
| Jadval | Ko'p ustun | Asosiy ustunlar | Karta ko'rinishi |
| Drawer | 480–600px | 100% | 100% (bottom sheet) |
| Dashboard widgetlar | 5 teng | 2+2+1 | 1 ta ustun |
| Login karta | 440px | 400px | 100% (16px padding) |

---

## 12. Dark Mode (Ixtiyoriy)

Sozlamalar orqali yoqiladi. CSS variables asosida:

| Variable | Light | Dark |
|---|---|---|
| `--bg-page` | `#F9FAFB` | `#0F172A` |
| `--bg-card` | `#FFFFFF` | `#1E293B` |
| `--border` | `#E5E7EB` | `#334155` |
| `--text-primary` | `#111827` | `#F1F5F9` |
| `--text-secondary` | `#6B7280` | `#94A3B8` |
| `--sidebar-bg` | `#0F172A` | `#020617` |

---

## 13. Sahifalar Ro'yxati (Deliverables)

Dizayner quyidagi sahifalarning Figma/Adobe XD frame'larini tayyorlashi kerak:

| № | Sahifa | URL |
|---|---|---|
| 1 | Login | `/login` |
| 2 | Dashboard | `/dashboard` |
| 3 | Monitoring | `/monitoring` |
| 4 | Talabalar ro'yxat | `/students` |
| 5 | Talaba profil | `/students/:id` |
| 6 | O'qituvchilar ro'yxat | `/teachers` |
| 7 | O'qituvchi profil | `/teachers/:id` |
| 8 | Xodimlar ro'yxat | `/employees` |
| 9 | Xodim profil | `/employees/:id` |
| 10 | Davomat jadvali | `/attendance` |
| 11 | Dars jadvali | `/schedules` |
| 12 | Binolar ro'yxat | `/buildings` |
| 13 | Bino detail | `/buildings/:id` |
| 14 | FaceID qurilmalar | `/devices` |
| 15 | Hisobotlar | `/reports` |
| 16 | Bayram kunlari | `/settings/holidays` |
| 17 | Sozlamalar | `/settings` |

**Har bir sahifa uchun kerakli holat variantlari:**
- Default (ma'lumot bor)
- Bo'sh holat (empty state)
- Loading (skeleton)
- Drawer varianti (qo'shish/tahrirlash bor sahifalar uchun)
- Confirmation Dialog varianti (o'chirish bor sahifalar uchun)

---

## 14. Figma Fayliga Qo'yiladigan Talablar

- **Design System page:** colors, typography, spacing, components
- **Components page:** barcha reusable komponentlar (atom, molecule, organism)
- **Screens page:** har bir sahifa alohida frame
- **Prototype:** asosiy UX oqimlar (login → dashboard → monitoring)
- **Auto Layout:** barcha komponentlarda ishlatilishi shart
- **Naming:** BEM uslubida (`card/header`, `button/primary`, `badge/success`)

---

*Yaratilgan: 2026-05-04 | Versiya: 1.0*
