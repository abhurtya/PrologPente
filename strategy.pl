% Check if the given move is valid
is_move_ok(Move) :-
    Move \= [].

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
find_best_strategy(Board, Symbol, BestMove) :-
    (
        % five_row_strategy(Board, Symbol, Move), is_move_ok(Move) ->
        % BestMove = Move
    % ;
    %     block_five_row_strategy(Board, Symbol, Move), is_move_ok(Move) ->
    %     BestMove = Move
    % ;
        random_strategy(Board, Symbol, BestMove)  % Default to random strategy
    ).


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
