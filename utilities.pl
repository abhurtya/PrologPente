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
check_for_n_in_a_row(Board, Symbol, N, Result) :-
    check_cell_for_n(Board, Symbol, 0, 0, N, Result).

% Helper function to check for n-in-a-row occurrences of a given symbol starting from the specified cell in all directions.
check_cell_for_n(Board, Symbol, 19, _, N, false) :- !.
check_cell_for_n(Board, Symbol, X, 19, N, Result) :-
    NewX is X + 1,
    check_cell_for_n(Board, Symbol, NewX, 0, N, Result), !.
check_cell_for_n(Board, Symbol, X, Y, N, true) :-
    directions(Directions),
    check_directions_for_n(Board, Symbol, X, Y, Directions, N), !.
check_cell_for_n(Board, Symbol, X, Y, N, Result) :-
    NewY is Y + 1,
    check_cell_for_n(Board, Symbol, X, NewY, N, Result).

% Define the four primary directions for checking.
directions(Directions) :-
    Directions = [[1, 0], [0, 1], [1, 1], [1, -1]].

% Check all directions for n consecutive stones.
check_directions_for_n(_, _, _, _, [], _, false) :- !.
check_directions_for_n(Board, Symbol, X, Y, [Dir|Rest], N, true) :-
    check_direction_n(Board, Symbol, X, Y, Dir, Count),
    Count >= N, !.
check_directions_for_n(Board, Symbol, X, Y, [_|Rest], N, Result) :-
    check_directions_for_n(Board, Symbol, X, Y, Rest, N, Result).

% Check a specific direction for consecutive stones.
check_direction_n(Board, Symbol, X, Y, [Dx, Dy], Count) :-
    count_consecutive_stones(Board, Symbol, X, Y, Dx, Dy, Count).

% Function to count consecutive stones in a given direction.
% count_consecutive_stones(Board, Symbol, X, Y, Dx, Dy, Count) :-
%     % Implement the logic to count consecutive stones in a given direction.

% Determine if there are five consecutive occurrences of a given symbol from a starting cell in any direction.
check_for_five_in_a_row(Board, Symbol, X, Y, Result) :-
    check_for_n_in_a_row(Board, Symbol, 5, Result).

% Count occurrences of four consecutive symbols on the board.
count_four_in_a_row(Board, Symbol, Count) :-
    check_for_n_in_a_row(Board, Symbol, 4, Count).

% Determine if a capture move is possible in a specific direction from a starting cell.
is_capture_possible(Board, X, Y, Dx, Dy, Symbol, true) :-
    % Implement the logic to check if a capture is possible in a specific direction.
is_capture_possible(Board, X, Y, Dx, Dy, Symbol, false).

% Capture opponent's stones if possible based on the current position and direction.
capture_stones(Board, X, Y, Dx, Dy, Symbol, [NewBoard, 1]) :-
    is_capture_possible(Board, X, Y, Dx, Dy, Symbol, true),
    % Implement the logic to remove captured stones and return the updated board.
capture_stones(Board, _, _, _, _, _, [Board, 0]).

% Check if any captures are possible for a given position in all directions.
check_for_capture(Board, Symbol, X, Y, [UpdatedBoard, TotalCaptures]) :-
    directions(Directions),
    check_directions_capture(Board, Symbol, X, Y, Directions, [UpdatedBoard, TotalCaptures]).

% Check multiple directions for possible captures and carry them out.
check_directions_capture(Board, Symbol, X, Y, [], [Board, 0]).
check_directions_capture(Board, Symbol, X, Y, [Direction|Rest], [UpdatedBoard, TotalCaptures]) :-
    Direction = [Dx, Dy],
    capture_stones(Board, X, Y, Dx, Dy, Symbol, [NewBoard, Captures]),
    check_directions_capture(NewBoard, Symbol, X, Y, Rest, [MoreUpdatedBoard, MoreCaptures]),
    TotalCaptures is Captures + MoreCaptures,
    UpdatedBoard = MoreUpdatedBoard.

% Count the total number of possible captures from a given position.
count_captures(Board, X, Y, Symbol, Count) :-
    directions(Directions),
    count_captures_directions(Board, X, Y, Symbol, Directions, Count).

count_captures_directions(_, _, _, _, [], 0).
count_captures_directions(Board, X, Y, Symbol, [Direction|Rest], Count) :-
    Direction = [Dx, Dy],
    is_capture_possible(Board, X, Y, Dx, Dy, Symbol, Possible),
    count_captures_directions(Board, X, Y, Symbol, Rest, RestCount),
    (   Possible -> Count is RestCount + 1
    ;   Count = RestCount
    ).
