% Mikael Dunhem
% CS 355 - Summer 2017
% Assignment 2 - THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY

:- include('equations').

main :-
    ( current_prolog_flag(os_argv, Argv) -> true; current_prolog_flag(argv, Argv) ),
    append([_, _, _, _, _, _], Rest, Argv),
    ( Rest = [Command|SubArgs] -> main(Command, SubArgs); usage ).

main(Days, _) :-
    banner,
    atom_number(Days, DaysAsNumber),
    compute_results(1, DaysAsNumber),
    print_results.

main(debug, Rest) :-
    writeln(Rest).

main(_, _) :- !, usage.

banner :-
    writeln('------------------------------------------------------------------------------'),
    writeln(' THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY '),
    writeln('                Mike Dunhem - CS 355, Summer 2017, Project 2                  '),
    writeln('------------------------------------------------------------------------------'),
    writeln('').

usage :-
    banner,
    writeln(' Usage: warfare <number_of_days>'),
    writeln('        warfare').

compute_results(CurrentDay, NumberOfDays) :-
    ( CurrentDay < NumberOfDays ->
        NextDay is CurrentDay + 1,
        attacker_ground_lethality(CurrentDay, _),
        defender_ground_lethality(CurrentDay, _),
        defender_surviving_CAS(CurrentDay, _),
        attacker_surviving_CAS(CurrentDay, _),
        defender_withdrawl_rate(CurrentDay, _),
        attacker_attrition_rate(CurrentDay, _),
        compute_results(NextDay, NumberOfDays);
        true
    ).

print_row([], _, _, _, _, _).
print_row(
    [DefenderHead | DefenderTail],
    [AttackerHead | AttackerTail],
    [AttackerAttritionHead | AttackerAttritionTail],
    [WithdrawlHead | WithdrawlTail],
    [DCASHead | DCASTail],
    [ACASHead | ACASTail]) :-
    AttackerAttritionValue is AttackerAttritionHead * 100,
    format(
        '|~t~D~t~16||~t~D~t~32||~t~3f~t~48||~t~1f~t~64||~t~D~t~80||~t~D~t~96||~n',
        [round(DefenderHead), round(AttackerHead), AttackerAttritionValue, WithdrawlHead, round(DCASHead), round(ACASHead)]
    ),
    format('+~`-t~96|+ ~n', []),
    print_row(DefenderTail, AttackerTail, AttackerAttritionTail, WithdrawlTail, DCASTail, ACASTail).

print_results :-
    format('+~`-t~96|+ ~n', []),
    format(
        '|~t~s~t~16||~t~s~t~32||~t~s~t~48||~t~s~t~64||~t~s~t~80||~t~s~t~96||~n',
        ['Def Lethality','Att Lethality', 'Att Attrition', 'W Rate', 'Def CAS', 'Att CAS']
    ),
    format('+~`-t~96|+ ~n', []),
    attacker_ground_lethality_list(AttackerGroundLethality),
    defender_ground_lethality_list(DefenderGroundLethality),
    attacker_surviving_CAS_list(ACAS),
    defender_surviving_CAS_list(DCAS),
    defender_withdrawl_rate_list(WithdrawlRate),
    attacker_attrition_rate_list(AttackerAttrition),
    print_row(DefenderGroundLethality, AttackerGroundLethality, AttackerAttrition, WithdrawlRate, DCAS, ACAS).
