select *
from NBAPlayoffs..Sheet1$

select *
from NBAPlayoffs..['1996-97$']

select * from NBAPlayoffs..['1996-97$'] where Team is null
--Delete duplicate header rows
delete
from NBAPlayoffs..['1996-97$']
where team is null

select *
from NBAPlayoffs..PlayerAdvancedStats$ where team is null

--1996-1997 is the first year of stats NBA.com has available.  So this is analysis of 1997 Playoffs and onwards

select * 
from NBAPlayoffs..PLAYOFFTEAMSTATS$

--Update rows so that Los Angeles and LA CLippers totals can be combined

update NBAPlayoffs..PLAYOFFTEAMSTATS$
set Team = 'Los Angeles Clippers'
where Team = 'LA Clippers'

update NBAPlayoffs..PLAYOFFTEAMSTATS$
set Team = 'Washington Wizards'
where Team = 'Washington Bullets'

update NBAPlayoffs..PLAYOFFTEAMSTATS$
set Team = 'Brooklyn Nets'
where Team = 'New Jersey Nets'


select *
from NBAPlayoffs..PLAYOFFTEAMADVANCEDSTATS$

update NBAPlayoffs..PLAYOFFTEAMADVANCEDSTATS$
set Team = 'Los Angeles Clippers'
where Team = 'LA Clippers'

update NBAPlayoffs..PLAYOFFTEAMADVANCEDSTATS$
set Team = 'Washington Wizards'
where Team = 'Washington Bullets'

update NBAPlayoffs..PLAYOFFTEAMADVANCEDSTATS$
set Team = 'Brooklyn Nets'
where Team = 'New Jersey Nets'


update Sheet1$
set COUNTRY = 'Democratic Republic of the Congo'
where COUNTRY = 'DRC'

--ensuring bio table can be linked to stats tables
select stat.Player, SUM(stat.W) as Career_Wins, SUM(stat.L) as Career_Losses, bio.[DRAFT YEAR]
from NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..Sheet1$ as bio
on stat.Player = bio.Player
group by stat.Player, bio.[DRAFT YEAR]
order by Career_Wins desc

--Most Career Wins
Select Player, SUM(W) as Career_Wins, SUM(L) as Career_Losses, (SUM(W)/(SUM(W)+SUM(L))) as Career_Win_Percentage, MIN(Year) as FirstPlayoffYear, MAX(Year) as LastPlayoffYear, COUNT(Team) as Appearances, COUNT(Distinct Team) as #DifferentTeams
from NBAPLAYOFFS..['1996-97$']
group by player
Order by Career_Wins desc

--Highest Winning Percentage
Select Player, SUM(W) as Career_Wins, SUM(L) as Career_Losses, (SUM(W)/(SUM(W)+SUM(L))) as Career_Win_Percentage, MIN(Year) as FirstPlayoffYear, MAX(Year) as LastPlayoffYear, COUNT(Team) as Appearances, COUNT(Distinct Team) as #DifferentTeams
from NBAPLAYOFFS..['1996-97$']
group by player
having SUM(GP) > 74 --arbitrary #; could decide differently how many games are needed to be significant
order by Career_Win_Percentage desc

--Career Minutes Leaders
Select Player, SUM(MIN) as Career_Minutes, MIN(Year) as FirstPlayoffYear, MAX(Year) as LastPlayoffYear, COUNT(Team) as Appearances, COUNT(Distinct Team) as #DifferentTeams
from NBAPLAYOFFS..['1996-97$']
group by player
order by Career_Minutes desc

---Players with 100 career Appearances since 1997
select stat.Player, SUM(stat.GP) as Games_Played, MIN(stat.[Year]) as FirstPlayoffYear, MAX(stat.[Year]) as LastPlayoffYear, COUNT(stat.Team) as Appearances, COUNT(Distinct stat.Team) as #DifferentTeams, bio.COLLEGE, bio.COUNTRY, bio.[DRAFT YEAR], bio.[DRAFT ROUND], bio.[DRAFT NUMBER] 
from NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..Sheet1$ as bio
on stat.Player = bio.Player
group by stat.Player, bio.COLLEGE, bio.COUNTRY, bio.[DRAFT YEAR], bio.[DRAFT ROUND], bio.[DRAFT NUMBER]
having SUM(GP) > 99
order by Games_Played desc

