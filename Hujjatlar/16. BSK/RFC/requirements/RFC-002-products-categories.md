# RFC-002: Mahsulotlar va kategoriyalar tizimi

| Parametr | Qiymat |
|----------|--------|
| **RFC raqami** | 002 |
| **Modul** | Mahsulotlar, kategoriyalar, brendlar, qidiruv |
| **Holat** | Draft |
| **Sana** | 2026-02-06 |
| **Muallif** | Frontend team |
| **Backend** | PHP team |

---

> **Asos:** Umumiy response/error formatlar, pagination, HTTP status kodlar va TypeScript base tiplari **RFC-000** da belgilangan.

## 1. Umumiy ko'rinish

Mahsulot tizimi platformaning asosi. Kategoriyalar ichma-ich (parent-child) tuzilmada, har bir kategoriyaga texnik spetsifikatsiya shabloni biriktirilgan. Mahsulotlar JSONB formatda dinamik spetsifikatsiyalarga ega. Tizim filtrlash, saralash, qidiruv va pagination ni qo'llab-quvvatlaydi.

---

## 2. Public API Endpointlar

### 2.1 Kategoriyalar daraxti

**`GET /api/categories`**

Barcha faol kategoriyalarni daraxt (tree) ko'rinishida qaytaradi.

**Headers:**
```
Accept-Language: uz | ru
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Kompyuter komplektlovchi",
      "slug": "kompyuter-komplektlovchi",
      "icon": "cpu",
      "image": "https://api.site.uz/uploads/categories/cpu.webp",
      "children": [
        {
          "id": 2,
          "name": "Protsessorlar",
          "slug": "protsessorlar",
          "icon": "processor",
          "image": null,
          "children": [],
          "product_count": 45
        },
        {
          "id": 3,
          "name": "Videokartalar",
          "slug": "videokartalar",
          "icon": "gpu",
          "image": null,
          "children": [],
          "product_count": 32
        }
      ],
      "product_count": 156
    },
    {
      "id": 10,
      "name": "Periferiya",
      "slug": "periferiya",
      "icon": "keyboard",
      "image": "https://api.site.uz/uploads/categories/periphery.webp",
      "children": [
        {
          "id": 11,
          "name": "Klaviaturalar",
          "slug": "klaviaturalar",
          "icon": null,
          "image": null,
          "children": [],
          "product_count": 28
        }
      ],
      "product_count": 89
    }
  ]
}
```

**Biznes qoidalar:**
- Faqat `is_active: true` kategoriyalar qaytariladi
- `name` — `Accept-Language` header ga qarab `name_uz` yoki `name_ru`
- `product_count` — shu kategoriya va barcha sub-kategoriyalaridagi faol mahsulotlar soni
- Maksimal 2 daraja chuqurlik (parent → child)

---

### 2.2 Kategoriya bo'yicha mahsulotlar

**`GET /api/categories/:slug`**

Kategoriya ma'lumotlari, filtrlash uchun mavjud spec qiymatlari va mahsulotlar ro'yxati.

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa raqami |
| `per_page` | number | 20 | Har sahifada (max 50) |
| `sort` | string | `newest` | Saralash: `newest`, `price_asc`, `price_desc`, `popular`, `rating` |
| `min_price` | number | — | Minimal narx |
| `max_price` | number | — | Maksimal narx |
| `brand` | string | — | Brend sluglari (vergul bilan: `amd,intel`) |
| `in_stock` | boolean | — | Faqat mavjud mahsulotlar |
| `spec.*` | string | — | Dinamik spec filter (masalan: `spec.socket=AM5,LGA1700`) |

