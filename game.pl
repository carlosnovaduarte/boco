:- include('board1.pl').
:- include('internalstructure.pl').

% Starts the game, printing an empty board
% Need to provide the size of the map (rows and columns)
start:-
    bocoStructure(X),
    print_board(X, 1).