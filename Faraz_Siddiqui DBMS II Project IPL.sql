use ipl;
-- Q1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select * from ipl_match;
select * from ipl_bidding_details;

select t1.bidder_id, t2.win_counts, t1.total_bid_count, round((t2.win_counts / t1.total_bid_count) * 100,2) AS winning_percentage
FROM
(select distinct bidder_id, count(bid_status)over(partition by BIDDER_ID) total_bid_count from ipl_bidding_details)t1
join
(select distinct bidder_id, count(BID_STATUS) win_counts from ipl_bidding_details where BID_STATUS ='won'
group by BIDDER_ID)t2
on t1.bidder_id=t2.bidder_id
order by winning_percentage desc;

-- Insights: bidder_id 103 have the highest win perncentage. 

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2. Display the number of matches conducted at each stadium with the stadium name and city.

select distinct SCHEDULE_ID from ipl_match_schedule;

select stadium_name, city, count(schedule_id) No_of_matches from ipl_stadium s
join
ipl_match_schedule ims on s.stadium_id = ims.stadium_id
where status = 'completed'
group by STADIUM_NAME, city;

-- Insights: MWankhede stadium Mimnai conducted the most no. of matches
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q3. In a given stadium, what is the percentage of wins by a team that has won the toss? 

select * from ipl_match;

select *, (won_toss/total_toss) *100 as winner_percent from 
(select distinct STADIUM_ID, count(im.match_id) won_toss from ipl_match im
 join ipl_match_schedule ims on im.MATCH_ID=ims.MATCH_ID where toss_winner= match_winner
group by STADIUM_ID)t1 join
(select distinct STADIUM_ID, count(im.match_id) total_toss from ipl_match im
 join ipl_match_schedule ims on im.MATCH_ID=ims.MATCH_ID
group by STADIUM_ID)t on t1.stadium_id=t.stadium_id;

select * from ipl_stadium;
-- Insights: stadium ID 6 Sawai Mansingh Stadium has the highest toss winners who are match winners as well
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q4. Show the total bids along with the bid team and team name. 

select * from ipl_bidding_details;

select count(bidder_id) Total_bids, bid_team, team_name
from ipl_bidding_details bid join ipl_team t
on bid.bid_team=t.TEAM_ID
group by team_name, bid_team;

-- Insights : most bids are on team id 8 that is sunrisers hyderabad
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q5. Show the team ID who won the match as per the win details. 

select* from ipl_team;
select * from ipl_match;
select match_id, TEAM_ID, TEAM_NAME as winner_Name from ipl_team t join ipl_match m on t.team_id in
(Case 
when substr(win_details,6,3) = 'CSK' then (select team_id from ipl_team where remarks like '%CSK%')
when substr(win_details,6,2) = 'DD' then (select team_id from ipl_team where remarks like '%DD%')
when substr(win_details,6,4) = 'KXIP' then (select team_id from ipl_team where remarks like '%KXIP%')
when substr(win_details,6,3) = 'KKR' then (select team_id from ipl_team where remarks like '%KKR%')
when substr(win_details,6,2) = 'MI' then (select team_id from ipl_team where remarks like '%MI%')
when substr(win_details,6,2) = 'RR' then (select team_id from ipl_team where remarks like '%RR%')
when substr(win_details,6,3) = 'RCB' then (select team_id from ipl_team where remarks like '%RCB%')
when substr(win_details,6,3) = 'SRH' then (select team_id from ipl_team where remarks like '%SRH%')
end);

-- Insights: output shows winner team name and ID od every match

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q6 Display the total matches played, total matches won and total matches lost by the team along with its team name.

select s.team_id, team_name, sum(matches_played) `Total Matches`, sum(MATCHES_WON) `Total Won`, sum(MATCHES_LOST) `Total Lost`from ipl_team t
join ipl_team_standings s on t.TEAM_ID=s.TEAM_ID
group by s.team_id, team_name;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q7 Display the bowlers for the Mumbai Indians team. 

-- if we filter bowlers on the basis of team_id 
 select team_id, tp.player_id, player_name from ipl_team_players tp 
join ipl_player p on tp.player_id=p.player_id 
where PLAYER_ROLE =
 'Bowler' and team_id= 
 (select team_id from ipl_team where team_name = 'Mumbai Indians');


