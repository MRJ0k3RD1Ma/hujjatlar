# RFC-008: Admin panel — Sozlamalar, Statistika, Blog, Aksiyalar

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 008 |
| **Modul** | Admin: sozlamalar, statistika, blog, aksiyalar, activity log |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Bu RFC admin panelning qolgan modullari — sayt sozlamalari, statistika dashboard, blog/maqolalar tizimi, chegirma/aksiyalar boshqaruvi va admin harakatlar logini qamrab oladi. Mahsulotlar, buyurtmalar, foydalanuvchilar va sharhlar boshqaruvi oldingi RFC larda tavsiflangan.

---

## 2. Statistika Dashboard

### 2.1 Umumiy statistika

**`GET /api/admin/stats/overview`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `period` | string | `today` | `today`, `week`, `month`, `year` |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "period": "today",
    "orders": {
      "count": 12,
      "total_revenue": 45000000,
      "average_order": 3750000,
      "comparison": {
        "count_change": 20,
        "revenue_change": 15.5
      }
    },
    "users": {
      "new_count": 5,
      "total_count": 342
    },
    "products": {
      "total_active": 485,
      "low_stock_count": 8,
      "out_of_stock_count": 3
    },
    "reviews": {
      "pending_count": 4
    },
    "recent_orders": [
      {
        "id": 1001,
        "order_number": "ORD-20260206-1001",
        "status": "paid",
        "total": 11435000,
        "user_phone": "+998901234567",
        "created_at": "2026-02-06T14:30:00Z"
      }
    ]
  }
}
```

**Biznes qoidalar:**
- `comparison` — oldingi davr bilan solishtirish (foizda). `today` → kecha, `week` → o'tgan hafta, va hokazo
- `recent_orders` — oxirgi 5 ta buyurtma
- `low_stock_count` — `stock_quantity < 5` bo'lgan mahsulotlar

---

### 2.2 Sotuv grafigi

**`GET /api/admin/stats/sales`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `period` | string | `week` | `week`, `month`, `year` |
| `type` | string | `revenue` | `revenue`, `orders` |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "type": "revenue",
    "chart_data": [
      { "date": "2026-02-01", "value": 15000000, "label": "Dush" },
      { "date": "2026-02-02", "value": 22000000, "label": "Sesh" },
      { "date": "2026-02-03", "value": 18000000, "label": "Chor" },
      { "date": "2026-02-04", "value": 30000000, "label": "Pay" },
      { "date": "2026-02-05", "value": 25000000, "label": "Jum" },
      { "date": "2026-02-06", "value": 12000000, "label": "Shan" }
    ],
    "total": 122000000
  }
}
```

---

### 2.3 Top mahsulotlar

**`GET /api/admin/stats/top-products`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `period` | string | `month` | `week`, `month`, `year` |
| `limit` | number | 10 | Nechta (max 50) |

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 101,
      "product_name": "AMD Ryzen 7 7800X3D",
      "product_image": "https://api.site.uz/uploads/products/101/main.webp",
      "sold_count": 25,
      "revenue": 120000000
    },
    {
      "product_id": 205,
      "product_name": "Corsair Vengeance 32GB DDR5",
      "product_image": "https://api.site.uz/uploads/products/205/main.webp",
      "sold_count": 18,
      "revenue": 32400000
    }
  ]
}
```

---

## 3. Blog / Maqolalar

### 3.1 Public API

**`GET /api/blog`** — Maqolalar ro'yxati

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 10 | Har sahifada |
| `category` | string | — | Kategoriya filter |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": 1,
        "title": "2026-yilda eng yaxshi protsessorlar",
        "slug": "2026-yilda-eng-yaxshi-protsessorlar",
        "cover_image": "https://api.site.uz/uploads/blog/1/cover.webp",
        "category": "Qo'llanma",
        "author": {
          "first_name": "Admin",
          "avatar_url": null
        },
        "excerpt": "Protsessor tanlashda nimalarni hisobga olish kerak...",
        "published_at": "2026-02-05T10:00:00Z"
      }
    ],
    "pagination": { "...": "..." }
  }
}
```

