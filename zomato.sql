create database zomato

create table sales
(
userid_ int,
createdat_ datetime,
productid_  int
)
insert into sales
values(1,'2016-08-21',2),
(1,'2017-04-19',3),
(2,'2019-06-22',3),
(3,'2019-09-14',1),
(1,'2014-10-20',2),
(1,'2018-10-04',1),
(1,'2017-08-05',1),
(1,'2015-11-28',2),
(1,'2015-06-08',2),
(1,'2017-05-24',3),
(3,'2018-05-24',1),
(3,'2019-08-08',2),
(3,'2018-08-18',3),
(2,'2021-07-07',2),
(2,'2021-11-03',2),
(2,'2020-12-18',3)

create table gold_signup
(
userid_ int,
gold_signup_date date
)
 insert into gold_signup
 values(1,'2016-03-27'),
 (3,'2017-04-25')


 create table product
 (
 productid_ int,
 productname_ nvarchar(3),
 price int
 )
  insert into product
  values (1,'p1',230),
  (2,'p2',449),
  (3,'p3',789)

  create table users
  (
  userid__ int,
  sign_up_date date
  )

  insert into users
  values(1,'2019-04-17'),
  (2,'2015-06-26'),
  (3,'2014-04-27')

select*from sales
select*from product
select*from gold_signup
select*from users

--1.what is the total amount each customer spent on zomato?

select a.userid_,sum(b.price) total_amt_spent from sales a inner join product b on a.productid_=b.productid_
group by a.userid_
 
--2.How many days does each customer visited zomato

select userid_,count(distinct createdat_) distinct_days from sales group by userid_

--select productid_,count(distinct createdat_) distinct_days from sales group by productid_

--3.what was the 1st product purchased by each customer?
select*from
(select*,rank()  over (partition by userid_ order by createdat_) rnk from sales) a where rnk =1

--select*from
--(select*,rank()  over (partition by userid_ order by productid_) rnk from sales) a where rnk =1

select*from
(select*,rank()  over (partition by userid_ order by productid_) rnk from sales) a where rnk =1

--4.what is the most purchased item on the menu and how many times was it purchased by all the customer

select userid_,count(productid_)cnt from sales where productid_=
(select top 1 productid_ from sales group by productid_ order by count(productid_) desc)
group by userid_

--5.which item was the most popular for each customer?
select*from
(select*,rank() over (partition by userid_ order by cnt desc) rnk from
(select userid_,productid_,count(productid_) cnt from sales group by  productid_,userid_)a)b

select*from sales
select*from product
select*from gold_signup
select*from users

--6.which item was first purchased after they became a member?
select*from sales
select*from gold_signup

select*from
(select c. *, rank() over(partition by userid_ order by createdat_)  rnk from
(select a.userid_,a.createdat_,a.productid_,b.gold_signup_date from sales a inner join gold_signup b on a.userid_=b.userid_ 
and createdat_>=gold_signup_date)c)d where rnk=1

--7.which item was first just before they became a member?

select*from
(select c. *, rank() over(partition by userid_ order by createdat_ desc)  rnk from
(select a.userid_,a.createdat_,a.productid_,b.gold_signup_date from sales a inner join gold_signup b on a.userid_=b.userid_ 
and createdat_<=gold_signup_date )c )d where rnk=1


--8. what is the total order and amount spent befored they became member


select userid_,count (createdat_) totalorder, sum(price) total_amt_spent from 
(select c.*,d.price from
(select a.userid_,a.createdat_,a.productid_,b.gold_signup_date from sales a inner join gold_signup b on a.userid_=b.userid_ 
and createdat_<gold_signup_date)c inner join  product d on c.productid_=d.productid_)e  group by userid_


--9.if buying each product generates points for eg 5rs= 2 zomato points and each product has different purchasing points 
--for eg for p1 5rs=1 zomato point,for p2 10rs = 5 zomato point and p3 5rs =1 zomato point 2rs = 1 zomato point
--calculate points collected by each customers and for which product most points have been given till now

select userid_,sum(total_points)*2.5 total_money_earned from
(select e.*,amt/points total_points from
(select d.*,case when productid_=1 then 5 when productid_= 2 then 2 when productid_=3 then 5 else 0 end as points from
(select c.userid_,c.productid_,sum(price) amt from
(select a.*,b.price from sales a inner join product b on a.productid_=b.productid_)c
group by userid_,productid_)d)e)f group by userid_

select*from
(select * ,rank() over (order by total_points_earned) rnk from
(select productid_,sum(total_points) total_points_earned from
(select e.*,amt/points total_points from
(select d.*,case when productid_=1 then 5 when productid_= 2 then 2 when productid_=3 then 5 else 0 end as points from
(select c.userid_,c.productid_,sum(price) amt from
(select a.*,b.price from sales a inner join product b on a.productid_=b.productid_)c
group by userid_,productid_)d)e)f group by productid_)f)g where rnk =1

--10. In the first one year after a customer joins the gold program (inculding their  join date) irrespective of what the customer
--has purchased they earn 5 z0mato points for every10 rs spent  who earned 1 or 3 and what was their points emerging in their 
-- 1st year 1=2rs


select c.*, d.price*0.5 total_points_earned from
(select a.userid_,a.createdat_,a.productid_,b.gold_signup_date from sales a inner join gold_signup b on a.userid_=b.userid_ 
and createdat_>=gold_signup_date and createdat_<= dateadd(year,1,gold_signup_date))c 
inner join  product d  on c.productid_=d.productid_

--11. rank all the transictions from the customers
select *from sales
select*, rank() over (partition by userid_   order by createdat_ desc)rnk from sales

--12.rank all the transcition for each member whenever they are a zomato gold member  for every non  gold member transcition mark as na


select e.*,case when rnk=0 then 'na' else rnk end as rnkk from
(select c.*, cast((case when gold_signup_date is null then 0 else rank()over (partition by userid_ order by createdat_ desc)end) as varchar) as rnk  from
(select a.userid_,a.createdat_,a.productid_,b.gold_signup_date from sales a left join 
gold_signup b on a.userid_=b.userid_ and createdat_>=gold_signup_date)c)e