-- if we filter bowlers on team name from remarks of team_players
select team_id, tp.player_id, player_name from ipl_team_players tp 
join ipl_player p on tp.player_id=p.player_id 
where PLAYER_ROLE =
 'Bowler' and tp.remarks like '%MI%';
 
 
 -- Insights: total 9 bowlers for mumbai Indians

select * from _ipl_player where player_ROLE = 'Bowlers';
select* from ipl_team_players where player_role = 'Bowler';
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q8. How many all-rounders are there in each team, Display the teams with more than 4  
--     all-rounders in descending order. 

select pt.team_id, team_name, count(player_id) ALL_Rounders_Counts from ipl_team_players pt
join ipl_team t on pt.TEAM_ID= t.TEAM_ID
where PLAYER_ROLE like '%all%'
group by pt.TEAM_ID
having ALL_Rounders_Counts>4 order by ALL_Rounders_Counts desc;

-- Insights: Delhi Daredevils and KXIP have 7 allrounders : for better depiction refer excel file
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q9. Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium 
--      bidding year-wise. 
--     Note the total bidders’ points in descending order and the year is the bidding year. 
--     Display columns: bidding status, bid date as year, total bidder’s points 

select bid_status, total_points as total_bidder_points, year(bid_date) as bid_year from ipl_bidding_details d
join ipl_bidder_points p on d.bidder_id=p.bidder_id 
where d.schedule_id in
(select schedule_id from ipl_match_schedule where stadium_id in
(select stadium_id from ipl_stadium where stadium_name = 'M. Chinnaswamy Stadium') and match_id in
(select match_id from ipl_match where (case when match_winner=1 then team_id1
else team_id2
end) =
(select team_id from ipl_team where team_name like '%Chennai%')))
order by total_bidder_points desc,year(bid_date);
select* from ipl_match;

-- Insights: 17 bidder points when bid is on CSK and playing in chinna swamy stadium and CSK won the match there

-- Working (select match_id, schedule_id, stadium_id from ipl_match_schedule where stadium_id =
-- (select stadium_id from ipl_stadium where stadium_name = 'M. Chinnaswamy Stadium'))t1
-- join
-- select match_id from ipl_match where (case when match_winner=1 then team_id1
-- else team_id2
-- end) =
-- (select team_id from ipl_team where team_name like '%Chennai%')t2;




-- Working  select match_id, schedule_id, stadium_id from ipl_match_schedule where stadium_id in
-- (select stadium_id from ipl_stadium where stadium_name = 'M. Chinnaswamy Stadium') and match_id in
-- (select match_id from ipl_match where (case when match_winner=1 then team_id1
-- else team_id2
-- end) =
-- (select team_id from ipl_team where team_name like '%Chennai%'));

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q10. Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets. 
--      Note  
-- 1. Use the performance_dtls column from ipl_player to get the total number of wickets 
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets 
-- Do not use joins in any cases. 
-- Display the following columns teamn_name, player_name, and player_role. 

-- Pts-379.5 Mat-16 Wkt-17 Dot-137 4s-40 6s-23 Cat-1 Stmp-0

select* from ipl_player;
with TABLE1 as
(select
(select Team_Name
from ipl_team
where team_id in
(select team_id
from ipl_team_players
where player_id = temp_1.player_id)) as TEAM_NAME,
player_name as PLAYER_NAME, 
(select player_role
from ipl_team_players
where player_id = temp_1.player_id) as PLAYER_ROLE,
Total_Wickets as TOTAL_WICKETS, dense_rank()over (order by total_wickets desc ) as ranking
from(select player_id,player_name, cast(substring(performance_dtls,instr(performance_dtls,'wkt')+4,2) as unsigned int) as Total_wickets
from ipl_player
where player_id in 
(select player_id
from ipl_team_players
where player_role = 'Bowler' or player_role= 'All-Rounder')) as temp_1)
select *
from TABLE1 
where ranking <=5;


#instring gives index value and substring extract  no. of values as per the index give 
#cast(substring(performance_dtls,instr(performance_dtls,'wkt')+4,2) as unsigned int)
#select performance_dtls, instr(performance_dtls,'wkt') from ipl_player;

-- Insights: Andrew Tye is the highest wicket taker with 24 wickets followed by siddarth kaul and rashid khan

select * from ipl_team;
select * from ipl_team_players;
select * from ipl_player;
select* from ipl_match;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q.11 show the percentage of toss wins of each bidder and display the results in descending order based on the percentage 

-- join ipl-bidding_details ki schedule id with  ipl_match_schedule ki schedule id
-- further join ipl_match on the basis of match_id to get toss_winner (use case when to get teamID of toss winner)
-- now get team name of toss winners

