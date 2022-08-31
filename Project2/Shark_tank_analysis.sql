drop table if exists shark_tank_data;

create table shark_tank_data (
EpNo int, 
	Brand varchar(50),
	Male int,
	Female int,
	Location varchar(50),
	Idea varchar(50),
	Sector varchar(30),
	Deal varchar(50),
	Amount_Invested_lakhs float,
	Amout_Asked float ,
	Debt_Invested float,
	Debt_Asked float,
	Equity_Taken float,
	Equity_Asked float,
	Avg_age	varchar(20),
	Team_members int,	
	Ashneer_Amount_Invested	float,
	Ashneer_Equity_Taken float,
	Namita_Amount_Invested float,
	Namita_Equity_Taken float, 	
	Anupam_Amount_Invested float,
	Anupam_Equity_Taken float,
	Vineeta_Amount_Invested	float,
	Vineeta_Equity_Taken	float,
	Aman_Amount_Invested float,
	Aman_Equity_Taken float,	
	Peyush_Amount_Invested float,
	Peyush_Equity_Taken float,
	Ghazal_Amount_Invested float, 
	Ghazal_Equity_Taken float,
	Total_investors	int, 
	Partners varchar(30)
	);
	
	select * from shark_tank_data;
	
	copy shark_tank_data from 'C:\Users\Pavan\Desktop\SQL\Project2\shark_tank_data.csv' with CSV HEADER encoding 'windows-1251';
	
	select * from shark_tank_data;
	
	-- Total episodes
	select max(distinct epno) from shark_tank_data;
	select count(distinct epno) from shark_tank_data;
	
	-- pitches
	select count (distinct brand) from shark_tank_data;
	
	-- pitches converted
	select cast (sum(a.converted_not_converted) as float) / cast(count(*) as float) from 
	(select amount_invested_lakhs, case when amount_invested_lakhs > 0 then 1 else 0 end as converted_not_converted 
	from shark_tank_data) a;
	
-- total male 
select sum(male) from shark_tank_data;
-- total female
select sum(female) from shark_tank_data;

-- gender ratio
select cast(sum(female) as float) / cast(sum(male)as float)  from shark_tank_data;


-- total invested amount
 select sum(amount_invested_lakhs) from shark_tank_data;
 
-- total equity taken 
 select avg(a.equity_taken) from
 (select * from shark_tank_data where equity_taken > 0) a ; 
	
-- highest deal taken
select max(amount_invested_lakhs) from shark_tank_data;

-- highest equity taken by the shark 
select max(equity_taken) from shark_tank_data;

--
select sum(a.female_count) startups from(
select female, case when female>0 then 1 else 0 end as female_count from shark_tank_data) a;

-- pitches converted having at least no women

select * from shark_tank_data;

select sum(b.female_count) from (
select case when a.female > 0 then 1 else 0 end as female_count, a.* from(
select * from shark_tank_data where deal != 'No Deal')a)b;

-- avg team members 
select avg(team_members) from shark_tank_data;

-- amount invested per deal
select avg(a.amount_invested_lakhs) as amount_invested_per_deal from
(select * from shark_tank_data where deal != 'No Deal') a;

-- avg age group of contestants
 select avg_age, count(avg_age) cnt from shark_tank_data group by avg_age order by cnt desc;


-- which is the location of the group of contestants
select location, count(location) cnt from shark_tank_data group by location order by cnt desc;

-- sector of group of contestants 
select sector, count(sector) cnt from shark_tank_data group by sector order by cnt desc;

-- partner deals
select partners , count(partners) cnt from shark_tank_data where partners != '-' group by partners order by cnt desc;

-- making the matrix
select ashneer_amount_invested from shark_tank_data where ashneer_amount_invested > 0;

-- count of ashneer amnt
select count(ashneer_amount_invested) from shark_tank_data where ashneer_amount_invested > 0;

-- ashneer equity taken
select sum(c.ashneer_amount_invested), avg(c.ashneer_equity_taken)
from (select * from shark_tank_data where ashneer_equity_taken > 0) c;


-- join all the records 

select m.keyy,m.total_deals_present,m.total_deals,n.total_amount_invested,n.avg_equity_taken from

(select a.keyy,a.total_deals_present,b.total_deals from(

select 'Ashneer' as keyy,count(ashneer_amount_invested) total_deals_present from shark_tank_data where ashneer_amount_invested > 0) a

inner join (
select 'Ashneer' as keyy,count(ashneer_amount_invested) total_deals from shark_tank_data 
where ashneer_amount_invested >0) b 

on a.keyy=b.keyy) m

inner join 

(SELECT 'Ashneer' as keyy,SUM(C.ASHNEER_AMOUNT_INVESTED) total_amount_invested,
AVG(C.ASHNEER_EQUITY_TAKEN) avg_equity_taken
FROM (SELECT * FROM shark_tank_data  WHERE ASHNEER_EQUITY_TAKEN >0 ) C) n

on m.keyy=n.keyy



-- which is the startup in which the highest amount has been invested in each domain/sector

select c.* from 
(select brand,sector,amount_invested_lakhs,rank() over(partition by sector order by amount_invested_lakhs desc) rnk 

from shark_tank_data) c

where c.rnk=1

--done--


