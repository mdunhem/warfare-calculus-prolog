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
    number(Rest) -> banner, print_results(Rest);
    Rest = [_] -> usage.

main(_, _) :- !, usage.

banner :-
    format('+~`-t~95|+ ~n', []),
    format(
        '|~t~s~t~95||~n',
        ['THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY']
    ),
    format('|~t~s~t~95||~n', ['Mike Dunhem - CS 355, Summer 2017, Project 2']),
    format('+~`-t~95|+ ~n', []).

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
compute_results(CurrentDay, NumberOfDays) :- compute_results(CurrentDay, NumberOfDays, 0.0).
compute_results(CurrentDay, NumberOfDays, Displacement) :-
    ( CurrentDay =< NumberOfDays ->
        NextDay is CurrentDay + 1,
        attacker_ground_lethality(CurrentDay, AttackerGroundLethality),
        defender_ground_lethality(CurrentDay, DefenderGroundLethality),
        defender_surviving_CAS(CurrentDay, DCAS),
        attacker_surviving_CAS(CurrentDay, ACAS),
        defender_withdrawl_rate(CurrentDay, WithdrawlRate),
        UpdatedDisplacement is Displacement + WithdrawlRate,
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
            UpdatedDisplacement,
            DCAS,
            ACAS
        ),
        compute_results(NextDay, NumberOfDays, UpdatedDisplacement);
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
    Displacement,
    DCAS,
    ACAS) :-
    AttackerProsecutionValue is AttackerProsecution * 100,
    AttackerAttritionValue is AttackerAttrition * 100,
    DefenderAttritionValue is DefenderAttrition * 100,
    format(
        '|~t~D~t~5||~t~D~t~15||~t~D~t~25||~t~3f~t~35||~t~3f~t~45||~t~1f~t~55||~t~3f~t~65||~t~1f~t~75||~t~D~t~85||~t~D~t~95||~n',
        [
            Day,
            round(DefenderGroundLethality),
            round(AttackerGroundLethality),
            AttackerProsecutionValue,
            AttackerAttritionValue,
            WithdrawlRate,
            DefenderAttritionValue,
            Displacement,
            round(DCAS),
            round(ACAS)
        ]
    ),
    format('+~`-t~95|+ ~n', []).

/**
 * Prints the table header with lables.
 */
print_results(NumberOfDays) :-
    format('+~`-t~95|+ ~n', []),
    format(
        '|~t~s~t~5||~t~s~t~15||~t~s~t~25||~t~s~t~35||~t~s~t~45||~t~s~t~55||~t~s~t~65||~t~s~t~75||~t~s~t~85||~t~s~t~95||~n',
        ['Day', 'Dg(t)','Ag(t)', 'ag(t)', 'aa(t)', 'W(t)', 'ad(t)', 'SUM W', 'D CAS', 'A CAS']
    ),
    format('+~`-t~95|+ ~n', []),
    compute_results(1, NumberOfDays).