**`GET /api/blog/:slug`** — Maqola batafsil

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "2026-yilda eng yaxshi protsessorlar",
    "slug": "2026-yilda-eng-yaxshi-protsessorlar",
    "content": "<h2>Kirish</h2><p>Protsessor tanlash...</p>",
    "cover_image": "https://api.site.uz/uploads/blog/1/cover.webp",
    "category": "Qo'llanma",
    "tags": ["protsessor", "amd", "intel", "2026"],
    "author": {
      "first_name": "Admin",
      "avatar_url": null
    },
    "seo": {
      "title": "Eng yaxshi protsessorlar 2026 | TechStore Blog",
      "description": "2026-yilda qaysi protsessor sotib olish kerak..."
    },
    "published_at": "2026-02-05T10:00:00Z",
    "updated_at": "2026-02-05T10:00:00Z"
  }
}
```

---

### 3.2 Admin Blog CRUD

**`GET /api/admin/blog`** — Barcha maqolalar (draft + published)

**`POST /api/admin/blog`** — Yangi maqola

**Request:**
```json
{
  "title_uz": "2026-yilda eng yaxshi protsessorlar",
  "title_ru": "Лучшие процессоры 2026 года",
  "slug": "2026-yilda-eng-yaxshi-protsessorlar",
  "content_uz": "<h2>Kirish</h2><p>...</p>",
  "content_ru": "<h2>Введение</h2><p>...</p>",
  "cover_image": "(file, multipart)",
  "category": "Qo'llanma",
  "tags": ["protsessor", "amd", "intel"],
  "status": "draft",
  "seo_title": "Eng yaxshi protsessorlar 2026",
  "seo_description": "2026-yilda qaysi protsessor sotib olish kerak..."
}
```

**`PATCH /api/admin/blog/:id`** — Tahrirlash

**`DELETE /api/admin/blog/:id`** — O'chirish

**Biznes qoidalar:**
- `status: draft` — faqat admin/moderator ko'radi
- `status: published` — `published_at` avtomatik belgilanadi
- `content` — HTML rich text (TipTap / Quill editor)
- `excerpt` — backend `content` dan avtomatik generatsiya qiladi (birinchi 200 belgi, HTML teglardan tozalangan)

---

## 4. Chegirma / Aksiyalar

### 4.1 Admin Aksiyalar CRUD

**`GET /api/admin/promotions`** — Ro'yxat

**Response (200):**
```json
{
  "success": true,
  "data": {
    "promotions": [
      {
        "id": 1,
        "name_uz": "Qish chegirmasi",
        "name_ru": "Зимняя скидка",
        "type": "percentage",
        "value": 10,
        "apply_to": "category",
        "target_id": 2,
        "target_name": "Protsessorlar",
        "banner_image": "https://api.site.uz/uploads/promotions/1.webp",
        "starts_at": "2026-02-01T00:00:00Z",
        "ends_at": "2026-02-28T23:59:59Z",
        "is_active": true,
        "affected_products": 45,
        "created_at": "2026-01-30T10:00:00Z"
      }
    ],
    "pagination": { "...": "..." }
  }
}
```

**`POST /api/admin/promotions`** — Yangi aksiya

**Request:**
```json
{
  "name_uz": "Qish chegirmasi",
  "name_ru": "Зимняя скидка",
  "type": "percentage",
  "value": 10,
  "apply_to": "category",
  "target_id": 2,
  "banner_image": "(file, multipart)",
  "starts_at": "2026-02-01T00:00:00Z",
  "ends_at": "2026-02-28T23:59:59Z",
  "is_active": true
}
```

**`PATCH /api/admin/promotions/:id`** — Tahrirlash

**`DELETE /api/admin/promotions/:id`** — O'chirish

**Biznes qoidalar:**
- `type: percentage` — foizda chegirma (masalan: 10%)
- `type: fixed` — aniq summada (masalan: 500,000 so'm)
- `apply_to: product` — bitta mahsulotga (`target_id` = product ID)
- `apply_to: category` — butun kategoriyaga (`target_id` = category ID)
- `apply_to: all` — barcha mahsulotlarga (`target_id` = null)
- Aksiya faollashganda tegishli mahsulotlarning `discount_price` va `discount_expires_at` yangilanadi
- Aksiya tugaganda `discount_price` null ga qaytadi
- Bir vaqtda bir nechta aksiya bo'lishi mumkin — eng katta chegirma qo'llanadi

---

## 5. Sayt sozlamalari

### 5.1 Sozlamalarni olish

**`GET /api/admin/settings`**

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "site_name": "TechStore",
    "site_logo": "https://api.site.uz/uploads/settings/logo.webp",
    "site_favicon": "https://api.site.uz/uploads/settings/favicon.ico",
    "phone": "+998901234567",
    "email": "info@techstore.uz",
    "address": "Toshkent, Yunusobod tumani, Amir Temur ko'chasi 15",
    "working_hours": "09:00 - 18:00",
    "social": {
      "telegram": "https://t.me/techstore",
      "instagram": "https://instagram.com/techstore",
      "facebook": null
    },
    "seo": {
      "default_title": "TechStore — Kompyuter ehtiyot qismlari onlayn do'koni",
      "default_description": "Protsessorlar, videokartalar va boshqa kompyuter qismlarini onlayn xarid qiling"
    },
    "delivery": {
      "sender_city_id": 1,
      "sender_name": "TechStore",
      "sender_phone": "+998901234567",
      "sender_address": "Toshkent, Yunusobod, Amir Temur 15",
      "pickup_enabled": true,
      "pickup_address": "Toshkent, Yunusobod tumani, Amir Temur ko'chasi 15",
      "pickup_working_hours": "09:00 - 18:00"
    },
    "payment": {
      "click_enabled": true,
      "payme_enabled": true
    },
    "banners": [
      {
        "id": 1,
        "image": "https://api.site.uz/uploads/banners/1.webp",
        "link": "/category/protsessorlar",
        "sort_order": 0,
        "is_active": true
      }
    ]
  }
}
```

