-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


CREATE DATABASE tournament;

-- Connect to the database
\c tournament


-- Players table: records player identity
CREATE TABLE players (
  id serial PRIMARY KEY,
  name text
);

-- Matches table: records match results
CREATE TABLE matches (
  id serial PRIMARY KEY,
  winner integer REFERENCES players (id),
  loser integer REFERENCES players (id)
);


-- Votes table: records player votes
CREATE TABLE votes (
  id serial PRIMARY KEY,
  voter integer REFERENCES players (id),
  candidate integer REFERENCES players (id)
);


-- Returns the number of matches played, per player
CREATE VIEW player_match_count AS
  SELECT
    players.id,
    count(*) AS match_count
  FROM players JOIN matches
    ON players.id = matches.winner
    OR players.id = matches.loser
  GROUP BY players.id;


-- Returns the number of matches won, per player
CREATE VIEW player_win_count AS
  SELECT
    players.id,
    count(*) AS win_count
  FROM players join matches
  ON players.id = matches.winner
  GROUP BY players.id;


-- Returns the number of matches lost, per player
CREATE VIEW player_lose_count AS
  SELECT
    players.id,
    count(*) AS lose_count
  FROM players join matches
  ON players.id = matches.loser
  GROUP BY players.id;


-- Returns each player's win count and match count
--   Dependencies: player_win_count, player_match_count
CREATE VIEW player_standings AS
  SELECT
    players.id AS player_id,
    players.name AS player_name,
    COALESCE(player_win_count.win_count, (0)) AS win_count,
    COALESCE(player_match_count.match_count, (0)) AS match_count
  FROM
    players
      LEFT JOIN player_match_count
        ON players.id = player_match_count.id
      LEFT JOIN player_win_count
        ON player_match_count.id = player_win_count.id
  ORDER BY win_count DESC;


-- Returns every odd row of player_standings
--   used for swiss_pairing view
CREATE VIEW standings_odd AS
  SELECT *
  FROM (
      SELECT player_id, player_name, win_count, row_number() over (order by win_count) as rownum
      FROM player_standings
    ) AS t
  WHERE t.rownum % 2 = 0
  ORDER BY win_count DESC;


-- Returns every even row of player_standings
--   used for swiss_pairing view
CREATE VIEW standings_even AS
  SELECT *
  FROM (
      SELECT player_id, player_name, win_count, row_number() over (ORDER BY win_count) AS rownum
      FROM player_standings
    ) AS t
  WHERE t.rownum % 2 != 0
  ORDER BY win_count DESC;


-- Returns the matchup of players with similar number of wins
--   Assumes an even number of players.
--   Dependencies: standings_odd, standings_even
CREATE VIEW swiss_pairing AS
  SELECT
    even.player_id AS p1,
    even.player_name AS name1,
    odd.player_id AS p2,
    odd.player_name AS name2
  FROM (
    SELECT *, row_number() over (ORDER BY win_count) AS row_number FROM standings_even) AS even
  JOIN (
    SELECT *, row_number() over (ORDER BY win_count) AS row_number FROM standings_odd) AS odd
  ON even.row_number = odd.row_number;