--Career Points Leaders

Select Player, SUM(PTS) as Career_Points, MIN(Year) as FirstPlayoffYear, MAX(Year) as LastPlayoffYear, COUNT(Team) as Appearances, COUNT(Distinct Team) as #DifferentTeams
from NBAPLAYOFFS..['1996-97$']
group by player
order by Career_Points desc

--Career Pts/Game Leaders -- could add minimum game filter

Select Player, SUM(PTS) as Career_Points, SUM(GP) as Career_Games_Played, (SUM(PTS)/SUM(GP)) as Career_PPG
from NBAPLAYOFFS..['1996-97$']
group by player
order by Career_PPG desc


--Single Season Points Per Game Leaders for Teams to go to win at least 1 round

Select Player, Team, [Year], W, L, GP, PTS, (PTS/GP) as PPG
From NBAPlayoffs..['1996-97$']
where w > 3 
order by PPG desc

--Total Points scored in each Playoff Season

Select [Year], (SUM(GP)/2) as Games_Played, Sum(PTS) as Total_Points, (Sum(PTS)/(SUM(GP)/2)) as Points_Per_Game
from NBAPlayoffs..PLAYOFFTEAMSTATS$
group by [Year]
order by [Year] desc

--Win Totals over Period
--First round was not always a best of 7

Select Team, SUM(W) as Total_Wins, SUM(L) as Total_Losses, (SUM(W)/Sum(GP)) as Win_Pecentage, COUNT(CASE WHEN [YEAR] < 2003 and W > 14 THEN 1 END) + COUNT(CASE WHEN [YEAR] > 2002 and W > 15 THEN 1 END) as Championships
from NBAPlayoffs..PLAYOFFTEAMSTATS$
group by Team
order by Total_Wins desc

Select Team, [YEAR], SUM(W) Over (Partition by Team order by [Year]) as Rolling_Win_Total, SUM(L) Over (Partition by Team order by [Year]) as Rolling_Loss_Total
from NBAPlayoffs..PLAYOFFTEAMSTATS$

--Most Championships (Player)

Select stat.Player, COUNT(CASE WHEN team.[YEAR] < 2003 and team.W > 14 THEN 1 END) + COUNT(CASE WHEN team.[YEAR] > 2002 and team.W > 15 THEN 1 END) as Championships
from NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PLAYOFFTEAMSTATS$ as team
on stat.Team = team.Abbreviation
and stat.[Year] = team.[Year]
group by stat.Player
order by Championships desc


--Rebounds

--Rebound Leaders (Season)
Select Player, YEAR, OREB, DREB, REB, Min, (OREB/Min) as OREB_per_min, (DREB/Min) as DREB_per_min, (REB/Min) as REB_per_min
from NBAPLAYOFFS..['1996-97$']
where min !=0 and min > 200
group by Player, Year, OREB, DREB, REB, Min
order by OREB_per_min desc

--Free Throws

--Free Throw Career Leaders
Select Player, SUM(FTM), SUM(FTA), (SUM(FTM)/SUM(FTA)) as Career_FT
From NBAPlayoffs..['1996-97$']
where FTA != 0 and FTA > 100
group by Player
order by Career_FT desc

--Highest USG%
Select adv.Player, adv.[Year], adv.GP, adv.[USG%], (stat.PTS)/(stat.GP) as Point_per_Game, (stat.AST/stat.GP) as Assists_per_Game
from NBAPlayoffs..PlayerAdvancedStats$ as adv
join NBAPlayoffs..['1996-97$'] as stat
on adv.PLAYER = stat.Player
and adv.[Year] = stat.[Year]
where stat.[Min] > 100
order by [USG%] desc

--Highest USG% on Championship Winning Team

Select adv.Player, adv.Team, adv.[Year], adv.GP, adv.[USG%], (stat.PTS)/(stat.GP) as Point_per_Game, (stat.AST/stat.GP) as Assists_per_Game
from NBAPlayoffs..PlayerAdvancedStats$ as adv
join NBAPlayoffs..['1996-97$'] as stat
on adv.PLAYER = stat.Player
and adv.[Year] = stat.[Year]
where stat.[Min] > 100
group by adv.Player, adv.Team, adv.[Year], adv.GP, adv.[USG%], (stat.PTS)/(stat.GP), (stat.AST/stat.GP)
having Count(CASE WHEN adv.[YEAR] < 2003 and adv.W > 14 THEN 1 END) + COUNT(CASE WHEN adv.[YEAR] > 2002 and adv.W > 15 THEN 1 END) = 1
order by [USG%] desc

