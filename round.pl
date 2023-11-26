% round.pl

% Load required modules
:- consult('board.pl').
:- consult('player.pl').
:- consult('strategy.pl').
:- consult('utilities.pl').


    play_round(Board, CurrentPlayer, Symbol, HumanCaptures, ComputerCaptures, Scores) :-

        make_move(CurrentPlayer, Board,  Symbol, NewBoard, LastMove),
        check_for_capture(NewBoard, Symbol, LastMove, NewBoardWithCaptures, NumCaptures),
        update_captures(CurrentPlayer, HumanCaptures, ComputerCaptures, NumCaptures, NewHumanCaptures, NewComputerCaptures),
        print_board(NewBoardWithCaptures),
        print_captures(NewHumanCaptures, NewComputerCaptures),
        
        (   check_win(NewBoardWithCaptures, LastMove, Symbol, NumCaptures) ->
            % win condition
            determine_winner_type(NewBoardWithCaptures, LastMove, Symbol, NumCaptures, WinnerType), 
            format("~w wins this round! Reason code: ~w\n", [CurrentPlayer, WinnerType]),
            count_four_in_a_row_points(NewBoardWithCaptures, CurrentPlayer, Symbol, FourInARowPoints),
            count_total_points(WinnerType, CurrentPlayer, NewHumanCaptures, NewComputerCaptures, FourInARowPoints, Scores)
        ; %no winner condition
            ask_user_continue(Choice),
            (   Choice == continue ->
                get_opponent_player(CurrentPlayer, NextPlayer),
                get_opponent_symbol(Symbol, NextSymbol),
                play_round(NewBoardWithCaptures, NextPlayer, NextSymbol, HumanCaptures, ComputerCaptures, Scores)
            ;   Choice == save ->
                save_game_to_file(NewBoardWithCaptures, HumanCaptures, ComputerCaptures, CurrentPlayer, Symbol),
                Scores = [HumanCaptures, ComputerCaptures]
            ;   Choice == quit ->
                writeln('Game ended without saving.'),
                Scores = [HumanCaptures, ComputerCaptures]
            )
        ).
    


make_move(human,Board,  Symbol, NewBoard, LastMove) :-
    human_play(Board, Symbol, NewBoard, LastMove).

make_move(computer, Board, Symbol, NewBoard, LastMove) :-
    computer_play(Board, Symbol, NewBoard, LastMove).

update_captures(human, HumanCaptures, ComputerCaptures, NumCaptures, NewHumanCaptures, ComputerCaptures) :-
    NewHumanCaptures is HumanCaptures + NumCaptures.

update_captures(computer, HumanCaptures, ComputerCaptures, NumCaptures, HumanCaptures, NewComputerCaptures) :-
    NewComputerCaptures is ComputerCaptures + NumCaptures.

print_captures(HumanCaptures, ComputerCaptures) :-
    format('Human Captures: ~d\tComputer Captures: ~d~n', [HumanCaptures, ComputerCaptures]).
    
% Determines if the current player has won
check_win(Board, LastMove, Symbol, NumCaptures) :-
    (   check_for_five_in_a_row(Board, Symbol, LastMove)
    ;   NumCaptures >= 5
    ).

determine_winner_type(Board, LastMove, Symbol, NumCaptures, WinnerType) :-
    (   check_for_five_in_a_row(Board, Symbol, LastMove) -> 
        WinnerType = row5
    ;   NumCaptures >= 5 -> 
        WinnerType = capture5
    ).


count_four_in_a_row_points(Board, human, Symbol, [HumanPoints, ComputerPoints]) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    count_four_in_a_row(Board, Symbol, HumanPoints),
    count_four_in_a_row(Board, OpponentSymbol, ComputerPoints).

count_four_in_a_row_points(Board, computer, Symbol, [HumanPoints, ComputerPoints]) :-
    get_opponent_symbol(Symbol, OpponentSymbol),
    count_four_in_a_row(Board, OpponentSymbol, HumanPoints),
    count_four_in_a_row(Board, Symbol, ComputerPoints).

count_four_in_a_row_points(_, _, _, [0, 0]). % Default case

%points

win_bonus(row5, 4).
win_bonus(_, 0).

count_total_points(WinType, CurrentPlayer, HumanCaptures, ComputerCaptures, [FourInARowHuman, FourInARowComputer], [HumanPoints, ComputerPoints]) :-
    win_bonus(WinType, WinBonus),
    calculate_player_points(CurrentPlayer, WinBonus, HumanCaptures, ComputerCaptures, FourInARowHuman, FourInARowComputer, HumanPoints, ComputerPoints).

win_bonus(row5, 4).
win_bonus(_, 0).

calculate_player_points(human, WinBonus, HumanCaptures, ComputerCaptures, FourInARowHuman, FourInARowComputer, HumanPoints, ComputerPoints) :-
    HumanPoints is HumanCaptures + WinBonus + FourInARowHuman,
    ComputerPoints is ComputerCaptures + FourInARowComputer.

calculate_player_points(computer, WinBonus, HumanCaptures, ComputerCaptures, FourInARowHuman, FourInARowComputer, HumanPoints, ComputerPoints) :-
    HumanPoints is HumanCaptures + FourInARowHuman,
    ComputerPoints is ComputerCaptures + WinBonus + FourInARowComputer.

% save_game_to_file - Saves the current game state to a file

% save_game_to_file(Board, HumanCaptures, ComputerCaptures, CurrentPlayer, Symbol) :-
%     writeln('Enter filename to save: '),
%     read_line_to_string(user_input, FileName),
%     open(FileName, write, Stream),
%     write(Stream, Board), write(Stream, '\n'),
%     write(Stream, 'Human Captures: '), write(Stream, HumanCaptures), write(Stream, '\n'),
%     write(Stream, 'Computer Captures: '), write(Stream, ComputerCaptures), write(Stream, '\n'),
%     write(Stream, 'Current Player: '), write(Stream, CurrentPlayer), write(Stream, '\n'),
%     write(Stream, 'Symbol: '), write(Stream, Symbol), write(Stream, '\n'),
%     close(Stream),
%     writeln('Game saved successfully!').


ask_user_continue(Choice) :-
    writeln('Press [Q] to quit without saving, [S] to save and quit, or any other key to continue: '),
    % read_line_to_string(user_input, Input),
    Input = "*",
    (   Input == "Q" -> Choice = quit
    ;   Input == "S" -> Choice = save
    ;   Choice = continue
    ).

