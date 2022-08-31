drop table if exists Sales_data;

create table Sales_data(
ORDERNUMBER int,
	QUANTITYORDERED int,
	PRICEEACH float,
	ORDERLINENUMBER int,
	SALES float,
	ORDERDATE varchar(20)	,
	STATUS varchar(20),
	QTR_ID int,
	MONTH_ID int,
	YEAR_ID	int,
	PRODUCTLINE	varchar(20),
	MSRP int,
	PRODUCTCODE varchar(20),
	CUSTOMERNAME varchar(50),
	PHONE varchar(20),
	ADDRESSLINE1 varchar(50),
	ADDRESSLINE2 varchar(50),
	CITY varchar(20),
	STATE varchar(20),
	POSTALCODE	varchar(20),
	COUNTRY	varchar(20),
	TERRITORY varchar(20),
	CONTACTLASTNAME varchar(30),
	CONTACTFIRSTNAME varchar(30),
	DEALSIZE varchar(20)
)

-- Import data
copy Sales_data from 'C:\Users\Pavan\Desktop\SQL\Project3\sales_data.csv' with CSV HEADER ;

select * from Sales_data;

-- change date type of orderdate column
 SET datestyle = mdy;
	ALTER TABLE Sales_data ALTER COLUMN ORDERDATE TYPE date
	USING orderdate::date;
	
	
-- check row counts
select count(ordernumber) from Sales_data;
-- We have 2823 data entries in dataset

-- check distinct values 
select distinct year_id from Sales_data; -- we have 3 different year data 2003, 2004, 2005.
select distinct productline from Sales_data; -- 7 distinct productlines 
select distinct country from Sales_data; -- 19 countries 
select distinct dealsize from Sales_data;  -- 3 deal size Small, Large, Medium
select distinct territory from Sales_data; -- 4 different territories Japan, EMEA, NA, APAC.

select distinct month_id from Sales_data
where year_id =2005;						-- we can see here months details of every year


-- Analysis
-- Grouping Sales by Productline
select productline, sum(sales) Revenue
from Sales_data
group by productline
order by 2 desc;


-- Grouping Sales by Year_id
select year_id, sum(sales) Revenue
from Sales_data
group by year_id
order by 2 desc;

-- Grouping Sales by deal_size
select dealsize, sum(sales) Revenue
from Sales_data
group by dealsize
order by 2 desc;


-- What was the best month for sales in a specific year ? how much was earned that month?

select month_id, sum(sales) Revenue, count(ordernumber) Frequency
from Sales_data
where year_id = 2004   --- change year to see the rest years
group by month_id 
order by 2 desc;

-- November is the month what product do they sell in november

select month_id, productline, sum(sales) Revenue, count(ordernumber) Frequency
from Sales_data
where year_id = 2003 and month_id = 11  --- change year to see the rest years
group by month_id , productline
order by 3 desc;

-- who is  best customer (this will be best answser by RFM)
'''
Recency-frequency- Monetary 
* it is an indexing technique that uses past purchase behavior to segment customers.
3 key metrics 
1. recency (how long ago their last purchse was)
2. frequency (how often they purchase)
3. monetary value( how much they spent)

In this dataset
* Recency - Last order date
* Frequency - Count of total orders
* Monetary value - total spend
'''
DROP TABLE IF EXISTS rfm
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from Sales_data) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from Sales_data)) Recency
	from Sales_data
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from rfm



--What products are most often sold together? 
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =  10411

select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from Sales_data p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM Sales_data
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from Sales_data s
order by 2 desc


---EXTRAs----
--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from Sales_data
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from Sales_data
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc
