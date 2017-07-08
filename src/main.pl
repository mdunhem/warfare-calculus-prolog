/**
 * Mikael Dunhem
 * CS 355 - Summer 2017
 * Assignment 2 - THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY
 */

:- include('equations').

/**
 * Main entry point when called from executable
 */
main :-
    ( current_prolog_flag(os_argv, Argv) -> true; current_prolog_flag(argv, Argv) ),
    append([_, _, _, _, _, _], Rest, Argv),
    ( Rest = [Command|SubArgs] -> main(Command, SubArgs); usage ).

main(days, Rest) :-
    Rest = [Days], atom_number(Days, DaysAsNumber) -> banner, print_results(DaysAsNumber);
    Rest = [_] -> usage.

main(_, _) :- !, usage.

banner :-
    format('+~`-t~133|+ ~n', []),
    format(
        '|~t~s~t~133||~n',
        ['THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY']
    ),
    format('|~t~s~t~133||~n', ['Mike Dunhem - CS 355, Summer 2017, Project 2']),
    format('+~`-t~133|+ ~n', []).

usage :-
    banner,
    writeln(' Executable Usage                                             '),
    writeln('   ./bin/warfare days <number_of_days>                        '),
    writeln('                                                              '),
    writeln(' Loading from REPL                                            '),
    writeln('   ["./src/main.pl"].                                         '),
    writeln('   main(days, <number_of_days>).                              '),
    writeln('                                                              '),
    writeln(' Options                                                      '),
    writeln('   number_of_days   -   Number of days to run the calculations').

/**
 * Counts up from CurrentDay to NumberOfDays and calls each equation to calculate
 * and print out the results.
 */
compute_results(CurrentDay, NumberOfDays) :-
    ( CurrentDay =< NumberOfDays ->
        NextDay is CurrentDay + 1,
        attacker_ground_lethality(CurrentDay, AttackerGroundLethality),
        defender_ground_lethality(CurrentDay, DefenderGroundLethality),
        defender_surviving_CAS(CurrentDay, DCAS),
        attacker_surviving_CAS(CurrentDay, ACAS),
        defender_withdrawl_rate(CurrentDay, WithdrawlRate),
        attacker_total_ground_lethality_attrition_rate(CurrentDay, AttackerAttrition),
        defender_total_ground_lethality_attrition_rate(CurrentDay, DefenderAttrition),
        attacker_prosecution_rate(CurrentDay, AttackerProsecution),
        print_row(
            CurrentDay,
            DefenderGroundLethality,
            AttackerGroundLethality,
            AttackerProsecution,
            AttackerAttrition,
            WithdrawlRate,
            DefenderAttrition,
            DCAS,
            ACAS
        ),
        compute_results(NextDay, NumberOfDays);
        true
    ).

/**
 * Prints out the values from the calculation in a nice formatted way.
 */
print_row(
    Day,
    DefenderGroundLethality,
    AttackerGroundLethality,
    AttackerProsecution,
    AttackerAttrition,
    WithdrawlRate,
    DefenderAttrition,
    DCAS,
    ACAS) :-
    AttackerProsecutionValue is AttackerProsecution * 100,
    AttackerAttritionValue is AttackerAttrition * 100,
    DefenderAttritionValue is DefenderAttrition * 100,
    format(
        '|~t~D~t~5||~t~D~t~21||~t~D~t~37||~t~3f~t~53||~t~3f~t~69||~t~1f~t~85||~t~3f~t~101||~t~D~t~117||~t~D~t~133||~n',
        [
            Day,
            round(DefenderGroundLethality),
            round(AttackerGroundLethality),
            AttackerProsecutionValue,
            AttackerAttritionValue,
            WithdrawlRate,
            DefenderAttritionValue,
            round(DCAS),
            round(ACAS)
        ]
    ),
    format('+~`-t~133|+ ~n', []).

/**
 * Prints the table header with lables.
 */
print_results(NumberOfDays) :-
    format('+~`-t~133|+ ~n', []),
    format(
        '|~t~s~t~5||~t~s~t~21||~t~s~t~37||~t~s~t~53||~t~s~t~69||~t~s~t~85||~t~s~t~101||~t~s~t~117||~t~s~t~133||~n',
        ['Day', 'Def Lethality','Att Lethality', 'Att Prosecution', 'Att Attrition', 'W Rate', 'Def Attrition', 'Def CAS', 'Att CAS']
    ),
    format('+~`-t~133|+ ~n', []),
    compute_results(1, NumberOfDays).
