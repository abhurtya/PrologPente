% Determine the best move based on the given game board and symbol
strategy(Board, Symbol, BestMove) :-
    (   
        check_first_move_second_move(Board, Symbol, 0), Symbol = 'W' ->
        BestMove = [9, 9]  % First move strategy
    ;
        check_first_move_second_move(Board, Symbol, 1), Symbol = 'W', get_cell(Board, 9, 9, 'W') ->
        second_move_strategy(Board, BestMove)  % Second move strategy
    ;
        find_best_strategy(Board, Symbol, BestMove)  % Best strategy move
    ).

% Determine the best move based on a hierarchy of strategies
% Try five_row_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    five_row_strategy(Board, Symbol, BestMove),
    format('Strategy: To make 5-in-a-row~n').

% Try block_five_row_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    block_five_row_strategy(Board, Symbol, BestMove),
    format('Strategy: To Block Opponent\'s Possible 5-in-a-row~n').

% Try block_capture_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    block_capture_strategy(Board, Symbol, BestMove),
    format('Strategy: To Defend Against Possible Capture~n').

% Try check_capture_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    check_capture_strategy(Board, Symbol, BestMove),
    format('Strategy: Capture Opponent\'s Stones~n').

% Try snake_strategy_4
find_best_strategy(Board, Symbol, BestMove) :-
    snake_strategy_4(Board, Symbol, BestMove),
    format('Strategy: Form a Chain of 4 Stones~n').

% Try block_snake_4_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    block_snake_4_strategy(Board, Symbol, BestMove),
    format('Strategy: Block Opponent from Making Chain of 4 Stones~n').

% Try snake_strategy_3
find_best_strategy(Board, Symbol, BestMove) :-
    snake_strategy_3(Board, Symbol, BestMove),
    format('Strategy: Form a Chain of 3 Stones~n').

% Try block_snake_3_strategy
find_best_strategy(Board, Symbol, BestMove) :-
    block_snake_3_strategy(Board, Symbol, BestMove),
    format('Strategy: Block Opponent from Making Chain of 3 Stones~n').

find_best_strategy(Board, Symbol, BestMove) :-
    snake_strategy_2(Board, Symbol, BestMove),
    format('Strategy: Form a Chain of 2 Stones~n').


% Default to random strategy if none of the above strategies work
find_best_strategy(Board, Symbol, BestMove) :-
    random_strategy(Board, Symbol, BestMove),
    format('Strategy: Make a Random Move~n').

% ================================ Random Default Fallback Strategy ================================

random_strategy(Board, Symbol, Move) :-
    random(0, 19, Row),
    random(0, 19, Col),

    (   is_valid_move(Board, Row, Col, Symbol) ->
        Move = [Row, Col]
    ;   % If not valid, try again
        random_strategy(Board, Symbol, Move)
    ).

% ================================ Second White Move Strategy ================================
second_move_strategy(Board, [Row, Col]) :-
    Directions = [[4, 0], [0, 4], [-4, 0], [0, -4]],
    random_member([DirRow, DirCol], Directions),
    NewRow is 9 + DirRow,
    NewCol is 9 + DirCol,
    (   is_valid_move(Board, NewRow, NewCol, 'W') ->
        Row = NewRow, 
        Col = NewCol
    ;   second_move_strategy(Board, [Row, Col])
    ).

% ================================ Five Row Strategy ================================

five_row_strategy(Board, Symbol, Move) :-
    find_five_row_move(Board, Symbol, 0, 0, Move).

% End of the board
find_five_row_move(_, _, 19, _, _) :- fail.

% End of the row
find_five_row_move(Board, Symbol, X, 19, Move) :-
    NewX is X + 1,
    find_five_row_move(Board, Symbol, NewX, 0, Move).

find_five_row_move(Board, Symbol, X, Y, [X, Y]) :-
    is_within_bounds(X, Y),
    get_cell(Board, X, Y, Cell),
    Cell == '.',
    place_stone(Board, X, Y, Symbol, NewBoard),
    check_for_five_in_a_row(NewBoard, Symbol, [X, Y]).

% Move to the next cell
find_five_row_move(Board, Symbol, X, Y, Move) :-
    is_within_bounds(X, Y),
    next_cell(X, Y, NextX, NextY),
    find_five_row_move(Board, Symbol, NextX, NextY, Move).

block_five_row_strategy(Board, Symbol, Move) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    find_five_row_move(Board, OpponentSymbol, 0, 0, Move).

% ================================ Capture Strategy ================================

