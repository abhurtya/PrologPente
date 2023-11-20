
:- consult('board.pl').
:- consult('strategy.pl').
:- consult('utilities.pl').

human_play(Board, Symbol, UpdatedBoard, Move) :-
    writeln('Enter move (like C4) or type help:'),
    clear_input_buffer,
    read_line_to_string(user_input, Input),
    string_upper(Input, UpperInput),
    process_input(UpperInput, Board, Symbol, UpdatedBoard, Move).



process_input("HELP", Board, Symbol, UpdatedBoard, Move) :-
    strategy(Board, Symbol, [SuggestedRow, SuggestedCol]),
    format('Suggested move: ~w~n', [[SuggestedRow, SuggestedCol]]),
    human_play(Board, Symbol, UpdatedBoard, Move).

process_input(Input, Board, Symbol, UpdatedBoard, Move) :-
    (   grid_to_index(Input, Row, Col),
        is_valid_move(Board, Row, Col, Symbol) ->
        place_stone(Board, Row, Col, Symbol, UpdatedBoard),
        format('You chose position: ~w~n', [[Row, Col]]),
        Move = [Row, Col]
    ;   write('Invalid move. Try again.'), nl,
        human_play(Board, Symbol, UpdatedBoard, Move)
    ).

% Computer player move
computer_play(Board, Symbol, UpdatedBoard, Move) :-
    strategy(Board, Symbol, [Row, Col]),
    place_stone(Board, Row, Col, Symbol, UpdatedBoard),
    format('Computer chose position: ~w~n', [[Row, Col]]),
    
    Move = [Row, Col].
