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
    return


def deleteVotes():
    """Remove all vote records from the database."""
    conn = connect()
    c = conn.cursor()
    # c.execute('DELETE FROM votes;')
    conn.commit()
    conn.close()
    return


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
    c.execute('SELECT count(*) AS registered_players FROM players;')
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
    c.execute('INSERT INTO players(name) VALUES(%s)', (name,))
    conn.commit()
    conn.close()
    return


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """

    conn = connect()
    c = conn.cursor()
    c.execute('SELECT * FROM winners;')
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

    # create row in match table
    c.execute('INSERT INTO matches (winner, loser) VALUES (%s, %s)', (winner, loser,))

    # update each player's match count
    c.execute('UPDATE players SET matches = matches + 1 WHERE id = %s OR id = %s', (winner, loser,))

    # update winner's win count
    c.execute('UPDATE players SET wins = wins + 1 WHERE id = %s', (winner,))

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
    c.execute('SELECT * FROM same_wins;')
    result = c.fetchall()
    conn.close()
    return result


def castVote(voter_id, candidate_id):
    """Records a player's vote for whom he endorses for the 'Player of the Tournament' award.

    Args:
        voter: the id of the player who is voting
        candidate: the id of the player candidate who receives the vote
    """

    conn = connect()
    c = conn.cursor()
    c.execute('INSERT INTO votes (voter_id, candidate_id) VALUES (%s, %s)', (voter_id, candidate_id,))
    conn.commit()
    conn.close()
    return


def getPlayerOfTheTournament():
    """Returns the player with the highest count of votes casted by tournament participants.
        After the tournament, all participants vote on a 'Player of the Tournament'.
    """

    conn = connect()
    c = conn.cursor()
    c.execute('SELECT candidate_id, count(candidate_id) AS vote_count FROM vote_tally GROUP BY candidate_id ORDER BY vote_count DESC LIMIT 1;')
    result = c.fetchone()[0]
    conn.commit()
    conn.close()
    return result