**Misol so'rov:**
```
GET /api/categories/protsessorlar?page=1&per_page=20&sort=price_asc&brand=amd&spec.socket=AM5&min_price=2000000
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "category": {
      "id": 2,
      "name": "Protsessorlar",
      "slug": "protsessorlar",
      "icon": "processor",
      "parent": {
        "id": 1,
        "name": "Kompyuter komplektlovchi",
        "slug": "kompyuter-komplektlovchi"
      },
      "seo_title": "Protsessorlar narxlari Toshkent | TechStore",
      "seo_description": "AMD va Intel protsessorlar eng arzon narxlarda..."
    },
    "filters": {
      "brands": [
        { "slug": "amd", "name": "AMD", "count": 25 },
        { "slug": "intel", "name": "Intel", "count": 20 }
      ],
      "price_range": {
        "min": 800000,
        "max": 15000000
      },
      "specs": [
        {
          "key": "socket",
          "label": "Socket",
          "type": "select",
          "options": [
            { "value": "AM5", "count": 15 },
            { "value": "LGA1700", "count": 12 },
            { "value": "LGA1200", "count": 8 }
          ]
        },
        {
          "key": "cores",
          "label": "Yadrolar soni",
          "type": "number",
          "range": { "min": 4, "max": 24 }
        }
      ]
    },
    "products": [
      {
        "id": 101,
        "name": "AMD Ryzen 7 7800X3D",
        "slug": "amd-ryzen-7-7800x3d",
        "price": 5200000,
        "discount_price": 4800000,
        "discount_expires_at": "2026-03-01T00:00:00Z",
        "image": "https://api.site.uz/uploads/products/101/main.webp",
        "brand": {
          "slug": "amd",
          "name": "AMD"
        },
        "rating": 4.8,
        "review_count": 12,
        "in_stock": true,
        "is_featured": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 45,
      "total_pages": 3,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

**Biznes qoidalar:**
- Faqat `is_active: true` mahsulotlar
- Agar kategoriya parent bo'lsa — barcha child kategoriyalarning mahsulotlari ham chiqadi
- `filters` — shu kategoriyaning haqiqiy qiymatlari asosida (faqat mavjud variantlar ko'rsatiladi)
- `count` — har bir filter qiymati nechta mahsulotga mos kelishini ko'rsatadi
- `discount_price` faqat `discount_expires_at` muddati o'tmagan bo'lsa ko'rsatiladi
- `name`, `label` — `Accept-Language` ga qarab tilni tanlaydi

---

### 2.3 Mahsulot batafsil

**`GET /api/products/:slug`**

Mahsulotning to'liq ma'lumotlari, rasmlari, spetsifikatsiyalari va qo'llanmalari.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 101,
    "name": "AMD Ryzen 7 7800X3D",
    "slug": "amd-ryzen-7-7800x3d",
    "sku": "CPU-AMD-7800X3D",
    "description": "<p>AMD Ryzen 7 7800X3D — o'yinlar uchun eng yaxshi protsessor...</p>",
    "price": 5200000,
    "discount_price": 4800000,
    "discount_expires_at": "2026-03-01T00:00:00Z",
    "stock_quantity": 15,
    "in_stock": true,
    "is_featured": true,
    "category": {
      "id": 2,
      "name": "Protsessorlar",
      "slug": "protsessorlar",
      "parent": {
        "id": 1,
        "name": "Kompyuter komplektlovchi",
        "slug": "kompyuter-komplektlovchi"
      }
    },
    "brand": {
      "id": 1,
      "name": "AMD",
      "slug": "amd",
      "logo_url": "https://api.site.uz/uploads/brands/amd.webp"
    },
    "images": [
      {
        "id": 1,
        "url": "https://api.site.uz/uploads/products/101/main.webp",
        "alt_text": "AMD Ryzen 7 7800X3D",
        "is_primary": true
      },
      {
        "id": 2,
        "url": "https://api.site.uz/uploads/products/101/box.webp",
        "alt_text": "AMD Ryzen 7 7800X3D qutisi",
        "is_primary": false
      }
    ],
    "specifications": [
      { "key": "socket", "label": "Socket", "value": "AM5" },
      { "key": "cores", "label": "Yadrolar soni", "value": "8", "unit": "ta" },
      { "key": "threads", "label": "Iplar soni", "value": "16", "unit": "ta" },
      { "key": "base_clock", "label": "Bazaviy chastota", "value": "4.2", "unit": "GHz" },
      { "key": "boost_clock", "label": "Boost chastota", "value": "5.0", "unit": "GHz" },
      { "key": "tdp", "label": "TDP", "value": "120", "unit": "W" },
      { "key": "cache", "label": "L3 kesh", "value": "96", "unit": "MB" }
    ],
    "guides": [
      {
        "id": 1,
        "type": "video",
        "title": "AMD Ryzen 7 7800X3D o'rnatish",
        "video_url": "https://youtube.com/watch?v=...",
        "content": null
      },
      {
        "id": 2,
        "type": "article",
        "title": "AM5 protsessor tanlash bo'yicha qo'llanma",
        "video_url": null,
        "content": "<p>Protsessor tanlashda...</p>"
      }
    ],
    "rating": {
      "average": 4.8,
      "count": 12,
      "distribution": {
        "5": 8,
        "4": 3,
        "3": 1,
        "2": 0,
        "1": 0
      }
    },
    "related_products": [
      {
        "id": 102,
        "name": "AMD Ryzen 9 7950X3D",
        "slug": "amd-ryzen-9-7950x3d",
        "price": 9500000,
        "discount_price": null,
        "image": "https://api.site.uz/uploads/products/102/main.webp",
        "rating": 4.9,
        "in_stock": true
      }
    ],
    "seo": {
      "title": "AMD Ryzen 7 7800X3D sotib olish | TechStore",
      "description": "AMD Ryzen 7 7800X3D protsessor narxi 4 800 000 so'm...",
      "canonical": "https://site.uz/uz/product/amd-ryzen-7-7800x3d"
    },
    "breadcrumbs": [
      { "name": "Bosh sahifa", "slug": "/" },
      { "name": "Kompyuter komplektlovchi", "slug": "/category/kompyuter-komplektlovchi" },
      { "name": "Protsessorlar", "slug": "/category/protsessorlar" },
      { "name": "AMD Ryzen 7 7800X3D", "slug": null }
    ],
    "created_at": "2026-01-10T08:00:00Z",
    "updated_at": "2026-02-05T12:30:00Z"
  }
}
```

