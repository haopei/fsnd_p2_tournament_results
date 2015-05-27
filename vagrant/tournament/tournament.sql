-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


CREATE DATABASE tournament;


-- Connect to the database
\c tournament;


-- Table: Players
--  shows each player's matches and wins
CREATE TABLE players (
  id serial PRIMARY KEY,
  name text,
  matches integer default 0,
  wins integer default 0
);


-- Table: Matches
--  records the winner and loser of each match.
CREATE TABLE matches (
  id serial PRIMARY KEY,
  loser integer REFERENCES players (id),
  winner integer REFERENCES players (id)
);


-- Table: Votes
--  shows each player's vote for sportsmanship award
CREATE TABLE votes (
  id serial PRIMARY KEY,
  voter_id integer REFERENCES players (id),
  candidate_id integer REFERENCES players (id)
);


--  shows total votes per candidate
CREATE VIEW vote_tally AS
  SELECT players.name, votes.candidate_id, votes.voter_id
  FROM players join votes
  ON players.id = votes.candidate_id;


-- Returns a list
--  of pairs of players
--  who have the same number of wins.
--  Used by swissPairing()
CREATE VIEW same_wins AS
  SELECT
    players.id AS p1_id,
    players.name AS p1_name,
    players_2.id AS p2_id,
    players_2.name AS p2_name
  FROM players
  LEFT JOIN players players_2
  ON players.wins = players_2.wins
  WHERE players.id > players_2.id;  -- prevents pairing of the same player
