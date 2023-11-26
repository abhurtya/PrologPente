
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

% Default to random strategy if none of the above strategies work
find_best_strategy(Board, Symbol, BestMove) :-
    random_strategy(Board, Symbol, BestMove),
    format('Strategy: (Default strategy)~n').



random_strategy(Board, Symbol, Move) :-
    random(0, 19, Row),
    random(0, 19, Col),

    (   is_valid_move(Board, Row, Col, Symbol) ->
        Move = [Row, Col]
    ;   % If not valid, try again
        random_strategy(Board, Symbol, Move)
    ).

% Second move strategy white
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


five_row_strategy(Board, Symbol, Move) :-
    find_five_row_move(Board, Symbol, 0, 0, Move).

% end of the board
find_five_row_move(_, _, 19, _, []).

% end of the row
find_five_row_move(Board, Symbol, X, 19, Move) :-
    NewX is X + 1,
    find_five_row_move(Board, Symbol, NewX, 0, Move).

find_five_row_move(Board, Symbol, X, Y, [X, Y]) :-
    get_cell(Board, X, Y, Cell),
    Cell == '.',
    place_stone(Board, X, Y, Symbol, NewBoard),
    check_for_five_in_a_row(NewBoard, Symbol, [X, Y]).

% Move to the next cell
find_five_row_move(Board, Symbol, X, Y, Move) :-
    NewY is Y + 1,
    find_five_row_move(Board, Symbol, X, NewY, Move).

block_five_row_strategy(Board, Symbol, Move) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    find_five_row_move(Board, OpponentSymbol, 0, 0, Move).

