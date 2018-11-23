/**
 * This is a simulation of a tic-tac-toe game.
 */

#include <iostream>
#include <fstream>
#include <set>
#include<string>
#include <algorithm>

using namespace std;

/**
 * The file (descriptor) in which the results of the simulation wil be stored.
 */
ofstream myFile, nodes;
/**
 * A set that contains all the actual played games, without symetries.
 */
set<string> playedGames;
/**
 * Permutations ofr checing the symetries in the game in function is_played(string const).
 */
int perm[2][4] = {{0, 6, 8, 2}, {1, 3, 7, 5}};

/**
 * Check whether the current game is finished (one of the players won) or not.
 * @param  game The current state of the board, as a string of 9 caracters, with knots and crosses for the moves played and dots for empty boxes.
 * @return      A boolean state at True if one of the players won the game.
 */
bool is_won( string const game ) {
	// lines
	for( int i = 0; i < 9; i+=3 ) {
		if( game[i] != '.' && game[i+1] == game[i] && game[i+2] == game[i] ) {
			return true;
		}
	}

	// columns
	for( int i = 0; i < 3; ++i ) {
		if( game[i] != '.' && game[i+3] == game[i] && game[i+6] == game[i] ) {
			return true;
		}
	}

	// diagonal
	if( game[0] != '.' && game[4] == game[0] && game[8] == game[0] ) {
		return true;
	}
	if( game[2] != '.' && game[4] == game[2] && game[6] == game[2] ) {
		return true;
	}
	return false;
}

/**
 * Checks if a symetry on the current game gives a game that has already been played.
 * @param  game The current state of the board, as a string of 9 caracters, with knots and crosses for the moves played and dots for empty boxes.
 * @return      True if an already played symetry has been found, False otherwise.
 */
string is_played( string const game ) {
	string symetric = game;
	char tmp;
	int it, jt;

	// Rotation -(i+1)*pi/2
	for( int i = 0; i < 4; ++i ) {
		for( it = 0; it < 2; ++it ) {
			tmp = symetric[perm[it][0]];
			for( jt = 0; jt < 3; ++jt ) {
				symetric[perm[it][jt]] = symetric[perm[it][jt+1]];
			}
			symetric[perm[it][jt]] = tmp;
		}
		if( playedGames.find(symetric) != playedGames.end() ) {
			return *(playedGames.find(symetric));
		}
	}

	// Vertical symetries
	symetric = game; // Shouldn't be necessary, as the rotations already lead to the case where we are back to the original game
	for( int i = 0; i < 9; i += 3 ) {
		tmp = symetric[i];
		symetric[i] = symetric[i + 2];
		symetric[i + 2] = tmp;
	}
	if( playedGames.find(symetric) != playedGames.end() ) {
		return *(playedGames.find(symetric));
	}

	// Horizontal symetries
	symetric = game;
	for( int i = 0; i < 3; ++i ) {
		tmp = symetric[i];
		symetric[i] = symetric[i + 6];
		symetric[i + 6] = tmp;
	}
	if( playedGames.find(symetric) != playedGames.end() ) {
		return *(playedGames.find(symetric));
	}

	// First diagonal
	symetric = game;
	for( int i = 0; i < 3; ++i ) {
		for( int j = 0; j < i; ++j ) {
			tmp = symetric[i + 3 * j];
			symetric[i + 3 * j] = symetric[ j + 3 * i ];
			symetric[ j + 3 * i ] = tmp;
		}
	}
	if( playedGames.find(symetric) != playedGames.end() ) {
		return *(playedGames.find(symetric));
	}

	// Second diagonal
	symetric = game;
	for( int j = 0; j < 3; ++j ) {
		for( int i = 0; i < 2 - j; ++i ) {
			tmp = symetric[i + 3 * j];
			symetric[i + 3 * j] = symetric[ (2 - j) + 3 * (2 - i) ];
			symetric[ (2 - j) + 3 * (2 - i) ] = tmp;
		}
	}
	if( playedGames.find(symetric) != playedGames.end() ) {
		return *(playedGames.find(symetric));
	}

	return "";
}

/**
 * Recursive function that simulates both the moves of two players and all the possible tic-tac-toe games.
 * Players add a cross or a knot one after another until the board is full or one of them has won. In either case the function stops calling itself, thus going back in time and when the players can try a different move.
 * @param	turn	The turn number of the current game. Used in order to present the results in a nice way with a tabulation for each turn.
 *          game	The current state of the board, as a string of 9 caracters, with knots and crosses for the moves played and dots for empty boxes.
 *          p		The box index of the current play. Is set to -1 at the beginning of the simulation.
 *          c		The character (knot 'o' or cross 'x') of the current play at the box of index p. The character depends on the value of turn.
 *          moves	The boxes that have been played, as an array of 9 nodes with indeex from 0 to 9 when the box is empty and -1 when it has been filled.
 */
void play( int turn, string game, int const p, char const c, char moves[9] ) {
	bool isWon;
	string isPlayed, toWrite;

	if( p != -1 ) {
		game[p] = c;
	}

	isWon = is_won(game);
	isPlayed = is_played(game);
	toWrite = ((isWon)? (char)(c-32): ((turn >= 9)? 'C': '_')) + ((isPlayed == "")? game: isPlayed);

	for( int j = 0; j < turn; ++j ) {
		myFile << "\t";
	}
	myFile << ((turn != 0)? "|-": "") << toWrite;

	if(isPlayed == "") {
		playedGames.insert(game);
	}

	if( turn < 9 && !isWon ) {
		for( int i = 0; i < 9; ++i ) {
			if( moves[i] != -1 ) {
				moves[i] = -1;
				play( turn + 1, game, i, (c == 'x')? 'o': 'x', moves );
				moves[i] = i;
			}
		}
	}
}

/**
 * Initializes the game, the file descriptor to store the results of the simulation.
 * Launches the simulation.
 * 
 * @return 0 if the simulation went well.
 */
int main( void ) {
	/**
	 * The state of the game. Each dot represents a free box.
	 */
	string game =	".........\n";
	/**
	 * The moves empty boxes of the board, represented by their index number in the game string, and the played boxes, represented by -1.
	 */
	char moves[9] = {	0, 1, 2,
						3, 4, 5,
						6, 7, 8
					};
	int XWinningNodes = 0,
		OWinningNodes = 0,
		unwiningNodes = 0,
		twoPlaysGames = 0;

	// Playing the games
	myFile.open( "graph.txt" );
	play( 0, game, -1, 'o', moves );
	myFile.close();

	// Some statistics
	cout << "Number of nodes: " << playedGames.size() << endl;
	cout << "### Number of winning (X and O) and unwinning (U) nodes ###\n";
	nodes.open( "nodes.txt" );
	for( set<string>::iterator it = playedGames.begin(); it != playedGames.end(); ++it ) {
		nodes << *it;
		if( is_won(*it) ) {
			if( count( (*it).begin(), (*it).end(), '.' ) % 2 == 0 ) {
				++XWinningNodes;
			} else {
				++OWinningNodes;
			}
		} else {
			++unwiningNodes;
		}
	}
	nodes.close();
	cout << "\tX: " << XWinningNodes << endl << "\tO: " << OWinningNodes << endl << "\tU: " << unwiningNodes << endl;

	return 0;
}