**Biznes qoidalar:**
- `description` — HTML rich text (backend sanitize qiladi)
- `specifications` — kategoriya `spec_template` asosida formatlanadi
- `related_products` — o'sha kategoriyadagi boshqa mahsulotlar (4-8 ta)
- `in_stock` — `stock_quantity > 0`
- `breadcrumbs` — SEO va navigatsiya uchun to'liq yo'l
- `discount_price` — faqat `discount_expires_at` hali kelmagan bo'lsa

---

### 2.4 Mahsulot sharhlari

**`GET /api/products/:id/reviews`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 10 | Har sahifada |
| `sort` | string | `newest` | `newest`, `oldest`, `rating_high`, `rating_low` |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "reviews": [
      {
        "id": 1,
        "user": {
          "id": 5,
          "first_name": "Anvar",
          "last_name": "T.",
          "avatar_url": null
        },
        "rating": 5,
        "comment": "Juda yaxshi protsessor, o'yinlarda zo'r ishlaydi!",
        "created_at": "2026-02-01T15:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total_items": 12,
      "total_pages": 2,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

**Biznes qoidalar:**
- Faqat `is_approved: true` sharhlar ko'rsatiladi
- Foydalanuvchi familiyasi qisqartiriladi (`last_name` faqat birinchi harf + nuqta)

---

### 2.5 Mahsulotlar ro'yxati (umumiy)

**`GET /api/products`**

Barcha mahsulotlar (kategoriyadan qat'iy nazar). Asosan bosh sahifa, aksiya sahifalari uchun.

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `page` | number | 1 | Sahifa |
| `per_page` | number | 20 | Har sahifada (max 50) |
| `sort` | string | `newest` | `newest`, `price_asc`, `price_desc`, `popular`, `rating` |
| `category` | string | — | Kategoriya slug |
| `brand` | string | — | Brend sluglari (vergul bilan) |
| `min_price` | number | — | Min narx |
| `max_price` | number | — | Max narx |
| `in_stock` | boolean | — | Faqat mavjud |
| `featured` | boolean | — | Faqat tavsiya etilgan |
| `on_sale` | boolean | — | Faqat chegirmali |

**Response:** Kategoriya endpointidagi `products` va `pagination` bilan bir xil format.

---

### 2.6 Qidiruv

**`GET /api/search`**

**Query parametrlar:**

| Parametr | Turi | Default | Tavsif |
|----------|------|---------|--------|
| `q` | string | — | Qidiruv so'zi (min 2 belgi) |
| `page` | number | 1 | Sahifa |
| `per_page` | number | 20 | Har sahifada |

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "query": "ryzen 7",
    "products": [
      {
        "id": 101,
        "name": "AMD Ryzen 7 7800X3D",
        "slug": "amd-ryzen-7-7800x3d",
        "price": 5200000,
        "discount_price": 4800000,
        "image": "https://api.site.uz/uploads/products/101/main.webp",
        "brand": { "slug": "amd", "name": "AMD" },
        "category": { "slug": "protsessorlar", "name": "Protsessorlar" },
        "rating": 4.8,
        "in_stock": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 3,
      "total_pages": 1,
      "has_next": false,
      "has_prev": false
    }
  }
}
```

**Biznes qoidalar:**
- Qidiruv `name_uz`, `name_ru`, `sku`, `description_uz`, `description_ru` bo'yicha
- Minimal 2 belgi kerak
- Natijalar relevantlik bo'yicha saralangan (PostgreSQL full-text search yoki ILIKE)
- Faqat `is_active: true` mahsulotlar

---

### 2.7 Brendlar ro'yxati

**`GET /api/brands`**

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "AMD",
      "slug": "amd",
      "logo_url": "https://api.site.uz/uploads/brands/amd.webp",
      "product_count": 45
    },
    {
      "id": 2,
      "name": "Intel",
      "slug": "intel",
      "logo_url": "https://api.site.uz/uploads/brands/intel.webp",
      "product_count": 38
    }
  ]
}
```

---

## 3. Admin API Endpointlar

### 3.1 Kategoriyalar CRUD (faqat Admin)

**`GET /api/admin/categories`** — Barcha kategoriyalar (daraxt, faol/nofaol)

**`POST /api/admin/categories`** — Yangi kategoriya yaratish

**Request:**
```json
{
  "parent_id": null,
  "name_uz": "Protsessorlar",
  "name_ru": "Процессоры",
  "slug": "protsessorlar",
  "icon": "processor",
  "image": null,
  "sort_order": 1,
  "is_active": true,
  "spec_template": {
    "fields": [
      {
        "key": "socket",
        "label_uz": "Socket",
        "label_ru": "Сокет",
        "type": "select",
        "options": ["AM5", "LGA1700", "LGA1200"]
      },
      {
        "key": "cores",
        "label_uz": "Yadrolar soni",
        "label_ru": "Кол-во ядер",
        "type": "number",
        "unit": "ta"
      },
      {
        "key": "base_clock",
        "label_uz": "Bazaviy chastota",
        "label_ru": "Базовая частота",
        "type": "text",
        "unit": "GHz"
      }
    ]
  }
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Kategoriya yaratildi",
  "data": {
    "id": 2,
    "parent_id": null,
    "name_uz": "Protsessorlar",
    "name_ru": "Процессоры",
    "slug": "protsessorlar",
    "icon": "processor",
    "image": null,
    "sort_order": 1,
    "is_active": true,
    "spec_template": { "fields": ["..."] },
    "created_at": "2026-02-06T10:00:00Z"
  }
}
```

**`PATCH /api/admin/categories/:id`** — Tahrirlash (faqat yuborilgan maydonlar yangilanadi)

**`DELETE /api/admin/categories/:id`** — O'chirish (faqat mahsuloti bo'lmagan kategoriya)

---

### 3.2 Mahsulotlar CRUD (Admin + Moderator)

**`GET /api/admin/products`** — Admin uchun mahsulotlar ro'yxati

**Query parametrlar:**

| Parametr | Turi | Tavsif |
|----------|------|--------|
| `page`, `per_page` | number | Pagination |
| `search` | string | Nom/SKU bo'yicha qidirish |
| `category_id` | number | Kategoriya filter |
| `brand_id` | number | Brend filter |
| `is_active` | boolean | Faollik filter |
| `low_stock` | boolean | Kam qolganlar (stock < 5) |

**`POST /api/admin/products`** — Yangi mahsulot yaratish

**Request (multipart/form-data):**
```json
{
  "category_id": 2,
  "brand_id": 1,
  "name_uz": "AMD Ryzen 7 7800X3D",
  "name_ru": "AMD Ryzen 7 7800X3D",
  "slug": "amd-ryzen-7-7800x3d",
  "description_uz": "<p>O'yinlar uchun eng yaxshi protsessor...</p>",
  "description_ru": "<p>Лучший процессор для игр...</p>",
  "sku": "CPU-AMD-7800X3D",
  "price": 5200000,
  "discount_price": 4800000,
  "discount_expires_at": "2026-03-01T00:00:00Z",
  "stock_quantity": 15,
  "is_active": true,
  "is_featured": false,
  "specifications": {
    "socket": "AM5",
    "cores": 8,
    "threads": 16,
    "base_clock": "4.2",
    "boost_clock": "5.0",
    "tdp": 120,
    "cache": 96
  },
  "seo_title": "AMD Ryzen 7 7800X3D sotib olish",
  "seo_description": "AMD Ryzen 7 7800X3D protsessor eng arzon narxda..."
}
```

**Rasmlar alohida yuboriladi:**

**`POST /api/admin/products/:id/images`** — Rasm yuklash (multipart)

**Request:**
```
Content-Type: multipart/form-data

images[]: (file) main.jpg
images[]: (file) box.jpg
is_primary: 0  (qaysi rasm asosiy — index)
```

**Response (201):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "url": "https://api.site.uz/uploads/products/101/main.webp",
      "is_primary": true,
      "sort_order": 0
    },
    {
      "id": 2,
      "url": "https://api.site.uz/uploads/products/101/box.webp",
      "is_primary": false,
      "sort_order": 1
    }
  ]
}
```

**`DELETE /api/admin/products/:id/images/:imageId`** — Rasmni o'chirish

**`PATCH /api/admin/products/:id`** — Tahrirlash

**`DELETE /api/admin/products/:id`** — O'chirish (soft delete — `is_active: false`)

---

### 3.3 CSV Import/Export

**`POST /api/admin/products/import`** — CSV dan import

**Request (multipart/form-data):**
```
file: products.csv
```

CSV format:
```csv
name_uz,name_ru,sku,category_slug,brand_slug,price,stock_quantity,spec.socket,spec.cores
"AMD Ryzen 5 7600X","AMD Ryzen 5 7600X","CPU-AMD-7600X","protsessorlar","amd",3200000,20,"AM5",6
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "imported": 45,
    "skipped": 3,
    "errors": [
      { "row": 12, "error": "SKU 'CPU-INTEL-XXX' allaqachon mavjud" },
      { "row": 25, "error": "Kategoriya 'noma'lum' topilmadi" }
    ]
  }
}
```

**`GET /api/admin/products/export`** — CSV ga export

Query: `?category_id=2&brand_id=1` (ixtiyoriy filter)

Response: CSV fayl download bo'ladi.

---

### 3.4 Brendlar CRUD (Admin + Moderator)

**`GET /api/admin/brands`** — Ro'yxat
**`POST /api/admin/brands`** — Yaratish
**`PATCH /api/admin/brands/:id`** — Tahrirlash
**`DELETE /api/admin/brands/:id`** — O'chirish

**POST Request:**
```json
{
  "name": "AMD",
  "slug": "amd",
  "logo": "(file, multipart)",
  "is_active": true
}
```

---

## 4. Error kodlari

| HTTP Status | Error Code | Tavsif | Qachon |
|-------------|-----------|--------|--------|
| 400 | `INVALID_SLUG` | Slug formati noto'g'ri | Slug validatsiyasi |
| 400 | `INVALID_SPEC_TEMPLATE` | Spec template formati noto'g'ri | JSONB validatsiya |
| 404 | `CATEGORY_NOT_FOUND` | Kategoriya topilmadi | Noto'g'ri slug/id |
| 404 | `PRODUCT_NOT_FOUND` | Mahsulot topilmadi | Noto'g'ri slug/id |
| 404 | `BRAND_NOT_FOUND` | Brend topilmadi | Noto'g'ri id |
| 409 | `SLUG_EXISTS` | Bu slug allaqachon mavjud | Dublikat slug |
| 409 | `SKU_EXISTS` | Bu SKU allaqachon mavjud | Dublikat SKU |
| 409 | `CATEGORY_HAS_PRODUCTS` | Kategoriyada mahsulotlar bor | O'chirish urinishi |
| 413 | `IMAGE_TOO_LARGE` | Rasm hajmi katta (max 5MB) | Yuklash |
| 415 | `INVALID_IMAGE_TYPE` | Rasm formati noto'g'ri | Faqat jpg/png/webp |
| 422 | `IMPORT_FAILED` | CSV import xatosi | Import paytida |

---

## 5. TypeScript interfeyslar

```typescript
// ============================================
// Category types
// ============================================

