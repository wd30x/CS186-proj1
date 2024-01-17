-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  from people
  where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  from people p
  where namefirst like '% %'
  order by namefirst asc, namelast asc
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  select birthyear, avg(height), count(playerid)
  from people
  group by birthyear
  order by birthyear asc
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  select birthyear, avg(height), count(playerid)
  from people
  group by birthyear
  having avg(height) > 70
  order by birthyear asc
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  select p.namefirst,p.namelast,h.playerid,h.yearid
  from halloffame h
  inner join people p
  on h.playerid = p.playerid
  where h.inducted = 'Y'
  order by yearid desc, h.playerid asc
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  with t as (
    select *
    from halloffame h
    inner join people p
    on h.playerid = p.playerid
    where h.inducted = 'Y'
  ) 
  select namefirst,namelast,t.playerid,c.schoolid,yearid
  from t
  inner join collegeplaying c
  on t.playerid = c.playerid
  where schoolid in 
    (select schoolid from schools where
      schoolstate = 'CA')
  order by yearid desc, c.schoolid asc, t.playerid asc
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  with t as (
    select *
    from halloffame h
    inner join people p
    on h.playerid = p.playerid
    where h.inducted = 'Y'
  ) 
  select t.playerid,namefirst,namelast,c.schoolid
  from t
  left join collegeplaying c
  on t.playerid = c.playerid
  order by t.playerid desc, c.schoolid asc
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  select b.playerid, namefirst, namelast, yearid,
    cast((h - h2b - h3b - hr)+(2*h2b)+(3*h3b)+(4*hr) as real)/ab as slg
  from batting b
  left join people p
  on b.playerid = p.playerid
  where ab > 50
  order by slg desc, yearid asc, b.playerid asc
  limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  with t as (
    select playerid,
            sum(h) as th,
            sum(h2b) as th2b,
            sum(h3b) as th3b,
            sum(hr) as thr, 
            sum(ab) as tab
    from batting
    group by playerid
    having tab > 50
  ) 
  select t.playerid, namefirst, namelast,
    cast((th-th2b-th3b-thr)+(2*th2b)+(3*th3b)+(4*thr) as real)/tab as slg
  from t
  left join people p
  on t.playerid = p.playerid
  order by slg desc,t.playerid asc
  limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  with t as (
    select playerid,
            sum(h) as th,
            sum(h2b) as th2b,
            sum(h3b) as th3b,
            sum(hr) as thr, 
            sum(ab) as tab
    from batting
    group by playerid
    having tab > 50
  ) 
  select namefirst, namelast,
    cast((th-th2b-th3b-thr)+(2*th2b)+(3*th3b)+(4*thr) as real)/tab as slg
  from t
  left join people p
  on t.playerid = p.playerid
  where slg > (select cast((th-th2b-th3b-thr)+(2*th2b)+(3*th3b)+(4*thr) as real)/tab
              from t
              where playerid = 'mayswi01')
  order by slg desc,t.playerid asc
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  select yearid,min(salary),max(salary),avg(salary)
  from salaries
  group by yearid
  order by yearid asc
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS

;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  with t1 as (
    select yearid,min(salary) as mi,max(salary) as ma,avg(salary) as av
    from salaries
    group by yearid
  ),
  t2 as (
    select  
      yearid, 
      lag(mi, 1) OVER (order BY yearid) a,
      lag(ma, 1) OVER (order BY yearid) b,
      lag(av, 1) OVER (order BY yearid) c
    from t1
  )
  select t1.yearid, mi-a,ma-b,av-c
  from t1,t2
  where t1.yearid = t2.yearid
  limit -1 offset 1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  with t as (
    select p.playerid, namefirst, namelast, salary, yearid
    from people p
    inner join salaries s
    on p.playerid = s.playerid
  )
  select playerid, namefirst, namelast, salary, yearid
  from t
  where (yearid = '2000' and salary = 
    (select max(salary) from t where yearid = '2000'))
  or (yearid = '2001' and salary = 
    (select max(salary) from t where yearid = '2001'))
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  with t as (
    select a.teamid,salary
    from allstarfull a
    inner join salaries s
    on a.playerid = s.playerid
    where a.yearid = '2016'
    and s.yearid = '2016'
  ),
  t1 as (
  select teamid,max(salary) as hi
  from t
  group by teamid
  ),
  t2 as (
  select teamid,min(salary) as lo
  from t
  group by teamid
  )
  select t1.teamid,hi-lo
  from t1,t2
  where t1.teamid = t2.teamid
;

