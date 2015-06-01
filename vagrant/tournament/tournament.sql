-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


create database tournament;

\c tournament

create table players (
  id serial primary key,
  name text
);

create table matches (
  id serial primary key,
  winner integer references players (id),
  loser integer references players (id)
);



create view player_match_count AS
  select
    players.id,
    count(*) as match_count
  from players join matches
  on players.id = matches.winner OR players.id = matches.loser
  group by players.id;


create view player_win_count as
  select
    players.id,
    count(*) as win_count
  from players join matches
  on players.id = matches.winner
  group by players.id;

create view player_lose_count as
  select
    players.id,
    count(*) as lose_count
  from  players join matches
  on players.id = matches.loser
  group by players.id;



  -- so we got the match count and win count for all players, via the two views above. Now, we can join these two views with
  -- the player table to achieve the overall standings info!!!!!!!!

create view player_standings as
  select
    players.id as player_id,
    players.name as player_name,
    COALESCE(player_win_count.win_count, (0)) as win_count,
    COALESCE(player_match_count.match_count, (0)) as match_count
  from
    players
      left join player_match_count
        on players.id = player_match_count.id
      left join player_win_count
        on player_match_count.id = player_win_count.id
  order by win_count desc;

-- select every nth row in player_standings
create view standings_odd as
  select *
  from (
      select player_id, player_name, win_count, row_number() over (order by win_count) as rownum
      from player_standings
    ) as t
  where t.rownum % 2 = 0
  order by win_count desc;

-- select every nth row in player_standings
create view standings_even as
  select *
  from (
      select player_id, player_name, win_count, row_number() over (order by win_count) as rownum
      from player_standings
    ) as t
  where t.rownum % 2 != 0
  order by win_count desc;


-- swisspairing
create view swiss_pairing as
  select
    even.player_id as p1,
    even.player_name as name1,
    odd.player_id as p2,
    odd.player_name as name2
  from
    (
      select *, row_number() over (order by win_count) as row_number from standings_even) as even
    join
    (
      select *, row_number() over (order by win_count) as row_number from standings_odd) as odd
  on even.row_number = odd.row_number;


-- SELECT
--   id,
--   name,
--   (SELECT count(*) FROM matches WHERE players.id = matches.winner) AS wins,
--   (SELECT count(*) FROM matches WHERE players.id = matches.winner OR players.id = matches.loser) AS matches
-- FROM players
-- ORDER BY wins DESC;

-- CREATE VIEW player_wins AS
--   SELECT winner AS player_id,
--          COUNT(*) AS wins
--   FROM matches
--   GROUP BY winner;
