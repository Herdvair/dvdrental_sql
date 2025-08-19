--Questions : --

--1. Tampilkan first_name dan last_name dari aktor yang memiliki first_name "Jennifer", "Nick", atau "Ed"!
select first_name, last_name
from actor a 
where first_name in ('Jennifer', 'Nick', 'Ed');

--2. Hitunglah total pembayaran (amount) untuk setiap payment_id yang lebih besar dari 5.99!
select payment_id, 
sum(amount) as total_pembayaran
from payment
group by payment_id
having sum(amount) > 5.99 order by sum(amount) asc;

--3. Kelompokkan film berdasarkan durasi menjadi 4 kategori!
select film_id, title, length,
case 
	when length > 0 and length <= 72 then 'singkat'
	when length > 72 and length <= 86 then 'sedang'
	when length > 87 and length <= 100 then 'lama'
	when length > 100 then 'sangat lama'
end as duration
from film
order by title;

--4. Gabungkan data dari tabel rental dan payment untuk menampilkan rental_id, rental_date, payment_id, dan amount, urutkan berdasarkan amount secara ascending!
select 
	rental.rental_id,
	rental.rental_date,
	payment.payment_id,
	payment.amount
from payment 
join rental
	on rental.rental_id = payment.rental_id
order by payment.amount asc;

--5. Gunakan UNION untuk menggabungkan alamat (address) yang memiliki city_id = 42 dengan city_id = 300.
select address, city_id
from address
where city_id = 42
union
select address, city_id
from address 
where city_id = 300
order by address;

--6. Tampilkan nama pelanggan yang pernah melakukan transaksi dengan jumlah lebih dari rata-rata transaksi di tabel payment!
select distinct customer.first_name, customer.last_name
from customer
join payment 
on payment.customer_id = customer.customer_id
where payment.amount > (
	select 
	avg(amount) as rata_rata_amount
	from payment
	)

--7. Ambil daftar film yang memiliki durasi lebih panjang dibandingkan durasi rata-rata dari semua film dalam tabel film!
select f.length, f.title
from film f 
cross join(
		select avg(length) as rata_rata_durasi
		from film f 
)avg_durasi
where f.length > avg_durasi.rata_rata_durasi
order by f.length desc;

--8. Gunakan RANK() untuk menentukan peringkat film berdasarkan rental_rate!
select film_id, title, rental_rate,
		rank() over(order by rental_rate desc) as rank
from film;

--9. Gunakan DENSE_RANK() untuk menentukan peringkat pelanggan berdasarkan total transaksi yang mereka lakukan!
select customer_id, total_transaksi,
	dense_rank() over(order by total_transaksi desc) as rank_transaksi
from(
	select customer_id,
	sum(amount) as total_transaksi
	from payment
	group by customer_id
)as transaksi;

--10. Gunakan ROW_NUMBER() untuk memberikan nomor urut pada daftar film berdasarkan release_year!
select title, release_year,
row_number() over(order by release_year desc) as tahun_rilis
from film;

--11. Gunakan CTE untuk membuat daftar pelanggan yang melakukan transaksi lebih dari 10 kali!
with transaksi_over_10 as(
	select customer_id,
	count(payment_id) as banyak_transaksi
from payment
group by customer_id
)
select
* from transaksi_over_10
where banyak_transaksi > 10
order by banyak_transaksi asc;

--12. Gunakan CTE untuk mendapatkan daftar film dengan jumlah rental terbanyak!
with banyak_rental as (
	select f.film_id, f.title,
	count(rental_id) jumlah_rental
	from rental r
	join inventory i on r.inventory_id  = i.inventory_id 
	join film f on i.film_id = f.film_id
	group by f.film_id, f.title
),

sort_rental as(
	select 
	*, 
	rank() over (order by jumlah_rental desc) as ranking
	from banyak_rental
)

select film_id, title, jumlah_rental, ranking
from sort_rental;

--13. Buat query yang mengelompokkan film berdasarkan rental_rate:
--o Jika rental_rate lebih dari 4, kategori "Premium"
--o Jika rental_rate antara 2 dan 4, kategori "Regular"
--o Jika rental_rate kurang dari 2, kategori "Budget"
select title, rental_rate,
case
	when rental_rate > 4 then 'Premium'
	when rental_rate >= 2 and rental_rate <= 4 then 'Regular'
	when rental_rate < 2 then 'Budget'
end kategori
from film
order by rental_rate desc;

--14. Buat query yang mengelompokkan pelanggan berdasarkan total transaksi mereka:
--o Pelanggan dengan total transaksi lebih dari $100 sebagai "High Value Customer"
--o Pelanggan dengan transaksi antara $50-$100 sebagai "Medium Value Customer"
--o Pelanggan dengan transaksi di bawah $50 sebagai "Low Value Customer"
with total_transaksi as(
	select p.customer_id,
	sum (p.amount) as jumlah_transaksi
	from payment p
	group by p.customer_id
),
kategori_transaksi as (
	select
	total_transaksi.customer_id,
	total_transaksi.jumlah_transaksi,
	c.first_name,
	c.last_name,
	case 
		when total_transaksi.jumlah_transaksi > 100 then 'High Value'
		when total_transaksi.jumlah_transaksi > 50 and total_transaksi.jumlah_transaksi <= 100 then 'Medium Value'
		when total_transaksi.jumlah_transaksi <= 50 then 'Low Value'
	end kategori
from total_transaksi 
join customer c on total_transaksi.customer_id = c.customer_id
)
select customer_id, first_name, last_name, jumlah_transaksi,kategori
from kategori_transaksi
order by jumlah_transaksi desc;