select * from ipl_bidding_details;
select * from ipl_bidder_points;
select * from ipl_bidder_details;

-- working note
-- select cnt_toss_wins/ cnt_total_toss * 100 from
-- with t1 as
-- (select bidder_id, bid_team, schedule_id, count(schedule_id) total_bids from ipl_bidding_details
-- group by bidder_id,bid_team,schedule_id), t2 as
-- (select schedule_id, m.match_id, case when 
-- toss_winner =1 then team_id1 
-- else team_id2
-- end Toss_winner_Team 
-- from ipl_match m join ipl_match_schedule ms on m.match_id=ms.match_id)
-- select t1.bidder_id,count(t1.schedule_id) toss_win_bids from t1, t2
-- where t1.schedule_id = t2.schedule_id and t1.bid_team= t2.Toss_winner_Team group by t1.bidder_id;
-- select t1.schedule_id, toss_win_bids/total_bids;




-- Working note
## // WITH t1 AS 
-- (SELECT bidder_id, bid_team, count( schedule_id) AS total_bids 
-- FROM ipl_bidding_details group by bidder_id, bid_team), 
-- t2 AS 
-- (SELECT schedule_id, m.match_id, CASE 
-- WHEN toss_winner = 1 THEN team_id1 
-- ELSE team_id2
-- END AS Toss_winner_Team FROM ipl_match m 
-- JOIN ipl_match_schedule ms ON m.match_id = ms.match_id),
-- t3 AS 
-- (SELECT t1.bidder_id, 
-- count(schedule_id) AS toss_win_bids FROM t1 JOIN 
-- t2 ON schedule_id = t2.schedule_id AND t1.bid_team = t2.Toss_winner_Team group by t1.bidder_id)
-- SELECT distinct t3.bidder_id, t3.toss_win_bids*100 / count(t3.bidder_id) AS toss_win_percentage 
-- FROM t1
-- JOIN t3 ON t1.bidder_id = t3.bidder_id
-- group by t1.bidder_id;##\\
    
 with tab1 as
(select distinct bidder_id, count(d.schedule_id)over(partition by bidder_id) toss_win_bet
from ipl_bidding_details d left join ipl_match_schedule s on d.schedule_id =s.schedule_id left join ipl_match m on s.match_id= m.match_id 
where d.schedule_id= s.schedule_id and d.bid_team= case when toss_winner = 1 then team_id1
else team_id2
end),
tab2 as
(select distinct bidder_id, count(d.schedule_id)over(partition by bidder_id) total_toss_bet from ipl_bidding_details d)
select distinct tab1.bidder_id, round(tab1.toss_win_bet*100/tab2.total_toss_bet,2) as Toss_win_on_bid from tab1
join tab2 on tab1.bidder_id=tab2.bidder_id order by Toss_win_on_bid desc;	
 
 -- Insights : output here shows bidder_id wise percentge of toss win by the team on which bid was placed
 -- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- Q.12 find the IPL season which has a duration and max duration. 
--       Output columns should be like the below: Tournment_ID, Tourment_name, Duration column, Duration 

select TOURNMT_ID as tournament_id, TOURNMT_NAME, from_date, to_date,
datediff(to_date, from_date) as duration, 
max(datediff(to_date, from_date))over () as max_Duration
from ipl_tournament order by duration desc;

-- Insights: IPL duration 2012 and 2013 have maximum duration that is 53 days

select * from ipl_tournamanet;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q13. Write a query to display to calculate the total points month-wise for the 2017 bid year. 
--      sort the results based on total points in descending order and month-wise in ascending order. 
--      Note: Display the following columns: 
--      Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points 
--      Only use joins for the above query queries. 



-- assuming total points will remain as it is and data needs to be ordered by (total points irrespective of bid year)

select distinct p.bidder_id, bidder_name, year(bid_date)as years, month(bid_date)as months, Total_Points
from ipl_bidder_details bd join ipl_bidding_details d on  bd.bidder_id= d.bidder_id
right join ipl_bidder_points p on  d.bidder_id= p.bidder_id
where  year(bid_date)= 2017 order by total_points desc,p.bidder_id, months;

select * from ipl_bidder_points;
select * from ipl_bidding_details;
--                                                   -------- 



-- assuming total points in bidder points table contains won bids of 2017 and 2018
-- thus, we need to find  total points in 2017
--  we need (total_point / count(bid won)) and then multiply it with count(bid won in 2017)