--Assists

Select stat.[Year], stat.Player, stat.AST, stat.TOV, adv.[AST%], adv.[AST/TO]
From NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.[Year] = adv.[Year]
and stat.Player = adv.Player
order by stat.AST desc

--Per Game (Season)
Select stat.[Year], stat.Player, (stat.AST/stat.GP) as AST_per_Game, (stat.TOV/stat.GP) as TOV_per_Game, adv.[AST%], (stat.AST/stat.TOV) as Assist_to_Turnover_Ratio
From NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.[Year] = adv.[Year]
and stat.Player = adv.Player
where stat.GP > 3 and stat.TOV != 0
order by AST_per_Game desc

--AST/TO emphasis
Select stat.[Year], stat.Player, (stat.AST/stat.GP) as AST_per_Game, (stat.TOV/stat.GP) as TOV_per_Game, adv.[AST%], (stat.AST/stat.TOV) as Assist_to_Turnover_Ratio, stat.AST, stat.GP, stat.Min
From NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.[Year] = adv.[Year]
and stat.Player = adv.Player
where stat.Min > 200 and stat.TOV != 0
order by Assist_to_Turnover_Ratio desc

---Amongst 100 Assist Playoff Years
Select stat.[Year], stat.Team, stat.Player, (stat.AST/stat.GP) as AST_per_Game, (stat.TOV/stat.GP) as TOV_per_Game, adv.[AST%], (stat.AST/stat.TOV) as Assist_to_Turnover_Ratio, stat.AST, stat.GP, stat.Min
From NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.[Year] = adv.[Year]
and stat.Player = adv.Player
where stat.AST > 99 and stat.TOV != 0
order by Assist_to_Turnover_Ratio desc


--Career Numbers

Select stat.Player, SUM(stat.AST) as Career_Assists, SUM(stat.TOV) as Career_Turnovers, (SUM(stat.AST)/SUM(stat.TOV)) as Assist_Turnover_Ratio, AVG(adv.[AST%]) as Average_Assist_Percentage
from NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.Player = adv.Player
and stat.[Year] = adv.[Year]
where stat.MIN > 30
group by stat.Player
having SUM(stat.TOV)> 0
order by SUM(AST) desc

--AST/TO emphasis players with at least 500 assists

Select stat.Player, SUM(stat.AST) as Career_Assists, SUM(stat.TOV) as Career_Turnovers, (SUM(stat.AST)/SUM(stat.TOV)) as Assist_Turnover_Ratio, AVG(adv.[AST%]) as Average_Assist_Percentage, MAX(adv.[AST%]) as Max_Assist_Percent, MIN(adv.[AST%]) as Minimum_Assist_Percent
from NBAPlayoffs..['1996-97$'] as stat
join NBAPlayoffs..PlayerAdvancedStats$ as adv
on stat.Player = adv.Player
and stat.[Year] = adv.[Year]
where stat.MIN > 30
group by stat.Player
having SUM(stat.TOV)> 0 and SUM(stat.AST) > 500
order by Assist_Turnover_Ratio desc

--3Point Shooting

Select Player, [Year], Team, [3PM], [3PA], [3P%]
from NBAPlayoffs..['1996-97$']
where [3PA] > 24
order by [3P%] desc


--High Volume Shooters

Select Player, [Year], ([3PM]/GP) as Three_Pointers_Made_pg, ([3PA]/GP) as Three_Pointers_Attempted_pg, [3P%], GP
from NBAPlayoffs..['1996-97$']
where ([3PA]/GP) > 8 and GP > 3
order by [3P%] desc



--Career Numbers

Select Player, (SUM([3PM])/SUM(GP)) as Three_Pointers_Made_pg_Career, (SUM([3PA])/SUM(GP)) as Three_Pointers_Attempted_pg, (SUM([3PM])/SUM([3PA])) as Career_Three_Point_Percentage, SUM(GP) as Career_Games
from NBAPlayoffs..['1996-97$']
group by Player
having SUM([3PA]) != 0 and (SUM([3PA])/SUM(GP)) > 6 and SUM(GP) > 19
order by Career_Three_Point_Percentage desc

