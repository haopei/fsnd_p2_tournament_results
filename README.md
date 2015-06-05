# FSND P2 Tournament Results

## How to Run

 1. On Terminal, run `cd vagrant`.
 2. Run `vagrant up`, then `vagrant ssh` to start up the Vagrant VM.
 3. `cd` into `/vagrant` (sync folder)
 4. Run `psql`, followed by `\i tournament/tournament.sql` to build and access the database
 5. Exit `psql` cli with `\q1` and run tests with `python tournament/tournament_test.py`

## Views

| View Name | columns | Description |
| --------- | ------- | ----------- |
| player_match_count | player_id, match_count | Returns the number of matches played, per player |
| player_win_count | player_id, win_count |
| player_lose_count | player_id, lose_count |
| player_standings | player_id, player_name, win_count, match_count |
| standings_odd | player_id, player_name, win_count, rownum | Returns odd rows from player_standings |
| standings_even | player_id, player_name, win_count, rownum | Returns even rows from player_standings |
| swiss_pairing | p1, name1, p2, name2 | Returns the matchup of payers with similar number of wins |


## Swiss Pairings

The `swiss_pairing` view is used to generate the swiss pairing, and depends on the `standings_even` and `standings_odd` views, which subsequently depends on the `player_standings` view.


The `player_standings` view returns a list of players ordered by their number of wins.

| player_id | player_name | win_count | match_count |
| --------- | ----------- | --------- | ----------- |
| 1 | Bruno | 4 | 6 |
| 2 | Cathy | 3 | 6 |
| 3 | Boots | 2 | 6 |
| 4 | Diane | 1 | 6 |

This means that every two players in sequence is an appropriate pair of opponents for the `swiss_pairing`. In the above example, ideally Bruno is paired with Cathy, while Boots is paired with Diane for the next round.

The standings_odd and standings_even views divide the `player_standings` according to their even/odd nth position.

`select * from standings_odd`

| player_id | player_name | win_count | rownum |
| --------- | ----------- | --------- | ------ |
| 1 | Bruno | 4 | 1 |
| 3 | Boots | 2 | 3 |

`select * from standings_even`

| player_id | player_name | win_count | rownum |
| --------- | ----------- | --------- | ------ |
| 2 | Cathy | 3 | 2 |
| 4 | Diane | 1 | 4 |

Finally, to return the swiss pairing, we join `standings_odd` and `standings_even` pair the players according to their corresponding nth row. For example, both Bruno and Cathy are the 1st row in their respective tables, while Boots and Diane are in the 2nd row.

## Extra Test: Voting for Player of the Tournament

Players may cast a single vote for another player, besides himself/herself, to be the "Player of the Tournament". This involves the following additional functions:

| Function | Description |
| -------- | ----------- |
| `castVote(voter, candidate)` | Records a voter's vote and the candidate for whom he/she votes. |
| `getAwardWinner()` | Returns the player id with the most votes, i.e. the Player of the Tournament winner |
| `testAwardWinner()` | Tests if the award winner is returned correctly. |
