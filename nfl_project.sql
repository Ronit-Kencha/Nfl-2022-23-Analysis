select n.teamName, 
	SUM(d.sk) AS sacks,
	SUM(d.tfl) AS tfl,
	SUM(d.qbHits) AS qbHits,
	ROUND((AVG(n.teamWins)/17), 3) * 100 AS win_percentage
from nfl n
JOIN defStats d
ON n.teamId = d.tmId
GROUP BY n.teamName
ORDER BY sacks DESC, tfl DESC, qbHits DESC;
/*Multiple teams have same number of sacks, like 5 teams have 44 sacks and 5 have 40 and so on. The 10th most sacks for a team is 38
and 12 of the teams out of 22 who have atleast 38 sacks have over a 50% win rate showing that getting pressure and sacking the quarterback
has an impact on the overall teams performance. Moreover, the best teams in the league with the highest win percentage, Chiefs and Eagles,
have the most sacks in the league. The great teams are consistent across the board with the sacks, tackles for losses, and qbhits.*/

SELECT n.teamName,
	SUM(r.rshAtt) AS rushAttempts,
	SUM(r.rshYds) AS rushYards,
	ROUND((SUM(r.rshYds)/SUM(rshAtt)), 2) AS rushYdsPerAtt,
	SUM(r.rshTdS) AS rushTds,
	SUM(r.recTgt) as targets,
	SUM(r.rec) AS receptions,
	SUM(r.recYds) AS receivingYards,
	ROUND((SUM(r.recYds)/SUM(r.rec)), 2) AS recYdsPerAtt,
	SUM(r.recTds) AS receivingTds,
	SUM(r.rshYds) + SUM(recYds) AS scrimmageYards,
	ROUND(AVG(r.scmYds), 2) AS scrimmageYardsPerGame,
	SUM(totTds) AS totalTds,
	SUM(totFmb) AS totalFumbles,
	ROUND((AVG(n.teamWins)/17), 3) * 100 AS win_percentage
FROM nfl n
JOIN rshAndRecStats r 
	ON n.teamId = r.tmId
GROUP BY n.teamName
ORDER BY receivingYards DESC;
/*9 of the top 10 teams with the most receiving yards have an over 50% win percentage, and this shows that in the modern nfl, having good
receivers along with a good quarterback to throw them the ball play a really big part in how well the team is going to do.*/

/*Analyize qb's quality of play and efficiency and how it correlates with team performance*/
WITH qb_1 AS 
(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY s.tmId ORDER BY s.att DESC) AS row_n
	FROM passingStats s
)
SELECT n.teamName,
	q.name,
	q.adjNetYdsPerAtt,
	ROUND((q.gamesWon)/(q.gamesPlayed), 3) * 100 AS win_percentage
FROM nfl n
JOIN qb_1 q
	ON n.teamId = q.tmId
WHERE row_n = 1
ORDER BY adjNetYdsPerAtt DESC;
/*Adjusted Net Yards Per Attempt, or AY/A, is a statistic that measures the average yardage of a quarterback's passing attempts while accounting
for touchdowns and interceptions. It places weight on touchdowns and interceptions, thus making it a key metric that can show the efficiency
and quality play of a quarterback. Looking at the results of this query, we can see that the median AY/A for starting qbs is 6.1 and the mean
is 6.05, which can be rounded up to 6.1 for analysis purposes. There are 17 qbs with a AY/A with atleast 6.1 and of those 17, 14 of them had a
win percentage of over 50%. On the other hand, of the bottom 15 AY/A, only 3 qbs had a winning record, and those teams had a excellent defense
or running games to overcome the qb shortcomings. This proves that the quarterback's quality of play and efficiency plays a very huge part
in how well the team does.*/

SELECT n.teamName,
	t.scPcnt,
	t.toPcnt,
	ROUND((n.teamWins/17), 3) * 100 AS win_percentage
FROM nfl n
JOIN teamStatistics t ON n.teamId = t.teamId
ORDER BY scPcnt DESC, toPcnt;
/*This query shows the scoring percentage and turnover percentage for each team. Scoring percentage is the percentage of drives that ended in 
an offensive score, whereas turnover percentage is the percentage of drives that ended in an offensive turnover. This analysis shows that a high
scoring percentage usually means that the team is good and a high turnover percentage means that the team is bad. There are some outliers, like
the Buffalo Bills who have a high turnover percentage, but they have the second highest scoring percentage to offset that to have a win percentage
of over 76%. This analysis shows that to be a good team, you have to limit the amount of turnovers you have throughout the season, and more 
importantly, have posessions that end in some points getting on the board.*/

WITH qb_1 AS 
(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY s.tmId ORDER BY s.att DESC) AS row_n
	FROM passingStats s
)
SELECT n.teamName,
	q.name,
	q.att,
	ROUND((q.comp)/(q.att), 3) * 100 AS completion_pct,
	q.tds,
	q.interceptions,
	q.qbRating,
	q.totalQBR,
	q.fourthQComebacks,
	q.gameWinningDrives,
	ROUND((q.gamesWon)/(q.gamesPlayed), 3)* 100 AS qb_win_percentage
FROM nfl n 
JOIN qb_1 q 
	ON n.teamId = q.tmId
WHERE row_n = 1
ORDER BY totalQBR DESC;

WITH qb_1 AS 
(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY s.tmId ORDER BY s.att DESC) AS row_n
	FROM passingStats s
)
SELECT n.teamName,
	q.name,
	q.totalQBR,
	q.totalQBR,
	ROUND((q.gamesWon)/(q.gamesPlayed), 3) * 100 AS qb_win_percentage
FROM nfl n
JOIN qb_1 q
	ON n.teamId = q.tmId
WHERE row_n = 1