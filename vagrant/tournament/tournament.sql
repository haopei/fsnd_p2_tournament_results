-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


create database tournament;

-- Connect to the database
\c tournament


-- Players table: records player identity
create table players (
  id serial primary key,
  name text
);

-- Matches table: records match results
create table matches (
  id serial primary key,
  winner integer references players (id),
  loser integer references players (id)
);


-- Votes table: records player votes
create table votes (
  id serial primary key,
  voter integer references players (id),
  candidate integer references players (id)
);


-- Returns the number of matches played, per player
create view player_match_count AS
  select
    players.id,
    count(*) as match_count
  from players join matches
  on players.id = matches.winner OR players.id = matches.loser
  group by players.id;


-- Returns the number of matches won, per player
create view player_win_count as
  select
    players.id,
    count(*) as win_count
  from players join matches
  on players.id = matches.winner
  group by players.id;


-- Returns the number of matches lost, per player
create view player_lose_count as
  select
    players.id,
    count(*) as lose_count
  from  players join matches
  on players.id = matches.loser
  group by players.id;




-- Returns each player's win count and match count
--   Dependencies: player_win_count, player_match_count
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


-- Returns every odd row of player_standings
-- used for swiss_pairing view
create view standings_odd as
  select *
  from (
      select player_id, player_name, win_count, row_number() over (order by win_count) as rownum
      from player_standings
    ) as t
  where t.rownum % 2 = 0
  order by win_count desc;


-- Returns every even row of player_standings
-- used for swiss_pairing view
create view standings_even as
  select *
  from (
      select player_id, player_name, win_count, row_number() over (order by win_count) as rownum
      from player_standings
    ) as t
  where t.rownum % 2 != 0
  order by win_count desc;


-- Returns the matchup of players with similar number of wins
--   Dependencies: standings_odd, standings_even
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