---

### 5.2 Sozlamalarni yangilash

**`PATCH /api/admin/settings`**

**Request (partial):**
```json
{
  "site_name": "TechStore UZ",
  "phone": "+998901234567",
  "social": {
    "telegram": "https://t.me/techstore_uz"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Sozlamalar yangilandi"
}
```

---

### 5.3 Banner boshqaruvi

**`POST /api/admin/settings/banners`** — Yangi banner

**Request (multipart):**
```
image: (file) banner.jpg
link: /category/protsessorlar
sort_order: 0
is_active: true
```

**`PATCH /api/admin/settings/banners/:id`** — Tahrirlash

**`DELETE /api/admin/settings/banners/:id`** — O'chirish

---

## 6. Activity Log

### 6.1 Harakatlar logi

**`GET /api/admin/activity-logs`**

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page`, `per_page` | number | Pagination |
| `user_id` | number | Admin/moderator bo'yicha |
| `action` | string | `create`, `update`, `delete` |
| `entity_type` | string | `product`, `order`, `user`, `blog`, ... |
| `date_from`, `date_to` | string | Sana oralig'i |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": 100,
        "user": {
          "id": 1,
          "first_name": "Admin",
          "role": "admin"
        },
        "action": "update",
        "entity_type": "product",
        "entity_id": 101,
        "entity_name": "AMD Ryzen 7 7800X3D",
        "changes": {
          "price": { "from": 5200000, "to": 4800000 },
          "stock_quantity": { "from": 20, "to": 15 }
        },
        "created_at": "2026-02-06T15:30:00Z"
      }
    ],
    "pagination": { "...": "..." }
  }
}
```

**Biznes qoidalar:**
- Barcha admin/moderator harakatlari loglanadi
- `changes` — faqat `update` da, qaysi maydonlar o'zgarganini ko'rsatadi
- Log 90 kun saqlanadi, keyin avtomatik o'chiriladi
- Faqat Admin ko'ra oladi

---

## 7. Public sahifalar uchun endpointlar

### 7.1 Bosh sahifa ma'lumotlari

**`GET /api/home`**