% Entry point for checking capture strategy
check_capture_strategy(Board, Symbol, BestMove) :-
    format('Entering check_capture_strategy with Symbol: ~w~n', [Symbol]),
    check_capture(Board, Symbol, 0, 0, false, 0, _, FinalBestMove),
    BestMove = FinalBestMove.

% Base case for recursion - when the best move is found
check_capture(_, _, 19, _, true, _, BestMove, BestMove):-
    format('Ending check_capture with BestMove: ~w~n', [BestMove]).
    

% Ending board condition - fail if no move found
check_capture(_, _, 19, _, false, _, _, _) :-
    fail.

% Recursive case - check current cell for potential captures
check_capture(Board, Symbol, X, Y, FoundMove, MaxCapture, CurrentBestMove, FinalBestMove) :-
    is_within_bounds(X, Y),
    (is_cell_empty(Board, X, Y) ->
        count_captures(Board, X, Y, Symbol, CaptureCount),
        (CaptureCount > MaxCapture ->
            NextBestMove = [X, Y],
            NextMaxCapture = CaptureCount,
            Found = true

        ;
            NextBestMove = CurrentBestMove,
            NextMaxCapture = MaxCapture,
            Found = FoundMove
        )
    ;
        NextBestMove = CurrentBestMove,
        NextMaxCapture = MaxCapture,
        Found = FoundMove
    ),
    next_cell(X, Y, NextX, NextY),
    check_capture(Board, Symbol, NextX, NextY, Found, NextMaxCapture, NextBestMove, FinalBestMove).

block_capture_strategy(Board, Symbol, BestMove) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    check_capture_strategy(Board, OpponentSymbol, BestMove).


% ================================ Snake Strategy  ================================


% Wrapper predicates for specific chain lengths
snake_strategy_4(Board, Symbol, Move) :-
    snake_strategy(Board, Symbol, 4, Move).

block_snake_4_strategy(Board, Symbol, Move) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    snake_strategy(Board, OpponentSymbol, 4, Move).

snake_strategy_3(Board, Symbol, Move) :-
    snake_strategy(Board, Symbol, 3, Move).

block_snake_3_strategy(Board, Symbol, Move) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    snake_strategy(Board, OpponentSymbol, 3, Move).

snake_strategy_2(Board, Symbol, Move) :-
    snake_strategy(Board, Symbol, 2, Move).

% General snake strategy predicate
snake_strategy(Board, Symbol, ChainLength, Move) :-
    find_snake_move(Board, Symbol, ChainLength, 0, 0, Move).

% End of the board
find_snake_move(_, _, _, 19, _, _) :- fail.

% End of the row
find_snake_move(Board, Symbol, ChainLength, X, 19, Move) :-
    NewX is X + 1,
    find_snake_move(Board, Symbol, ChainLength, NewX, 0, Move).

% Check if current cell can make a chain of specified length
find_snake_move(Board, Symbol, ChainLength, X, Y, [X, Y]) :-
    is_within_bounds(X, Y),
    is_cell_empty(Board, X, Y),
    check_snake_chain(Board, Symbol, ChainLength, X, Y).

% Move to the next cell if current cell is not suitable
find_snake_move(Board, Symbol, ChainLength, X, Y, Move) :-
    is_within_bounds(X, Y),
    next_cell(X, Y, NextX, NextY),
    find_snake_move(Board, Symbol, ChainLength, NextX, NextY, Move).

% Predicate to check if placing a stone at (X, Y) can make a chain of specified length
check_snake_chain(Board, Symbol, ChainLength, X, Y) :-
    directions(Directions),
    check_all_directions(Board, Symbol, X, Y, Directions, ChainLength).

% Predicate to check all directions for a potential chain of specified length
check_all_directions(Board, Symbol, X, Y, [[DX, DY]|Rest], ChainLength) :-
    count_consecutive_stones(Board, X, Y, DX, DY, Symbol, 0, Count1),
    count_consecutive_stones(Board, X, Y, -DX, -DY, Symbol, 0, Count2),
    TotalCount is Count1 + Count2 + 1,
    TotalCount >= ChainLength,
    get_opponent_symbol(Symbol, OpponentSymbol),
    \+ is_capture_possible(Board, [X, Y], DX, DY, OpponentSymbol),
    \+ is_capture_possible(Board, [X, Y], -DX, -DY, OpponentSymbol).

check_all_directions(Board, Symbol, X, Y, [_|Rest], ChainLength) :-
    check_all_directions(Board, Symbol, X, Y, Rest, ChainLength).
