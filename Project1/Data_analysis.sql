drop table if exists Dataset1;
drop table if exists Dataset2;
create table Dataset1(
  District varchar(50),
  State varchar(50),
  Growth float,
  Sex_Ratio int,
  Literacy float
);

select * from Dataset1

--import dataset for analysis

copy Dataset1 from 'C:\Users\Pavan\Desktop\SQL\Dataset1new.csv' with CSV HEADER;

--create table2
create table Dataset2(
  District varchar(50),
	State varchar(50),
	Area_km2 int,
	Population int

);

--import dataset2
copy Dataset2 from 'C:\Users\Pavan\Desktop\SQL\Dataset2new.csv' with CSV HEADER;

select * from Dataset1
select * from Dataset2

-- check total no of rows in dataset
select  count(*) from Dataset1 -- here we can see 640 rows present in dataset1
select  count(*) from Dataset2 -- here we can see 640 rows present in dataset2

-- dataset from jharkhand and bihar 
select * from Dataset1 where state in ('Jharkhand','Bihar')

-- population of India
select sum(population) as Population from dataset2 

-- avg growth %
select avg(growth)*100 as avg_growth from dataset1

--avg growth% by state
select state, round( CAST(avg(growth)*100 as numeric), 2) as avg_growth from dataset1 group by state;

-- avg sex ratio
select * from dataset1;
select state, round(avg(sex_ratio), 0) avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;

-- avg litracy rate
select state, round( CAST(avg(literacy) as numeric), 2) as avg_litracy_ratio from dataset1 
group by state having round( CAST(avg(literacy) as numeric), 2) >90 order by avg_litracy_ratio desc;

--top 3 state showing highest growth ratio
select state, round( CAST(avg(growth)*100 as numeric), 2) as avg_growth from dataset1 
group by state order by avg_growth desc limit 3;

-- Bottom 3 state showing  lowest sex_ratio
select state, round(avg(sex_ratio), 0) avg_sex_ratio from dataset1 
group by state order by avg_sex_ratio asc limit 3;

-- top and bottom 3 state in literacy state
drop table if exists Top_states;
create table Top_states
(state varchar(50),
top_states float
);

insert into Top_states
select state, round( CAST(avg(literacy) as numeric), 2) as avg_literacy_ratio from dataset1 
group by state order by avg_literacy_ratio desc;

select * from Top_states order by Top_states desc limit 3;

drop table if exists Bottom_states;
create table Bottom_states
(state varchar(50),
bottom_states float
);

-- Bottom states
insert into Bottom_states
select state, round( CAST(avg(literacy) as numeric), 2) as avg_literacy_ratio from dataset1 
group by state order by avg_literacy_ratio desc;

select * from Bottom_states order by Bottom_states asc limit 3;


-- union operator
select * from (select * from Top_states order by Top_states desc limit 3) a 
union
select * from (select * from Bottom_states order by Bottom_states asc limit 3
) b;

-- states starting with letter a  or b 
select distinct state from dataset1 where lower(state) like 'a%' or lower (state) like 'b%'


-- joining both tables
select * from dataset1;
select a.district , a.state, a.sex_ratio, b.population from dataset1 as a 
inner join dataset2 as b on a.district = b.district;

-- for calculation of males and females 
'''
female/males= sex_ratio        ...1
females + males = population   ...2
females = population - males 	...3
(population - males) =  (sex_ratio)* males
population = males(sex_ratio+1 )
males = population/(sex_ratio+1)  ... males
females = population- population/(sex_ratio + 1)  ... females

= population (1-1/ (sex_ratio+1))

= population*(sex_ratio))/(sex_ratio+1)

'''


select d.state, sum(d.males) total_males, sum(d.females) total_females from 
(select c.district, c.state state,round( c.population/(c.sex_ratio+1),0) as males, 
round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females 
from
(select a.district , a.state, a.sex_ratio/1000 sex_ratio, b.population from dataset1 as a 
inner join dataset2 as b on a.district = b.district) as c) d
group by d.state;

-- total literacy rate 
select * from dataset1;

'''
total literate people/ population- literacy_ratio 		...1
total literate people = literacy_ratio*population		...2
total illiterate people = (1- literacy_ratio )* population

'''
select c.state, sum(literate_people) total_literate_ppl, sum(illiterate_people) total_illiterate_ppl from
(select d.district, d.state, round(cast(d.literacy_ratio*d.population as numeric), 0) literate_people, 
round(cast((1-d.literacy_ratio)*d.population as numeric),0) illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from dataset1 a 
inner join dataset2 as b on a.district= b.district) d) as c 
group by c.state


-- populaiton in previous census
'''
previous_census + growth* previous_census * Population
previous_census = population / (1+ growth)

'''

select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from
(select e.state, sum(e.previous_census_population)previous_census_population, sum(e.current_census_population) current_census_population 
from
(select d.district , d.state, round(cast (d.population/(1+d.growth) as numeric), 0) previous_census_population, 
d.population  current_census_population from
(select a.district, a.state, a.growth growth, b.population from dataset1 a 
 inner join dataset2 b on a.district = b.district)d)e
group by e.state)m;


-- population vs area

select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, 
		(g.total_area/ g.current_census_population) as current_census_population_vs_area from

(select q.*, r.* from(
	select '1' as keyy, n.* from (
select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from
(select e.state, sum(e.previous_census_population)previous_census_population, sum(e.current_census_population) current_census_population 
from
(select d.district , d.state, round(cast (d.population/(1+d.growth) as numeric), 0) previous_census_population, 
d.population  current_census_population from
(select a.district, a.state, a.growth growth, b.population from dataset1 a 
 inner join dataset2 b on a.district = b.district)d)e
group by e.state)m) n) q inner join (

	select '1' as keyy, z.* from (
select sum(area_km2) total_area from dataset2) z) r on q.keyy = r.keyy)g



-- window 
-- output top 3 districts from each state with highest literacy rate
select a.* from 
(select district, state, literacy, rank() over (partition by state order by literacy desc) rnk from dataset1) as a 
 where a.rnk in (1,2,3) order by state
 
 --Done--
 

