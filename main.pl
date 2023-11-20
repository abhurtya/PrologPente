% Entry point for the Pente program in Prolog
% Asks user to start a new game or load a game

:- consult('board.pl').
:- consult('utilities.pl').
:- consult('strategy.pl').
:- consult('player.pl').
:- consult('round.pl').
:- consult('tournament.pl').

:-use_module(library(system)).

% Seed the random number generator
:- get_time(Time), Seed is integer(Time), set_random(seed(Seed)).


show_menu :-
    writeln('-----------------------------------------------'),
    writeln('           Welcome to PENTE'),
    writeln(''),
    writeln('              Menu:'),
    writeln('           1. New Game'),
    writeln('           2. Load Game'),
    writeln('-----------------------------------------------').

% main game loop
main :-
    show_menu,
    read(UserChoice),
    process_choice(UserChoice).


process_choice(1) :- new_tournament.
process_choice(2) :- load_tournament.
process_choice(_) :-
    writeln('Invalid choice. Please select 1 or 2.'),
    main.

% Start the program
% :- main.
   