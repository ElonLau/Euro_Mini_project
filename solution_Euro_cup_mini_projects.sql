use euro_cup_2016;

/* 
Please answer write the following queries:
1. Write a SQL query to find the date EURO Cup 2016 started on.
*/
select play_date as euro_cup_starting_date
from match_mast
order by play_date
limit 1;

/* 
2. Write a SQL query to find the number of matches that were won by penalty shootout.
*/
select count(*)
from match_mast
where decided_by = 'P' AND results = 'WIN';

/* 
3. Write a SQL query to find the match number, date, and score for matches in which no
stoppage time was added in the 1st half.
*/
select match_no, play_date, goal_score
from match_mast
where stop1_sec = 0;

/* 
4. Write a SQL query to compute a list showing the number of substitutions that
happened in various stages of play for the entire tournament.
*/
SELECT play_half,play_schedule,COUNT(*) 
FROM player_in_out 
WHERE in_out='I'
GROUP BY play_half,play_schedule
ORDER BY play_half,play_schedule,count(*) DESC;

/* 
5. Write a SQL query to find the number of bookings that happened in stoppage time.
*/
select distinct count(*) as booking_stoppage
from player_booked
where play_schedule = 'ST';


/*
6. Write a SQL query to find the number of matches that were won by a single point, but
do not include matches decided by penalty shootout.
*/
select count(*) as matches_won_by_one_point
from match_details
where goal_score = 1
and win_lose = 'W'
and decided_by != 'P';

/*
7. Write a SQL query to find all the venues where matches with penalty shootouts were
played.
*/
select s.venue_name as venues_matches_penalty_shoutouts
from soccer_venue as s
inner join match_mast as m
on s.venue_id = m.venue_id
where m.decided_by = 'P';

/*
8. Write a SQL query to find the match number for the game with the highest number of
penalty shots, and which countries played that match.
*/
select m.match_no, s.country_name
from match_details as m
	inner join soccer_country as s
    on s.country_id = m.team_id
order by m.penalty_score desc
limit 1;

/*
9. Write a SQL query to find the goalkeeper’s name and jersey number, playing for
Germany, who played in Germany’s group stage matches.
*/
select distinct player_name, jersey_no
from player_mast as root
	inner join match_details as m
    on root.team_id = m.team_id
    inner join soccer_country as s
    on root.team_id = s.country_id
where s.country_name = 'Germany'  
and m.play_stage = 'G'
and m.player_gk = root.player_id;

/*
10. Write a SQL query to find all available information about the players under contract to
Liverpool F.C. playing for England in EURO Cup 2016.
*/
select * 
from soccer_country as s
	inner join player_mast as p
    on s.country_id = p.team_id
where p.playing_club = 'Liverpool' 
and s.country_name = 'England';

/*
11. Write a SQL query to find the players, their jersey number, and playing club who were
the goalkeepers for England in EURO Cup 2016.
*/
select jersey_no, playing_club, player_name
from player_mast as p
	inner join soccer_country as s
    on p.team_id = s.country_id
where p.posi_to_play = 'GK'
and s.country_name = 'England';

/*
12. Write a SQL query that returns the total number of goals scored by each position on
each country’s team. Do not include positions which scored no goals.
*/
select p.posi_to_play, s.country_name,
sum(g.goal_id) over(partition by p.posi_to_play) as goals_as_position,
sum(g.goal_id) over (partition by s.country_name) as goals_as_country
from goal_details as g
	inner join player_mast as p
    on g.player_id = p.player_id
    inner join soccer_country as s
    on p.team_id = s.country_id;

/*
13. Write a SQL query to find all the defenders who scored a goal for their teams.
*/
select distinct player_name
from player_mast as p
	inner join goal_details as g
    on p.player_id = g.player_id
where p.posi_to_play = 'DF';

/*
14. Write a SQL query to find referees and the number of bookings they made for the
entire tournament. Sort your answer by the number of bookings in descending order.
*/

select distinct referee_name,
sum(p.booking_time) over(partition by r.referee_name) as booking_stats
from referee_mast as r
	inner join match_mast as m
    on r.referee_id = m.referee_id
	inner join player_booked as p
    on m.match_no = p.match_no
order by booking_stats desc;


/*
15. Write a SQL query to find the referees who booked the most number of players.
*/
WITH referees_table AS
	(SELECT COUNT(*) AS referees_booking, referee_id
	 FROM match_mast
	 GROUP BY referee_id
	 ORDER BY referees_booking DESC
	 LIMIT 1)

SELECT referee_name
FROM referee_mast as r
  INNER JOIN referees_table
  ON referees_table.referee_id = r.referee_id;

/*
16. Write a SQL query to find referees and the number of matches they worked in each
venue.
*/
WITH referees_table AS
	(SELECT COUNT(*) AS number_of_matches, referee_id, venue_id
	 FROM match_mast
	 GROUP BY venue_id, referee_id
     )

SELECT r.referee_name, s.venue_name, referees_table.number_of_matches
FROM referee_mast as r
  INNER JOIN referees_table
  ON referees_table.referee_id = r.referee_id
  INNER JOIN soccer_venue as s
  ON referees_table.venue_id = s.venue_id;


/*
17. Write a SQL query to find the country where the most assistant referees come from,
and the count of the assistant referees.
*/
SELECT DISTINCT s.country_name, 
COUNT(a.ass_ref_id) OVER(PARTITION BY a.country_id) AS final_count
FROM soccer_country AS s
	INNER JOIN asst_referee_mast AS a
	ON s.country_id = a.country_id
ORDER BY final_count DESC;

/*
18. Write a SQL query to find the highest number of foul cards given in one match.
*/
SELECT 
COUNT(p.booking_time) OVER(PARTITION BY m.match_no) AS highest_number_foul_cards
FROM player_booked AS p
	INNER JOIN match_mast AS m
	ON p.match_no = m.match_no
ORDER BY highest_number_foul_cards desc
LIMIT 1;


/*
19. Write a SQL query to find the number of captains who were also goalkeepers.
*/
SELECT COUNT(m.player_captain) as number_capitains_also_goalkeepers
FROM match_captain AS m
	INNER JOIN player_mast AS p
	ON m.team_id = p.team_id
WHERE p.posi_to_play = 'GK';


/*
20. Write a SQL query to find the substitute players who came into the field in the first
half of play, within a normal play schedule.
*/

SELECT p.player_name
FROM player_mast AS p
	INNER JOIN player_in_out AS in_out
	ON p.player_id = in_out.player_id
WHERE in_out.play_schedule = 'NT' 
AND in_out.play_half = 1;