interface Category {
  id: number;
  name: string; // tilga qarab name_uz yoki name_ru
  slug: string;
  icon: string | null;
  image: string | null;
  children: Category[];
  product_count: number;
}

interface CategoryDetail {
  id: number;
  name: string;
  slug: string;
  icon: string | null;
  parent: {
    id: number;
    name: string;
    slug: string;
  } | null;
  seo_title: string | null;
  seo_description: string | null;
}

interface SpecTemplateField {
  key: string;
  label_uz: string;
  label_ru: string;
  type: "select" | "number" | "text" | "boolean";
  options?: string[];  // faqat select uchun
  unit?: string;
}

interface SpecTemplate {
  fields: SpecTemplateField[];
}

// Admin uchun
interface AdminCategory {
  id: number;
  parent_id: number | null;
  name_uz: string;
  name_ru: string;
  slug: string;
  icon: string | null;
  image: string | null;
  sort_order: number;
  is_active: boolean;
  spec_template: SpecTemplate | null;
  created_at: string;
  updated_at: string;
  children: AdminCategory[];
}

// ============================================
// Product types
// ============================================

interface ProductCard {
  id: number;
  name: string;
  slug: string;
  price: number;
  discount_price: number | null;
  discount_expires_at: string | null;
  image: string | null;
  brand: {
    slug: string;
    name: string;
  } | null;
  rating: number;
  review_count: number;
  in_stock: boolean;
  is_featured: boolean;
}