Frontend bosh sahifani render qilish uchun kerakli barcha ma'lumotlarni bitta so'rovda olish.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "banners": [
      {
        "id": 1,
        "image": "https://api.site.uz/uploads/banners/1.webp",
        "link": "/category/protsessorlar"
      }
    ],
    "categories": [
      {
        "id": 1,
        "name": "Kompyuter komplektlovchi",
        "slug": "kompyuter-komplektlovchi",
        "icon": "cpu",
        "image": "https://api.site.uz/uploads/categories/cpu.webp",
        "product_count": 156
      }
    ],
    "featured_products": [
      {
        "id": 101,
        "name": "AMD Ryzen 7 7800X3D",
        "slug": "amd-ryzen-7-7800x3d",
        "price": 5200000,
        "discount_price": 4800000,
        "image": "...",
        "brand": { "slug": "amd", "name": "AMD" },
        "rating": 4.8,
        "in_stock": true
      }
    ],
    "new_products": ["... (oxirgi 8 ta mahsulot)"],
    "on_sale_products": ["... (chegirmali mahsulotlar, max 8 ta)"],
    "recent_posts": [
      {
        "id": 1,
        "title": "2026-yilda eng yaxshi protsessorlar",
        "slug": "2026-yilda-eng-yaxshi-protsessorlar",
        "cover_image": "...",
        "excerpt": "...",
        "published_at": "2026-02-05T10:00:00Z"
      }
    ]
  }
}
```

### 7.2 Sayt ma'lumotlari (header/footer uchun)

**`GET /api/site-info`**

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "site_name": "TechStore",
    "site_logo": "https://api.site.uz/uploads/settings/logo.webp",
    "phone": "+998901234567",
    "email": "info@techstore.uz",
    "address": "Toshkent, Yunusobod tumani, Amir Temur ko'chasi 15",
    "working_hours": "09:00 - 18:00",
    "social": {
      "telegram": "https://t.me/techstore",
      "instagram": "https://instagram.com/techstore"
    },
    "categories": [
      {
        "id": 1,
        "name": "Kompyuter komplektlovchi",
        "slug": "kompyuter-komplektlovchi",
        "children": [
          { "id": 2, "name": "Protsessorlar", "slug": "protsessorlar" }
        ]
      }
    ]
  }
}
```

**Biznes qoidalar:**
- Bu endpoint auth talab qilmaydi
- Frontend layout (header, footer, mega menu) uchun ishlatiladi
- Cache qilinishi kerak (ISR yoki Redis, 5 daqiqa)

---

## 8. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_PROMOTION_TYPE` | Aksiya turi noto'g'ri | percentage/fixed dan boshqa |
| 400 | `INVALID_DATE_RANGE` | Sana oralig'i noto'g'ri | starts_at > ends_at |
| 400 | `INVALID_SETTINGS_KEY` | Noma'lum sozlama kaliti | Mavjud bo'lmagan kalit |
| 404 | `BLOG_POST_NOT_FOUND` | Maqola topilmadi | Noto'g'ri slug/id |
| 404 | `PROMOTION_NOT_FOUND` | Aksiya topilmadi | Noto'g'ri id |
| 409 | `BLOG_SLUG_EXISTS` | Blog slug allaqachon mavjud | Dublikat |
| 413 | `BANNER_TOO_LARGE` | Banner hajmi katta (max 5MB) | Yuklash |

---

## 9. TypeScript interfeyslar