-----+/-

Select Player, Team, [Year], SUM([+/-]) as Plus_Minus
from NBAPlayoffs..['1996-97$']
group by Player, Team, [Year]
order by Plus_Minus desc

--+/- Career

Select Player, SUM([+/-]) as Plus_Minus
from NBAPlayoffs..['1996-97$']
group by Player
order by Plus_Minus desc

--+/- Career/per min

Select Player, SUM([MIN]) as total_Minutes, SUM([+/-]) as Plus_Minus, (SUM([+/-])/SUM([MIN])) as Plus_Minus_Per_Minute
from NBAPlayoffs..['1996-97$']
group by Player
having SUM([MIN]) != 0 and SUM([MIN]) > 500
order by Plus_Minus_Per_Minute desc

--+/- Career/ per Game
Select Player, SUM(GP) as Games_Played, SUM([+/-]) as Plus_Minus, (SUM([+/-])/SUM(GP)) as Plus_Minus_Per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM([MIN]) != 0 and SUM([MIN]) > 500
order by Plus_Minus_Per_Game desc

--Disruptors

--Steals in 1 playoff run
select top 20 Player, Team, [YEAR], GP, STL
from NBAPlayoffs..['1996-97$']
order by STL desc

--Blocks in 1 playoff run
select top 20 Player, Team, [YEAR], GP, BLK
from NBAPlayoffs..['1996-97$']
order by BLK desc

--Blocks + steals in 1 playoff run
select top 20 Player, Team, [YEAR], GP, BLK, STL, BLK+STL as Blocks_and_Steals
from NBAPlayoffs..['1996-97$']
order by Blocks_and_Steals desc

--Career Steals

select top 20 Player, SUM(GP) as Games_Played, SUM(STL) as Career_Steals
from NBAPlayoffs..['1996-97$']
group by Player
order by Career_Steals desc

--Career Blocks

select top 20 Player, SUM(GP) as Games_Played, SUM(BLK) as Career_Blocks
from NBAPlayoffs..['1996-97$']
group by Player
order by Career_Blocks desc

--Career Blocks + Steals

select top 20 Player, SUM(GP) as Games_Played, SUM(BLK) as Career_Blocks, SUM(STL) as Career_Steals, SUM(BLK)+SUM(STL) as Career_Blocks_Steals
from NBAPlayoffs..['1996-97$']
group by Player
order by Career_Blocks_Steals desc

--Career Steals per Game
select top 20 Player, SUM(GP) as Games_Played, SUM(STL) as Career_Steals, (SUM(STL)/SUM(GP)) as Steals_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 24
order by Steals_per_Game desc

--50 game minimum
select top 20 Player, SUM(GP) as Games_Played, SUM(STL) as Career_Steals, (SUM(STL)/SUM(GP)) as Steals_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 49
order by Steals_per_Game desc

--100 game minimum
select top 20 Player, SUM(GP) as Games_Played, SUM(STL) as Career_Steals, (SUM(STL)/SUM(GP)) as Steals_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 99
order by Steals_per_Game desc

---Career Blocks per Game

select top 20 Player, SUM(GP) as Games_Played, SUM(BLK) as Career_BLocks, (SUM(BLK)/SUM(GP)) as Blocks_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 24
order by Blocks_per_Game desc

--50 game minimum

select top 20 Player, SUM(GP) as Games_Played, SUM(BLK) as Career_BLocks, (SUM(BLK)/SUM(GP)) as Blocks_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 49
order by Blocks_per_Game desc

--100 game minimum

select top 20 Player, SUM(GP) as Games_Played, SUM(BLK) as Career_BLocks, (SUM(BLK)/SUM(GP)) as Blocks_per_Game
from NBAPlayoffs..['1996-97$']
group by Player
having SUM(GP) > 99
order by Blocks_per_Game desc



---Breakdown by College

Select bio.COLLEGE, COUNT(Distinct stat.Player) as Number_of_Players, SUM(stat.PTS) as Total_Points, SUM(stat.AST) as Total_Assists
from dbo.Sheet1$ as bio
join NBAPlayoffs..['1996-97$'] as stat
on bio.Player = stat.Player
where bio.COLLEGE != 'None'
group by bio.COLLEGE
order by Number_of_Players desc

