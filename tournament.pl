% Ask the user if they want to play another round
ask_user_play(Continue) :-
    writeln("Do you wanna play another round? (y/n): "),
    read_line_to_string(user_input, Input),
    (   
        Input = "y" -> Continue = true;
        Input = "n" -> Continue = false;
        writeln("Invalid input. Please enter 'y' for yes or 'n' for no."),
        ask_user_play(Continue)
    ).

% Announce the overall winner of the tournament based on the points
announce_tournament_winner(HumanPoints, ComputerPoints) :-
    (   
        HumanPoints > ComputerPoints -> writeln("Human wins the tournament!");
        HumanPoints < ComputerPoints -> writeln("Computer wins the tournament!");
        writeln("The tournament is a draw!")
    ).


human_wins_toss(Wins) :-
    writeln("Call the coin toss! (0 for heads / 1 for tails): "),
    read(UserInput),
    (   member(UserInput, [0, 1]) ->
        TossResult is random(2),
        heads_or_tails(UserInput, UserChoice),
        heads_or_tails(TossResult, TossOutcome),
        format("You chose ~w\n", [UserChoice]),
        format("The toss result was ~w\n", [TossOutcome]),
        Wins = (UserInput =:= TossResult)
    ;   writeln("Invalid input. Please enter 0 or 1."),
        human_wins_toss(Wins) % Recursive call for invalid input
    ).

heads_or_tails(0, heads).
heads_or_tails(1, tails).


% Determine who starts
determine_next_starter(HumanPoints, ComputerPoints, Starter) :-
    (   
        HumanPoints > ComputerPoints -> Starter = human;
        HumanPoints < ComputerPoints -> Starter = computer;
        human_wins_toss(Wins),
        (
            Wins -> Starter = human;
            Starter = computer
        )
    ).


new_tournament :-
    create_board(19, 19, Board),
    human_wins_toss(HumanWins),
    (
        HumanWins -> StartingPlayer = human;
        StartingPlayer = computer
    ),
    format("Starting player: ~w\n", [StartingPlayer]),
    tournament_helper(Board, StartingPlayer, 'W', 0, 0, 0, 0).

% Function to manage and facilitate the rounds of a tournament
tournament_helper(Board, StartingPlayer, StartingSymbol, HumanPoints, ComputerPoints, HumanCaptures, ComputerCaptures) :-
    print_board(Board),
    play_round(Board, StartingPlayer, StartingSymbol, HumanCaptures, ComputerCaptures, RoundPoints),
    nth0(0, RoundPoints, HumanRoundPoints),
    nth0(1, RoundPoints, ComputerRoundPoints),
    NewHumanPoints is HumanPoints + HumanRoundPoints,
    NewComputerPoints is ComputerPoints + ComputerRoundPoints,
    format("Human Points: ~w, Computer Points: ~w\n", [NewHumanPoints, NewComputerPoints]),
    ask_user_play(Continue),
    (
        Continue ->
        determine_next_starter(NewHumanPoints, NewComputerPoints, NextStarter),
        create_board(19, 19, NewBoard),
        tournament_helper(NewBoard, NextStarter, 'W', NewHumanPoints, NewComputerPoints, 0, 0);
        announce_tournament_winner(NewHumanPoints, NewComputerPoints)
    ).

