% Mikael Dunhem
% CS 355 - Summer 2017
% Assignment 2 - THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY

:- include('default-variables').
:- include('ground-forces').
:- include('air-forces').

main :-
    ( current_prolog_flag(os_argv, Argv) -> true; current_prolog_flag(argv, Argv) ),
    append([_, _, _, _, _, _], Rest, Argv),
    ( Rest = [Command|SubArgs] -> main(Command, SubArgs); usage ).

main(debug, Rest) :-
    writeln(Rest).

main(blah, Rest) :-
    Rest = ['--all'] -> banner, write('Hello All!'), nl;
    Rest = ['--missing'] -> banner, write('Hello Missing!'), nl;
    Rest = [] -> banner, groundForcesTest('Blah'), nl.

main(_, _) :- !, usage.

test(X) :-
    write(X).

banner :-
    writeln('------------------------------------------------------------------------------'),
    writeln(' THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY '),
    writeln('                Mike Dunhem - CS 355, Summer 2017, Project 2                  '),
    writeln('------------------------------------------------------------------------------'),
    writeln('').

usage :-
    banner,
    writeln(' Usage: warfare blah [--all | --missing]'),
    writeln('        warfare').
