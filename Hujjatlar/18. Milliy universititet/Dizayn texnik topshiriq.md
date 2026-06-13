Yaxshi, bu loyiha oddiy UI emas — real vaqt, monitoring, statistika va boshqaruvni birlashtirgan murakkab tizim. Shuning uchun UI texnik topshirig‘i (TZ) ham shunchaki “ekranlar ro‘yxati” emas, balki aniq struktura, UX oqim va komponent darajasida yozilishi kerak.

Quyida senga **professional darajadagi UI texnik topshiriq (frontend/UX/UI spec)** beraman — sen buni dizaynerga yoki frontend devga to‘g‘ridan-to‘g‘ri berib ishlatishing mumkin.

---

# 📌 1. Umumiy UI arxitektura

## 1.1 Platforma

* Web-based admin panel (responsive)
* Minimal width: **1280px**
* Tavsiya: Desktop-first (monitoring tizim bo‘lgani uchun)

## 1.2 Texnologiyalar (tavsiya)

* Frontend: ReactJs
* UI framework: Tailwind / Ant Design
* State management: Zustand / Redux Toolkit
* Charts: Recharts / Chart.js
* Real-time: WebSocket

---

# 📌 2. Layout struktura

## 2.1 Asosiy layout

* **Sidebar (chap)**
* **Topbar (yuqori)**
* **Content area (asosiy qism)**

### Sidebar menyu:

1. Dashboard
2. Monitoring (real-time)
3. Talabalar
4. O’qituvchilar
5. Xodimlar
6. Davomat
7. Dars jadvali
8. Binolar
9. FaceID qurilmalar
10. Hisobotlar
11. Sozlamalar

---

# 📌 3. Dashboard (Bosh sahifa)

## 3.1 Widgetlar

* Bugungi kirganlar soni
* Hozir binoda borlar (live count)
* Kechikkanlar soni
* Erta ketganlar
* Faol qurilmalar soni

## 3.2 Grafiklar

* Kunlik kirishlar (line chart)
* Binolar kesimida (bar chart)
* Talabalar davomat % (pie chart)

---

# 📌 4. Real-time Monitoring sahifasi

## 4.1 Live event feed

* Oxirgi kirish/chiqishlar (table yoki list)

  * F.I.O
  * Roli (talaba/o’qituvchi/xodim)
  * Qurilma
  * Bino
  * Vaqt
  * Status (kirish/chiqish)

## 4.2 Live map (ixtiyoriy)

* Binolar kesimida kimlar ichida ekanligi

## 4.3 Filterlar

* Bino
* Role
* Sana (real-time + tarix)

---

# 📌 5. Foydalanuvchilar moduli

## 5.1 Umumiy table (talaba/o’qituvchi/xodim uchun bir xil UI)

* Rasm (face preview)
* F.I.O
* ID
* Guruh / Lavozim
* Status (aktiv/noaktiv)
* Oxirgi kirish vaqti

## 5.2 CRUD form

* F.I.O
* ID (HEMIS bilan bog‘liq)
* Rasm yuklash (face)
* Role
* Guruh / bo‘lim
* Status

---

# 📌 6. Profile sahifa

## 6.1 Umumiy info

* Rasm
* F.I.O
* Role
* Hozirgi holati:

  * 🟢 Binoda
  * 🔴 Tashqarida

## 6.2 Statistikalar

* Oy bo‘yicha ishlagan soat
* Kechikishlar
* Davomat %

## 6.3 Kirib-chiqishlar

Tabs:

* Umumiy
* Binolar kesimida
* Sana bo‘yicha filter

---

# 📌 7. Davomat sahifasi

## 7.1 Table

* F.I.O
* Sana
* Kirish vaqti
* Chiqish vaqti
* Status:

  * Normal
  * Kechikkan
  * Erta ketgan
  * Ruxsatli

## 7.2 Qo‘lda qo‘shish formasi

* F.I.O (select)
* Sana
* Kirish vaqti
* Chiqish vaqti
* Izoh
* Fayl yuklash

---

# 📌 8. Dars jadvali UI

## 8.1 Calendar view

* Week view (asosiy)
* Har bir dars blok sifatida ko‘rinadi

## 8.2 Jadval elementi

* Fan nomi
* O’qituvchi
* Bino
* Vaqt

---

# 📌 9. Ish vaqti sozlash UI

## 9.1 O’qituvchilar

* Dars jadvali asosida (auto)

## 9.2 Xodimlar

* Manual schedule:

  * Kunlar
  * Soatlar

## 9.3 Qoravullar

* Cycle scheduler (4 kunlik)
* Toggle:

  * Sutkalik rejim

---

# 📌 10. Binolar va FaceID

## 10.1 Binolar

* Nomi
* Lokatsiya
* Qurilmalar soni

## 10.2 FaceID qurilmalar

* Nomi
* IP address
* Holati:

  * Online / Offline
* Oxirgi sync vaqti

---

# 📌 11. Hisobotlar

## 11.1 Filterlar

* Sana oralig‘i
* Role
* Bino

## 11.2 Hisobot turlari

* Davomat report
* Kechikishlar
* Ishlangan soatlar
* Bino bo‘yicha kirishlar

## 11.3 Export

* Excel
* PDF

---

# 📌 12. Bayram kunlari UI

* Sana tanlash
* Nomi
* Global disable toggle

---

# 📌 13. UX talablar

## 13.1 Ranglar

* Yashil — normal
* Qizil — muammo
* Sariq — ogohlantirish

## 13.2 Status ikonlar

* 🟢 online
* 🔴 offline
* ⏰ kechikkan

## 13.3 Loading states

* Skeleton UI ishlatish

---

# 📌 14. Real-time talablar

* WebSocket orqali:

  * Live kirishlar
  * Dashboard yangilanishi
  * Device status

---

# 📌 15. Performance talablar

* Table pagination
* Lazy loading
* Debounce search

---

# 📌 16. Xavfsizlik (UI darajasida)

* Role-based access:

  * Admin
  * Operator
* Sahifalarga ruxsat

---

# 📌 17. Qo‘shimcha (MUHIM)

### UI’da albatta bo‘lishi kerak:

* Global search (F.I.O bo‘yicha)
* Notification system
* Dark mode (ixtiyoriy)

---

# 🔥 Yakuniy fikr

Bu UI oddiy CRM emas — bu:

* Monitoring tizim
* HR tizim
* Analytics dashboard
