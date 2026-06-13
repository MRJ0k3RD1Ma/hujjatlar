Hemis tizimiga integratsiyalashga davomat tizimi.
Tizimdan umumiy ko’zlangan maqsad:
Faceid qurilmalari orqali talaba, o’qituvchi va xodimlarning davomatlarini elektron yuritish. Kim qaysi binoga kirib chiqqan ekanligini aniqlash va hisobotlarini yuritish.
Mavjud ma’lumotlar:
1.	Talabalarning yuzlari.
2.	O’qituvchilar va xodimlarning yuzlari
3.	Dars jadvallari
4.	Sababli ruhsat berilganlar
a.	O’qituvchilar va xodimlar
b.	Talabalar
c.	Guruhlar
5.	Binolar
6.	FaceIDlar
7.	Administratorlar
Ushbu tizimni yaratish uchun kerakli serverlar:
1.	Windows server 2016/2022 – FaceID qurilmalarini remote boshqarish uchun.
2.	Ubuntu 22.04 serveri – Davomatlarni ko’rsatib berish uchun.
a.	Docker o’rnatilishi majburiy.
b.	Baza PostgreSQL
Funksiyalar: 
1.	Talabalar integrate va ularning yuzlarini CRUD
2.	O’qituvchilar integrate va ularning yuzlarini CRUD
3.	Xodimlar integrate va ularning yuzlarini CRUD
4.	Dars jadvallari integrate 
5.	O’qituvchi va xodimlarga ish vaqti biriktirish
a.	O’qituvchilar dars jadvali bo’yicha ishlaydigan bo’lsa darsi bor paytlari binoda bo’lishi shart
b.	O’qituvchiga ish kuni va vaqti biriktirilgan bo’lsa aynan haftaning shu kunlarida ishda bo’lishi shart.
c.	Xodimlar orasida qoravullar ham bor ular har 4 kunda marta ishga tushadi. Sutkalik.
d.	Ishlagan vaqtini hisoblash tartibini – ertalab eng erta kelgan vaqti bilan shu kuni eng kech ketgan vaqti olinadi.
6.	O’qituvchi, xodimlar va talabalarning davomatlarini qo’lda kirish – Tadbir, topshiriq bo’lib chaqirilganda ruhsat berilganlar shu kuni uchun davom qo’shish imkoniyati. Forma ma’lumotlari
a.	Izoh
b.	Fayl
c.	Sana
d.	Kirish vaqti
e.	Ketish vaqti 
7.	Bayram kunlari – Bayram kunlarida O’qituvchi, xodimlar va talabalarning davomatlari hisoblanmaydi hammaga shu kuni dam olish kuni ekanligi tizimda yozib qo’yiladi.
8.	Statistikalar – Kun, hafta, oy va period
a.	Binoga kirishlar kesimida
b.	Talabalar darsga qatnashishlari kesimida
c.	O’qituvchilarning darsi bor paytlari aynan dars bo’ladigan binoda bo’lganliklari kesimida
d.	Binoga umumiy qancha tanish talaba, o’qituvchi va xodimlar kirib chiqqanligi kesimida
e.	Belgilangan vaqt oralig’idagi kechga qolishlarning yoki erta ketishlarning umumiy soati.
9.	Talabalar, O’qituvchilar va xodimlarning profile
a.	Umumiy ma’lumotlari
b.	Hozr qaysi binoda ekanligi
c.	Ushbu oy davomida umumiy ishlagan ish soati
d.	Ushbu oy davomida kechikgan soatlari
e.	Kirib chiqishlar taribi
i.	Umumiy
ii.	Binolar kesimida
iii.	Belgilangan period oralig’ida
f.	Ish kunlari bo’yicha ishlagan vaqtlari (tabeli)

Ushbu loyihani Texnik topshirig'ini o'rganib chiq va dasturni UI qismi uchun texnik topshiriq yozib ber