--Breakdown by Country

Select bio.COUNTRY, COUNT(Distinct stat.Player) as Number_of_Players, SUM(GP) as Games_Played, SUM(stat.PTS) as Total_Points, SUM(stat.AST) as Total_Assists
from dbo.Sheet1$ as bio
join NBAPlayoffs..['1996-97$'] as stat
on bio.Player = stat.Player
where bio.Country != 'USA'
group by bio.COUNTRY
order by Number_of_Players desc

--Career Summaries non-US Players

select stat.Player, bio.COUNTRY, SUM(stat.GP) as Games_Played, SUM(stat.PTS) as Total_Points, SUM(stat.AST) as Total_Assists, SUM(stat.REB) as Total_Rebounds, SUM(stat.STL) as Total_Steals, SUM(stat.BLK) as Total_Blocks, SUM(stat.FGM) as Field_Goals_Made, SUM(stat.FGA) as Field_Goals_Attempted, SUM(stat.[3PM]) as Three_Pointers_Made, SUM(stat.[3PA]) as Three_Points_Attempted, SUM(stat.DD2) as Double_Doubles, SUM(stat.TD3) as Triple_Doubles
from NBAPlayoffs..['1996-97$'] as stat
join Sheet1$ as bio
on stat.Player = bio.Player
where bio.COUNTRY != 'USA'
group by stat.Player, bio.COUNTRY
order by Games_Played desc

--Career Per Game Summaries

select stat.Player, bio.COUNTRY, SUM(stat.GP) as Games_Played, (SUM(stat.PTS)/SUM(stat.GP)) as Total_Points_PG, (SUM(stat.AST)/SUM(stat.GP)) as Total_Assists_PG, (SUM(stat.REB)/SUM(stat.GP)) as Total_Rebounds, (SUM(stat.STL)/SUM(stat.GP)) as Total_Steals_PG, (SUM(stat.BLK)/SUM(stat.GP)) as Total_Blocks_PG, (SUM(stat.FGM)/SUM(stat.GP)) as Field_Goals_Made, (SUM(stat.FGA)/SUM(stat.GP)) as Field_Goals_Attempted, (SUM(stat.[3PM])/SUM(stat.GP)) as Three_Pointers_Made_PG, (SUM(stat.[3PA])/SUM(stat.GP)) as Three_Points_Attempted_PG
from NBAPlayoffs..['1996-97$'] as stat
join Sheet1$ as bio
on stat.Player = bio.Player
where bio.COUNTRY != 'USA'
group by stat.Player, bio.COUNTRY
order by Total_Points_PG desc

--Single Season Summaries non-US Players

select stat.Player, stat.[Year], bio.COUNTRY, stat.GP, stat.PTS, stat.AST, stat.REB, stat.STL, stat.BLK, stat.FGM, stat.FGA, stat.[3PM], stat.[3PA]
from NBAPlayoffs..['1996-97$'] as stat
join Sheet1$ as bio
on stat.Player = bio.Player
where bio.COUNTRY != 'USA'
order by stat.PTS desc


--Single Season Per-Games non-US born Players

select stat.Player, stat.[Year], bio.COUNTRY, stat.GP, (stat.PTS/stat.GP) as PPG, (stat.AST/stat.GP) as APG, (stat.REB/stat.GP) as RPG, (stat.STL/stat.GP) as SPG, (stat.BLK/stat.GP) as BPG, (stat.FGM/stat.GP) as FGMPG, (stat.FGA/stat.GP) as FGAPG, (stat.[3PM]/stat.GP) as [3PMPG], (stat.[3PA]/stat.GP) as [3PAPG]
from NBAPlayoffs..['1996-97$'] as stat
join Sheet1$ as bio
on stat.Player = bio.Player
where bio.COUNTRY != 'USA'
order by PPG desc


--Breakdown by Draft Year

Select bio.[DRAFT YEAR], SUM(GP) as Games_Played, SUM(stat.PTS) as Total_Points, SUM(stat.AST) as Total_Assists
from dbo.Sheet1$ as bio
join NBAPlayoffs..['1996-97$'] as stat
on bio.Player = stat.Player
where bio.[DRAFT YEAR] > 1996 and bio.[DRAFT YEAR] != 19995
group by bio.[DRAFT YEAR]
order by Games_Played desc

