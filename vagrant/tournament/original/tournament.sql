-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;


-- Connect to the database
\c tournament;


-- Table: Players
--  shows each player's matches and wins
CREATE TABLE players (
  id serial PRIMARY KEY,
  name text
);


-- Table: Matches
--  records the winner and loser of each match.
CREATE TABLE matches (
  id serial PRIMARY KEY,
  loser integer REFERENCES players (id),
  winner integer REFERENCES players (id)
);

create view players_match_count as
  select matches.winner, matches.loser
  from matches;



-- self join matches to get list of all players


-- list of losers
-- create view losers as
--   select
--     players.id as id,
--     players.name as name
--   from players join matches
--   on players.id = matches.loser;


-- list of winners
create view winners as
  select
    players.id as id,
    players.name as name,
    count(players.id) as win_count
  from players left join matches
  on players.id = matches.winner
  group by players.id;

-- create view winners AS
--   select
--     players.id as id,
--     players.name as winner_name,
--     count(players.id) as wins,
--     count(matches.id) as match_count
--   from players left join matches
--   on players.id = matches.winner
--   group by players.id;
