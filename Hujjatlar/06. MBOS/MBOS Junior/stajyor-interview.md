# 🎤 Stajyorlar uchun Interview Savollar va Amaliy Kod Topshiriqlar

Bu hujjat frontend va backend stajyorlarni tanlashda foydalanish uchun **nazariy savollar** va **live coding topshiriqlar**ni o‘z ichiga oladi.

---

## 🔵 Umumiy Savollar (Frontend + Backend)
1. Git bilan qanday ishlagansiz? Branch ochish va PR qilish jarayonini tushuntirib bering.  
2. REST API nima? CRUD operatsiyalarni misol bilan aytib bera olasizmi?  
3. `GET` va `POST` request farqi nimada?  
4. JSON nima va undan qanday foydalanamiz?  
5. HTTP status kodlaridan 200, 201, 400, 404, 500 nimani anglatadi?  
6. Loyihada error chiqqanda qanday qilib debugging qilasiz?  
7. Jamoada ishlaganda task manager (Trello, Jira, ClickUp) bilan ishlaganmisiz?  

### 💻 Umumiy Live Coding
1. Massiv berilgan: `[1,2,3,4,5,6]`. Faqat juft va toq alohida oldin juft keyin toq sonlarni qaytaruvchi funksiya yozing.  
2. String: `"hello world"`. Harflarni teskari tartibda qaytaruvchi funksiya yozing.  
3. Object: `{name: "Ali", age: 20, job: "developer"}` → `Object.keys()` va `Object.values()` ishlatib key va value’larni chiqaring.  

---

## 🟢 Frontend (React/Next.js) Savollar
1. React’da functional component va class component farqini tushuntiring.  
2. Props va state nima, ular orasidagi asosiy farq nima?  
3. `useState` va `useEffect` hooklari qanday ishlaydi? Misol keltiring.  
4. Virtual DOM nima va React uni qanday ishlatadi?  
5. Controlled va uncontrolled form komponentlar farqi nimada?  
6. CSS’da `flexbox` va `grid` o‘rtasidagi asosiy farq nima? Qaysi holatda qaysi birini ishlatish kerak?  
7. Next.js’da `getStaticProps` va `getServerSideProps` farqi nimada?  
8. Responsive dizayn uchun qanday yondashuvlarni ishlatgansiz?  
9. API’dan kelgan datani React komponentida qanday qilib ko‘rsatasiz?  
10. SEO uchun Next.js’da qanday imkoniyatlar mavjud?  

### 💻 Frontend Live Coding
1. **Form Handling**: Input va button bo‘lsin. User text yozadi → button bosilganda pastda ko‘rsatiladi.  
2. **State Update**: Button bosilganda counter +1 bo‘lishi kerak.  
3. **API fetch**: `https://jsonplaceholder.typicode.com/posts` API’dan data olib, ro‘yxat ko‘rinishida chiqaring.  
4. **Conditional Rendering**: Agar list bo‘sh bo‘lsa → `"No data"` yozuvi chiqsin, bo‘lmasa list chiqsin.  
5. **Component Split**: Todo list yozing: `App -> TodoList -> TodoItem` komponentlar bo‘lib ishlasin.  

---

## 🟠 Backend (Node.js/Express/NestJS/Postgres) Savollar
1. Node.js’da event loop nima va qanday ishlaydi?  
2. Express.js’da middleware nima va misol keltira olasizmi?  
3. `async/await` va `Promise.then` o‘rtasidagi farq nima?  
4. REST API’da authentication va authorization nima farq qiladi?  
5. Postgres’da `JOIN` turlari haqida tushuntirib bering (INNER, LEFT, RIGHT).  
6. Database’da `one-to-many` va `many-to-many` relationshipni qanday tushunasiz?  
7. NestJS’da Module, Controller, Service arxitekturasi qanday ishlaydi?  
8. API’ni Postman yoki boshqa vosita bilan test qilganmisiz?  
9. SQL injection nima va undan qanday himoyalanish mumkin?  
10. Scaling masalasida backend’da qaysi muammolar bo‘lishi mumkin va qanday hal qilinadi?  

### 💻 Backend Live Coding
1. Express.js’da oddiy route yozing: `GET /hello` → `"Hello World"` qaytarsin.  
2. Oddiy CRUD yozish:  
   - `POST /users` → yangi user qo‘shish  
   - `GET /users` → userlar ro‘yxatini olish  
   - `GET /users/:id` → bitta userni olish  
   - `PUT /users/:id` → userni yangilash  
   - `DELETE /users/:id` → userni o‘chirish  
3. Middleware yozing: har bir request kelganda `console.log(method, url)` chiqarsin.  
4. SQL Query:  
   - `users` jadvalidan 18 yoshdan kattalarni olish (`SELECT * FROM users WHERE age > 18;`)  
   - `users` va `orders` jadvallarini `JOIN` qilib, har bir userning buyurtmalarini chiqarish.  
5. NestJS: Oddiy `UsersModule` yozing, unda `UsersController` va `UsersService` bo‘lsin.  

---

## 📝 Yakuniy Eslatma
- Har bir stajyor **nazariy + amaliy** qismdan o‘tishi kerak.  
- Live coding topshiriqlar 15-30 daqiqa ichida yechiladigan darajada bo‘lishi lozim.  
- Savollar **real hayotdagi vazifalarga yaqinlashtirilgan** bo‘lishi kerak.  