interface ProductDetail {
  id: number;
  name: string;
  slug: string;
  sku: string;
  description: string; // HTML
  price: number;
  discount_price: number | null;
  discount_expires_at: string | null;
  stock_quantity: number;
  in_stock: boolean;
  is_featured: boolean;
  category: {
    id: number;
    name: string;
    slug: string;
    parent: {
      id: number;
      name: string;
      slug: string;
    } | null;
  };
  brand: {
    id: number;
    name: string;
    slug: string;
    logo_url: string | null;
  } | null;
  images: ProductImage[];
  specifications: ProductSpec[];
  guides: ProductGuide[];
  rating: ProductRating;
  related_products: ProductCard[];
  seo: {
    title: string | null;
    description: string | null;
    canonical: string;
  };
  breadcrumbs: Breadcrumb[];
  created_at: string;
  updated_at: string;
}

interface ProductImage {
  id: number;
  url: string;
  alt_text: string | null;
  is_primary: boolean;
}

interface ProductSpec {
  key: string;
  label: string;
  value: string;
  unit?: string;
}

interface ProductGuide {
  id: number;
  type: "video" | "article";
  title: string;
  video_url: string | null;
  content: string | null; // HTML
}

interface ProductRating {
  average: number;
  count: number;
  distribution: Record<string, number>; // "1"-"5" => count
}

