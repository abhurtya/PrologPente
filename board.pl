% Create a new game board with specified rows and columns
create_board(Rows, Cols, Board) :-
    Rows >= 0,
    create_board_helper(Rows, Cols, Board).

create_board_helper(0, _, []).
create_board_helper(Rows, Cols, [Row|Board]) :-
    Rows > 0,
    create_row(Cols, Row),
    NewRows is Rows - 1,
    create_board_helper(NewRows, Cols, Board).

% Create a new row for the game board with specified columns
create_row(Cols, Row) :-
    Cols >= 0,
    create_row_helper(Cols, Row).

create_row_helper(0, []).
create_row_helper(Cols, ['.'|Row]) :-
    Cols > 0,
    NewCols is Cols - 1,
    create_row_helper(NewCols, Row).


% Display the game board
print_board(Board) :-
    writeln('-----------------------------------------------'),
    writeln('   A B C D E F G H I J K L M N O P Q R S'),
    print_board_body(Board, 19),
    writeln('-----------------------------------------------').

% Recursively print each row of the game board with its corresponding row number
print_board_body([], _).
print_board_body([Row|Rest], RowNum) :-
    format_row(Row, FormattedRow),
    (RowNum >= 10 -> format('~w ~w~n', [RowNum, FormattedRow]);
                    format(' ~w ~w~n', [RowNum, FormattedRow])),
    NewRowNum is RowNum - 1,
    print_board_body(Rest, NewRowNum).

% Helper to format each row for printing
format_row([], '').
format_row([H|T], FormattedRow) :-
    format_row(T, FormattedRest),
    (FormattedRest = '' -> format(atom(FormattedRow), '~w', [H]);
                            format(atom(FormattedRow), '~w ~w', [H, FormattedRest])).

% % Place a specific stone on a given position of the board
% place_stone(Board, X, Y, Stone, UpdatedBoard) :-
%     replace_stone_in_board(Board, X, Y, Stone, UpdatedBoard, 0).

% % Replace a specific stone in the board, row by row
% replace_stone_in_board([Row|RestBoard], X, Y, Stone, [NewRow|UpdatedRestBoard], CurrentRow) :-
%     (   X == CurrentRow ->
%         replace_stone_in_row(Row, Y, Stone, NewRow),
%         UpdatedRestBoard = RestBoard
%     ;   NewRow = Row,
%         NextRow is CurrentRow + 1,
%         replace_stone_in_board(RestBoard, X, Y, Stone, UpdatedRestBoard, NextRow)
%     ).
% replace_stone_in_board([], _, _, _, [], _).

% % Replace a specific stone in a given row at a specified column position
% replace_stone_in_row([_|RestRow], 0, Stone, [Stone|RestRow]).
% replace_stone_in_row([Cell|RestRow], Y, Stone, [Cell|NewRow]) :-
%     Y > 0,
%     NewY is Y - 1,
%     replace_stone_in_row(RestRow, NewY, Stone, NewRow).

place_stone(Board, X, Y, Stone, UpdatedBoard) :-
    nth0(X, Board, Row, RestRows),      % Extract the target row and the rest of the rows
    nth0(Y, Row, _, RestCells),         % Extract the rest of the cells in the target row
    nth0(Y, NewRow, Stone, RestCells),  % Create the new row with the stone placed
    nth0(X, UpdatedBoard, NewRow, RestRows). % Create the updated board with the new row


% To check if the provided coordinates are within the boundaries of the board
is_within_bounds(X, Y) :-
    X >= 0, X < 19,
    Y >= 0, Y < 19.

% Check if move is valid
is_valid_move(Board, X, Y, Symbol) :-
    (   not(is_within_bounds(X, Y)) ->
        print('Coordinates out of bounds'), nl, false
    ;   not(get_cell(Board, X, Y, '.')) ->
        print('Cell is not empty'), nl, false
    ;   Symbol = 'W', check_first_move_second_move(Board, 'W', 0), not((X = 9, Y = 9)) ->
        print('First white move must be at J10'), nl, false
    ;   Symbol = 'W', check_first_move_second_move(Board, 'W', 1), not((abs(X - 9) > 3; abs(Y - 9) > 3)) ->
        print('Second white move must be 3 steps away from J10'), nl, false
    ;   true % If none of the above, the move is valid
    ).

% Check if cell is empty
is_cell_empty(Board, X, Y) :-
    get_cell(Board, X, Y, Cell),
    Cell == '.'.

