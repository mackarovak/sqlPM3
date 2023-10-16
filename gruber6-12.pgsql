-- 6 глава
-- 2
select * from myschema.orders;
select sum(amt) from myschema.orders where cnum=2004;
-- 7
select * from myschema.customers WHERE cname LIKE 'G%' ORDER BY cname;
-- 12 
SELECT count(DISTINCT cnum) AS num_customers, odate FROM myschema.orders GROUP BY odate;

-- 7 глава
-- 1
select onum, snum, amt*0.12 as comis from myschema.orders;
-- 3
SELECT CONCAT('For the city ', city, ', the highest rating is: ', MAX(rating)) AS formatted_output FROM myschema.customers GROUP BY city;
select * from myschema.customers;
--8
select cnum, sum(amt) from myschema.orders GROUP BY cnum ORDER BY sum(amt) desc;

-- 8 глава 
-- 1 
select onum, cname from myschema.orders inner join myschema.customers on myschema.orders.cnum=myschema.customers.cnum;
-- 5
select cname, sname, comm from myschema.customers inner join myschema.salespeople on myschema.customers.snum=myschema.salespeople.snum where comm >0.12;
-- 8
select onum, sum(amt+amt*comm) from myschema.customers inner join myschema.orders on myschema.customers.cnum=myschema.orders.cnum inner join myschema.salespeople on myschema.customers.snum=myschema.salespeople.snum where myschema.customers.city='London' group by myschema.orders.onum;

-- 9 глава
-- 1
select STRING_AGG(sname, ', ') as sname, city from myschema.salespeople where city in (select city from myschema.salespeople group by city having count(*) > 1) group by city;
-- 4
select STRING_AGG(cname, ', ') as cname, odate from myschema.customers join myschema.orders on myschema.customers.cnum=myschema.orders.cnum where odate in (select odate from myschema.orders group by odate having count(*) > 1) group by odate;
-- 6
select sname, city from myschema.salespeople where comm >(select comm from myschema.salespeople where myschema.salespeople.snum=1001);
select sname, city from myschema.salespeople where comm >(select comm from myschema.salespeople where myschema.salespeople.sname='Peel');

-- 10 глава
-- 1
select cname, onum from myschema.customers inner join myschema.orders on myschema.customers.cnum=myschema.orders.cnum where cname in (select cname from myschema.customers where cname='Cisneros');
-- 4 
select distinct(myschema.salespeople.sname), comm from myschema.orders inner join myschema.salespeople on myschema.orders.snum=myschema.salespeople.snum inner join myschema.customers on myschema.orders.cnum=myschema.customers.cnum where rating>(select avg(rating) from myschema.customers);
-- 6
select count(orders.cnum), orders.cnum from myschema.orders inner join myschema.customers on myschema.orders.cnum=myschema.customers.cnum inner join myschema.salespeople on myschema.orders.snum=myschema.salespeople.snum group by orders.cnum having min(amt+amt*comm)>(select avg(amt+amt*comm) from myschema.orders inner join myschema.salespeople on myschema.orders.snum=myschema.salespeople.snum);
select * from myschema.orders;

-- 11-12 глава
-- 1     
select cname, cnum from myschema.customers where rating =(select max(rating) from myschema.customers as c where c.city=myschema.customers.city);
-- 4
select distinct(myschema.salespeople.snum), sname from myschema.customers inner join myschema.salespeople on myschema.customers.snum=myschema.salespeople.snum where exists (select * from myschema.customers where myschema.customers.rating=300 and myschema.customers.snum=myschema.salespeople.snum);
-- 7
select * from myschema.orders where cnum in (select cnum from myschema.orders group by cnum having count(*)>1);