interface Breadcrumb {
  name: string;
  slug: string | null; // null = joriy sahifa
}

// ============================================
// Filter types
// ============================================

interface CategoryFilters {
  brands: {
    slug: string;
    name: string;
    count: number;
  }[];
  price_range: {
    min: number;
    max: number;
  };
  specs: SpecFilter[];
}

interface SpecFilter {
  key: string;
  label: string;
  type: "select" | "number";
  options?: {
    value: string;
    count: number;
  }[];
  range?: {
    min: number;
    max: number;
  };
}

// ============================================
// Review types
// ============================================

interface Review {
  id: number;
  user: {
    id: number;
    first_name: string;
    last_name: string; // qisqartirilgan "K."
    avatar_url: string | null;
  };
  rating: number;
  comment: string | null;
  created_at: string;
}

// ============================================
// Brand types
// ============================================

interface Brand {
  id: number;
  name: string;
  slug: string;
  logo_url: string | null;
  product_count: number;
}

// Pagination — RFC-000 da aniqlangan

// ============================================
// Admin product types
// ============================================

interface AdminProductCreate {
  category_id: number;
  brand_id: number | null;
  name_uz: string;
  name_ru: string;
  slug: string;
  description_uz: string;
  description_ru: string;
  sku: string;
  price: number;
  discount_price?: number | null;
  discount_expires_at?: string | null;
  stock_quantity: number;
  is_active: boolean;
  is_featured: boolean;
  specifications: Record<string, string | number | boolean>;
  seo_title?: string | null;
  seo_description?: string | null;
}

