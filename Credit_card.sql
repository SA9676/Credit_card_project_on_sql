-- 1) top 5 cities with highest spends and their percentage contribution of total credit card spends 
 with cte1 as (
 SELECT SUM(CAST(Amount AS BIGINT)) AS total_wise
    FROM dbo.Credit_card
 ),
 cte2 as (
     select top 5 city, SUM(Amount) as city_wise
     from dbo.credit_card
     group by city
     order by city_wise desc
 )
 SELECT city,ROUND((city_wise*100.0 / total_wise),2) as contri_per
 from cte1 cross join cte2;

-- 2) highest spend month and amount spent in that month for each card type--

 with cte1 as (
 SELECT Card_Type,Datepart(MONTH,Date) as month,Datepart(YEAR,Date) as year, sum(Amount) as total
    FROM dbo.Credit_card
   group by Card_Type,Datepart(MONTH,Date),Datepart(YEAR,Date)
    ),
 cte2 as (
    select *, RANK() over (partition by Card_Type order by total desc) as rn from cte1
    )
 
 select * from cte2 where rn=1 order by total desc;

 -- 3) city which had lowest percentage spend for gold card type in comparison total amount spent in that city--

 with cte as (
    SELECT City, 
       SUM(Amount) as total, 
       SUM(CASE WHEN Card_Type='Gold' THEN Amount ELSE 0 END) as gold
FROM dbo.Credit_card
GROUP BY City
)
select *, gold*1.0/total as per from cte where gold != 0  order by per asc;

-- 4) which card and expense type combination saw highest month over month growth in Jan-2014 --

With CTE1 as (
    SELECT Card_Type,Exp_Type,sum(Amount) as dec_2013 from dbo.Credit_card
where Date BETWEEN '2013-12-01' and '2013-12-31'
group by Card_Type,Exp_Type
),
 CTE2 as (
    SELECT Card_Type,Exp_Type, sum(Amount) as jan_2014 from dbo.Credit_card
where Date BETWEEN '2014-01-01' and '2014-01-31'
group by Card_Type,Exp_Type
)
SELECT Top 1  C1.Card_Type,C1.Exp_Type, (jan_2014-dec_2013)*100.0/dec_2013 as DIFFERENCE
from CTE1 as C1 inner join CTE2 as C2 on C1.Card_Type=C2.Card_Type and C1.Exp_Type=C2.Exp_Type
order by [DIFFERENCE] desc;



-- 5) percentage contribution of spends by females for each expense type --

with cte as (
    select Exp_Type,SUM(Amount) as total, Sum(case when Gender='F' then Amount else 0 end) as f_total from dbo.Credit_card
    group by Exp_Type
    )

select *, f_total*1.0/total as per
     from cte;
