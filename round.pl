% round.pl

% Load required modules
:- consult('board.pl').
:- consult('player.pl').
:- consult('strategy.pl').
:- consult('utilities.pl').

% % play_round - Executes a round of the game and returns the scores
% play_round(Board, CurrentPlayer, Symbol, HumanCaptures, ComputerCaptures, Scores) :-
%     make_move(Board, CurrentPlayer, Symbol, NewBoard, LastMove),
%     print_board(NewBoard),
%     % check_for_capture(NewBoard, Symbol, LastMove, CaptureResult, NewBoardWithCaptures),
%     % update_captures(CurrentPlayer, CaptureResult, HumanCaptures, ComputerCaptures, NewHumanCaptures, NewComputerCaptures),
%     (   check_win(NewBoardWithCaptures, LastMove, Symbol, NewHumanCaptures, NewComputerCaptures, Winner) ->
%         count_four_in_a_row_points(NewBoardWithCaptures, CurrentPlayer, Symbol, FourInARowPoints),
%         count_total_points(Winner, CurrentPlayer, NewHumanCaptures, NewComputerCaptures, FourInARowPoints, Scores)
%     ;   ask_user_continue(Choice),
%         (   Choice == continue ->
%             get_opponent_player(CurrentPlayer, NextPlayer),
%             get_opponent_symbol(Symbol, NextSymbol),
%             play_round(NewBoardWithCaptures, NextPlayer, NextSymbol, NewHumanCaptures, NewComputerCaptures, Scores)
%         ;   Choice == save ->
%             save_game_to_file(NewBoardWithCaptures, NewHumanCaptures, NewComputerCaptures, CurrentPlayer, Symbol),
%             Scores = [NewHumanCaptures, NewComputerCaptures]
%         ;   Choice == quit ->
%             writeln('Game ended without saving.'),
%             Scores = [NewHumanCaptures, NewComputerCaptures]
%         )
%     ).

    play_round(Board, CurrentPlayer, Symbol, HumanCaptures, ComputerCaptures, Scores) :-
        print_board(Board),
        format('Player ~w (~w)~n', [CurrentPlayer, Symbol]),
        make_move(Board, CurrentPlayer, Symbol, NewBoard, LastMove),
        print_board(NewBoard),

        % check_for_capture(NewBoard, Symbol, LastMove, CaptureResult, NewBoardWithCaptures),
        % update_captures(CurrentPlayer, CaptureResult, HumanCaptures, ComputerCaptures, NewHumanCaptures, NewComputerCaptures),
        % (   check_win(NewBoardWithCaptures, LastMove, Symbol, NewHumanCaptures, NewComputerCaptures, Winner) ->
        %     count_four_in_a_row_points(NewBoardWithCaptures, CurrentPlayer, Symbol, FourInARowPoints),
        %     count_total_points(Winner, CurrentPlayer, NewHumanCaptures, NewComputerCaptures, FourInARowPoints, Scores)
        % ;
        ask_user_continue(Choice),
        (   Choice == continue ->
            get_opponent_player(CurrentPlayer, NextPlayer),
            get_opponent_symbol(Symbol, NextSymbol),
            play_round(NewBoard, NextPlayer, NextSymbol, HumanCaptures, ComputerCaptures, Scores)
        ;   Choice == save ->
            save_game_to_file(NewBoard, HumanCaptures, ComputerCaptures, CurrentPlayer, Symbol),
            Scores = [HumanCaptures, ComputerCaptures]
        ;   Choice == quit ->
            writeln('Game ended without saving.'),
            Scores = [HumanCaptures, ComputerCaptures]
        ).
    


make_move(Board, human, Symbol, NewBoard, LastMove) :-
    human_play(Board, Symbol, NewBoard, LastMove).

make_move(Board, computer, Symbol, NewBoard, LastMove) :-
    computer_play(Board, Symbol, NewBoard, LastMove).

% make_move(Board, _, _, Board, []).

% Determines if the current player has won
check_win(Board, LastMove, Symbol, HumanCaptures, ComputerCaptures, Winner) :-
    (   check_for_five_in_a_row(Board, Symbol, LastMove) -> Winner = row5
    ;   (   Symbol == 'W', HumanCaptures >= 5
        ;   Symbol == 'B', ComputerCaptures >= 5
        ) -> Winner = capture5
    ;   Winner = none
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

count_total_points(Winner, CurrentPlayer, HumanCaptures, ComputerCaptures, FourInARowPoints, Scores) :-
    (   Winner \= none ->
        % Assign row 5 win bonus points to the winner
        WinPoints is 4,
        (   CurrentPlayer == human ->
            HumanPoints is HumanCaptures + WinPoints + FourInARowPoints,
            ComputerPoints = ComputerCaptures
        ;   ComputerPoints is ComputerCaptures + WinPoints + FourInARowPoints,
            HumanPoints = HumanCaptures
        )
    ;   HumanPoints = HumanCaptures,
        ComputerPoints = ComputerCaptures
    ),
    Scores = [HumanPoints, ComputerPoints].

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