interface AdminProductUpdate extends Partial<AdminProductCreate> {}

interface CsvImportResult {
  imported: number;
  skipped: number;
  errors: {
    row: number;
    error: string;
  }[];
}
```

---

## 6. Frontend uchun eslatmalar

1. **Kategoriya sahifasi:** URL query parametrlari bilan filtrlar sinxronlashtiriladi (`?brand=amd&spec.socket=AM5`). Foydalanuvchi filtrni o'zgartirsa URL yangilanadi, URL orqali kirsa filtrlar tiklanadi.

2. **Rasm optimizatsiya:** Backend rasmlarni WebP ga konvertatsiya qiladi va bir nechta o'lchamda saqlaydi (thumbnail: 300px, medium: 600px, large: 1200px). Frontend `next/image` orqali responsive yuklaydi.

3. **SEO:** Mahsulot va kategoriya sahifalari SSR. JSON-LD structured data (Product schema) har bir mahsulot sahifasiga qo'yiladi.

4. **Rich text editor:** Admin panelda mahsulot tavsifi uchun TipTap yoki Quill editor. HTML saqlanadi, frontend `dangerouslySetInnerHTML` bilan render qiladi (backend sanitize qiladi).

5. **Spec template:** Admin yangi kategoriya yaratayotganda spec template builder ko'rsatiladi. Mahsulot qo'shayotganda tanlangan kategoriyaning template'i asosida dinamik forma chiqadi.

6. **Infinite scroll vs pagination:** Kategoriya sahifasida pagination (SEO uchun), qidiruv natijalarida esa ixtiyoriy.
