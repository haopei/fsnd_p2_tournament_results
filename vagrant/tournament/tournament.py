#!/usr/bin/env python
#
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2


def connect():
    """Connect to the PostgreSQL database. Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""

    conn = connect()
    c = conn.cursor()
    c.execute('DELETE FROM matches;')
    conn.commit()
    conn.close()


def deletePlayers():
    """Remove all the player records from the database."""

    conn = connect()
    c = conn.cursor()
    c.execute('DELETE FROM players;')
    conn.commit()
    conn.close()
    return


def countPlayers():
    """Returns the number of players currently registered."""

    conn = connect()
    c = conn.cursor()
    c.execute('SELECT count(*) FROM players;')
    result = c.fetchone()[0]
    conn.close()
    return result


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """

    conn = connect()
    c = conn.cursor()
    c.execute('INSERT INTO players (name) VALUES (%s)', (name,))
    conn.commit()
    conn.close()
    return


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place,
    or a player tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """

    conn = connect()
    c = conn.cursor()
    c.execute('SELECT * FROM player_standings;')
    result = c.fetchall()
    conn.close()

    return result


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """

    conn = connect()
    c = conn.cursor()
    c.execute('INSERT INTO matches (winner, loser) VALUES (%s, %s)', (winner, loser))
    conn.commit()
    conn.close()
    return


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """

    conn = connect()
    c = conn.cursor()

    c.execute('SELECT * FROM swiss_pairing;')
    result = c.fetchall()
    conn.close()
    return result


# Extras
#   The three functions below is used for test #9.
def castVote(voter, candidate):
    """Records a player's vote casted for the Player of the Tournament award.

    Args:
        voter: the id of the player who casts the vote
        candidate: the id of the player for whom the voted is casted
    """

    conn = connect()
    c = conn.cursor()
    c.execute('INSERT INTO votes (voter, candidate) VALUES (%s, %s);', (voter, candidate))
    conn.commit()
    conn.close()


def deleteVotes():
    """Remove all the vote records from the database.
        Vote records are used to determine the winner of
        the Player of the Tournament award.
    """

    conn = connect()
    c = conn.cursor()
    c.execute('DELETE FROM votes;')
    conn.commit()
    conn.close()
    return


def getAwardWinner():
    """Returns the winner of the Player of the Tournament award

    In a tournament, participant players may cast a vote for whom
    they believe is an exemplery player of the game. The winner
    of the award is one who exhibited outstanding game ethics.
    """

    conn = connect()
    c = conn.cursor()
    query = """
        SELECT candidate, count(*)
        AS vote_count
        FROM votes
        GROUP BY candidate
        ORDER BY vote_count desc
        LIMIT 1;"""
    c.execute(query)
    result = c.fetchone()[0]
    conn.commit()
    conn.close()
    return result
