This is a simple project that aims at computing the minimal number of games for a Tic-Tac-Toe.

After having searched on the internet, it appeared that there is no document for this simple question: taking into account the symetries of the game, what is the minimal number of games one can extract from the Tic-Tac-Toe tree of possibilities?

Also, what is the graph of all the possible games ?

The code divides in two parts: the simulation part, that generates all the possible games (modulo the symetries), written in ++c, and the drawing part, in python, that uses [graph_tool](https://graph-tool.skewed.de/).