with t1 as
(select d.bidder_id, (total_points/count(d.bidder_id)) as totalwins from ipl_bidding_details d join ipl_bidder_points p on 
d.bidder_id= p.bidder_id where bid_status='won' group by d.bidder_id, total_points),
t2 as
(select d.bidder_id, count(d.bidder_id) as wins2017 from ipl_bidding_details d where year(bid_date)= 2017 and bid_status ='won' group by d.bidder_id), 
t3 as
(select distinct p.bidder_id, bidder_name, year(bid_date)as years, month(bid_date)as months
from ipl_bidder_details bd join ipl_bidding_details d on  bd.bidder_id= d.bidder_id
right join ipl_bidder_points p on  d.bidder_id= p.bidder_id
where  year(bid_date)= 2017)
select t1.bidder_id, bidder_name, years, months, round((totalwins*wins2017),0) as total_points_2017 from
 t1 join t2 on t1.bidder_id =t2.bidder_id join t3 on t2.bidder_id = t3.bidder_id order by
total_points_2017 desc, t1.bidder_id,months;

--                                                     --------


-- with sum of total points
-- assuming it is total individual points for each bid win which needs to be sum up for every win
 
select distinct p.bidder_id, bidder_name, year(bid_date)as years, month(bid_date)as months, sum(Total_Points) total_points
from ipl_bidder_details bd join ipl_bidding_details d on  bd.bidder_id= d.bidder_id
right join ipl_bidder_points p on  d.bidder_id= p.bidder_id
where  year(bid_date)= 2017 
group by p.bidder_id, bidder_name, years,months order by total_points desc, months;

-- Insights: bidder_id 121 have the highest total_points followed by bidder_id 103 and 104

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q14. Write a query for the above question using sub-queries by having the same constraints as the above question. 
-- Write a query to display to calculate the total points month-wise for the 2017 bid year. 
--      sort the results based on total points in descending order and month-wise in ascending order. 
--      Note: Display the following columns: 
--      Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points 
--      Only use joins for the above query queries. 

select distinct t3.bidder_id, t2.bidder_name, t1.years, t1.months, t3.total_points from
(select bidder_id, year(bid_date) years, month(bid_date) months from ipl_bidding_details
where year(bid_date) =2017)t1
join
(select bidder_id, bidder_name from ipl_bidder_details)t2 on t1.bidder_id = t2.bidder_id
join
(select bidder_id, sum(total_points)over (partition by bidder_id) as total_points from ipl_bidder_points)t3 on
t1.bidder_id = t3.bidder_id
order by total_points desc, months;

-- Insights: bidder_id 121 have the highest total_points followed by bidder_id 103 and 104

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q15. Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year. 
--      Output columns should be: like 
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder; 



-- with not summing up of points

with cte as
(select bid_pt.Bidder_id, Bidder_name,Total_points,dense_rank()over(order by total_points desc) as Top, dense_rank()over(order by total_points ) as Bottom
from ipl_bidder_points bid_pt join ipl_bidding_details bid_dt
on bid_pt.bidder_id = bid_dt.bidder_id join ipl_bidder_details bidd_dt 
on bidd_dt.Bidder_id =bid_pt.bidder_id
where year(bid_date)= 2018 
group by bid_pt.Bidder_id, Bidder_name,Total_points),
cte1 as
(select Bidder_id,Total_points, Bidder_name,
Case 
	when top <=3 then 'Highest_bidder' end Highest_bidder, 
    case
    when bottom <=3 then'Lowest_bidder' end lowest_bidder
from cte)
select *
from cte1 
where highest_bidder is not null or lowest_bidder is not null
order by total_points desc;

--                                                           --------                                                  -------


-- with suming up total points

with t1 as
(select p.bidder_id,year(bid_date) years,cast(dense_rank()Over(order by sum(total_points) desc)  as unsigned INT )as ranking, sum(total_points) total_points 
from ipl_bidder_points p join ipl_bidding_details bd on p.bidder_id=bd.bidder_id
where year(bid_date) = 2018
group by p.bidder_id, years )
select bidder_id, total_points, ranking,
case when Ranking <= 3 then (select bidder_name from ipl_bidder_details where bidder_id = t1.bidder_id)
Else 0
end Highest_3_Bidders,
case 
when Ranking >= (select max(ranking)-2 from 
(select bidder_id, cast(dense_rank()Over(order by sum(total_points) desc)  as unsigned INT )as ranking, sum(total_points) total_points from ipl_bidder_points
group by bidder_id)t11
) then (select bidder_name from ipl_bidder_details where bidder_id = t1.bidder_id) 
Else 0
end Lowest_3_Bidders from t1
WHERE ranking <4 or ranking>= (select max(ranking)-2 from t1);