```typescript
// ============================================
// Stats types
// ============================================

type StatsPeriod = "today" | "week" | "month" | "year";

interface StatsOverview {
  period: StatsPeriod;
  orders: {
    count: number;
    total_revenue: number;
    average_order: number;
    comparison: {
      count_change: number;      // foizda
      revenue_change: number;    // foizda
    };
  };
  users: {
    new_count: number;
    total_count: number;
  };
  products: {
    total_active: number;
    low_stock_count: number;
    out_of_stock_count: number;
  };
  reviews: {
    pending_count: number;
  };
  recent_orders: {
    id: number;
    order_number: string;
    status: string;
    total: number;
    user_phone: string;
    created_at: string;
  }[];
}

interface SalesChartItem {
  date: string;
  value: number;
  label: string;
}

interface TopProduct {
  product_id: number;
  product_name: string;
  product_image: string | null;
  sold_count: number;
  revenue: number;
}

// ============================================
// Blog types
// ============================================

interface BlogPostCard {
  id: number;
  title: string;
  slug: string;
  cover_image: string | null;
  category: string | null;
  author: {
    first_name: string | null;
    avatar_url: string | null;
  };
  excerpt: string;
  published_at: string;
}

interface BlogPostDetail {
  id: number;
  title: string;
  slug: string;
  content: string; // HTML
  cover_image: string | null;
  category: string | null;
  tags: string[];
  author: {
    first_name: string | null;
    avatar_url: string | null;
  };
  seo: {
    title: string | null;
    description: string | null;
  };
  published_at: string;
  updated_at: string;
}

interface AdminBlogPost {
  id: number;
  title_uz: string;
  title_ru: string;
  slug: string;
  content_uz: string;
  content_ru: string;
  cover_image: string | null;
  category: string | null;
  tags: string[];
  status: "draft" | "published";
  seo_title: string | null;
  seo_description: string | null;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}

interface CreateBlogPostRequest {
  title_uz: string;
  title_ru: string;
  slug: string;
  content_uz: string;
  content_ru: string;
  category?: string;
  tags?: string[];
  status: "draft" | "published";
  seo_title?: string;
  seo_description?: string;
}

// ============================================
// Promotion types
// ============================================

type PromotionType = "percentage" | "fixed";
type PromotionApplyTo = "product" | "category" | "all";

interface Promotion {
  id: number;
  name_uz: string;
  name_ru: string;
  type: PromotionType;
  value: number;
  apply_to: PromotionApplyTo;
  target_id: number | null;
  target_name: string | null;
  banner_image: string | null;
  starts_at: string;
  ends_at: string;
  is_active: boolean;
  affected_products: number;
  created_at: string;
}

interface CreatePromotionRequest {
  name_uz: string;
  name_ru: string;
  type: PromotionType;
  value: number;
  apply_to: PromotionApplyTo;
  target_id?: number;
  starts_at: string;
  ends_at: string;
  is_active: boolean;
}

// ============================================
// Settings types
// ============================================

interface SiteSettings {
  site_name: string;
  site_logo: string | null;
  site_favicon: string | null;
  phone: string;
  email: string;
  address: string;
  working_hours: string;
  social: {
    telegram: string | null;
    instagram: string | null;
    facebook: string | null;
  };
  seo: {
    default_title: string;
    default_description: string;
  };
  delivery: {
    sender_city_id: number;
    sender_name: string;
    sender_phone: string;
    sender_address: string;
    pickup_enabled: boolean;
    pickup_address: string;
    pickup_working_hours: string;
  };
  payment: {
    click_enabled: boolean;
    payme_enabled: boolean;
  };
  banners: Banner[];
}

interface Banner {
  id: number;
  image: string;
  link: string;
  sort_order: number;
  is_active: boolean;
}

// ============================================
// Activity Log types
// ============================================

interface ActivityLog {
  id: number;
  user: {
    id: number;
    first_name: string | null;
    role: string;
  };
  action: "create" | "update" | "delete";
  entity_type: string;
  entity_id: number;
  entity_name: string;
  changes: Record<string, { from: any; to: any }> | null;
  created_at: string;
}

// ============================================
// Home page types
// ============================================

interface HomePage {
  banners: {
    id: number;
    image: string;
    link: string;
  }[];
  categories: {
    id: number;
    name: string;
    slug: string;
    icon: string | null;
    image: string | null;
    product_count: number;
  }[];
  featured_products: ProductCard[];
  new_products: ProductCard[];
  on_sale_products: ProductCard[];
  recent_posts: BlogPostCard[];
}

interface SiteInfo {
  site_name: string;
  site_logo: string | null;
  phone: string;
  email: string;
  address: string;
  working_hours: string;
  social: {
    telegram: string | null;
    instagram: string | null;
  };
  categories: {
    id: number;
    name: string;
    slug: string;
    children: {
      id: number;
      name: string;
      slug: string;
    }[];
  }[];
}
```

---

## 10. Frontend uchun eslatmalar

1. **Dashboard:** Recharts kutubxonasi bilan sotuv grafiklari. Card komponentlarda KPI raqamlar (bugungi sotuv, yangi buyurtmalar, kam mahsulotlar). Auto-refresh har 5 daqiqada.

2. **Blog editor:** TipTap yoki Quill rich text editor. Rasm yuklash editor ichida. Draft/Published toggle. SEO preview (Google snippet ko'rinishida).

3. **Aksiyalar:** Forma — aksiya turi (foiz/summa), qo'llanish (mahsulot/kategoriya/barchasi), muddat (date range picker), banner rasm. Preview — qancha mahsulotga ta'sir qilishini ko'rsatish.

4. **Sozlamalar:** Tab layout — Umumiy, Yetkazib berish, To'lov, SEO, Ijtimoiy tarmoqlar, Bannerlar. Har bir tab alohida saqlash.

5. **Activity log:** Jadval ko'rinishida, filtrlash imkoniyati. `changes` JSON ni odam o'qiy oladigan formatda ko'rsatish (masalan: "Narx: 5,200,000 → 4,800,000").

6. **Bosh sahifa:** `GET /api/home` bitta so'rovda barcha ma'lumotlar. ISR (5 daqiqa) bilan cache. Slider (banner), kategoriya grid, mahsulot carousellari.

7. **Site info:** Layout (header/footer) da ishlatiladi. `GET /api/site-info` Next.js layout.tsx da chaqiriladi va barcha sahifalarga uzatiladi.