% get the next cell in baord
next_cell(18, 18, 19, 0). 
next_cell(X, 18, NextX, 0) :-  
    NextX is X + 1.
next_cell(X, Y, X, NextY) :-
    Y < 18,
    NextY is Y + 1.

% ==================================================================================================


% Retrieve the content of a cell on the board at the provided coordinates
get_cell(Board, X, Y, Cell) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Cell).

check_first_move_second_move(Board, Symbol, Result) :-
    findall(Pos, (member(RowList, Board), 
                  member(Symbol, RowList), 
                  Pos = [RowList, Symbol]), Occurrences),
    length(Occurrences, Count),
    classify_move(Count, Result).

classify_move(0, 0).  % No symbols, first move
classify_move(1, 1).  % One symbol, second move
classify_move(_, -1). % > one symbol

% Helper to check each row for the number of moves made by the specified symbol
check_board_row([], _, _, 0).
check_board_row([Row|Rest], Symbol, RowNum, Count) :-
    check_row(Row, Symbol, RowCount),
    NewRowNum is RowNum + 1,
    check_board_row(Rest, Symbol, NewRowNum, RestCount),
    Count is RowCount + RestCount.

% Count the occurrences of the symbol in a row
check_row(Row, Symbol, Count) :-
    include(=(Symbol), Row, Filtered),
    length(Filtered, Count).

% Count the number of consecutive stones in a specified direction excluding the current cell
count_consecutive_stones(Board, X, Y, Dx, Dy, Symbol, Depth, Count) :-
    NewX is X + Dx,
    NewY is Y + Dy,
    (
        % Base case: out of bounds, max depth, or cell doesn't match the symbol
        not(is_within_bounds(NewX, NewY));
        Depth >= 5;
        (get_cell(Board, NewX, NewY, Cell), Cell \= Symbol)
    ),
    Count = 0.

count_consecutive_stones(Board, X, Y, Dx, Dy, Symbol, Depth, Count) :-
    NewX is X + Dx,
    NewY is Y + Dy,
    is_within_bounds(NewX, NewY),
    Depth < 5,
    get_cell(Board, NewX, NewY, Cell),
    Cell == Symbol,
    % Recursive case: continue counting in the given direction
    NextDepth is Depth + 1,
    count_consecutive_stones(Board, NewX, NewY, Dx, Dy, Symbol, NextDepth, NextCount),
    Count is 1 + NextCount.


% % To convert the entire board either from file format to display format or vice-versa
% convert_board([], _, []) :- !.
% convert_board([Row|Rest], ConvertType, [ConvertedRow|ConvertedBoard]) :-
%     convert_row(Row, ConvertType, ConvertedRow),
%     convert_board(Rest, ConvertType, ConvertedBoard).

% % To convert a single row either from file format to display format or vice-versa
% convert_row([], _, []) :- !.
% convert_row([Cell|Rest], ConvertType, [ConvertedCell|ConvertedRow]) :-
%     convert_cell(Cell, ConvertType, ConvertedCell),
%     convert_row(Rest, ConvertType, ConvertedRow).

% % To convert an individual cell either from file format to display format or vice-versa
% convert_cell(Cell, from_file, ConvertedCell) :-
%     (   Cell = 'O', ConvertedCell = '.'
%     ;   Cell = 'W', ConvertedCell = 'W'
%     ;   Cell = 'B', ConvertedCell = 'B'
%     ;   ConvertedCell = Cell
%     ).
% convert_cell(Cell, to_file, ConvertedCell) :-
%     (   Cell = '.', ConvertedCell = 'O'
%     ;   Cell = 'W', ConvertedCell = 'W'
%     ;   Cell = 'B', ConvertedCell = 'B'
%     ;   ConvertedCell = Cell
%     ).



% % To count the number of consecutive stones in a specified direction
% count_consecutive_stones(Board, X, Y, Dx, Dy, Symbol, Depth, Count) :-
%     NewX is X + Dx,
%     NewY is Y + Dy,
%     (   is_within_bounds(NewX, NewY),
%         get_cell(Board, NewX, NewY, Cell),
%         Cell = Symbol,
%         NewDepth is Depth + 1,
%         count_consecutive_stones(Board, NewX, NewY, Dx, Dy, Symbol, NewDepth, RecursiveCount),
%         Count is RecursiveCount + 1
%     ;   Count = 0
%     ).



% ==================================================================================================