-- on basis if average total points year wise

with cte as
(select d.bidder_id, (total_points/count(d.bidder_id)) as tp from ipl_bidding_details d join ipl_bidder_points p on 
d.bidder_id= p.bidder_id where bid_status='won' group by d.bidder_id, total_points),
cte2 as
(select d.bidder_id, count(d.bidder_id) as wins2018 from ipl_bidding_details d where year(bid_date)= 2018 and bid_status ='won' group by d.bidder_id), 
cte3 as
(select cte2.bidder_id, round((tp*wins2018),0) points_2018 from cte,cte2
where cte.bidder_id = cte2.bidder_id), 
cte4 as
(select bidder_id, points_2018 pts from cte3 ), 
cte5 as
(select bidder_id, pts, dense_rank()over(order by pts desc) top, dense_rank()over(order by pts)bottom from cte4)
select bidder_id,pts, Case 
	when top <=3 then 'Highest_bidder' end Highest_bidder, 
    case
    when bottom <=3 then'Lowest_bidder' end lowest_bidder from cte5 
    where case when top <=3 then 'Highest_bidder' end is not null or 
    case when bottom <=3 then'Lowest_bidder' end is not null
    order by pts desc;
    
    
    -- Insights:  bidder_id 121, 103 and 104 are highest points bidder and biider id 116, 109, 102, 119, 128, 122, 105 atr lowest bidders
    -- if consider average points assumption then 121,110,126, 103,106 are highest bidders and 129, 128, 122 are among the lowest bidders
    
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q16 Create two tables called Student_details and Student_details_backup. (Additional Question - Self Study is required) 
-- Table 1: Attributes 	 Table 2: Attributes 
-- Student id, Student name, mail id, mobile no. 
-- Student id, student name, mail id, mobile no. 
-- Feel free to add more columns the above one is just an example schema. 
-- Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student details table.
-- Every time the students change their details like their mobile number, 
-- You need to update their details in the student details table.  
-- Here is one thing you should ensure whenever the new students' details come, 
-- you should also store them in the Student backup table so that if you modify the details in the student details table,
-- you will be having the old details safely. 
-- You need not insert the records separately into both tables rather Create a trigger in such a way that
-- It should insert the details into the Student back table when you insert the student details into the student table automatically. 


-- STEP 1: Table1 and Table2 
create table Student_details
( Student_id int,
Student_Name varchar(15),
mail_id varchar(25),
mobile_no int);

create table Student_details_Backup
(operation varchar(20), 
operation_time timestamp,
Student_id int ,
Student_Name varchar(15),
mail_id varchar(25),
mobile_no bigint);

-- STEP 2: creating triggers for insert and update
delimiter %%
create trigger backup_insert 
after insert on student_details
for each row
begin
	insert into student_details_backup(Operation,operation_time,student_id,student_name,mail_id,mobile_no)
	values('Insert',now(),new.student_id,new.student_name,new.mail_id,new.mobile_no);
end %%
delimiter ;

delimiter %%
create trigger backup_update 
after update on student_details
for each row
begin
	insert into student_details_backup(Operation,operation_time,student_id,student_name,mail_id,mobile_no)
	values('Update',now(),new.student_id,new.student_name,new.mail_id,new.mobile_no);
end %%
delimiter ;

-- STEP 3: Inserting values in Table 1 and check table 2 also whether the record is inserted 
insert into student_details(student_id,student_name,mail_id,mobile_no)
values(1, 'A', 'xyz',12345),(2, 'B', 'abc',99999),(3, 'C', 'LMN',100000);
-- Whenever we insert new records it will be inserted automatically in table2
insert into student_details(student_id,student_name,mail_id,mobile_no)
values(4, 'D', 'liv',888888);

select * from student_details;
select * from student_details_backup;
-- STEP 4: Updating Values in Table 1 and check table 2 whether the updated record is there  
update student_details
set mobile_no = 123456789
where student_id = 1;


select *
from student_details;
select *
from student_details_backup;

-- ----------------------------------------------------------------------END--------------------------------------------------------------------------------------------------------------------------------------------------------------