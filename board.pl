:- use_module(library(ansi_term)).
:- use_module(library(lists)).
:- include('internalstructure.pl').

print_board([], Row) :-
    print_horizontalLine(Row),
    nl.

print_board([H|T], Row) :-
    print_horizontalLine(Row),
    nl,
    Col is 1,
    print_row(H, Row, Col),
    nl,
    Row2 is Row+1,
    print_board(T, Row2).

print_row([], _, _) :-
    write('|').

print_row([H|T], Row, Col) :-
    print_verticalLine(Row, Col),
    print_cell(H, Row, Col),
    Col2 is Col+1,
    print_row(T, Row, Col2).

print_horizontalLine(1) :-
    write('    | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10 |'),
    nl,
    write(---------------------------------------------).

print_horizontalLine(2) :-
    write('-----   -------------------------------------').

print_horizontalLine(10) :-
    write('-----------------------------------------    ').

print_horizontalLine(Row) :-
    (   Row==6
    ;   Row==11
    ),
    write(---------------------------------------------).

print_horizontalLine(Row) :-
    Row\=1,
    Row\=2,
    Row\=6,
    Row\=10,
    Row\=11,
    write('-----   ---------------------------------    ').

print_verticalLine(10, 1) :-
    write(' 10 |').

print_verticalLine(Row, 1) :-
    write('  '),
    write(Row),
    write(' |').

print_verticalLine(1, Col) :-
    (   Col==2
    ;   Col==6
    ),
    write('|').

print_verticalLine(10, Col) :-
    (   Col==6
    ;   Col==10
    ),
    write('|').

print_verticalLine(Row, _) :-
    Row\=1,
    Row\=10,
    write('|').

print_verticalLine(_, _).

print_cell([H|T], 1, Col) :-
    Col\=1,
    Col\=5,
    Col\=10,
    print_character(H, T),
    write(' ').

print_cell([H|T], 10, Col) :-
    Col\=5,
    Col\=9,
    Col\=10,
    print_character(H, T),
    write(' ').

print_cell([H|T], _, _) :-
    print_character(H, T).

print_character('T', [H|T]) :-
    H==up,
    nth1(1, T, X),
    get_color(X, C1),
    nth1(2, T, Y),
    get_color(Y, C2),
    print_triangle_cell(9700, 9698, C1, C2).

print_character('T', [H|T]) :-
    H==dw,
    nth1(1, T, X),
    get_color(X, C1),
    nth1(2, T, Y),
    get_color(Y, C2),
    print_triangle_cell(9699, 9701, C1, C2).

print_character('R', [_, H|_]) :-
    get_color(H, C1),
    print_square_cell(9632, C1).

print_character('Q', [H|_]) :-
    get_color(H, C1),
    print_square_cell(9632, C1).

print_square_cell(Code1, Color1) :-
    write(' '),
    ansi_format([fg(Color1)], '~c', [Code1]),
    write(' ').

print_triangle_cell(Code1, Code2, Color1, Color2) :-
    ansi_format([fg(Color1)], '~c', [Code1]),
    write(' '),
    ansi_format([fg(Color2)], '~c', [Code2]).

get_color(nill, Color) :-
    Color=white.

get_color(p1, Color) :-
    Color=red.

get_color(p2, Color) :-
    Color=blue.

% Note that index starts at 0!
replace_nth([_|T], 0, X, [X|T]).
replace_nth([H|T], I, X, [H|R]) :-
    I> -1,
    NI is I-1,
    replace_nth(T, NI, X, R), !.
replace_nth(L, _, _, L).

get_line(Board, Row, Line) :-
    nth1(Row, Board, Line).

get_cell(Board, Row, Column, Cell) :-
    nth1(Row, Board, Line),
    nth1(Column, Line, Cell).

paint_cell(Player, Cell, PaintedCell) :-
    nth1(1, Cell, Shape),
    Shape=='R',
    nth1(3, Cell, Owner),
    Owner==nill,
    replace_nth(Cell, 2, Player, PaintedCell).
    
paint_cell(Player, Cell, PaintedCell) :-
    nth1(1, Cell, Shape),
    Shape=='Q',
    nth1(2, Cell, Owner),
    Owner==nill,
    replace_nth(Cell, 1, Player, PaintedCell).

paint_cell(Player, Cell, Side, PaintedCell) :-
    nth1(1, Cell, Shape),
    Shape=='T',
    Side==left,
    nth1(3, Cell, Owner),
    Owner==nill,
    replace_nth(Cell, 2, Player, PaintedCell).

paint_cell(Player, Cell, Side, PaintedCell) :-
    nth1(1, Cell, Shape),
    Shape=='T',
    Side==right,
    nth1(4, Cell, Owner),
    Owner==nill,
    replace_nth(Cell, 3, Player, PaintedCell).

update_board(Player, Row, Column, Board, NewBoard) :-
    get_cell(Board, Row, Column, Cell),
    paint_cell(Player, Cell, PaintedCell),
    get_line(Board, Row, Line),
    % FIXME: Bug in the following line. For some reason, col=1 or line=1 is not painting in board
    replace_nth(Line, Column-1, PaintedCell, NewLine),
    replace_nth(Board, Row-1, NewLine, NewBoard),
    print_board(NewBoard, 1).

% Side can be left or right (triangle)
update_board(Player, Row, Column, Side, Board, NewBoard) :-
    get_cell(Board, Row, Column, Cell),
    paint_cell(Player, Cell, Side, PaintedCell),
    get_line(Board, Row, Line),
    replace_nth(Line, Column-1, PaintedCell, NewLine),
    replace_nth(Board, Row-1, NewLine, NewBoard).

is_triangle(Cell) :-
    nth1(1, Cell, 'T').

is_square(Cell) :-
    nth1(1, Cell, 'Q').

is_rectangle(Cell) :-
    nth1(1, Cell, 'R').

is_up_side(Char) :-
    Char==u.

is_down_side(Char) :-
    Char==d.

valid_side(u).
valid_side(d).

valid_coordinate(Coord) :-
    Coord>=1,
    Coord=<10.