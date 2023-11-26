clear_input_buffer :-
    peek_char(user_input, Char),
    (Char == '\n' -> get_char(user_input, _); true).

% Retrieve the opponent's symbol based on the given player symbol.
get_opponent_symbol('W', 'B').
get_opponent_symbol('B', 'W').

% Determine the opponent of the given player.
get_opponent_player(human, computer).
get_opponent_player(computer, human).


grid_to_index(Input, Row, Col) :-
    string_chars(Input, [ColChar | RowChars]),
    char_code(ColChar, ColCode),
    char_code('A', ACode),
    Col is ColCode - ACode,
    string_chars(RowString, RowChars),
    number_string(RowNumber, RowString),
    Row is 19 - RowNumber.



% Convert matrix indices (like 0 0) to grid coordinates (like A1).
index_to_grid(Row, Col, Grid) :-
    Ascii is Col + 65,
    char_code(Char, Ascii),
    Number is 19 - Row,
    atom_number(NumAtom, Number),
    atom_concat(Char, NumAtom, Grid).

% Check if there are n consecutive occurrences of a given symbol from a starting cell in all directions.
check_for_n_in_a_row(Board, Symbol, N, Count) :-
    check_cell_for_n(Board, Symbol, 0, 0, N, Count).

% Helper function to check for n-in-a-row occurrences of a given symbol starting from the specified cell in all directions.
check_cell_for_n(_, _, 19, _, _, 0).

check_cell_for_n(Board, Symbol, X, 19, N, Count) :-
    NewX is X + 1,
    check_cell_for_n(Board, Symbol, NewX, 0, N, Count).


check_cell_for_n(Board, Symbol, X, Y, N, Count) :-
    directions(Directions),
    check_directions_for_n(Board, Symbol, X, Y, Directions, N, DirectionCount),
    NewY is Y + 1,
    check_cell_for_n(Board, Symbol, X, NewY, N, NextCount),
    Count is DirectionCount + NextCount.

% Define the four primary directions for checking.
directions(Directions) :-
    Directions = [[1, 0], [0, 1], [1, 1], [1, -1]].

capture_directions(Directions) :-
    Directions = [[1, 0], [0, 1], [1, 1], [1, -1], [-1, 0], [0, -1], [-1, -1], [-1, 1]].

% Check all directions for n consecutive stones.
check_directions_for_n(_, _, _, _, [], _, 0).
check_directions_for_n(Board, Symbol, X, Y, [Dir|Rest], N, Count) :-
    check_direction_n(Board, Symbol, X, Y, Dir, N, DirectionCount),
    check_directions_for_n(Board, Symbol, X, Y, Rest, N, RestCount),
    Count is DirectionCount + RestCount.

% Check a specific direction for consecutive stones.return 1 if found, 0 otherwise.
check_direction_n(Board, Symbol, X, Y, [Dx, Dy], N, 1) :-
    count_consecutive_stones(Board, X, Y, Dx, Dy,Symbol, 0, Count),
    Count >= N.
check_direction_n(_, _, _, _, _, _, 0).


% Determine if there are five consecutive occurrences of a given symbol from a starting cell in any direction.
check_for_five_in_a_row(Board, Symbol, [X, Y]) :-
    directions(Directions),
    check_both_directions_for_five(Board, Symbol, X, Y, Directions, Found),
    Found = true.

check_both_directions_for_five(_, _, _, _, [], false).

check_both_directions_for_five(Board, Symbol, X, Y, [[Dx, Dy] | Rest], Found) :-
    OppositeDx is -Dx, OppositeDy is -Dy,
    count_consecutive_stones(Board, X, Y, Dx, Dy, Symbol, 0, Count1),
    count_consecutive_stones(Board, X, Y, OppositeDx, OppositeDy, Symbol, 0, Count2),
    Total is Count1 + Count2 ,
    (   Total >= 4
    ->  Found = true
    ;   check_both_directions_for_five(Board, Symbol, X, Y, Rest, Found)
    ).


% Count occurrences of four consecutive symbols on the board.
count_four_in_a_row(Board, Symbol, Count) :-
    check_for_n_in_a_row(Board, Symbol, 4, Count).

is_capture_possible(Board, [X, Y], Dx, Dy, Symbol) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    DeltaX1 is X + Dx,
    DeltaY1 is Y + Dy,
    DeltaX2 is X + 2 * Dx,
    DeltaY2 is Y + 2 * Dy,
    DeltaX3 is X + 3 * Dx,
    DeltaY3 is Y + 3 * Dy,
    get_cell(Board, DeltaX1, DeltaY1, FirstCell),
    get_cell(Board, DeltaX2, DeltaY2, SecondCell),
    get_cell(Board, DeltaX3, DeltaY3, ThirdCell),
    FirstCell == OpponentSymbol,
    SecondCell == OpponentSymbol,
    ThirdCell == Symbol.


capture_stones(Board, [X, Y], Dx, Dy, Symbol, NewBoard, Captures) :-
    (   is_capture_possible(Board, [X, Y], Dx, Dy, Symbol) ->
        DeltaX1 is X + Dx,
        DeltaY1 is Y + Dy,
        DeltaX2 is X + 2 * Dx,
        DeltaY2 is Y + 2 * Dy,
        place_stone(Board, DeltaX1, DeltaY1, '.', TempBoard),
        place_stone(TempBoard, DeltaX2, DeltaY2, '.', NewBoard),
        index_to_grid(DeltaX1, DeltaY1, Grid1),
        index_to_grid(DeltaX2, DeltaY2, Grid2),
        format("🌟🌟🌟🌟 Captured pairs at ~w and ~w 🌟🌟🌟🌟\n", [Grid1, Grid2]),
        Captures = 1
    ;   NewBoard = Board,
        Captures = 0
    ).



% Check if any captures are possible for a given position in all directions.
check_for_capture(Board, Symbol, [X, Y], UpdatedBoard, TotalCaptures) :-
    capture_directions(Directions),
    check_directions_capture(Board, Symbol, [X, Y], Directions, UpdatedBoard, TotalCaptures).

% Check multiple directions for possible captures and carry them out.
check_directions_capture(Board, Symbol, [X, Y], [], Board, 0).
check_directions_capture(Board, Symbol, [X, Y], [[Dx, Dy] | Rest], UpdatedBoard, TotalCaptures) :-
    capture_stones(Board, [X, Y], Dx, Dy, Symbol, NewBoard, Captures),
    check_directions_capture(NewBoard, Symbol, [X, Y], Rest, MoreUpdatedBoard, MoreCaptures),
    TotalCaptures is Captures + MoreCaptures,
    UpdatedBoard = MoreUpdatedBoard.


% ==================================================================================================
% FOR STRATEGY TO PROIORITIZE MOVE WITH MORE CAPTURES
% % Count the total number of possible captures from a given position.
% count_captures(Board, X, Y, Symbol, Count) :-
%     directions(Directions),
%     count_captures_directions(Board, X, Y, Symbol, Directions, Count).

% count_captures_directions(_, _, _, _, [], 0).
% count_captures_directions(Board, X, Y, Symbol, [Direction|Rest], Count) :-
%     Direction = [Dx, Dy],
%     is_capture_possible(Board, X, Y, Dx, Dy, Symbol, Possible),
%     count_captures_directions(Board, X, Y, Symbol, Rest, RestCount),
%     (   Possible -> Count is RestCount + 1
%     ;   Count = RestCount
%     ).
